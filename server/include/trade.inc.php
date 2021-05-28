<?php
//---------------------------------
require_once("dbconnected_vn.inc.php");
require_once("common.inc.php");
require_once("user.inc.php");
require_once("industry.inc.php");
require_once("ships.inc.php");
require_once("starsystem_vn.inc.php");
require_once("quests.inc.php");
require_once("xmlex.inc.php");
//---------------------------------
class Trade extends DBConnectedVn
{
	var $Comm;			// Объект Common
	var $XEx;			// Объект XMLEx

	public function __construct() {
		// Конструктор родителя
		parent::__construct();
		// Конструктор
		$this->Comm = new Common();
		$this->XEx = new XMLEx();
	}

	public function __destruct() {
		// Деструктор
		unset($this->Comm);
		unset($this->XEx);
		// Деструктор родителя
		parent::__destruct();
	}

	function BuyDeal($UserId, $IndustryId, $BuyingCount, $ShipId) {
		// Покупка пользователем $UserId груза $IndustryId (vn.starsystem_industry.id) в количестве $BuyingCount для загрузки в корабль $ShipId
		$rez = $this->XEx->CreateXMLErr("117");	// Системная ошибка
		// Проверить на возможность совершения покупки
		if($BuyingCount <= 0) {
			// Покупка 0
			$rez = $this->XEx->CreateXMLErr("120");	// "Укажите количество"
		}
		else {
			$this->Sql->SqlQuery = "select ssi.spaceobject_id, ssi.current_value from vn_starsystem_industry ssi where ssi.id='".$this->Sql->Escape($IndustryId)."';";
			$this->Sql->Exec();
			if($SQLRez = $this->Sql->SqlRez) {
				while($tmp = $SQLRez->fetch_array()) {
					$Planet = $tmp["spaceobject_id"];
					// Покупка больше чем есть на планете
					if($tmp["current_value"] < $BuyingCount) {
						$rez = $this->XEx->CreateXMLErr("121");	// "Такого количества нет в наличии"
					}
					else {
						// Хватает ли денег на покупку
						$Usr = new UserVn();
						$Money = $Usr->GetUserGold($UserId);
						$Price = $this->IndustryPrice($IndustryId);
						if($Money < $BuyingCount * $Price) {
							$rez = $this->XEx->CreateXMLErr("113");	// "Не хватает денег"
						}
						else {
							// Нельзя купить больше, чем есть свободного места
							$S = new Ships();
							$Ind = new Industry();
							$indId = $Ind->industryIdById($IndustryId);
							$freeSpace = $S->freeSpaceForCargo($ShipId, $indId);
							if($BuyingCount > $freeSpace) {
								$rez = $this->XEx->CreateXMLErr("123");		// Байта: - Не хватает свободного места.
							}
							else {
								// Все условия прошли - совершаем покупку
								// Поместить груз в корабль
								$starSystem = new StarSystemVn();
								$sourceId = $starSystem->GetIdByRId($Planet);
								unset($starSystem);
								$S->addCargoToShip($ShipId, $indId, $sourceId, $BuyingCount, $Price);
								// Деньги пользователя
								$Usr->UpdateMoney($UserId, -$BuyingCount * $Price);
								// Остаток на планете
								$Ind->ChangeCountOn($IndustryId, -$BuyingCount);
								// Обновить условия квестов
								$Qst = new Quests();
								$Cond = $Qst->FormFinishConditionBuyCargo($indId, $BuyingCount, $Planet);
								$Qst->CheckFinishConditions($UserId, $Cond);
								// Покупка совершена
								// Создать XML для возврата
								$XMLDoc = new DOMDocument('1.0', 'utf-8');
								$RootNode = $XMLDoc->createElement("BuyCargo");
								$XMLDoc->appendChild($RootNode);
								$Node = $XMLDoc->createElement("cargo");	// Id продукции (vn_industry.id)
								$Value = $XMLDoc->createTextNode($indId);
								$Node->appendChild($Value);
								$RootNode->appendChild($Node);
								$Node = $XMLDoc->createElement("count");	// Количество продукции
								$Value = $XMLDoc->createTextNode($BuyingCount);
								$Node->appendChild($Value);
								$RootNode->appendChild($Node);
								$Node = $XMLDoc->createElement("planet");	// Id планеты покупки (vn_spaceobject.id)
								$Value = $XMLDoc->createTextNode($Planet);
								$Node->appendChild($Value);
								$RootNode->appendChild($Node);
								$rez = $XMLDoc;
							}
						}
					}
				}
				$this->Sql->FreeResult($SQLRez);
			}
		}
		return $rez;
	}

