<?php
//---------------------------------
require_once("include/planetr.inc.php");
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
// �������� ������� �������� �� �������
//---------------------------------
// ������� ���������
//---------------------------------
$PlanetId = 0;
if (isset($_REQUEST['PlanetId'])) $PlanetId = $_REQUEST['PlanetId'];
//---------------------------------
	// �������
$Rez = 0;	// ���������
	// ��������� ������� ��������
$Pl = new PlanetR();
$Rez = $Pl->ShipCountOnPlanet($_SESSION["vn_id"],$PlanetId);
	// ������� ���������
echo $Rez;
?>
