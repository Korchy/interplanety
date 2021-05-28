package Vn.Interface.Button {
	// Класс "Кнопка" (тоже самое, что и класс Button, но не отправляет собственное событие, работате только со стандартным MouseEvent.CLICK)
//-----------------------------------------------------------------------------------------------------
	import flash.events.MouseEvent;
	import Vn.Common.SC;
	import Vn.Objects.VnObjectSA;
	import Vn.Interface.Text.VnText;
//-----------------------------------------------------------------------------------------------------
	public class ButtonVn extends VnObjectSA {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		private var ButtonType:uint;		// Вид кнопки
		private var ButtonText:VnText;		// Надпись на кнопке
		private var ButtonTextAlign:uint;	// Выравнивание текста
		private var ButtonTextAlignSpace:uint;	// Размер отступа от края при выравнивании
		private var lEnabled:Boolean;		// true - работает, false - заблокирована
		// Виды кнопок
		public static const BUTTON:uint = 0;		// Обычная кнопка
		public static const BUTTON_TXT:uint = 1;	// Кнопка с текстом
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function ButtonVn() {
			// Конструктор предка
			super();
			// Конструктор
			Type = Button.BUTTON;	// Тип кнопки - обычная
			ButtonTextAlign = SC.CENTER;	// По-умолчанию выравнивание текста по центру
			TextAlignSpace = 0;	// Отступ 0
			// Кнопка доступна
			lEnabled = true;
			addEventListener(MouseEvent.CLICK, OnClick);
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		override public function _delete():void {
			// Текст
			if(ButtonText!=null) {
				removeChild(ButtonText);
				ButtonText._delete();
				ButtonText = null;
			}
			removeEventListener(MouseEvent.CLICK, OnClick);
			// Деструктор предка
			super._delete();
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		private function RealignText():void {
			// Пересчитать выравнивание текста для кнопки
			if(Type==Button.BUTTON_TXT) {
				switch(TextAlign) {
					case SC.CENTER: {
						// По центру
						ButtonText.x = Width05-ButtonText.width/2;
						break;
					}
					case SC.LEFT: {
						// По левому краю
						ButtonText.x = TextAlignSpace;
						break;
					}
					case SC.RIGHT: {
						// По правому краю
						ButtonText.x = Width-ButtonText.width-TextAlignSpace;
						break;
					}
					// y всегда по центру по вертикали
					ButtonText.y = Height05-ButtonText.height/2;
				}
			}
		}
//-----------------------------------------------------------------------------------------------------
// Обработка событий
//-----------------------------------------------------------------------------------------------------
		protected function OnClick(e:MouseEvent):void {
			// Нажатие
			// Переопределяется в наследниках
		}
//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------
		public function get Enabled():Boolean {
			if (hasEventListener(MouseEvent.CLICK)) return true;
			else return false;
		}
//-----------------------------------------------------------------------------------------------------
		public function set Enabled(Value:Boolean):void {
			switch(Value) {
				case true: {
					// Включение
					if (lEnabled == false) addEventListener(MouseEvent.CLICK, OnClick);
				}
				case false: {
					// Блокировка
					if (lEnabled == true) removeEventListener(MouseEvent.CLICK, OnClick);
				}
			}
			lEnabled = Value;
		}
//-----------------------------------------------------------------------------------------------------
		public function get Text():String {
			if(Type==Button.BUTTON_TXT) return ButtonText.Text;
			else return null;
		}
//-----------------------------------------------------------------------------------------------------
		public function set Text(Value:String):void {
			if(Type==Button.BUTTON_TXT) {
				ButtonText.Text = Value;
				RealignText();
			}
		}
//-----------------------------------------------------------------------------------------------------
		public function get TextAlign():uint {
			return ButtonTextAlign;
		}
//-----------------------------------------------------------------------------------------------------
		public function set TextAlign(Value:uint):void {
			ButtonTextAlign = Value;
			RealignText();
		}
//-----------------------------------------------------------------------------------------------------
		public function get TextAlignSpace():uint {
			return ButtonTextAlignSpace;
		}
//-----------------------------------------------------------------------------------------------------
		public function set TextAlignSpace(Value:uint):void {
			ButtonTextAlignSpace = Value;
			RealignText();
		}
//-----------------------------------------------------------------------------------------------------
		public function get Type():uint {
			return ButtonType;
		}
//-----------------------------------------------------------------------------------------------------
		public function set Type(Value:uint):void {
			switch(Value) {
				case Button.BUTTON: {
					// Обычная кнопка
					if(ButtonText!=null) {
						removeChild(ButtonText);
						ButtonText._delete();
						ButtonText = null;
					}
					break;
				}
				case Button.BUTTON_TXT: {
					// Текст
					if(ButtonText!=null) {
						removeChild(ButtonText);
						ButtonText._delete();
						ButtonText = null;
					}
					ButtonText = new VnText();
					TextAlign = SC.CENTER;
					addChild(ButtonText);
					break;
				}
			}
			ButtonType = Value;
		}
//-----------------------------------------------------------------------------------------------------
	}
}