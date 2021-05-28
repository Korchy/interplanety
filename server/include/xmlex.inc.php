<?php
//---------------------------------
// ����������� ����� ��� ������ � XML
//---------------------------------
//require_once("mysql.inc.php");
//---------------------------------
class XMLEx
{

	public function __construct() {
		// �����������
		
	}

	public function __destruct() {
		// ����������
		
	}

	public function FindEqualNode($Source,$Node) {
		// ����� ���� � XML $Source �������������� $Node
		// ���������������� ���������: ���������� ���, ��� �������� �� ���� � $Source ���� � $Node � �� �������� �����
		$SourceNodes = $Source->getElementsByTagName($Node->nodeName);	// <SellCargo></SellCargo><SellCargo></SellCargo>
		foreach($SourceNodes as $SourceNode) {	// <SellCargo></SellCargo>
			// ��������� �� ����������
			$AllAttrEqual = true;
			foreach($SourceNode->attributes as $SAttr) {
				$AttrEqual = false;
				foreach($Node->attributes as $NAttr) {
					if($SAttr->nodeName==$NAttr->nodeName&&$SAttr->nodeValue==$NAttr->nodeValue) {
						// ����� ������� ����
						$AttrEqual = true;
						break;
					}
				}
				if($AttrEqual==false) {
					// ������� �� ������ - false
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
		// ����� ���� � XML $Root � ������ = $Name � (���� ����) � ��������� id = $Id
		$RootNodes = $Root->getElementsByTagName($Name);
		foreach($RootNodes as $RootNode) {
			// ���� ���� ������� (Id) ��������� ��� � �� ����
			// ���� ��� �������� - ������� ���������� ������ �� �����
			if($RootNode->hasAttributes()) {
				foreach($RootNode->attributes as $Attr) {
					if($Attr->name=="id"&&$Attr->value==$Id) {
						// Id ���������
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
		// ������� XML-�������� ��� ������ �� �� ������
		if($XMLDoc == null) $XMLDoc = new DOMDocument('1.0','utf-8');
		$Err = $XMLDoc->createElement('ERR');
		$Txt = $XMLDoc->createTextNode($Number);
		$Err->appendChild($Txt);
		$XMLDoc->appendChild($Err);
		return $XMLDoc;
	}
}
?>