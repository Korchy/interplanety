<?php
//---------------------------------
// ���������� ��� ������������� ����������� ����������� ���� �� ����������� �������� �������
// ���������� ��� ������ ��� ERR=0
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
$Id = 0;	// id ����� (vn_user_starsystem.id)
if (isset($_REQUEST['Id'])) $Id = $_REQUEST['Id'];
$SubId = "null";	// sub_id ������� (id ������� � �������� ��������� �������)
if (isset($_REQUEST['SubId'])&&$_REQUEST['SubId']!="null") $SubId = $_REQUEST['SubId'];
$X = "null";	// X ���������� �������
if (isset($_REQUEST['X'])&&$_REQUEST['X']!="null") $X = $_REQUEST['X'];
$Y = "null";	// Y ���������� �������
if (isset($_REQUEST['Y'])&&$_REQUEST['Y']!="null") $Y = $_REQUEST['Y'];
$Z = "null";	// Z ���������� �������
if (isset($_REQUEST['Z'])&&$_REQUEST['Z']!="null") $Z = $_REQUEST['Z'];
//---------------------------------
//$file = fopen ("replaceprizeobject.txt","w+");
//fputs($file, "Id= ".$Id."\n");
//fputs($file, "SubId= ".$SubId."\n");
//fputs($file, "X= ".$X."\n");
//fputs($file, "Y= ".$Y."\n");
//fputs($file, "Z= ".$Z."\n");
$SSV = new StarSystemVVn();
$Rez = $SSV->ReplacePrizeObject($Id,$SubId,$X,$Y,$Z);
	// ������� ��������������� XML
//$file = fopen ("replaceprizeobject.xml","w+");
//fputs($file, $Rez->saveXML());
echo $Rez->saveXML();
?>