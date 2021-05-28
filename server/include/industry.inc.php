<?php
//---------------------------------
require_once("dbconnected_vn.inc.php");
require_once("happy.inc.php");
require_once("common.inc.php");
require_once("user.inc.php");
require_once("servertime.inc.php");
require_once("trade.inc.php");
require_once("log.inc.php");
//---------------------------------
class Industry extends DBConnectedVn
{

	public function __construct() {
		// ����������� ��������
		parent::__construct();
		// �����������
		
	}

	public function __destruct() {
		// ����������
		
		// ���������� ��������
		parent::__destruct();
	}

	public function Produce() {
		// ������������ ���������
		$this->Sql->SqlQuery = "select pr.happy, ssi.id, ssi.max, ssi.min, ssi.current_value, ssi.production, ssi.needs, ssi.last_updated from vn_planet_r pr inner join vn_starsystem_industry ssi on pr.spaceobject_id=ssi.spaceobject_id;";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			// ������������ - �� ��������
			while($tmp = $SQLRez->fetch_array()) {
				// ��������� current_value ��������� ���: ������������ * ����������� ������������ - �����������
				$PlanetHappy = $tmp["happy"];
				if(is_null($PlanetHappy)) $PlanetHappy = 0;
				$Kproizv = $this->KPreal($PlanetHappy,$tmp["max"],$tmp["min"],$tmp["current_value"]);
//echo "<p>&nbsp;&nbsp;&nbsp;&nbsp;".$tmp["id"]."&nbsp;&nbsp;&nbsp;&nbsp;".$Kproizv."<br>";
				$CV = $tmp["production"]*$Kproizv-$tmp["needs"];	// �����������/���������� �� ������
				// �����������/���������� � ������� ���������� ����������
				$ServerTimeObj = new ServerTime();
				$CurrentTime = $ServerTimeObj->GetServerTime();
				$DeltaTime = $CurrentTime - $tmp["last_updated"];	// � ��
				$K = $DeltaTime/60000;	// ����������� ������������ �� ������
				$CV = $CV*$K;
				$CV = floor($CV);	// ����� - �����: ��� 219771 - ����������� 0.8 � ������������ -1. � �������� ���������, ����� ������������� ������ - ��������� happy
				// �������� ���-�� ���������
				$CV = $tmp["current_value"] + $CV;
				if($CV>$tmp["max"]) $CV = $tmp["max"];
				if($CV<$tmp["min"]) $CV = $tmp["min"];
				// ���� ���������� - ��������
				if($tmp["current_value"]!=$CV) {
					$this->Sql->SqlQuery = "update vn_starsystem_industry set current_value=".$CV.", last_updated=".$CurrentTime." where id=".$tmp["id"].";";
					$this->Sql->Exec();
				}
			}
			$this->Sql->FreeResult($SQLRez);
		}
	}

	public function GetIndustries($StarSystemId) {
		// �������� � XML-�������� $XMLDoc � ���� $RootNode ������ �� ������������� ��� �������� ������� $StarSystemId
		$XMLDoc = new DOMDocument('1.0','utf-8');
		$Industries = $XMLDoc->createElement('Industries');
		// �������� ������� ������
		$Usr = new UserVn();
		$UserLevel = $Usr->GetUserLevel($_SESSION["vn_id"]);
		// �������� ���������� �� ������������ $IndustryId
//		$this->Sql->SqlQuery = "select id from vn_industry where level<=".$this->Sql->Escape($UserLevel).";";
		$this->Sql->SqlQuery = "select distinct ssi.industry_id as id from vn_starsystem ss inner join vn_starsystem_industry ssi on ss.spaceobject_id=ssi.spaceobject_id left outer join vn_industry i on ssi.industry_id=i.id where ss.starsystem_id = '".$this->Sql->Escape($StarSystemId)."' and i.level <= '".$this->Sql->Escape($UserLevel)."';";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			// ������������ - �� ��������
			while($tmp = $SQLRez->fetch_assoc()) {
				while (list($key, $val) = each($tmp)) {
					switch($key) {
						case "id":	// id
							$IndId = $XMLDoc->createElement("industry");
							$IndId->setAttribute($key,$val);
							$Industries->appendChild($IndId);
							break;
						default:
//							$Node = $XMLDoc->createElement($key);
//							$Value = $XMLDoc->createTextNode($val);
//							$Node->appendChild($Value);
//							$IndId->appendChild($Node);
					}
				}
			}
			$this->Sql->FreeResult($SQLRez);
		}
		$XMLDoc->appendChild($Industries);
		return $XMLDoc;
	}

	public function GetIndustry($IndustryId,$XMLDoc,$RootNode) {
		// �������� � XML-�������� $XMLDoc � ���� $RootNode ������ �� ������������ $IndustryId
		// �������� ���������� �� ������������ $IndustryId
		$this->Sql->SqlQuery = "select i.id, i.type, sm.img30x30 as typeimg30x30, i.name, i.img from vn_industry i left outer join vn_ship_modules sm on i.type=sm.id where i.id=".$this->Sql->Escape($IndustryId).";";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			// ������������ - �� ��������
			while($tmp = $SQLRez->fetch_assoc()) {
				while (list($key, $val) = each($tmp)) {
					switch($key) {
						case "id":	// id - �� �������
							break;
						default:
							$Node = $XMLDoc->createElement($key);
							$Value = $XMLDoc->createTextNode($val);
							$Node->appendChild($Value);
							$RootNode->appendChild($Node);
					}
				}
			}
			$this->Sql->FreeResult($SQLRez);
		}
	}

	public function GetPlanetIndustry($PlanetId,$XMLDoc,$RootNode) {
		// �������� � XML-�������� $XMLDoc � ���� $RootNode ������ �� ������������� ��� ������� c spaceobject_id = $PlanetId
//		$L = new Log(Common::TmpDir()."/log.log");
//		$StartTime = microtime(true)*1000;
		// �������� ������� ������
		$Usr = new UserVn();
		$UserLevel = $Usr->GetUserLevel($_SESSION["vn_id"]);
		// �������� ���������� �� ������������ �� �������
		$this->Sql->SqlQuery = "select ssi.id, ssi.industry_id, ssi.current_value, i.level, i.type from vn_planet_r p inner join vn_starsystem_industry ssi on p.spaceobject_id=ssi.spaceobject_id inner join vn_industry i on ssi.industry_id=i.id where p.spaceobject_id='".$this->Sql->Escape($PlanetId)."' and i.level<='".$this->Sql->Escape($UserLevel)."' and p.level<='".$this->Sql->Escape($UserLevel)."' order by ssi.industry_id;";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			// ������������ - �� ��������
			while($tmp = $SQLRez->fetch_assoc()) {
				while (list($key, $val) = each($tmp)) {
					switch($key) {
						case "id":	// id - � ������� � ����
							$IndId = $XMLDoc->createElement("industry");
							$IndId->setAttribute($key,$val);
							$RootNode->appendChild($IndId);
							break;
						case "level":	// level - �� ��������
							break;
						default:
							$Node = $XMLDoc->createElement($key);
							$Value = $XMLDoc->createTextNode($val);
							$Node->appendChild($Value);
							$IndId->appendChild($Node);
					}
				}
/*
				// ����������� ����������� � ��������� (0-100) - ��������� current_value � max
				$Node = $XMLDoc->createElement("Kpot");
				$Comm = new Common();
				$Kpot = round($Comm->Otn($tmp["current_value"],$tmp["max"],$tmp["min"])*100);	// Kpot = 100 ��� current_value = max � = 0 ��� current_value = min
				$Value = $XMLDoc->createTextNode($Kpot);
				$Node->appendChild($Value);
				$IndId->appendChild($Node);
				// ����������� ������������ � ��������� (0-100) - ��������� ������� ���������� � ����, ������� ����� ����������� �����������
				$Node = $XMLDoc->createElement("Kpr");
				if($tmp["production"]-$tmp["needs"]<=0) $Kpr_real = 0;
				else $Kpr_real = $this->KPreal(0,$tmp["max"],$tmp["min"],$tmp["current_value"]);
				$Kpr_max = $this->KPmax(0,$tmp["max"],$tmp["min"],$tmp["current_value"]);
				$Kpr = round(($Kpr_real/$Kpr_max)*100);	// Kpr
				$Value = $XMLDoc->createTextNode($Kpr);
				$Node->appendChild($Value);
				$IndId->appendChild($Node);
*/
				// ����
				$Trd = new Trade();
				$Price = $Trd->IndustryPrice($tmp["id"]);
				$Node = $XMLDoc->createElement("price");
				$Value = $XMLDoc->createTextNode($Price);
				$Node->appendChild($Value);
				$IndId->appendChild($Node);
			}
			$this->Sql->FreeResult($SQLRez);
		}
