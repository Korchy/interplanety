package Vn.System 
{
//-----------------------------------------------------------------------------------------------------
// Класс отвечает за выгрузку ByteArray на сервер
//-----------------------------------------------------------------------------------------------------
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.utils.ByteArray;
	import Vn.Interplanety;
	import Vn.Common.SC;
//-----------------------------------------------------------------------------------------------------
	public class ByteArrayUploader extends EventDispatcher {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		private var lData:ByteArray;		// Данные по скриншоту
		private var lDelimiter:String;		// Разделитель между данными (какая-либо уникальная комбинация символов, чтобы разделять данные в общем потоке)
		private var lScript:String;			// Php скрипт для выгрузки
		private var lRequest:URLRequest;	// Request
		private var lLoader:URLLoader;		// Loader
		// Константы событий
		public static const BYTEARRAY_UPLOADED:String = "EvByteArrayUploaded";				// Идентификатор "ByteArray загружен"
		public static const BYTEARRAY_IO_ERROR:String = "EvByteArrayIoError";				// Идентификатор "IO Error"
		public static const BYTEARRAY_SECURITY_ERROR:String = "EvByteArraySecurityError";	// Идентификатор "Security Error"
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function ByteArrayUploader() {
			// Конструктор родителя
			super();
			// Конструктор
			lData = null;
			lDelimiter = "_0vn0_";
			lScript = "uploadbytearray.php";
			lRequest = new URLRequest();
			lRequest.url = Vn.Interplanety.HomeDir + lScript;
			lRequest.method = URLRequestMethod.POST;
			lRequest.requestHeaders.push(new URLRequestHeader("Content-type", "application/octet-stream"));
			lRequest.requestHeaders.push(new URLRequestHeader("Cache-Control", "no-cache"));
			lLoader = new URLLoader();
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		public function _delete():void {
			// Деструктор
			lData = null;
			if (lLoader.hasEventListener(Event.COMPLETE)) lLoader.removeEventListener(Event.COMPLETE, OnComplete);
			if (lLoader.hasEventListener(IOErrorEvent.IO_ERROR)) lLoader.removeEventListener(IOErrorEvent.IO_ERROR, OnIOError);
			if (lLoader.hasEventListener(SecurityErrorEvent.SECURITY_ERROR)) lLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, OnSecurityError);
			lLoader = null;
			lRequest = null;
			// Деструктор родителя
//			super._delete();
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		public function Upload():Boolean {
			// Выгрузка ByteArray на сервер
			if (lData == null) return false;
			if (Interplanety.SId == null || Interplanety.SId.VnSessionId == "0") return false;
			// Добавить идентификатор сессии SId
			lData.writeMultiByte(lDelimiter + Interplanety.SId.VnSessionId, "us-ascii");
			// Добавить идентификатор, что вызов идет из программы
			lData.writeMultiByte(lDelimiter + SC.PROGRAM_IDENTIFICATOR, "us-ascii");
			// Отправить на сервер
			lLoader.addEventListener(Event.COMPLETE, OnComplete);
			lLoader.addEventListener(IOErrorEvent.IO_ERROR, OnIOError);
			lLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, OnSecurityError);
			lRequest.data = lData;
			lLoader.load(lRequest);
			return true;
		}
//-----------------------------------------------------------------------------------------------------
// Обработка событий
//-----------------------------------------------------------------------------------------------------
		private function OnComplete(e:Event):void {
			// Успешное завершение
			dispatchEvent(new Event(BYTEARRAY_UPLOADED));
			lLoader.removeEventListener(Event.COMPLETE, OnComplete);
			lLoader.removeEventListener(IOErrorEvent.IO_ERROR, OnIOError);
			lLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, OnSecurityError);
		}
//-----------------------------------------------------------------------------------------------------
		private function OnIOError(e:IOErrorEvent):void {
			// IO Error
			dispatchEvent(new Event(BYTEARRAY_IO_ERROR));
			lLoader.removeEventListener(Event.COMPLETE, OnComplete);
			lLoader.removeEventListener(IOErrorEvent.IO_ERROR, OnIOError);
			lLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, OnSecurityError);
		}
//-----------------------------------------------------------------------------------------------------
		private function OnSecurityError(e:SecurityErrorEvent):void {
			// Security Error
			dispatchEvent(new Event(BYTEARRAY_SECURITY_ERROR));
			lLoader.removeEventListener(Event.COMPLETE, OnComplete);
			lLoader.removeEventListener(IOErrorEvent.IO_ERROR, OnIOError);
			lLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, OnSecurityError);
		}
//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------
		public function set Data(Value:ByteArray):void {
			// Данные ByteArray
			lData = Value;
		}
//-----------------------------------------------------------------------------------------------------
	}
}