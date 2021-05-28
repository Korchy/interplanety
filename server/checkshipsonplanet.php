<?php
//---------------------------------
require_once("include/planetr.inc.php");
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
// Проверка наличия кораблей на планете
//---------------------------------
// Входные параметры
//---------------------------------
$PlanetId = 0;
if (isset($_REQUEST['PlanetId'])) $PlanetId = $_REQUEST['PlanetId'];
//---------------------------------
	// Покупка
$Rez = 0;	// Результат
	// Проверить наличие кораблей
$Pl = new PlanetR();
$Rez = $Pl->ShipCountOnPlanet($_SESSION["vn_id"],$PlanetId);
	// Вернуть результат
echo $Rez;
?>
