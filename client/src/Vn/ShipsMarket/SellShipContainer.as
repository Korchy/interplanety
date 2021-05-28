package Vn.ShipsMarket {
	// Контейнер для продаваемого корабля
//-----------------------------------------------------------------------------------------------------
	import Vn.Math.Vector2;
	import Vn.Objects.Var.ObjectView;
	import Vn.Objects.VnObjectU;
	import Vn.Scene.StarSystem.StarSystemRealVn;
	import Vn.Ships.Ship;
	import Vn.Ships.ShipInfoButton;
	import Vn.Interplanety;
//-----------------------------------------------------------------------------------------------------
	public class SellShipContainer extends VnObjectU {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		private var Pict:ObjectView;			// Указатель на пиктограмму корабля
		private var SPrice:ShipPrice;			// Цена
		private var Info:ShipInfoButton;		// Кнопка "Информация о корабле"
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function SellShipContainer(ShipId:uint) {
			// Конструктор предка
			super();
			// Конструктор
			Id = ShipId;	// Id = Id корабля
			// Картинка 40 + инфо 20 + промежуток 2 х 40 + надпись внизу 14 + стрелка выбора 20
			SetLocalPosition(20+1+10,20+7);
			// Пиктограмма
			Pict = Ship(StarSystemRealVn(Vn.Interplanety.Universe.CurrentStarSystem).Ships.ById(ShipId)).CreateView();
			addChild(Pict);
			// Кнопка информации
			Info = new ShipInfoButton(Ship(StarSystemRealVn(Vn.Interplanety.Universe.CurrentStarSystem).Ships.ById(ShipId)));
			addChild(Info);
			Info.MoveIntoParent(52,10,true);
			// Цена
			SPrice = new ShipPrice(Width,ShipPrice.GOLD);	// Корабли продаются только за Gold
			SPrice.MoveInto(new Vector2(Width05,Pict.Height+SPrice.Height05));
			addChild(SPrice);
			// Переопределить размеры
			SetLocalPosition(Pict.Width05+1+Info.Width05,Pict.Height05+SPrice.height/2);
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		override public function _delete():void {
			// Деструктор
			// Цена
			removeChild(SPrice);
			SPrice._delete();
			SPrice = null;
			// Инфо
			removeChild(Info);
			Info._delete();
			Info = null;
			// Картинка
			removeChild(Pict);
			Pict._delete();
			Pict = null;
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
			Info.Update();
		}
//-----------------------------------------------------------------------------------------------------
// Обработка событий
//-----------------------------------------------------------------------------------------------------
		
//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------
		public function set Price(Value:uint):void {
			SPrice.Text = String(Value);
			SPrice.TextSize = 10;
		}
//-----------------------------------------------------------------------------------------------------
	}
}