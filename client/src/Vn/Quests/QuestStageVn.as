package Vn.Quests {
	// Класс "Этап квеста"
//-----------------------------------------------------------------------------------------------------
	import flash.events.Event;
//-----------------------------------------------------------------------------------------------------
	public class QuestStageVn {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		private var lId:uint;	// Id
		private var lEasy:QuestDifficultyLevelVn;
		private var lNormal:QuestDifficultyLevelVn;
		private var lHard:QuestDifficultyLevelVn;
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function QuestStageVn() {
			// Конструктор родителя
//			super();
			// Конструктор
			lId = 1;
			lEasy = null;
			lNormal = null;
			lHard = null;
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		public function _delete():void {
			// Деструктор
			if(lEasy!=null) {
				lEasy._delete();
				lEasy = null;
			}
			if(lNormal!=null) {
				lNormal._delete();
				lNormal = null;
			}
			if(lHard!=null) {
				lHard._delete();
				lHard = null;
			}
			// Деструктор родителя
//			super._delete();
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		public function Load(Data:XML):void {
			// Заполнение этапа данными
			lId = Data.attribute("id");
			var EasyNode:XMLList = Data.child("easy");
			var NormalNode:XMLList = Data.child("normal");
			var HardNode:XMLList = Data.child("hard");
			// Easy (всегда есть)
			lEasy = new QuestDifficultyLevelVn(QuestDifficultyLevelVn.EASY);
			lEasy.Load(EasyNode);
			// Normal
			if(NormalNode.length()!=0) {
				lNormal = new QuestDifficultyLevelVn(QuestDifficultyLevelVn.NORMAL);
				lNormal.Load(NormalNode);
			}
			// Hard
			if(HardNode.length()!=0) {
				lHard = new QuestDifficultyLevelVn(QuestDifficultyLevelVn.HARD);
				lHard.Load(HardNode);
			}
		}
//-----------------------------------------------------------------------------------------------------
		public function QuestEventOccurse(e:Event):void {
			// Произошло событие влияющее на условия выполнения квеста
			// Событие проверяется на всех уровнях сложности
			Easy.QuestEventOccurse(e);
			if(Normal!=null) Normal.QuestEventOccurse(e);
			if(Hard!=null) Hard.QuestEventOccurse(e);
		}
//-----------------------------------------------------------------------------------------------------
// Обработка событий
//-----------------------------------------------------------------------------------------------------

//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------
		public function get Id():uint {
			return lId;	// Id
		}
//-----------------------------------------------------------------------------------------------------
		public function get Easy():QuestDifficultyLevelVn {
			return lEasy;	// Easy
		}
//-----------------------------------------------------------------------------------------------------
		public function get Normal():QuestDifficultyLevelVn {
			return lNormal;	// Normal
		}
//-----------------------------------------------------------------------------------------------------
		public function get Hard():QuestDifficultyLevelVn {
			return lHard;	// Hard
		}
//-----------------------------------------------------------------------------------------------------
		public function get Finished():Boolean {
//trace(Easy.Finished);
//if(Normal!=null) trace(Normal.Finished);
//if(Hard!=null) trace(Hard.Finished);
			if(Easy.Finished==true&&(Normal==null||Normal.Finished==true)&&(Hard==null||Hard.Finished==true)) return true;	// Finished
			else return false;
		}
//-----------------------------------------------------------------------------------------------------
	}
}