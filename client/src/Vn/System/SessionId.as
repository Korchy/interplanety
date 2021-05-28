package Vn.System {
	// Класс
//-----------------------------------------------------------------------------------------------------
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.EventDispatcher;
	import flash.display.Stage;
	import Vn.System.PHPLoader;
//-----------------------------------------------------------------------------------------------------
	public class SessionId extends EventDispatcher {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		private var InfoLoader:PHPLoader;
		public var VnSessionId:String;
		// Константы событий
		public static const INFO_LOADED:String = "EvSessionIdLoaded";	// Идентификатор "данные о сессии загружены"
		public static const INFO_FAIL:String = "EvSessionIdFail";		// Идентификатор "данные о сессии НЕ загружены"
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function SessionId() {
			// Конструктор предка
			super();
			// Конструктор
			VnSessionId = "0";
			InfoLoader = new PHPLoader();
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		public function _delete():void {
			// Деструктор
			InfoLoader._delete();
			InfoLoader = null;
			// Деструктор предка
//			super._delete();
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		public function GetSessionId(Instance:Stage):void {
			// Получить Id запущенной в браузере сессии
			if(Instance.loaderInfo.parameters["session_id"]) {
				VnSessionId = Instance.loaderInfo.parameters['session_id'];
				dispatchEvent(new Event(SessionId.INFO_LOADED));
			}
			else dispatchEvent(new Event(SessionId.INFO_FAIL));
		}
//-----------------------------------------------------------------------------------------------------
		public function GetDebugSessionId(Script:String):void {
			// Получить Id запущенной в браузере сессии
			InfoLoader.addEventListener(Event.COMPLETE,OnCompleteSessionId);
			InfoLoader.addEventListener(IOErrorEvent.IO_ERROR, OnIoErrorSessionId);
			InfoLoader.Load(Script);
		}
//-----------------------------------------------------------------------------------------------------
// Обработка событий
//-----------------------------------------------------------------------------------------------------
		protected function OnCompleteSessionId(e:Event):void {
			// Данные о сесси получены
			// Отсоединить слушатели и отправить событие загрузки данных пользователя
			InfoLoader.removeEventListener(Event.COMPLETE,OnCompleteSessionId);
			InfoLoader.removeEventListener(IOErrorEvent.IO_ERROR,OnIoErrorSessionId);
			VnSessionId = e.target.data;
			dispatchEvent(new Event(SessionId.INFO_LOADED));
		}
//-----------------------------------------------------------------------------------------------------
		protected function OnIoErrorSessionId(e:Event):void {
			// Данные о сесси не получены
			trace("SessionId Io Err");
			// Отсоединить слушатели и отправить событие загрузки данных пользователя
			InfoLoader.removeEventListener(Event.COMPLETE,OnCompleteSessionId);
			InfoLoader.removeEventListener(IOErrorEvent.IO_ERROR,OnIoErrorSessionId);
			dispatchEvent(new Event(SessionId.INFO_FAIL));
		}
//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------

//-----------------------------------------------------------------------------------------------------
	}
}