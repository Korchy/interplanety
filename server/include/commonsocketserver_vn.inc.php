<?php
//---------------------------------
// Сокет-сервер (абстрактный)
//---------------------------------
require_once("daemon.inc.php");
//---------------------------------
class CommonSocketServerVn extends Daemon
{
	
	var $SocketPort;		// Порт сокета
	var $MaxClients;		// Максимально допустимое кол-во клиентов (если больше - отказ в подключении через сокет)
	var $MasterSocket;		// Мастер-сокет (слушает и обрабатывает подключения)
	var $ClientSockets;		// Массив соединений с сокетами-клиентами
	public static $PIDFileName = "/var/www/vn/tmp/commonsocketserver.pid";	// Пути задаются абсолютные т.к. домашний каталог для демона присваивается = корню;
	
	public function __construct() {
		// Конструктор родителя
		parent::__construct();
		// Конструктор
		$this->SetLog("/var/www/vn/tmp/commonsocketserver.log");
		$this->IterationDelay = 400;	// Задержка итерации на 40 мс - выполняется 25 раз в секунду
		$this->SocketPort = 33307;	// Дефолтный открытый рабочий порт
		$this->MaxClients = 1000;	// Больше 247 все равно не подключает (видимо ограничение php)
	}

	public function __destruct() {
		// Деструктор
		// Удаляем только в рабочем процессе-демоне, чтобы не удалились при промежуточных форках
		if($this->PID>0) {
			// Удалить мастер-сокет
			$this->ShutDownSocket($this->MasterSocket);
			unset($this->MasterSocket);
			// Очистить массив подключений
			foreach($this->ClientSockets[0] as $SocketId) {
				$this->ShutDownSocket($SocketId);
			}
			unset($this->ClientSockets[0]);
			unset($this->ClientSockets[1]);
			unset($this->ClientSockets[2]);
			unset($this->ClientSockets[3]);
			unset($this->ClientSockets);
		}
		// Деструктор родителя
		parent::__destruct();
	}
	public function Init() {
		// Инициализация сокет-сервера
		if($this->IsRunning()==false) {
			// Инициализация объектов только для первого запуска (чтобы запуск с параметрами при уже запущенном сервере не вызывал инициализацию)
			// Создать мастер-сокет
			$this->MasterSocket = socket_create(AF_INET,SOCK_STREAM,SOL_TCP);
			socket_set_option($this->MasterSocket,SOL_SOCKET,SO_REUSEADDR,1);	// Иначе при запуске сразу после выключения выдает ошибку unable to bind address [98]: Address alredy in use
			if(socket_bind($this->MasterSocket,0,$this->SocketPort)==false) {
				// Если остановить и сразу запустить сокет-сервер, получаем ошибку: unable to bind address [98]: Address already in use
				// т.к. соединения с клиентскими сокетами-клиентами уничтожаются с задержкой -> при ошибке не стартуем
				$SocketLastErr = socket_last_error($this->MasterSocket);
				$this->Log("ERR:	socket_bind (".$SocketLastErr.") ".socket_strerror($SocketLastErr));
				// Удалить мастер-сокет
				$this->ShutDownSocket($this->MasterSocket);
				unset($this->MasterSocket);
				return false;
			}
			socket_listen($this->MasterSocket);
			socket_set_nonblock($this->MasterSocket);	// Устанавливаем неблокирующим, чтобы socket_select не зависала при имеющихся непрочитанных в буфере данных
			// Клиенты: массив в 4 строки
			$this->ClientSockets = array();
			$this->ClientSockets[0] = array();	// указатели на сокет
			$this->ClientSockets[1] = array();	// id пользователя
			$this->ClientSockets[2] = array();	// буфер чтения из сокета
			$this->ClientSockets[3] = array();	// буфер записи в сокет
			return true;
		}
		return false;
	}
	
	public function Start() {
		// Начало работы
		if(PHP_OS=="WINNT") {
			// Для Windows - не запускаем
			
		}
		else {
			// Для Debian (сервера) - демонизироваться и запустить работу
			// Демонизация и начало работы
			parent::Start();
		}
	}
	
