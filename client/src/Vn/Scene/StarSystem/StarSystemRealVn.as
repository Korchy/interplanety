package Vn.Scene.StarSystem 
{
//-----------------------------------------------------------------------------------------------------
// Класс "Реальная звездная система"
//-----------------------------------------------------------------------------------------------------
	import flash.events.Event;
	import Vn.Events.EventVn;
	import Vn.Industry.IndustryManagerVn;
	import Vn.List.ObjectsListLVn;
	import Vn.Market.MarketVn;
	import Vn.Market.Events.EvCargoTrade;
	import Vn.Objects.Var.LoadedObject;
	import Vn.Ships.ShipsManager;
	import Vn.Ships.Routes.Events.EvRouteFinish;
	import Vn.SpaceObjects.InteractiveSpaceObjectRC;
	import Vn.SpaceObjects.SpaceObject;
	import Vn.SpaceObjects.SpaceObjectManagerVn;
	import Vn.Interplanety;
//-----------------------------------------------------------------------------------------------------
	public class StarSystemRealVn extends StarSystemVn {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		private var EnableObjectsList:Array;	// Массив объектов, доступных для полетов
		public var Ships:ShipsManager;		// Корабли
		public var Market:MarketVn;			// Рынок
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function StarSystemRealVn() {
			// Конструктор родителя
			super();
			// Конструктор
			Id = 1;	// По-умолчанию - Солнечная система
			Name = 28;	// "Солнечная система"
			EnableObjectsList = new Array(0);
			l_LoadScript = "getstarsystem.php";
			Ships = new ShipsManager();		// ShipsManager
			Market = new MarketVn();		// Market
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		override public function _delete():void {
			// Деструктор
			Clear();
			Market._delete();	// Market
			Market = null;
			Ships._delete();	// ShipsManager
			Ships = null;
			EnableObjectsList = null;
			// Деструктор родителя
			super._delete();
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		override public function Clear():void {
			// Очистка системы
//			// По всем SpaceObject из списка проверить, чтобы закрылись окна, если они были открыты
//			// По хорошему надо сделать контроль через SceneInterface. Пока работает закрытие при удалении SpaceObject-ов
//			for (var i:uint = 0; i < ObjectList.length; i++) {
//				if (ObjectList[i] is InteractiveSpaceObjectRC && InteractiveSpaceObjectRC(ObjectList[i]).InteractiveWindow != null) InteractiveSpaceObjectRC(ObjectList[i]).InteractiveWindow.Close();
//			}
			// ShipsManager
			if (Ships != null) {
				if (Ships.hasEventListener(LoadedObject.LOADED)) Ships.removeEventListener(LoadedObject.LOADED, OnShipsLoaded);
				if (Ships.hasEventListener(LoadedObject.FAIL)) Ships.removeEventListener(LoadedObject.FAIL, OnShipsIoError);
//				Vn.Interplanety.Universe.QuestsManager.RemoveEventToListen(Ships,EvRouteFinish.ROUTE_FINISH);	// Убрать из квестов прослушку событий
//				Ships.Clear();
			}
			// Industry
			if (Interplanety.Universe.IndustryManager.hasEventListener(LoadedObject.LOADED)) Interplanety.Universe.IndustryManager.removeEventListener(LoadedObject.LOADED, OnIndustryLoaded);
			if (Interplanety.Universe.IndustryManager.hasEventListener(LoadedObject.FAIL)) Interplanety.Universe.IndustryManager.removeEventListener(LoadedObject.FAIL, OnIndustryIoError);
			// Market
			Vn.Interplanety.Universe.QuestsManager.RemoveEventToListen(Market,EvCargoTrade.BUY);	// Убрать из квестов прослушку событий
			Vn.Interplanety.Universe.QuestsManager.RemoveEventToListen(Market, EvCargoTrade.SELL);
			if (Market != null) {
				Market.Clear();
			}
			// SpaceoObjectManager
			if (Interplanety.Universe.SpaceObjectManager.hasEventListener(SpaceObjectManagerVn.STAR_SYSTEM_LOADED)) Interplanety.Universe.SpaceObjectManager.removeEventListener(SpaceObjectManagerVn.STAR_SYSTEM_LOADED, OnComplete);
			if (Interplanety.Universe.SpaceObjectManager.hasEventListener(LoadedObject.FAIL)) Interplanety.Universe.SpaceObjectManager.removeEventListener(LoadedObject.FAIL, OnFail);
			// Очистить список доступных для полета объектов
			if (EnableObjectsList != null) {
				while (EnableObjectsList.length > 0) {
					EnableObjectsList.splice(0, 1);
				}
			}
			// Очистка общего списка
			if (ObjectList != null) {
				while (ObjectList.length > 0) {
					if (ObjectList[0].parent == this) removeChild(ObjectList[0]);
					ObjectList.splice(0, 1);
				}
			}
			super.Clear();
		}
//-----------------------------------------------------------------------------------------------------
		override public function Load(NewStarSystemId:uint):void {
			// Загрузка реальной звездной системы - через SpaceObjectManager
			Id = NewStarSystemId;
			Interplanety.Universe.SpaceObjectManager.addEventListener(SpaceObjectManagerVn.STAR_SYSTEM_LOADED, OnComplete);
			Interplanety.Universe.SpaceObjectManager.addEventListener(LoadedObject.FAIL, OnFail);
			Interplanety.Universe.SpaceObjectManager.LoadFromStarSystem(Id);
		}
//-----------------------------------------------------------------------------------------------------
		private function createFromSOManager():void {
			// Создание системы из объектов, хранящихся в SpaceObjectManager
			for each(var currentSpaceObject:SpaceObject in Interplanety.Universe.SpaceObjectManager.All) {
				if (currentSpaceObject.StarSystemId == Id) {
					Add(currentSpaceObject);
					if (currentSpaceObject is InteractiveSpaceObjectRC && InteractiveSpaceObjectRC(currentSpaceObject).flyEnable == true) FlyEnableObject(InteractiveSpaceObjectRC(currentSpaceObject));
					if (currentSpaceObject.Trace == null) {
						addChild(currentSpaceObject);
						currentSpaceObject.MoveIntoParent(currentSpaceObject.StatCoordinates.X, currentSpaceObject.StatCoordinates.Y, true);
					}
				}
			}
			Update();	// Стартовый update для начальной расстановки объектов по местам
		}
//-----------------------------------------------------------------------------------------------------
		override protected function FlyEnableObject(SObj:InteractiveSpaceObjectRC):void {
			// Указание на то, что SObj доступен для полетов
			EnableObjectsList.push(SObj);
		}
//-----------------------------------------------------------------------------------------------------
// Обработка событий
//-----------------------------------------------------------------------------------------------------
		override protected function OnComplete(e:Event):void {
			// Данные по сектору загружены
			Interplanety.Universe.SpaceObjectManager.removeEventListener(SpaceObjectManagerVn.STAR_SYSTEM_LOADED, OnComplete);
			Interplanety.Universe.SpaceObjectManager.removeEventListener(LoadedObject.FAIL, OnFail);
			createFromSOManager();
			// После загрузки системы последовательно грузим корабли, производства
			// Загрузить корабли
			Ships.addEventListener(LoadedObject.LOADED,OnShipsLoaded);
			Ships.addEventListener(LoadedObject.FAIL,OnShipsIoError);
			Ships.Script = "getships.php";
			Ships.Load();
		}
//-----------------------------------------------------------------------------------------------------
		private function OnFail(e:Event):void {
			// Ошибка загрузки данных по сектору
			Interplanety.Universe.SpaceObjectManager.removeEventListener(SpaceObjectManagerVn.STAR_SYSTEM_LOADED, OnComplete);
			Interplanety.Universe.SpaceObjectManager.removeEventListener(LoadedObject.FAIL, OnFail);
			Clear();
			dispatchEvent(new Event(StarSystemVn.FAIL));
		}
//-----------------------------------------------------------------------------------------------------
		private function OnShipsLoaded(e:Event):void {
			// Корабли загружены
			Ships.removeEventListener(LoadedObject.LOADED,OnShipsLoaded);
			Ships.removeEventListener(LoadedObject.FAIL,OnShipsIoError);
			// Слушаем в квестах его события
			Vn.Interplanety.Universe.QuestsManager.AddEventToListen(Ships,EvRouteFinish.ROUTE_FINISH);
			// Загрузка данных по производствам
			Interplanety.Universe.IndustryManager.addEventListener(LoadedObject.LOADED, OnIndustryLoaded);
			Interplanety.Universe.IndustryManager.addEventListener(LoadedObject.FAIL, OnIndustryIoError);
			Interplanety.Universe.IndustryManager.LoadIndustries(Id);
		}
//-----------------------------------------------------------------------------------------------------
		private function OnShipsIoError(e:Event):void {
			// Ошибка при загрузке кораблей
			Ships.removeEventListener(LoadedObject.LOADED,OnShipsLoaded);
			Ships.removeEventListener(LoadedObject.FAIL,OnShipsIoError);
			// Сектор на загрузился
			_delete();
			dispatchEvent(new Event(StarSystemVn.FAIL));
		}
//-----------------------------------------------------------------------------------------------------
		private function OnIndustryLoaded(e:Event):void {
			// Промышленность загружена
			Interplanety.Universe.IndustryManager.removeEventListener(LoadedObject.LOADED, OnIndustryLoaded);
			Interplanety.Universe.IndustryManager.removeEventListener(LoadedObject.FAIL, OnIndustryIoError);
			// Слушаем в квестах события рынка
			Vn.Interplanety.Universe.QuestsManager.AddEventToListen(Market,EvCargoTrade.BUY);
			Vn.Interplanety.Universe.QuestsManager.AddEventToListen(Market,EvCargoTrade.SELL);
			// Вся звездная система загружена
			dispatchEvent(new Event(StarSystemVn.LOADED));
		}
//-----------------------------------------------------------------------------------------------------
		private function OnIndustryIoError(e:Event):void {
			// Ошибка при загрузке производств
			Interplanety.Universe.IndustryManager.removeEventListener(LoadedObject.LOADED, OnIndustryLoaded);
			Interplanety.Universe.IndustryManager.removeEventListener(LoadedObject.FAIL, OnIndustryIoError);
			// Сектор на загрузился
			_delete();
			dispatchEvent(new Event(StarSystemVn.FAIL));
		}
//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------
		public function get FlyEnable():Array {
			return EnableObjectsList;
		}
//-----------------------------------------------------------------------------------------------------
	}
}