﻿package Vn.Actions {
	// Класс "действие"
//-----------------------------------------------------------------------------------------------------
	import Vn.Objects.VnObject;
//----------------------------------------------------------------------------------------------------
	public class Action {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		protected var ActId:String;			// Id действия
		protected var ActCompleted:Boolean;	// false - действие выполняется, true - действие завершено - удалить
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function Action() {
			// Конструктор
			Id = "ACT_UNDEFINED";
			Completed = false;
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		public function _delete():void {
			// Деструктор
			
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		public function PerformAction(Obj:VnObject):void {
			// Выполнить действие для объекта Obj
		}
//-----------------------------------------------------------------------------------------------------
		public function Correct(NewAction:Action):void {
			// Откорректировать данные текущего действия по данным переданным через NewAction
			Completed = NewAction.Completed;
		}
//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------
		public function get Id():String {
			return ActId;
		}
//-----------------------------------------------------------------------------------------------------
		public function set Id(Value:String):void {
			ActId = Value;
		}
//-----------------------------------------------------------------------------------------------------
		public function get Completed():Boolean {
			return ActCompleted;
		}
//-----------------------------------------------------------------------------------------------------
		public function set Completed(Value:Boolean):void {
			ActCompleted = Value;
		}
//-----------------------------------------------------------------------------------------------------
	}
}