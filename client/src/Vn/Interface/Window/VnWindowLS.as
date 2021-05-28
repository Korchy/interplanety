package Vn.Interface.Window {
//-----------------------------------------------------------------------------------------------------
// Окно с загрузкой содержимого с сервера и с закрытием через обращение к серверу
//-----------------------------------------------------------------------------------------------------
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import Vn.Interface.Window.VnWindowB;
	import Vn.Interplanety;
	import Vn.System.PHPLoader;
	import Vn.Text.TextDictionary;
//-----------------------------------------------------------------------------------------------------
	public class VnWindowLS extends VnWindowB {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		private var lInfoLoader:PHPLoader;	// Загрузчик данных
		private var lInfoSaver:PHPLoader;	// Сохранение данных на сервере
		private var lSaverScript:String;	// Скрипт для сохранения
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function VnWindowLS(vLoadScript:String="") {
			// Конструктор предка
			super();
			// Конструктор
			lInfoLoader = null;
			lInfoSaver = null;
			lSaverScript = "";
			if(vLoadScript!="") Load(vLoadScript);	// Получить данные с сервера
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		override public function _delete():void {
			// Деструктор
			if(lInfoLoader!=null) {
				lInfoLoader.removeEventListener(Event.COMPLETE,OnInfoLoaded);
				lInfoLoader.removeEventListener(IOErrorEvent.IO_ERROR,OnIoErrorInfoLoaded);
				lInfoLoader._delete();
				lInfoLoader = null;
			}
			if(lInfoSaver!=null) {
				lInfoSaver.removeEventListener(Event.COMPLETE,OnInfoSaved);
				lInfoSaver.removeEventListener(IOErrorEvent.IO_ERROR,OnIoErrorInfoSaved);
				lInfoSaver._delete();
				lInfoSaver = null;
			}
			// Деструктор предка
			super._delete();
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		private function Load(vLoadScript:String):void {
			// Загрузка содержимого
			lInfoLoader = new PHPLoader();
			lInfoLoader.addEventListener(Event.COMPLETE,OnInfoLoaded);
			lInfoLoader.addEventListener(IOErrorEvent.IO_ERROR,OnIoErrorInfoLoaded);
			SetLoaderScriptParams();
			lInfoLoader.Load(vLoadScript);
		}
//-----------------------------------------------------------------------------------------------------
		protected function SetLoaderScriptParams():void {
			// Задание входных параметров для скрипта загрузки данных
			// Переопределяется в наследниках
		}
//-----------------------------------------------------------------------------------------------------
		protected function AddLoaderScriptParam(Name:String,Value:String):void {
			// Добавление входного параметра для скрипта загрузки данных
			lInfoLoader.AddVariable(Name,Value);
		}
//-----------------------------------------------------------------------------------------------------
		protected function OnLoad(Data:*):void {
			// Отработка загруженных данных
			// Переопределяется в наследниках
		}
//-----------------------------------------------------------------------------------------------------
		protected function Save():void {
			// Сохранение на сервере
			lInfoSaver = new PHPLoader();
			lInfoSaver.addEventListener(Event.COMPLETE,OnInfoSaved);
			lInfoSaver.addEventListener(IOErrorEvent.IO_ERROR,OnIoErrorInfoSaved);
			SetSaverScriptParams();
			lInfoSaver.Load(lSaverScript);
		}
//-----------------------------------------------------------------------------------------------------
		protected function SetSaverScriptParams():void {
			// Задание входных параметров для скрипта сохранения данных
			// Переопределяется в наследниках
		}
//-----------------------------------------------------------------------------------------------------
		protected function AddSaverScriptParam(Name:String,Value:String):void {
			// Добавление входного параметра для скрипта сохранения данных
			lInfoSaver.AddVariable(Name,Value);
		}
//-----------------------------------------------------------------------------------------------------
		protected function OnSaved(Data:*):void {
			// Отработка после сохранения данных
			// Переопределяется в наследниках
		}
//-----------------------------------------------------------------------------------------------------
// Обработка событий
//-----------------------------------------------------------------------------------------------------
		private function OnInfoLoaded(e:Event):void {
			// Получены данные от скрипта загрузки
			OnLoad(e.target.data);
			// Удалить загрузчик
			lInfoLoader.removeEventListener(Event.COMPLETE, OnInfoLoaded);
			lInfoLoader.removeEventListener(IOErrorEvent.IO_ERROR, OnIoErrorInfoLoaded);
			lInfoLoader._delete();
			lInfoLoader = null;
		}
//-----------------------------------------------------------------------------------------------------
		private function OnIoErrorInfoLoaded(e:IOErrorEvent):void {
			// Ошибка получения данных от скрипта загрузки
			Interplanety.Cons.Add(TextDictionary.Text(117));	// Системная ошибка
			// Удалить загрузчик
			lInfoLoader.removeEventListener(Event.COMPLETE,OnInfoLoaded);
			lInfoLoader.removeEventListener(IOErrorEvent.IO_ERROR,OnIoErrorInfoLoaded);
			lInfoLoader._delete();
			lInfoLoader = null;
		}
//-----------------------------------------------------------------------------------------------------
		private function OnInfoSaved(e:Event):void {
			// Получены данные от скрипта сохранения
			OnSaved(e.target.data);
			// Удалить загрузчик
			lInfoSaver.removeEventListener(Event.COMPLETE, OnInfoSaved);
			lInfoSaver.removeEventListener(IOErrorEvent.IO_ERROR, OnIoErrorInfoSaved);
			lInfoSaver._delete();
			lInfoSaver = null;
			// Закрыть окно
			Close();
		}
//-----------------------------------------------------------------------------------------------------
		private function OnIoErrorInfoSaved(e:IOErrorEvent):void {
			// Ошибка получения данных от скрипта сохранения
			Interplanety.Cons.Add(TextDictionary.Text(117));	// Системная ошибка
			// Удалить загрузчик
			lInfoSaver.removeEventListener(Event.COMPLETE,OnInfoSaved);
			lInfoSaver.removeEventListener(IOErrorEvent.IO_ERROR,OnIoErrorInfoSaved);
			lInfoSaver._delete();
			lInfoSaver = null;
		}
//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------
		public function set SaverScript(vValue:String):void {
			// Скрипт сохранения данных на сервере
			lSaverScript = vValue;
		}
//-----------------------------------------------------------------------------------------------------
	}
}