<?php
//---------------------------------
// Policy-сервер
//---------------------------------
require_once("commonsocketserver_vn.inc.php");
require_once("common.inc.php");
//---------------------------------
class PolicyServerVn extends CommonSocketServerVn
{
	public static $PIDFileName = "/var/www/vn/tmp/policyserver.pid";	// Пути задаются абсолютные т.к. домашний каталог для демона присваивается = корню;
	private static $PolicyFileName = "/var/www/vn/include/policy.xml";
	
	public function __construct() {
		// Конструктор родителя
		parent::__construct();
		// Конструктор
		$this->SetLog("/var/www/vn/tmp/policyserver.log");
		$this->SocketPort = 843;	// Дефолтный порт для отдачи файла политик
	}

	public function __destruct() {
		// Деструктор
		
		// Деструктор родителя
		parent::__destruct();
	}
	
	public function ProcessReceivedData() {
		// Обработка полученных данных
		foreach($this->ClientSockets[0] as $UCl) {
			$ClData = $this->ClientSockets[2][$UCl];
			if($ClData!="") {
				if(strpos("<policy-file-request/>",$ClData)===false) {
					// Пришло что-то левое - оборвать соединение
					$this->ShutDownSocket($UCl);
					continue;
				}
				if($ClData=="<policy-file-request/>") {
					// Пришел запрос файла политики
					// Считать файл политики из файла
					$Policy = new DOMDocument('1.0','utf-8');
					$Policy->load(static::$PolicyFileName);
					// Занести его в буфер записи в сокет
					$this->ClientSockets[3][$UCl] = $Policy->saveXML()."\0";
				}
			}
		}
	}
	
	public function ProcessSendingData() {
		// Обработка отправляемых данных
		foreach($this->ClientSockets[0] as $UCl) {
			if($this->ClientSockets[3][$UCl]!="") {
				// Если файл политики записан в буфер записи - отдать его клиенту
				$DataLength = strlen($this->ClientSockets[3][$UCl]);
				$BytesWritten = @socket_write($UCl,$this->ClientSockets[3][$UCl],$DataLength);
				// Глушить ошибки т.к. если клиентский сокет не подключен или отвалился - выдается warning: unable to write to socket [32]: Broken pipe
				// Другие ошибки - в лог (для дальнейшего разбирательства)
				$SocketLastErr = socket_last_error($UCl);
				if($SocketLastErr!=0&&$SocketLastErr!=32) $this->Log("ERR:	socket_write (".$SocketLastErr.") ".socket_strerror($SocketLastErr));
				if($BytesWritten===false) {
					// Клиентский сокет отключился (в ошибку вываливается со второй попытки записи в сокет с отвалившимся клиентом)
					$this->ShutDownSocket($UCl);
				}
				else {
					// Данные успешно записаны
					$this->ClientSockets[3][$UCl] = substr($this->ClientSockets[3][$UCl],$BytesWritten);
					// Если отдали файл полностью - закрыть соединение
					if($this->ClientSockets[3][$UCl]=="") {
						$this->ShutDownSocket($UCl);
					}
				}
			}
		}
	}	
}
?>