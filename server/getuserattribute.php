<?php
//---------------------------------
require_once("include/user.inc.php");
//---------------------------------
if (isset($_REQUEST['session_id'])) {
	session_id($_REQUEST['session_id']);
}
session_start();
// ���� ��� ����������� - �������� �� �������� �����������
if(!isset($_SESSION["vn_id"])) {
	session_destroy();
	header("Location: login");
}
//---------------------------------
// ������� ���������
$Type = "C";
if (isset($_REQUEST['Type'])) $Type = $_REQUEST['Type'];
//---------------------------------
// ������� ������
$Rez = 0;
$Usr = new UserVn();
switch($Type) {
	case "C":
		// ���������
		$Rez = $Usr->GetUserCrystals($_SESSION["vn_id"]);
		break;
	case "G":
		// ������
		$Rez = $Usr->GetUserGold($_SESSION["vn_id"]);
		break;
	case "E":
		// ����
		$Rez = $Usr->GetUserExp($_SESSION["vn_id"]);
		break;
}
//$file = fopen ("getuserattribute.txt","w+");
//fputs($file, $Type." = ".$Rez);
echo $Rez;
?>
