<?php
//---------------------------------
require_once("include/planetr.inc.php");
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
$PlanetAId = 0;	// 1 планета (spaceobject_id)
if (isset($_REQUEST['PlanetAId'])) $PlanetAId = $_REQUEST['PlanetAId'];
$PlanetBId = 0;	// 2 планета (spaceobject_id)
if (isset($_REQUEST['PlanetBId'])) $PlanetBId = $_REQUEST['PlanetBId'];
$CargoId = 0;	// Груз (Id в vn_industru)
if (isset($_REQUEST['CargoId'])) $CargoId = $_REQUEST['CargoId'];
//---------------------------------
	// Данные  передаются в виде XML-документа
$XMLDoc = new DOMDocument('1.0','utf-8');
$PictInfo = $XMLDoc->createElement('info');
	// Получить данные о квестах
if($PlanetAId!=0||$PlanetBId!=0) {
	$Pl = new PlanetR();
	if($PlanetAId!=0) {
		$Node = $XMLDoc->createElement("PlanetA");
		$Value = $XMLDoc->createTextNode($PlanetAId);
		$Node->appendChild($Value);
		$PictInfo->appendChild($Node);
		$PlanetAName = $Pl->Name($PlanetAId);
		$Node = $XMLDoc->createElement("PlanetAName");
		$Value = $XMLDoc->createTextNode($PlanetAName);
		$Node->appendChild($Value);
		$PictInfo->appendChild($Node);
	}
	if($PlanetBId!=0) {
		$Node = $XMLDoc->createElement("PlanetB");
		$Value = $XMLDoc->createTextNode($PlanetBId);
		$Node->appendChild($Value);
		$PictInfo->appendChild($Node);
		$PlanetBName = $Pl->Name($PlanetBId);
		$Node = $XMLDoc->createElement("PlanetBName");
		$Value = $XMLDoc->createTextNode($PlanetBName);
		$Node->appendChild($Value);
		$PictInfo->appendChild($Node);
	}
}
if($CargoId!=0) {
	$Cg = new Industry();
	$CargoName = $Cg->Name($CargoId);
	$Node = $XMLDoc->createElement("CargoId");	// CargoId нужно возвращать, чтобы пользоваться им в получающей функции (хотя гонять туда-сюда неправильно)
	$Value = $XMLDoc->createTextNode($CargoId);
	$Node->appendChild($Value);
	$PictInfo->appendChild($Node);
	$Node = $XMLDoc->createElement("CargoName");
	$Value = $XMLDoc->createTextNode($CargoName);
	$Node->appendChild($Value);
	$PictInfo->appendChild($Node);
}
$XMLDoc->appendChild($PictInfo);
	// Вернуть сгенерированный XML
//$file = fopen ("getquestconditionpictinfo.xml","w+");
//fputs($file, $XMLDoc->saveXML());
echo $XMLDoc->saveXML();
?>