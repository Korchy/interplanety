<?php
//---------------------------------
require_once("include/mysqliex.inc.php");
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
$ClData = "";	// ���������� �� ������� ������
if (isset($_REQUEST['Data'])) $ClData = $_REQUEST['Data'];
//---------------------------------
$SData = "";	// ������������ ������������ ������
// ������������
$Sql = new MySqliEx();
$Sql->Connect();
$Sql->Fastcharset();
// �������� ���������� ������ � read_buff
$Sql->SqlQuery = "update vn_user_connections set read_buff=concat(read_buff,\"".$Sql->Escape($ClData)."\") where user_id=\"".$Sql->Escape($_SESSION["vn_id"])."\";";
$Sql->Exec();
// �������� ������ �� ������� �� write_buff
$Sql->SqlQuery = "select write_buff from vn_user_connections where user_id=\"".$Sql->Escape($_SESSION["vn_id"])."\";";
$Sql->Exec();
if($SQLRez = $Sql->SqlRez) {
	while($tmp = $SQLRez->fetch_array()) {
		$SData = $tmp["write_buff"];
		$SDataLength = strlen($SData);
		$Sql->SqlQuery = "update vn_user_connections set write_buff=substring(write_buff,".($SDataLength+1).") where user_id=".$Sql->Escape($_SESSION["vn_id"]).";";
		$Sql->Exec();
	}
	$Sql->FreeResult($SQLRez);
}
// ��������� ������ ������������
//$file = fopen ("getsocketdata.txt","w+");
//fputs($file, $SData);
echo $SData;
?>