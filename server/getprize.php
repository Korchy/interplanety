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
$SpaceObjectId = 0;	// spaceobject_id �������
if (isset($_REQUEST['SpaceObjectId'])) $SpaceObjectId = $_REQUEST['SpaceObjectId'];
//---------------------------------
$SSV = new StarSystemVVn();
$Rez = $SSV->GetPrizeXML($SpaceObjectId,$_SESSION["vn_id"]);
	// ������� ��������������� XML
//$file = fopen ("getprize.xml","w+");
//fputs($file, $Rez->saveXML());
echo $Rez->saveXML();
?>