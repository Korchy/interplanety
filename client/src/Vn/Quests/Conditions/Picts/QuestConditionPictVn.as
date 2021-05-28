package Vn.Quests.Conditions.Picts {
	// Картинка с условием для квеста
//-----------------------------------------------------------------------------------------------------
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.system.System;
	import Vn.Common.SC;
	import Vn.Objects.VnObjectT;
	import Vn.Interface.Text.VnText;
	import Vn.Interface.ToolTip.ToolTip;
	import Vn.System.PHPLoader;
	import Vn.Text.TextDictionary;
	import Vn.Interplanety;
//-----------------------------------------------------------------------------------------------------
	public class QuestConditionPictVn extends VnObjectT {
//	public class QuestCondition extends VnObjectD {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		private var IdentifyText:VnText;	// Дополнительный текст
		protected var Desc:ToolTip;			// Всплывающее описание
		protected var InfoLoader:PHPLoader;		// Загрузка/сохранение данных
		protected var Script:String;			// Скрипт для загрузки данных
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function QuestConditionPictVn() {
			// Конструктор предка
			super();
			// Конструктор
			SetLocalPosition(30,28);	// 56 в высоту, из них 15 на подпись, 60х40 - картинка
			// Текст
			IdentifyText = new VnText();
//			IdentifyText.border = true;
			IdentifyText.width = Width;
			IdentifyText.x = Width/2.0;
			IdentifyText.y = Height-15;
			IdentifyText.Align = VnText.CENTER;
			IdentifyText.textColor = SC.BLACK;
			IdentifyText.FontSize = 10;
			addChild(IdentifyText);
			// Описание
			Desc = new ToolTip();
			addEventListener(MouseEvent.ROLL_OVER,MouseOver);
			addEventListener(MouseEvent.ROLL_OUT,MouseOut);
			// Загрузчик
			Script = "getquestconditionpictinfo.php";
//			InfoLoader = new PHPLoader();
			InfoLoader = null;
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		override public function _delete():void {
			// Деструктор
			// Загрузчик
			if(InfoLoader!=null) {
				if(InfoLoader.hasEventListener(Event.COMPLETE)) InfoLoader.removeEventListener(Event.COMPLETE,OnDataComplete);
				if(InfoLoader.hasEventListener(IOErrorEvent.IO_ERROR)) InfoLoader.removeEventListener(IOErrorEvent.IO_ERROR,OnDataIoError);
				InfoLoader._delete();
				InfoLoader = null;
			}
			// Текст
			if(IdentifyText.parent!=null) removeChild(IdentifyText);
			IdentifyText._delete();
			IdentifyText = null;
			// Описание
			if(Desc.parent!=null) removeChild(Desc);
			removeEventListener(MouseEvent.ROLL_OVER,MouseOver);
			removeEventListener(MouseEvent.ROLL_OUT,MouseOut);
			Desc._delete();
			Desc = null;
			// Деструктор предка
			super._delete();
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		public function Load(Params:Object):void {
			// Загрузка данными
			InfoLoader = new PHPLoader();
			for (var Name:String in Params) {
				InfoLoader.AddVariable(Name,Params[Name]);
			}
			InfoLoader.addEventListener(Event.COMPLETE,OnDataComplete);
			InfoLoader.addEventListener(IOErrorEvent.IO_ERROR,OnDataIoError);
			InfoLoader.Load(Script);
		}
//-----------------------------------------------------------------------------------------------------
		protected function OnComplete(Data:XML):void {
			// Действия с полученными данными для загрузки
			// Переопределяется в наследниках
		}
//-----------------------------------------------------------------------------------------------------
		protected function OnIoError(e:Event):void {
			// Действия при ошибке получения данных
			// Переопределяется в наследниках
			Vn.Interplanety.Cons.Add(TextDictionary.Text(117));	// Системная ошибка
		}
//-----------------------------------------------------------------------------------------------------
//		override protected function Draw():void {
//			// Отрисовка объекта
//			graphics.lineStyle(1,0x444444,0.5);
//			graphics.drawRect(0,0,Width,Height);
//		}
//-----------------------------------------------------------------------------------------------------
// Обработка событий
//-----------------------------------------------------------------------------------------------------
		private function OnDataComplete(e:Event):void {
			// Данные получены
			try {
				var Data:XML = new XML(e.target.data);	// Данные
			}
			catch (e1:Error) {
				trace(e.target.data);
				trace("------");
				trace(e1.toString());
				trace("------");
			}
			OnComplete(Data);
			System.disposeXML(Data);
			// Удалить загрузчик
			InfoLoader.removeEventListener(Event.COMPLETE,OnDataComplete);
			InfoLoader.removeEventListener(IOErrorEvent.IO_ERROR, OnDataIoError);
			InfoLoader._delete();
			InfoLoader = null;
		}
//-----------------------------------------------------------------------------------------------------
		private function OnDataIoError(e:IOErrorEvent):void {
			// Ошибка получения данных
			OnIoError(e);
			// Удалить загрузчик
			InfoLoader.removeEventListener(Event.COMPLETE,OnDataComplete);
			InfoLoader.removeEventListener(IOErrorEvent.IO_ERROR,OnDataIoError);
			InfoLoader._delete();
			InfoLoader = null;
		}
//-----------------------------------------------------------------------------------------------------
		private function MouseOver(e:Event):void {
			// Наведение курсора на объект
			if(Desc.parent==null) addChild(Desc);
		}
//-----------------------------------------------------------------------------------------------------
		private function MouseOut(e:Event):void {
			// Уход курсора с объекта
			if(Desc.parent!=null) removeChild(Desc);
		}
//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------
		public function set Text(Value:String):void {
			IdentifyText.Text = Value;
		}
//-----------------------------------------------------------------------------------------------------
	}
}