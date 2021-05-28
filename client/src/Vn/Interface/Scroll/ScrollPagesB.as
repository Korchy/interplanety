package Vn.Interface.Scroll {
	// Кнопки пролистывания страниц
//-----------------------------------------------------------------------------------------------------
	import flash.events.Event;
	import Vn.Math.Vector2;
	import Vn.Objects.VnObjectR;
	import Vn.Interface.Button.Button;
	import Vn.Interface.Button.NextButton;
	import Vn.Interface.Button.PrevButton;
//-----------------------------------------------------------------------------------------------------
	public class ScrollPagesB extends VnObjectR {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		private var ButtonNext:NextButton;	// "Далее"
		private var ButtonPrev:PrevButton;	// "Назад"
		// Константы событий
		public static const NEXT:String = "EvScrollPagesBNext";	// Далее
		public static const PREV:String = "EvScrollPagesBPrev";	// Назад
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function ScrollPagesB(vNewSize:Vector2) {
			// Конструктор предка
			super();
			// Конструктор
			// Кнопки "Далее", "Назад"
			ButtonNext = new NextButton();
			ButtonNext.addEventListener(Button.CLICKED,ButtonNextClicked);
			ButtonPrev = new PrevButton();
			ButtonPrev.addEventListener(Button.CLICKED,ButtonPrevClicked);
			// Центр
			SetLocalPosition(vNewSize.X / 2.0, vNewSize.Y / 2.0);
			// Добавить кнопки
			addChild(ButtonNext);
			addChild(ButtonPrev);
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		override public function _delete():void {
			// Деструктор
			// Кнопки
			ButtonNext.removeEventListener(Button.CLICKED,ButtonNextClicked);
			removeChild(ButtonNext);
			ButtonNext._delete();
			ButtonNext = null;
			ButtonPrev.removeEventListener(Button.CLICKED,ButtonPrevClicked);
			removeChild(ButtonPrev);
			ButtonPrev._delete();
			ButtonPrev = null;
			// Деструктор предка
			super._delete();
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		public function ReSize(vNewSize:Vector2):void {
			// Изменить размеры
			SetLocalPosition(vNewSize.X / 2.0, vNewSize.Y / 2.0);
			ButtonNext.RePlace();
			ButtonPrev.RePlace();
		}
//-----------------------------------------------------------------------------------------------------
// Обработка событий
//-----------------------------------------------------------------------------------------------------
		protected function ButtonPrevClicked(e:Event):void {
			// Назад
			dispatchEvent(new Event(ScrollPagesB.PREV));
		}
//-----------------------------------------------------------------------------------------------------
		protected function ButtonNextClicked(e:Event):void {
			// Далее
			dispatchEvent(new Event(ScrollPagesB.NEXT));
		}
//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------
		public function get ClientX():uint {
			// Начало клиентской части страницы (X от кнопки Prev)
			return 5+ButtonPrev.Width+5;
		}
//-----------------------------------------------------------------------------------------------------
		public function get ClientY():uint {
			// Начало клиентской части страницы (Y от кнопки Prev)
			return 5;
		}
//-----------------------------------------------------------------------------------------------------
		public function get ClientWidth():uint {
			// Ширина клиентской области
			return Width-2*(5+ButtonNext.Width+5);
		}
//-----------------------------------------------------------------------------------------------------
		public function get ClientHeight():uint {
			// Высота клиентской области
			return Height;
		}
//-----------------------------------------------------------------------------------------------------
	}
}