<?php
//---------------------------------

//---------------------------------
class ServerTime
{
	public function __construct() {
		// �����������
		
	}

	public function __destruct() {
		// ����������
		
	}

	public function GetServerTime() {
		// ������� ���������� ���������� ��������� � 01.01.1970:00:00:00 GMT (��� �� UTC)
		list($usec, $sec) = explode(" ", microtime());
		return round(((float)$usec + (float)$sec)*1000);
	}
}
?>