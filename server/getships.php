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
$ShipsList = new Ships();
	// Данные о кораблях передаются в виде XML-документа
$Doc = new DOMDocument('1.0','utf-8');
	// Корабли
$UserShips = $Doc->createElement('UserShips');
$ShipsList->GetShipsXML($_SESSION["vn_id"],$Doc,$UserShips);
	// ---
$Doc->appendChild($UserShips);
	// Вернуть сгенерированный XML
//$file = fopen ("getships.xml","w+");
//fputs($file, $Doc->saveXML());
echo $Doc->saveXML();
?>