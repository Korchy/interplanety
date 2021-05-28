<?php
//---------------------------------
require("include/gettext.inc.php");
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
// Получить текст на нужном языке
$Text = new VNText();	// Объект для получения данных по сектору
echo $Text->GetDictionary();
?>
