package Vn.Indicator {
//-----------------------------------------------------------------------------------------------------
// Базовый класс для индикаторов - интерефейсных объектов, показывающих состояние
//-----------------------------------------------------------------------------------------------------
	import Vn.Interface.Background.BackgroundVn;
	import Vn.Objects.VnObjectR;
//-----------------------------------------------------------------------------------------------------
	public class IndicatorVn extends VnObjectR {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		private var lOwner:Object;	// Указатель на объект от которого индикатор
		private var lBackground:BackgroundVn;	// Подложка
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function IndicatorVn(vOwner:Object, vX:Number, vY:Number) {
			// Конструктор родителя
			super();
			// Конструктор
			lOwner = vOwner;
			SetLocalPosition(vX, vY);
			lBackground = new BackgroundVn();
			lBackground.SetLocalPosition(Width05, Height05);
			addChild(lBackground);
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		override public function _delete():void {
			// Деструктор
			removeChild(lBackground);
			lBackground._delete();
			lBackground = null;
			lOwner = null;
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
		public function get Owner():Object {
			return lOwner;
		}
//-----------------------------------------------------------------------------------------------------
	}
}