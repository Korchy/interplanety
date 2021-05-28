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

//---------------------------------
$SSV = new StarSystemVVn();
$Rez = $SSV->GetItemsFromStorageXML($_SESSION["vn_id"]);
	// Вернуть сгенерированный XML
//$file = fopen ("getstarsystemvirtualstorage.xml","w+");
//fputs($file, $Rez->saveXML());
echo $Rez->saveXML();
?>