package Vn.Objects.Var {
//-----------------------------------------------------------------------------------------------------
// Объект с загрузчиком для получения данных от сервера
//-----------------------------------------------------------------------------------------------------
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.EventDispatcher;
	import Vn.Common.LoadStatusVn;
	import Vn.Events.EventVn;
	import Vn.System.PHPLoader;
	import Vn.Interplanety;
	import Vn.Text.TextDictionary;
//-----------------------------------------------------------------------------------------------------
	public class LoadedObject extends EventDispatcher {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		protected var InfoLoader:PHPLoader;		// Загрузка/сохранение данных
		private var lScript:String;				// Скрипт для загрузчика
		private var lId:uint;					// Id
		private var lStatus:uint;				// Статус загрузки
		// Константы сообщений
		public static const LOADED:String = "EvLoadedObjectLoaded";			// LoadedObject загружен
		public static const FAIL:String = "EvLoadedObjectLoadedFail";		// LoadedObject НЕ загружена
		public static const REFRESHED:String = "EvLoadedObjectRefreshed";	// LoadedObject обновлен
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function LoadedObject() {
			// Конструктор предка
			super();
			// Конструктор
			Id = 0;
			Script = "";
			lStatus = LoadStatusVn.NOT_LOADED;
			// Загрузчик
			InfoLoader = new PHPLoader();
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, Sавтоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		public function _delete():void {
			// Деструктор
			// Загрузчик
			if(InfoLoader!=null) {
				if(InfoLoader.hasEventListener(Event.COMPLETE)) {
					InfoLoader.removeEventListener(Event.COMPLETE, OnDataComplete);
					InfoLoader.removeEventListener(Event.COMPLETE, OnDataRefresh);
				}
				if(InfoLoader.hasEventListener(IOErrorEvent.IO_ERROR)) InfoLoader.removeEventListener(IOErrorEvent.IO_ERROR,OnDataIoError);
				InfoLoader._delete();
				InfoLoader = null;
			}
			// Деструктор предка
//			super._delete();
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		public function AddScriptParam(Name:String, Value:String):void {
			// Добавление входного параметра для скрипта
			InfoLoader.AddVariable(Name, Value);
		}
//-----------------------------------------------------------------------------------------------------
		protected function SetScriptParams():void {
			// Задать входные параметры для работы скрипта
			// Переопределяется в наследниках
		}
//-----------------------------------------------------------------------------------------------------
		public function Load():void {
			// Загрузка данных
			if(Script!="") {
				SetScriptParams();
				InfoLoader.addEventListener(Event.COMPLETE,OnDataComplete);
				InfoLoader.addEventListener(IOErrorEvent.IO_ERROR,OnDataIoError);
				lStatus = LoadStatusVn.IN_PROGRESS;
				InfoLoader.Load(Script);
			}
			else dispatchEvent(new EventVn(LoadedObject.FAIL));
		}
//-----------------------------------------------------------------------------------------------------
		public function Refresh():void {
			// Обновление данных
			if(Script!="") {
				SetScriptParams();	// Нужно убрать, но в UserAttribute деньги/опыт/кристаллы завязаны на один скрипт - сначала исправить
				InfoLoader.addEventListener(Event.COMPLETE, OnDataRefresh);
				InfoLoader.addEventListener(IOErrorEvent.IO_ERROR, OnDataIoError);
				lStatus = LoadStatusVn.IN_PROGRESS;
				InfoLoader.Load(Script);
			}
		}
//-----------------------------------------------------------------------------------------------------
		protected function OnComplete(e:Event):void {
			// Действия с полученными данными для загрузки
			// Переопределяется в наследниках
		}
//-----------------------------------------------------------------------------------------------------
		protected function OnRefresh(e:Event):void {
			// Действия с полученными данными для обновления
			// Переопределяется в наследниках
		}
//-----------------------------------------------------------------------------------------------------
		protected function OnIoError(e:IOErrorEvent):void {
			// Действия при ошибке получения данных
			// Переопределяется в наследниках
			Vn.Interplanety.Cons.Add(TextDictionary.Text(94));	// Обшика обращения к серверу
		}
//-----------------------------------------------------------------------------------------------------
// Обработка событий
//-----------------------------------------------------------------------------------------------------
		private function OnDataComplete(e:Event):void {
			// Данные получены
			// Отсоединить слушатели
			InfoLoader.removeEventListener(Event.COMPLETE,OnDataComplete);
			InfoLoader.removeEventListener(IOErrorEvent.IO_ERROR, OnDataIoError);
			// Отработать полученные данные
			OnComplete(e);
			lStatus = LoadStatusVn.LOADED;
			dispatchEvent(new EventVn(LoadedObject.LOADED, e.target.data));
		}
//-----------------------------------------------------------------------------------------------------
		private function OnDataRefresh(e:Event):void {
			// Данные получены
			// Отсоединить слушатели
			InfoLoader.removeEventListener(Event.COMPLETE,OnDataRefresh);
			InfoLoader.removeEventListener(IOErrorEvent.IO_ERROR, OnDataIoError);
			// Отработать полученные данные
			OnRefresh(e);
			lStatus = LoadStatusVn.LOADED;
			dispatchEvent(new EventVn(LoadedObject.REFRESHED, e.target.data));
		}
//-----------------------------------------------------------------------------------------------------
		private function OnDataIoError(e:IOErrorEvent):void {
			// Ошибка получения данных
			// Отсоединить слушатели
			InfoLoader.removeEventListener(Event.COMPLETE,OnDataComplete);
			InfoLoader.removeEventListener(Event.COMPLETE,OnDataRefresh);
			InfoLoader.removeEventListener(IOErrorEvent.IO_ERROR, OnDataIoError);
			// Отработать полученные данные
			OnIoError(e);
			lStatus = LoadStatusVn.NOT_LOADED;
			dispatchEvent(new EventVn(LoadedObject.FAIL, e.target.data));
		}
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
		public function get Status():uint {
			return lStatus;		// Загружен/не загружен/в процессе
		}
//-----------------------------------------------------------------------------------------------------
		public function get Script():String {
			return lScript;
		}
//-----------------------------------------------------------------------------------------------------
		public function set Script(vValue:String):void {
			lScript = vValue;
		}
//-----------------------------------------------------------------------------------------------------
	}
}