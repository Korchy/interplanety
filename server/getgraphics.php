<?php
//---------------------------------
require("include/image.inc.php");
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
// Получить текстовые данные по графике
$Img = new Image();	// Объект для получения данных по сектору
//$file = fopen ("getgraphics.txt","w+");
//fputs($file,$Img->GetImagesInfo());
echo $Img->GetImagesInfo();
?>
