﻿package Vn.User.Attributes {
	// Опыт
//-----------------------------------------------------------------------------------------------------
	import flash.events.Event;
	import Vn.Interplanety;
	import Vn.System.PHPLoader;
	import Vn.Scene.Interface.LevelInfo;
	import Vn.User.User;
//-----------------------------------------------------------------------------------------------------
	public class Experience extends UserAttribute {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		private var UserLevel:uint;		// Уровень
		private var NextLevelExp:uint;	// Опыта до перехода на следующий уровень
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function Experience() {
			// Конструктор предка
			super();
			// Конструктор
			NextLevelExp = 0;
			UserLevel = 0;
			InfoLoader.Format = PHPLoader.VARIABLES;
			Script = "getuserlevel.php";
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
		public static function CreateIndicator():LevelInfo {
			// Создать индиктора для отображения
			var Ind:LevelInfo = new LevelInfo();
			return Ind;
		}
//-----------------------------------------------------------------------------------------------------
// Обработка событий
//-----------------------------------------------------------------------------------------------------
		override protected function OnRefresh(e:Event):void {
			// Обновление полученными данными
			Level = uint(e.target.data.Level);
			NextLevel = uint(e.target.data.NextLevelExp);
			Count = uint(e.target.data.Exp);	// Count после NextLevel т.к. в Count идет проверка перехода через уровень
		}
//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------
		public function get NextLevel():uint {
			return NextLevelExp;
		}
//-----------------------------------------------------------------------------------------------------
		public function set NextLevel(NewValue:uint):void {
			NextLevelExp = NewValue;
		}
//-----------------------------------------------------------------------------------------------------
		public function get Level():uint {
			return UserLevel;
		}
//-----------------------------------------------------------------------------------------------------
		public function set Level(NewValue:uint):void {
			if(Level<NewValue) {
				UserLevel = NewValue;
				Vn.Interplanety.VnUser.dispatchEvent(new Event(User.LEVEL_UP));	// Сообщить что уровень юзера изменился
			}
		}
//-----------------------------------------------------------------------------------------------------
		override public function set Count(NewValue:uint):void {
			super.Count = NewValue;
			if(Count>=NextLevel) Refresh();	// Получить с сервера
			Vn.Interplanety.VnUser.dispatchEvent(new Event(User.EXP_CHANGED));	// Сообщить что кол-во опыта юзера изменилось
		}
//-----------------------------------------------------------------------------------------------------
	}
}