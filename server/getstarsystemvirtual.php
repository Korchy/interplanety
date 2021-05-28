<?php
//---------------------------------
// Возвращает схему виртуальной звездной системы пользователя
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
$Rez = $SSV->GetStarSystemXML(null);
	// Вернуть сгенерированный XML
//$file = fopen ("getstarsystemvirtual.xml","w+");
//fputs($file, $Rez->saveXML());
echo $Rez->saveXML();
?>
