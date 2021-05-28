package Vn.Quests {
	// Квест
//-----------------------------------------------------------------------------------------------------
	import flash.events.Event;
	import flash.system.System;
	import Vn.Objects.Var.LoadedObject;
//-----------------------------------------------------------------------------------------------------
	public class QuestVn extends LoadedObject {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		private var QuestName:uint;	// Name
		private var QuestType:uint;	// Тип квеста (свободный/принятый/завершенный)
		private var QuestLevel:uint;	// Уровень квеста
		private var QuestImageId:uint;	// Иконка квеста
		private var lIntro:uint;		// Первоначальное описание
		private var QuestPlanet:uint;	// Id планеты на которой берется квест (0 - постоянный)
		private var lStages:Array;		// Этапы квеста
		private var lActiveStage:QuestStageVn;	// Текущий этап квеста
		// Константы
		public static const FREE:uint = 0;		// Свободный (непринятый) квест
		public static const ACTIVE:uint = 1;	// Активный (принятый) квест
		public static const FINISHED:uint = 2;	// Завершенный квест
		// Константы событий
		public static const QUEST_FINISHED:String = "EvQuestFinished";			// Квест завершен
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function QuestVn() {
			// Конструктор предка
			super();
			// Конструктор
			Script = "getquest.php";
			Name = 2;
			Type = QuestVn.FREE;
			Level = 0;
			ImageId = 0;
			Intro = 0;
			Planet = 0;
			lStages = new Array();
			lActiveStage = null;
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, Sавтоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		override public function _delete():void {
			// Деструктор
			Clear();
			lStages = null;
			// Деструктор предка
			super._delete();
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		private function Clear():void {
			// Удаление данных
			for(var i:uint=0;i<lStages.length;) {
				if(lStages[i]!=null&&lStages[i]!=undefined) {
					lStages[i]._delete();
					lStages.splice(i,1);
				}
			}
			lActiveStage = null;
		}
//-----------------------------------------------------------------------------------------------------
		override protected function SetScriptParams():void {
			// Задать входные параметры для работы скрипта
			AddScriptParam("QuestId",String(Id));
		}
//-----------------------------------------------------------------------------------------------------
		override protected function OnComplete(e:Event):void {
			// Данные загружены
			try {
				var Data:XML = new XML(e.target.data);	// Данные по квесту
			}
			catch (e1:Error) {
				trace(e.target.data);
				trace("------");
				trace(e1.toString());
				trace("------");
			}
			// Удалить старые данные
			Clear();
			// Обработать данные
			var ActiveStageId:uint = uint(Data.attribute("c_stage"));
			if(ActiveStageId==999) Type = QuestVn.FINISHED;	// Обновить тип т.к. квест может завершиться в процессе одного сеанса (по Refresh)
			// Заполнить этапы
			for each (var Node:XML in Data.*) {	// <stage></stage>
				if(Node.nodeKind()=="element") {
					var CurrentStage:QuestStageVn = new QuestStageVn();
					CurrentStage.Load(Node);
					lStages.push(CurrentStage);
					if(CurrentStage.Id==ActiveStageId) lActiveStage = CurrentStage;	// Текущий этап
				}
			}
			System.disposeXML(Data);
		}
//-----------------------------------------------------------------------------------------------------
		override protected function OnRefresh(e:Event):void {
			// Данные обновлены
			var OldType:uint = Type;
			OnComplete(e);	// Просто переставляем данные
			if(OldType!=QuestVn.FINISHED&&Type==QuestVn.FINISHED) {
				// Квест завершен
				dispatchEvent(new Event(QuestVn.QUEST_FINISHED));
			}
		}
//-----------------------------------------------------------------------------------------------------
		public function QuestEventOccurse(e:Event):Boolean {
			// Произошло событие влияющее на условия выполнения квеста
			// Возвращает true если был переход через любой уровнеь сложности (для проверки призов)
			var StageJump:Boolean = false;	// Переход через уровень сложности
			if(ActiveStage!=null) {
				for(var i:uint=0;i<lStages.length;i++) {
					if(lStages[i].Finished==false) {
						var EasyFinished:Boolean = lStages[i].Easy.Finished;
						var NormalFinished:Boolean = false;
						if(lStages[i].Normal!=null) NormalFinished = lStages[i].Normal.Finished;
						var HardFinished:Boolean = false;
						if(lStages[i].Hard!=null) HardFinished = lStages[i].Hard.Finished;
						// Обновить все незавершенные этапы
						lStages[i].QuestEventOccurse(e);
						// Проверить переходы через уровни сложности
						if(StageJump==false&&(EasyFinished!=lStages[i].Easy.Finished||(lStages[i].Normal!=null&&NormalFinished!=lStages[i].Normal.Finished)||(lStages[i].Hard!=null&&HardFinished!=lStages[i].Hard.Finished))) {
							StageJump = true;
						}
					}
				}
			}
			// При переходе через уровень сложности - обновить квест, чтобы получить следующий этап, или перевести квест в "завершенные"
			if(StageJump==true) Refresh();
			return StageJump;
		}
//-----------------------------------------------------------------------------------------------------
// Обработка событий
//-----------------------------------------------------------------------------------------------------
		
//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------
		public function get Name():uint {
			return QuestName;	// Name
		}
//-----------------------------------------------------------------------------------------------------
		public function set Name(Value:uint):void {
			QuestName = Value;
		}
//-----------------------------------------------------------------------------------------------------
		public function get Type():uint {
			return QuestType;	// Тип
		}
//-----------------------------------------------------------------------------------------------------
		public function set Type(Value:uint):void {
			QuestType = Value;
		}
//-----------------------------------------------------------------------------------------------------
		public function get Level():uint {
			return QuestLevel;	// Level
		}
//-----------------------------------------------------------------------------------------------------
		public function set Level(Value:uint):void {
			QuestLevel = Value;
		}
//-----------------------------------------------------------------------------------------------------
		public function get ImageId():uint {
			return QuestImageId;	// ImageId
		}
//-----------------------------------------------------------------------------------------------------
		public function set ImageId(Value:uint):void {
			QuestImageId = Value;
		}
//-----------------------------------------------------------------------------------------------------
		public function get Intro():uint {
			return lIntro;	// Intro
		}
//-----------------------------------------------------------------------------------------------------
		public function set Intro(Value:uint):void {
			lIntro = Value;
		}
//-----------------------------------------------------------------------------------------------------
		public function get Planet():uint {
			return QuestPlanet;	// Planet
		}
//-----------------------------------------------------------------------------------------------------
		public function set Planet(Value:uint):void {
			QuestPlanet = Value;
		}
//-----------------------------------------------------------------------------------------------------
		public function get Stages():Array {
			return lStages;	// Этапы
		}
//-----------------------------------------------------------------------------------------------------
		public function get ActiveStage():QuestStageVn {
			return lActiveStage;	// Текущий этап
		}
//-----------------------------------------------------------------------------------------------------
	}
}