<?php
//---------------------------------
require_once("spaceobject.inc.php");
require_once("xmlex.inc.php");
//---------------------------------
class OrbitV extends SpaceObject
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
		// �������� ������ �� Orbit �� ��� id (��� ���������� ������)
		$this->Sql->SqlQuery = "select so.type, sov.price, sov.price_type, sov.img_60x60 from vn_spaceobject so left outer join vn_spaceobject_v sov on so.id=sov.spaceobject_id where so.id='".$this->Sql->Escape($SpaceObjectId)."';";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			$Rez = $this->CreateXMLFromSQLRez($SQLRez);
			$this->Sql->FreeResult($SQLRez);
			return $Rez;
		}
	}
	
	public function GetFullInfo($SpaceObjectId,$StarSystemId) {
		// �������� ������ �� Orbit �� ��� id (� ����������� ������)
		// ��� ����������� ����� - �� id � vn_user_starsystem �.�. ��� ��� spaceobject=24, � ��������� ������������� ������������� �� id � ������� ������������
		$this->Sql->SqlQuery = "select uss.id, so.type, sov.price, sov.price_type, sov.img_60x60, usso.radius_s, usso.radius_l, usso.angle, usso.speed from vn_spaceobject so left outer join vn_spaceobject_v sov on so.id=sov.spaceobject_id left outer join vn_user_starsystem uss on so.id=uss.spaceobject_id left outer join vn_user_starsystem_orbits_v usso on uss.id=usso.user_starsystem_id where uss.id='".$this->Sql->Escape($StarSystemId)."';";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			$Rez = $this->CreateXMLFromSQLRez($SQLRez);
			$this->Sql->FreeResult($SQLRez);
			return $Rez;
		}
	}
	
	public function UpdateParameters($Id, $RadiusL, $RadiusS, $Angle, $Speed) {
		// ������ ����������� ������ ����� ���������
		$XEx = new XMLEx();
		$XMLDoc = new DOMDocument();
		// ��������
		$Rez = true;
		if($Id==0) $Rez = false;
		// ��������� - �����
		if(!is_numeric($RadiusL)||!is_numeric($RadiusS)||!is_numeric($Angle)||!is_numeric($Speed)) $Rez = false;
		// �����������
		if($RadiusL<20||$RadiusL>2000||$RadiusS<20||$RadiusS>2000||$Angle<0||$Angle>360||$Speed<-10||$Speed>10) $Rez = false;
		if($Rez==false) {
			$XEx->CreateXMLErr("191",$XMLDoc);	// "������ ������� ���������� ������"
		}
		else {
			// �������� �������� - ��������� ������
			$this->Sql->SqlQuery = "update vn_user_starsystem_orbits_v set radius_s='".$this->Sql->Escape($RadiusS)."', radius_l='".$this->Sql->Escape($RadiusL)."', angle='".$this->Sql->Escape($Angle)."', speed='".$this->Sql->Escape($Speed)."' where user_starsystem_id='".$this->Sql->Escape($Id)."';";
			$this->Sql->Exec();
			if($this->Sql->SqlRez) $XEx->CreateXMLErr("0",$XMLDoc);	// ��� ������
			else $XEx->CreateXMLErr("191",$XMLDoc);					// "������ ������� ���������� ������"
		}
		return $XMLDoc;
	}
}
?>