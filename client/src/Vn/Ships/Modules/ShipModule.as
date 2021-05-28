package Vn.Ships.Modules {
//-----------------------------------------------------------------------------------------------------
// Модуль корабля
//-----------------------------------------------------------------------------------------------------

//-----------------------------------------------------------------------------------------------------
	public class ShipModule {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		private var lId:uint;			// Id
		private var lType:uint;		// Тип модуля
		private var lImg30x30Id:uint;	// Id картинки типа модуля
		private var lMount:Boolean;		// false - постоянный, true - сменный
		private var lValue:uint;		// Объем модуля в кг.
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function ShipModule() {
			// Конструктор родителя
			
			// Конструктор
			lId = 0;
			lType = 0;
			lImg30x30Id = 0;
			lMount = false;
			lValue = 0;
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		public function _delete():void {
			// Деструктор
			
			// Деструктор родителя
//			super._delete();
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		public function LoadFromXML(Node:XML):void {
			// Загрузка из XML
			if (Node.nodeKind() == "element") {
				Id = uint(Node.attribute("id"));
				Type = uint(Node.child("type_id"));
				if (Node.child("mount") == "C") Mount = false;
				else Mount = true;
				Value = uint(Node.child("value"));
				Img30x30Id = uint(Node.child("img30x30"));
			}
		}
//-----------------------------------------------------------------------------------------------------
		public function GetModuleIndicator():ShipModuleIndicator {
			// Переопределяется в наследниках
			var CurrentIndicator:ShipModuleIndicator = new ShipModuleIndicator(this, Img30x30Id, Value);
			return CurrentIndicator;
		}
//-----------------------------------------------------------------------------------------------------
// Обработка событий
//-----------------------------------------------------------------------------------------------------

//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------
		public function get Id():uint {
			return lId;
		}
//-----------------------------------------------------------------------------------------------------
		public function set Id(vValue:uint):void {
			lId = vValue;
		}
//-----------------------------------------------------------------------------------------------------
		public function get Type():uint {
			return lType;
		}
//-----------------------------------------------------------------------------------------------------
		public function set Type(vValue:uint):void {
			lType = vValue;
		}
//-----------------------------------------------------------------------------------------------------
		public function get Img30x30Id():uint {
			return lImg30x30Id;
		}
//-----------------------------------------------------------------------------------------------------
		public function set Img30x30Id(vValue:uint):void {
			lImg30x30Id = vValue;
		}
//-----------------------------------------------------------------------------------------------------
		public function get Mount():Boolean {
			return lMount;
		}
//-----------------------------------------------------------------------------------------------------
		public function set Mount(vValue:Boolean):void {
			lMount = vValue;
		}
//-----------------------------------------------------------------------------------------------------
		public function get Value():uint {
			return lValue;
		}
//-----------------------------------------------------------------------------------------------------
		public function set Value(vValue:uint):void {
			lValue = vValue;
		}
//-----------------------------------------------------------------------------------------------------
	}
}