package Vn.Ships.Cargo {
//-----------------------------------------------------------------------------------------------------
// Груз на корабле
//-----------------------------------------------------------------------------------------------------
	import Vn.Cargo.CargoVn;
//-----------------------------------------------------------------------------------------------------
	public class ShipCargoVn extends CargoVn{
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		private var lSource:uint;		// Id места, где груз был куплен (vn_user_ships_cargo.cargo_source = vn_spaceobject.id)
		private var lSourcePrice:uint;	// Цена, за которую груз был куплен (vn_user_ships_cargo.cargo_price)
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function ShipCargoVn(vOwner:Object = null) {
			// Конструктор родителя
			super(vOwner);
			// Конструктор
			SourceId = 0;
			SourcePrice = 0;
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		override public function _delete():void {
			// Деструктор
			
			// Деструктор родителя
			super._delete();
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		
//-----------------------------------------------------------------------------------------------------
// Обработка событий
//-----------------------------------------------------------------------------------------------------

//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------
		public function get SourceId():uint {
			return lSource;
		}
//-----------------------------------------------------------------------------------------------------
		public function set SourceId(Value:uint):void {
			lSource = Value;
		}
//-----------------------------------------------------------------------------------------------------
		public function get SourcePrice():uint {
			return lSourcePrice;
		}
//-----------------------------------------------------------------------------------------------------
		public function set SourcePrice(Value:uint):void {
			lSourcePrice = Value;
		}
//-----------------------------------------------------------------------------------------------------
	}
}