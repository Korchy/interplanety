<?php
//---------------------------------
require_once("spaceobject.inc.php");
//---------------------------------
class SpaceObjectR extends SpaceObject
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
	
	protected function CreateXMLFromSQLRez($SQLRez) {
		// ���������� XML � ��������� �������
		$XMLDoc = new DOMDocument('1.0','utf-8');
		while($tmp = $SQLRez->fetch_assoc()) {
			$RootNode = $XMLDoc->createElement($tmp["type"]);
			while (list($key, $val) = each($tmp)) {
				switch($key) {
					case "type":	// type - ������
						break;
					case "id":		// id - � ��������
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
					case "k_real":	// ������ ���� !=1
						if($val!=1) {
							$Node = $XMLDoc->createElement($key);
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