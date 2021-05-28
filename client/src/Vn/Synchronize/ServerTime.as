package Vn.Synchronize {
	// Класс ServerTime - время сервера
	// Кодичество милисекунд с 01.01.1970:00:00:00 в формате UTC
	// Расширяем EventDispatcher чтобы генерировать события
//-----------------------------------------------------------------------------------------------------
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.EventDispatcher;
	import flash.utils.getTimer;
	import Vn.System.PHPLoader;
//-----------------------------------------------------------------------------------------------------
	public class ServerTime extends EventDispatcher {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		// Сервеное время
		protected static var CurrentServerTime:Number;	// Время, полученное с сервера
		protected static var RequestTime:Number;	// Момент начала запроса серверного времени (в мс. от запуска приложения)
		protected static var StartOwnTime:Number;	// Момент начала осчета собственного времени с момент получения серверного времени
		// Объект для обращения к скриктам PHP
		protected var TimeLoader:PHPLoader;
		// Константы событий
		public static const INFO_LOADED:String = "EvServerTimeLoaded";	// Идентификатор "время сервера получено"
		public static const INFO_FAIL:String = "EvServerTimeFail";		// Идентификатор "время сервера НЕ получено"
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function ServerTime() {
			super();
			CurrentServerTime = 0.0;
			RequestTime = 0.0;
			StartOwnTime = 0.0;
			TimeLoader = new PHPLoader();
			TimeLoader.Format = PHPLoader.TEXT;
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		public function _delete():void {
			if(TimeLoader!=null) {
				if(TimeLoader.hasEventListener(Event.COMPLETE)) TimeLoader.removeEventListener(Event.COMPLETE,OnComplete);
				if(TimeLoader.hasEventListener(IOErrorEvent.IO_ERROR)) TimeLoader.removeEventListener(IOErrorEvent.IO_ERROR,OnIoError);
				TimeLoader._delete();
				TimeLoader = null;
			}
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		public function RefreshServerTime():void {
			// Обновить данные о серверном времени
			TimeLoader.addEventListener(Event.COMPLETE,OnComplete);
			TimeLoader.addEventListener(IOErrorEvent.IO_ERROR,OnIoError);
			// Запомнить время начала запроса
			RequestTime = getTimer();
			// Обратиться к скрипту возвращающему данные о времени сервера
			TimeLoader.Load("getservertime.php");
		}
//-----------------------------------------------------------------------------------------------------
// Обработка событий
//-----------------------------------------------------------------------------------------------------
		protected function OnComplete(e:Event):void {
			// Получено серверное время
			// Начать отсчет своего времени
			StartOwnTime = getTimer();
			// Время на отправку-получение данных
			var LagTime:Number = StartOwnTime - RequestTime;
			// Время сервера = полученное время + время затраченное на получение
			CurrentServerTime = Number(e.target.data) + LagTime;
			// Серверное время получено
			TimeLoader.removeEventListener(Event.COMPLETE,OnComplete);
			TimeLoader.removeEventListener(IOErrorEvent.IO_ERROR,OnIoError);
			dispatchEvent(new Event(ServerTime.INFO_LOADED));
		}
//-----------------------------------------------------------------------------------------------------
		protected function OnIoError(e:IOErrorEvent):void {
			// Ошибка получения данных
			TimeLoader.removeEventListener(Event.COMPLETE,OnComplete);
			TimeLoader.removeEventListener(IOErrorEvent.IO_ERROR,OnIoError);
			dispatchEvent(new Event(ServerTime.INFO_FAIL));
		}
//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------
		public static function get Time():Number {
			// Текущее время скоординированное с сервером (Серверное время + время с момента его получения)
			return CurrentServerTime+(getTimer()-StartOwnTime);
		}
//-----------------------------------------------------------------------------------------------------
	}
}