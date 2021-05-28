<?php
//---------------------------------
require_once("include/quests.inc.php");
//---------------------------------
if (isset($_REQUEST['session_id'])) {
	session_id($_REQUEST['session_id']);
}
session_start();
// Если нет авторизации - вернутся на страницу авторизации
if(!isset($_SESSION["vn_id"])) {
	session_destroy();
	header("Location: login");
}
//---------------------------------
// Входные параметры
$PrizeId = 0;
if (isset($_REQUEST['PrizeId'])) $PrizeId = $_REQUEST['PrizeId'];
//---------------------------------
	// Закрыть получение призов
$Rez = "F";
$Qst = new Quests();
$Rez = $Qst->QuestsPrizeGetted($PrizeId);
	// Вернуть "T"
//$file = fopen ("questprizegetted.txt","w+");
//fputs($file, $Rez);
echo $Rez;
?>