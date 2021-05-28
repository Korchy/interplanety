package Vn {
// Основной класс приложения
//-----------------------------------------------------------------------------------------------------
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import flash.display.Sprite;
	import flash.display.StageScaleMode;	// Масштабирование флешки
	import flash.display.StageAlign;		// Выравнивание флешки в окне
	import Vn.Connections.ConnectionsManagerVn;
	import Vn.Fonts.FontsManagerVn;
	import Vn.Graphic.GraphicManager;
	import Vn.Math.Vector2;
	import Vn.System.Console;
	import Vn.System.FPSCounter;
	import Vn.System.Preloader;
	import Vn.System.SessionId;
	import Vn.Scene.UniverseVn;
	import Vn.Scene.Interface.SceneInterface;
	import Vn.Tutorial.TutorialHelper;
	import Vn.User.User;
	import Vn.Synchronize.ServerTime;
	import Vn.Synchronize.ServerSynchronizer;
	import Vn.Text.TextDictionary;
	import Vn.Common.DynamicObjectsVn;
	import Vn.Vn.Events.EvAppResize;
//	import flash.system.Capabilities;	// Версия флеш-плеера
//-----------------------------------------------------------------------------------------------------
	public class Interplanety extends Sprite {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		private var VnDOL:DynamicObjectsVn;	// Статический объект необходим для корректной рабыты getDefinitionByName
		public static var HomeDir:String = "";	// Начало абсолютного пути к скриптам PHP (для отладки)
		// Размер игровой области (нужен в отдельных переменных т.к. не отовсюду есть доступ к root.stage)
		public static var Width:uint;
		public static var Height:uint;
//-----------------------------------------------------------------------------------------------------
		private var MainTimer:Timer;		// Таймер основного цикла
		private var FPS:FPSCounter;			// Счетчик FPS
		public static var CManager:ConnectionsManagerVn;	// Менеджер соединений с сервером
		public static var SId:SessionId;				// Id сессии
		public static var Cons:Console;				// Консоль
		private static var Preload:Preloader;			// Прелоадер
		public static var Graphic:GraphicManager;		// Графика
		public static var VnSceneI:SceneInterface;	// Интерфейс сцены
		public static var Universe:UniverseVn;		// Вселенная
		public static var VnUser:User;				// Пользователь
		public static var THelper:TutorialHelper;	// Помощник для обучения. Создается после Вселенной, при наличии незакрытого обучающего квеста №1 (добро пожаловать на борт)
		private var STime:ServerTime;		// Серверное время
		private var SSync:ServerSynchronizer;	// Синхронизатор с сервером (пока оставлен для синхронизации времени, потом м.б. все переделать в CManager)
		private var Text:TextDictionary;	// Справочник текста
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function Interplanety() {
			// Конструктор
			// Запретить масштабирование объектов при изменении размеров флешки
			stage.scaleMode = StageScaleMode.NO_SCALE;
			// Выравнивание - по левому верхнему углу
			stage.align = StageAlign.TOP_LEFT;
			// Проверка на изменение размеров флешки
			stage.addEventListener(Event.RESIZE, OnResize);
			OnResize(null);	// Делаем чтоб получить начальные Height и Width
			// Прописать динамические объекты
			DynamicObjectsVn.Init();
			// Основные объекты
			SId = null;
			Cons = null;
			Graphic = null;
			MainTimer = null;
			FPS = null;
			CManager = new ConnectionsManagerVn();
			VnSceneI = null;
			VnUser = new User();
			THelper = null;
			Universe = new UniverseVn();
			STime = null;
			Init();
			}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		public function _delete():void {
			// Удаляем в обратном порядке создания
			// Удалить вселенную
			if(Universe!=null) {
				if(Universe.hasEventListener(UniverseVn.LOADED)) Universe.removeEventListener(UniverseVn.LOADED,InitScene);
				if(Universe.hasEventListener(UniverseVn.FAIL)) Universe.removeEventListener(UniverseVn.FAIL,InitFail);
				Universe._delete();
				Universe = null;
			}
			// Удалить менеджер соединений с сервером
			if(CManager!=null) {
				CManager._delete();
				CManager = null;
			}
			// Удалить счетчик FPS
			if(FPS!=null) {
				removeChild(FPS);
				FPS._delete();
				FPS = null;
			}
			// Удалить синхронизатор с сервером
			if(SSync!=null) {
				SSync._delete();
				SSync = null;
			}
			// Обнулить таймер
			if(MainTimer!=null) {
				MainTimer.stop();	// Остановить таймер
				MainTimer.removeEventListener(TimerEvent.TIMER,Iteration);
				MainTimer = null;
			}
			// Удалить интерфейс сцены
			if(VnSceneI!=null) {
				if(VnSceneI.hasEventListener(SceneInterface.LOADED)) VnSceneI.removeEventListener(SceneInterface.LOADED,LoadSceneInterface);
				if(VnSceneI.hasEventListener(SceneInterface.FAIL)) VnSceneI.removeEventListener(SceneInterface.FAIL,InitFail);
				removeChild(VnSceneI);
				VnSceneI._delete();	// Удаление интерфейса сцены
				VnSceneI = null;
			}
			// Удалить серверное время
			if(STime!=null) {
				if(STime.hasEventListener(ServerTime.INFO_LOADED)) STime.removeEventListener(ServerTime.INFO_LOADED,InitScene);
				if(STime.hasEventListener(ServerTime.INFO_FAIL)) STime.removeEventListener(ServerTime.INFO_FAIL,InitFail);
				STime._delete();
				STime = null;
			}
			// Удалить справочник текста
			if(Text!=null) {
				if(Text.hasEventListener(TextDictionary.INFO_LOADED)) Text.removeEventListener(TextDictionary.INFO_LOADED,GetServerTime);
				if(Text.hasEventListener(TextDictionary.INFO_FAIL)) Text.removeEventListener(TextDictionary.INFO_FAIL,InitFail);
				Text._delete();
				Text = null;
			}
			// Удалить пользователя
			if(VnUser!=null) {
				if(VnUser.hasEventListener(User.INFO_LOADED)) VnUser.removeEventListener(User.INFO_LOADED,GetText);
				if(VnUser.hasEventListener(User.INFO_FAIL)) VnUser.removeEventListener(User.INFO_FAIL,InitFail);
				VnUser._delete();
				VnUser = null;
			}
			// Удалить помощника обучения
			if (THelper != null) {
				removeChild(THelper);
				THelper._delete();
				THelper = null;
			}
			// Удалить график-менеджер
			if(Graphic!=null) {
				if(Graphic.hasEventListener(GraphicManager.INFO_LOADED)) Graphic.removeEventListener(GraphicManager.INFO_LOADED,LoadGraphic);
				if(Graphic.hasEventListener(GraphicManager.INFO_FAIL)) Graphic.removeEventListener(GraphicManager.INFO_FAIL,InitFail);
				Graphic._delete();	// Удаление график-менеджера
				Graphic = null;
			}
			// Удалить Sid
			if(SId!=null) {
				if(SId.hasEventListener(SessionId.INFO_LOADED)) SId.removeEventListener(SessionId.INFO_LOADED,GetUserInfo);
				if(SId.hasEventListener(SessionId.INFO_FAIL)) SId.removeEventListener(SessionId.INFO_FAIL,InitFail);
				SId._delete();
				SId = null;
			}
			// Удалить прелоадер
			if(Preload!=null) {
				if(Preload.parent!=null) removeChild(Preload);
				Preload._delete();
				Preload = null;
			}
			// Удалить консоли
			if(Cons!=null) {
				removeChild(Cons);
				Cons._delete();
				Cons = null;
			}
			// Удалить обработку изменения размеров флешки
			stage.removeEventListener(Event.RESIZE,OnResize);
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		private function Init():void {
			// Начало работы
			// Создать Консоль
			Cons = new Console();
			addChild(Cons);
//			Cons.Add(Capabilities.version);
			// Создать прелоадер
			Preload = new Preloader();
			addChild(Preload);
			Preload.MoveInto(new Vector2(Width/2.0,Height/2.0));
			Preload.addEventListener(Preloader.ALL_PRELOADED,FirstActions);	// Вызов FirstAction по завершении всех предзагрузок
			Preload.StartFill();	// Можно заполнять прелоадер объектами требующими контроля
			// Получить сессию
			SId = new SessionId();
			SId.addEventListener(SessionId.INFO_LOADED,LoadFonts);	// При удаче LoadFonts
			SId.addEventListener(SessionId.INFO_FAIL,InitFail);	// При ошибке InitFail
			// слушатели не снимаются, ну и для дебага пусть висят
//--- ОТЛАДКА ----------------------------------
//--- РАБОЧИЙ РЕЖИМ ----------------------------
			SId.GetSessionId(stage);
//--- ОТЛАДОЧНЫЙ РЕЖИМ -------------------------
//			Vn.Interplanety.HomeDir = "http://interplanetylocal/";
//			SId.GetDebugSessionId("tmp/getsessionid.php");
//--- КОНЕЦ ОТЛАДКИ ----------------------------
		}
//-----------------------------------------------------------------------------------------------------
		private function LoadFonts(e:Event):void {
			// Данные по шрифтам
			// Удалить слушатели с SId
			SId.removeEventListener(SessionId.INFO_LOADED,LoadFonts);
			SId.removeEventListener(SessionId.INFO_FAIL,InitFail);
			// Получить данные по шрифтам
			var FontsManager:FontsManagerVn = new FontsManagerVn();
			Preload.AddToCheck(FontsManager,FontsManagerVn.FONTS_LOADED);
			FontsManager.addEventListener(FontsManagerVn.FONTS_LOADED,LoadGraphic);	// При удаче LoadGraphic
			FontsManager.addEventListener(FontsManagerVn.FONTS_FAIL,InitFail);	// При ошибке InitFail
			FontsManager.LoadFontsFromExternalSWF("FontsVn.swf");
		}
//-----------------------------------------------------------------------------------------------------
		private function LoadGraphic(e:Event):void {
			// Данные по графике
			// Удалить слушатели с FontsManager
			e.target.removeEventListener(FontsManagerVn.FONTS_LOADED,LoadGraphic);
			e.target.removeEventListener(FontsManagerVn.FONTS_FAIL, InitFail);
			// Удалить сам FontsManager (он больше не нужен)
			FontsManagerVn(e.target)._delete();
			// Получить данные по графике
			Graphic = new GraphicManager();
			Preload.AddToCheck(Graphic,GraphicManager.PRELOAD_LOADED);
			Graphic.addEventListener(GraphicManager.INFO_LOADED,GetUserInfo);	// При удаче GetUserInfo (графику грузим параллельно с остальным)
//			Graphic.addEventListener(GraphicManager.PRELOAD_LOADED,GetUserInfo);	// При удаче GetUserInfo
			Graphic.addEventListener(GraphicManager.INFO_FAIL,InitFail);	// При ошибке InitFail
			Graphic.LoadInfo();
		}
//-----------------------------------------------------------------------------------------------------
		private function GetUserInfo(e:Event):void {
			// Получить данные о пользователе
			// Удалить слушатели с Graphic
			Graphic.removeEventListener(GraphicManager.INFO_LOADED,GetUserInfo);	// Продолжаем сразу после загрузки списка прелоад-графики, сама графика грузится параллельно
//			Graphic.removeEventListener(GraphicManager.PRELOAD_LOADED,GetUserInfo);	// Ждем загрузки всей прелоад-графики и только потом продолжаем
			Graphic.removeEventListener(GraphicManager.INFO_FAIL,InitFail);
			// Получить данные о пользователе
			Preload.AddToCheck(VnUser,User.INFO_LOADED);
			VnUser.addEventListener(User.INFO_LOADED,GetText);	// При удаче GetText
			VnUser.addEventListener(User.INFO_FAIL,InitFail);	// При ошибке InitFail
			VnUser.GetInfo("getuserinfo.php");
		}
//-----------------------------------------------------------------------------------------------------
		private function GetText(e:Event):void {
			// Загрузить справочник текста
			// Удалить слушатели с VnUser (данные по пользователю получены)
			VnUser.removeEventListener(User.INFO_LOADED,GetText);
			VnUser.removeEventListener(User.INFO_FAIL,InitFail);
			// Получить текст
			Text = new TextDictionary();
			Preload.AddToCheck(Text,TextDictionary.INFO_LOADED);
			Text.addEventListener(TextDictionary.INFO_LOADED,GetServerTime);	// При удаче GetServerTime
			Text.addEventListener(TextDictionary.INFO_FAIL,InitFail);		// При ошибке InitFail
			Text.LoadText("gettext.php");
		}
//-----------------------------------------------------------------------------------------------------
		private function GetServerTime(e:Event):void {
			// Получить время сервера
			// Удалить слушатели с Text (справочник текста загружен)
			Text.removeEventListener(TextDictionary.INFO_LOADED,GetServerTime);
			Text.removeEventListener(TextDictionary.INFO_FAIL,InitFail);
			// Получить время
			STime = new ServerTime();
			Preload.AddToCheck(STime,ServerTime.INFO_LOADED);
			STime.addEventListener(ServerTime.INFO_LOADED,LoadSceneInterface);	// При удаче LoadSceneInterface
			STime.addEventListener(ServerTime.INFO_FAIL,InitFail);		// При ошибке InitFail
			STime.RefreshServerTime();
		}
//-----------------------------------------------------------------------------------------------------
		private function LoadSceneInterface(e:Event):void {
			// Загрузить интерфейс для сцены
			// Удалить слушатели с STime (данные по серверному времени получены)
			STime.removeEventListener(ServerTime.INFO_LOADED,LoadSceneInterface);
			STime.removeEventListener(ServerTime.INFO_FAIL,InitFail);
			// Загрузить интерфейс
			VnSceneI = new SceneInterface();
			Preload.AddToCheck(VnSceneI,SceneInterface.LOADED);
			VnSceneI.addEventListener(SceneInterface.LOADED,LoadUniverse);	// При удаче InitScene
			VnSceneI.addEventListener(SceneInterface.FAIL,InitFail);	// При ошибке InitFail
			addChild(VnSceneI);
			VnSceneI.visible = false;	// Скрываем до полной загрузки
			VnSceneI.Load();
		}
//-----------------------------------------------------------------------------------------------------
		private function LoadUniverse(e:Event):void {
			// Загрузка вселенной
			// Удалить слушатели с VnSceneI (интерфейс сцены загружен)
			VnSceneI.removeEventListener(SceneInterface.LOADED,LoadUniverse);
			VnSceneI.removeEventListener(SceneInterface.FAIL,InitFail);
			// Загрузить вселенную сектором 0 (Солнечная система)
			Preload.AddToCheck(Universe,UniverseVn.LOADED);
			Universe.addEventListener(UniverseVn.LOADED,InitScene);	// При удаче InitScene
			Universe.addEventListener(UniverseVn.FAIL,InitFail);	// При ошибке InitFail
			addChildAt(Universe,0);	// Сцену ставим в самый низ
			Universe.visible = false;	// Скрываем до полной загрузки
			Universe.Load(1);	// 1 - Солнечная система
		}
//-----------------------------------------------------------------------------------------------------
		private function InitScene(e:Event):void {
			// Инициализация сцены
			// Удалить слушатели с Universe
			Universe.removeEventListener(UniverseVn.LOADED,InitScene);
			Universe.removeEventListener(UniverseVn.FAIL,InitFail);
			// Собрать сцену
			// Инициализируем Таймер
			MainTimer = new Timer((1000/stage.frameRate)/10);	// Задаем частоту таймера по умолчанию 250 раз в секунду
			// Регистрация событий
			MainTimer.addEventListener(TimerEvent.TIMER,Iteration);	// Обработка событя по таймеру
			MainTimer.start();	// Запустить таймер
			// Cоздать синхронизатор с сервером
			SSync = new ServerSynchronizer();
			SSync.Add(10000,STime.RefreshServerTime);	// Раз в 10 секунд - Синхронизация времени с сервером
			// Создать счетчик FPS
			FPS = new FPSCounter();
			Universe.FPS = FPS;
			// Отцентрировать на т. 0,0
//			Center();
			// Счетчик FPS добавить в список отображения последним, чтобы он был поверх всего
			addChild(FPS);
			// Больше предзагрузок не будет
			Preload.EndFill();
		}
//-----------------------------------------------------------------------------------------------------
		private function FirstActions(e:Event):void {
			// Первые действия после загрузки сцены
//			Cons.Add("2014.01.27");
			// Убрать прелоадер
			Preload.removeEventListener(Preloader.ALL_PRELOADED,FirstActions);
			removeChild(Preload);
			Preload._delete();
			Preload = null;
			// Отобразить интерфейс и сцену
			VnSceneI.visible = true;
			Universe.visible = true;
			// Включить обмен данными с сервером
			CManager.SetSync();
			// Если не закрыт обучающий квест - создать помощника
			if (Universe.QuestsManager.IsQuestActive(1) == true) {
				THelper = new TutorialHelper();
				addChild(THelper);
			}
		}
//-----------------------------------------------------------------------------------------------------
		private function InitFail(e:Event):void {
			// Не удалось получить игровые данные - выход
			Exit();
		}
//-----------------------------------------------------------------------------------------------------
		public function Center():void {
			// Центрирование сцены - 0,0 сцены ставим в центр флешки
			if(Universe!=null) Universe.CenterCurrentStarSystem();
		}
//-----------------------------------------------------------------------------------------------------
		public function Exit():void {
			// Выход - переход на login.php
			// Удалить все объекты
			_delete();
			// Вернуться в login.php
			var Request:URLRequest = new URLRequest("login");
			navigateToURL(Request,"_self");
		}
//-----------------------------------------------------------------------------------------------------
//	Итерации игрового цикла
//-----------------------------------------------------------------------------------------------------
		private function Iteration(e:TimerEvent):void {
			// Итерация игрового цикла
			if(FPS!=null) FPS.NextFrame();
			// Провести синхронизацию с сервером
			SSync.Synchronize();	// Синхронизация времени - потом перевести на CManager
			CManager.Synchronize();	// Обмен данными с сервером
			// Обновить компоненты
			Universe.Update();	// Вселенную
			VnSceneI.Update();	// Интерфейс
			// Обновить экран (RENDER)
			e.updateAfterEvent();
		}
//-----------------------------------------------------------------------------------------------------
// Обработка событий
//-----------------------------------------------------------------------------------------------------
		private function OnResize(e:Event):void {
			// Изменение размеров флешки
			// Сохранить новые Height и Width
			Width = stage.stageWidth;
			Height = stage.stageHeight;
			// Изменить размеры компонентов которые завязанные на размеры
			if(VnSceneI!=null) VnSceneI.Resize();
			if(Cons!=null) Cons.Resize();
			if(Preload!=null) Preload.MoveInto(new Vector2(Width/2.0,Height/2.0));
			if (Universe != null) Universe.Resize();
			// Отправить сообщение компонентам не связанным напрямую
			dispatchEvent(new EvAppResize(EvAppResize.APP_RESIZE,Width,Height));
		}
//-----------------------------------------------------------------------------------------------------
	}
}