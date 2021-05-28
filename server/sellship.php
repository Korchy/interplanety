<?php
//---------------------------------
// Продажа корабля
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
$ShipId = 0;
if (isset($_REQUEST['ShipId'])) $ShipId = $_REQUEST['ShipId'];	// vn_user_ship.id
//---------------------------------
	// Данные возвращаются в виде XML-документа
	// Проверить на возможность совершения сделки и возврат параметров
$Sh = new Ships();
$rez = $Sh->SellShip($_SESSION["vn_id"], $ShipId);
// Если сделка состоялась - вернуть полученные деньги, если нет - вернуть код ошибки
//$file = fopen ("sellship.xml","w+");
//fputs($file, $rez->saveXML());
echo $rez->saveXML();
?>