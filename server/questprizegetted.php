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
$PrizeId = 0;
if (isset($_REQUEST['PrizeId'])) $PrizeId = $_REQUEST['PrizeId'];
//---------------------------------
	// ������� ��������� ������
$Rez = "F";
$Qst = new Quests();
$Rez = $Qst->QuestsPrizeGetted($PrizeId);
	// ������� "T"
//$file = fopen ("questprizegetted.txt","w+");
//fputs($file, $Rez);
echo $Rez;
?>