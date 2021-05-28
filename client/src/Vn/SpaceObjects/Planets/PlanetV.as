﻿package Vn.SpaceObjects.Planets {
//-----------------------------------------------------------------------------------------------------
// Планета виртуальная
//-----------------------------------------------------------------------------------------------------
	import Vn.Common.SC;
	import Vn.Objects.VnObjectSA;
	import Vn.SpaceObjects.InteractiveSpaceObjectVC;
//-----------------------------------------------------------------------------------------------------
	public class PlanetV extends InteractiveSpaceObjectVC {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function PlanetV() {
			// Конструктор родителя
			super();
			// Конструктор
			VnObjectSA(lSpaceObjectImage).AnimationType = SC.ANIM_CIRCLE;
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
		
//-----------------------------------------------------------------------------------------------------
	}
}