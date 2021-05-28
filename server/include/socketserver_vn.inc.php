<?php
//---------------------------------
// Сокет-сервер
//---------------------------------
require_once("commonsocketserver_vn.inc.php");
require_once("mysqliex.inc.php");
require_once("common.inc.php");
//---------------------------------
class SocketServerVn extends CommonSocketServerVn
{
	
	var $Sql;				// Объект для работы с БД
	public static $PIDFileName = "/var/www/vn/tmp/socketserver.pid";	// Пути задаются абсолютные т.к. домашний каталог для демона присваивается = корню;
	
	public function __construct() {
		// Конструктор родителя
		parent::__construct();
		// Конструктор
		$this->SetLog("/var/www/vn/tmp/socketserver.log");
		$this->SocketPort = 33307;	// Порт обмена данными
	}

	public function __destruct() {
		// Деструктор
		
		// Деструктор родителя
		parent::__destruct();
	}

	public function ReadData($Socket,$Data) {
		// Данные прочитаны из сокета
		if($this->ClientSockets[1][$Socket]=="") {
			// Данные поступили от неидентифицированного клиента - занести их в буфер чтения (пришла идентификация пользователя)
			$this->ClientSockets[2][$Socket] = $this->ClientSockets[2][$Socket].$Data;
		}
		else {
			// Данные поступили от идентифицированного клиента - занести их в базу для последующей обработки
			$this->Sql->SqlQuery = "update vn_user_connections set read_buff=concat(read_buff,\"".$this->Sql->Escape($Data)."\") where user_id=\"".$this->Sql->Escape($this->ClientSockets[1][$Socket])."\";";
			$this->Sql->Exec();
		}
	}
	
	public function ReadDataErr($Socket) {
		// Ошибка чтения данных из сокета (клиент отключился)
		$SocketLastErr = socket_last_error($Socket);
		if($SocketLastErr!=0) $this->Log("ERR:	socket_read (".$SocketLastErr.") ".socket_strerror($SocketLastErr));
		// Закрыть сокет клиента
		if($this->ClientSockets[1][$Socket]!="") {
			// Если отключился идентифицированный клиент
			$this->Sql->SqlQuery = "update vn_user_connections set user_online=\"F\" where user_id=\"".$this->Sql->Escape($this->ClientSockets[1][$Socket])."\";";
			$this->Sql->Exec();
		}
		$this->ShutDownSocket($Socket);
	}

	public function ProcessReceivedData() {
		// Обработка полученных данных (в буфере может быть только идентификация пользователя, все остальное идет в vn_user_connections)
		// Данные должны быть в формате: <001 id="999">
		foreach($this->ClientSockets[0] as $UCl) {
			$ClData = $this->ClientSockets[2][$UCl];
			if($ClData!="") {
				if(strlen($ClData)>=4&&substr($ClData,0,4)!="<001") {
					// Пришло что-то левое - оборвать соединение
					$this->ShutDownSocket($UCl);
					continue;
				}
				if(substr($ClData,strlen($ClData)-1,1)==">") {	// ">" - завершающий символ, значит вся строка данных получена
					// Пакет полностью получен
					$Id = substr($ClData,1,3);
					$Comm = new Common();
					$Params = $Comm->StringToKeyedArray(substr($ClData,5,-1)," ","=");
					// Данные - идентификатор пользователя
					$UserId = $Params["id"];
					// Проверить, не было ли уже коннекта от этого же id (два окна, физический обрыв связи, при котором оборванный сокет не вылетает в ошибку при чтении/записи)
					// Если коннект уже был - закрыть его
					$OldSocket = $this->GetSocketByUserId($UserId);
					if($OldSocket!=null) $this->ShutDownSocket($OldSocket);
					// Присвоить новому коннекту данные пользователя
					$this->ClientSockets[1][$UCl] = $UserId;
					$this->ClientSockets[2][$UCl] = "";
					$this->Sql->SqlQuery = "update vn_user_connections set user_online=\"T\" where user_id='".$this->Sql->Escape($UserId)."';";
					$this->Sql->Exec();
				}
			}
		}
	}
	
	public function ProcessSendingData() {
		// Обработка отправляемых данных
		// Проверить данные в буферах идентифицировынных пользователей
		$this->Sql->SqlQuery = "select user_id,write_buff from vn_user_connections where user_online=\"T\" and write_buff like \"%>%\";";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			while($tmp = $SQLRez->fetch_array()) {
				// Найти указатель на сокет по id пользователя
				$Ind = array_search($tmp["user_id"],$this->ClientSockets[1]);
				$SocketId = $this->ClientSockets[0][$Ind];
				// Данные для записи
				$DataToWrite = substr($tmp["write_buff"],0,strrpos($tmp["write_buff"],">")+1)."\n\0";
				$DataLength = strlen($DataToWrite);
				$BytesWritten = @socket_write($SocketId,$DataToWrite,$DataLength);
				// Глушить ошибки т.к. если клиентский сокет не подключен или отвалился - выдается warning: unable to write to socket [32]: Broken pipe
				// Другие ошибки - в лог (для дальнейшего разбирательства)
				$SocketLastErr = socket_last_error($SocketId);
				if($SocketLastErr!=0&&$SocketLastErr!=32) $this->Log("ERR:	socket_write (".$SocketLastErr.") ".socket_strerror($SocketLastErr));
				if($BytesWritten===false) {
					// Клиентский сокет отключился (в ошибку вываливается со второй попытки записи в сокет с отвалившимся клиентом)
					$this->Sql->SqlQuery = "update vn_user_connections set user_online=\"F\" where user_id=".$this->Sql->Escape($tmp["user_id"]).";";
					$this->Sql->Exec();
					$this->ShutDownSocket($SocketId);
				}
				else {
					// Данные успешно записаны
					$RemainingData = substr($tmp["write_buff"],$BytesWritten);
					$this->Sql->SqlQuery = "update vn_user_connections set write_buff=substring(write_buff,".($BytesWritten-1).") where user_id=".$this->Sql->Escape($tmp["user_id"]).";";
					$this->Sql->Exec();
				}
			}
			$this->Sql->FreeResult($SQLRez);
		}
	}

	public function MLConstruct() {
		// Подключиться к БД - в рабочем процессе т.к. при завершении процесса соединение с базой разрывается в любом случае и в чайлд-процессах не остается
		$this->Sql = new MySqliEx();
		$this->Sql->Connect();
		$this->Sql->Fastcharset();
		$this->Sql->SetUnsignedSubstraction();
	}
	
	public function MLDestruct() {
		// Отключение от БД
		// Очистить таблицу идентифицированных подключений
		$this->Sql->SqlQuery = "update vn_user_connections set user_online='F' where user_online='T';";
		$this->Sql->Exec();
		// Отсоединиться от БД
		$this->Sql->Disconnect();
		unset($this->Sql);
	}
}
?>