<?php
//---------------------------------
require_once("spaceobjectr.inc.php");
//---------------------------------
class PlanetR extends SpaceObjectR
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
		// Получить данные по Planet по его spaceobject_id
		$this->Sql->SqlQuery = "select so.type, so.id, sor.k_real, p.img, p.name, pr.img_20x20, pr.img_24x24, pr.img_30x30, pr.fly_enable, pr.level, pr.happy, ss.starsystem_id as ss_id, ss.id as id_in_ss, ss.sub_id as sub_id_in_ss, ss.s_point_x, ss.s_point_y, ss.s_point_z from vn_spaceobject so left outer join vn_spaceobject_r sor on so.id=sor.spaceobject_id left outer join vn_planet p on so.id=p.spaceobject_id left outer join vn_planet_r pr on so.id=pr.spaceobject_id left outer join vn_starsystem ss on so.id=ss.spaceobject_id where ss.id='".$this->Sql->Escape($SpaceObjectId)."';";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			$Rez = $this->CreateXMLFromSQLRez($SQLRez);
			$this->Sql->FreeResult($SQLRez);
			return $Rez;
		}
	}
	
	public function ShipCountOnPlanet($UserId,$PlanetId) {
		// Возвращает количество кораблей пользователя на планете $PlanetId (spaceobject_id)
		$this->Sql->SqlQuery = "select count(id) as count from vn_user_ships where a_planet=b_planet and a_planet='".$this->Sql->Escape($PlanetId)."' and user_id='".$this->Sql->Escape($UserId)."';";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			$tmp = $SQLRez->fetch_array();
			$Rez = $tmp["count"];
			$this->Sql->FreeResult($SQLRez);
			return $Rez;
		}
	}
	
	public function SpaceObjectId($StarSystemPlanetId) {
		// Возвращает SpaceobjectId планеты по ее StarSystemId
		$this->Sql->SqlQuery = "select spaceobject_id from vn_starsystem where id='".$this->Sql->Escape($StarSystemPlanetId)."';";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			$tmp = $SQLRez->fetch_array();
			$Rez = $tmp["spaceobject_id"];
			$this->Sql->FreeResult($SQLRez);
			return $Rez;
		}
	}
	
	public function Name($PlanetId) {
		// Возвращает имя (индекс в vn_text) планеты по ее SpaceObject_id
		$this->Sql->SqlQuery = "select name from vn_planet where spaceobject_id='".$this->Sql->Escape($PlanetId)."';";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			$tmp = $SQLRez->fetch_array();
			$Rez = $tmp["name"];
			$this->Sql->FreeResult($SQLRez);
			return $Rez;
		}
	}
}
?>