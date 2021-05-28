package Vn.Interface.Edit {
	// Класс EditN - Esit для ввода чисел
//-----------------------------------------------------------------------------------------------------
	import flash.display.FocusDirection;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.TextEvent;
	import flash.events.MouseEvent;
	import Vn.Common.Common;
	import Vn.Objects.VnObjectT;
	import Vn.Interface.Button.IncrementButton;
	import Vn.Interface.Button.DecrementButton;
//-----------------------------------------------------------------------------------------------------
	public class EditN extends VnObjectT {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		private var lType:uint;					// Тип поля ввода
		private var EditWindow:Edit;			// Текстовый компонент
		private var IButton:IncrementButton;	// +1
		private var DButton:DecrementButton;	// -1
		private var lIDValue:Number;			// Значение инкремента/декремента
		private var MaxControl:Boolean;			// true - контролировать Max
		private var MinControl:Boolean;			// true - контролировать Min
		private var MaxValue:Number;			// Возможный максимум
		private var MinValue:Number;			// Возможный минимум
		// Константы
		public static const TYPE_UINT:uint = 0;	// Целые положительные беззнаковые числа
		public static const TYPE_INT:uint = 1;	// Целые беззнаковые числа
		public static const TYPE_UNUMBER:uint = 2;	// Нецелые положительные беззнаковые числа
		public static const TYPE_NUMBER:uint = 3;	// Нецелые беззнаковые числа
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function EditN() {
			// Конструктор предка
			super();
			// Конструктор
			Name = 64;
			SetLocalPosition(25+10+10,10);	// Edit - 50, две кнопки по 20
			MaxValue = 0.0;
			MinValue = 0.0;
			MaxControl = false;
			MinControl = false;
			// Текстовый элемент
			EditWindow = new Edit();
			EditWindow.x = 20;
			EditWindow.Text = "0";
			Type = TYPE_UINT;
			addChild(EditWindow);
			EditWindow.addEventListener(FocusEvent.FOCUS_OUT, OnFocusOut);
			EditWindow.addEventListener(Event.CHANGE, OnChange);
			// Кнопки
			IButton = new IncrementButton();
			addChild(IButton);
			IButton.MoveIntoParent(80, 10, true);
			IButton.addEventListener(MouseEvent.CLICK, OnIButtonClick);
			DButton = new DecrementButton();
			addChild(DButton);
			DButton.addEventListener(MouseEvent.CLICK, OnDButtonClick);
			lIDValue = 1.0;	// По умолчанию меняем на 1
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		override public function _delete():void {
			// Деструктор
			EditWindow.removeEventListener(FocusEvent.FOCUS_OUT, OnFocusOut);
			EditWindow.removeEventListener(Event.CHANGE, OnChange);
			removeChild(EditWindow);
			EditWindow._delete();
			EditWindow = null;
			IButton.removeEventListener(MouseEvent.CLICK, OnIButtonClick);
			removeChild(IButton);
			IButton._delete();
			IButton = null;
			DButton.removeEventListener(MouseEvent.CLICK, OnDButtonClick);
			removeChild(DButton);
			DButton._delete();
			DButton = null;
			// Деструктор предка
			super._delete();
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		private function MinMaxControl():void {
			// Контроль max/min
			if(MaxControl==true) {
				if(Number(EditWindow.Text)>MaxValue) EditWindow.Text = String(MaxValue);
			}
			if(MinControl==true) {
				if(Number(EditWindow.Text)<MinValue) EditWindow.Text = String(MinValue);
			}
		}
//-----------------------------------------------------------------------------------------------------
// Обработка событий
//-----------------------------------------------------------------------------------------------------
		private function OnIButtonClick(e:MouseEvent):void {
			// Инкремент (+1)
			Value = Common.Round(Value + lIDValue,5)
		}
//-----------------------------------------------------------------------------------------------------
		private function OnDButtonClick(e:MouseEvent):void {
			// Декремент (-1)
			Value = Common.Round(Value - lIDValue,5)
		}
//-----------------------------------------------------------------------------------------------------
		private function OnChange(e:Event):void {
			// Ввод данных в поле
			// Для знаковых чисел
			if(lType==TYPE_INT||lType==TYPE_NUMBER) {
				// Минус допускается только на первом месте
				var MinusPos:int = EditWindow.Text.lastIndexOf("-");
				if (MinusPos > 0) {
					var MPattern:RegExp = /-/gi;
					EditWindow.Text = EditWindow.Text.substr(0, 1)+EditWindow.Text.substring(1).replace(MPattern, "");
				}
			}
			// Для не целых чисел
			if (lType == TYPE_NUMBER || lType == TYPE_UNUMBER) {
				// Точка допускается только одна
				var PosF:int = EditWindow.Text.indexOf(".");
				if (PosF != EditWindow.Text.lastIndexOf(".")) {
					// Больше одной - удалить все точки в части строки, после первой точки
					var PPattern:RegExp = /\./gi;
					EditWindow.Text = EditWindow.Text.substring(0, PosF + 1) + EditWindow.Text.substring(PosF + 1).replace(PPattern, "");
				}
				// Если точка первая - добавить впереди 0
				if (PosF == 0) EditWindow.Text = "0" + EditWindow.Text;
			}
			// Выход за пределы значений
			// Здесь можно контролировать только максимальное значение. Минимальное - при потере фокуса т.к. первая цифра может быть меньше минимальной, но набор еще идет
			if(MaxControl==true) {
				if(Number(EditWindow.Text)>MaxValue) EditWindow.Text = String(MaxValue);
			}
			dispatchEvent(new Event(Event.CHANGE));
		}
//-----------------------------------------------------------------------------------------------------
		private function OnFocusOut(e:FocusEvent):void {
			// Потеря фокуса
			MinMaxControl();
			dispatchEvent(new Event(Event.CHANGE));
		}
//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------
		public function set Value(NewValue:Number):void {
			EditWindow.Text = String(NewValue);
			MinMaxControl();
		}
//-----------------------------------------------------------------------------------------------------
		public function get Value():Number {
			return Number(EditWindow.Text);
		}
//-----------------------------------------------------------------------------------------------------
		public function get Max():int {
			return MaxValue;
		}
//-----------------------------------------------------------------------------------------------------
		public function set Max(NewValue:int):void {
			MaxValue = NewValue;
			MaxControl = true;
		}
//-----------------------------------------------------------------------------------------------------
		public function get Min():int {
			return MinValue;
		}
//-----------------------------------------------------------------------------------------------------
		public function set Min(NewValue:int):void {
			MinValue = NewValue;
			MinControl = true;
		}
//-----------------------------------------------------------------------------------------------------
		public function set IDVAlue(vValue:Number):void {
			// Значение инкремента/декремента
			lIDValue = vValue;
		}
//-----------------------------------------------------------------------------------------------------
		public function set Type(vValue:uint):void {
			// Тип поля ввода
			switch (vValue)  {
				case TYPE_INT:
					EditWindow.Restrict = "0-9\\-";		// Цифры, минус
					break;
				case TYPE_UNUMBER:
					EditWindow.Restrict = "0-9.";		// Цифры, точка
					break;
				case TYPE_NUMBER:
					EditWindow.Restrict = "0-9.\\-";	// Цифры, точка, минус
					break;
				default:	// TYPE_UINT
					EditWindow.Restrict = "0-9";		// Цифры
					vValue = TYPE_UINT;
			}
			lType = vValue;
		}
//-----------------------------------------------------------------------------------------------------
	}
}