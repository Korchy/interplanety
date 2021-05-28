﻿package Vn.SpaceObjects.Stations {
//-----------------------------------------------------------------------------------------------------
// Станция реальная
//-----------------------------------------------------------------------------------------------------
	import Vn.Common.SC;
	import Vn.Objects.VnObjectSA;
	import Vn.SpaceObjects.InteractiveSpaceObjectRC;
	import Vn.Text.TextDictionary;
//-----------------------------------------------------------------------------------------------------
	public class StationR extends InteractiveSpaceObjectRC {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function StationR() {
			// Конструктор предка
			super();
			// Конструктор
			VnObjectSA(lSpaceObjectImage).AnimationSpeed = 350;
			VnObjectSA(lSpaceObjectImage).AnimationType = SC.ANIM_CIRCLE;
			Interaction = true;	// Включить интерактивное окно
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
		override public function ArrivedText():String {
			// Текст при прибытии корабля на эту планету
			return TextDictionary.Text(108)+" "+TextDictionary.Text(179)+" "+TextDictionary.Text(Name);
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