package Vn.Dock {
	// Класс "Окно "Корабли"
//-----------------------------------------------------------------------------------------------------
	import Vn.Math.Vector2;
	import Vn.Interface.Window.VnWindowB;
	import Vn.Scene.StarSystem.StarSystemRealVn;
	import Vn.Ships.Ship;
	import Vn.Ships.ShipManager;
	import Vn.Interface.List.ImageList;
	import Vn.Text.TextDictionary;
	import Vn.Interplanety;
//-----------------------------------------------------------------------------------------------------
	public class ShipsWindow extends VnWindowB {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		private var lPages:ImageList;	// Страничный компонент для размещения пиктограмм кораблей
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function ShipsWindow(PlanetId:uint = 0) {
			// Конструктор предка
			super();
			// Конструктор
			Name = 48;
			Caption.Text = TextDictionary.Text(Name);
			SetLocalPosition(181,74);
			// Страничный компонент
			lPages = new ImageList(new Vector2(Width,Height-WorkSpace.Y));	// - заголовок окна
			addChild(lPages);
			lPages.MoveIntoParent(Width05,WorkSpace.Y+WorkSpace.Height05,true);
			// Создать пиктограммы для кораблей
			var AllShips:Array = StarSystemRealVn(Vn.Interplanety.Universe.CurrentStarSystem).Ships.All;	// Все корабли
			for (var i:uint = 0; i < AllShips.length; i++) {
				if(AllShips[i].PlanetA==AllShips[i].PlanetB&&AllShips[i].PlanetA.SpaceObjectId==PlanetId||PlanetId==0) {
					// Для планеты только если корабль находится на планете (A==B) и эта текущая планета или
					// для всех кораблей, если вызвано через кнопку "корабли" (PlanetId==0)
					var ShipM:ShipManager = new ShipManager(Ship(AllShips[i]));
					var Img:uint = Ship(AllShips[i]).Img40x40;
					ShipM.Pict.ReLoadById(Img);
					ShipM.RegNumber = AllShips[i].Id;
					ShipM.Id = AllShips[i].Id;
					lPages.Add(ShipM);
				}
			}
//			lPages.Refresh();
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		override public function _delete():void {
			// Деструктор
			// Убрать страничный компонент
			removeChild(lPages);
			lPages._delete();
			lPages = null;
			// Деструктор предка
			super._delete();
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		override public function Update():void {
			// Обновление
			super.Update();	// Движение за кнопкой, если окно вызвали с планеты
			lPages.Update();	// Передать обновление дальше
		}
//-----------------------------------------------------------------------------------------------------
		public function RemoveElement(Element:Ship):void {
			// Удаление корабля из списка
			lPages.DeleteById(Element.Id);
//			lPages.Refresh();
		}
//-----------------------------------------------------------------------------------------------------
// Обработка событий
//-----------------------------------------------------------------------------------------------------
	
//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------
		public function get Pages():ImageList {
			// Указатель на страничный компонент
			return lPages;
		}
//-----------------------------------------------------------------------------------------------------
	}
}