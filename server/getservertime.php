<?php
//---------------------------------
require_once("include/servertime.inc.php");
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
// ������� ���������� ���������� ��������� � 01.01.1970:00:00:00 GMT (��� �� UTC)
$STime = new ServerTime();
echo $STime->GetServerTime();
?>
