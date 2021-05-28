<?php
//---------------------------------------------------------------------------------------------------
// ��������� ������ � �������� ������������, ������� ����� �������
//---------------------------------------------------------------------------------------------------
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
$PlanetId = 0;	// vn_spaceobject.id (22 - �����)
if (isset($_REQUEST['PlanetId'])) $PlanetId = $_REQUEST['PlanetId'];
//---------------------------------
$ShipsList = new Ships();
$rez = $ShipsList->GetSellingShipsXML($_SESSION["vn_id"], $PlanetId);
	// ������� ��������������� XML
//$file = fopen ("getsellingships.xml","w+");
//fputs($file, $rez->saveXML());
echo $rez->saveXML();
?>