//		$EndTime = microtime(true)*1000;
//		$L->Add($EndTime-$StartTime);
	}

	public function KPreal($Happy,$Max,$Min,$CurrentValue) {
		// ���������� ��������� ������������ ������������
		// ��������� ���: ����������� ���������� + ����������� ������� ������
		// �.�. ������ �� ������������� �� 0 �� 1, ����� ����������� ����� ���� �� 0 �� 2
		$Comm = new Common();
		$Kn = 1-$Comm->Otn($CurrentValue,$Max,$Min);	// ����������� ������� ������ (= 1 ��� 0 ������������� ��������� � = 0 ��� ������������)
		$Ksumm = $Happy+$Kn;
		return $Ksumm;
	}

	public function KPmax($Happy,$Max,$Min,$CurrentValue) {
		// ���������� ������������� ������������ ������������
		// $Happy = max,$CurrentValue � ���������� $Max - $Min = 0
		$Km = $this->KPreal(1,1,0,0);
		return $Km;
	}

	public function GetCount($PlanetId,$IndustryId) {
		// �������� ���-�� ������� ������������ $IndustryId �� ������� $PlanetId (spaceobject_id)
		$Rez = 0;
		$this->Sql->SqlQuery = "select current_value from vn_starsystem_industry where spaceobject_id=".$this->Sql->Escape($PlanetId)." and industry_id=".$this->Sql->Escape($IndustryId).";";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			while($tmp = $SQLRez->fetch_array()) {
				$Rez = $tmp["current_value"];
			}
			$this->Sql->FreeResult($SQLRez);
		}
		return $Rez;
	}
	
	public function ChangeCountOn($industryId, $diff) {
		// �������� ���-�� ������� ������������ $industryId (vn_starsystem_industry.id) �� $diff
		// ��������� ����� �� max/min �� ��������
		$newCount = 0;
		$this->Sql->SqlQuery = "select min, max, current_value from vn_starsystem_industry where id='".$this->Sql->Escape($industryId)."';";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			while($tmp = $SQLRez->fetch_array()) {
				$newCount = $tmp["current_value"] + $diff;
				if($newCount > $tmp["max"]) $newCount = $tmp["max"];
				if($newCount < $tmp["min"]) $newCount = $tmp["min"];
			}
			$this->Sql->FreeResult($SQLRez);
		}
		// ������� ������
		$this->Sql->SqlQuery = "update vn_starsystem_industry set current_value = '".$this->Sql->Escape($newCount)."' where id = '".$this->Sql->Escape($industryId)."';";
		$this->Sql->Exec();
	}
	
	public function Name($IndustryId) {
		// ��������� �������� (id � vn_text) ������������ �� ��� $IndustryId
		$this->Sql->SqlQuery = "select name from vn_industry where id='".$this->Sql->Escape($IndustryId)."';";
		$this->Sql->Exec();
		$rez = "";
		if($SQLRez = $this->Sql->SqlRez) {
			$tmp = $SQLRez->fetch_array();
			$rez = $tmp["name"];
			$this->Sql->FreeResult($SQLRez);
		}
		return $rez;
	}
	
	public function industryIdById($Id) {
		// ���������� industry_id �� id �� ������� vn_starsystem_industry
		$this->Sql->SqlQuery = "select industry_id from vn_starsystem_industry where id='".$this->Sql->Escape($Id)."';";
		$this->Sql->Exec();
		$rez = 0;
		if($SQLRez = $this->Sql->SqlRez) {
			$tmp = $SQLRez->fetch_array();
			$rez = $tmp["industry_id"];
			$this->Sql->FreeResult($SQLRez);
		}
		return $rez;
	}
	
	public function idByIndustry($industryId, $spaceobjectId) {
		// ���������� id �� industry_id � spaceobject_id �� ������� vn_starsystem_industry
		$this->Sql->SqlQuery = "select id from vn_starsystem_industry where industry_id = '".$this->Sql->Escape($industryId)."' and spaceobject_id = '".$this->Sql->Escape($spaceobjectId)."';";
		$this->Sql->Exec();
		$rez = 0;
		if($SQLRez = $this->Sql->SqlRez) {
			$tmp = $SQLRez->fetch_array();
			$rez = $tmp["id"];
			$this->Sql->FreeResult($SQLRez);
		}
		return $rez;
	}
	
}
?>