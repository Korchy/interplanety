<?php
//---------------------------------
// ���������� ��� ������������� �������������� ����������� ���� � ������ ����������� �������� �������
// ���������� ��� ������ ��� ������ ��� ���������� ������� � �������
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
$SOId = 0;	// spaceobject_id �����
if (isset($_REQUEST['SOId'])) $SOId = $_REQUEST['SOId'];
$SubId = "null";	// sub_id ������� (id ������� � �������� ��������� �������)
if (isset($_REQUEST['SubId'])&&$_REQUEST['SubId']!="null") $SubId = $_REQUEST['SubId'];
$X = "null";	// X ���������� �������
if (isset($_REQUEST['X'])&&$_REQUEST['X']!="null") $X = $_REQUEST['X'];
$Y = "null";	// Y ���������� �������
if (isset($_REQUEST['Y'])&&$_REQUEST['Y']!="null") $Y = $_REQUEST['Y'];
$Z = "null";	// Z ���������� �������
if (isset($_REQUEST['Z'])&&$_REQUEST['Z']!="null") $Z = $_REQUEST['Z'];
//---------------------------------
$SSV = new StarSystemVVn();
$Rez = $SSV->ConvertPrizeObjectFromStorage($SOId,$SubId,$X,$Y,$Z);
	// ������� ��������������� XML
//$file = fopen ("convertprizeobjectfromstorage.xml","w+");
if($Rez!="0") {
//	fputs($file, $Rez->saveXML());
	echo $Rez->saveXML();
	}
else {
//	fputs($file, $Rez);
	echo $Rez;;
	}
?>