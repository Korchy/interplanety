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
$Rez = $ShipsManager->GetShipCargoXML($ShipId);
	// Вернуть сгенерированный XML
//$file = fopen ("getshipcargo".$ShipId.".xml","w+");
//fputs($file, $Rez->saveXML());
echo $Rez->saveXML();
?>