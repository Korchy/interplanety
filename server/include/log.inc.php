<?php
//---------------------------------
// Логгер
//---------------------------------
require_once("common.inc.php");
//---------------------------------
class Log {
	
	private $LogFile;	// Файл лога
	
	public function __construct($LogFilePath = "") {
		// Конструктор
		if($LogFilePath == "") $this->LogFile = fopen(__Dir__."\\log.log", "ab");
		else $this->LogFile = fopen($LogFilePath, "ab");
	}

	public function __destruct() {
		// Деструктор
		fclose($this->LogFile);
	}

	public function Add($String) {
		// Добавление данных в лог
		// текущее время - данные
		fputs($this->LogFile, date("Y-m-d H:i:s").":\t".$String."\r\n");
	}
	
	public static function AddToCommonLog($String) {
		// Добавить данные в общий лог
		$commonLog = fopen(Common::TmpDir()."/log.log", "ab");
		fputs($commonLog, date("Y-m-d H:i:s").":\t".$String."\r\n");
		fclose($commonLog);
	}
}
?>