<?php
//---------------------------------
require_once("dbconnected_vn.inc.php");
require_once("common.inc.php");
//---------------------------------
class Happy extends DBConnectedVn
{
	var $Comm;		// Common

	public function __construct() {
		// Конструктор родителя
		parent::__construct();
		// Конструктор
		$this->Comm = new Common();
	}

	public function __destruct() {
		// Деструктор
		unset($this->Comm);
		// Деструктор родителя
		parent::__destruct();
	}

	function Update() {
		// Обновить коэффициент довольства для каждой планеты
		// = 1 при максимальном наличии всех товаров производства, = 0 при 0 товаров.
		$this->Sql->SqlQuery = "select spaceobject_id from vn_planet_r;";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			// Производства - по планетам
			while($tmp = $SQLRez->fetch_array()) {
				$Khappy = $this->PlanetHappy($tmp["spaceobject_id"]);
				$this->Sql->SqlQuery = "update vn_planet_r set happy = ".$Khappy." where spaceobject_id = ".$tmp["spaceobject_id"].";";
				$this->Sql->Exec();
			}
			$this->Sql->FreeResult($SQLRez);
		}
	}

	function PlanetHappy($PlanetId) {
		// Вычисляет коэффициент Производства на основе суммарного потребления для планеты $PlanetId
		// Считается: берется текущее кол-во продукции в процентах между max и min для каждого производства и считается среднее значение по всем производствам
		//  = 1 при максимальном наличии всей продукции потребления и = 0 при 0
		$Khappy = 0;
		$this->Sql->SqlQuery = "select ssi.spaceobject_id, ssi.max, ssi.min, ssi.current_value from vn_starsystem_industry ssi where ssi.spaceobject_id='".$this->Sql->Escape($PlanetId)."';";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			if($this->Sql->Rows($SQLRez)!=0) {
				// Из всех производств получить коэффициент
				$KhSumm = 0;
				$KhNum = 0;
				while($tmp = $SQLRez->fetch_array()) {
					// Подсчет коэффициента производства на основе имеющегося потребления
					$Kh = $this->Comm->Otn($tmp["current_value"],$tmp["max"],$tmp["min"]);	// current_value в долях от диапазона min - max
					$KhSumm += $Kh;
					$KhNum ++;
				}
				$Khappy = $KhSumm/$KhNum;	// Итоговый коэффициет
			}
			$this->Sql->FreeResult($SQLRez);
		}
		return $Khappy;
	}
}
?>