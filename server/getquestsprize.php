<?php
//---------------------------------
require_once("include/quests.inc.php");
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
	// ������  ���������� � ���� XML-���������
$Doc = new DOMDocument('1.0','utf-8');
$Quests = $Doc->createElement('quest');
	// �������� ������ � �������
$Qst = new Quests();
$Qst->GetQuestsPrize($_SESSION["vn_id"],$Doc,$Quests);
$Doc->appendChild($Quests);
	// ������� ��������������� XML
//$file = fopen ("getquestsprize.xml","w+");
//fputs($file, $Doc->saveXML());
echo $Doc->saveXML();
?>