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
// ������� �������
//---------------------------------
// ������� ���������
$ShipModelId = 0;
$PlanetId = 22;
if (isset($_REQUEST['ShipId'])) $ShipModelId = $_REQUEST['ShipId'];
if (isset($_REQUEST['PlanetId'])) $PlanetId = $_REQUEST['PlanetId'];
//---------------------------------
	// �������
	// ������ ������������ � ���� XML-���������
$Doc = new DOMDocument('1.0','utf-8');
	// ��������� �� ����������� ���������� ������ � ������� ����������
$Sh = new Ships();
$Sh->BuyShip($_SESSION["vn_id"],$ShipModelId,$PlanetId,$Doc);
// ���� ������ ���������� - ������� �������� ���������� �������, ���� ��� - ������� ��� ������
//$file = fopen ("buyship.xml","w+");
//fputs($file, $Doc->saveXML());
echo $Doc->saveXML();
?>
