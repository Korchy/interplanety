<?php
//---------------------------------
// ������� �������
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
$ShipId = 0;
if (isset($_REQUEST['ShipId'])) $ShipId = $_REQUEST['ShipId'];	// vn_user_ship.id
//---------------------------------
	// ������ ������������ � ���� XML-���������
	// ��������� �� ����������� ���������� ������ � ������� ����������
$Sh = new Ships();
$rez = $Sh->SellShip($_SESSION["vn_id"], $ShipId);
// ���� ������ ���������� - ������� ���������� ������, ���� ��� - ������� ��� ������
//$file = fopen ("sellship.xml","w+");
//fputs($file, $rez->saveXML());
echo $rez->saveXML();
?>