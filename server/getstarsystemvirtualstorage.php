<?php
//---------------------------------
// ���������� �������� ����������������� ��������� ��� ����������� �������� ������� ������������
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

//---------------------------------
$SSV = new StarSystemVVn();
$Rez = $SSV->GetItemsFromStorageXML($_SESSION["vn_id"]);
	// ������� ��������������� XML
//$file = fopen ("getstarsystemvirtualstorage.xml","w+");
//fputs($file, $Rez->saveXML());
echo $Rez->saveXML();
?>