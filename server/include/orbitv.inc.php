<?php
//---------------------------------
require_once("spaceobject.inc.php");
require_once("xmlex.inc.php");
//---------------------------------
class OrbitV extends SpaceObject
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

	public function GetInfo($SpaceObjectId) {
		// Получить данные по Orbit по его id (без параметров орбиты)
		$this->Sql->SqlQuery = "select so.type, sov.price, sov.price_type, sov.img_60x60 from vn_spaceobject so left outer join vn_spaceobject_v sov on so.id=sov.spaceobject_id where so.id='".$this->Sql->Escape($SpaceObjectId)."';";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			$Rez = $this->CreateXMLFromSQLRez($SQLRez);
			$this->Sql->FreeResult($SQLRez);
			return $Rez;
		}
	}
	
	public function GetFullInfo($SpaceObjectId,$StarSystemId) {
		// Получить данные по Orbit по его id (с параметрами орбиты)
		// Для виртуальных орбит - по id в vn_user_starsystem т.к. они все spaceobject=24, а параметры редактируются пользователем по id в системе пользователя
		$this->Sql->SqlQuery = "select uss.id, so.type, sov.price, sov.price_type, sov.img_60x60, usso.radius_s, usso.radius_l, usso.angle, usso.speed from vn_spaceobject so left outer join vn_spaceobject_v sov on so.id=sov.spaceobject_id left outer join vn_user_starsystem uss on so.id=uss.spaceobject_id left outer join vn_user_starsystem_orbits_v usso on uss.id=usso.user_starsystem_id where uss.id='".$this->Sql->Escape($StarSystemId)."';";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			$Rez = $this->CreateXMLFromSQLRez($SQLRez);
			$this->Sql->FreeResult($SQLRez);
			return $Rez;
		}
	}
	
	public function UpdateParameters($Id, $RadiusL, $RadiusS, $Angle, $Speed) {
		// Задать виртуальной орбите новые параметры
		$XEx = new XMLEx();
		$XMLDoc = new DOMDocument();
		// Проверки
		$Rez = true;
		if($Id==0) $Rez = false;
		// Параметры - числа
		if(!is_numeric($RadiusL)||!is_numeric($RadiusS)||!is_numeric($Angle)||!is_numeric($Speed)) $Rez = false;
		// Ограничения
		if($RadiusL<20||$RadiusL>2000||$RadiusS<20||$RadiusS>2000||$Angle<0||$Angle>360||$Speed<-10||$Speed>10) $Rez = false;
		if($Rez==false) {
			$XEx->CreateXMLErr("191",$XMLDoc);	// "Ошибка задания параметров орбиты"
		}
		else {
			// Проверки пройдены - сохранить данные
			$this->Sql->SqlQuery = "update vn_user_starsystem_orbits_v set radius_s='".$this->Sql->Escape($RadiusS)."', radius_l='".$this->Sql->Escape($RadiusL)."', angle='".$this->Sql->Escape($Angle)."', speed='".$this->Sql->Escape($Speed)."' where user_starsystem_id='".$this->Sql->Escape($Id)."';";
			$this->Sql->Exec();
			if($this->Sql->SqlRez) $XEx->CreateXMLErr("0",$XMLDoc);	// Нет ошибок
			else $XEx->CreateXMLErr("191",$XMLDoc);					// "Ошибка задания параметров орбиты"
		}
		return $XMLDoc;
	}
}
?>