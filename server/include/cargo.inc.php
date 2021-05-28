<?php
//---------------------------------
require_once("dbconnected_vn.inc.php");
require_once("trade.inc.php");
//---------------------------------
class CargoVn extends DBConnectedVn
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
	
	public function typeById($cargoId) {
		// Возвращает тип груза по его $cargoId
		$this->Sql->SqlQuery = "select type from vn_industry where id='".$this->Sql->Escape($cargoId)."';";
		$this->Sql->Exec();
		$cargoType = 0;
		if($SQLRez = $this->Sql->SqlRez) {
			// Производства - по планетам
			$tmp = $SQLRez->fetch_assoc();
			$cargoType = $tmp["type"];
			$this->Sql->FreeResult($SQLRez);
		}
		return $cargoType;
	}
	
	public function shipCargoPrice($shipId, $planetId) {
		// Возвращает общую стоимость груза корабля $shipId (vn_usrship.id) по ценам планеты $planetId (vn_spaceobject.id)
		$cargoPrice = 0;
		$this->Sql->SqlQuery = "select usc.cargo_id, sum(usc.cargo_volume) as volume, ssi.id from vn_user_ships_cargo usc left outer join vn_starsystem_industry ssi on usc.cargo_id = ssi.industry_id where usc.user_ship_id = '".$this->Sql->Escape($shipId)."' and ssi.spaceobject_id = '".$this->Sql->Escape($planetId)."' group by usc.cargo_id;";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			$IndTrade = new Trade();
			while($tmp = $SQLRez->fetch_assoc()) {
				$cargoPrice += $IndTrade->IndustryPrice($tmp["id"]) * $tmp["volume"];
			}
			$this->Sql->FreeResult($SQLRez);
		}
		return $cargoPrice;
	}
}
?>