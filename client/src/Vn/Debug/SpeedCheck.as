package Vn.Debug {
//-----------------------------------------------------------------------------------------------------
// Класс для отладки - Контроль времени выполнения участка кода
// Использование:
//	import Vn.Debug.SpeedCheck;
//	SpeedCheck.AddPoint("P1");
//	SpeedCheck.AddPoint("P2");
//	SpeedCheck.AddPoint("P3");
//	SpeedCheck.TraceTime();	// Будет выведена разница по времени между точками P1 и P2, P2 и P3 и т.д.
//								Точки можно добавлять в разных классах
//-----------------------------------------------------------------------------------------------------
	import flash.utils.getTimer;
	import Vn.Common.UID;
//-----------------------------------------------------------------------------------------------------
	public class SpeedCheck {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		private static var lStartPoint:uint;			// Значение времени в стартовой точке
		private static var Points:Array = new Array();	// Массив с контрольными точками
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function SpeedCheck() {
			// Конструктор родителя
			
			// Конструктор
			
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
		public static function AddPoint(vId:String = ""):void {
			// Добавление контрольной точки отсчета
			var NewId:String = vId;
			if (NewId == "") NewId = String(UID.SetUID());
			var AlwaysChecked:Boolean = false;
			for each (var Point:Array in Points) {
				if (Point[0] == NewId) {
					Point[1] = getTimer();
					AlwaysChecked = true;
				}
			}
			if(AlwaysChecked==false) Points.push(new Array(NewId, getTimer()));
		}
//-----------------------------------------------------------------------------------------------------
		public static function TraceTime():void {
			// Вывод разницы от каждой из контрольных точек
			trace("-----");
			for (var i:uint = 0; i < Points.length; i++ ) {
				trace("[" + Points[i][0] + "] = " + String(Points[i][1] - (i == 0?Points[i][1]:Points[i - 1][1])));
			}
			trace("-----");
		}
//-----------------------------------------------------------------------------------------------------
		public static function Clear():void {
			// Очистка массива с контрольными точками
			for (var i:uint = 0; i < Points.length; ) {
				if (Points[i] != null && Points[i] != undefined) {
					Points[i].splice(1,2);
				}
				Points.splice(i, 1);
			}
		}
//-----------------------------------------------------------------------------------------------------
// Обработка событий
//-----------------------------------------------------------------------------------------------------

//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------

//-----------------------------------------------------------------------------------------------------
	}
}