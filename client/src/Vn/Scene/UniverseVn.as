package Vn.Scene {
//-----------------------------------------------------------------------------------------------------
// Собственно вся вселенная целиком
//-----------------------------------------------------------------------------------------------------
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.text.engine.BreakOpportunity;
	import Vn.Industry.IndustryManagerVn;
	import Vn.Interplanety;
	import Vn.Objects.Var.LoadedObject;
	import Vn.SpaceObjects.SpaceObjectManagerVn;
	import Vn.User.User;
	import Vn.Scene.StarSystem.StarSystemVn;
	import Vn.Scene.StarSystem.StarSystemRealVn;
	import Vn.Scene.StarSystem.StarSystemVirtualVn;
	import Vn.System.FPSCounter;
	import Vn.Objects.VnObjectR;
	import Vn.Quests.QuestManager;
//-----------------------------------------------------------------------------------------------------
	public class UniverseVn extends VnObjectR {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		private var Quests:QuestManager;		// Квесты
		private var l_QuestsLoaded:Boolean;		// true - квесты загружены, false - нет (квесты грузятся один раз, глобально)
		private var StarSystem:StarSystemVn;	// Текущая звездная система
		private var lIndustryManager:IndustryManagerVn;	// Справочник производств
		private var lSpaceObjectManager:SpaceObjectManagerVn;	// Справочник SpaceObject
		// Константы сообщений
		public static const LOADED:String = "EvUniverseLoaded";		// Universe загружена
		public static const FAIL:String = "EvUniverseLoadedFail";	// Universe НЕ загружена
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function UniverseVn() {
			// Конструктор родителя
			super();
			// Конструктор
			// Задаем размеры сцены
			SetLocalPosition(Vn.Interplanety.Width / 2.0, Vn.Interplanety.Height / 2.0);
			// Справочники
			lIndustryManager = new IndustryManagerVn();			// Производства
			lSpaceObjectManager = new SpaceObjectManagerVn();	// SpaceObject
			// Квесты
			Quests = new QuestManager();
			l_QuestsLoaded = false;
			// Звездная система
			StarSystem = new StarSystemRealVn();	// По умолчанию - реальная звездная система
			addChild(StarSystem);
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		override public function _delete():void {
			// Деструктор
			// Звездная система
			ClearStarSystem();
			removeChild(StarSystem);
			StarSystem._delete();
			StarSystem = null;
			// Квесты
			ClearQuests();
			Quests._delete();
			Quests = null;
			// Справочники
			lIndustryManager.Clear();
			lIndustryManager._delete();
			lIndustryManager = null;
			lSpaceObjectManager._delete();
			lSpaceObjectManager = null;
			// Деструктор родителя
			super._delete();
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		private function ClearStarSystem():void {
			// Очистка текущей звездной системы
			if(StarSystem.hasEventListener(StarSystemVn.LOADED)) StarSystem.removeEventListener(StarSystemVn.LOADED,OnStarSystemLoaded);
			if(StarSystem.hasEventListener(StarSystemVn.FAIL)) StarSystem.removeEventListener(StarSystemVn.FAIL,OnStarSystemLoadedIoError);
			StarSystem.Clear();
		}
//-----------------------------------------------------------------------------------------------------
		private function ClearQuests():void {
			// Очистка квестов
			if (Quests.Quests.hasEventListener(LoadedObject.LOADED)) Quests.Quests.removeEventListener(LoadedObject.LOADED, OnQuestsLoaded);
			if (Quests.Quests.hasEventListener(LoadedObject.FAIL)) Quests.Quests.removeEventListener(LoadedObject.FAIL, OnQuestsLoadedIoError);
			// События отработки квестов очищаются в QuestManager
			Quests.Clear();
		}
//-----------------------------------------------------------------------------------------------------
		public function Load(NewStarSystemId:uint):void {
			// Начальная загрузка звездной системы по Id
			if (l_QuestsLoaded != true) {
				// Сначала загрузить квесты
				StarSystem.Id = NewStarSystemId;	// Сохранить новый Id т.к. будет перевызов после загрузки квестов
				QuestsManager.Quests.addEventListener(LoadedObject.LOADED,OnQuestsLoaded);
				QuestsManager.Quests.addEventListener(LoadedObject.FAIL,OnQuestsLoadedIoError);
				QuestsManager.ReloadQuests();
			}
			else {
				// Загрузить систему по сохраненному Id
				StarSystem.addEventListener(StarSystemVn.LOADED,OnStarSystemLoaded);
				StarSystem.addEventListener(StarSystemVn.FAIL,OnStarSystemLoadedIoError);
				StarSystem.Load(NewStarSystemId);
			}
		}
//-----------------------------------------------------------------------------------------------------
		public function ReloadStarSystem(NewStarSystemId:uint):void {
			// Перезагрузка звездной системы
			ClearStarSystem();
			if (StarSystem.parent != null) removeChild(StarSystem);
			StarSystem._delete();
			if (NewStarSystemId == 0) {
				// Виртуальная звездная система
				Vn.Interplanety.VnSceneI.DisableRealStarSystemButtons();	// Закрыть кнопки реальной звездной системы (до загрузки системы т.к. система слушает интерфейс)
				StarSystem = new StarSystemVirtualVn();
			}
			else {
				// Реальная звездная система
				Vn.Interplanety.VnSceneI.EnableRealStarSystemButtons();		// Открыть кнопки реальной звездной системы (до загрузки системы т.к. система слушает интерфейс)
				StarSystem = new StarSystemRealVn();
			}
			if (FPS != null) StarSystem.FPS = FPS;
			StarSystem.addEventListener(StarSystemVn.LOADED,OnStarSystemLoaded);
			StarSystem.addEventListener(StarSystemVn.FAIL,OnStarSystemLoadedIoError);
			StarSystem.Load(NewStarSystemId);
			// Обновить квесты
			QuestsManager.Refresh();
			// Обновить атрибуты пользователя
			Vn.Interplanety.VnUser.RefreshCrystals();
			Vn.Interplanety.VnUser.RefreshGold();
			Vn.Interplanety.VnUser.RefreshExp();
		}
//-----------------------------------------------------------------------------------------------------
		private function LoadSuccess():void {
			// Загрузка вселенной прошла успешно
			addChild(StarSystem);
			CenterCurrentStarSystem();
			// Проверить на наличие завершенных квестов (наличие призов)
			QuestsManager.CheckPrize();
			// Все загружено
			dispatchEvent(new Event(UniverseVn.LOADED));
		}
//-----------------------------------------------------------------------------------------------------
		private function LoadFail():void {
			// Нормальная загрузка не прошла
			dispatchEvent(new Event(UniverseVn.FAIL));
		}
//-----------------------------------------------------------------------------------------------------
		public function Update():void {
			// Обновление за итерацию игрового цикла
			StarSystem.Update();
		}
//-----------------------------------------------------------------------------------------------------
		public function CenterCurrentStarSystem():void {
			// Отцентрировать текущую звездную систему
			CurrentStarSystem.MoveIntoParent(Width,Height,true);
		}
//-----------------------------------------------------------------------------------------------------
		public function Resize():void {
			// Изменение размера
			SetLocalPosition(Vn.Interplanety.Width / 2.0, Vn.Interplanety.Height / 2.0);
			CurrentStarSystem.Resize();
			CenterCurrentStarSystem();
		}
//-----------------------------------------------------------------------------------------------------
// Обработка событий
//-----------------------------------------------------------------------------------------------------
		private function OnStarSystemLoaded(e:Event):void {
			// Звездная система загружена
			StarSystem.removeEventListener(StarSystemVn.LOADED,OnStarSystemLoaded);
			StarSystem.removeEventListener(StarSystemVn.FAIL, OnStarSystemLoadedIoError);
			// Все загрузки завершены успешно
			LoadSuccess();
		}
//-----------------------------------------------------------------------------------------------------
		private function OnStarSystemLoadedIoError(e:IOErrorEvent):void {
			// Ошибка загрузки звездной системы
			StarSystem.removeEventListener(StarSystemVn.LOADED,OnStarSystemLoaded);
			StarSystem.removeEventListener(StarSystemVn.FAIL,OnStarSystemLoadedIoError);
			LoadFail();
		}
//-----------------------------------------------------------------------------------------------------
		private function OnQuestsLoaded(e:Event):void {
			// Квесты загружены
			l_QuestsLoaded = true;
			Quests.Quests.removeEventListener(LoadedObject.LOADED,OnQuestsLoaded);
			Quests.Quests.removeEventListener(LoadedObject.FAIL, OnQuestsLoadedIoError);
			// Начать слушать события Пользователя (Здесь т.к. User был создан раньше)
			Quests.AddEventToListen(Vn.Interplanety.VnUser,User.CRYSTALS_CHANGED);
			Quests.AddEventToListen(Vn.Interplanety.VnUser,User.GOLD_CHANGED);
			Quests.AddEventToListen(Vn.Interplanety.VnUser,User.EXP_CHANGED);
			Quests.AddEventToListen(Vn.Interplanety.VnUser,User.LEVEL_UP);
			// Перевызов для загрузки звездной системы
			Load(StarSystem.Id);
		}
//-----------------------------------------------------------------------------------------------------
		private function OnQuestsLoadedIoError(e:Event):void {
			// Ошибка загрузки квестов
			Quests.Quests.removeEventListener(LoadedObject.LOADED, OnQuestsLoaded);
			Quests.Quests.removeEventListener(LoadedObject.FAIL, OnQuestsLoadedIoError);
			LoadFail();
		}
//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------
		override public function set FPS(Value:FPSCounter):void {
			super.FPS = Value;
			// Добавить счетчик FPS к StarSystem
			if(StarSystem!=null) StarSystem.FPS = Value;
		}
//-----------------------------------------------------------------------------------------------------
		public function get CurrentStarSystem():StarSystemVn {
			return StarSystem;
		}
//-----------------------------------------------------------------------------------------------------
		public function get QuestsManager():QuestManager {
			return Quests;
		}
//-----------------------------------------------------------------------------------------------------
		public function get IndustryManager():IndustryManagerVn {
			return lIndustryManager;
		}
//-----------------------------------------------------------------------------------------------------
		public function get SpaceObjectManager():SpaceObjectManagerVn {
			return lSpaceObjectManager;
		}
//-----------------------------------------------------------------------------------------------------
	}
}