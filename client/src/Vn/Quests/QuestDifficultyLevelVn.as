package Vn.Quests {
	// Класс "Уровень сложности квеста"
//-----------------------------------------------------------------------------------------------------
	import flash.utils.getDefinitionByName;
	import flash.events.Event;
	import Vn.Common.DynamicObjectsVn;
	import Vn.Quests.Conditions.QuestConditionVn;
	import Vn.Quests.Conditions.QuestConditionTextVn;
	import Vn.Quests.Prizes.QuestPrizeVn;
//-----------------------------------------------------------------------------------------------------
	public class QuestDifficultyLevelVn {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		private var lDifficulty:uint;		// Сложность
		private var lConditions:Array;		// Условия выполнения на данном уровне сложности
		private var lPrizes:Array;			// Призы на данном уровне сложности
		// Константы
		public static const EASY:uint = 0;		// Easy
		public static const NORMAL:uint = 1;	// Normal
		public static const HARD:uint = 2;		// Hard
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function QuestDifficultyLevelVn(vDifficulty:uint) {
			// Конструктор родителя
//			super();
			// Конструктор
			lDifficulty = vDifficulty;
			lConditions = new Array();
			lPrizes = new Array();
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		public function _delete():void {
			// Деструктор
			for(var i:uint=0;i<lConditions.length;) {
				if(lConditions[i]!=null&&lConditions[i]!=undefined) {
					lConditions[i]._delete();
					lConditions.splice(i,1);
				}
			}
			lConditions = null;
			for(i=0;i<lPrizes.length;) {
				if(lPrizes[i]!=null&&lPrizes[i]!=undefined) {
					lPrizes[i]._delete();
					lPrizes.splice(i,1);
				}
			}
			lPrizes = null;
			// Деструктор родителя
//			super._delete();
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		public function Load(Data:XMLList):void {
			// Заполнение данными
			var Node:XMLList = Data.child("condition");
			if(Node.length()==0) {
				// Нет данных - инструктаж
				var Instruct:QuestConditionTextVn = new QuestConditionTextVn();
				lConditions.push(Instruct);
			}
			else {
				// Есть данные
				for each (var CCNode:XML in Node.*) {	// <Sell id=1></Sell><Sell id=2></Sell>...
					if(CCNode.nodeKind()=="element") {
						var ClassReference:Class = getDefinitionByName(DynamicObjectsVn.FullName(CCNode.name())) as Class;
						var Instance:QuestConditionVn = new ClassReference();
						Instance.Load(CCNode);
						lConditions.push(Instance);
					}
				}
			}
			var PrizeNode:XMLList = Data.child("prize");
			for each (var CPNode:XML in PrizeNode.*) {	// <Gold></Gold><Planet></Planet>...
				if(CPNode.nodeKind()=="element") {
					if(CPNode.name()!="Text") {			// Text в призы не ставим
						var CurrentPrize:QuestPrizeVn = new QuestPrizeVn();
						CurrentPrize.Load(CPNode);
						lPrizes.push(CurrentPrize);
					}
				}
			}
		}
//-----------------------------------------------------------------------------------------------------
		public function QuestEventOccurse(e:Event):void {
			// Произошло событие влияющее на условия выполнения квеста
			for(var i:uint=0;i<lConditions.length;i++) {
				// Проверить все условия
				if(lConditions[i].EventType==e.type) {
					// Обновить условие
					lConditions[i].QuestEventOccurse(e);
				}
			}
		}
//-----------------------------------------------------------------------------------------------------
// Обработка событий
//-----------------------------------------------------------------------------------------------------

//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------
		public function get Difficulty():uint {
			return lDifficulty;	// Сложность
		}
//-----------------------------------------------------------------------------------------------------
		public function get Conditions():Array {
			return lConditions;	// Список условий
		}
//-----------------------------------------------------------------------------------------------------
		public function get Prizes():Array {
			return lPrizes;	// Список призов
		}
//-----------------------------------------------------------------------------------------------------
		public function get Finished():Boolean {
			// Finished
			var Rez:Boolean = true;
			for(var i:uint=0;i<lConditions.length;i++) {
//trace(String(Conditions[i].Value)+" - "+String(Conditions[i].CurrentValue));
				if(lConditions[i].Finished==false) {
					Rez = false;
					break;
				}
			}
			return Rez;
		}
//-----------------------------------------------------------------------------------------------------
	}
}