package Vn.SpaceObjects {
	// Класс ISOCommonWindow - общее окно для InteractiveSpaceObject
//-----------------------------------------------------------------------------------------------------
	import Vn.SpaceObjects.InteractiveSpaceObject;
	import Vn.SpaceObjects.ISOWindow;
	import Vn.Industry.IButton;
	import Vn.Dock.DButton;
	import Vn.Quests.QButton;
	import Vn.Interplanety;
//-----------------------------------------------------------------------------------------------------
	public class ISOCommonWindow extends ISOWindow {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		private var Industry:IButton;	// Указатель на кнопку "Информация о производстве"
		private var Dock:DButton;		// Указатель на кнопку "Док"
		private var QuestsB:QButton;	// Кнопка Q (Квесты)
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function ISOCommonWindow(vPlanet:SpaceObject) {
			// Конструктор родителя
			super(vPlanet);
			// Конструктор
			// 3 кнопки 20х20 + промежутки в 4 пикс
			SetLocalPosition(10+2+10+2+10,10);
			// Промышленность
			Industry = new IButton(vPlanet);
			addChild(Industry);
			Industry.MoveIntoParent(10,10,true);
			// Док
			Dock = new DButton(vPlanet);
			addChild(Dock);
			Dock.MoveIntoParent(34,10,true);
			// Если есть квесты на этой планете - показывать кнопку
			if(Vn.Interplanety.Universe.QuestsManager.CheckQuestsAvailableOnPlanet(InteractiveSpaceObject(vPlanet))!=false) {
				QuestsB = new QButton(vPlanet);
				addChild(QuestsB);
				QuestsB.MoveIntoParent(58,10,true);
			}
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		override public function _delete():void {
			// Деструктор
			if(QuestsB!=null) {
				removeChild(QuestsB);
				QuestsB._delete();
				QuestsB = null;
			}
			removeChild(Industry);
			Industry._delete();
			Industry = null;
			removeChild(Dock);
			Dock._delete();
			Dock = null;
			// Деструктор родителя
			super._delete();
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		override public function Update():void {
			// Обновление
			super.Update();
			// Обновить содержимое окна
//			Industry.Update();	// Нет смысла обновлять пока сделал по низу экрана
			Dock.Update();
			if (QuestsB != null) QuestsB.Update();
		}
//-----------------------------------------------------------------------------------------------------
// Обработка событий
//-----------------------------------------------------------------------------------------------------

//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------
		public function get DockButton():DButton {
			// Указатель на кнопку "Док"
			return Dock;
		}
//-----------------------------------------------------------------------------------------------------
		public function get IndustryButton():IButton {
			// Указатель на кнопку "Производства"
			return Industry;
		}
//-----------------------------------------------------------------------------------------------------
	}
}