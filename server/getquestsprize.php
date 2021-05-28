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

//---------------------------------
	// Данные  передаются в виде XML-документа
$Doc = new DOMDocument('1.0','utf-8');
$Quests = $Doc->createElement('quest');
	// Получить данные о квестах
$Qst = new Quests();
$Qst->GetQuestsPrize($_SESSION["vn_id"],$Doc,$Quests);
$Doc->appendChild($Quests);
	// Вернуть сгенерированный XML
//$file = fopen ("getquestsprize.xml","w+");
//fputs($file, $Doc->saveXML());
echo $Doc->saveXML();
?>