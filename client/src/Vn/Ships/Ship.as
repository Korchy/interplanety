package Vn.Ships {
//-----------------------------------------------------------------------------------------------------
// Класс "Корабль"
//-----------------------------------------------------------------------------------------------------
	import flash.events.Event;
	import Vn.Cargo.CargoManagerVn;
	import Vn.Cargo.IUnitWithCargoVn;
	import Vn.List.ObjectsListLVn;
	import Vn.Math.Vector2;
	import Vn.Objects.Var.LoadedObject;
	import Vn.Objects.Var.ObjectView;
	import Vn.Objects.Var.ObjectViewVn;
	import Vn.Objects.VnObject;
	import Vn.Objects.VnObjectL;
	import Vn.Ships.Cargo.ShipCargoManagerVn;
	import Vn.Ships.Modules.ShipModulesManagerVn;
	import Vn.Ships.Routes.ShipRoute;
	import Vn.SpaceObjects.InteractiveSpaceObjectRC;
	import Vn.Synchronize.ServerTime;
	import Vn.Text.TextDictionary;
	import Vn.Interplanety;
//-----------------------------------------------------------------------------------------------------
	public class Ship extends VnObjectL implements IUnitWithCargoVn {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		// Изображения корабля различных размеров
		private var lModulesManager:ShipModulesManagerVn;	// Менеджер модулей корабля
		private var lCargoManager:ShipCargoManagerVn;		// Менеджер грузов корабля
		public var Img40x40:uint;	// 40x40
		public var Img200x150:uint;	// 200x150
		public var Img28x28:uint;	// 28x28
		private var USId:uint;		// Тип корабля (Id в vn_ship)
		private var l_PlanetA:InteractiveSpaceObjectRC;	// Планета старта
		private var l_PlanetB:InteractiveSpaceObjectRC;	// Планета назначения
		private var ATime:Number;	// Время старта с планеты A
		private var BTime:Number;	// Время прибытия на планету B
		private var ShipSpeed:Number;	// Скорость корабля (ед./сек)
		private var lShipVolume:uint;	// Объем свободного места на корабле
		private var VisualRoute:ShipRoute;	// Визуализация маршрута
		// Константы
		public static const s40x40:uint = 0;
		public static const s28x28:uint = 1;
		public static const s200x150:uint = 2;
		public static const VIEW_MARKET:uint = 0;
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function Ship() {
			// Конструктор родителя
			super();
			// Конструктор
			lModulesManager = new ShipModulesManagerVn();
			lCargoManager = new ShipCargoManagerVn(this);
			lShipVolume = 0;
			Img40x40 = 0;
			Img200x150 = 0;
			Img28x28 = 0;
			l_PlanetA = null;
			l_PlanetB = null;
			TimeA = 0;
			TimeB = 0;
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		override public function _delete():void {
			// Деструктор
			lModulesManager._delete();
			lModulesManager = null;
			lCargoManager._delete();
			lCargoManager = null;
			// Маршрут
			if(VisualRoute!=null) {
				DeleteVisualRoute();
			}
			lShipVolume = 0;
			// Деструктор родителя
			super._delete();
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		override public function LoadFromXML(Data:XML):void {
			// Заполнение данными из XML
			Id = uint(Data.attribute("id"));	// Id в vn_user_ships - регистрационный № корабля
			Name = uint(Data.child("name"));
			Speed = Number(Data.child("speed"));
			volume = uint(Data.child("volume"));
			Type = uint(Data.child("ship_id"));		// Тип корабля (id в vn_ships)
			l_PlanetA = InteractiveSpaceObjectRC(Vn.Interplanety.Universe.CurrentStarSystem.GetBySpaceObjectId(uint(Data.child("a_planet"))));
			l_PlanetB = InteractiveSpaceObjectRC(Vn.Interplanety.Universe.CurrentStarSystem.GetBySpaceObjectId(uint(Data.child("b_planet"))));
			TimeA = Number(Data.child("a_time"));
			TimeB = Number(Data.child("b_time"));
			Img40x40 = uint(Data.child("img40x40"));
			Img200x150 = uint(Data.child("img200x150"));
			Img28x28 = uint(Data.child("img28x28"));
			// Загрузить модули
			lModulesManager.ShipId = Id;
			lModulesManager.addEventListener(LoadedObject.LOADED, OnModulesLoaded);
			lModulesManager.addEventListener(LoadedObject.FAIL, OnModulesIoError);
			lModulesManager.Load();
			// Загрузить данные по грузу
			lCargoManager.addEventListener(LoadedObject.LOADED, OnCargoLoaded);
			lCargoManager.addEventListener(LoadedObject.FAIL, OnCargoIoError);
//			lCargoManager.Load();	// Нужно ли загружать грузы для кораблей при первой общей загрузке - ?
			// После загрузки всех данных
			if(l_PlanetA!=l_PlanetB) CreateVisualRoute();	// Если в пути - создать визуальный маршрут
		}
//-----------------------------------------------------------------------------------------------------
		public function CreateVisualRoute():void {
			// Создание визуализации маршрута
			VisualRoute = new ShipRoute(this);
			Vn.Interplanety.Universe.CurrentStarSystem.Add(VnObject(VisualRoute));
//trace(VisualRoute.Pict.GetPosition());
//trace(VisualRoute.GetPosition());
			Vn.Interplanety.Universe.CurrentStarSystem.addChildAt(VisualRoute,Vn.Interplanety.Universe.CurrentStarSystem.GetMaxObjectsZIndex()+1);
//			VisualRoute.MoveInto(new Vector2(0,0));	// Переместить в 0,0 чтобы аннулировать влияние матрицы сцены
//trace(VisualRoute.Pict.GetPosition());
//trace(VisualRoute.GetPosition());
		}
//-----------------------------------------------------------------------------------------------------
		public function DeleteVisualRoute():void {
			// Удаление визуализации маршрута
			Vn.Interplanety.Universe.CurrentStarSystem.Remove(VnObject(VisualRoute));
			VisualRoute._delete();
			VisualRoute = null;
		}
//-----------------------------------------------------------------------------------------------------
		public function CreateView(Size:uint=s40x40):ObjectView {
			// Создание визуального представления объекта
			var View:ObjectView = new ObjectView(this);
			// Размер видового изображения
			var SourceImgInfo:uint;
			switch(Size) {
				case s40x40:
					SourceImgInfo = Img40x40;
					break;
				case s200x150:
					SourceImgInfo = Img200x150;
					break;
				case s28x28:
					SourceImgInfo = Img28x28;
					break;
			}
			View.TextPlace = true;
			View.Text = TextDictionary.Text(77)+" "+String(Id);
			View.ReLoadById(SourceImgInfo);
			return View;
		}
//-----------------------------------------------------------------------------------------------------
		public function CreateOView(vType:uint):ObjectViewVn {
			// Создание визуального представления объекта - от CreateView постепенно отказаться
			switch(vType) {
				case VIEW_MARKET: {
					// Для рынка
					var CurrentView:ObjectViewVn = new ObjectViewVn(this, 60.0, 60.0);
					CurrentView.SetImage(Img40x40);
					CurrentView.Text = TextDictionary.Text(77)+" "+String(Id);
					CurrentView.TextPlace = ObjectViewVn.MB;
					return CurrentView;
					break;
				}
			}
			return null;
		}
//-----------------------------------------------------------------------------------------------------
		public function freeCargoSpace(vCargoType:uint):uint {
			// Возврат свободного места под определенный тип груза
			var freeSpace:uint = 0;
			var cargoTypedSpace:uint = ModulesManager.cargoSpace(vCargoType);	// Объем места под тип груза vCargoType
			var cargoUniversalSpace:uint = ModulesManager.cargoSpace(1);		// Объем универсальных танков
			if (cargoTypedSpace + cargoUniversalSpace == 0) return 0;
			var cargoCount:uint = CargoManager.cargoCount(vCargoType);	// Объем имеющегося груза vCargoType
//			// Свободного места в модулях типа vCargoType
			if (cargoCount < cargoTypedSpace) freeSpace = cargoTypedSpace - cargoCount;
			else cargoCount -= cargoTypedSpace;	// В cargoCount остается только груз, лежащий в универсальных танках
			// Cвободного места в универсальных модулях
			var freeCargoUniversalSpace:uint = cargoUniversalSpace;
			for each(var currentCargoInfo:Array in CargoManager.cargoByTypes()) {
				var currentCargoTypedSpace:uint = ModulesManager.cargoSpace(currentCargoInfo[0]);
				var currentCargo:uint = currentCargoInfo[1];
				if (currentCargo > currentCargoTypedSpace) freeCargoUniversalSpace -= currentCargo - currentCargoTypedSpace;
			}
			freeSpace += freeCargoUniversalSpace;
			return freeSpace;
		}
//-----------------------------------------------------------------------------------------------------
// Обработка событий
//-----------------------------------------------------------------------------------------------------
		private function OnModulesLoaded(e:Event):void {
			// Данные по модулям загружены
			lModulesManager.removeEventListener(LoadedObject.LOADED, OnModulesLoaded);
			lModulesManager.removeEventListener(LoadedObject.FAIL, OnModulesIoError);
		}
//-----------------------------------------------------------------------------------------------------
		private function OnModulesIoError(e:Event):void {
			// Ошибка при загрузке данных по модулю
			lModulesManager.removeEventListener(LoadedObject.LOADED, OnModulesLoaded);
			lModulesManager.removeEventListener(LoadedObject.FAIL, OnModulesIoError);
			// Message
			Vn.Interplanety.Cons.Add(TextDictionary.Text(11)+"№ "+String(Id));	// Ошибка загрузки модулей корабля
		}
//-----------------------------------------------------------------------------------------------------
		private function OnCargoLoaded(e:Event):void {
			// Данные по грузам загружены
			lCargoManager.removeEventListener(LoadedObject.LOADED, OnCargoLoaded);
			lCargoManager.removeEventListener(LoadedObject.FAIL, OnCargoIoError);
		}
//-----------------------------------------------------------------------------------------------------
		private function OnCargoIoError(e:Event):void {
			// Ошибка при загрузке данных по грузам
			lCargoManager.removeEventListener(LoadedObject.LOADED, OnCargoLoaded);
			lCargoManager.removeEventListener(LoadedObject.FAIL, OnCargoIoError);
			// Message
			Vn.Interplanety.Cons.Add(TextDictionary.Text(90)+"№ "+String(Id));	// Ошибка загрузки грузов корабля
		}
//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------
		public function get PlanetA():InteractiveSpaceObjectRC {
			return l_PlanetA;
		}
//-----------------------------------------------------------------------------------------------------
		public function set PlanetA(Value:InteractiveSpaceObjectRC):void {
			l_PlanetA = Value;
		}
//-----------------------------------------------------------------------------------------------------
		public function get PlanetB():InteractiveSpaceObjectRC {
			return l_PlanetB;
		}
//-----------------------------------------------------------------------------------------------------
		public function set PlanetB(Value:InteractiveSpaceObjectRC):void {
			l_PlanetB = Value;
		}
//-----------------------------------------------------------------------------------------------------
		public function get TimeA():Number {
			return ATime;
		}
//-----------------------------------------------------------------------------------------------------
		public function set TimeA(Value:Number):void {
			ATime = Value;
		}
//-----------------------------------------------------------------------------------------------------
		public function get TimeB():Number {
			return BTime;
		}
//-----------------------------------------------------------------------------------------------------
		public function set TimeB(Value:Number):void {
			BTime = Value;
		}
//-----------------------------------------------------------------------------------------------------
		public function get volume():uint {
			return lShipVolume;
		}
//-----------------------------------------------------------------------------------------------------
		public function set volume(Value:uint):void {
			lShipVolume = Value;
		}
//-----------------------------------------------------------------------------------------------------
		public function get Speed():Number {
			return ShipSpeed;
		}
//-----------------------------------------------------------------------------------------------------
		public function set Speed(Value:Number):void {
			ShipSpeed = Value;
		}
//-----------------------------------------------------------------------------------------------------
		public function get Type():uint {
			return USId;
		}
//-----------------------------------------------------------------------------------------------------
		public function set Type(Value:uint):void {
			USId = Value;
		}
//-----------------------------------------------------------------------------------------------------
		public function get RegNo():uint {
			return Id;
		}
//-----------------------------------------------------------------------------------------------------
		public function get VRoute():ShipRoute {
			return VisualRoute;
		}
//-----------------------------------------------------------------------------------------------------
		public function get FlyingProc():Number {
			// Проценты полета корабля от общего времени полета
			var TN:Number = ServerTime.Time-TimeA;	// Текущее - старт = сколько прошло с момента старта
			var Proc:Number = TN*100/(TimeB-TimeA);
			if(Proc<10) Proc = 10;
			if (Proc > 90) Proc = 90;
			return Proc;
		}
//-----------------------------------------------------------------------------------------------------
		public function get ModulesManager():ShipModulesManagerVn {
			return lModulesManager;
		}
//-----------------------------------------------------------------------------------------------------
		public function get CargoManager():CargoManagerVn {
			return lCargoManager;
		}
//-----------------------------------------------------------------------------------------------------
	}
}