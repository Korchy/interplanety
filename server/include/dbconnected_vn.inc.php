<?php
//---------------------------------
// ���������� � ����� ������
//---------------------------------
require_once("mysqliex.inc.php");
require_once("common.inc.php");
//---------------------------------
class DBConnectedVn
{
	public $Sql;			// ������ ��� ������ � ��
	
	public function __construct() {
		// �����������
		// ������������ � ��
		$this->Sql = new MySqliEx();
		$this->Sql->Connect();
		$this->Sql->Fastcharset();
		$this->Sql->SetUnsignedSubstraction();
	}

	public function __destruct() {
		// ����������
		// ������������� �� ��
		$this->Sql->Disconnect();
		unset($this->Sql);
	}
}
?>