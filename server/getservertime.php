<?php
//---------------------------------
require_once("include/servertime.inc.php");
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
// ¬ернуть количество милисекунд прошедших с 01.01.1970:00:00:00 GMT (оно же UTC)
$STime = new ServerTime();
echo $STime->GetServerTime();
?>
