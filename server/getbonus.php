<?php
//---------------------------------
// Получение данных по бонусу от виртуального объекта
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
$Id = 0;	// spaceobject_id приза (vn_user_starsystem.id)
if (isset($_REQUEST['Id'])) $Id = $_REQUEST['Id'];
//---------------------------------
	// Получить данные по бонусу
$SSV = new StarSystemVVn();
$Rez = $SSV->GetBonus($Id, $_SESSION["vn_id"]);
	// Вернуть сгенерированный XML
//$file = fopen ("getbonus.xml","w+");
//fputs($file, $Rez->saveXML());
echo $Rez->saveXML();
?>