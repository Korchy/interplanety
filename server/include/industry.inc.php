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
		// Конструктор родителя
		parent::__construct();
		// Конструктор
		
	}

	public function __destruct() {
		// Деструктор
		
		// Деструктор родителя
		parent::__destruct();
	}

	public function Produce() {
		// Производство продукции
		$this->Sql->SqlQuery = "select pr.happy, ssi.id, ssi.max, ssi.min, ssi.current_value, ssi.production, ssi.needs, ssi.last_updated from vn_planet_r pr inner join vn_starsystem_industry ssi on pr.spaceobject_id=ssi.spaceobject_id;";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			// Производства - по планетам
			while($tmp = $SQLRez->fetch_array()) {
				// Изменение current_value считается как: производство * коэффициент производства - потребление
				$PlanetHappy = $tmp["happy"];
				if(is_null($PlanetHappy)) $PlanetHappy = 0;
				$Kproizv = $this->KPreal($PlanetHappy,$tmp["max"],$tmp["min"],$tmp["current_value"]);
//echo "<p>&nbsp;&nbsp;&nbsp;&nbsp;".$tmp["id"]."&nbsp;&nbsp;&nbsp;&nbsp;".$Kproizv."<br>";
				$CV = $tmp["production"]*$Kproizv-$tmp["needs"];	// Произведено/потреблено за минуту
				// Произведено/потреблено с момента последнего обновления
				$ServerTimeObj = new ServerTime();
				$CurrentTime = $ServerTimeObj->GetServerTime();
				$DeltaTime = $CurrentTime - $tmp["last_updated"];	// в мс
				$K = $DeltaTime/60000;	// Коэффициент производства за минуту
				$CV = $CV*$K;
				$CV = floor($CV);	// Земля - Зерно: при 219771 - коэффициент 0.8 и производство -1. В принципе нормально, чтобы производилось больше - разгонять happy
				// Итоговое кол-во продукции
				$CV = $tmp["current_value"] + $CV;
				if($CV>$tmp["max"]) $CV = $tmp["max"];
				if($CV<$tmp["min"]) $CV = $tmp["min"];
				// Если изменилось - обновить
				if($tmp["current_value"]!=$CV) {
					$this->Sql->SqlQuery = "update vn_starsystem_industry set current_value=".$CV.", last_updated=".$CurrentTime." where id=".$tmp["id"].";";
					$this->Sql->Exec();
				}
			}
			$this->Sql->FreeResult($SQLRez);
		}
	}

	public function GetIndustries($StarSystemId) {
		// Добавить в XML-документ $XMLDoc в узел $RootNode данные по производствам для звездной системы $StarSystemId
		$XMLDoc = new DOMDocument('1.0','utf-8');
		$Industries = $XMLDoc->createElement('Industries');
		// Получить уровень игрока
		$Usr = new UserVn();
		$UserLevel = $Usr->GetUserLevel($_SESSION["vn_id"]);
		// Получить информацию по производству $IndustryId
//		$this->Sql->SqlQuery = "select id from vn_industry where level<=".$this->Sql->Escape($UserLevel).";";
		$this->Sql->SqlQuery = "select distinct ssi.industry_id as id from vn_starsystem ss inner join vn_starsystem_industry ssi on ss.spaceobject_id=ssi.spaceobject_id left outer join vn_industry i on ssi.industry_id=i.id where ss.starsystem_id = '".$this->Sql->Escape($StarSystemId)."' and i.level <= '".$this->Sql->Escape($UserLevel)."';";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			// Производства - по планетам
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
		// Добавить в XML-документ $XMLDoc в узел $RootNode данные по производству $IndustryId
		// Получить информацию по производству $IndustryId
		$this->Sql->SqlQuery = "select i.id, i.type, sm.img30x30 as typeimg30x30, i.name, i.img from vn_industry i left outer join vn_ship_modules sm on i.type=sm.id where i.id=".$this->Sql->Escape($IndustryId).";";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			// Производства - по планетам
			while($tmp = $SQLRez->fetch_assoc()) {
				while (list($key, $val) = each($tmp)) {
					switch($key) {
						case "id":	// id - не выводим
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
		// Добавить в XML-документ $XMLDoc в узел $RootNode данные по производствам для планеты c spaceobject_id = $PlanetId
//		$L = new Log(Common::TmpDir()."/log.log");
//		$StartTime = microtime(true)*1000;
		// Получить уровень игрока
		$Usr = new UserVn();
		$UserLevel = $Usr->GetUserLevel($_SESSION["vn_id"]);
		// Получить информацию по производству на планете
		$this->Sql->SqlQuery = "select ssi.id, ssi.industry_id, ssi.current_value, i.level, i.type from vn_planet_r p inner join vn_starsystem_industry ssi on p.spaceobject_id=ssi.spaceobject_id inner join vn_industry i on ssi.industry_id=i.id where p.spaceobject_id='".$this->Sql->Escape($PlanetId)."' and i.level<='".$this->Sql->Escape($UserLevel)."' and p.level<='".$this->Sql->Escape($UserLevel)."' order by ssi.industry_id;";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			// Производства - по планетам
			while($tmp = $SQLRez->fetch_assoc()) {
				while (list($key, $val) = each($tmp)) {
					switch($key) {
						case "id":	// id - в атрибут к узлу
							$IndId = $XMLDoc->createElement("industry");
							$IndId->setAttribute($key,$val);
							$RootNode->appendChild($IndId);
							break;
						case "level":	// level - не передаем
							break;
						default:
							$Node = $XMLDoc->createElement($key);
							$Value = $XMLDoc->createTextNode($val);
							$Node->appendChild($Value);
							$IndId->appendChild($Node);
					}
				}
/*
				// Коэффициент потребления в процентах (0-100) - Отношение current_value к max
				$Node = $XMLDoc->createElement("Kpot");
				$Comm = new Common();
				$Kpot = round($Comm->Otn($tmp["current_value"],$tmp["max"],$tmp["min"])*100);	// Kpot = 100 при current_value = max и = 0 при current_value = min
				$Value = $XMLDoc->createTextNode($Kpot);
				$Node->appendChild($Value);
				$IndId->appendChild($Node);
				// Коэффициент производства в процентах (0-100) - отношение сколько производит к тому, сколько может максимально производить
				$Node = $XMLDoc->createElement("Kpr");
				if($tmp["production"]-$tmp["needs"]<=0) $Kpr_real = 0;
				else $Kpr_real = $this->KPreal(0,$tmp["max"],$tmp["min"],$tmp["current_value"]);
				$Kpr_max = $this->KPmax(0,$tmp["max"],$tmp["min"],$tmp["current_value"]);
				$Kpr = round(($Kpr_real/$Kpr_max)*100);	// Kpr
				$Value = $XMLDoc->createTextNode($Kpr);
				$Node->appendChild($Value);
				$IndId->appendChild($Node);
*/
				// Цена
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
		// Вычисление реального коэффициента производства
		// Считается как: Коэффициент довольства + Коэффициент наличия товара
		// Т.к. каждый из коэффициентов от 0 до 1, общий коэффициент может быть от 0 до 2
		$Comm = new Common();
		$Kn = 1-$Comm->Otn($CurrentValue,$Max,$Min);	// Коэффициент наличия товара (= 1 при 0 произведенной продукции и = 0 при максимальном)
		$Ksumm = $Happy+$Kn;
		return $Ksumm;
	}

	public function KPmax($Happy,$Max,$Min,$CurrentValue) {
		// Вычисление максимального коэффициента производства
		// $Happy = max,$CurrentValue в промежутке $Max - $Min = 0
		$Km = $this->KPreal(1,1,0,0);
		return $Km;
	}

	public function GetCount($PlanetId,$IndustryId) {
		// Получить кол-во объекта производства $IndustryId на планете $PlanetId (spaceobject_id)
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
		// Изменить кол-во объекта производства $industryId (vn_starsystem_industry.id) на $diff
		// Коррекция чтобы за max/min не выходило
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
		// Занести данные
		$this->Sql->SqlQuery = "update vn_starsystem_industry set current_value = '".$this->Sql->Escape($newCount)."' where id = '".$this->Sql->Escape($industryId)."';";
		$this->Sql->Exec();
	}
	
	public function Name($IndustryId) {
		// Возвращае название (id в vn_text) производства по его $IndustryId
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
		// Возвращает industry_id по id из таблицы vn_starsystem_industry
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
		// Возвращает id по industry_id и spaceobject_id из таблицы vn_starsystem_industry
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