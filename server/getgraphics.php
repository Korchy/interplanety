<?php
//---------------------------------
require("include/image.inc.php");
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
// �������� ��������� ������ �� �������
$Img = new Image();	// ������ ��� ��������� ������ �� �������
//$file = fopen ("getgraphics.txt","w+");
//fputs($file,$Img->GetImagesInfo());
echo $Img->GetImagesInfo();
?>
