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
$QuestId = 4;	// Id � vn_quests
if (isset($_REQUEST['QuestId'])) $QuestId = $_REQUEST['QuestId'];
//---------------------------------
	// ������  ���������� � ���� XML-���������
$Doc = new DOMDocument('1.0','utf-8');
	// �������� ������ � ������������ �� �������
$Qst = new Quests();
$Qst->AcceptDynamicQuest($_SESSION["vn_id"],$QuestId,$Doc);
	// ������� ��������������� XML
//$file = fopen ("acceptdynamicquest.xml","w+");
//fputs($file, $Doc->saveXML());
echo $Doc->saveXML();
?>