	function SellDeal($UserId, $cargoId, $sellingCount) {
		// Продажа пользователем $UserId груза $cargoId (vn_user_ships_cargo.id) в количестве $sellingCount
		$rez = $this->XEx->CreateXMLErr("117");	// Системная ошибка
		// Проверить на возможность совершения продажи
		if($sellingCount <= 0) {
			// Продажа 0
			$rez = $this->XEx->CreateXMLErr("120");	// "Укажите количество"
		}
		else {
			$sellingAll = false;	// true - продается все, что есть в танке
			$this->Sql->SqlQuery = "select usc.id, usc.user_ship_id, us.user_id as user_id, usc.cargo_id, usc.cargo_volume, us.a_planet, us.b_planet, ss.spaceobject_id as cargo_source, ssi.id as industry_id from vn_user_ships_cargo usc left outer join vn_user_ships us on usc.user_ship_id = us.id left outer join vn_starsystem ss on usc.cargo_source=ss.id left outer join vn_starsystem_industry ssi on ssi.industry_id=usc.cargo_id and ssi.spaceobject_id=us.a_planet where usc.id = '".$this->Sql->Escape($cargoId)."';";
			$this->Sql->Exec();
			if($SQLRez = $this->Sql->SqlRez) {
				while($tmp = $SQLRez->fetch_array()) {
					if($tmp["user_id"] == $UserId) {
						// Корабль принадлежит именно этому пользователю
						if($tmp["a_planet"] != $tmp["b_planet"]) {
							// Продажа в движении
							$rez = $this->XEx->CreateXMLErr("124");	// Байта: - Выгрузить груз можно только на планете.
						}
						else {
							if($sellingCount > $tmp["cargo_volume"]) {
								// Продажа больше чем есть груза
								$rez = $this->XEx->CreateXMLErr("121");	// "Такого количества нет в наличии"
							}
							else {
								// Проверки пройдены
								if($sellingCount == $tmp["cargo_volume"]) $sellingAll = true;	// Продали все, что было в танке
								$ss_industry_id = $tmp["industry_id"];			// Id производства на планете (vn_starsystem_industry.id)
								$industry_id = $tmp["cargo_id"];				// Id производства (vn_industry.id)
								$dealPlanet = $tmp["a_planet"];					// Планета совершения сделки (vn_spaceobject.id)
								$cargoSouucePlanet = $tmp["cargo_source"];		// Планета где был куплен груз (vn_spaceobject.id)
								// Все условия прошли - совершаем продажу
								// Цена продажи
								$price = $this->IndustryPrice($ss_industry_id);
								// Выгрузить груз из танка
								if($sellingAll == true) $this->Sql->SqlQuery = "delete from vn_user_ships_cargo where id = '".$this->Sql->Escape($cargoId)."';";
								else $this->Sql->SqlQuery = "update vn_user_ships_cargo set cargo_volume = cargo_volume - '".$this->Sql->Escape($sellingCount)."' where id = '".$this->Sql->Escape($cargoId)."';";
								$this->Sql->Exec();
								// Деньги пользователя
								$Usr = new UserVn();
								$Usr->UpdateMoney($UserId, $sellingCount * $price);
								// Остаток на планете
								$Ind = new Industry();
								$Ind->ChangeCountOn($ss_industry_id, $sellingCount);
								// Обновить условия квестов
								$Qst = new Quests();
								$Cond = $Qst->FormFinishConditionSellCargo($industry_id, $sellingCount, $cargoSouucePlanet, $dealPlanet);
								$Qst->CheckFinishConditions($UserId, $Cond);
								// Продажа совершена
								$XMLDoc = new DOMDocument('1.0', 'utf-8');
								$RootNode = $XMLDoc->createElement("SellCargo");
								$XMLDoc->appendChild($RootNode);
								$Node = $XMLDoc->createElement("cargo");	// Id продукции (vn_industry.id)
								$Value = $XMLDoc->createTextNode($industry_id);
								$Node->appendChild($Value);
								$RootNode->appendChild($Node);
								$Node = $XMLDoc->createElement("count");	// Количество груза
								$Value = $XMLDoc->createTextNode($sellingCount);
								$Node->appendChild($Value);
								$RootNode->appendChild($Node);
								$Node = $XMLDoc->createElement("source");	// Id планеты покупки груза (vn_spaceobject.id)
								$Value = $XMLDoc->createTextNode($cargoSouucePlanet);
								$Node->appendChild($Value);
								$RootNode->appendChild($Node);
								$Node = $XMLDoc->createElement("planet");	// Id планеты продажи (vn_spaceobject.id)
								$Value = $XMLDoc->createTextNode($dealPlanet);
								$Node->appendChild($Value);
								$RootNode->appendChild($Node);
								$rez = $XMLDoc;
							}
						}
					}
				}
				$this->Sql->FreeResult($SQLRez);
			}
		}
		return $rez;
	}

