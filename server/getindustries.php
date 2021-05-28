<?php
//------------------------------------------------------------------------------------------------------------------------------------
// «агрузка перечн€ производств дл€ конкретного сектора звездной системы
//------------------------------------------------------------------------------------------------------------------------------------
require_once("include/industry.inc.php");
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
// ¬ходные параметры
$StarSystemId = 1;	// Id в vn_starsystem
if (isset($_REQUEST['StarSystemId'])) $StarSystemId = $_REQUEST['StarSystemId'];
//---------------------------------
	// ƒанные  передаютс€ в виде XML-документа
	// ѕолучить данные о производстве на планете
$Ind = new Industry();
$Rez = $Ind->GetIndustries($StarSystemId);
	// ¬ернуть сгенерированный XML
//$file = fopen ("getindustries".$StarSystemId.".xml","w+");
//fputs($file, $Rez->saveXML());
echo $Rez->saveXML();
?>