<?php
//---------------------------------
// �������� ��������� (ByteArray) �� ������
//---------------------------------
require_once("include/common.inc.php");
//---------------------------------
if (isset($GLOBALS["HTTP_RAW_POST_DATA"])) {
	$Parts = explode("_0vn0_",$GLOBALS["HTTP_RAW_POST_DATA"]);
	// ��������, ��� ����� �� ���������
	$ProgIdent = $Parts[2];	// interplanety
	if($ProgIdent==''||$ProgIdent!=Common::ProgramIdentificator()) {
		header("Location: login");
		return;
	}
	// �������� ������������
	$SId = $Parts[1];
	if ($SId!='') {
		session_id($SId);
	}
	session_start();
	// ���� ��� ����������� - �������� �� �������� �����������
	if(!isset($_SESSION["vn_id"])) {
		session_destroy();
		header("Location: login");
		return;
	}
	// ��������� �������� � ����������
	$File = fopen(Common::VirtualSystemScreenDir()."/".$_SESSION["vn_id"].".jpg",'wb');
	fwrite($File,$Parts[0]);
	fclose($File);
}
?>