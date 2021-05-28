<?php
//---------------------------------------------------------------------------------------------------
// Получение данных о кораблях пользователя, которые можно продать
//---------------------------------------------------------------------------------------------------
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
$PlanetId = 0;	// vn_spaceobject.id (22 - верфь)
if (isset($_REQUEST['PlanetId'])) $PlanetId = $_REQUEST['PlanetId'];
//---------------------------------
$ShipsList = new Ships();
$rez = $ShipsList->GetSellingShipsXML($_SESSION["vn_id"], $PlanetId);
	// Вернуть сгенерированный XML
//$file = fopen ("getsellingships.xml","w+");
//fputs($file, $rez->saveXML());
echo $rez->saveXML();
?>