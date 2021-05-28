<?php
//---------------------------------
// Вызывается при необходимости переместить виртуальный приз по виртуальной звездной системе
// Возвращает или ошибку или ERR=0
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
$Id = 0;	// id приза (vn_user_starsystem.id)
if (isset($_REQUEST['Id'])) $Id = $_REQUEST['Id'];
$SubId = "null";	// sub_id объекта (id объекта к которому цепляется текущий)
if (isset($_REQUEST['SubId'])&&$_REQUEST['SubId']!="null") $SubId = $_REQUEST['SubId'];
$X = "null";	// X координата объекта
if (isset($_REQUEST['X'])&&$_REQUEST['X']!="null") $X = $_REQUEST['X'];
$Y = "null";	// Y координата объекта
if (isset($_REQUEST['Y'])&&$_REQUEST['Y']!="null") $Y = $_REQUEST['Y'];
$Z = "null";	// Z координата объекта
if (isset($_REQUEST['Z'])&&$_REQUEST['Z']!="null") $Z = $_REQUEST['Z'];
//---------------------------------
//$file = fopen ("replaceprizeobject.txt","w+");
//fputs($file, "Id= ".$Id."\n");
//fputs($file, "SubId= ".$SubId."\n");
//fputs($file, "X= ".$X."\n");
//fputs($file, "Y= ".$Y."\n");
//fputs($file, "Z= ".$Z."\n");
$SSV = new StarSystemVVn();
$Rez = $SSV->ReplacePrizeObject($Id,$SubId,$X,$Y,$Z);
	// Вернуть сгенерированный XML
//$file = fopen ("replaceprizeobject.xml","w+");
//fputs($file, $Rez->saveXML());
echo $Rez->saveXML();
?>