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
//$QuestId = 3;
//$UserFinish = "<part><CloseWindow id=\"1\">1</CloseWindow></part>";
$QuestId = 0;
$UserFinish = "";
if (isset($_REQUEST['QuestId'])) $QuestId = $_REQUEST['QuestId'];				// Id ������ (� vn_quests)
if (isset($_REQUEST['UserFinish'])) $UserFinish = $_REQUEST['UserFinish'];		// ��������� �������� ������������� ��������� ���� (�����)
//---------------------------------
//$file1 = fopen ("finishquestconditionA_".$QuestId.".txt","w+");
//fputs($file1,$UserFinish);
	// ������  ���������� � ���� XML-���������
$Doc = new DOMDocument('1.0','utf-8');
$CurrentCondition = $Doc->createElement('fc');
	// �������� ������ � ������������ �� �������
$Qst = new Quests();
$Qst->FinishQuest($QuestId,$UserFinish,$Doc,$CurrentCondition);
$Doc->appendChild($CurrentCondition);
	// ������� ��������������� XML
//$file = fopen ("finishquestcondition_".$QuestId.".xml","w+");
//fputs($file, $Doc->saveXML());
echo $Doc->saveXML();
?>