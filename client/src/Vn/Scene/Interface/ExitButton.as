﻿package Vn.Scene.Interface {
	// Класс "Кнопка ВЫХОД из игры"
//-----------------------------------------------------------------------------------------------------
	import flash.events.MouseEvent;
	import flash.events.EventPhase;
	import Vn.Interface.Button.Button;
	import Vn.Interplanety;
//-----------------------------------------------------------------------------------------------------
	public class ExitButton extends Button {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function ExitButton() {
			// Конструктор родителя
			super();
			// Конструктор
			NeedPlace = true;
			Name = 26;
			ReLoadById(128);	// close
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
		override protected function OnClick(e:MouseEvent):void {
			// Нажатие
			if(e.eventPhase==EventPhase.AT_TARGET) {
				// Полный выход
				(root as Interplanety).Exit();
			}
		}
//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------

//-----------------------------------------------------------------------------------------------------
	}
}