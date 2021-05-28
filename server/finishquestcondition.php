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
//$QuestId = 3;
//$UserFinish = "<part><CloseWindow id=\"1\">1</CloseWindow></part>";
$QuestId = 0;
$UserFinish = "";
if (isset($_REQUEST['QuestId'])) $QuestId = $_REQUEST['QuestId'];				// Id квеста (в vn_quests)
if (isset($_REQUEST['UserFinish'])) $UserFinish = $_REQUEST['UserFinish'];		// Насколько выполнен пользователем очередной этап (текст)
//---------------------------------
//$file1 = fopen ("finishquestconditionA_".$QuestId.".txt","w+");
//fputs($file1,$UserFinish);
	// Данные  передаются в виде XML-документа
$Doc = new DOMDocument('1.0','utf-8');
$CurrentCondition = $Doc->createElement('fc');
	// Получить данные о производстве на планете
$Qst = new Quests();
$Qst->FinishQuest($QuestId,$UserFinish,$Doc,$CurrentCondition);
$Doc->appendChild($CurrentCondition);
	// Вернуть сгенерированный XML
//$file = fopen ("finishquestcondition_".$QuestId.".xml","w+");
//fputs($file, $Doc->saveXML());
echo $Doc->saveXML();
?>