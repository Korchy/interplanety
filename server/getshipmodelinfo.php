<?php
//---------------------------------
require_once("include/ships.inc.php");
//---------------------------------
if (isset($_REQUEST['session_id'])) {
	session_id($_REQUEST['session_id']);
}
session_start();
// ���� ��� ����������� - �������� �� �������� �����������
if(!isset($_SESSION["vn_id"])) {
	session_destroy();
	header("Location: login");
}
//---------------------------------
// ������� ���������
$ShipId = 1;
if (isset($_REQUEST['ShipId'])) $ShipId = $_REQUEST['ShipId'];
//---------------------------------
	// �������� ������ �� ������ ������� � Id = $ShipId
// ������ ���������� � ���� XML-���������
$Doc = new DOMDocument('1.0','utf-8');
	// ������ �� �������
$Sh = new Ships();
$ShipModelInfo = $Doc->createElement('ShipModelInfo');
$Sh->GetShipModelInfoXML($ShipId,$Doc,$ShipModelInfo);
	// ---
$Doc->appendChild($ShipModelInfo);
// ������� ��������������� XML
//$file = fopen ("getshipmodelinfo.xml","w+");
//fputs($file, $Doc->saveXML());
echo $Doc->saveXML();
?>