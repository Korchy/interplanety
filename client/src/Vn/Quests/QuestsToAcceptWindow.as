package Vn.Quests {
	// Окно списка квестов, принимаемых на планете
//-----------------------------------------------------------------------------------------------------
	import flash.events.Event;
	import Vn.Math.Vector2;
	import Vn.Interface.Window.VnWindowB;
	import Vn.Interface.List.ImageList;
	import Vn.SpaceObjects.InteractiveSpaceObject;
	import Vn.Quests.Events.EvQuestAcceptedByUser;
	import Vn.Interplanety;
//-----------------------------------------------------------------------------------------------------
	public class QuestsToAcceptWindow extends VnWindowB {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		private var QList:ImageList;		// Список квестов
		private var CurrentPlanet:InteractiveSpaceObject;	// Указатель на текущую планету
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function QuestsToAcceptWindow(vPlanet:InteractiveSpaceObject) {
			// Конструктор предка
			super();
			// Конструктор
			SetLocalPosition(150,40);
			CurrentPlanet = vPlanet;
			Vn.Interplanety.Universe.QuestsManager.addEventListener(QuestManager.QUEST_ACCEPTED_BY_USER,QuestAccepted);
			// Список квестов
			QList = new ImageList(new Vector2(Width,Height-WorkSpace.Y));
			addChild(QList);
			QList.MoveIntoParent(Width05,WorkSpace.Y+WorkSpace.Height05,true);
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		override public function _delete():void {
			// Деструктор
			if(QList!=null) {
				removeChild(QList);
				QList._delete();
				QList = null;
			}
			Vn.Interplanety.Universe.QuestsManager.removeEventListener(QuestManager.QUEST_ACCEPTED_BY_USER,QuestAccepted);
			CurrentPlanet = null;
			// Деструктор предка
			super._delete();
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		override public function Update():void {
			// Обновление
			super.Update();
			// Обновить содержимое окна
			QList.Update();
		}
//-----------------------------------------------------------------------------------------------------
// Обработка событий
//-----------------------------------------------------------------------------------------------------
		override protected function OnAddToStage(e:Event):void {
			// При добавлении в список отображения
			super.OnAddToStage(e);
			// Создать список квестов на текущей планете, которые можно принять
			var PlanetQuests:Array = CurrentPlanet.QuestsToAccept();
			// Обработать массив
			QList.Clear();
			for(var i:uint=0;i<PlanetQuests.length;) {
				if(PlanetQuests[i]!=null&&PlanetQuests[i]!=undefined) {
					// Создать кнопку для вызова окна с описанием квеста
					var QuestButton:QuestToAcceptButton = new QuestToAcceptButton(Vn.Interplanety.Universe.QuestsManager,PlanetQuests[i]);
					QuestButton.Id = PlanetQuests[i].Id;	// Связка кнопки по Id с квестом
					QList.Add(QuestButton);
					// Удалить указатель из массива
					PlanetQuests.splice(i,1);
				}
			}
			PlanetQuests = null;
		}
//-----------------------------------------------------------------------------------------------------
		private function QuestAccepted(e:EvQuestAcceptedByUser):void {
			// Пользователем принят квест
			// Убрать из списка
			QList.DeleteById(e.AcceptedQuest.Id);
		}
//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------

//-----------------------------------------------------------------------------------------------------
	}
}