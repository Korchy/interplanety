<?php
//---------------------------------
// ��������� ������ �� ������ �� ������������ �������
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
$Id = 0;	// spaceobject_id ����� (vn_user_starsystem.id)
if (isset($_REQUEST['Id'])) $Id = $_REQUEST['Id'];
//---------------------------------
	// �������� ������ �� ������
$SSV = new StarSystemVVn();
$Rez = $SSV->GetBonus($Id, $_SESSION["vn_id"]);
	// ������� ��������������� XML
//$file = fopen ("getbonus.xml","w+");
//fputs($file, $Rez->saveXML());
echo $Rez->saveXML();
?>