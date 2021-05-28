package Vn.Connections.Socket 
{
//-----------------------------------------------------------------------------------------------------
// Соединение через сокет
//-----------------------------------------------------------------------------------------------------
	import flash.net.Socket;
	import flash.events.EventDispatcher;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import Vn.System.PHPLoader;
	import Vn.Interplanety;
//-----------------------------------------------------------------------------------------------------
	public class SocketVn extends EventDispatcher {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		private var l_Sock:Socket;
		private var l_Status:uint;	// Статус сокета
		public static const S_NOT_CONNECTED:uint = 0;	// Сокет не соединен
		public static const S_CONNECTING:uint = 1;		// Сокет в процессе соединения
		public static const S_CONNECTED:uint = 2;		// Сокет подсоединен
		private var l_Host:String;						// Имя сервера
		private var HostLoader:PHPLoader;				// Загрузчик для получения имени сервера
		private var l_Port:int = 33307;
		private var l_IBuff:String;		// Буфер полученных от сервера данных (накапливаем данные до получения ">")
		// Константы событий
		public static const CONNECTED:String = "EvSocketConnected";	// Соединение установлено
		public static const NOT_CONNECTED:String = "EvSocketNotConnected";	// Соединение НЕ установлено
		public static const CLOSED:String = "EvSocketClosed";	// Соединение закрыто
		public static const READ_DATABLOCK:String = "EvSocketReadDatablock";	// Получен блок данных
		public static const IO_ERR:String = "EvSocketIOErr";	// Получена ошибка IO
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function SocketVn() {
			// Конструктор предка
			super();
			// Конструктор
			// Создать сокет
			l_Sock = new Socket();
			l_Status = SocketVn.S_NOT_CONNECTED;
			l_IBuff = "";
			l_Host = "";
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		public function _delete():void {
			// Деструктор
			if (l_Status != SocketVn.S_NOT_CONNECTED) CloseConnection();
			l_Sock = null;
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		public function OpenConnection():void {
			// Установить соединение
			l_Status = SocketVn.S_CONNECTING;
			if (l_Host == "") {
				// Получить хост
				HostLoader = new PHPLoader();
				HostLoader.addEventListener(Event.COMPLETE,OnHostGetted);
				HostLoader.addEventListener(IOErrorEvent.IO_ERROR,OnHostGettingErr);
				HostLoader.Load("gethost.php");
			}
			else {
				// Подключить сокет к сокет-серверу
				l_Sock.addEventListener(Event.CONNECT, OnConnect);
				l_Sock.addEventListener(IOErrorEvent.IO_ERROR,OnIOError);
				l_Sock.addEventListener(SecurityErrorEvent.SECURITY_ERROR, OnSecurityError);
				l_Sock.connect(l_Host, l_Port);
			}
		}
//-----------------------------------------------------------------------------------------------------
		public function CloseConnection():void {
			// Закрыть соединение
			if (l_Status == SocketVn.S_CONNECTED) {
				// Сокет был соединен
				l_Sock.removeEventListener(IOErrorEvent.IO_ERROR,OnIOError);
				l_Sock.removeEventListener(Event.CLOSE,OnClose);
				l_Sock.removeEventListener(ProgressEvent.SOCKET_DATA,OnReadDataBlock);
				l_Sock.close();
				l_Status = S_NOT_CONNECTED;
				dispatchEvent(new Event(SocketVn.CLOSED));
			}
			if (l_Status == SocketVn.S_CONNECTING) {
				// Сокет находился в процессе соединения
				if (HostLoader != null) {
					HostLoader.removeEventListener(Event.COMPLETE, OnHostGetted);
					HostLoader.removeEventListener(IOErrorEvent.IO_ERROR, OnHostGettingErr)
					HostLoader._delete();
					HostLoader = null;
				}
				else {
					l_Sock.removeEventListener(Event.CONNECT, OnConnect);
					l_Sock.removeEventListener(IOErrorEvent.IO_ERROR,OnIOError);
					l_Sock.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, OnSecurityError);
					l_Sock.close();
				}
				l_Status = S_NOT_CONNECTED;
				dispatchEvent(new Event(SocketVn.NOT_CONNECTED));
			}
		}
//-----------------------------------------------------------------------------------------------------
		public function SendDataBlock(Data:String):void {
			// Отправка данных на сервер
			l_Sock.writeUTFBytes(Data);
			l_Sock.flush();
//			Vn.Vn.Cons.Add("SendData: "+Data);
		}
//-----------------------------------------------------------------------------------------------------
// Обработка событий
//-----------------------------------------------------------------------------------------------------
		private function OnHostGetted(e:Event):void {
			// Получение хоста
			l_Host = e.target.data;
			HostLoader.removeEventListener(Event.COMPLETE, OnHostGetted);
			HostLoader.removeEventListener(IOErrorEvent.IO_ERROR, OnHostGettingErr)
			HostLoader._delete();
			HostLoader = null;
			// Еще раз вызвать OpenConnection для подключения сокета к полученному хосту
			OpenConnection();
		}
//-----------------------------------------------------------------------------------------------------
		private function OnHostGettingErr(e:IOErrorEvent):void {
			// Ошибка получения хоста
			CloseConnection();
		}
//-----------------------------------------------------------------------------------------------------
		private function OnConnect(e:Event):void {
			// Успешное подсоединение сокета
//			Vn.Vn.Cons.Add("Connected");
			l_Sock.removeEventListener(Event.CONNECT, OnConnect);
			l_Sock.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, OnSecurityError);
			l_Sock.addEventListener(Event.CLOSE,OnClose);	// закрытие сокета со стороны сервера
			l_Sock.addEventListener(ProgressEvent.SOCKET_DATA,OnReadDataBlock);
			l_Status = SocketVn.S_CONNECTED;
			SendDataBlock("<001 id=\""+String(Vn.Interplanety.VnUser.Id)+"\">");	// Авторизация пользователя
			dispatchEvent(new Event(SocketVn.CONNECTED));
		}
//-----------------------------------------------------------------------------------------------------
		private function OnClose(e:Event):void {
			// Закрытие сокета со стороны сервера
//			Vn.Vn.Cons.Add("Closed on server side");
			// Закрыть соединение со своей стороны
			CloseConnection();
		}
//-----------------------------------------------------------------------------------------------------
		private function OnReadDataBlock(e:ProgressEvent):void {
			// Получен блок данных от сервера
			// Положить прочитанные данные в буфер
			var DataBlock:String = "";
			DataBlock = l_Sock.readUTFBytes(l_Sock.bytesAvailable);
//Vn.Vn.Cons.Add("Read: "+DataBlock);
			IBuff += DataBlock;
			dispatchEvent(new Event(SocketVn.READ_DATABLOCK));
		}
//-----------------------------------------------------------------------------------------------------
		private function OnIOError(e:IOErrorEvent):void {
			// Выпала ошибка IO
//			Vn.Vn.Cons.Add("IOErr ("+String(e.errorID)+")");
			if(l_Status != S_NOT_CONNECTED) CloseConnection();
		}
//-----------------------------------------------------------------------------------------------------
		private function OnSecurityError(e:SecurityErrorEvent):void {
			// Ошибка доступа к сокет-серверу
//			Vn.Vn.Cons.Add("SecurityErr");
			if(l_Status != S_NOT_CONNECTED) CloseConnection();
		}
//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------
		public function get Status():uint {
			// Статус соединения
			return l_Status;
		}
//-----------------------------------------------------------------------------------------------------
		public function get IBuff():String {
			// Полученные от сервера данные
			return l_IBuff;
		}
//-----------------------------------------------------------------------------------------------------
		public function set IBuff(Data:String):void {
			l_IBuff = Data;
		}
//-----------------------------------------------------------------------------------------------------
	}
}