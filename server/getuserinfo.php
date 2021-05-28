<?php
//---------------------------------
require_once("include/language.inc.php");
require_once("include/user.inc.php");
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
// Язык
$Lang = new Language();	// Объект для перевода
$User = new UserVn();
	// Данные о пользователе передаются в виде XML-документа
$Doc = new DOMDocument('1.0','utf-8');
$UserNode = $Doc->createElement('User');
	// Общая информация
$UserInfo = $Doc->createElement('UserInfo');
	// Id
$Node = $Doc->createElement('id');
$Value = $Doc->createTextNode($_SESSION["vn_id"]);
$Node->appendChild($Value);
$UserInfo->appendChild($Node);
	// Login
$Node = $Doc->createElement('login');
$Value = $Doc->createTextNode($_SESSION["vn_login"]);
$Node->appendChild($Value);
$UserInfo->appendChild($Node);
	// Rights
$Node = $Doc->createElement('rights');
$Value = $Doc->createTextNode($_SESSION["vn_rights"]);
$Node->appendChild($Value);
$UserInfo->appendChild($Node);
	// Lang
$Node = $Doc->createElement('lang');
$Value = $Doc->createTextNode($_SESSION[$Lang->LangName]);
$Node->appendChild($Value);
$UserInfo->appendChild($Node);
	// --
$UserNode->appendChild($UserInfo);
	// Настройки
$UserOptions = $Doc->createElement('UserOptions');
$User->GetOptionsXML($_SESSION["vn_id"],$Doc,$UserOptions);
	// ---
$UserNode->appendChild($UserOptions);
	// Данные
$UserData = $Doc->createElement('UserData');
$User->GetDataXML($_SESSION["vn_id"],$Doc,$UserData);
	// ---
$UserNode->appendChild($UserData);
	// ---
$Doc->appendChild($UserNode);
	// Вернуть сгенерированный XML
//$file = fopen ("getuserinfo.xml","w+");
//fputs($file, $Doc->saveXML());
echo $Doc->saveXML();
?>
