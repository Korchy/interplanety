<?php
//---------------------------------
// Класс - демон для выполнения процесса в фоновом режиме
//---------------------------------
require_once("log.inc.php");
require_once("servertime.inc.php");
//---------------------------------
class Daemon
{
	var $PID;			// Идентификатор процесса
	public static $PIDFileName = "tmp/daemon.pid";	// Файл с идентификатором процесса
	var $LogFile;
	var $Running;	// Флаг - указатель работать
	var $IterationDelay;	// Задержка между выполнениями итераций в мс
	
	public function __construct() {
		// Конструктор
		set_time_limit(0);	// Время выполнения - бесконечно
		$PID = -2;	// Невозможный идентификатор
		$this->Running = false;
		$this->IterationDelay = 1000;
	}

	public function __destruct() {
		// Деструктор
	}

	public function Start() {
		// Инициализация работы
		$this->Log("START DAEMON");
		// Проверить не запущен ли уже процесс
		if($this->IsRunning()==true) {
			$this->Log("DOUBLE START");
			return false;
		}
		// Демонизировать процесс
		if($this->Daemonize()==false) return false;
		// Запустить рабочий цикл
		$this->MLConstruct();	// Выполнение операций до начала основного цикла (инициализация каких-либо объектов в рабочем процессе)
		$STime = new ServerTime();
		$LastTime = $STime->GetServerTime();
		while($this->Running==true) {
			// Рабочий цикл
			$this->Iteration();
			// Задержка
			$CurrentTime = $STime->GetServerTime();
			$Delay = $this->IterationDelay - ($CurrentTime - $LastTime);
			$LastTime = $CurrentTime;
			if($Delay<=0) $Delay = 1;
			usleep($Delay*1000);	// Задержка на $IterationDelay минус время затраченное на выполнение итерации цикла (*1000 т.к. usleep счтает в микросекундах (1/1000 милисекунды))
		}
		$this->MLDestruct();	// Выполнение операций по завершении основного цикла (деинициализация каких-либо объектов в рабочем процессе)
		return true;
	}
	
	public function Stop() {
		// Остановить работу
		if(file_exists(static::$PIDFileName)) unlink(static::$PIDFileName);	// Удалить PID-файл
		$this->Running = false;		// Остановить рабочий цикл
		$this->Log("STOP DAEMON");
	}
	
	public function Iteration() {
		// Итерация работы цикла
		
	}
	
	public function Daemonize() {
		// Демонизация процесса
		$Rez = false;
		// Породить первый чайлд-процесс
		$CurrentPID = pcntl_fork();
		switch($CurrentPID) {
			case -1:
				// Ошибка
				$this->Log("FORK ERR");
				break;
			case 0:	
				// Первый чайлд-процесс
				// Для первого чайлд-процесса - отсоединить дескрипторы
				umask(0);
				chdir("/");
				// Породить второй чайлд-процесс
				if(posix_setsid()>=0) {	// Отвязаться от терминала
					$CurrentPID = pcntl_fork();
					switch($CurrentPID) {
						case -1:
							// Ошибка
							$this->Log("FORK2 ERR");
							break;
						case 0:
							// Второй чайлд-процесс
							$this->PID = posix_getpid();
							// Сохранить PID в файл
							if(file_put_contents(static::$PIDFileName,$this->PID)>0) {
								// Регистрируем обработку сигналов
								declare(ticks = 1);
								pcntl_signal(SIGTERM,array(&$this,"ProcessSigterm"));	// Завершение процесса
								pcntl_signal(SIGQUIT,array(&$this,"ProcessSigquit"));	// Завершение процесса
								pcntl_signal(SIGCHLD,array(&$this,"ProcessSigchld"));	// Процесс-чайл завершился
								// Демонизация прошла успешно
								$this->Running = true;
								$Rez = true;
							}
							break;
						default:
							// >0 Первый чайлд-процесс - завершить
					}
				}
				break;
			default:
				// >0 Родительский процесс - завершить
		}
		return $Rez;
	}
	
	public static function IsRunning() {
		// Проверка на то, что процесс уже выполняется
		$Rez = false;
		if(file_exists(static::$PIDFileName)==true) {
			// Если PID-файл существует
			$FilePID = (int)file_get_contents(static::$PIDFileName);
			if($FilePID>0&&posix_kill($FilePID,0)==true) {
				// Процесс работает
				$Rez = true;
			}
			else {
				// Процесс не был запущен
				unlink(static::$PIDFileName);	// Удалить PID-файл, оставшийся от предыдущего запуска
				$Rez = false;
			}
		}
		return $Rez;
	}
	
	public function SetLog($String) {
		// Подключение лога
		$this->LogFile = new Log($String);
	}
	
	public function Log($String) {
		// Добавление записи в лог
		if($this->LogFile!=null) $this->LogFile->Add($String);
	}
	
	public function ProcessSigterm() {
		// Обработка сигнала SIGTERM
		$this->Stop();
	}
	public function ProcessSigquit() {
		// Обработка сигнала SIGQUIT
		$this->Stop();
	}
	public function ProcessSigchld() {
		// Обработка сигнала SIGCHLD
		// Завершился чайлд-процесс
		while(pcntl_waitpid(-1,$status,WNOHANG)>0);
	}
	
	public function MLConstruct() {
		// Main Loop Constructor если какие-то объекты нужно инициализировать только в рабочем процессе
	}
	
	public function MLDestruct() {
		// Main Loop Destructor - удаление объектов, созданных в MLConstruct
	}

}
?>