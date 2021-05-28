package Vn.Text {
	// Класс
//-----------------------------------------------------------------------------------------------------
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.EventDispatcher;
	import Vn.System.PHPLoader;
//-----------------------------------------------------------------------------------------------------
	public class TextDictionary extends EventDispatcher {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		// Справочник
		protected static var TextList:Array;
		// Загрузчик
		protected var TextLoader:PHPLoader;
		// Константы событий
		public static const INFO_LOADED:String = "EvTextDictionaryLoaded";	// Идентификатор "справочник загружен"
		public static const INFO_FAIL:String = "EvTextDictionaryFail";		// Идентификатор "справочник НЕ загружен"
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function TextDictionary() {
			super();
			TextLoader = new PHPLoader();
			TextLoader.Format = PHPLoader.TEXT;
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		public function _delete():void {
			if(TextLoader.hasEventListener(Event.COMPLETE)) TextLoader.removeEventListener(Event.COMPLETE,OnComplete);
			if(TextLoader.hasEventListener(IOErrorEvent.IO_ERROR)) TextLoader.removeEventListener(IOErrorEvent.IO_ERROR,OnIoError);
			TextLoader._delete();
			TextLoader = null;
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		public function LoadText(Script:String):void {
			// Загрузка текста
			TextLoader.addEventListener(Event.COMPLETE,OnComplete);
			TextLoader.addEventListener(IOErrorEvent.IO_ERROR,OnIoError);
			TextLoader.Load(Script);
		}
//-----------------------------------------------------------------------------------------------------
		public static function Text(Id:uint):String {
			// Возвращает текст по id
			return TextList[Id-1];
		}
//-----------------------------------------------------------------------------------------------------
// Обработка событий
//-----------------------------------------------------------------------------------------------------
		protected function OnComplete(e:Event):void {
			TextList = String(e.target.data).split("#");
			// Данные в справочник загружены
			TextLoader.removeEventListener(Event.COMPLETE,OnComplete);
			TextLoader.removeEventListener(IOErrorEvent.IO_ERROR,OnIoError);
			dispatchEvent(new Event(TextDictionary.INFO_LOADED));
		}
//-----------------------------------------------------------------------------------------------------
		protected function OnIoError(e:Event):void {
			// Ошибка получения данных
			TextLoader.removeEventListener(Event.COMPLETE,OnComplete);
			TextLoader.removeEventListener(IOErrorEvent.IO_ERROR,OnIoError);
			dispatchEvent(new Event(TextDictionary.INFO_FAIL));
		}
//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------

//-----------------------------------------------------------------------------------------------------
	}
}