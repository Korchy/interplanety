<?php
//---------------------------------
require_once("spaceobjectr.inc.php");
//---------------------------------
class OrbitR extends SpaceObjectR
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
		// Получить данные по Orbit по его id
		$this->Sql->SqlQuery = "select so.type, so.id, sor.k_real, o.radius_s, o.radius_l, o.angle, o.speed, ss.starsystem_id as ss_id, ss.id as id_in_ss, ss.sub_id as sub_id_in_ss, ss.s_point_x, ss.s_point_y, ss.s_point_z from vn_spaceobject so left outer join vn_spaceobject_r sor on so.id=sor.spaceobject_id left outer join vn_orbit o on so.id=o.spaceobject_id left outer join vn_starsystem ss on so.id=ss.spaceobject_id where ss.id='".$this->Sql->Escape($SpaceObjectId)."';";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			$Rez = $this->CreateXMLFromSQLRez($SQLRez);
			$this->Sql->FreeResult($SQLRez);
			return $Rez;
		}
	}
}
?>