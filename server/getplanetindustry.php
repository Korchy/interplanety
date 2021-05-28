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
$PlanetId = 0;
if (isset($_REQUEST['PlanetId'])) $PlanetId = $_REQUEST['PlanetId'];
//---------------------------------
	// ������  ���������� � ���� XML-���������
$Doc = new DOMDocument('1.0','utf-8');
$Planet = $Doc->createElement('Industry');
	// �������� ������ � ������������ �� �������
$Ind = new Industry();
$Ind->GetPlanetIndustry($PlanetId,$Doc,$Planet);
$Doc->appendChild($Planet);
	// ������� ��������������� XML
//$file = fopen ("getplanetindustry".$PlanetId.".xml","w+");
//fputs($file, $Doc->saveXML());
echo $Doc->saveXML();
?>