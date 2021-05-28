package Vn.Connections 
{
//-----------------------------------------------------------------------------------------------------
	// Менеджер управления соединениями с сервером
	// Сначала установить соединение через синхронизатор, в процессе пробовать переподключаться через сокет
	// Если сокет-соединение разорвалось - восстановить соединение через синхронизатор и опять пробовать переподключать через сокет
//-----------------------------------------------------------------------------------------------------
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import Vn.Connections.DataExchanger.DataExchangerVn;
	import Vn.Connections.Socket.SocketVn;
	import Vn.Synchronize.ServerSynchronizer;
	import Vn.Text.TextDictionary;
	import Vn.Connections.Events.EvReceivedServerData;
	import Vn.Interplanety;
//-----------------------------------------------------------------------------------------------------
	public class ConnectionsManagerVn extends EventDispatcher {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		private var l_Synchronizer:ServerSynchronizer;	// Синхронизатор
		private var l_Socket:SocketVn;					// Сокет
		private var l_DataExchanger:DataExchangerVn;	// Обменик данными через синхронизацию
		private var l_IBuff:String;	// Буфер полученных от сервера данных (накапливаем данные до получения ">")
		private var l_OBuff:String;	// Буфер отправляемых на сервер данных
		private var l_Type:uint;	// Тип текущего соединения с сервером
		public static const SYNC_NONE:uint = 0;		// Синхронизация отсутствует
		public static const SYNC_S10:uint = 1;		// Через синхронизатор раз в 10 секунд
		public static const SYNC_SOCKET:uint = 2;	// Через сокет
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function ConnectionsManagerVn() {
			// Конструктор предка
			super();
			// Конструктор
			l_Synchronizer = new ServerSynchronizer();
			l_Socket = new SocketVn();
			l_DataExchanger = new DataExchangerVn();
			l_OBuff = "";
			l_IBuff = "";
			// По умолчанию - обмен данными через синхронизатор
			l_Type = ConnectionsManagerVn.SYNC_NONE;
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		public function _delete():void {
			// Деструктор
			// Удалить синхронизатор
			if (l_Synchronizer != null) {
				l_Synchronizer._delete();
				l_Synchronizer = null;
			}
			// Удалить сокет
			if (l_Socket != null) {
				if(l_Socket.hasEventListener(SocketVn.CONNECTED)) l_Socket.removeEventListener(SocketVn.CONNECTED, OnSocketConnected);
				if(l_Socket.hasEventListener(SocketVn.CLOSED)) l_Socket.removeEventListener(SocketVn.CLOSED, OnSocketClosed);
				if(l_Socket.hasEventListener(SocketVn.READ_DATABLOCK)) l_Socket.removeEventListener(SocketVn.READ_DATABLOCK, OnSocketReadDatablock);
				if(l_Socket.hasEventListener(SocketVn.NOT_CONNECTED)) l_Socket.removeEventListener(SocketVn.NOT_CONNECTED, OnSocketNotConnected);
				l_Socket._delete();
				l_Socket = null;
			}
			// Удалить обменник данными
			if (l_DataExchanger != null) {
				if(l_DataExchanger.hasEventListener(DataExchangerVn.LOADED)) l_DataExchanger.removeEventListener(DataExchangerVn.LOADED, OnSyncS10ReadDatablock);
				l_DataExchanger._delete();
				l_DataExchanger = null;
			}
			l_Type = ConnectionsManagerVn.SYNC_NONE;
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		public function Synchronize():void {
			// Синхронизация - вызывается в каждой итерации игрового цикла
			l_Synchronizer.Synchronize();	// Работа синхронизатора
		}
//-----------------------------------------------------------------------------------------------------
		public function SetSync():void {
			// Установка синхронизации с сервером
			// Пробуем установить через сокет, если не получится, автоматом установится через синхронизатор
			SetSyncSocket()
		}
//-----------------------------------------------------------------------------------------------------
		private function SetSyncSocket():void {
			// Установить обмен данными через сокет
			if (l_Type != ConnectionsManagerVn.SYNC_SOCKET) {
				l_Socket.addEventListener(SocketVn.CONNECTED, OnSocketConnected);
				l_Socket.addEventListener(SocketVn.NOT_CONNECTED, OnSocketNotConnected);
				l_Socket.OpenConnection();
			}
		}
//-----------------------------------------------------------------------------------------------------
		private function SetSyncS10():void {
			// Установить обмен данными через синхронизатор
			if (l_Type == ConnectionsManagerVn.SYNC_SOCKET) {
				// Если было соединение через сокет - закрыть. После закрытия будет еще один вызов SetSyncS10
				l_Socket.CloseConnection();
			}
			else {
				// Установить обмен данными через синхронизатор
				l_Synchronizer.Add(10000,SyncS10);			// Раз в 10 секунд - получать/отправлять данные
				l_Synchronizer.Add(60000, SetSyncSocket);	// Раз в минуту пытаться установить соединение через сокет
				l_Type = SYNC_S10;
				Vn.Interplanety.Cons.Add(TextDictionary.Text(180));	// "Задействован импульсный передатчик"
			}
		}
//-----------------------------------------------------------------------------------------------------
		private function SyncS10():void {
			// Обмен данными через синхронизатор
			ProceedSendingData();
		}
//-----------------------------------------------------------------------------------------------------
		private function ProceedSendingData():void {
			// Отправить данные серверу
			if (Type == ConnectionsManagerVn.SYNC_SOCKET) {
				if (OBuff != "") {
					// Соединение через сокет - отправить данные через сокет
					l_Socket.SendDataBlock(OBuff);
					l_OBuff = "";
				}
			}
			if (Type == ConnectionsManagerVn.SYNC_S10) {
				// Соединение через синхронизатор - отдать данные через DataExchanger
				l_DataExchanger.AddScriptParam("Data", OBuff);
				l_DataExchanger.addEventListener(DataExchangerVn.LOADED, OnSyncS10ReadDatablock);
				l_DataExchanger.addEventListener(DataExchangerVn.FAIL, OnSyncS10ReadDatablock);
				l_DataExchanger.Load();
				l_OBuff = "";
			}
		}
//-----------------------------------------------------------------------------------------------------
		private function ProceedGettedData():void {
			// Обработка полученных от сервера данных
			// Буфер полученных данных
			if (IBuff!="") {
				// Выделить блок до последней закрывающей ">" и оповестить всех о полученных данных
				var LastCloser:int = IBuff.lastIndexOf(">");
				if(LastCloser!=-1) {
					var ClosedBlock:String = IBuff.substr(0, LastCloser + 1);
//Vn.Vn.Cons.Add(ClosedBlock);
					IBuff = IBuff.substr(LastCloser+1);
					// Отправить событие о получении полного блока данных
					dispatchEvent(new EvReceivedServerData(EvReceivedServerData.RECEIVED_SERVER_DATA, ClosedBlock));
				}
			}
		}
//-----------------------------------------------------------------------------------------------------
// Обработка событий
//-----------------------------------------------------------------------------------------------------
		private function OnSocketConnected(e:Event):void {
			// Соединение через сокет установленно
			l_Socket.removeEventListener(SocketVn.CONNECTED, OnSocketConnected);
			l_Socket.removeEventListener(SocketVn.NOT_CONNECTED, OnSocketNotConnected);
			l_Socket.addEventListener(SocketVn.CLOSED, OnSocketClosed);	// закрытие сокета со стороны сервера
			l_Socket.addEventListener(SocketVn.READ_DATABLOCK, OnSocketReadDatablock);
			// Если было соединение через синхронизатор - отключить
			if(l_Type==ConnectionsManagerVn.SYNC_S10) {
				l_Synchronizer.Remove(SyncS10);			// Убрать обмен данными через синхронизатор
				l_Synchronizer.Remove(SetSyncSocket);	// Убрать реконнект сокета
			}
			// Соединение чере сокет установлено
			l_Type = SYNC_SOCKET;
			Vn.Interplanety.Cons.Add(TextDictionary.Text(181));	// "Задействован линейный передатчик"
		}
//-----------------------------------------------------------------------------------------------------
		private function OnSocketNotConnected(e:Event):void {
			// Не удалось установить соединение через сокет
			l_Socket.removeEventListener(SocketVn.CONNECTED, OnSocketConnected);
			l_Socket.removeEventListener(SocketVn.NOT_CONNECTED, OnSocketNotConnected);
			// Если соединения не было - попытаться установить через синхронизатор
			if (l_Type==ConnectionsManagerVn.SYNC_NONE) SetSyncS10();
		}
//-----------------------------------------------------------------------------------------------------
		private function OnSocketClosed(e:Event):void {
			// Сокет закрылся
			l_Socket.removeEventListener(SocketVn.CLOSED, OnSocketClosed);
			l_Socket.removeEventListener(SocketVn.READ_DATABLOCK, OnSocketReadDatablock);
			l_Type = ConnectionsManagerVn.SYNC_NONE;
			// Установить обмен данными через синхронизатор
			SetSyncS10();
		}
//-----------------------------------------------------------------------------------------------------
		private function OnSocketReadDatablock(e:Event):void {
			// Получены данные от сервера (через сокет)
			// Скинуть в буфер
			IBuff += l_Socket.IBuff;
			l_Socket.IBuff = "";
			// Обработать
			ProceedGettedData();
		}
//-----------------------------------------------------------------------------------------------------
		private function OnSyncS10ReadDatablock(e:Event):void {
			// Получены данные от сервера (через синхронизатор)
			l_DataExchanger.removeEventListener(DataExchangerVn.LOADED, OnSyncS10ReadDatablock);
			l_DataExchanger.removeEventListener(DataExchangerVn.FAIL, OnSyncS10ReadDatablock);
			// Скинуть в буфер
			IBuff += e.target.data;
			// Обработать
			ProceedGettedData();
		}
//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------
		public function get Type():uint {
			// Тип текущего соединения с сервером
			return l_Type;
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
		public function get OBuff():String {
			// Отдаваемые на сервер данные
			return l_OBuff;
		}
//-----------------------------------------------------------------------------------------------------
		public function set OBuff(Data:String):void {
			l_OBuff = Data;
			if (Type == ConnectionsManagerVn.SYNC_SOCKET) {
				// Если соединение через сокет - после записи в буфер сразу пытаемся отправить
				ProceedSendingData();
			}
		}
//-----------------------------------------------------------------------------------------------------
	}
}