package Vn.Interface.Window {
//-----------------------------------------------------------------------------------------------------
// Класс "Окно, генерящееся от нажатия кнопки и расположенное рядом с вызывающей кнопкой"
//-----------------------------------------------------------------------------------------------------
	import Vn.Math.Vector2;
	import Vn.Common.Common;
	import Vn.Objects.VnObjectT;
//-----------------------------------------------------------------------------------------------------
	public class VnWindowB extends VnWindow {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function VnWindowB() {
			super();
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		override public function _delete():void {
			// Деструктор предка
			super._delete();
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		override protected function GetPlace():Vector2 {
			// Местоположение считаем относительно лидера
			// В координатах мира - для MoveInto
			if(Leader!=null) {
				// Если лидер есть - считаем от него
				// Смещение окна относительно лидера
				var SubPlace:Vector2 = Common.SubObjPlace(VnObjectT(Leader), VnObjectT(this));
				// Т.к. окно чайлдится к StarSystem, а размещаться должно относительно лидера - вычислить смещение между центром лидера и центром StarSystem
				var FromPar:Vector2 = new Vector2();
				Vector2.Vec2Subtract(VnObjectT(parent).GetPosition(), Leader.GetPosition(), FromPar);
				// Учесть размеры StarSystem - теперь окно позиционируется в центр лидера
				Vector2.Vec2Add(VnObjectT(parent).GetLocalPosition(), FromPar , FromPar);
				// Добавить смещещение относительно лидера
				Vector2.Vec2Add(FromPar , SubPlace, FromPar);
				return FromPar;
			}
			else {
				// Если нет - по общей схеме
				return super.GetPlace();
			}
		}
//-----------------------------------------------------------------------------------------------------
		override public function Update():void {
			// Обновление состояния объекта
			super.Update();
			// Следовать за лидером
			FollowLeader();
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