<?php
//---------------------------------
// ��������� ��������� ����������� ������ � ������������ � ����������� �������
//---------------------------------
require_once("include/orbitv.inc.php");
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
$Id = "0";			// id ������ (vn_user_starsystem_orbits_v.user_starsystem_id)
if (isset($_REQUEST['Id'])) $Id = $_REQUEST['Id'];
$RadiusL = "100";	// ������� ������
if (isset($_REQUEST['RadiusL'])) $RadiusL = $_REQUEST['RadiusL'];
$RadiusS = "100";	// ����� ������
if (isset($_REQUEST['RadiusS'])) $RadiusS = $_REQUEST['RadiusS'];
$Angle = "0";		// ���� �������
if (isset($_REQUEST['Angle'])) $Angle = $_REQUEST['Angle'];
$Speed = "0.001";	// �������� �������� �� ������
if (isset($_REQUEST['Speed'])) $Speed = $_REQUEST['Speed'];
//---------------------------------
$Orbit = new OrbitV();
$Rez = $Orbit->UpdateParameters($Id, $RadiusL, $RadiusS, $Angle, $Speed);
	// ������� ��������������� XML
//$file = fopen ("updateorbitvparameters.xml","w+");
//fputs($file, $Rez->saveXML());
echo $Rez->saveXML();
?>