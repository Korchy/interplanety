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
// Покупка корабля
//---------------------------------
// Входные параметры
$ShipModelId = 0;
$PlanetId = 22;
if (isset($_REQUEST['ShipId'])) $ShipModelId = $_REQUEST['ShipId'];
if (isset($_REQUEST['PlanetId'])) $PlanetId = $_REQUEST['PlanetId'];
//---------------------------------
	// Покупка
	// Данные возвращаются в виде XML-документа
$Doc = new DOMDocument('1.0','utf-8');
	// Проверить на возможность совершения сделки и возврат параметров
$Sh = new Ships();
$Sh->BuyShip($_SESSION["vn_id"],$ShipModelId,$PlanetId,$Doc);
// Если сделка состоялась - вернуть описание купленного корабля, если нет - вернуть код ошибки
//$file = fopen ("buyship.xml","w+");
//fputs($file, $Doc->saveXML());
echo $Doc->saveXML();
?>
