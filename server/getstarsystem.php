<?php
//------------------------------------------------------------------------------------------------------------------------------------
// �������� ������� ��������, ����������� � �������� ������� �� $StarSystemId
//------------------------------------------------------------------------------------------------------------------------------------
require_once("include/starsystem_vn.inc.php");
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
$StarSystemId = 1;
if (isset($_REQUEST['StarSystemId'])) $StarSystemId = $_REQUEST['StarSystemId'];
//---------------------------------
	// �������� ������ � �������
$StarSystem = new StarSystemVn();
$Rez = $StarSystem->GetStarSystemXML($StarSystemId);
	// ������� ��������������� XML
//$file = fopen ("getstarsystem.xml","w+");
//fputs($file, $Rez->saveXML());
echo $Rez->saveXML();
?>