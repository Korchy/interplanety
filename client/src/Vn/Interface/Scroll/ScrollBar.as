package Vn.Interface.Scroll {
	// Класс ScrollBar - полоса прокрутки
//-----------------------------------------------------------------------------------------------------
	import flash.events.Event;
	import flash.events.MouseEvent;
	import Vn.Common.SC;
	import Vn.Objects.VnObjectD;
//-----------------------------------------------------------------------------------------------------
	public class ScrollBar extends VnObjectD {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		private var Trip:ScrollBarTrip;	// Подложка
		private var StartOffset:int;	// Точка отсчета для вычисления смещения подложки
		private var CurrentOffset:int;	// Текущие значения смещения подложки
		private var EndOffset:int;		// Окончательное смещение подложки относительно нулевой отметки
		// Константы событий
		public static const SCROLLING:String = "EvScrolling";	// Скроллирование
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function ScrollBar(NewW:uint,NewH:uint) {
			// Конструктор предка
			super();
			// Конструктор
			SetLocalPosition(NewW/2,NewH/2);
			StartOffset = 0;
			CurrentOffset = 0;
			EndOffset = 0;
			Trip = new ScrollBarTrip(5);
			addChild(Trip);
			Trip.addEventListener(MouseEvent.MOUSE_DOWN,OnMouseDown);
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		override public function _delete():void {
			// Деструктор
			Trip.removeEventListener(MouseEvent.MOUSE_DOWN,OnMouseDown);
			removeChild(Trip);
			Trip._delete();
			Trip = null;
			// Деструктор предка
			super._delete();
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		override protected function Draw():void {
			// Отрисовка объекта
			graphics.lineStyle(2,SC.GREY);
			graphics.moveTo(Width05,0);
			graphics.lineTo(Width05,Height);
			Trip.MoveIntoParent(Width05+Trip.Width05,Trip.Height05,true);
		}
//-----------------------------------------------------------------------------------------------------
		override public function Clear():void {
			// Очистка объекта
			graphics.clear();
		}
//-----------------------------------------------------------------------------------------------------
// Обработка событий
//-----------------------------------------------------------------------------------------------------
		public function OnMouseDown(e:MouseEvent):void {
			// Нажатие мышкой с намерением перетаскивания
			StartOffset = e.stageY;
			CurrentOffset = 0;
			stage.addEventListener(MouseEvent.MOUSE_UP,OnMouseUp);
			stage.addEventListener(MouseEvent.MOUSE_MOVE,OnMouseMove);
		}
//-----------------------------------------------------------------------------------------------------
		public function OnMouseUp(e:MouseEvent):void {
			// Отпускание мышки после перетаскивания
			stage.removeEventListener(MouseEvent.MOUSE_UP,OnMouseUp);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE,OnMouseMove);
			EndOffset += CurrentOffset;
		}
//-----------------------------------------------------------------------------------------------------
		public function OnMouseMove(e:MouseEvent):void {
			// Перемещение указателя мышки
			// Смещение подложки от ее предыдущего положения
			CurrentOffset = e.stageY - StartOffset;
			if(EndOffset+CurrentOffset>Height) CurrentOffset = Height - EndOffset;
			if(EndOffset+CurrentOffset<0) CurrentOffset = -EndOffset;
			Trip.MoveIntoParent(Width05+Trip.Width05,EndOffset+CurrentOffset+Trip.Height05,true);
			dispatchEvent(new Event(ScrollBar.SCROLLING));
		}
//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------
		public function get Offset():Number {
			return (EndOffset+CurrentOffset)/Height;	// Смещение от 0 (верхней точки) (значение от 0 до 1)
		}
//-----------------------------------------------------------------------------------------------------
	}
}