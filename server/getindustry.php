<?php
//---------------------------------
require_once("include/industry.inc.php");
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
$IndustryId = 1;
if (isset($_REQUEST['IndustryId'])) $IndustryId = $_REQUEST['IndustryId'];
//---------------------------------
	// Данные  передаются в виде XML-документа
$Doc = new DOMDocument('1.0','utf-8');
$CurrentIndustry = $Doc->createElement('Industry');
	// Получить данные о производстве на планете
$Ind = new Industry();
$Ind->GetIndustry($IndustryId,$Doc,$CurrentIndustry);
$Doc->appendChild($CurrentIndustry);
	// Вернуть сгенерированный XML
//$file = fopen ("getindustry".$IndustryId.".xml","w+");
//fputs($file, $Doc->saveXML());
echo $Doc->saveXML();
?>
