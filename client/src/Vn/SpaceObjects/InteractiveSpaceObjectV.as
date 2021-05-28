package Vn.SpaceObjects {
//-----------------------------------------------------------------------------------------------------
// Виртуальный космический объект
//-----------------------------------------------------------------------------------------------------
	import flash.events.EventPhase;
	import flash.events.MouseEvent;
	import Vn.Math.Vector2;
	import Vn.Events.EventVn;
	import Vn.Interplanety;
//-----------------------------------------------------------------------------------------------------
	public class InteractiveSpaceObjectV extends InteractiveSpaceObject {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		private var lImageDragging:Boolean;		// true - разрешается перетаскивание картинки, false - не разрешается
		private var lMode:uint;					// Режим работы
		// Константы
		public static const MODE_VIEW:uint = 0;		// Стандартный режим (просмотр)
		public static const MODE_DELETE:uint = 1;	// Режим удаления объектов
		public static const MODE_MODIFY:uint = 2;	// Режим изменения параметров объектов
		public static const MODE_MOVE:uint = 3;		// Режим перемещения объектов
		public static const MODE_ADD:uint = 4;		// Режим добавленя других объектов в систему
		// Константы событий
		public static const PRIZE_MOVED:String = "EvPrizeMoved";	// ISOV изменил положение
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function InteractiveSpaceObjectV() {
			// Конструктор предка
			super();
			// Конструктор
			lMode = MODE_VIEW;
//			ImageDragging = false;
			}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		override public function _delete():void {
			// Деструктор
			RemoveMDEvent();
			// Деструктор предка
			super._delete();
			}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		protected function AddMDEvent():void {
			// Включить перетаскивание
			lSpaceObjectImage.addEventListener(MouseEvent.MOUSE_DOWN, OnMouseDown);
			lSpaceObjectImage.addEventListener(MouseEvent.MOUSE_UP, OnMouseUp);
		}
//-----------------------------------------------------------------------------------------------------
		protected function RemoveMDEvent():void {
			// Выключить перетаскивание
			if (lSpaceObjectImage != null) {
				lSpaceObjectImage.removeEventListener(MouseEvent.MOUSE_DOWN, OnMouseDown);
				lSpaceObjectImage.removeEventListener(MouseEvent.MOUSE_UP, OnMouseUp);
			}
		}
//-----------------------------------------------------------------------------------------------------
		protected function SetModeView():void {
			// Переключение в режим MODE_VIEW
			if (BackLightable == true) BackLightable = false;
			if (ImageDragging == true) ImageDragging = false;
		}
//-----------------------------------------------------------------------------------------------------
		protected function SetModeDelete():void {
			// Переключение в режим MODE_DELETE
			BackLightable = true;
		}
//-----------------------------------------------------------------------------------------------------
		protected function SetModeModify():void {
			// Переключение в режим MODE_MODIFY
			
		}
//-----------------------------------------------------------------------------------------------------
		protected function SetModeMove():void {
			// Переключение в режим MODE_MOVE
			BackLightable = true;
			ImageDragging = true;
		}
//-----------------------------------------------------------------------------------------------------
		protected function SetModeAdd():void {
			// Переключение в режим MODE_Add
			BackLightable = true;
			ImageDragging = false;
		}
//-----------------------------------------------------------------------------------------------------
// Обработка событий
//-----------------------------------------------------------------------------------------------------
		protected function OnMouseDown(e:MouseEvent):void {
			// Нажатие курсора
			if (e.eventPhase == EventPhase.AT_TARGET) {
				if(lSpaceObjectImage.DragCont.Dragging==false) {
					lSpaceObjectImage.DragCont.MouseDown(e);	// Для контроля за drag
					// Изображение перечайлдить на звездную систему (чтобы не получало изменений координат от нескольких уровней родительских объектов)
					lSpaceObjectImage.NeedPlace = false;
					var CurrentPosition:Vector2 = lSpaceObjectImage.GetPosition();
					removeChild(lSpaceObjectImage);
					(root as Interplanety).addChildAt(lSpaceObjectImage,(root as Interplanety).numChildren);	// Наверх, иначе не получает MOUSE_UP, если зевести под другой объект
					lSpaceObjectImage.MoveInto(CurrentPosition);	// Т.к. при addChild встает в 0,0
					// Начать перетаскивание
					lSpaceObjectImage.startDrag();
				}
			}
		}
//-----------------------------------------------------------------------------------------------------
		protected function OnMouseUp(e:MouseEvent):void {
			// Отжатие курсора
			if (e.eventPhase == EventPhase.AT_TARGET) {
				if(lSpaceObjectImage.DragCont.Dragging==true) {
					// Создать сообщение об изменении положения
					var Data:Array = new Array();
					Data.push(Id);																	// Id текущего объекта
					Data.push(lSpaceObjectImage.GetPosition());										// Координаты
					var SubObject:SpaceObject = Interplanety.Universe.CurrentStarSystem.OverSpaceObject;	// Объект, на который сбросили
					if (SubObject != null) Data.push(SubObject.Id);
					else Data.push("null");
					dispatchEvent(new EventVn(InteractiveSpaceObjectV.PRIZE_MOVED, Data, true));
					// Сбросить перетаскивание
					lSpaceObjectImage.stopDrag();
					// Вернуть привязку изображения обратно к объекту
					lSpaceObjectImage.NeedPlace = true;
					(root as Interplanety).removeChild(lSpaceObjectImage);
					addChildAt(lSpaceObjectImage, 0);	// В самый низ (RePlace вызывается при добавлении автоматом)
					lSpaceObjectImage.DragCont.MouseUp(e);	// Для контроля за drag
				}
			}
		}
//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------
		public function set ImageDragging(vValue:Boolean):void {
			// Разрешение на перетаскивание картинки
			if (lImageDragging == vValue) return;
			switch (vValue) {
				case true: {
					AddMDEvent();
					break;
				}
				case false: {
					RemoveMDEvent();
					break;
				}
			}
			lImageDragging = vValue;
		}
//-----------------------------------------------------------------------------------------------------
		public function get ImageDragging():Boolean {
			return lImageDragging;
		}
//-----------------------------------------------------------------------------------------------------
		public function set StatCoordinates(vValue:Vector2):void {
			// Координаты местоположения (если стационарный объект)
			l_X = vValue.X;
			l_Y = vValue.Y;
		}
//-----------------------------------------------------------------------------------------------------
		public function set Mode(vValue:uint):void {
			// Режим объекта
			if (lMode == vValue) return;
			if (vValue != MODE_VIEW) Mode = MODE_VIEW;	// Сначала очистка (ставим стандартный режим) потом - выставить нужный режим
			switch(vValue) {
				case MODE_VIEW: {
					// Стандартный режим
					SetModeView();
					break;
				}
				case MODE_DELETE: {
					// Режим удаления объектов
					SetModeDelete();
					break;
				}
				case MODE_MODIFY: {
					// Режим изменения параметров объектов
					SetModeModify();
					break;
				}
				case MODE_MOVE: {
					// Режим перемещения объектов
					SetModeMove();
					break;
				}
				case MODE_ADD: {
					// Режим добавления других объектов в систему
					SetModeAdd();
					break;
				}
			}
			lMode = vValue;
		}
//-----------------------------------------------------------------------------------------------------
		public function get Mode():uint {
			return lMode;
		}
//-----------------------------------------------------------------------------------------------------
	}
}