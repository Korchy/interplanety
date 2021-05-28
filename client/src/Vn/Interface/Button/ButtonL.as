package Vn.Interface.Button {
//-----------------------------------------------------------------------------------------------------
// Кнопка с отработкой скрипта по клику
//-----------------------------------------------------------------------------------------------------
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.IOErrorEvent;
	import flash.system.System;
	import Vn.Events.EventVn;
	import Vn.Objects.Var.LoadedObject;
	import Vn.System.PHPLoader;
//-----------------------------------------------------------------------------------------------------
	public class ButtonL extends Button {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		private var lLoadedObject:LoadedObject;	// Объект для работы с загрузками
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function ButtonL() {
			// Конструктор предка
			super();
			// Конструктор
			lLoadedObject = new LoadedObject();
			lLoadedObject.Script = "";
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		override public function _delete():void {
			// Деструктор
			if(lLoadedObject.hasEventListener(LoadedObject.LOADED)) lLoadedObject.removeEventListener(LoadedObject.LOADED, onLoaderObjectLoad);
			if(lLoadedObject.hasEventListener(LoadedObject.FAIL)) lLoadedObject.removeEventListener(LoadedObject.FAIL, onLoaderObjectFail);
			lLoadedObject._delete();
			lLoadedObject = null;
			// Деструктор предка
			super._delete();
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		protected function setScriptParams():void {
			// Задание входных параметров скрипта
			// Переопределяется в наследниках
		}
//-----------------------------------------------------------------------------------------------------
		protected function addScriptParam(vName:String, vValue:String):void {
			// Добавление входного параметра для скрипта
			lLoadedObject.AddScriptParam(vName, vValue);
		}
//-----------------------------------------------------------------------------------------------------
// Обработка событий
//-----------------------------------------------------------------------------------------------------
		override protected function OnClick(e:MouseEvent):void {
			// При нажатии - выполнить скрипт
			setScriptParams();
			lLoadedObject.addEventListener(LoadedObject.LOADED, onLoaderObjectLoad);
			lLoadedObject.addEventListener(LoadedObject.FAIL, onLoaderObjectFail);
			lLoadedObject.Load();
		}
//-----------------------------------------------------------------------------------------------------
		protected function onLoad(vData:XML):void {
			// Переопределение в наследниках
			
		}
//-----------------------------------------------------------------------------------------------------
		protected function onFail(vData:XML):void {
			// Переопределение в наследниках
			
		}
//-----------------------------------------------------------------------------------------------------
		private function onLoaderObjectLoad(e:EventVn):void {
			// Данные загружены
			lLoadedObject.removeEventListener(LoadedObject.LOADED, onLoaderObjectLoad);
			lLoadedObject.removeEventListener(LoadedObject.FAIL, onLoaderObjectFail);
			// Данные получаем в XML формате
			try {
				var Data:XML = new XML(e.Data);
			}
			catch (e1:Error) {
				trace(e.Data);
			}
			// Обработать полученные данные
			if (Data.name() == "ERR" && uint(Data) != 0) {
				// Если корневой узел = ERR и значение != 0 - возвращена ошибка
				dispatchEvent(new EventVn(LoadedObject.FAIL, Data));
				onFail(Data);
			}
			else {
				// Возвращены данные
				dispatchEvent(new EventVn(LoadedObject.LOADED, Data));
				onLoad(Data);
			}
		}
//-----------------------------------------------------------------------------------------------------
		private function onLoaderObjectFail(e:EventVn):void {
			// Данные НЕ загружены
			lLoadedObject.removeEventListener(LoadedObject.LOADED, onLoaderObjectLoad);
			lLoadedObject.removeEventListener(LoadedObject.FAIL, onLoaderObjectFail);
			var errData:XML = <ERR>117</ERR>;	// "Системная ошибка"
			dispatchEvent(new EventVn(LoadedObject.FAIL, errData));
			onFail(errData);
		}
//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------
		public function get Script():String {
			return lLoadedObject.Script;
		}
//-----------------------------------------------------------------------------------------------------
		public function set Script(vValue:String):void {
			lLoadedObject.Script = vValue;
		}
//-----------------------------------------------------------------------------------------------------
	}
}