	public function Iteration() {
		// Выполняемое действие
		// Проверить изменение состояния сокетов
		$Read = $this->ClientSockets[0];					// Массив работающих сокетов
		$Read[] = $this->MasterSocket;						// Добавть в список мастер-сокет
		$ClientsCount = count($Read);						// Общее кол-во присоединенных клиентов
		$ClientSocketChangedCount = socket_select($Read,$Write = NULL,$Except = NULL,0);
		if($ClientSocketChangedCount>0) {
			// Состояние изменилось
			// Проверить мастер-сокет
			if(in_array($this->MasterSocket,$Read)) {
				// Изменился мастер-сокет - подключение нового клиента
				if($ClientsCount<$this->MaxClients) {
					// Подключить нового клиента и добавить его в список клиентов
					$NewClient = socket_accept($this->MasterSocket);
					if($NewClient!=false) {
						socket_set_nonblock($NewClient);	// Устанавливаем неблокирующим, чтобы socket_select не зависала при имеющихся непрочитанных в буфере данных
						$this->ClientSockets[0][$NewClient] = $NewClient;	// сокет
						$this->ClientSockets[1][$NewClient] = "";			// id пользователя
						$this->ClientSockets[2][$NewClient] = "";			// буфер чтения
						$this->ClientSockets[3][$NewClient] = "";			// буфер записи
					}
					// Удалить мастер-сокет из списка $Read т.к. в него ничего не читается/пишется
					$MS = array_search($this->MasterSocket,$Read);
					unset($Read[$MS]);
				}
			}
			// Проверить получение данных от клиентов
			foreach($Read as $Client) {
				// Читаем последовательно из клиент-сокетов
				$RData = socket_read($Client,1024);
				// Прочитано '' или false - клиент отключился
				if($RData===''||$RData===false) {
					$this->ReadDataErr($Client);	// Ошибка чтения
				}
				else {
					// Прочитаны данные - занести в буфер чтеия
					$RData = trim($RData);
//					print($RData."\n\r");
					if(strlen($RData)>0) {
						$this->ReadData($Client,$RData);
					}
				}
			}
		}
		// Обработка полученных от клиента данных
		$this->ProcessReceivedData();
		// Обработка отправляемых клиентам данных
		$this->ProcessSendingData();
	}
	
	public function ShutDownSocket($SSocket) {
		// Корректное закрытие сокета
		if(is_resource($SSocket)) {
			@socket_shutdown($SSocket,1);	// Оборвать запись (глушить ошибки т.к. если клиентский сокет не подключен или отвалился - выдается warning: unable to shutdown socket [107]: Transport endpoint is not connected)
			$SocketLastErr = socket_last_error($SSocket);	// Другие ошибки - в лог (для дальнейшего разбирательства)
			if($SocketLastErr!=0&&$SocketLastErr!=107) $this->Log("ERR:	socket_shutdown(1) (".$SocketLastErr.") ".socket_strerror($SocketLastErr));
			usleep(500);					// Подождать ответа
			@socket_shutdown($SSocket,0);	// Оборвать чтение
			$SocketLastErr = socket_last_error($SSocket);	// Другие ошибки - в лог (для дальнейшего разбирательства)
			if($SocketLastErr!=0&&$SocketLastErr!=107) $this->Log("ERR:	socket_shutdown(0) (".$SocketLastErr.") ".socket_strerror($SocketLastErr));
			socket_close($SSocket);			// Закрыть сокет
			unset($this->ClientSockets[0][$SSocket]);	// отсоединить id сокета
			unset($this->ClientSockets[1][$SSocket]);	// отсоединить id пользователя
			unset($this->ClientSockets[2][$SSocket]);	// отсоединить буфер чтения сокета
			unset($this->ClientSockets[3][$SSocket]);	// отсоединить буфер записи в сокет
		}
	}
	
	public function ReadData($Socket,$Data) {
		// Данные прочитаны из сокета - занести их в буфер чтения
		$this->ClientSockets[2][$Socket] = $this->ClientSockets[2][$Socket].$Data;
	}
	
	public function ReadDataErr($Socket) {
		// Ошибка чтения данных из сокета (клиент отключился)
		// Ошибки - в лог (для дальнейшего разбирательства)
		$SocketLastErr = socket_last_error($Socket);
		if($SocketLastErr!=0) $this->Log("ERR:	socket_read (".$SocketLastErr.") ".socket_strerror($SocketLastErr));
		// Закрыть сокет клиента
		$this->ShutDownSocket($Socket);
	}
	
	public function ProcessReceivedData() {
		// Обработка полученных данных
		
	}
	
	public function ProcessSendingData() {
		// Обработка отправляемых данных
		
	}
	
	public function GetSocketByUserId($UserId) {
		// Возвращает сокет по Id пользователя (если не найден возвращает null)
		foreach($this->ClientSockets[0] as $FSocket) {
			if($this->ClientSockets[1][$FSocket]==$UserId) {
				return $FSocket;
				break;
			}
		}
		return null;
	}
}
?>