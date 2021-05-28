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
// Входные параметры
$Type = "C";
if (isset($_REQUEST['Type'])) $Type = $_REQUEST['Type'];
//---------------------------------
// Вернуть данные
$Rez = 0;
$Usr = new UserVn();
switch($Type) {
	case "C":
		// Кристаллы
		$Rez = $Usr->GetUserCrystals($_SESSION["vn_id"]);
		break;
	case "G":
		// Золото
		$Rez = $Usr->GetUserGold($_SESSION["vn_id"]);
		break;
	case "E":
		// Опыт
		$Rez = $Usr->GetUserExp($_SESSION["vn_id"]);
		break;
}
//$file = fopen ("getuserattribute.txt","w+");
//fputs($file, $Type." = ".$Rez);
echo $Rez;
?>
