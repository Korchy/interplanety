package Vn.Interface.Window {
//-----------------------------------------------------------------------------------------------------
// Класс "Окно"
//-----------------------------------------------------------------------------------------------------
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import Vn.Math.RectangleVn;
	import Vn.Math.Vector2;
	import Vn.Objects.VnObjectL;
	import Vn.Interface.Text.VnText;
	import Vn.Interface.Button.CloseButton;
	import Vn.Text.TextDictionary;
	import Vn.Vn.Events.EvAppResize;
//-----------------------------------------------------------------------------------------------------
	public class VnWindow extends VnObjectL {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		protected var CaptionObj:VnText;	// Заголовок окна
		protected var CloseBtn:CloseButton;	// Кнопка закрытия окна
		protected var WindowImg:WindowImageVn;	// Подложка окна
		private var lWorkSpace:RectangleVn;	// Размеры рабочей области
		private var lSizeable:Boolean;	// true - с изменяемыми размерами, false - только заданный размер
		// Константы событий
		public static const CLOSED:String = "EvWindowClosed";	// Окно требует себя закрыть
		public static const ONCLOSE:String = "EvWindowOnClose";	// При закрытии окна
		public static const ONOPEN:String = "EvWindowOnOpen";	// При окрытии окна
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function VnWindow() {
			// Конструктор предка
			super();
			// Конструктор
			NeedPlace = true;
			Sizeable = false;
			// Рабочая область
			lWorkSpace = new RectangleVn();	// Рабочая область - прямоугольник с полями 25 пикс. по горизонтали и верхним полем 20 пикс.
			lWorkSpace.X = 25;
			lWorkSpace.Y = 20;
			// Подложка
			AddBackground();
			// Заголовок
			CaptionObj = new VnText();
			Caption.x = lWorkSpace.X;
			Caption.Text = TextDictionary.Text(1);
			addChild(CaptionObj);
			// Кнопка закрытия окна
			CloseBtn = new CloseButton();
			addChild(CloseBtn);
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		override public function _delete():void {
			// Деструктор
			lWorkSpace._delete();	// Рабочая область
			lWorkSpace = null;
			RemoveBackground();		// Подложка
			removeChild(CaptionObj);	// Заголовок
			CaptionObj._delete();
			CaptionObj = null;
			removeChild(CloseBtn);	// Кнопка закрытия
			CloseBtn._delete();
			CloseBtn = null;
			// Деструктор предка
			super._delete();
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		protected function AddBackground():void {
			// Добавление подложки
			WindowImg = new WindowImageVn();
			addChild(WindowImg);
		}
//-----------------------------------------------------------------------------------------------------
		protected function RemoveBackground():void {
			// Удаление подложки
			if (WindowImg.parent != null) removeChild(WindowImg);
			WindowImg._delete();
			WindowImg = null;
		}
//-----------------------------------------------------------------------------------------------------
		override public function SetLocalPosition(NewX:Number,NewY:Number):void {
			super.SetLocalPosition(NewX, NewY);
			lWorkSpace.Width = NewX * 2.0 - lWorkSpace.X * 2.0;
			lWorkSpace.Height = NewY * 2.0 - lWorkSpace.Y;
			WindowImg.SetLocalPosition(NewX, NewY);
		}
//-----------------------------------------------------------------------------------------------------
		override public function hitTestPoint(x:Number, y:Number, shapeFlag:Boolean = false):Boolean {
			// Само окно проверяем по обрисовке подложки
			return WindowImg.hitTestPoint(x,y,shapeFlag);
		}

//-----------------------------------------------------------------------------------------------------
		public function Close():void {
			// Закрыть окно
			OnClose();
			// Сказать тому, кто создал это окно, что нужно его закрыть
			dispatchEvent(new Event(VnWindow.CLOSED));
		}
//-----------------------------------------------------------------------------------------------------
		override public function RePlace(NewPlace:Vector2 = null):void {
			// Перемещение в новую точку
			super.RePlace();
			// Перерисовать подложкку
			WindowImg.Redraw();
		}
//-----------------------------------------------------------------------------------------------------
		protected function GetSize():Vector2 {
			// Получение размеров окна - переопределяется в наследниках
			return new Vector2(Width, Height);
		}
//-----------------------------------------------------------------------------------------------------
		protected function ReSize(NewSize:Vector2=null):void {
			// Изменить размеры
			if(stage!=null) {
				if(Sizeable==true) {
					var SizeTo:Vector2;
					if (NewSize == null) SizeTo = GetSize();
					else SizeTo = NewSize;
					SetLocalPosition(SizeTo.X / 2.0, SizeTo.Y / 2.0);
//					RePlace();
//					CloseBtn.RePlace();
				}
			}
		}
//-----------------------------------------------------------------------------------------------------
// Обработка событий
//-----------------------------------------------------------------------------------------------------
		override protected function OnAddToStage(e:Event):void {
			// При добавлении в список отображения
			RePlace();
			// Следить за изменениями размеров
			(root).addEventListener(EvAppResize.APP_RESIZE, OnApplicationResize);
			// Отправить событие
			dispatchEvent(new Event(VnWindow.ONOPEN));
		}
//-----------------------------------------------------------------------------------------------------
		override protected function OnRemoveFromStage(e:Event):void {
			// При удалении из списка отображения
			(root).removeEventListener(EvAppResize.APP_RESIZE, OnApplicationResize);
			// Отправить событие
			dispatchEvent(new Event(VnWindow.ONCLOSE));
		}
//-----------------------------------------------------------------------------------------------------
		protected function OnClose():void {
			// Отработка при закрытии окна
		}
//-----------------------------------------------------------------------------------------------------
		protected function OnApplicationResize(e:EvAppResize):void {
			// Отработка при изменении размеров основного окна
			// Размеры: ширина - по ширине окна минус 5 пикс по бокам
			ReSize(new Vector2(e.NewWidth, e.NewHeight));
			RePlace();
		}
//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------
		public function get Caption():VnText {
			return CaptionObj;	// Заголовок
		}
//-----------------------------------------------------------------------------------------------------
		public function get WorkSpace():RectangleVn {
			return lWorkSpace;	// Квадрат рабочей области
		}
//-----------------------------------------------------------------------------------------------------
		public function get Sizeable():Boolean {
			return lSizeable;	// Признак изменяемости размеров
		}
//-----------------------------------------------------------------------------------------------------
		public function set Sizeable(Value:Boolean):void {
			lSizeable = Value;
			ReSize();
			if (parent != null) RePlace();
		}
//-----------------------------------------------------------------------------------------------------
		public function get closeButton():CloseButton {
			return CloseBtn;
		}
//-----------------------------------------------------------------------------------------------------
	}
}