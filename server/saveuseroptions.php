<?php
//---------------------------------
require_once("include/user.inc.php");
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
// Объект пользовательских параметров
$UOpt = new UserVn();
$UOpt->SaveOptions($_SESSION["vn_id"]);
echo "a=1";	// Строка нужна чтобы были возвращаемые значения при параметре URLLoaderDataFormat.VARIABLES загрузчика
?>
