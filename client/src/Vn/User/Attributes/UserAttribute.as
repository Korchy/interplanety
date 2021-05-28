﻿package Vn.User.Attributes {
	// Атрибут пользователя (деньги, кристаллы, опыт и т.п.)
//-----------------------------------------------------------------------------------------------------
	import flash.events.Event;
	import Vn.Objects.Var.LoadedObject;
//-----------------------------------------------------------------------------------------------------
	public class UserAttribute extends LoadedObject {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		protected var AttributeCount:uint;	// Количество
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function UserAttribute() {
			// Конструктор предка
			super();
			// Конструктор
			AttributeCount = 0;
			Script = "getuserattribute.php";
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
		override protected function OnRefresh(e:Event):void {
			// Обновление полученными данными
			Count = uint(e.target.data);
		}
//-----------------------------------------------------------------------------------------------------
// Обработка событий
//-----------------------------------------------------------------------------------------------------
		
//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------
		public function get Count():uint {
			return AttributeCount;
		}
//-----------------------------------------------------------------------------------------------------
		public function set Count(NewValue:uint):void {
			AttributeCount = NewValue;
		}
//-----------------------------------------------------------------------------------------------------//-----------------------------------------------------------------------------------------------------
	}
}