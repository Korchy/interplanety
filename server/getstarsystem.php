<?php
//------------------------------------------------------------------------------------------------------------------------------------
// Загрузка перечня объектов, находящихся в звездной системе со $StarSystemId
//------------------------------------------------------------------------------------------------------------------------------------
require_once("include/starsystem_vn.inc.php");
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
$StarSystemId = 1;
if (isset($_REQUEST['StarSystemId'])) $StarSystemId = $_REQUEST['StarSystemId'];
//---------------------------------
	// Получить данные о секторе
$StarSystem = new StarSystemVn();
$Rez = $StarSystem->GetStarSystemXML($StarSystemId);
	// Вернуть сгенерированный XML
//$file = fopen ("getstarsystem.xml","w+");
//fputs($file, $Rez->saveXML());
echo $Rez->saveXML();
?>