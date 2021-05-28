<?php
//---------------------------------
// ������ � ����� ������ MySql ����� MySqli
//---------------------------------
require_once("common.inc.php");
require_once("log.inc.php");
require_once("config.inc.php");
//---------------------------------
class MySqliEx {
	private $Connection;	// ������� ���������� � �.�.
	public $SqlQuery;		// ����� Sql-�������
	public $SqlRez;			// ��������� ���������� Sql-�������
	private $SqlRezArray;	// ������ �� ����� ������������ ���������� �������� ��� �� �������������� ������� ��� ����������
	private $MysqlLog;		// Log

	public function __construct() {
		// �����������
		$this->Connection = NULL;
		$this->MysqlLog = new Log(Common::TmpDir()."/log.log");
		$this->SqlRezArray = array();
	}
	
	public function __destruct() {
		// ����������
		$this->Disconnect();
		unset($this->SqlRezArray);
		unset($this->MysqlLog);
	}
	
	public function Connect() {
		// C���������� � ��
		// �������� ��������� ���������� �� �������
		$Conf = new Config(Common::IncDir()."/config.xml");
		$this->Connection = new mysqli($Conf->Data["db"]["host"], $Conf->Data["db"]["user"], $Conf->Data["db"]["password"], $Conf->Data["db"]["base"]);
		if ($this->Connection->connect_errno) {
			$this->MysqlLog->Add("�� ������� ������������ � ��: (".$this->Connection->connect_errno.") ".$this->Connection->connect_error);
		}
		$this->SelectDB($Conf->Data["db"]["base"]);
	}
	
	public function SelectDB($DBName) {
		// ����� ���� ������
		$this->Connection->select_db($DBName);
	}
	
	public function Disconnect() {
		// ������������� �� ��
		// �������� ������ ��������
		while(count($this->SqlRezArray)>0) {
			$this->SqlRezArray[0]->free();
			array_splice($this->SqlRezArray,0,1);
		}
		// ������� ����������
		if($this->Connection) {
			$this->Connection->close();
			$this->Connection = NULL;
		}
	}
	
	public function Exec() {
		// ��������� Sql-������
		if($this->SqlQuery!="") {
//			echo "<P>".$this->SqlQuery."<P>";								// ����� ������ �������
//			$this->MysqlLog->Add($this->SqlQuery);							// ����� ������� � ���
			$this->SqlRez = $this->Connection->query($this->SqlQuery);
			if($this->SqlRez===false) {
				$this->MysqlLog->Add("������ ���������� ������� � ��: ".$this->SqlQuery);
				$this->MysqlLog->Add($this->Connection->error);
//				print($this->SqlQuery."/n/r");
				return false;
			}
			// � ������ ����� ������� ������ ������ mysqli_result � ������������ �������
			if($this->SqlRez!==true) $this->SqlRezArray[] = $this->SqlRez;
  			return true;
		}
		else return false;
	}
	
	public function FreeResult($Rez) {
		// ������������ ������, ������� ����������� ������� $Rez
		if($Rez && $Rez!==true) {
			for($i=0; $i<count($this->SqlRezArray); $i++) {
				if($this->SqlRezArray[$i]===$Rez) {
					$this->SqlRezArray[$i]->free();
					array_splice($this->SqlRezArray,$i,1);
					break;
				}
			}
		}
	}

	public function First($Rez) {
		// ��������� ������ �������� ���������� � ������ �������
		if($Rez && $Rez!==true) {
			$Rez->data_seek(0);
		}
	}

	public function Fastcharset() {
		// ��������� ������������� "������"
		$this->SqlRez = $this->Connection->query("SET CHARACTER SET cp1251_koi8;");
		if(!$this->SqlRez) {
			$this->MysqlLog->Add("������ ��������� ������������� \"�� ����\"");
			return false;
		}
		return true;
	}

	public function SetUnsignedSubstraction($Value=true) {
		// � MySQL 4 � ���� ��� ��������� ���� ����������� ������� ��������� ���� ����� �����������
		// ���� ���������� ����� NO_UNSIGNED_SUBTRACTION ��� �������� ���������� �� �����
		if($Value==true) {
			$this->SqlRez = $this->Connection->query("SET sql_mode = 'NO_UNSIGNED_SUBTRACTION';");
			if(!$this->SqlRez) {
				$this->MysqlLog->Add("������ ��������� ������ NO_UNSIGNED_SUBTRACTION");
				return false;
			}
			return true;
		}
		else {
			return false;
		}
	}

	public function Rows($Rez) {
		// ���������� ���������� ����� � �������
		if($Rez && $Rez!==true) return $Rez->num_rows;
	}
	
	public function Escape($Text) {
		// ������������� ��������� �������� ��� ��������
		if($this->Connection!=NULL) {
			// ����������� �������������
			$Text = $this->Connection->real_escape_string($Text);
			// �������������� �����
			$Text = addcslashes($Text,'%_');
			return $Text;
		}
		else return '';
	}
	
	public function FetchAll($ResultType = MYSQLI_NUM) {
		// ���������� ��� ������ ���������� ������� � ���� �������
		$Rez = array();
		if($this->SqlRez) {
			if (method_exists("mysqli_result","fetch_all")) {
				$Rez = $this->SqlRez->fetch_all($ResultType);
			}
			else {
				while($tmp = mysql_fetch_array($this->SqlRez)) {
					$Rez[] = $tmp;
				}
			}
		}
		return $Rez;
	}
}
?>