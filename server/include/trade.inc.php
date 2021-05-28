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
	var $Comm;			// ������ Common
	var $XEx;			// ������ XMLEx

	public function __construct() {
		// ����������� ��������
		parent::__construct();
		// �����������
		$this->Comm = new Common();
		$this->XEx = new XMLEx();
	}

	public function __destruct() {
		// ����������
		unset($this->Comm);
		unset($this->XEx);
		// ���������� ��������
		parent::__destruct();
	}

	function BuyDeal($UserId, $IndustryId, $BuyingCount, $ShipId) {
		// ������� ������������� $UserId ����� $IndustryId (vn.starsystem_industry.id) � ���������� $BuyingCount ��� �������� � ������� $ShipId
		$rez = $this->XEx->CreateXMLErr("117");	// ��������� ������
		// ��������� �� ����������� ���������� �������
		if($BuyingCount <= 0) {
			// ������� 0
			$rez = $this->XEx->CreateXMLErr("120");	// "������� ����������"
		}
		else {
			$this->Sql->SqlQuery = "select ssi.spaceobject_id, ssi.current_value from vn_starsystem_industry ssi where ssi.id='".$this->Sql->Escape($IndustryId)."';";
			$this->Sql->Exec();
			if($SQLRez = $this->Sql->SqlRez) {
				while($tmp = $SQLRez->fetch_array()) {
					$Planet = $tmp["spaceobject_id"];
					// ������� ������ ��� ���� �� �������
					if($tmp["current_value"] < $BuyingCount) {
						$rez = $this->XEx->CreateXMLErr("121");	// "������ ���������� ��� � �������"
					}
					else {
						// ������� �� ����� �� �������
						$Usr = new UserVn();
						$Money = $Usr->GetUserGold($UserId);
						$Price = $this->IndustryPrice($IndustryId);
						if($Money < $BuyingCount * $Price) {
							$rez = $this->XEx->CreateXMLErr("113");	// "�� ������� �����"
						}
						else {
							// ������ ������ ������, ��� ���� ���������� �����
							$S = new Ships();
							$Ind = new Industry();
							$indId = $Ind->industryIdById($IndustryId);
							$freeSpace = $S->freeSpaceForCargo($ShipId, $indId);
							if($BuyingCount > $freeSpace) {
								$rez = $this->XEx->CreateXMLErr("123");		// �����: - �� ������� ���������� �����.
							}
							else {
								// ��� ������� ������ - ��������� �������
								// ��������� ���� � �������
								$starSystem = new StarSystemVn();
								$sourceId = $starSystem->GetIdByRId($Planet);
								unset($starSystem);
								$S->addCargoToShip($ShipId, $indId, $sourceId, $BuyingCount, $Price);
								// ������ ������������
								$Usr->UpdateMoney($UserId, -$BuyingCount * $Price);
								// ������� �� �������
								$Ind->ChangeCountOn($IndustryId, -$BuyingCount);
								// �������� ������� �������
								$Qst = new Quests();
								$Cond = $Qst->FormFinishConditionBuyCargo($indId, $BuyingCount, $Planet);
								$Qst->CheckFinishConditions($UserId, $Cond);
								// ������� ���������
								// ������� XML ��� ��������
								$XMLDoc = new DOMDocument('1.0', 'utf-8');
								$RootNode = $XMLDoc->createElement("BuyCargo");
								$XMLDoc->appendChild($RootNode);
								$Node = $XMLDoc->createElement("cargo");	// Id ��������� (vn_industry.id)
								$Value = $XMLDoc->createTextNode($indId);
								$Node->appendChild($Value);
								$RootNode->appendChild($Node);
								$Node = $XMLDoc->createElement("count");	// ���������� ���������
								$Value = $XMLDoc->createTextNode($BuyingCount);
								$Node->appendChild($Value);
								$RootNode->appendChild($Node);
								$Node = $XMLDoc->createElement("planet");	// Id ������� ������� (vn_spaceobject.id)
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
		// ������� ������������� $UserId ����� $cargoId (vn_user_ships_cargo.id) � ���������� $sellingCount
		$rez = $this->XEx->CreateXMLErr("117");	// ��������� ������
		// ��������� �� ����������� ���������� �������
		if($sellingCount <= 0) {
			// ������� 0
			$rez = $this->XEx->CreateXMLErr("120");	// "������� ����������"
		}
		else {
			$sellingAll = false;	// true - ��������� ���, ��� ���� � �����
			$this->Sql->SqlQuery = "select usc.id, usc.user_ship_id, us.user_id as user_id, usc.cargo_id, usc.cargo_volume, us.a_planet, us.b_planet, ss.spaceobject_id as cargo_source, ssi.id as industry_id from vn_user_ships_cargo usc left outer join vn_user_ships us on usc.user_ship_id = us.id left outer join vn_starsystem ss on usc.cargo_source=ss.id left outer join vn_starsystem_industry ssi on ssi.industry_id=usc.cargo_id and ssi.spaceobject_id=us.a_planet where usc.id = '".$this->Sql->Escape($cargoId)."';";
			$this->Sql->Exec();
			if($SQLRez = $this->Sql->SqlRez) {
				while($tmp = $SQLRez->fetch_array()) {
					if($tmp["user_id"] == $UserId) {
						// ������� ����������� ������ ����� ������������
						if($tmp["a_planet"] != $tmp["b_planet"]) {
							// ������� � ��������
							$rez = $this->XEx->CreateXMLErr("124");	// �����: - ��������� ���� ����� ������ �� �������.
						}
						else {
							if($sellingCount > $tmp["cargo_volume"]) {
								// ������� ������ ��� ���� �����
								$rez = $this->XEx->CreateXMLErr("121");	// "������ ���������� ��� � �������"
							}
							else {
								// �������� ��������
								if($sellingCount == $tmp["cargo_volume"]) $sellingAll = true;	// ������� ���, ��� ���� � �����
								$ss_industry_id = $tmp["industry_id"];			// Id ������������ �� ������� (vn_starsystem_industry.id)
								$industry_id = $tmp["cargo_id"];				// Id ������������ (vn_industry.id)
								$dealPlanet = $tmp["a_planet"];					// ������� ���������� ������ (vn_spaceobject.id)
								$cargoSouucePlanet = $tmp["cargo_source"];		// ������� ��� ��� ������ ���� (vn_spaceobject.id)
								// ��� ������� ������ - ��������� �������
								// ���� �������
								$price = $this->IndustryPrice($ss_industry_id);
								// ��������� ���� �� �����
								if($sellingAll == true) $this->Sql->SqlQuery = "delete from vn_user_ships_cargo where id = '".$this->Sql->Escape($cargoId)."';";
								else $this->Sql->SqlQuery = "update vn_user_ships_cargo set cargo_volume = cargo_volume - '".$this->Sql->Escape($sellingCount)."' where id = '".$this->Sql->Escape($cargoId)."';";
								$this->Sql->Exec();
								// ������ ������������
								$Usr = new UserVn();
								$Usr->UpdateMoney($UserId, $sellingCount * $price);
								// ������� �� �������
								$Ind = new Industry();
								$Ind->ChangeCountOn($ss_industry_id, $sellingCount);
								// �������� ������� �������
								$Qst = new Quests();
								$Cond = $Qst->FormFinishConditionSellCargo($industry_id, $sellingCount, $cargoSouucePlanet, $dealPlanet);
								$Qst->CheckFinishConditions($UserId, $Cond);
								// ������� ���������
								$XMLDoc = new DOMDocument('1.0', 'utf-8');
								$RootNode = $XMLDoc->createElement("SellCargo");
								$XMLDoc->appendChild($RootNode);
								$Node = $XMLDoc->createElement("cargo");	// Id ��������� (vn_industry.id)
								$Value = $XMLDoc->createTextNode($industry_id);
								$Node->appendChild($Value);
								$RootNode->appendChild($Node);
								$Node = $XMLDoc->createElement("count");	// ���������� �����
								$Value = $XMLDoc->createTextNode($sellingCount);
								$Node->appendChild($Value);
								$RootNode->appendChild($Node);
								$Node = $XMLDoc->createElement("source");	// Id ������� ������� ����� (vn_spaceobject.id)
								$Value = $XMLDoc->createTextNode($cargoSouucePlanet);
								$Node->appendChild($Value);
								$RootNode->appendChild($Node);
								$Node = $XMLDoc->createElement("planet");	// Id ������� ������� (vn_spaceobject.id)
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
		// ���������� ��������� ��������� $IndustryId (vn_starsystem_industry.id)
		if($IndustryId==0) return 0;
		// ���������� ����
		$this->Sql->SqlQuery = "select i.base_price, ssi.current_value, min as min_value, max as max_value, ssi.production, ssi.needs,(select min(needs-production) from vn_starsystem_industry) as min_needs,(select max(needs-production) from vn_starsystem_industry) as max_needs from vn_industry i left outer join vn_starsystem_industry ssi on i.id=ssi.industry_id where ssi.id=".$this->Sql->Escape($IndustryId).";";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			while($tmp = $SQLRez->fetch_array()) {
				// ������������ ��������� ���������
				// ����������� ������� ������ �� ������� �������
				// ��������� � ������ ������ ����� �� ������� � ���������� ��������� � ��������� �����������-������������ ���-�� ������ �� ���� �������
				$CountK = $this->Comm->Otn($tmp["current_value"],$tmp["max_value"],$tmp["min_value"]);
				// ����������� ���������������� ������ �� ���� ���������
				// ������������� � ������ ������ �� ������� � ���������� ��������� � ��������� ���-���� ������������� �� ������ �������� ���������
				//	(���� ��� ������������� �� ���������, ���� ���� ������������� �� ��������� - ��� ������ ��������. ������� ��������� � ������� ��������)
				$NeedsK = $this->Comm->Otn($tmp["needs"]-$tmp["production"],$tmp["max_needs"],$tmp["min_needs"]);
				// ��������� ������� �� ������� ���� + ������������ ���������� ���-�� (0 - +1) + ����������� ���������������� (-0.5 - +0.5)
				$Price = round($tmp["base_price"]+(1-$CountK)*$tmp["base_price"]+(($NeedsK-0.5)*$tmp["base_price"]));
				if($Price<0) $Price = 0;
				$this->Sql->FreeResult($SQLRez);
				return $Price;
			}
			$this->Sql->FreeResult($SQLRez);
		}
		// ���� �� ������� ��� ����� ������������� - ���� 0
		return 0;
	}
}
?>