<?php
//---------------------------------
require_once("include/spaceobject.inc.php");
// include всех типов SpaceObject, экземпляры генерируются по имени
require_once("include/starr.inc.php");
require_once("include/orbitr.inc.php");
require_once("include/planetr.inc.php");
require_once("include/stationr.inc.php");
require_once("include/shipyardr.inc.php");
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
$Id = 0;	// Id в звездной системе (vn_starsystem.id)
if (isset($_REQUEST['Id'])) $Id = $_REQUEST['Id'];
//---------------------------------
	// Данные  передаются в виде XML-документа
	// Получить данные о типе SpaceObject
$SO = new SpaceObject();
$SpaceObjectType = $SO->TypeById($Id);
	// По полученному типу получить данные по конкретному SpaceObject
$CurrentSO = new $SpaceObjectType();
$CurrentSOXML = $CurrentSO->GetInfo($Id);
	// Вернуть сгенерированный XML
//$file = fopen ("getspaceobject".$Id.".xml","w+");
//fputs($file, $CurrentSOXML->saveXML());
echo $CurrentSOXML->saveXML();
?>