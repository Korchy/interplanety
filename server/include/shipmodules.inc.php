<?php
//---------------------------------
require_once("dbconnected_vn.inc.php");
//---------------------------------
class ShipModulesVn extends DBConnectedVn
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
	
	public function modulesVolume($ShipId, $ModuleType) {
		// Общий объем модулей, установленных на корабль $ShipId, типа $ModuleType
		$this->Sql->SqlQuery = "select sum(value) as volume from vn_user_ships_modules where user_ship_id='".$this->Sql->Escape($ShipId)."' and type='".$ModuleType."';";
		$this->Sql->Exec();
		$Volume = 0;
		if($SQLRez = $this->Sql->SqlRez) {
			// Производства - по планетам
			$tmp = $SQLRez->fetch_assoc();
			if($tmp["volume"] != NULL) $Volume = $tmp["volume"];
			$this->Sql->FreeResult($SQLRez);
		}
		return $Volume;
	}
}
?>