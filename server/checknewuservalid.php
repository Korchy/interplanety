<?php
//---------------------------------
// ���� �������� ������������� ������ � Email ��� ��������� ������ ������������
//---------------------------------
require_once("include/user.inc.php");
//---------------------------------
$U = new UserVn();
// �������� ������
if(isset($_POST["vn_newlogin"])) {
	if($U->UserExists($_POST["vn_newlogin"])==true) echo "vn_newlogin=true";
	else echo "vn_newlogin=false";
	return;
}
// �������� Email
if(isset($_POST["vn_newemail"])) {
	if($U->EmailExists($_POST["vn_newemail"])==true) echo "vn_newemail=true";
	else echo "vn_newemail=false";
	return;
}
?>