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
//---------------------------------
$ShipId = 1;
if(isset($_REQUEST['ShipId'])) $ShipId = $_REQUEST['ShipId'];
//---------------------------------
$ShipsManager = new Ships();
	// ������ � �������� ���������� � ���� XML-���������
$Doc = new DOMDocument('1.0','utf-8');
	// ������ ��� �������
$ShipModules = $Doc->createElement('modules');
$ShipsManager->GetShipModulesXML($_SESSION["vn_id"], $ShipId, $Doc, $ShipModules);
$Doc->appendChild($ShipModules);
	// ������� ��������������� XML
//$file = fopen ("getshipmodules".$ShipId.".xml","w+");
//fputs($file, $Doc->saveXML());
echo $Doc->saveXML();
?>