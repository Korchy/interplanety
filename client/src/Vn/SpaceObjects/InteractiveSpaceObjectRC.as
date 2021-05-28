package Vn.SpaceObjects {
//-----------------------------------------------------------------------------------------------------
// Общий космический объект (звезды, планеты, станции) реальной звездной системы
//-----------------------------------------------------------------------------------------------------
	import Vn.Cargo.CargoManagerVn;
	import Vn.Cargo.IUnitWithCargoVn;
	import Vn.Objects.VnObjectSA;
	import Vn.SpaceObjects.InteractiveSpaceObjectR;
//-----------------------------------------------------------------------------------------------------
	public class InteractiveSpaceObjectRC extends InteractiveSpaceObjectR implements IUnitWithCargoVn {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		private var SpaceObjectLevel:uint	// Уровень с которого объект доступен для полетов
		private var lFlyEnable:Boolean;		// true - на этот объект возможен перелет, false - нет
		private var lImg20x20Id:uint;		// Id картинки 20x20
		private var lImg24x24Id:uint;		// Id картинки 25x25
		protected var Img30x30p:uint;		// Данные по картинке 30x30 (картинка для указания маршрута)
		private var lCargoManager:ISOCargoManagerVn;	// Менеджер грузов на объекте
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function InteractiveSpaceObjectRC() {
			// Конструктор предка
			super();
			// Конструктор
			lCargoManager = new ISOCargoManagerVn(this);
			// Т.к. данный класс служит контейнером для изображения - постоянные размеры 20х20
			SetLocalPosition(10.0,10.0);
			lSpaceObjectImage = new VnObjectSA();
			lSpaceObjectImage.NeedPlace = true;	// Картинку - по центру
			addChild(lSpaceObjectImage);
			Img30x30p = 0;
			lImg20x20Id = 0;
			lImg24x24Id = 0;
			lFlyEnable = false;
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		override public function _delete():void {
			// Деструктор
			removeChild(lSpaceObjectImage);
			VnObjectSA(lSpaceObjectImage)._delete();
			lSpaceObjectImage = null;
			lCargoManager._delete();
			lCargoManager = null;
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
			if (Data.child("level").length() > 0) Level = Number(Data.child("level"));
			if (Data.child("fly_enable").length() > 0 && Data.child("fly_enable") != "F") lFlyEnable = true;
			lImg20x20Id = uint(Data.child("img_20x20"));
			lImg24x24Id = uint(Data.child("img_24x24"));
			Img30x30p = uint(Data.child("img_30x30"));
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
		public function ArrivedText():String {
			// Текст при прибытии корабля на эту планету
			return "";
		}
//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------
		public function get Level():uint {	// Уровень
			return SpaceObjectLevel;
		}
//-----------------------------------------------------------------------------------------------------
		public function set Level(Value:uint):void {
			SpaceObjectLevel = Value;
		}
//-----------------------------------------------------------------------------------------------------
		public function get flyEnable():Boolean {	// Возможность перелета
			return lFlyEnable;
		}
//-----------------------------------------------------------------------------------------------------
		public function get img20x20Id():uint {
			return lImg20x20Id;
		}
//-----------------------------------------------------------------------------------------------------
		public function get img24x24Id():uint {
			return lImg24x24Id;
		}
//-----------------------------------------------------------------------------------------------------
		public function get Img30x30():uint {
			return Img30x30p;
		}
//-----------------------------------------------------------------------------------------------------
		public function get RealScaleK():uint {
			return l_RealScaleK;
		}
//-----------------------------------------------------------------------------------------------------
		public function get CargoManager():CargoManagerVn {
			return lCargoManager;
		}
//-----------------------------------------------------------------------------------------------------

	}
}