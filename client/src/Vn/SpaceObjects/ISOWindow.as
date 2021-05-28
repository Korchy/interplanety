﻿package Vn.SpaceObjects {
//-----------------------------------------------------------------------------------------------------
// Класс SpaceObjectWindow - база окна для InteractiveSpaceObject
//-----------------------------------------------------------------------------------------------------
	import Vn.Interface.Window.VnWindowB;
//-----------------------------------------------------------------------------------------------------
	public class ISOWindow extends VnWindowB {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		private var lPlanet:SpaceObject	// Указатель на планету
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function ISOWindow(vPlanet:SpaceObject) {
			// Конструктор предка
			super();
			// Конструктор
			Planet = vPlanet;
			// Скрыть Caption и кнопку закрытия окна
			Caption.visible = false;
			CloseBtn.visible = false;
			WindowImg.Rendered = false;
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		override public function _delete():void {
			// Деструктор
			
			// Деструктор предка
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
		protected function set Planet(Value:SpaceObject):void {
			lPlanet = Value;
		}
//-----------------------------------------------------------------------------------------------------
		protected function get Planet():SpaceObject {
			return lPlanet;
		}
//-----------------------------------------------------------------------------------------------------
	}
}