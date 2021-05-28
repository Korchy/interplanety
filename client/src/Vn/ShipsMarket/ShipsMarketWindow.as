package Vn.ShipsMarket {
//-----------------------------------------------------------------------------------------------------
// Класс "Окно "Космосалон"
//-----------------------------------------------------------------------------------------------------
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.system.System;
	import Vn.Events.EventVn;
	import Vn.Math.Vector2;
	import Vn.Objects.Var.LoadedObject;
	import Vn.Scene.StarSystem.StarSystemRealVn;
	import Vn.System.PHPLoader;
	import Vn.Interface.Window.VnWindowB;
	import Vn.Interface.List.ImageListSelect;
	import Vn.Interface.List.ImageListSelectAB;
	import Vn.Text.TextDictionary;
	import Vn.Ships.Ship;
	import Vn.Interplanety;
//-----------------------------------------------------------------------------------------------------
	public class ShipsMarketWindow extends VnWindowB {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		private var MarketShpsLoader:PHPLoader;			// Загрузчик (для покупающихся кораблей)
		private var MarketShipsPage:ImageListSelect;	// Страничный компонент для списка продающихся кораблей
		private var UserShpsLoader:PHPLoader;			// Загрузчик (для продающихся кораблей)
		private var UserShipsPage:ImageListSelect;		// Странчиный компонент для кораблей пользователя
		private var BuyShipBtn:BuyShipButton;				// Кнопка покупки корабля
		private var SellShipBtn:SellShipButton;				// Кнопка продажи корабля
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function ShipsMarketWindow(PlanetId:uint = 0) {
			// Конструктор предка
			super();
			// Конструктор
			// Загрузка графики
			Name = 109;
			Caption.Text = TextDictionary.Text(Name);
			SetLocalPosition(200,110);
			// Получить список всех доступных для покупки кораблей
			MarketShpsLoader = new PHPLoader();
			MarketShpsLoader.addEventListener(Event.COMPLETE,OnMarketComplete);
			MarketShpsLoader.addEventListener(IOErrorEvent.IO_ERROR, OnMarketIoError);
			MarketShpsLoader.AddVariable("PlanetId", String(PlanetId));
			MarketShpsLoader.Load("getbuyingships.php");
			// Получить список кораблей пользователя (для продажи)
			UserShpsLoader = new PHPLoader();
			UserShpsLoader.addEventListener(Event.COMPLETE,OnUserComplete);
			UserShpsLoader.addEventListener(IOErrorEvent.IO_ERROR, OnUserIoError);
			UserShpsLoader.AddVariable("PlanetId", String(PlanetId));
			UserShpsLoader.Load("getsellingships.php");
			// Списки
			MarketShipsPage = new ImageListSelectAB(new Vector2(Width, 70));
			addChild(MarketShipsPage);
			MarketShipsPage.MoveIntoParent(Width05, MarketShipsPage.Height05 + WorkSpace.Y, true);
			UserShipsPage = new ImageListSelectAB(new Vector2(Width,80+10));
			addChild(UserShipsPage);
			UserShipsPage.MoveIntoParent(Width05,Height-UserShipsPage.Height05-2,true);	// На 2 pix от нижнего края (чтобы стрелка выбора не сливалась с краем)
			// Кнопки
			BuyShipBtn = new BuyShipButton(MarketShipsPage, PlanetId);
			addChild(BuyShipBtn);
			BuyShipBtn.addEventListener(LoadedObject.LOADED, BuyShip);
			BuyShipBtn.addEventListener(LoadedObject.FAIL, BuyShipF);
			SellShipBtn = new SellShipButton(UserShipsPage);
			addChild(SellShipBtn);
			SellShipBtn.addEventListener(LoadedObject.LOADED, SellShip);
			SellShipBtn.addEventListener(LoadedObject.FAIL, SellShipF);
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		override public function _delete():void {
			// Деструктор
			// Кнопки
			BuyShipBtn.removeEventListener(LoadedObject.LOADED, BuyShip);
			BuyShipBtn.removeEventListener(LoadedObject.FAIL, BuyShipF);
			removeChild(BuyShipBtn);
			BuyShipBtn._delete();
			BuyShipBtn = null;
			SellShipBtn.removeEventListener(LoadedObject.LOADED, SellShip);
			SellShipBtn.removeEventListener(LoadedObject.FAIL, SellShipF);
			removeChild(SellShipBtn);
			SellShipBtn._delete();
			SellShipBtn = null;
			// Загрузчики
			MarketShpsLoader.removeEventListener(Event.COMPLETE,OnMarketComplete);
			MarketShpsLoader.removeEventListener(IOErrorEvent.IO_ERROR,OnMarketIoError);
			MarketShpsLoader._delete();
			MarketShpsLoader = null;
			UserShpsLoader.removeEventListener(Event.COMPLETE,OnUserComplete);
			UserShpsLoader.removeEventListener(IOErrorEvent.IO_ERROR,OnUserIoError);
			UserShpsLoader._delete();
			UserShpsLoader = null;
			// Страничный компонент продающихся кораблей
			if(MarketShipsPage!=null) {
				if(MarketShipsPage.parent!=null) removeChild(MarketShipsPage);
				MarketShipsPage._delete();
				MarketShipsPage = null;
			}
			// Страничный компонент кораблей пользователя
			if(UserShipsPage!=null) {
				if(UserShipsPage.parent!=null) removeChild(UserShipsPage);
				UserShipsPage._delete();
				UserShipsPage = null;
			}
			// Деструктор предка
			super._delete();
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		override public function Update():void {
			// Обновление
			super.Update();
			// Обновить содержимое окна
			if (MarketShipsPage != null) MarketShipsPage.Update();
			if (UserShipsPage != null) UserShipsPage.Update();
		}
//-----------------------------------------------------------------------------------------------------
// Обработка событий
//-----------------------------------------------------------------------------------------------------
		private function OnMarketComplete(e:Event):void {
			// Данные по доступным для покупки кораблям загружены
			try {
				var IndData:XML = new XML(e.target.data);
			}
			catch(e1:Error) {
				trace(e.target.data);
			}
			// Создать набор индикаторов по полученному файлу
			for each (var Node:XML in IndData.*) {
				if (Node.nodeKind() == "element") {
					// Создать объект с данными по кораблю
					// За что покупаем корабль (золото или кристаллы)
					var PriceType:uint = ShipPrice.GOLD;
					if(Node.child("price_type")=="C")  PriceType = ShipPrice.CRYSTALS;
					// Создать индикатор цены
					var CurrentContainer:BuyShipContainer = new BuyShipContainer(uint(Node.attribute("id")), PriceType);
					// Загрузка данных в объект
					CurrentContainer.Pict.ReLoadById(uint(Node.child("img40x40")));
					CurrentContainer.Price = uint(Node.child("price"));
					// Добавить индикатор в окно
					MarketShipsPage.Add(CurrentContainer);
				}
			}
			System.disposeXML(IndData);
		}
//-----------------------------------------------------------------------------------------------------
		private function OnMarketIoError(e:Event):void {
			// Ошибка получения данных
		}
//-----------------------------------------------------------------------------------------------------
		private function OnUserComplete(e:Event):void {
			// Данные по доступным для покупки кораблям загружены
			try {
				var IndData:XML = new XML(e.target.data);
			}
			catch(e1:Error) {
				trace(e.target.data);
			}
			// Создать набор индикаторов по полученному файлу
			for each (var Node:XML in IndData.*) {
				if(Node.nodeKind()=="element") {
					// Создать объект с данными по кораблю
					var CurrentContainer:SellShipContainer = new SellShipContainer(uint(Node.attribute("id")));
					// Загрузка данных в объект
					CurrentContainer.Price = uint(Node.child("price"));
					// Добавить индикатор в окно
					UserShipsPage.Add(CurrentContainer);
				}
			}
			System.disposeXML(IndData);
		}
//-----------------------------------------------------------------------------------------------------
		private function OnUserIoError(e:Event):void {
			// Ошибка получения данных кораблей пользователя
		}
//-----------------------------------------------------------------------------------------------------
		private function BuyShip(e:EventVn):void {
			// Покупка корабля
			var NewUserShip:Ship = new Ship();
			NewUserShip.LoadFromXML(e.Data);
			// Добавить в список кораблей пользователя
			StarSystemRealVn(Vn.Interplanety.Universe.CurrentStarSystem).Ships.Add(NewUserShip);
			// Добавить в список индикаторов кораблей пользователя в окне космосалона
			var NewContainer:SellShipContainer = new SellShipContainer(NewUserShip.Id);
			NewContainer.Price = uint(e.Data.child("selling_price"));
			UserShipsPage.Add(NewContainer);
			// Изменить деньги/кристаллы
			Vn.Interplanety.VnUser.ChangeFinance(-uint(e.Data.child("price")),e.Data.child("price_type"));
		}
//-----------------------------------------------------------------------------------------------------
		private function BuyShipF(e:EventVn):void {
			// Ошибка покупки корабля
			Vn.Interplanety.Cons.Add(TextDictionary.Text(uint(e.Data)));
		}
//-----------------------------------------------------------------------------------------------------
		private function SellShip(e:EventVn):void {
			// Продажа корабля
			var ShipId:uint = uint(e.Data.attribute("Id"));
			// Удалить из списка кораблей пользователя
			StarSystemRealVn(Vn.Interplanety.Universe.CurrentStarSystem).Ships.Delete(ShipId);
			// Удалить из списка индикаторов кораблей пользователя в окне космосалона
			UserShipsPage.DeleteById(ShipId);
			// Изменить деньги (корабли продаются только за золото)
			Vn.Interplanety.VnUser.ChangeFinance(uint(e.Data.child("price")),"G");
		}
//-----------------------------------------------------------------------------------------------------
		private function SellShipF(e:EventVn):void {
			// Ошибка продажи корабля
			Vn.Interplanety.Cons.Add(TextDictionary.Text(uint(e.Data)));
		}
//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------

//-----------------------------------------------------------------------------------------------------
	}
}