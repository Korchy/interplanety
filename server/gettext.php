<?php
//---------------------------------
require("include/gettext.inc.php");
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
// �������� ����� �� ������ �����
$Text = new VNText();	// ������ ��� ��������� ������ �� �������
echo $Text->GetDictionary();
?>
