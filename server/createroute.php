<?php
//---------------------------------
require_once("include/routes.inc.php");
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
$PlanetId = 0;
$UserShipId = 0;
if (isset($_REQUEST['PlanetId'])) $PlanetId = $_REQUEST['PlanetId'];
if (isset($_REQUEST['UserShipId'])) $UserShipId = $_REQUEST['UserShipId'];
//---------------------------------
	// �������� ��������
$Rez = "F";	// ���������
	// ��������� �� ����������� �������� � ������� �������
$Routes = new URoutes();
$Rez = $Routes->CreateRoute($PlanetId,$UserShipId);
//$Rez = $Routes->CreateRoute(22,2);
	// ������� ���������
echo $Rez;
?>
