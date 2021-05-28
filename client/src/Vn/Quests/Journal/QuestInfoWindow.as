package Vn.Quests.Journal {
	// Окно с информацией по квесту
//-----------------------------------------------------------------------------------------------------
	import flash.events.Event;
	import Vn.Math.Vector2;
	import Vn.Interface.Window.VnWindowB;
	import Vn.Interface.Pages.PagesB;
	import Vn.Interface.Pages.PagesP;
	import Vn.Quests.QuestVn;
	import Vn.Objects.Var.LoadedObject;
	import Vn.Text.TextDictionary;
//-----------------------------------------------------------------------------------------------------
	public class QuestInfoWindow extends VnWindowB {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		private var Quest:QuestVn;		// Указатель на квест
		private var QuestInfo:PagesB;	// Страничный компонент с информацией по этапам квеста
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function QuestInfoWindow(vQuest:QuestVn) {
			// Конструктор предка
			super();
			// Конструктор
			Quest = vQuest;
			if(Quest!=null) {
				Quest.addEventListener(LoadedObject.REFRESHED,OnQuestRefreshed);
			}
			Name = Quest.Name;
			Caption.Text = TextDictionary.Text(Name);
			SetLocalPosition(180,105);
			// Страничный компонент
			QuestInfo = new PagesB(new Vector2(Width,Height-WorkSpace.Y));
			QuestInfo.ShowPageNumber = true;
			addChild(QuestInfo);
			QuestInfo.MoveIntoParent(Width05,WorkSpace.Y+QuestInfo.Height05,true);
			FillQuestInfo();
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		override public function _delete():void {
			// Деструктор
			if(Quest!=null) {
				Quest.removeEventListener(LoadedObject.REFRESHED,OnQuestRefreshed);
			}
			// Страничный компонент
			removeChild(QuestInfo);
			QuestInfo._delete();
			QuestInfo = null;
			// Деструктор предка
			super._delete();
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		override public function Clear():void {
			// Очистка
			QuestInfo.Clear();
		}
//-----------------------------------------------------------------------------------------------------
		override protected function AddBackground():void {
			// Добавление подложки
			WindowImg = new QuestInfoWindowImageVn();
			addChild(WindowImg);
		}
//-----------------------------------------------------------------------------------------------------
		private function FillQuestInfo():void {
			// Загрузка содержимого окна квестами
			var ActiveStageNumber:uint = 1;
			if (Quest.ActiveStage != null) ActiveStageNumber = Quest.ActiveStage.Id;
			for (var i:uint = 0; i < Quest.Stages.length; i++) {
				// По этапам
				// Заполняем соответствующую номеру stage страницу QuestInfo
				// Создаем страничный компонент с 3 страницами по 3 уровням сложности
				var DiffPages:PagesP = new PagesP(new Vector2(WorkSpace.Width, WorkSpace.Height));
				QuestInfo.Add(DiffPages,Quest.Stages[i].Id,Width05,QuestInfo.Height05);
					// Easy (есть всегда)
					if(Quest.Stages[i].Easy!=null) {
						// Кнопка
						DiffPages.AddNewPageButton(1,93);	// 1 страница - star_bronze
						// Содержимое
						var ESheet:QuestSheet = new QuestSheet(new Vector2(WorkSpace.Width-10,WorkSpace.Height-10));
						ESheet.Load(Quest.Stages[i].Easy);
						DiffPages.Add(ESheet,1,DiffPages.Width05,DiffPages.Height05);
					}
					// Normal
					if(Quest.Stages[i].Normal!=null) {
						// Кнопка
						DiffPages.AddNewPageButton(2,94);	// 2 страница - star_silver
						// Содержимое
						var NSheet:QuestSheet = new QuestSheet(new Vector2(WorkSpace.Width-10,WorkSpace.Height-10));
						NSheet.Load(Quest.Stages[i].Normal);
						DiffPages.Add(NSheet,2,DiffPages.Width05,DiffPages.Height05);
					}
					// Hard
					if(Quest.Stages[i].Hard!=null) {
						// Кнопка
						DiffPages.AddNewPageButton(3,95);	// 3 страница - star_gold
						// Содержимое
						var HSheet:QuestSheet = new QuestSheet(new Vector2(WorkSpace.Width-10,WorkSpace.Height-10));
						HSheet.Load(Quest.Stages[i].Hard);
						DiffPages.Add(HSheet,3,DiffPages.Width05,DiffPages.Height05);
					}
			}
			QuestInfo.ShowPage(ActiveStageNumber);
		}
//-----------------------------------------------------------------------------------------------------
// Обработка событий
//-----------------------------------------------------------------------------------------------------
		private function OnQuestRefreshed(e:Event):void {
			// Обновить все данные т.к. квест обновился с сервера
			Clear();
			FillQuestInfo();
		}
//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------

//-----------------------------------------------------------------------------------------------------
	}
}