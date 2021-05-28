<?php
//---------------------------------

//---------------------------------
if (isset($_REQUEST['session_id'])) {
	session_id($_REQUEST['session_id']);
}
session_start();
// ≈сли нет авторизации - вернутс€ на страницу авторизации
if(!isset($_SESSION["vn_id"])) {
	session_destroy();
	header("Location: login");
}
//---------------------------------
// ¬ернуть им€ сервера
//---------------------------------
echo $_SERVER["SERVER_NAME"];
?>