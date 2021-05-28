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
$QuestId = 4;	// Id в vn_quests
if (isset($_REQUEST['QuestId'])) $QuestId = $_REQUEST['QuestId'];
//---------------------------------
	// Данные  передаются в виде XML-документа
$Doc = new DOMDocument('1.0','utf-8');
	// Получить данные о производстве на планете
$Qst = new Quests();
$Qst->AcceptDynamicQuest($_SESSION["vn_id"],$QuestId,$Doc);
	// Вернуть сгенерированный XML
//$file = fopen ("acceptdynamicquest.xml","w+");
//fputs($file, $Doc->saveXML());
echo $Doc->saveXML();
?>