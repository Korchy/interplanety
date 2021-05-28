<?php
//---------------------------------
require_once("include/user.inc.php");
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
$User = new UserVn();
	// ƒанные о пользователе
$Lv = $User->GetUserLevel($_SESSION["vn_id"]);
$Exp = $User->GetUserExp($_SESSION["vn_id"]);
$NextLevelExp = $User->GetNextLevelExp($Lv);
//$file = fopen ("getuserlevel.txt","w+");
//fputs($file, "Level=".$Lv."&Exp=".$Exp."&NextLevelExp=".$NextLevelExp);
echo "Level=".$Lv."&Exp=".$Exp."&NextLevelExp=".$NextLevelExp;
?>
