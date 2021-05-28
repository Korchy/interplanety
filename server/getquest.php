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
$QuestId = 3;	// Id в vn_quests
if (isset($_REQUEST['QuestId'])) $QuestId = $_REQUEST['QuestId'];
//---------------------------------
	// Данные  передаются в виде XML-документа
$Doc = new DOMDocument('1.0','utf-8');
$CurrentQuest = $Doc->createElement('quest');
	// Получить данные о производстве на планете
$Qst = new Quests();
$Qst->GetQuest($_SESSION["vn_id"],$QuestId,$Doc,$CurrentQuest);
$Doc->appendChild($CurrentQuest);
	// Вернуть сгенерированный XML
//$file = fopen ("getquest_".$QuestId.".xml","w+");
//fputs($file, $Doc->saveXML());
echo $Doc->saveXML();
?>