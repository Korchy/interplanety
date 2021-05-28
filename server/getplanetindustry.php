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
$PlanetId = 0;
if (isset($_REQUEST['PlanetId'])) $PlanetId = $_REQUEST['PlanetId'];
//---------------------------------
	// Данные  передаются в виде XML-документа
$Doc = new DOMDocument('1.0','utf-8');
$Planet = $Doc->createElement('Industry');
	// Получить данные о производстве на планете
$Ind = new Industry();
$Ind->GetPlanetIndustry($PlanetId,$Doc,$Planet);
$Doc->appendChild($Planet);
	// Вернуть сгенерированный XML
//$file = fopen ("getplanetindustry".$PlanetId.".xml","w+");
//fputs($file, $Doc->saveXML());
echo $Doc->saveXML();
?>