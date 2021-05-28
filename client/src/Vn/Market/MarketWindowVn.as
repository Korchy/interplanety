package Vn.Market {
//-----------------------------------------------------------------------------------------------------
// Окно рынка
//-----------------------------------------------------------------------------------------------------
	import flash.events.Event;
	import Vn.Cargo.CargoVn;
	import Vn.Cargo.IUnitWithCargoVn;
	import Vn.Events.EventVn;
	import Vn.Industry.ISOCargoIndicator;
	import Vn.Interface.Edit.EditN;
	import Vn.Interface.List.ImageListSelect;
	import Vn.Interface.Window.VnWindowB;
	import Vn.Interplanety;
	import Vn.Math.Vector2;
	import Vn.Objects.Var.LoadedObject;
	import Vn.Objects.Var.ObjectViewVn;
	import Vn.Objects.VnObjectT;
	import Vn.Ships.Cargo.ShipCargoIndicator;
	import Vn.Ships.Cargo.ShipCargoListVn;
	import Vn.Ships.Modules.ShipModulesVolumeListVn;
	import Vn.Ships.Ship;
	import Vn.Ships.ShipsListVn;
	import Vn.SpaceObjects.SpaceObject;
	import Vn.Text.TextDictionary;
//-----------------------------------------------------------------------------------------------------
	public class MarketWindowVn extends VnWindowB {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		private var lPlanet:SpaceObject;	// Указатель на планету
		private var lISOCargoList:ISORCCargoListVn;	// Список производств на планете
		private var lShipsList:ShipsListVn;		// Список кораблей на планете
		private var lShipModulesVolumeList:ShipModulesVolumeListVn;	// Список типов модулей с их объемом на корабле
		private var lShipCargoList:ShipCargoListVn;	// Список грузов на выбранном корабле
		private var lDealCount:EditN;	// Количество покупаемого/продаваемого груза
		private var lBuyButton:BuyCargoButton;	// Кнопка покупки груза
		private var lSellButton:SellCargoButton;	// Кнопка продажи груза
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function MarketWindowVn(vPlanet:SpaceObject) {
			// Конструктор предка
			super();
			// Конструктор
			lPlanet = vPlanet;
			Name = 34;	// Рынок
			Caption.Text = TextDictionary.Text(lPlanet.Name)+" - "+TextDictionary.Text(Name);
			// Размеры 750 x 330
			SetLocalPosition(375.00, 170.00);
			// Список производств. Ширина - на два индикатора по 120
			lISOCargoList = new ISORCCargoListVn(new Vector2(304, Height - WorkSpace.Y));
			lISOCargoList.Load(lPlanet);
			addChild(lISOCargoList);
			lISOCargoList.MoveIntoParent(WorkSpace.X + lISOCargoList.Width05, WorkSpace.Y + WorkSpace.Height05, true);
			// Список кораблей на планете
			lShipsList = new ShipsListVn(new Vector2(304.00, 60 + 20));
			lShipsList.Load(lPlanet);
			addChild(lShipsList);
			lShipsList.MoveIntoParent(Width - WorkSpace.X - lShipsList.Width05, WorkSpace.Y + lShipsList.Height05);
			lShipsList.addEventListener(ImageListSelect.SELECTION_CHANGED, onShipSelection);
			// Список объемов модулей у выбранного корабля
			lShipModulesVolumeList = new ShipModulesVolumeListVn(new Vector2(304.00, 60 + 20));
			addChild(lShipModulesVolumeList);
			lShipModulesVolumeList.MoveIntoParent(Width - WorkSpace.X - lShipsList.Width05, WorkSpace.Y + lShipsList.Height + lShipModulesVolumeList.Height05);
			// Список грузов у выбранного корабля
			lShipCargoList = new ShipCargoListVn(new Vector2(304.00, Height - WorkSpace.Y - lShipModulesVolumeList.Height - lShipsList.Height));
			addChild(lShipCargoList);
			lShipCargoList.MoveIntoParent(Width - WorkSpace.X - lShipsList.Width05, WorkSpace.Y + lShipsList.Height + lShipModulesVolumeList.Height + lShipCargoList.Height05);
			// Выбрать первый корабль в списке
			lShipsList.SelectByNum(0);
			// Кнопки
			lDealCount = new EditN();
			addChild(lDealCount);
			lDealCount.Min = 0;
			lDealCount.MoveIntoParent(Width05, Height05);
			lISOCargoList.addEventListener(ImageListSelect.SELECTION_CHANGED, onISOCargoSelection);
			lShipCargoList.addEventListener(ImageListSelect.SELECTION_CHANGED, onShipCargoSelection);
			lBuyButton = new BuyCargoButton(lISOCargoList, lShipsList, lDealCount);
			addChild(lBuyButton);
			lBuyButton.MoveIntoParent(Width05, Height05 - lBuyButton.Height * 2);
			lBuyButton.addEventListener(LoadedObject.LOADED, onDealComplete);
			lSellButton = new SellCargoButton(lShipCargoList, lDealCount);
			addChild(lSellButton);
			lSellButton.MoveIntoParent(Width05, Height05 + lSellButton.Height * 2);
			lSellButton.addEventListener(LoadedObject.LOADED, onDealComplete);
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		override public function _delete():void {
			// Деструктор
			// Кнопки
			lSellButton.removeEventListener(LoadedObject.LOADED, onDealComplete);
			removeChild(lSellButton);
			lSellButton._delete();
			lSellButton = null;
			lBuyButton.removeEventListener(LoadedObject.LOADED, onDealComplete);
			removeChild(lBuyButton);
			lBuyButton._delete();
			lBuyButton = null;
			removeChild(lDealCount);
			lDealCount._delete();
			lDealCount = null;
			// Список производств
			lISOCargoList.removeEventListener(ImageListSelect.SELECTION_CHANGED, onISOCargoSelection);
			removeChild(lISOCargoList);
			lISOCargoList._delete();
			lISOCargoList = null;
			// Список кораблей
			lShipsList.removeEventListener(ImageListSelect.SELECTION_CHANGED, onShipSelection);
			removeChild(lShipsList);
			lShipsList._delete();
			lShipsList = null;
			// Список объемов модулей
			removeChild(lShipModulesVolumeList);
			lShipModulesVolumeList._delete();
			lShipModulesVolumeList = null;
			// Список грузов
			lShipCargoList.removeEventListener(ImageListSelect.SELECTION_CHANGED, onShipCargoSelection);
			removeChild(lShipCargoList);
			lShipCargoList._delete();
			lShipCargoList = null;
			// Деструктор предка
			super._delete();
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		override protected function GetPlace():Vector2 {
			// Местоположение по середине экрана на 5 пикс. от низа
//			return new Vector2(VnObjectT(parent).Width05, VnObjectT(parent).Height-Height05-5);
			// По центру экрана
			return new Vector2(VnObjectT(parent).Width05, VnObjectT(parent).Height05);
		}
//-----------------------------------------------------------------------------------------------------
// Обработка событий
//-----------------------------------------------------------------------------------------------------
		private function onShipSelection(e:Event):void {
			// Выбор корабля
			if (e.target.Selected != null) {
				// Выбран корабль
//				trace(e.target.Selected.Owner.Id);
				// Загрузить список объемов модулей
				lShipModulesVolumeList.Load(e.target.Selected.Owner);
				// Загрузить список грузов
				lShipCargoList.Load(e.target.Selected.Owner);
			}
			else {
				// Очистка выбора
				lShipModulesVolumeList.Clear();
				lShipCargoList.Clear();
				lISOCargoList.Selected = null;
			}
		}
//-----------------------------------------------------------------------------------------------------
		private function onISOCargoSelection(e:Event):void {
			// Выбор груза на планете
//			lShipCargoList.Selected = null;
			if (e.target.Selected != null && lShipsList.Selected != null) {
				// Занести в lDealCount максимальное возможное кол-во для покупки
				// Объем модуля такого же типа минус уже имеющееся кол-во груза такого же типа
				var selectedCargo:CargoVn = CargoVn(ISOCargoIndicator(ISORCCargoListVn(e.target).Selected).Owner);
				var CargoType:uint = selectedCargo.Type;
				var CargoVolume:uint = selectedCargo.Volume;
				var freeShipCargoVolume:uint = Ship(ObjectViewVn(lShipsList.Selected).Owner).freeCargoSpace(CargoType);
				if (CargoVolume < freeShipCargoVolume) lDealCount.Value = CargoVolume;
				else lDealCount.Value = freeShipCargoVolume;
				// Проверка, на какое кол-во хватит денег
				var cargoPrice:uint = selectedCargo.Price;
				var canBuyCargo:uint = Math.floor(Interplanety.VnUser.MoneyCount / cargoPrice);
				if (canBuyCargo < lDealCount.Value) lDealCount.Value = canBuyCargo;
			}
			else lDealCount.Value = 0;
		}
//-----------------------------------------------------------------------------------------------------
		private function onShipCargoSelection(e:Event):void {
			// Выбор груза на корабле
//			lISOCargoList.Selected = null;
			if (e.target.Selected != null) {
				// Занести в lDealCount полное кол-во выбранного груза
				lDealCount.Value = CargoVn(ShipCargoIndicator(ImageListSelect(e.target).Selected).Owner).Volume;
			}
			else lDealCount.Value = 0;
		}
//-----------------------------------------------------------------------------------------------------
		private function onDealComplete(e:EventVn):void {
			// Завершена операция покупки/продажи груза
			lISOCargoList.reLoad();
			lShipCargoList.reLoad();
			Interplanety.VnUser.RefreshGold();
		}
//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------
		public function get ISOCargoList():ISORCCargoListVn {
			// Список грузов на планете
			return lISOCargoList;
		}
//-----------------------------------------------------------------------------------------------------
		public function get shipCargoList():ShipCargoListVn {
			// Список грузов на корабле
			return lShipCargoList;
		}
//-----------------------------------------------------------------------------------------------------
		public function get buyCargoButton():BuyCargoButton {
			// Кнопка покупки груза
			return lBuyButton;
		}
//-----------------------------------------------------------------------------------------------------
		public function get sellCargoButton():SellCargoButton {
			// Кнопка продажи груза
			return lSellButton;
		}
//-----------------------------------------------------------------------------------------------------
	}
}