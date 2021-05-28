<?php
//---------------------------------
require_once("dbconnected_vn.inc.php");
require_once("trade.inc.php");
require_once("crystals.inc.php");
require_once("user.inc.php");
require_once("xmlex.inc.php");
require_once("shipmodules.inc.php");
require_once("cargo.inc.php");
//require_once("log.inc.php");
//---------------------------------
class Ships extends DBConnectedVn
{
	var $XEx;			// Объект XMLEx
	private $Modules;	// Модули корабля
	private $Cargo;		// Груз корабля

	public function __construct() {
		// Конструктор родителя
		parent::__construct();
		// Конструктор
		$this->XEx = new XMLEx();
		$this->Modules = new ShipModulesVn();
		$this->Cargo = new CargoVn();
	}

	public function __destruct() {
		// Деструктор
		unset($this->Cargo);
		unset($this->Modules);
		unset($this->XEx);
		// Деструктор родителя
		parent::__destruct();
	}

	public function GetShipsXML($UserId,$XMLDoc,$RootNode) {
		// Получить данные по кораблям пользователя $UserId в виде XML-узлов (добавить в $XMLDoc в узел $RootNode)
		$this->Sql->SqlQuery = "select us.id as usership_id, s.id as ship_id, s.name, s.speed, s.volume, s.img40x40, s.img200x150, s.img28x28, us.a_planet, us.b_planet, us.a_time, us.b_time from vn_user_ships us inner join vn_ship s on us.ship_id=s.id where us.user_id='".$this->Sql->Escape($UserId)."';";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			while($tmp = $SQLRez->fetch_assoc()) {
				$ShipNode = $XMLDoc->createElement("Ship");
				$RootNode->appendChild($ShipNode);
				while(list($key, $val) = each($tmp)) {
					switch($key) {
						case "usership_id":	// id корабля - в атрибут
							$ShipNode->setAttribute("id", $val);
							break;
						default:
							$Node = $XMLDoc->createElement($key);
							$Value = $XMLDoc->createTextNode($val);
							$Node->appendChild($Value);
							$ShipNode->appendChild($Node);
					}
				}
			}
			$this->Sql->FreeResult($SQLRez);
		}
	}
	
	public function GetShipModulesXML($UserId, $ShipId, $XMLDoc, $RootNode) {
		// Получить данные по модулям корабля $ShipId пользователя $UserId в виде XML-узлов (добавить в $XMLDoc в узел $RootNode)
		$this->Sql->SqlQuery = "select usm.id, sm.type, sm.id as type_id, sm.img30x30, usm.mount, usm.value from vn_user_ships_modules usm left outer join vn_ship_modules sm on usm.type=sm.id where usm.user_ship_id='".$this->Sql->Escape($ShipId)."';";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			while($tmp = $SQLRez->fetch_assoc()) {
				$ModuleNode = $XMLDoc->createElement("module");
				$RootNode->appendChild($ModuleNode);
				while(list($key, $val) = each($tmp)) {
					switch($key) {
						case "id":	// id модуля - в атрибут
							$ModuleNode->setAttribute($key, $val);
							break;
						default:
							$Node = $XMLDoc->createElement($key);
							$Value = $XMLDoc->createTextNode($val);
							$Node->appendChild($Value);
							$ModuleNode->appendChild($Node);
					}
				}
			}
			$this->Sql->FreeResult($SQLRez);
		}
	}
	
	public function GetShipCargoXML($ShipId) {
		// Получить данные по грузам корабля $ShipId (vn_user_ships.id)в виде XML
		$XMLDoc = new DOMDocument('1.0','utf-8');
		$ShipCargo = $XMLDoc->createElement('cargos');
		$this->Sql->SqlQuery = "select usc.id, usc.cargo_id as industry_id, i.type, usc.cargo_source, usc.cargo_volume, usc.cargo_price from vn_user_ships_cargo usc left outer join vn_industry i on usc.cargo_id=i.id where usc.user_ship_id='".$this->Sql->Escape($ShipId)."';";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			while($tmp = $SQLRez->fetch_assoc()) {
				$CargoNode = $XMLDoc->createElement("cargo");
				$ShipCargo->appendChild($CargoNode);
				while(list($key, $val) = each($tmp)) {
					switch($key) {
						case "id":	// id груза - в атрибут
							$CargoNode->setAttribute($key, $val);
							break;
						default:
							$Node = $XMLDoc->createElement($key);
							$Value = $XMLDoc->createTextNode($val);
							$Node->appendChild($Value);
							$CargoNode->appendChild($Node);
					}
				}
			}
			$this->Sql->FreeResult($SQLRez);
		}
		$XMLDoc->appendChild($ShipCargo);
		return $XMLDoc;
	}
	
	public function GetBuyingShipsXML($UserId,$XMLDoc,$RootNode) {
		// Получить доступные для покупки пользователю (по его user_id) корабли в виде XML-узлов (добавить в $XMLDoc в узел $RootNode)
		$this->Sql->SqlQuery = "select s.id, s.name, s.price, s.price_type, s.img40x40 from vn_ship s inner join vn_user_data ud on s.level<=ud.level where !isnull(price) and ud.user_id='".$this->Sql->Escape($UserId)."';";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			while($tmp = $SQLRez->fetch_assoc()) {
				$ShipNode = $XMLDoc->createElement("Ship");
				$RootNode->appendChild($ShipNode);
				while (list($key, $val) = each($tmp)) {
					switch($key) {
						case "id":	// id - в атрибут
							$ShipNode->setAttribute($key,$val);
							break;
						default:
							$Node = $XMLDoc->createElement($key);
							$Value = $XMLDoc->createTextNode($val);
							$Node->appendChild($Value);
							$ShipNode->appendChild($Node);
					}
				}
			}
			$this->Sql->FreeResult($SQLRez);
		}
	}

	public function BuyShip($UserId,$ShipModelId,$PlanetId,$XMLDoc) {
		// Покупка корабля модели $ShipModelId
		// Проверить на возможность покупки
		$ShipPrice = 0;
		$PriceType = "G";
		// Хватает денег и корабль доступен по уровню
		$this->Sql->SqlQuery = "select s.id, s.price, s.price_type, ud.money, ud.crystals from vn_user_data ud left outer join vn_ship s on ud.level>=s.level where ud.user_id='".$this->Sql->Escape($UserId)."' and s.id='".$this->Sql->Escape($ShipModelId)."';";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			// Корабль недоступен по уровню (в результате получено 0 строк)
			if($this->Sql->Rows($SQLRez)!=1) {
				$this->Sql->FreeResult($SQLRez);
				return $this->XEx->CreateXMLErr("112",$XMLDoc);		// "Корабль слишком высокого уровня"
			}
			// Нехватает денег/кристаллов
			while($tmp = $SQLRez->fetch_array()) {
				if($tmp["price_type"]=='C') {
					if($tmp["price"]>$tmp["crystals"]) {
						$this->Sql->FreeResult($SQLRez);
						return $this->XEx->CreateXMLErr("114",$XMLDoc);	// "Не хватает кристаллов"
					}
				}
				else {
					if($tmp["price"]>$tmp["money"]) {
						$this->Sql->FreeResult($SQLRez);
						return $this->XEx->CreateXMLErr("113",$XMLDoc);		// "Не хватате денег"
					}
				}
				// Запомнить стоимость корабля и чем платить
				$ShipPrice = $tmp["price"];
				$PriceType = $tmp["price_type"];
			}
			$this->Sql->FreeResult($SQLRez);
		}
		// Не превышено кол-во кораблей на уровень
		// Количество уже имеющихся кораблей
		$Usr = new UserVn();
		$ShipsCount = $Usr->GetShipsCount($UserId);
		// Кол-во кораблей доступных на уровне
		$this->Sql->SqlQuery = "select ud.user_id,ud.level, max(sol.ships) as max_ships from vn_user_data ud left outer join vn_ship_on_level sol on ud.level>=sol.level where ud.user_id='".$this->Sql->Escape($UserId)."' group by ud.user_id;";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			while($tmp = $SQLRez->fetch_array()) {
				// Если доступно меньше - возврат
				if($tmp["max_ships"]<=$ShipsCount) {
					$this->Sql->FreeResult($SQLRez);
					return $this->XEx->CreateXMLErr("115",$XMLDoc);	// "Байта: На текущем уровне я не смогу управлять таким количеством кораблей"
				}
			}
			$this->Sql->FreeResult($SQLRez);
		}
		// Если дошли до сюда - значит можно покупать
		// Добавить корабль
		$NewShipId = $this->AddShipToUser($UserId, $ShipModelId, $PlanetId, $PlanetId);
		// Снять деньги/кристаллы
		if($PriceType=="C")	$this->Sql->SqlQuery = "update vn_user_data set crystals=crystals-".$ShipPrice." where user_id='".$this->Sql->Escape($UserId)."';";
		else $this->Sql->SqlQuery = "update vn_user_data set money=money-".$ShipPrice." where user_id='".$this->Sql->Escape($UserId)."';";
		$this->Sql->Exec();
		// Возврат подтверждения покупки
		$ShipNode = $XMLDoc->createElement('Ship');
		// Получить данные по купленному кораблю
		$this->Sql->SqlQuery = "select us.id as usership_id, s.id as ship_id, s.name, s.speed, s.tanks, s.tanks_volume, s.img40x40, s.img200x150, s.img28x28, us.a_planet, us.b_planet, us.a_time, us.b_time, us.tank_1, us.tank_1_vol, us.tank_2, us.tank_2_vol, us.tank_3, us.tank_3_vol from vn_user_ships us inner join vn_ship s on us.ship_id=s.id where us.id='".$this->Sql->Escape($NewShipId)."';";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			while($tmp = $SQLRez->fetch_assoc()) {
				while (list($key, $val) = each($tmp)) {
					switch($key) {
						case "usership_id":	// id корабля - в атрибут
							$ShipNode->setAttribute("id", $val);
							break;
						default:
							if(substr($key,0,5)=='tank_'&&substr($key,5,1)>$tmp['tanks']) break;		// Больше чем tanks трюмов не выводим
							$Node = $XMLDoc->createElement($key);
							$Value = $XMLDoc->createTextNode($val);
							$Node->appendChild($Value);
							$ShipNode->appendChild($Node);
					}
				}
			}
			$this->Sql->FreeResult($SQLRez);
		}
		// Добавим еще цену
		$Node = $XMLDoc->createElement("selling_price");
		$Value = $XMLDoc->createTextNode($this->GetSellingShipPrice($NewShipId));
		$Node->appendChild($Value);
		$ShipNode->appendChild($Node);
		$Node = $XMLDoc->createElement("price");
		$Value = $XMLDoc->createTextNode($ShipPrice);
		$Node->appendChild($Value);
		$ShipNode->appendChild($Node);
		$Node = $XMLDoc->createElement("price_type");
		$Value = $XMLDoc->createTextNode($PriceType);
		$Node->appendChild($Value);
		$ShipNode->appendChild($Node);
		// Занести все данные в дерево XML
		$XMLDoc->appendChild($ShipNode);
	}

	public function GetSellingShipsXML($UserId, $PlanetId) {
		// Получить доступные для продажи корабли пользователя на планете $PlanetId (vn_spaceobject.id) в виде XML
		$XMLDoc = new DOMDocument('1.0','utf-8');
		$SellingShips = $XMLDoc->createElement('SellingShips');
		$XMLDoc->appendChild($SellingShips);
		// Продаются корабли только за Gold
		$this->Sql->SqlQuery = "select us.id, us.ship_id, s.price, s.price_type from vn_user_ships us left outer join vn_ship s on us.ship_id = s.id where us.a_planet = us.b_planet and us.a_planet='".$this->Sql->Escape($PlanetId)."' and us.user_id='".$this->Sql->Escape($UserId)."';";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			while($tmp = $SQLRez->fetch_assoc()) {
				$ShipNode = $XMLDoc->createElement("Ship");
				$ShipNode->setAttribute("id", $tmp["id"]);
				$SellingShips->appendChild($ShipNode);
				// Базовая цена
				$Price = $tmp["price"];
				if($tmp["price_type"]=="C") {
					// Если продается премиум-корабль (купленный за кристаллы)
					$Crys = new Crystals();
					$Price *= $Crys->SellCrystalsRate();
				}
				// Цена груза на корабле (по ценам планеты, гда продается корабль)
				$Price += $this->Cargo->shipCargoPrice($tmp["id"], $PlanetId);
				// Добавить общую цену
				$Node = $XMLDoc->createElement("price");
				$Value = $XMLDoc->createTextNode($Price);
				$Node->appendChild($Value);
				$ShipNode->appendChild($Node);
			}
			$this->Sql->FreeResult($SQLRez);
		}
		return $XMLDoc;
	}

	public function GetShipModelInfoXML($ShipId,$XMLDoc,$RootNode) {
		// Получить данные по модели корабля (по его id) в виде XML-узлов (добавить в $XMLDoc в узел $RootNode)
		$this->Sql->SqlQuery = "select s.id, s.level, s.name, s.speed, s.tanks, s.tanks_volume, s.img200x150 as img from vn_ship s where s.id='".$this->Sql->Escape($ShipId)."';";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			while($tmp = $SQLRez->fetch_assoc()) {
				$ShipNode = $XMLDoc->createElement("Ship");
				$RootNode->appendChild($ShipNode);
				while (list($key, $val) = each($tmp)) {
					switch($key) {
						case "id":	// id - в атрибут
							$ShipNode->setAttribute($key,$val);
							break;
						default:
							$Node = $XMLDoc->createElement($key);
							$Value = $XMLDoc->createTextNode($val);
							$Node->appendChild($Value);
							$ShipNode->appendChild($Node);
					}
				}
			}
			$this->Sql->FreeResult($SQLRez);
		}
	}

	public function SellShip($UserId, $ShipId) {
		// Продажа корабля $ShipId (vn_user_ships.id)
		// Проверить на возможность продажи
		// Не последний корабль
		$Usr = new UserVn();
		$ShipsCount = $Usr->GetShipsCount($UserId);
		if($ShipsCount <= 1) return $this->XEx->CreateXMLErr("116");;	// "Байта: - Продажа единственного корабля невозможна."
		// Нельзя продать корабль в полете
		$this->Sql->SqlQuery = "select us.a_planet, us.b_planet from vn_user_ships us where us.id='".$this->Sql->Escape($ShipId)."';";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			while($tmp = $SQLRez->fetch_array()) {
				// Если планета не одна - возврат
				if($tmp["a_planet"]!=$tmp["b_planet"]) {
					$this->Sql->FreeResult($SQLRez);
					return $this->XEx->CreateXMLErr("118");;	// "Байта: Невозможно продать корабль в полете"
				}
			}
			$this->Sql->FreeResult($SQLRez);
		}
		// Если дошли до сюда - значит можно продать
		$XMLDoc = new DOMDocument('1.0','utf-8');
		// Получить цену
		$Price = $this->GetSellingShipPrice($ShipId);
		// Добавить деньги
		$this->Sql->SqlQuery = "update vn_user_data set money = money + ".$Price." where user_id='".$this->Sql->Escape($UserId)."';";
		$this->Sql->Exec();
		// Убрать корабль
		$this->Sql->SqlQuery = "delete from vn_user_ships where id='".$this->Sql->Escape($ShipId)."';";
		$this->Sql->Exec();
		// Возврат подтверждения продажи
		$ShipNode = $XMLDoc->createElement('Ship');
		$ShipNode->setAttribute("Id",$ShipId);
		// Возвращаем цену, за которую продали
		$Node = $XMLDoc->createElement("price");
		$Value = $XMLDoc->createTextNode($Price);
		$Node->appendChild($Value);
		$ShipNode->appendChild($Node);
		// Занести все данные в дерево XML
		$XMLDoc->appendChild($ShipNode);
		return $XMLDoc;
	}

	public function GetSellingShipPrice($ShipId) {
		// Получить продажную стоимость корабля пользователя $ShipId (vn_user_ship.id)
		$Price = 0;
		$this->Sql->SqlQuery = "select s.price, s.price_type, us.a_planet from vn_user_ships us left outer join vn_ship s on us.ship_id = s.id where us.id = '".$this->Sql->Escape($ShipId)."';";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			while($tmp = $SQLRez->fetch_assoc()) {
				// Базовая цена корабля
				$Price = $tmp["price"];
				if($tmp["price_type"]=="C") {
					// Если продается премиум-корабль (купленный за кристаллы)
					$Crys = new Crystals();
					$Price *= $Crys->SellCrystalsRate();
				}
				// Цена груза на корабле (по ценам планеты, гда продается корабль)
				$Price += $this->Cargo->shipCargoPrice($ShipId, $tmp["a_planet"]);
			}
			$this->Sql->FreeResult($SQLRez);
		}
		return $Price;
	}

	public function AddShipToUser($UserId,$ShipId,$PlanetAId,$PlanetBId) {
		// Добавить корабль $ShipId (на планету $PlanetId) пользователю $UserId
		$this->Sql->SqlQuery = "insert into vn_user_ships (`lock`, user_id, ship_id, a_planet, b_planet) values (".$this->Sql->Escape($UserId).", ".$this->Sql->Escape($UserId).", ".$this->Sql->Escape($ShipId).", ".$this->Sql->Escape($PlanetAId).", ".$this->Sql->Escape($PlanetBId).");";
		$this->Sql->Exec();
		// Id корабля
		$UserShipId = 0;
		$this->Sql->SqlQuery = "select id from vn_user_ships where `lock`='".$this->Sql->Escape($UserId)."';";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			while($tmp = $SQLRez->fetch_array()) {
				$UserShipId = $tmp["id"];
				$this->Sql->SqlQuery = "update vn_user_ships set `lock`=0 where id='".$UserShipId."';";
				$this->Sql->Exec();
			}
			$this->Sql->FreeResult($SQLRez);
		}
		// Добавить кораблю дефолтные модули
		$this->Sql->SqlQuery = "insert into vn_user_ships_modules (user_ship_id, type, mount, value) (select '".$UserShipId."' as user_ship_id, type, mount, value from vn_ship_modules_default where ship_id='".$this->Sql->Escape($ShipId)."');";
		$this->Sql->Exec();
		// Возвратить Id корабля
		return $UserShipId;
	}
	
	public function freeSpaceForCargo($shipId, $cargoId) {
		// Получить свободное место на корабле с $ShipId (vn_user_ships.id) под груз $IndustryId (vn_industry.id)
		$freeSpace = 0;
		// По $CargoId получить его тип
		$cargoType = $this->Cargo->typeById($cargoId);
		// Всего места под груз типа $cargoType
		$freeTypedSpace = $this->Modules->modulesVolume($shipId, $cargoType);
		// Всего места под груз типа "универсальный"
		$freeTUSpace = $this->Modules->modulesVolume($shipId, 1);
		if($freeTypedSpace + $freeTUSpace == 0) return 0;
		// Уже имеется груза типа $cargoType на корабле
		$cargoVolume = $this->engagedCargoVolume($shipId, $cargoType);
		// Свободного места под груз $cargoType в типовых модулях
		if($cargoVolume < $freeTypedSpace) $freeSpace = $freeTypedSpace - $cargoVolume;
		else $cargoVolume -= $freeTypedSpace;	// В $cargoVolume остается только груз, лежащий в универсальных танках (TU)
		// Свободного места в универсальных модулях TU
		$cargoArr = $this->cargoByTypes($shipId);	// Грузы на корабле по типам
		foreach($cargoArr as $currentCargo) {
			$currentCargoFreeSpace = $this->Modules->modulesVolume($shipId, $currentCargo[0]);
			$currentCargoVolume = $currentCargo[1];
			if($currentCargoVolume > $currentCargoFreeSpace) $freeTUSpace -= $currentCargoVolume - $currentCargoFreeSpace;
		}
		$freeSpace += $freeTUSpace;
		return $freeSpace;
	}
	
	public function engagedCargoVolume($shipId, $cargoType) {
		// Объем занятого места на корабле $shipId грузом типа $cargoType
		$engagedVolume = 0;
		$this->Sql->SqlQuery = "select sum(usc.cargo_volume) as volume from vn_user_ships_cargo usc left outer join vn_industry i on usc.cargo_id=i.id where usc.user_ship_id='".$this->Sql->Escape($shipId)."' and i.type='".$this->Sql->Escape($cargoType)."';";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			$tmp = $SQLRez->fetch_assoc();
			$engagedVolume = $tmp["volume"];
			$this->Sql->FreeResult($SQLRez);
		}
		return $engagedVolume;
	}
	
	public function cargoByTypes($shipId) {
		// Массив с объемами грузов по типу, загруженными на корабль $shipId
		$rez = array();
		$this->Sql->SqlQuery = "select i.type, sum(usc.cargo_volume) as volume from vn_user_ships_cargo usc left outer join vn_industry i on usc.cargo_id=i.id where usc.user_ship_id='".$this->Sql->Escape($shipId)."' group by i.type;";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			while($tmp = $SQLRez->fetch_array()) {
				$rez[] = array($tmp["type"], $tmp["volume"]);
			}
			$this->Sql->FreeResult($SQLRez);
		}
		return $rez;
	}
	
	public function addCargoToShip($shipId, $cargoId, $cargoSourceId, $volume, $price) {
		// Добавление груза $cargoId (vn_industry.id) в корабль $shipId с планеты $cargoSourceId (vn_starsystem.id) в объеме $volume, купленного за цену $price
		// Проверить, не было ли такого груза уже загружено
		$this->Sql->SqlQuery = "select usc.id from vn_user_ships_cargo usc where usc.user_ship_id='".$this->Sql->Escape($shipId)."' and usc.cargo_id='".$this->Sql->Escape($cargoId)."' and usc.cargo_source='".$this->Sql->Escape($cargoSourceId)."';";
		$this->Sql->Exec();
		$updateCargoId = 0;
		if($SQLRez = $this->Sql->SqlRez) {
			while($tmp = $SQLRez->fetch_array()) {
				$updateCargoId = $tmp["id"];
			}
			$this->Sql->FreeResult($SQLRez);
		}
		if($updateCargoId != 0) {
			// Такой груз есть - увеличить количество
			$this->Sql->SqlQuery = "update vn_user_ships_cargo usc set usc.cargo_price = round((usc.cargo_price * usc.cargo_volume + '".$this->Sql->Escape($price)."' * '".$this->Sql->Escape($volume)."')/(usc.cargo_volume + '".$this->Sql->Escape($volume)."')), usc.cargo_volume = usc.cargo_volume + '".$this->Sql->Escape($volume)."' where usc.id='".$this->Sql->Escape($updateCargoId)."';";
			$this->Sql->Exec();
		}
		else {
			// Такого груза нет - добавить новым
			$this->Sql->SqlQuery = "insert into vn_user_ships_cargo (user_ship_id, cargo_id, cargo_source, cargo_volume, cargo_price) values ('".$this->Sql->Escape($shipId)."', '".$this->Sql->Escape($cargoId)."', '".$this->Sql->Escape($cargoSourceId)."', '".$this->Sql->Escape($volume)."', '".$this->Sql->Escape($price)."');";
			$this->Sql->Exec();
		}
		
	}
}
?>