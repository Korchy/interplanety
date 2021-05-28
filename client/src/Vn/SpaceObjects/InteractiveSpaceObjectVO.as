package Vn.SpaceObjects {
//-----------------------------------------------------------------------------------------------------
// Виртуальный космический объект
//-----------------------------------------------------------------------------------------------------
	import flash.events.MouseEvent;
	import Vn.Math.Vector2;
	import Vn.SpaceObjects.Orbit.OrbitFuncVn;
	import Vn.SpaceObjects.Orbit.OrbitImage;
	import Vn.Interplanety;
	import Vn.SpaceObjects.Orbit.OrbitImageContainer;
//-----------------------------------------------------------------------------------------------------
	public class InteractiveSpaceObjectVO extends InteractiveSpaceObjectV {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		private var OrbitFunc:OrbitFuncVn;	// Функционал орбиты
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function InteractiveSpaceObjectVO() {
			// Конструктор предка
			super();
			// Конструктор
			// Т.к. данный класс служит контейнером для изображения - постоянные размеры 10х10
			SetLocalPosition(100.0,100.0);
			// Изображение для орбиты
			lSpaceObjectImage = new OrbitImageContainer();
			addChild(lSpaceObjectImage);
			// Функционал орбиты
			OrbitFunc = new OrbitFuncVn();
			}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		override public function _delete():void {
			// Деструктор
			OrbitFunc._delete();
			OrbitFunc = null;
			// Удалить изображение. Если изобрежение в этот момент перетаскивалось - оно было sddChild к звездной системе
			if (DragCont.Dragging == true) (root as Interplanety).removeChild(lSpaceObjectImage);
			else removeChild(lSpaceObjectImage);
			OrbitImageContainer(lSpaceObjectImage)._delete();
			// Деструктор предка
			super._delete();
			}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		public function SetRadius(NewL:Number,NewS:Number):void {
			// Установить новые радиусы эллипса
			if(NewL>=0.0&&NewS>=0.0) {
				OrbitFunc.SetRadius(NewL, NewS);
				OrbitImageContainer(lSpaceObjectImage).SetRadius(NewL, NewS);
			}
		}
//-----------------------------------------------------------------------------------------------------
		public function SetAngle(NewA:Number):void {
			// Установить новый угол наклона эллипса
			OrbitFunc.SetAngle(NewA);
			OrbitImageContainer(lSpaceObjectImage).SetAngle(NewA);
		}
//-----------------------------------------------------------------------------------------------------
		public function SetSpeed(NewS:Number):void {
			// Установить новую скорость движения по эллипсу
			OrbitFunc.SetSpeed(NewS);
		}
//-----------------------------------------------------------------------------------------------------
		override public function CountPos(Time:Number):Vector2 {
			// Вычислить положение объекта на орбите в момент времени Time (мс)
			return OrbitFunc.CountPos(this, Time);
		}
//-----------------------------------------------------------------------------------------------------
		override public function LoadFromXML(Data:XML):void {
			// Заполнение данными из XML
			// Общие данные
			super.LoadFromXML(Data);
			// Конкретные данные
			SetRadius(Data.child("radius_l"),Data.child("radius_s"));
			SetSpeed(Data.child("speed"));
			if(Data.child("angle")!=0) SetAngle(Data.child("angle"));
		}
//-----------------------------------------------------------------------------------------------------
		override public function Redraw():void {
			// Перерисовка объекта
			lSpaceObjectImage.Redraw();
		}
//-----------------------------------------------------------------------------------------------------
		override protected function AddMDEvent():void {
			// Включить перетаскивание
			OrbitImageContainer(lSpaceObjectImage).Image.addEventListener(MouseEvent.MOUSE_DOWN, OnMouseDown);
			OrbitImageContainer(lSpaceObjectImage).Image.addEventListener(MouseEvent.MOUSE_UP, OnMouseUp);	// К stage чтобы MOUSE_UP отрабатывало для всех объектов (нужно в ситуации, когда перетаскиваемый объект заведено под другой и не получил впрямую MOUSE_UP)
		}
//-----------------------------------------------------------------------------------------------------
		override protected function RemoveMDEvent():void {
			// Выключить перетаскивание
			if (OrbitImageContainer(lSpaceObjectImage).Image != null) {
				OrbitImageContainer(lSpaceObjectImage).Image.removeEventListener(MouseEvent.MOUSE_DOWN, OnMouseDown);
				OrbitImageContainer(lSpaceObjectImage).Image.removeEventListener(MouseEvent.MOUSE_UP, OnMouseUp);
			}
		}
//-----------------------------------------------------------------------------------------------------
		override protected function SetModeView():void {
			// Переключение в режим MODE_VIEW
			if (BackLightable == true) BackLightable = false;
			if (Interaction == true) Interaction = false;
			if (ImageDragging == true) ImageDragging = false;
		}
//-----------------------------------------------------------------------------------------------------
		override protected function SetModeModify():void {
			// Переключение в режим MODE_MODIFY
			BackLightable = true;
			Interaction = true;
		}
//-----------------------------------------------------------------------------------------------------
// Обработка событий
//-----------------------------------------------------------------------------------------------------
		
//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------
		public function get RadiusAverage():Number {
			return OrbitFunc.RadiusAverage;
		}
//-----------------------------------------------------------------------------------------------------
		public function get RadiusL():Number {
			// Большой радиус
			return OrbitFunc.RadiusL;
		}
//-----------------------------------------------------------------------------------------------------
		public function get RadiusS():Number {
			// Малый радиус
			return OrbitFunc.RadiusS;
		}
//-----------------------------------------------------------------------------------------------------
		public function get Angle():Number {
			// Угол наклона
			return OrbitFunc.Angle;
		}
//-----------------------------------------------------------------------------------------------------
		public function get Speed():Number {
			// Скорость движения по орбите
			return OrbitFunc.Speed;
		}
//-----------------------------------------------------------------------------------------------------
	}
}