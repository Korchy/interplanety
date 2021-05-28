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
//$StarSystemId = 0;	// Id в vn_quests
//if (isset($_REQUEST['StarSystemId'])) $StarSystemId = $_REQUEST['StarSystemId'];
//---------------------------------
	// Данные  передаются в виде XML-документа
$Doc = new DOMDocument('1.0','utf-8');
$Quests = $Doc->createElement('quests');
	// Получить данные о квестах
$Qst = new Quests();
$Qst->GetQuests($_SESSION["vn_id"],$Doc,$Quests);
$Doc->appendChild($Quests);
	// Вернуть сгенерированный XML
//$file = fopen ("getquests.xml","w+");
//fputs($file, $Doc->saveXML());
echo $Doc->saveXML();
?>