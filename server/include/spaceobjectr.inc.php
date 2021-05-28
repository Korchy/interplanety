<?php
//---------------------------------
require_once("spaceobject.inc.php");
//---------------------------------
class SpaceObjectR extends SpaceObject
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
	
	protected function CreateXMLFromSQLRez($SQLRez) {
		// Возвращает XML с описанием объекта
		$XMLDoc = new DOMDocument('1.0','utf-8');
		while($tmp = $SQLRez->fetch_assoc()) {
			$RootNode = $XMLDoc->createElement($tmp["type"]);
			while (list($key, $val) = each($tmp)) {
				switch($key) {
					case "type":	// type - корень
						break;
					case "id":		// id - в аттрибут
						$RootNode->setAttribute($key,$val);
						break;
					case "id_in_ss":		// Переименовать в нод id
						$Node = $XMLDoc->createElement("id");
						$Value = $XMLDoc->createTextNode($val);
						$Node->appendChild($Value);
						$RootNode->appendChild($Node);
						break;
					case "sub_id_in_ss":		// Переименовать в нод sub_id
						if(!is_null($val) && $val != 0) {
							$Node = $XMLDoc->createElement("sub_id");
							$Value = $XMLDoc->createTextNode($val);
							$Node->appendChild($Value);
							$RootNode->appendChild($Node);
						}
						break;
					case "k_real":	// Только если !=1
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