	function IndustryPrice($IndustryId) {
		// Вычисление стоимости продукции $IndustryId (vn_starsystem_industry.id)
		if($IndustryId==0) return 0;
		// Рассчитать цену
		$this->Sql->SqlQuery = "select i.base_price, ssi.current_value, min as min_value, max as max_value, ssi.production, ssi.needs,(select min(needs-production) from vn_starsystem_industry) as min_needs,(select max(needs-production) from vn_starsystem_industry) as max_needs from vn_industry i left outer join vn_starsystem_industry ssi on i.id=ssi.industry_id where ssi.id=".$this->Sql->Escape($IndustryId).";";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			while($tmp = $SQLRez->fetch_array()) {
				// Коэффициенты изменения стоимости
				// Коэффициент наличия товара на текущей планете
				// Имеющийся в данный момент товар на планете в процентном отношении к диапазону минимальное-максимальное кол-во товара на этой планете
				$CountK = $this->Comm->Otn($tmp["current_value"],$tmp["max_value"],$tmp["min_value"]);
				// Коэффициент востребованности товара во всей вселенной
				// Необходимость в данном товаре на планете в процентном отношении к диапазону мин-макс необходимость на других планетах вселенной
				//	(ищем мин необходимость во вселенной, ищем макс необходимость во вселенной - это задает диапазон. Считаем отношение с текущей планетой)
				$NeedsK = $this->Comm->Otn($tmp["needs"]-$tmp["production"],$tmp["max_needs"],$tmp["min_needs"]);
				// Стоимость считаем из базовой цены + коэффициента имеющегося кол-ва (0 - +1) + коэффициент востребованности (-0.5 - +0.5)
				$Price = round($tmp["base_price"]+(1-$CountK)*$tmp["base_price"]+(($NeedsK-0.5)*$tmp["base_price"]));
				if($Price<0) $Price = 0;
				$this->Sql->FreeResult($SQLRez);
				return $Price;
			}
			$this->Sql->FreeResult($SQLRez);
		}
		// Если на планете нет этого произоводства - цена 0
		return 0;
	}
}
?>