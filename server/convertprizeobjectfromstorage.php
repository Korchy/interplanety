<?php
//---------------------------------
// Вызывается при необходимости конвертировать виртуальный приз в объект виртуальной звездной системы
// Возвращает или ошибку или данные для добавления объекта в систему
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
$SOId = 0;	// spaceobject_id приза
if (isset($_REQUEST['SOId'])) $SOId = $_REQUEST['SOId'];
$SubId = "null";	// sub_id объекта (id объекта к которому цепляется текущий)
if (isset($_REQUEST['SubId'])&&$_REQUEST['SubId']!="null") $SubId = $_REQUEST['SubId'];
$X = "null";	// X координата объекта
if (isset($_REQUEST['X'])&&$_REQUEST['X']!="null") $X = $_REQUEST['X'];
$Y = "null";	// Y координата объекта
if (isset($_REQUEST['Y'])&&$_REQUEST['Y']!="null") $Y = $_REQUEST['Y'];
$Z = "null";	// Z координата объекта
if (isset($_REQUEST['Z'])&&$_REQUEST['Z']!="null") $Z = $_REQUEST['Z'];
//---------------------------------
$SSV = new StarSystemVVn();
$Rez = $SSV->ConvertPrizeObjectFromStorage($SOId,$SubId,$X,$Y,$Z);
	// Вернуть сгенерированный XML
//$file = fopen ("convertprizeobjectfromstorage.xml","w+");
if($Rez!="0") {
//	fputs($file, $Rez->saveXML());
	echo $Rez->saveXML();
	}
else {
//	fputs($file, $Rez);
	echo $Rez;;
	}
?>