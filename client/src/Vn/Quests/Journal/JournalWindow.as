package Vn.Quests.Journal {
	// Класс "Окно "Бортовой журнал"
//-----------------------------------------------------------------------------------------------------
	import flash.events.Event;
	import Vn.Math.Vector2;
	import Vn.Interface.Window.VnWindowB;
	import Vn.Interface.List.ImageList;
	import Vn.Objects.Var.LoadedObject;
	import Vn.Text.TextDictionary;
	import Vn.Quests.QuestManager;
	import Vn.Quests.QuestVn;
	import Vn.Quests.Events.EvQuestAcceptedByUser;
	import Vn.List.ObjectsListLVn;
	import Vn.Interplanety;
//-----------------------------------------------------------------------------------------------------
	public class JournalWindow extends VnWindowB {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		private var QListA:ImageList;		// Список активных квестов
		private var QListF:ImageList;		// Список завершенных квестов
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function JournalWindow() {
			// Конструктор предка
			super();
			// Конструктор
			Name = 80;
			Caption.Text = TextDictionary.Text(Name);
			SetLocalPosition(150,80);
			QListA = new ImageList(new Vector2(Width,WorkSpace.Height05));
			addChild(QListA);
			QListA.MoveIntoParent(Width05,WorkSpace.Y+QListA.Height05,true);	// По верхнему краю Workspace
			QListF = new ImageList(new Vector2(Width,WorkSpace.Height05));
			addChild(QListF);
			QListF.MoveIntoParent(Width05,Height-QListF.Height05,true);	// По нижнему краю Workspace
			// Контролируем появление новых квестов при обновлении
			Vn.Interplanety.Universe.QuestsManager.Quests.addEventListener(LoadedObject.REFRESHED,OnQuestsRefresh);
			Vn.Interplanety.Universe.QuestsManager.addEventListener(QuestManager.QUEST_ACCEPTED_BY_USER,OnQuestAcceptedByUser);
			// Заполнить списки квестами
			CreateLists();
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		override public function _delete():void {
			// Деструктор
			Vn.Interplanety.Universe.QuestsManager.Quests.removeEventListener(LoadedObject.REFRESHED,OnQuestsRefresh);
			Vn.Interplanety.Universe.QuestsManager.removeEventListener(QuestManager.QUEST_ACCEPTED_BY_USER,OnQuestAcceptedByUser);
			// Очистить списки
			if(QListA!=null) {
				for(var i:uint=0;i<QListA.Length;i++) {
					// Поснимать с активных квестов слушатели на завершение
					QListA.Objects[i].Quest.removeEventListener(QuestVn.QUEST_FINISHED,OnQuestFinished);
				}
				removeChild(QListA);
				QListA._delete();
				QListA = null;
			}
			if(QListF!=null) {
				removeChild(QListF);
				QListF._delete();
				QListF = null;
			}
			// Деструктор предка
			super._delete();
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		private function CreateLists():void {
			// Заполнение списков квестов
			var AllQuests:Array = Vn.Interplanety.Universe.QuestsManager.Quests.All;
			for(var i:uint=0;i<AllQuests.length;i++) {
				if(AllQuests[i].Type==QuestVn.ACTIVE||AllQuests[i].Type==QuestVn.FINISHED) {
					var QuestPict:QuestInfoButton = new QuestInfoButton(AllQuests[i]);
					QuestPict.ReLoadById(uint(AllQuests[i].ImageId));
					if(AllQuests[i].Type==QuestVn.ACTIVE) {
						QuestPict.Quest.addEventListener(QuestVn.QUEST_FINISHED,OnQuestFinished);	// Квест мониторится на завершение
						QListA.Add(QuestPict);
					}
					if(AllQuests[i].Type==QuestVn.FINISHED) QListF.Add(QuestPict);
				}
			}
		}
//-----------------------------------------------------------------------------------------------------
// Обработка событий
//-----------------------------------------------------------------------------------------------------
		private function OnQuestsRefresh(e:Event):void {
			// Списко квество обновился (новый квест получен как приз)
			var AllQuests:Array = e.target.All;
			for(var i:uint=0;i<AllQuests.length;i++) {
				// Искать квесты без кнопок
				var NewQuestButton:QuestInfoButton = null;
				for(var j:uint=0;j<QListA.Length;j++) {
					if(AllQuests[i]==QListA.Objects[j].Quest) NewQuestButton = QListA.Objects[j];
				}
				for(j=0;j<QListF.Length;j++) {
					if(AllQuests[i]==QListF.Objects[j].Quest) NewQuestButton = QListF.Objects[j];
				}
				// Если кнопка, соответствующая квесту, не найдена - создать
				if(NewQuestButton==null) {
					NewQuestButton = new QuestInfoButton(AllQuests[i]);
					NewQuestButton.ReLoadById(uint(AllQuests[i].ImageId));
					if(AllQuests[i].Type==QuestVn.ACTIVE) {
						NewQuestButton.Quest.addEventListener(QuestVn.QUEST_FINISHED,OnQuestFinished);	// Квест мониторится на завершение
						QListA.Add(NewQuestButton);
					}
					if(AllQuests[i].Type==QuestVn.FINISHED) QListF.Add(NewQuestButton);
				}
			}
		}
//-----------------------------------------------------------------------------------------------------
		private function OnQuestAcceptedByUser(e:EvQuestAcceptedByUser):void {
			// Пользователь принял новый квест
			var NewQuestButton:QuestInfoButton =  new QuestInfoButton(e.AcceptedQuest);
			NewQuestButton.ReLoadById(uint(e.AcceptedQuest.ImageId));
			NewQuestButton.Quest.addEventListener(QuestVn.QUEST_FINISHED,OnQuestFinished);	// Квест мониторится на завершение
			QListA.Add(NewQuestButton);
		}
//-----------------------------------------------------------------------------------------------------
		private function OnQuestFinished(e:Event):void {
			// При завершении квеста
			// Переместить кнопку квеста из активных в завершенные
			for(var i:uint=0;i<QListA.Length;i++) {
				if(e.target==QListA.Objects[i].Quest) {
					// Переставить в завершенные
					var QuestPict:QuestInfoButton = QListA.Objects[i];
					QuestPict.Quest.removeEventListener(QuestVn.QUEST_FINISHED,OnQuestFinished);
					QListA.Remove(QuestPict);
					QListF.Add(QuestPict);
				}
			}
		}
//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------

//-----------------------------------------------------------------------------------------------------
	}
}