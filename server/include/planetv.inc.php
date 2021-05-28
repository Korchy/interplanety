<?php
//---------------------------------
require_once("spaceobject.inc.php");
//---------------------------------
class PlanetV extends SpaceObject
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

	public function GetInfo($SpaceObjectId) {
		// �������� ������ �� Planet �� ��� spaceobject_id
		$this->Sql->SqlQuery = "select so.type, sov.price, sov.price_type, sov.img_60x60, p.img, p.name from vn_spaceobject so left outer join vn_spaceobject_v sov on so.id=sov.spaceobject_id left outer join vn_planet p on so.id=p.spaceobject_id where so.id='".$this->Sql->Escape($SpaceObjectId)."';";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			$Rez = $this->CreateXMLFromSQLRez($SQLRez);
			$this->Sql->FreeResult($SQLRez);
			return $Rez;
		}
	}
	
}
?>