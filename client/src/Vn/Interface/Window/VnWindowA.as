package Vn.Interface.Window {
//-----------------------------------------------------------------------------------------------------
// Окно с кнопками принятия или отмены. Принятие проверяется локально и на сервере.
//-----------------------------------------------------------------------------------------------------
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.system.System;
	import Vn.Interface.Button.AcceptButton;
	import Vn.Interface.Button.CancelButton;
	import Vn.System.PHPLoader;
	import Vn.Text.TextDictionary;
	import Vn.Interplanety;
//-----------------------------------------------------------------------------------------------------
	public class VnWindowA extends VnWindowB {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		private var AButton:AcceptButton;	// Кнопка "Принять"
		private var CButton:CancelButton;	// Кнопка "Отмена"
		private var lInfoLoader:PHPLoader;	// Загрузчик данных
		private var lScript:String;			// Скрипт загрузчика
		// Константы событий
		public static const ACCEPTED:String = "EvAccepted";	// Принято
		public static const DECLINED:String = "EvDeclined";	// Не принято
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function VnWindowA() {
			// Конструктор предка
			super();
			// Конструктор
			lScript = "";
			lInfoLoader = new PHPLoader();
			AButton = new AcceptButton();
			AButton.addEventListener(MouseEvent.CLICK,OnAcceptButtonClick);
			addChild(AButton);
			CButton = new CancelButton();
			CButton.addEventListener(MouseEvent.CLICK,OnCancelButtonClick);
			addChild(CButton);
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		override public function _delete():void {
			// Деструктор
			// Кнопка принятия
			AButton.removeEventListener(MouseEvent.CLICK,OnAcceptButtonClick);
			removeChild(AButton);
			AButton._delete();
			AButton = null;
			CButton.removeEventListener(MouseEvent.CLICK,OnCancelButtonClick);
			removeChild(CButton);
			CButton._delete();
			CButton = null;
			lInfoLoader.removeEventListener(Event.COMPLETE,OnDataComplete);
			lInfoLoader.removeEventListener(IOErrorEvent.IO_ERROR,OnDataIoError);
			lInfoLoader._delete();
			lInfoLoader = null;
			// Деструктор предка
			super._delete();
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		protected function CheckLocal():Boolean {
			// Провести проверку локально. Если не пройдено - вернуть false
			return true;
		}
//-----------------------------------------------------------------------------------------------------
		private function CheckServer():void {
			// Провести проверку на сервере
			if (lScript != "") {
				SetCheckingOnServerParameters();
				lInfoLoader.addEventListener(Event.COMPLETE,OnDataComplete);
				lInfoLoader.addEventListener(IOErrorEvent.IO_ERROR, OnDataIoError);
				lInfoLoader.Load(lScript);
			}
		}
//-----------------------------------------------------------------------------------------------------
		protected function SetCheckingOnServerParameters():void {
			// Установка параметров скрипта для проверки на сервере
			
		}
//-----------------------------------------------------------------------------------------------------
		protected function AddServerParameter(vName:String, vValue:String):void {
			// Добавление параметра для серверного скрипта
			lInfoLoader.AddVariable(vName, vValue);
		}
//-----------------------------------------------------------------------------------------------------
		protected function Accepted(Data:XML):void {
			// Условие принято
			dispatchEvent(new Event(VnWindowA.ACCEPTED));
		}
//-----------------------------------------------------------------------------------------------------
		protected function Declined():void {
			// Условие НЕ принято
			dispatchEvent(new Event(VnWindowA.DECLINED));
		}
//-----------------------------------------------------------------------------------------------------
// Обработка событий
//-----------------------------------------------------------------------------------------------------
		private function OnAcceptButtonClick(e:MouseEvent):void {
			// При нажатии кнопки принять
			// Проверить локально. Если не пройдена проверка - отмена
			if (CheckLocal() == false) {
				Declined();
				return;
			}
			// Проверить на сервере
			CheckServer();
		}
//-----------------------------------------------------------------------------------------------------
		private function OnCancelButtonClick(e:MouseEvent):void {
			// При нажатии кнопки "отмена" (до ее собственного обработчика)
			Declined();
		}
//-----------------------------------------------------------------------------------------------------
		private function OnDataComplete(e:Event):void {
			// Сервер отработал, проверить результаты
			lInfoLoader.removeEventListener(Event.COMPLETE,OnDataComplete);
			lInfoLoader.removeEventListener(IOErrorEvent.IO_ERROR, OnDataIoError);
			// Данные приходят в XML формате
			try {
				var Data:XML = new XML(e.target.data);
			}
			catch (e1:Error) {
				trace(e.target.data);
			}
			// Обработать полученные данные
			if(Data.name()=="ERR") {
				if(uint(Data)!=0) {
					// Если корневой узел ERR и значение != 0 - возвращена ошибка
					Vn.Interplanety.Cons.Add(TextDictionary.Text(uint(Data)));
					Declined();
				}
				else {
					// Если ERR=0 - нормальное завершение скрипта без ошибок и без возвращаемых данных
					Accepted(Data);
				}
			}
			else {
				// Возвращены данные о принятии
				Accepted(Data);
			}
			System.disposeXML(Data);
		}
//-----------------------------------------------------------------------------------------------------
		private function OnDataIoError(e:IOErrorEvent):void {
			// Ошибка отработки на сервере - отмена
			lInfoLoader.removeEventListener(Event.COMPLETE,OnDataComplete);
			lInfoLoader.removeEventListener(IOErrorEvent.IO_ERROR,OnDataIoError);
			Declined();
		}
//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------
		public function set Script(vValue:String):void {
			// Скрипт для работы с сервером
			lScript = vValue;
		}
//-----------------------------------------------------------------------------------------------------
	}
}