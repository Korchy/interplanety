<?php
//---------------------------------
require_once("dbconnected_vn.inc.php");
require_once("common.inc.php");
//---------------------------------
class Happy extends DBConnectedVn
{
	var $Comm;		// Common

	public function __construct() {
		// ����������� ��������
		parent::__construct();
		// �����������
		$this->Comm = new Common();
	}

	public function __destruct() {
		// ����������
		unset($this->Comm);
		// ���������� ��������
		parent::__destruct();
	}

	function Update() {
		// �������� ����������� ���������� ��� ������ �������
		// = 1 ��� ������������ ������� ���� ������� ������������, = 0 ��� 0 �������.
		$this->Sql->SqlQuery = "select spaceobject_id from vn_planet_r;";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			// ������������ - �� ��������
			while($tmp = $SQLRez->fetch_array()) {
				$Khappy = $this->PlanetHappy($tmp["spaceobject_id"]);
				$this->Sql->SqlQuery = "update vn_planet_r set happy = ".$Khappy." where spaceobject_id = ".$tmp["spaceobject_id"].";";
				$this->Sql->Exec();
			}
			$this->Sql->FreeResult($SQLRez);
		}
	}

	function PlanetHappy($PlanetId) {
		// ��������� ����������� ������������ �� ������ ���������� ����������� ��� ������� $PlanetId
		// ���������: ������� ������� ���-�� ��������� � ��������� ����� max � min ��� ������� ������������ � ��������� ������� �������� �� ���� �������������
		//  = 1 ��� ������������ ������� ���� ��������� ����������� � = 0 ��� 0
		$Khappy = 0;
		$this->Sql->SqlQuery = "select ssi.spaceobject_id, ssi.max, ssi.min, ssi.current_value from vn_starsystem_industry ssi where ssi.spaceobject_id='".$this->Sql->Escape($PlanetId)."';";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			if($this->Sql->Rows($SQLRez)!=0) {
				// �� ���� ����������� �������� �����������
				$KhSumm = 0;
				$KhNum = 0;
				while($tmp = $SQLRez->fetch_array()) {
					// ������� ������������ ������������ �� ������ ���������� �����������
					$Kh = $this->Comm->Otn($tmp["current_value"],$tmp["max"],$tmp["min"]);	// current_value � ����� �� ��������� min - max
					$KhSumm += $Kh;
					$KhNum ++;
				}
				$Khappy = $KhSumm/$KhNum;	// �������� ����������
			}
			$this->Sql->FreeResult($SQLRez);
		}
		return $Khappy;
	}
}
?>