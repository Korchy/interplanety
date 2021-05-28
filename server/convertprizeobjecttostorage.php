<?php
//---------------------------------
// Вызывается при необходимости конвертировать объект виртуальной звездной системы в виртуальный приз
//---------------------------------
require_once("include/starsystemv_vn.inc.php");
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
$Id = 0;	// Id объекта в виртуальной системе
if (isset($_REQUEST['Id'])) $Id = $_REQUEST['Id'];
//---------------------------------
$SSV = new StarSystemVVn();
$Rez = $SSV->ConvertPrizeObjectToStorage($Id,$_SESSION["vn_id"]);
	// Вернуть результат (T или F)
//$file = fopen ("convertprizeobjecttostorage.xml","w+");
//fputs($file, $Rez->saveXML());
echo $Rez->saveXML();
?>