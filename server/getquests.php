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
//$StarSystemId = 0;	// Id � vn_quests
//if (isset($_REQUEST['StarSystemId'])) $StarSystemId = $_REQUEST['StarSystemId'];
//---------------------------------
	// ������  ���������� � ���� XML-���������
$Doc = new DOMDocument('1.0','utf-8');
$Quests = $Doc->createElement('quests');
	// �������� ������ � �������
$Qst = new Quests();
$Qst->GetQuests($_SESSION["vn_id"],$Doc,$Quests);
$Doc->appendChild($Quests);
	// ������� ��������������� XML
//$file = fopen ("getquests.xml","w+");
//fputs($file, $Doc->saveXML());
echo $Doc->saveXML();
?>