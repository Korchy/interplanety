<?php
//---------------------------------
require_once("include/ships.inc.php");
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
$ShipId = 1;
if(isset($_REQUEST['ShipId'])) $ShipId = $_REQUEST['ShipId'];
//---------------------------------
$ShipsManager = new Ships();
	// Данные о кораблях передаются в виде XML-документа
$Doc = new DOMDocument('1.0','utf-8');
	// Модули для корабля
$ShipModules = $Doc->createElement('modules');
$ShipsManager->GetShipModulesXML($_SESSION["vn_id"], $ShipId, $Doc, $ShipModules);
$Doc->appendChild($ShipModules);
	// Вернуть сгенерированный XML
//$file = fopen ("getshipmodules".$ShipId.".xml","w+");
//fputs($file, $Doc->saveXML());
echo $Doc->saveXML();
?>