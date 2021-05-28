package Vn.Interface.Text {
	// Класс Текст со скроллбаром
//-----------------------------------------------------------------------------------------------------
	import flash.events.Event;
	import Vn.Objects.VnObjectT;
	import Vn.Interface.Scroll.ScrollBar;
//-----------------------------------------------------------------------------------------------------
	public class VnTextScroll extends VnObjectT {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		private var Txt:VnText;				// Текст
		private var Scroll:ScrollBar;		// Скроллбар
		private var lInnerScroll:Boolean;	// Указание, как размещать скролл бар: true - внутри рабочей области, false - вынести наружу
		private var lMarginW:Number;
		private var lMarginH:Number;		// Отступы текста по краям
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function VnTextScroll(NewWidth:uint,NewHeight:uint) {
			// Конструктор предка
			super();
			// Конструктор
			SetLocalPosition(NewWidth/2,NewHeight/2);
			// Скроллбар
			Scroll = new ScrollBar(10,NewHeight);
			addChild(Scroll);
			InnerScroll = false;
			Scroll.addEventListener(ScrollBar.SCROLLING,OnScrolling);
			// Текст
			lMarginH = 6;
			lMarginW = 6;
			Txt = new VnText();
			addChild(Txt);
			Txt.Align = VnText.NONE;
			Txt.wordWrap = true;
			Txt.multiline = true;
			Txt.height = NewHeight-lMarginH;
			Txt.y = lMarginH / 2.0;
			if (lInnerScroll == true) Txt.width = NewWidth - lMarginW - Scroll.Width;
			else Txt.width = NewWidth - lMarginW;
			Txt.x = lMarginW / 2.0;
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		override public function _delete():void {
			// Деструктор
			// Скроллбар
			Scroll.removeEventListener(ScrollBar.SCROLLING,OnScrolling);
			removeChild(Scroll);
			Scroll._delete();
			Scroll = null;
			// Текст
			removeChild(Txt);
			Txt._delete();
			Txt = null;
			// Деструктор предка
			super._delete();
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		
//-----------------------------------------------------------------------------------------------------
// Обработка событий
//-----------------------------------------------------------------------------------------------------
		public function OnScrolling(e:Event):void {
			// При скроллировании
			Txt.scrollV = Scroll.Offset*Txt.maxScrollV;
		}
//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------
		public function set Align(Value:uint):void {
			Txt.Align = Value;
		}
//-----------------------------------------------------------------------------------------------------
		public function set Size(Value:uint):void {
			Txt.FontSize = Value;	// Размер шрифта
		}
//-----------------------------------------------------------------------------------------------------
		public function set Leading(Value:uint):void {
			Txt.Leading = Value;	// Межстрочный интервал
		}
//-----------------------------------------------------------------------------------------------------
		public function get HtmlText():String {
			return Txt.HtmlText;	// Текст (в формате HTML)
		}
//-----------------------------------------------------------------------------------------------------
		public function set HtmlText(Value:String):void {
			Txt.HtmlText = Value;	// Текст (в формате HTML)
		}
//-----------------------------------------------------------------------------------------------------
		public function set TextColor(Value:uint):void {
			Txt.textColor = Value;	// Цвет текста
		}
//-----------------------------------------------------------------------------------------------------
		public function get Border():Boolean {
			return Txt.Border;	// Рамка
		}
//-----------------------------------------------------------------------------------------------------
		public function set Border(Value:Boolean):void {
			Txt.Border = Value;
		}
//-----------------------------------------------------------------------------------------------------
		public function set InnerScroll(Value:Boolean):void {
			// Положение скролла
			if (Value == true) Scroll.MoveIntoParent(Width - Scroll.Width05, Height05, true);	// Внутри - у правой границы
			else Scroll.MoveIntoParent(Width+Scroll.Width05+10,Height05,true);	// На 10 пикс. от правой границы
		}
//-----------------------------------------------------------------------------------------------------
	}
}