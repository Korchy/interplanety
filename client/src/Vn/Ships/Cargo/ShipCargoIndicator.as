package Vn.Ships.Cargo {
//-----------------------------------------------------------------------------------------------------
// Класс "Индикатор груза" - текущий груз в окне торговли
//-----------------------------------------------------------------------------------------------------
	import Vn.Cargo.CargoIndicatorVn;
	import Vn.Cargo.CargoVn;
	import Vn.Common.LoadStatusVn;
	import Vn.Events.EventVn;
	import Vn.Industry.Industry;
	import Vn.Interface.Text.VnTextI;
	import Vn.Interplanety;
	import Vn.Objects.Var.LoadedObject;
	import Vn.Objects.VnObjectS;
	import Vn.Ships.Ship;
	import Vn.SpaceObjects.InteractiveSpaceObjectRC;
	import Vn.SpaceObjects.ISOCargoManagerVn;
	import Vn.SpaceObjects.SpaceObject;
	import Vn.SpaceObjects.SpaceObjectManagerVn;
//-----------------------------------------------------------------------------------------------------
	public class ShipCargoIndicator extends CargoIndicatorVn {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		private var lSourcePlanetImg:VnObjectS;	// Картинка планеты, на которой был куплен груз
		private var lSourcePrice:VnTextI;		// Цена, за которую был куплен груз
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function ShipCargoIndicator(vOwner:Object) {
			// Конструктор предка
			super(vOwner);
			// Конструктор
			lSourcePlanetImg = null;
			lSourcePrice = null;
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		override public function _delete():void {
			// Деструктор
			if (Interplanety.Universe.SpaceObjectManager.hasEventListener(SpaceObjectManagerVn.SPACE_OBJECT_LOADED)) Interplanety.Universe.SpaceObjectManager.removeEventListener(SpaceObjectManagerVn.SPACE_OBJECT_LOADED, onCargoSourceSpaceObjectLoaded);
			if(Ship(ShipCargoVn(Owner).Owner).PlanetA.CargoManager.hasEventListener(LoadedObject.LOADED)) Ship(ShipCargoVn(Owner).Owner).PlanetA.CargoManager.removeEventListener(LoadedObject.LOADED, onPlanetCargoManagerLoaded);
			if(Ship(ShipCargoVn(Owner).Owner).PlanetA.CargoManager.hasEventListener(LoadedObject.FAIL)) Ship(ShipCargoVn(Owner).Owner).PlanetA.CargoManager.removeEventListener(LoadedObject.FAIL, onPlanetCargoManagerLoaded);
			if (lSourcePlanetImg != null) {
				removeChild(lSourcePlanetImg);
				lSourcePlanetImg._delete();
			}
			lSourcePlanetImg = null;
			if (lSourcePrice != null) {
				removeChild(lSourcePrice);
				lSourcePrice._delete();
			}
			lSourcePrice = null;
			// Деструктор предка
			super._delete();
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		override public function Fill(vIndustry:Industry):void {
			super.Fill(vIndustry);
			// Данные по конкретному грузу
			// Цена закупки
			lSourcePrice = new VnTextI(Width - lTypeImg.Width - 24, 20);	// Ширина - ширина картинки с типом груза - ширина картинки с планетой закупки груза
			lSourcePrice.ReLoadById(198);	// gold_red20x20
			lSourcePrice.Text = String(ShipCargoVn(Owner).SourcePrice);
//			lSourcePrice.Border = true;
			addChild(lSourcePrice);
			// Место закупки
			var cargoSourceSpaceObject:SpaceObject = SpaceObject(Interplanety.Universe.SpaceObjectManager.ById(ShipCargoVn(Owner).SourceId));
			// Т.к. место закупки может быть из другой звездной системы - контролировать загрузку
			if (cargoSourceSpaceObject.Loaded == false) {
				Interplanety.Universe.SpaceObjectManager.addEventListener(SpaceObjectManagerVn.SPACE_OBJECT_LOADED, onCargoSourceSpaceObjectLoaded);
			}
			else addSourcePlanet(InteractiveSpaceObjectRC(cargoSourceSpaceObject));
		}
//-----------------------------------------------------------------------------------------------------
		private function addSourcePlanet(vSourcePlanet:InteractiveSpaceObjectRC):void {
			// Добавление иконки планеты закупки груза
			lSourcePlanetImg = new VnObjectS();
			lSourcePlanetImg.ReLoadById(vSourcePlanet.img24x24Id);
			addChild(lSourcePlanetImg);
			lSourcePlanetImg.MoveIntoParent(lSourcePrice.Width + lSourcePlanetImg.Width05, lSourcePlanetImg.Height05);
		}
//-----------------------------------------------------------------------------------------------------
// Обработка событий
//-----------------------------------------------------------------------------------------------------
		private function onCargoSourceSpaceObjectLoaded(e:EventVn):void {
			// Контроль загрузки данных для места закупки груза
			if (SpaceObject(e.Data).Id == ShipCargoVn(Owner).SourceId) {
				Interplanety.Universe.SpaceObjectManager.removeEventListener(SpaceObjectManagerVn.SPACE_OBJECT_LOADED, onCargoSourceSpaceObjectLoaded);
				addSourcePlanet(InteractiveSpaceObjectRC(e.Data));
			}
		}
//-----------------------------------------------------------------------------------------------------
		private function onPlanetCargoManagerLoaded(e:EventVn):void {
			Ship(ShipCargoVn(Owner).Owner).PlanetA.CargoManager.removeEventListener(LoadedObject.LOADED, onPlanetCargoManagerLoaded);
			Ship(ShipCargoVn(Owner).Owner).PlanetA.CargoManager.removeEventListener(LoadedObject.FAIL, onPlanetCargoManagerLoaded);
			lSellPrice.Text = String(SellPrice);
		}
//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------
		override public function get SellPrice():uint {
			if (Ship(ShipCargoVn(Owner).Owner).PlanetA.CargoManager.Status != LoadStatusVn.LOADED) {
				// Еще не загрузился (но уже грузится т.к. загрузка должна быть вызвана для показа списка грузов на планете)
				Ship(ShipCargoVn(Owner).Owner).PlanetA.CargoManager.addEventListener(LoadedObject.LOADED, onPlanetCargoManagerLoaded);
				Ship(ShipCargoVn(Owner).Owner).PlanetA.CargoManager.addEventListener(LoadedObject.FAIL, onPlanetCargoManagerLoaded);
				return 0;
			}
			else {
				var cargoOnPlanet:CargoVn = CargoVn(ISOCargoManagerVn(Ship(ShipCargoVn(Owner).Owner).PlanetA.CargoManager).byIndustryId(ShipCargoVn(Owner).industryId));
				if (cargoOnPlanet != null) return cargoOnPlanet.Price;
				else return 0;
			}
		}
//-----------------------------------------------------------------------------------------------------
	}
}