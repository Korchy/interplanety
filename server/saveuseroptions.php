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
// ������ ���������������� ����������
$UOpt = new UserVn();
$UOpt->SaveOptions($_SESSION["vn_id"]);
echo "a=1";	// ������ ����� ����� ���� ������������ �������� ��� ��������� URLLoaderDataFormat.VARIABLES ����������
?>
