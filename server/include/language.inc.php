<?php
//---------------------------------
require_once("dbconnected_vn.inc.php");
//---------------------------------
class Language extends DBConnectedVn
{
	public $LangName;	// ������������ ����������, � ������� �������� ������� ����
	public $LangTime;	// ����� ���������� �������� ����� � cookie

	public function __construct() {
		// ����������� ��������
		parent::__construct();
		// �����������
		$this->LangName = "vn_lang";
		$this->LangTime = 2952000;	// 30 ����
	}

	public function __destruct() {
		// ����������
		
		// ���������� ��������
		parent::__destruct();
	}

	public function Text($id) {
		// ���������� ��� $id �� ������ ����� $lang ������ �����
		$Rez = "VN_LANG_ERR";
		$this->Sql->SqlQuery = "select ".$this->Sql->Escape($_SESSION[$this->LangName])." from vn_text where id='".$this->Sql->Escape($id)."';";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			$tmp = $SQLRez->fetch_array();
			$Rez = $tmp[$_SESSION[$this->LangName]];
			$this->Sql->FreeResult($SQLRez);
		}
		return $Rez;
	}

	public function CheckLang($page) {
		// �������� ������������ �����
		if(isset($_GET["changelang"])) {
			// ���� ������������ �����
			setcookie($this->LangName,$_GET["changelang"],time()+$this->LangTime);	// ���������� cookie
			$_SESSION[$this->LangName] = $_GET["changelang"];
			header("Location: ".$page);
		}
		else {
			// ������������ ����� ������, ��������� �� cookie
			if(!isset($_COOKIE[$this->LangName])) {
				setcookie($this->LangName,"rus",time()+$this->LangTime);	// ���������� cookie
				$_SESSION[$this->LangName] = "rus";
			}
			else {
				setcookie($this->LangName,$_COOKIE[$this->LangName],time()+$this->LangTime);	// �������� ���� �������� cookie
				$_SESSION[$this->LangName] = $_COOKIE[$this->LangName];
			}
		}
	}
}
?>