package Vn.SpaceObjects {
//-----------------------------------------------------------------------------------------------------
// Общий космический объект (звезды, планеты, станции) виртуальной звездной системы
//-----------------------------------------------------------------------------------------------------
	import flash.events.Event;
	import Vn.Interface.Window.VnWindow;
	import Vn.Interplanety;
	import Vn.Objects.VnObjectSA;
	import Vn.SpaceObjects.InteractiveSpaceObjectV;
	import Vn.Virtual.Bonus.BonusWindowVn;
//-----------------------------------------------------------------------------------------------------
	public class InteractiveSpaceObjectVC extends InteractiveSpaceObjectV {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		private static var lStaticInteractiveWindow:VnWindow = null;		// Статический указатель на интерактивное окно
		private static var lStaticInteractiveWindowCreator:InteractiveSpaceObjectVC = null;	// Статический указатель на объект, который создал интерактивное окно
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function InteractiveSpaceObjectVC() {
			// Конструктор предка
			super();
			// Конструктор
			// Т.к. данный класс служит контейнером для изображения - постоянные размеры 20х20
			SetLocalPosition(10.0,10.0);
			lSpaceObjectImage = new VnObjectSA();
			lSpaceObjectImage.NeedPlace = true;	// Картинку - по центру
			addChild(lSpaceObjectImage);
			// Интерактивное окно крепится к интерфейсу
			lInteractiveWindowSceneAttach = false;
			Interaction = true;
			}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		override public function _delete():void {
			// Деструктор
			// Удалить изображение. Если изобрежение в этот момент перетаскивалось - оно было addChild к корню
			if (DragCont.Dragging == true) (root as Interplanety).removeChild(lSpaceObjectImage); 
			else removeChild(lSpaceObjectImage);
			VnObjectSA(lSpaceObjectImage)._delete();
			// Если этот объект созздавал статическое окно - закрыть окно
			if (lStaticInteractiveWindowCreator == this) lStaticInteractiveWindow.Close();
			// Деструктор предка
			super._delete();
			}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		override public function LoadFromXML(Data:XML):void {
			// Заполнение данными из XML
			// Общие данные
			super.LoadFromXML(Data);
			// Конкретные данные
			VnObjectSA(lSpaceObjectImage).ReLoadById(uint(Data.child("img")));
		}
//-----------------------------------------------------------------------------------------------------
		override public function hitTestPoint(x:Number,y:Number,shapeFlag:Boolean=false):Boolean {
			// Переопределение hitTestPoint - проверка по картинке SOImg
			return VnObjectSA(lSpaceObjectImage).hitTestPoint(x, y, shapeFlag);
		}
//-----------------------------------------------------------------------------------------------------
		override protected function PlayAnimation():void {
			// Проигрыш анимации
			VnObjectSA(lSpaceObjectImage).PlayAnimation();
		}
//-----------------------------------------------------------------------------------------------------
		override protected function SetModeView():void {
			// Переключение в режим MODE_VIEW
			if (Interaction == false) Interaction = true;
			super.SetModeView();
		}
//-----------------------------------------------------------------------------------------------------
		override protected function SetModeDelete():void {
			// Переключение в режим MODE_DELETE
			Interaction = false;
			super.SetModeDelete();
		}
//-----------------------------------------------------------------------------------------------------
		override protected function SetModeModify():void {
			// Переключение в режим MODE_MODIFY
			Interaction = false;
			super.SetModeModify();
		}
//-----------------------------------------------------------------------------------------------------
		override protected function SetModeMove():void {
			// Переключение в режим MODE_MOVE
			Interaction = false;
			super.SetModeMove();
		}
//-----------------------------------------------------------------------------------------------------
		override protected function SetModeAdd():void {
			// Переключение в режим MODE_ADD
			Interaction = false;
			super.SetModeAdd();
		}
//-----------------------------------------------------------------------------------------------------
		override protected function CreateWindow():VnWindow {
			// Переопределяем создание окна так, чтобы оно было статическим для всех объектов
			// Если окно уже есть - закрыть
			if (lStaticInteractiveWindow != null) lStaticInteractiveWindow.Close();
			// Создать новое
			var NewWindow:VnWindow = new BonusWindowVn(this);
			lStaticInteractiveWindow = NewWindow;	// Статическое окно
			lStaticInteractiveWindowCreator = this;	// Создатель статического окна
			lStaticInteractiveWindow.addEventListener(VnWindow.CLOSED, OnStaticWindowClosed);
			return NewWindow;
		}
//-----------------------------------------------------------------------------------------------------
// Обработка событий
//-----------------------------------------------------------------------------------------------------
		private function OnStaticWindowClosed(e:Event):void {
			// При закрытии интерактивного окна
			e.target.removeEventListener(VnWindow.CLOSED, OnStaticWindowClosed);	// Через e.target т.к. в статическом указателе может быть уже другое окно
			if (e.target == this) {
				lStaticInteractiveWindow = null;
				lStaticInteractiveWindowCreator = null;
			}
		}
//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------
		
//-----------------------------------------------------------------------------------------------------
	}
}