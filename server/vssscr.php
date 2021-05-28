<?php
//---------------------------------
//require_once("include/user.inc.php");
//---------------------------------
if (isset($_REQUEST['session_id'])) {
	session_id($_REQUEST['session_id']);
}
session_start();
// Если нет авторизации - вернутся на страницу авторизации
if(!isset($_SESSION["vn_id"])) {
	session_destroy();
	header("Location: login");
	return;
}
//---------------------------------
echo "<html>";
echo "<body>";
echo "<img src=\"scr/".$_SESSION["vn_id"].".jpg\">";
echo "</body>";
echo "</html>";
?>