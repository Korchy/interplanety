package Vn.Quests {
//-----------------------------------------------------------------------------------------------------
// Список квестов
//-----------------------------------------------------------------------------------------------------
	import Vn.List.ObjectsListLVn;
//-----------------------------------------------------------------------------------------------------
	public class QuestsList extends ObjectsListLVn {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function QuestsList() {
			// Конструктор предка
			super();
			// Конструктор
			
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, Sавтоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		override public function _delete():void {
			// Деструктор
			
			// Деструктор предка
			super._delete();
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		override protected function CreateListFromXML(Data:XML):void {
			// Создание списка по полученным XML-данным
			for each (var AFNode:XML in Data.*) {	// <N>/<A>/<F>
				if(AFNode.nodeKind()=="element") {
					for each (var Quest:XML in AFNode.*) {	// <quest>
						if(Quest.nodeKind()=="element") {
							CreateQuestFromXML(Quest);
						}
					}
				}
			}
		}
//-----------------------------------------------------------------------------------------------------
		override protected function RefreshListFromXML(Data:XML):void {
			// Обновление списка по полученным XML-данным
			// Временный массив для удаляемых квестов
			var UnRefreshedQuests:Array = All.slice();	// Копируем все квесты
			// Добавить новые квесты
			for each (var AFNode:XML in Data.*) {	// <N>/<A>/<F>
				if(AFNode.nodeKind()=="element") {
					for each (var Quest:XML in AFNode.*) {	// <quest>
						if(Quest.nodeKind()=="element") {
							var NewQuest:QuestVn = QuestVn(ById(uint(Quest.attribute("id"))));
							if(NewQuest==null) {
								// Получен новый квест
								CreateQuestFromXML(Quest);
							}
							else {
								// Квест уже загружен - обновить данные (только для активных квестов)
								if(NewQuest.Type==QuestVn.ACTIVE) NewQuest.Refresh();
								// Квест в списке есть - убрать из удаляемых
								UnRefreshedQuests.splice(UnRefreshedQuests.indexOf(NewQuest),1);
							}
						}
					}
				}
			}
			// Удалить все квесты, которых нет в обновленном списке
			for(var i:uint=0;i<UnRefreshedQuests.length;) {
				Delete(UnRefreshedQuests[i].Id);
				UnRefreshedQuests.splice(i,1);
			}
		}
//-----------------------------------------------------------------------------------------------------
		private function CreateQuestFromXML(Data:XML):void {
			// Создание квеста из XML-данных
			var NewQuest:QuestVn = new QuestVn();
			NewQuest.Id = uint(Data.attribute("id"));
			NewQuest.Name = uint(Data.attribute("name"));
			NewQuest.Level = uint(Data.child("level"));;
			NewQuest.ImageId = uint(Data.child("img"));
			if(Data.child("intro").length()>0) NewQuest.Intro = uint(Data.child("intro"));
			if(Data.child("planet").length()>0) NewQuest.Planet = uint(Data.child("planet"));
			if(Data.parent().name()=="N") NewQuest.Type = QuestVn.FREE;
			if(Data.parent().name()=="A") NewQuest.Type = QuestVn.ACTIVE;
			if(Data.parent().name()=="F") NewQuest.Type = QuestVn.FINISHED;
			if(NewQuest.Type==QuestVn.ACTIVE) NewQuest.Load();	// Загружаем данными только принятые квесты
			Add(NewQuest);
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