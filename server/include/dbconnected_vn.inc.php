<?php
//---------------------------------
// Соединение с базой данных
//---------------------------------
require_once("mysqliex.inc.php");
require_once("common.inc.php");
//---------------------------------
class DBConnectedVn
{
	public $Sql;			// Объект для работы с БД
	
	public function __construct() {
		// Конструктор
		// Подключиться к БД
		$this->Sql = new MySqliEx();
		$this->Sql->Connect();
		$this->Sql->Fastcharset();
		$this->Sql->SetUnsignedSubstraction();
	}

	public function __destruct() {
		// Деструктор
		// Отсоединиться от БД
		$this->Sql->Disconnect();
		unset($this->Sql);
	}
}
?>