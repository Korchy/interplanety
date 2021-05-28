<?php
//---------------------------------

//---------------------------------
class ServerTime
{
	public function __construct() {
		// Конструктор
		
	}

	public function __destruct() {
		// Деструктор
		
	}

	public function GetServerTime() {
		// Вернуть количество милисекунд прошедших с 01.01.1970:00:00:00 GMT (оно же UTC)
		list($usec, $sec) = explode(" ", microtime());
		return round(((float)$usec + (float)$sec)*1000);
	}
}
?>