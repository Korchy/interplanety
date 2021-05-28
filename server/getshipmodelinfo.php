<?php
//---------------------------------
require_once("include/ships.inc.php");
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
$ShipId = 1;
if (isset($_REQUEST['ShipId'])) $ShipId = $_REQUEST['ShipId'];
//---------------------------------
	// Получить данные по модели корабля с Id = $ShipId
// Данные передаются в виде XML-документа
$Doc = new DOMDocument('1.0','utf-8');
	// Данные по покупке
$Sh = new Ships();
$ShipModelInfo = $Doc->createElement('ShipModelInfo');
$Sh->GetShipModelInfoXML($ShipId,$Doc,$ShipModelInfo);
	// ---
$Doc->appendChild($ShipModelInfo);
// Вернуть сгенерированный XML
//$file = fopen ("getshipmodelinfo.xml","w+");
//fputs($file, $Doc->saveXML());
echo $Doc->saveXML();
?>