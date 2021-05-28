<?php
//---------------------------------
require_once("dbconnected_vn.inc.php");
//---------------------------------
class Language extends DBConnectedVn
{
	public $LangName;	// Наименование переменной, в которой хранится текущий язык
	public $LangTime;	// Время сохранения настроек языка в cookie

	public function __construct() {
		// Конструктор родителя
		parent::__construct();
		// Конструктор
		$this->LangName = "vn_lang";
		$this->LangTime = 2952000;	// 30 дней
	}

	public function __destruct() {
		// Деструктор
		
		// Деструктор родителя
		parent::__destruct();
	}

	public function Text($id) {
		// Возвращает для $id на нужном языке $lang нужную фразу
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
		// Проверка переключения языка
		if(isset($_GET["changelang"])) {
			// Было переключение языка
			setcookie($this->LangName,$_GET["changelang"],time()+$this->LangTime);	// Установить cookie
			$_SESSION[$this->LangName] = $_GET["changelang"];
			header("Location: ".$page);
		}
		else {
			// Переключения языка небыло, проверить по cookie
			if(!isset($_COOKIE[$this->LangName])) {
				setcookie($this->LangName,"rus",time()+$this->LangTime);	// Установить cookie
				$_SESSION[$this->LangName] = "rus";
			}
			else {
				setcookie($this->LangName,$_COOKIE[$this->LangName],time()+$this->LangTime);	// Продлить срок действия cookie
				$_SESSION[$this->LangName] = $_COOKIE[$this->LangName];
			}
		}
	}
}
?>