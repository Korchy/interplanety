﻿package Vn.Options {
//-----------------------------------------------------------------------------------------------------
// Класс "Кнопка настроек"
//-----------------------------------------------------------------------------------------------------
	import Vn.Interface.Button.ButtonW;
	import Vn.Interface.Window.VnWindow;
//-----------------------------------------------------------------------------------------------------
	public class OptionsButton extends ButtonW {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function OptionsButton() {
			// Конструктор родителя
			super();
			// Конструктор
			Name = 27;
			ReLoadById(28);	// options
			WindowFunc.SceneAttach = false;
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
		override protected function CreateWindow():VnWindow {
			// Создать окно
			var NewWindow:VnWindow = new OptionsWindow();
			NewWindow.Leader = this;
			return NewWindow;
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