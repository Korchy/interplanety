package Vn.Objects {
	import flash.automation.ActionGenerator;
	import Vn.Actions.Action;
	// Класс объекта с возможностью выполнения действий
//-----------------------------------------------------------------------------------------------------

//-----------------------------------------------------------------------------------------------------
	public class VnObjectA extends VnObject {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		protected var Actions:Array;		// Массив выполняемых действий
		protected var ActionsToAdd:Array;	// Массив действий для добавления в Actions (нужен, чтобы не прерывать выполнение Actions)
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function VnObjectA() {
			super();
			// Создать массивы действий
			Actions = new Array(0);
			ActionsToAdd = new Array(0);
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		override public function _delete():void {
			super._delete();
			// Удалить массивы действий
			for(var i:uint=0;i<Actions.length;) {
				if(Actions[i]!=null&&Actions[i]!=undefined) {
					Actions[i]._delete();
					Actions.splice(i,1);
				}
			}
			Actions = null;
			for(i=0;i<ActionsToAdd.length;) {
				if(ActionsToAdd[i]!=null&&ActionsToAdd[i]!=undefined) {
					ActionsToAdd[i]._delete();
					ActionsToAdd.splice(i,1);
				}
			}
			ActionsToAdd = null;
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		public function AddAction(Act:Action):void {
			// Добавление нового действия
			// Добавить действие во временный список, чтобы не нарушить основной, если он в процессе выполнения
			ActionsToAdd.push(Act);
		}
//-----------------------------------------------------------------------------------------------------
		public function RemoveAction(ActId:String):void {
			// Удалить действие по id
			// Если действие еще не попало в массив Actions - удаляем
			for(var i:uint=0;i<ActionsToAdd.length;i++) {
				if(ActionsToAdd[i]!=null&&ActionsToAdd[i]!=undefined&&ActionsToAdd[i].Id==ActId) {
					ActionsToAdd[i]._delete();
					ActionsToAdd.splice(i,1);
					break;
				}
			}
			// Если действие уже в работе - только помечаем на удаление, реальное удаление будет в RunAction
			for(var j:uint=0;j<Actions.length;j++) {
				if(Actions[j]!=null&&Actions[j]!=undefined&&Actions[j].Id==ActId) {
					Actions[j].Completed = true;
				}
			}
		}
//-----------------------------------------------------------------------------------------------------
		public function GetAction(ActId:String):Action {
			// Получение действия из списка действий
			for(var i:uint=0;i<Actions.length;i++) {
				if(Actions[i]!=null&&Actions[i]!=undefined&&Actions[i].Id==ActId) {
					return Actions[i];
				}
			}
			return null;
		}
//-----------------------------------------------------------------------------------------------------
		public function RunAction():void {
			// Выполнение действий
			// Добавить в Actions новые действия из ActionsToAdd
			for(var i:uint=0;i<ActionsToAdd.length;) {
				if(ActionsToAdd[i]!=null&&ActionsToAdd[i]!=undefined) {
					var Act:Action = GetAction(ActionsToAdd[i].Id);
					if(Act!=null) {
						// Такое действие уже есть - правка
						Act.Correct(ActionsToAdd[i]);
						ActionsToAdd[i]._delete();
					}
					else {
						// Такого действия еще нет - добавляем
						Actions.push(ActionsToAdd[i]);
					}
					ActionsToAdd.splice(i,1);
				}
			}
			// Выполнить или удалить выполненные действия по списку Actions
			for(i=0;i<Actions.length;) {
				if(Actions[i]!=null&&Actions[i]!=undefined) {
					if(Actions[i].Completed==true) {
						// Удаление выполненного действия
						Actions[i]._delete();
						Actions.splice(i,1);
					}
					else {
						// Выполнить действие
						Actions[i].PerformAction(this);
						i++;
					}
				}
			}
		}
//-----------------------------------------------------------------------------------------------------
	}
}