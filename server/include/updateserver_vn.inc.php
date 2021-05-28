<?php
//---------------------------------
// Сервер обновления состояния вселенной
//---------------------------------
require_once("daemon.inc.php");
require_once("industry.inc.php");
require_once("happy.inc.php");
require_once("routes.inc.php");
//---------------------------------
class UpdateServerVn extends Daemon
{
	
	var $WorkProcessPID;
	public static $PIDFileName = "/var/www/vn/tmp/updateserver.pid";	// Пути задаются абсолютные т.к. домашний каталог для демона присваивается = корню;
	
	public function __construct() {
		// Конструктор родителя
		parent::__construct();
		// Конструктор
		if(PHP_OS=="WINNT") $this->SetLog("tmp/updateserver.log");
		else  $this->SetLog("/var/www/vn/tmp/updateserver.log");
		$this->IterationDelay = 500;	// Задержка итерации на 500 мс - выполняется 2 раза в секунду
		$this->WorkProcessPID = 0;
	}

	public function __destruct() {
		// Деструктор
		
		// Деструктор родителя
		parent::__destruct();
	}

	public function Start() {
		// Начало работы
		if(PHP_OS=="WINNT") {
			// Для Windows - просто один раз отработать обновление
			$this->Update();
		}
		else {
			// Для Debian (сервера) - демонизироваться и запустить работу
			parent::Start();
		}
	}
	
	public function Iteration() {
		// Выполняемое действие
		// Создать чайлд-процесс для выполнения обработки
		if($this->WorkProcessPID==0) {
			// Рабочего процесса нет - запустить
			$this->CreateWorkProcess();
		}
	}
	
	public function CreateWorkProcess() {
		// Создать рабочий процесс
		// Породить чайлд-процесс
		$CurrentPID = pcntl_fork();
		switch($CurrentPID) {
			case -1:
				// Ошибка
				break;
			case 0:
				// Чайлд-процесс
				$this->PID = posix_getpid();
				$this->Update();	// Отработать обновление
				$this->Running = false;	// Закончить рабочий цикл
				break;
			default:
				// Текущий процесс
				$this->WorkProcessPID = $CurrentPID;
		}
	}
	
	public function ProcessSigchld() {
		// Обработка сигнала SIGCHLD
		parent::ProcessSigchld();
		$this->WorkProcessPID = 0;
	}
	
	public function Update() {
		// Обновление данных
		// Обновление производства
		$Ind = new Industry();
		$Ind->Produce();
		// Обновить показатель довольства на планетах
		$PHappy = new Happy();
		$PHappy->Update();
		// Проверить на окончание маршрутов
		$Routes = new URoutes();
		$Routes->CheckFinish();
	}
}
?>