package Vn.Ships.Routes {
//-----------------------------------------------------------------------------------------------------
// Класс "Кнопка добавления маршрута"
//-----------------------------------------------------------------------------------------------------
	import Vn.Interface.Button.ButtonW;
	import Vn.Interface.Window.VnWindow;
	import Vn.Ships.Ship;
//-----------------------------------------------------------------------------------------------------
	public class AddRouteButton extends ButtonW {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		private var PShip:Ship;		// Указатель на корабль
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function AddRouteButton(NewShip:Ship) {
			// Конструктор предка
			super();
			// Конструктор
			Name = 51;
			PShip = NewShip;
			ReLoadById(37);	// plus
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
		override protected function CreateWindow():VnWindow {
			// Создать окно
			if (PShip == null) return null;
			var SubWindow:VnWindow = new AddRouteWindow(PShip);
			SubWindow.Leader = this;
			// Проверить кнопка в сцене (вызвана от планеты) или нет (вызвана из интерфейса)
			if (IsIntoScene() == false) WindowFunc.SceneAttach = false;
			return SubWindow;
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