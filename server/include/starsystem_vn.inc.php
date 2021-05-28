<?php
//---------------------------------
// Звездная система
//---------------------------------
require_once("dbconnected_vn.inc.php");
//---------------------------------
class StarSystemVn extends DBConnectedVn
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
	
	public function GetIdByRId($RId) {
		// Получить Id объекта (id) в системе по его RId (spaceobject_id)
		$this->Sql->SqlQuery = "select id from vn_starsystem where spaceobject_id='".$this->Sql->Escape($RId)."';";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			$tmp = $SQLRez->fetch_array();
			$Rez = $tmp["id"];
			$this->Sql->FreeResult($SQLRez);
			return $Rez;
		}
		return 0;
	}
	
	public function GetStarSystemXML($StarSystemId) {
		// Получить список объектов в системе с $StarSystemId
		// Возвращаются id в системе
		$this->Sql->SqlQuery = "select ss.id from vn_starsystem ss where ss.starsystem_id='".$this->Sql->Escape($StarSystemId)."';";
		$this->Sql->Exec();
		$XMLDoc = new DOMDocument('1.0','utf-8');
		$SpaceObjects = $XMLDoc->createElement('sos');
		if($SQLRez = $this->Sql->SqlRez) {
			// Создать по полученным данным XML-документ
			while($tmp = $SQLRez->fetch_array()) {
				$Node = $XMLDoc->createElement("so");
				$Node->setAttribute("id",$tmp["id"]);
				$SpaceObjects->appendChild($Node);
			}
			$this->Sql->FreeResult($SQLRez);
		}
		$XMLDoc->appendChild($SpaceObjects);
		return $XMLDoc;
	}
}
?>