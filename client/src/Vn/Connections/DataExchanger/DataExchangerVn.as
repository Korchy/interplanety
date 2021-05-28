package Vn.Connections.DataExchanger 
{
//-----------------------------------------------------------------------------------------------------
	// Класс обмена данными с сервером
//-----------------------------------------------------------------------------------------------------
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.EventDispatcher;
	import Vn.System.PHPLoader;
//-----------------------------------------------------------------------------------------------------
	public class DataExchangerVn extends EventDispatcher {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		protected var InfoLoader:PHPLoader;		// Загрузка/сохранение данных
		protected var Script:String;			// Скрипт для загрузки данных
		// Константы сообщений
		public static const LOADED:String = "EvDataExchangerLoaded";		// DataExchanger загружен
		public static const FAIL:String = "EvDataExchangerLoadedFail";		// DataExchanger НЕ загружена
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function DataExchangerVn() {
			// Конструктор предка
			super();
			// Конструктор
			Script = "getsocketdata.php";
			// Загрузчик
			InfoLoader = new PHPLoader();
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		public function _delete():void {
			// Деструктор
			if(InfoLoader!=null) {
				if(InfoLoader.hasEventListener(Event.COMPLETE)) InfoLoader.removeEventListener(Event.COMPLETE,OnDataComplete);
				if(InfoLoader.hasEventListener(IOErrorEvent.IO_ERROR)) InfoLoader.removeEventListener(IOErrorEvent.IO_ERROR,OnDataIoError);
				InfoLoader._delete();
				InfoLoader = null;
			}
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		public function AddScriptParam(Name:String,Value:String):void {
			// Добавление входного параметра для скрипта
			InfoLoader.AddVariable(Name,Value);
		}
//-----------------------------------------------------------------------------------------------------
		public function Load():void {
			// Загрузка данных
			if(Script!="") {
				InfoLoader.addEventListener(Event.COMPLETE,OnDataComplete);
				InfoLoader.addEventListener(IOErrorEvent.IO_ERROR,OnDataIoError);
				InfoLoader.Load(Script);
			}
		}
//-----------------------------------------------------------------------------------------------------
// Обработка событий
//-----------------------------------------------------------------------------------------------------
		private function OnDataComplete(e:Event):void {
			// Данные получены
			dispatchEvent(new Event(DataExchangerVn.LOADED));
			// Отсоединить слушатели
			InfoLoader.removeEventListener(Event.COMPLETE,OnDataComplete);
			InfoLoader.removeEventListener(IOErrorEvent.IO_ERROR,OnDataIoError);
		}
//-----------------------------------------------------------------------------------------------------
		private function OnDataIoError(e:Event):void {
			// Ошибка получения данных
			dispatchEvent(new Event(DataExchangerVn.FAIL));
			// Отсоединить слушатели
			InfoLoader.removeEventListener(Event.COMPLETE,OnDataComplete);
			InfoLoader.removeEventListener(IOErrorEvent.IO_ERROR,OnDataIoError);
		}
//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------
		public function get data():String {
			return InfoLoader.data;
		}
//-----------------------------------------------------------------------------------------------------
	}
}