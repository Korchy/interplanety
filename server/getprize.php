<?php
//---------------------------------
// Возвращает перечень незадействованных элементов для виртуальной звездной системы пользователя
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
$SpaceObjectId = 0;	// spaceobject_id объекта
if (isset($_REQUEST['SpaceObjectId'])) $SpaceObjectId = $_REQUEST['SpaceObjectId'];
//---------------------------------
$SSV = new StarSystemVVn();
$Rez = $SSV->GetPrizeXML($SpaceObjectId,$_SESSION["vn_id"]);
	// Вернуть сгенерированный XML
//$file = fopen ("getprize.xml","w+");
//fputs($file, $Rez->saveXML());
echo $Rez->saveXML();
?>