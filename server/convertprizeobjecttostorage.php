<?php
//---------------------------------
// ���������� ��� ������������� �������������� ������ ����������� �������� ������� � ����������� ����
//---------------------------------
require_once("include/starsystemv_vn.inc.php");
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
$Id = 0;	// Id ������� � ����������� �������
if (isset($_REQUEST['Id'])) $Id = $_REQUEST['Id'];
//---------------------------------
$SSV = new StarSystemVVn();
$Rez = $SSV->ConvertPrizeObjectToStorage($Id,$_SESSION["vn_id"]);
	// ������� ��������� (T ��� F)
//$file = fopen ("convertprizeobjecttostorage.xml","w+");
//fputs($file, $Rez->saveXML());
echo $Rez->saveXML();
?>