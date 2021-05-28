package Vn.Interface.Button {
//-----------------------------------------------------------------------------------------------------
// Отдельная часть функционала кнопки, по нажатию на которую создается и удаляется окно
// Окно создается после получения данных от сервера
//-----------------------------------------------------------------------------------------------------
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import Vn.System.PHPLoader;
//-----------------------------------------------------------------------------------------------------
	public class ButtonWLFuncVn extends ButtonWFuncVn {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		private var lInfoLoader:PHPLoader;	// Загрузчик для получения данных
		private var lScript:String;			// Скрипт для получения данных
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function ButtonWLFuncVn() {
			// Конструктор родителя
			super();
			// Коструктор
			lInfoLoader = new PHPLoader();	// Создаем сразу т.к. нужно хранить переменные для скрипта
			lScript = "";
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		override public function _delete():void {
			// Деструктор
			if(lInfoLoader.hasEventListener(Event.COMPLETE)) lInfoLoader.removeEventListener(Event.COMPLETE,OnDataComplete);
			if(lInfoLoader.hasEventListener(IOErrorEvent.IO_ERROR)) lInfoLoader.removeEventListener(IOErrorEvent.IO_ERROR,OnDataIoError);
			lInfoLoader._delete();
			lInfoLoader = null;
			// Деструктор родителя
			super._delete();
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		override protected function OpenWindow():void {
//			lSubWindow = lCreateWindowFunction();
//			if (Window != null) {
				lInfoLoader.addEventListener(Event.COMPLETE, OnDataComplete);
				lInfoLoader.addEventListener(IOErrorEvent.IO_ERROR, OnDataIoError);
//				SetScriptParams();
				if (lScript != "") lInfoLoader.Load(lScript);
//			}
		}
//-----------------------------------------------------------------------------------------------------
		public function AddScriptVariable(vName:String, vValue:String):void {
			// Задание входных параметров для скрипта
			lInfoLoader.AddVariable(vName, vValue);
		}
//-----------------------------------------------------------------------------------------------------
// Обработка событий
//-----------------------------------------------------------------------------------------------------
		private function OnDataComplete(e:Event):void {
			// Данные получены
			lInfoLoader.removeEventListener(Event.COMPLETE, OnDataComplete);
			lInfoLoader.removeEventListener(IOErrorEvent.IO_ERROR, OnDataIoError);
			// Данные могут быть в XML формате или просто данные
			if(e.target.data!="F") {
				// Создать окно
//				CreateWindowL(e.target.data);
				Window = CreateWindowFunction(e.target.data);
				// Вывести окно в сцену
				if (Window != null) {
					AttachWindow();
					dispatchEvent(new Event(ButtonWFuncVn.WINDOWOPENED));
				}
			}
		}
//-----------------------------------------------------------------------------------------------------
		private function OnDataIoError(e:Event):void {
			// Ошибка получения данных
			lInfoLoader.removeEventListener(Event.COMPLETE, OnDataComplete);
			lInfoLoader.removeEventListener(IOErrorEvent.IO_ERROR, OnDataIoError);
			// Ничего не делаем
		}
//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------
		public function set Script(vValue:String):void {
			// Скрипт для получения данных
			if(vValue!="") lScript = vValue;
		}
//-----------------------------------------------------------------------------------------------------
	}
}