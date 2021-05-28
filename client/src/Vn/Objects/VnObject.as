﻿package Vn.Objects {
//-----------------------------------------------------------------------------------------------------
// Общий класс для всех объектов
//-----------------------------------------------------------------------------------------------------
	import flash.display.Sprite;
	import Vn.Common.UID;
//-----------------------------------------------------------------------------------------------------
	public class VnObject extends Sprite {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		private var uid:uint;	// Уникальный идентификатор для каждого объекта
		private var nid:uint;	// Назначаемый идентификатор для каждого объекта (из sector_main)
		private var ObjectName:uint;	// Индекс названия
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function VnObject() {
			uid = UID.SetUID();
			nid = 0;
			ObjectName = 0;
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		public function _delete():void {
			// Удалить всех детей в списке отображения, если они были присоеденины
			while(numChildren) removeChildAt(numChildren-1);
			// Удалиться самому, если был присоединен в список отображения
			if(parent!=null) parent.removeChild(this);
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		public function GetUID():uint {
			return uid;
		}
//-----------------------------------------------------------------------------------------------------
// Обработка событий
//-----------------------------------------------------------------------------------------------------

//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------
		public function get Id():uint {
			return nid;	// Id
		}
//-----------------------------------------------------------------------------------------------------
		public function set Id(Value:uint):void {
			nid = Value;
		}
//-----------------------------------------------------------------------------------------------------
		public function get Name():uint {
			return ObjectName;	// Название
		}
//-----------------------------------------------------------------------------------------------------
		public function set Name(Value:uint):void {
			ObjectName = Value;
		}
//-----------------------------------------------------------------------------------------------------
	}
}