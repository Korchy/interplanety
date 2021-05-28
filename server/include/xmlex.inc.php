<?php
//---------------------------------
// Расширенный класс для работы с XML
//---------------------------------
//require_once("mysql.inc.php");
//---------------------------------
class XMLEx
{

	public function __construct() {
		// Конструктор
		
	}

	public function __destruct() {
		// Деструктор
		
	}

	public function FindEqualNode($Source,$Node) {
		// Поиск узла в XML $Source эквивалентного $Node
		// Эквивалентностью считается: одинаковое имя, все атрибуты из узла в $Source есть в $Node и их значения равны
		$SourceNodes = $Source->getElementsByTagName($Node->nodeName);	// <SellCargo></SellCargo><SellCargo></SellCargo>
		foreach($SourceNodes as $SourceNode) {	// <SellCargo></SellCargo>
			// Проверяем по аттрибутам
			$AllAttrEqual = true;
			foreach($SourceNode->attributes as $SAttr) {
				$AttrEqual = false;
				foreach($Node->attributes as $NAttr) {
					if($SAttr->nodeName==$NAttr->nodeName&&$SAttr->nodeValue==$NAttr->nodeValue) {
						// Такой атрибут есть
						$AttrEqual = true;
						break;
					}
				}
				if($AttrEqual==false) {
					// Атрибут не найден - false
					$AllAttrEqual = false;
					break;
				}
			}
			if($AllAttrEqual==true) {
				return $SourceNode;
			}
		}
		return NULL;
	}
	
	public function FindNodeInXML($Root,$Name,$Id) {
		// Поиск узла в XML $Root с именем = $Name и (если есть) с атрибутом id = $Id
		$RootNodes = $Root->getElementsByTagName($Name);
		foreach($RootNodes as $RootNode) {
			// Если есть атрибут (Id) проверяем еще и по нему
			// Если нет атрибута - считаем совпадение только по имени
			if($RootNode->hasAttributes()) {
				foreach($RootNode->attributes as $Attr) {
					if($Attr->name=="id"&&$Attr->value==$Id) {
						// Id совпадает
						return $RootNode;
					}
				}
			}
			else {
				return $RootNode;
			}
		}
		return NULL;
	}
	
	public function CreateXMLErr($Number, $XMLDoc = null) {
		// Создать XML-стуктуру для ошибки по ее номеру
		if($XMLDoc == null) $XMLDoc = new DOMDocument('1.0','utf-8');
		$Err = $XMLDoc->createElement('ERR');
		$Txt = $XMLDoc->createTextNode($Number);
		$Err->appendChild($Txt);
		$XMLDoc->appendChild($Err);
		return $XMLDoc;
	}
}
?>