<?php
//---------------------------------
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
$IndustryId = 1;
if (isset($_REQUEST['IndustryId'])) $IndustryId = $_REQUEST['IndustryId'];
//---------------------------------
	// ������  ���������� � ���� XML-���������
$Doc = new DOMDocument('1.0','utf-8');
$CurrentIndustry = $Doc->createElement('Industry');
	// �������� ������ � ������������ �� �������
$Ind = new Industry();
$Ind->GetIndustry($IndustryId,$Doc,$CurrentIndustry);
$Doc->appendChild($CurrentIndustry);
	// ������� ��������������� XML
//$file = fopen ("getindustry".$IndustryId.".xml","w+");
//fputs($file, $Doc->saveXML());
echo $Doc->saveXML();
?>
