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
$Rez = $ShipsManager->GetShipCargoXML($ShipId);
	// ������� ��������������� XML
//$file = fopen ("getshipcargo".$ShipId.".xml","w+");
//fputs($file, $Rez->saveXML());
echo $Rez->saveXML();
?>