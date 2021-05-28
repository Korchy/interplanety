<?php
//---------------------------------
// Работа с базой данный MySql через MySqli
//---------------------------------
require_once("common.inc.php");
require_once("log.inc.php");
require_once("config.inc.php");
//---------------------------------
class MySqliEx {
	private $Connection;	// Текущее соединение с б.д.
	public $SqlQuery;		// Текст Sql-запроса
	public $SqlRez;			// Результат выполнения Sql-запроса
	private $SqlRezArray;	// Массив со всеми результатами выполнения запросов для их принудительной очистки при отключении
	private $MysqlLog;		// Log

	public function __construct() {
		// Конструктор
		$this->Connection = NULL;
		$this->MysqlLog = new Log(Common::TmpDir()."/log.log");
		$this->SqlRezArray = array();
	}
	
	public function __destruct() {
		// Деструктор
		$this->Disconnect();
		unset($this->SqlRezArray);
		unset($this->MysqlLog);
	}
	
	public function Connect() {
		// Cоединиться с БД
		// Получить параметры соединения из конфига
		$Conf = new Config(Common::IncDir()."/config.xml");
		$this->Connection = new mysqli($Conf->Data["db"]["host"], $Conf->Data["db"]["user"], $Conf->Data["db"]["password"], $Conf->Data["db"]["base"]);
		if ($this->Connection->connect_errno) {
			$this->MysqlLog->Add("Не удалось подключиться к БД: (".$this->Connection->connect_errno.") ".$this->Connection->connect_error);
		}
		$this->SelectDB($Conf->Data["db"]["base"]);
	}
	
	public function SelectDB($DBName) {
		// Выбор базы данных
		$this->Connection->select_db($DBName);
	}
	
	public function Disconnect() {
		// Отсоединиться от БД
		// Очистить данные запросов
		while(count($this->SqlRezArray)>0) {
			$this->SqlRezArray[0]->free();
			array_splice($this->SqlRezArray,0,1);
		}
		// Закрыть соединение
		if($this->Connection) {
			$this->Connection->close();
			$this->Connection = NULL;
		}
	}
	
	public function Exec() {
		// Выполнить Sql-запрос
		if($this->SqlQuery!="") {
//			echo "<P>".$this->SqlQuery."<P>";								// ПОКАЗ ТЕКСТА ЗАПРОСА
//			$this->MysqlLog->Add($this->SqlQuery);							// ТЕКСТ ЗАПРОСА В ЛОГ
			$this->SqlRez = $this->Connection->query($this->SqlQuery);
			if($this->SqlRez===false) {
				$this->MysqlLog->Add("Ошибка выполнения запроса к БД: ".$this->SqlQuery);
				$this->MysqlLog->Add($this->Connection->error);
//				print($this->SqlQuery."/n/r");
				return false;
			}
			// В массив может попасть только объект mysqli_result с результатами запроса
			if($this->SqlRez!==true) $this->SqlRezArray[] = $this->SqlRez;
  			return true;
		}
		else return false;
	}
	
	public function FreeResult($Rez) {
		// Освобождение памяти, занятой результатом запроса $Rez
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
		// Поставить курсор текущего результата в первую позицию
		if($Rez && $Rez!==true) {
			$Rez->data_seek(0);
		}
	}

	public function Fastcharset() {
		// Установка перекодировки "налету"
		$this->SqlRez = $this->Connection->query("SET CHARACTER SET cp1251_koi8;");
		if(!$this->SqlRez) {
			$this->MysqlLog->Add("Ошибка установки перекодировки \"на лету\"");
			return false;
		}
		return true;
	}

	public function SetUnsignedSubstraction($Value=true) {
		// В MySQL 4 и выше при вычитании двух беззнаковых величин результат тоже будет беззнаковый
		// Если установить режим NO_UNSIGNED_SUBTRACTION эта проверка включаться не будет
		if($Value==true) {
			$this->SqlRez = $this->Connection->query("SET sql_mode = 'NO_UNSIGNED_SUBTRACTION';");
			if(!$this->SqlRez) {
				$this->MysqlLog->Add("Ошибка включения режима NO_UNSIGNED_SUBTRACTION");
				return false;
			}
			return true;
		}
		else {
			return false;
		}
	}

	public function Rows($Rez) {
		// Возвращает количество строк в запросе
		if($Rez && $Rez!==true) return $Rez->num_rows;
	}
	
	public function Escape($Text) {
		// Экранирование служебных символов для запросов
		if($this->Connection!=NULL) {
			// Стандартное экранирование
			$Text = $this->Connection->real_escape_string($Text);
			// Дополнительные знаки
			$Text = addcslashes($Text,'%_');
			return $Text;
		}
		else return '';
	}
	
	public function FetchAll($ResultType = MYSQLI_NUM) {
		// Возвращает все строки результата запроса в виде массива
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