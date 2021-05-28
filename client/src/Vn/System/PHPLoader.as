package Vn.System {
	// Класс
//-----------------------------------------------------------------------------------------------------
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequestMethod;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import Vn.Interplanety;
//-----------------------------------------------------------------------------------------------------
	public class PHPLoader extends URLLoader {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		// Объекты для обращения к скриктам PHP
		private var lId:uint;					// Id
		protected var Variables:URLVariables;	// Массив переменных
		protected var Request:URLRequest;		// Описание скрипта
		private var RequestSended:Boolean;		// true - метка о том, что запрос отправлен на сервер, но ответ еще не получен (т.к. можно при плохой связи успеть отправить второй раз не получив ответа от первой отправки)
		// Переопределить константы для удобства обращения
		public static const VARIABLES:String = URLLoaderDataFormat.VARIABLES;
		public static const BINARY:String = URLLoaderDataFormat.BINARY;
		public static const TEXT:String = URLLoaderDataFormat.TEXT;
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function PHPLoader() {
			super();
			Id = 0;
			Variables = new URLVariables();
			Request = new URLRequest();
			Request.method = URLRequestMethod.POST;			// По умолчанию - POST
			Request.data = Variables;
			dataFormat = TEXT;								// По умолчанию - текст
			RequestSended = false;
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		public function _delete():void {
			if(bytesLoaded!=bytesTotal) close();	// Оборвать загрузку
			Variables = null;
			Request = null;
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		public function AddVariable(Name:String,Value:String):void {
			// Добавить переменную в Request.data
			Variables[Name] = Value;
		}
//-----------------------------------------------------------------------------------------------------
		public function GetVariable(Name:String):String {
			// Получить переменную из Request.data
			return Variables[Name];
		}
//-----------------------------------------------------------------------------------------------------
		public function Load(Script:String):void {
			// Начать загрузку данных через PHP-скрипт Script
// Пока закомментировал т.к. получается ситуация, когда запрос уходит, потом уходит воторй закпро, возвращается результат 2, а первый еще не вернулся.
//			if(RequestSended!=true) {
				Request.url = Vn.Interplanety.HomeDir + Script;
				if(Vn.Interplanety.SId!=null&&Vn.Interplanety.SId.VnSessionId!="0") AddVariable("session_id", Vn.Interplanety.SId.VnSessionId);	// Если сессия начата - все запросы идут с указанием сессии
				load(Request);
				RequestSended = true;
//				addEventListener(Event.COMPLETE,OnComplete);
//				addEventListener(IOErrorEvent.IO_ERROR,OnIoError);
//			}
		}
//-----------------------------------------------------------------------------------------------------
// Обработка событий
//-----------------------------------------------------------------------------------------------------
/*		protected function OnComplete(e:Event):void {
			// Запрос выполнен
			removeEventListener(Event.COMPLETE,OnComplete);
			removeEventListener(IOErrorEvent.IO_ERROR,OnIoError);
			RequestSended = false;
		}
//-----------------------------------------------------------------------------------------------------
		protected function OnIoError(e:Event):void {
			// Запрос выполнен с ошибкой
			removeEventListener(Event.COMPLETE,OnComplete);
			removeEventListener(IOErrorEvent.IO_ERROR,OnIoError);
			RequestSended = false;
		}*/
//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------
		public function get Id():uint {
			return lId;
		}
//-----------------------------------------------------------------------------------------------------
		public function set Id(Value:uint):void {
			lId = Value;
		}
//-----------------------------------------------------------------------------------------------------
//	Метод запроса	
//-----------------------------------------------------------------------------------------------------
		public function get RequestMetod():String {
			return Request.method;
		}
//-----------------------------------------------------------------------------------------------------
		public function set RequestMetod(Value:String):void {
			Request.method = Value;
		}
//-----------------------------------------------------------------------------------------------------
//	Формат запроса
//-----------------------------------------------------------------------------------------------------
		public function get Format():String {
			return dataFormat;
		}
//-----------------------------------------------------------------------------------------------------
		public function set Format(Value:String):void {
			dataFormat = Value;
		}
//-----------------------------------------------------------------------------------------------------
	}
}