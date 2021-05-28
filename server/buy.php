<?php
//---------------------------------
require_once("include/trade.inc.php");
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
$IndustryId = 0;	// 14 -> Луна - Почта
$BuyingCount = 0;
$ShipId = 0;
if(isset($_REQUEST['IndustryId'])) $IndustryId = $_REQUEST['IndustryId'];
if(isset($_REQUEST['BuyingCount'])) $BuyingCount = $_REQUEST['BuyingCount'];
if(isset($_REQUEST['ShipId'])) $ShipId = $_REQUEST['ShipId'];
//---------------------------------
// Покупка
// Данные возвращаются в виде XML-документа
//---------------------------------
$Buy = new Trade();
$Rez = $Buy->BuyDeal($_SESSION["vn_id"], $IndustryId, $BuyingCount, $ShipId);
//$file = fopen ("buy.xml","w+");
//fputs($file, $Rez->saveXML());
echo $Rez->saveXML();
?>