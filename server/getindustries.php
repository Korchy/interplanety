<?php
//------------------------------------------------------------------------------------------------------------------------------------
// �������� ������� ����������� ��� ����������� ������� �������� �������
//------------------------------------------------------------------------------------------------------------------------------------
require_once("include/industry.inc.php");
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
$StarSystemId = 1;	// Id � vn_starsystem
if (isset($_REQUEST['StarSystemId'])) $StarSystemId = $_REQUEST['StarSystemId'];
//---------------------------------
	// ������  ���������� � ���� XML-���������
	// �������� ������ � ������������ �� �������
$Ind = new Industry();
$Rez = $Ind->GetIndustries($StarSystemId);
	// ������� ��������������� XML
//$file = fopen ("getindustries".$StarSystemId.".xml","w+");
//fputs($file, $Rez->saveXML());
echo $Rez->saveXML();
?>