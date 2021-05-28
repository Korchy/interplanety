<?php
//---------------------------------
// ������
//---------------------------------
require_once("common.inc.php");
//---------------------------------
class Log {
	
	private $LogFile;	// ���� ����
	
	public function __construct($LogFilePath = "") {
		// �����������
		if($LogFilePath == "") $this->LogFile = fopen(__Dir__."\\log.log", "ab");
		else $this->LogFile = fopen($LogFilePath, "ab");
	}

	public function __destruct() {
		// ����������
		fclose($this->LogFile);
	}

	public function Add($String) {
		// ���������� ������ � ���
		// ������� ����� - ������
		fputs($this->LogFile, date("Y-m-d H:i:s").":\t".$String."\r\n");
	}
	
	public static function AddToCommonLog($String) {
		// �������� ������ � ����� ���
		$commonLog = fopen(Common::TmpDir()."/log.log", "ab");
		fputs($commonLog, date("Y-m-d H:i:s").":\t".$String."\r\n");
		fclose($commonLog);
	}
}
?>