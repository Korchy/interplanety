<?php
//---------------------------------
require_once("dbconnected_vn.inc.php");
//---------------------------------
class SpaceObject extends DBConnectedVn
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
	
	public function TypeById($SpaceObjectId) {
		// ���������� �������� ��� SpaceObject �� ��� SpaceObjectId
		$this->Sql->SqlQuery = "select so.type from vn_starsystem ss left outer join vn_spaceobject so on ss.spaceobject_id=so.id where ss.id='".$this->Sql->Escape($SpaceObjectId)."';";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			while($tmp = $SQLRez->fetch_array()) {
				$Rez = $tmp["type"];
				$this->Sql->FreeResult($SQLRez);
				return $Rez;
			}
		}
	}
	
	protected function CreateXMLFromSQLRez($SQLRez) {
		// ���������� XML � ��������� �������
		$XMLDoc = new DOMDocument('1.0','utf-8');
		while($tmp = $SQLRez->fetch_assoc()) {
			$RootNode = $XMLDoc->createElement($tmp["type"]);
			while (list($key, $val) = each($tmp)) {
				switch($key) {
					case "type":	// type - ������
						break;
					case "id":		// id - � �������
						$RootNode->setAttribute($key,$val);
						break;
					case "id_in_ss":		// ������������� � ��� id
						$Node = $XMLDoc->createElement("id");
						$Value = $XMLDoc->createTextNode($val);
						$Node->appendChild($Value);
						$RootNode->appendChild($Node);
						break;
					case "sub_id_in_ss":		// ������������� � ��� sub_id
						if(!is_null($val) && $val != 0) {
							$Node = $XMLDoc->createElement("sub_id");
							$Value = $XMLDoc->createTextNode($val);
							$Node->appendChild($Value);
							$RootNode->appendChild($Node);
						}
						break;
					default:
						if(!is_null($val)) {
							$Node = $XMLDoc->createElement($key);
							$Value = $XMLDoc->createTextNode($val);
							$Node->appendChild($Value);
							$RootNode->appendChild($Node);
						}
				}
			}
			$XMLDoc->appendChild($RootNode);
		}
		return $XMLDoc;
	}
}
?>