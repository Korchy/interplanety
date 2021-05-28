package Vn.Quests {
	// Квест
//-----------------------------------------------------------------------------------------------------
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.EventDispatcher;
	import flash.system.System;
	import Vn.Objects.Var.LoadedObject;
	import Vn.System.PHPLoader;
	import Vn.Quests.Prizes.QuestPrizeWindow;
	import Vn.SpaceObjects.InteractiveSpaceObject;
	import Vn.Interface.Window.VnWindow;
	import Vn.List.ObjectsListLVn;
	import Vn.Quests.Events.EvQuestAcceptedByUser;
	import Vn.Interplanety;
	import Vn.Quests.Prizes.PrizeWindow;
	import Vn.Text.TextDictionary;
//-----------------------------------------------------------------------------------------------------
	public class QuestManager extends EventDispatcher {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		private var QList:QuestsList;			// Список квестов
		private var QuestsLoaderScript:String;	// Скрипт загрузки квестов
		private var PrizeLoader:PHPLoader;		// Загрузчик данных по призам
		private var PrizeLoaderScript:String;	// Скрипт для проверки на получение приза
		private static var QWindow:QuestPrizeWindow = null;	// Статический указатель чтобы показывать только одно окно (если приходит еще одно окно - оно выводится после проверки по закрытии первого)
		private var ListeningEvents:Array;	// Массив прослушиваемых событий
		// Константы событий
		public static const QUEST_ACCEPTED_BY_USER:String = "EvQuestAcceptedByUser";	// Квест принят пользователем
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function QuestManager() {
			// Конструктор
			QList = new QuestsList();
			QuestsLoaderScript = "getquests.php";
			PrizeLoader = null;
			PrizeLoaderScript = "getquestsprize.php";
			ListeningEvents = new Array();
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		public function _delete():void {
			// Деструктор
			Clear();
			ListeningEvents = null;
//			if(QList.hasEventListener(ObjectsList.REFRESHED)) QList.removeEventListener(ObjectsList.REFRESHED, OnRefreshed);
			if (QList.hasEventListener(LoadedObject.REFRESHED)) QList.removeEventListener(LoadedObject.REFRESHED, OnRefreshed);
			QList._delete();
			QList = null;
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		public function Clear():void {
			// Очистка без удаления
			CloseQuestWindow();
			// Убрать слушатели с событий завершения квестов
			for(var i:uint=0;i<ListeningEvents.length;) {
				if(ListeningEvents[i]!=null&&ListeningEvents[i]!=undefined) {
					ListeningEvents[i][0].removeEventListener(ListeningEvents[i][1],QuestEventOccurse);
					ListeningEvents[i].splice(0,2);
					ListeningEvents[i] = null;
					ListeningEvents.splice(i,1);
				}
			}
			// Загрузчик призов
			if(PrizeLoader!=null) {
				if(PrizeLoader.hasEventListener(Event.COMPLETE)) PrizeLoader.removeEventListener(Event.COMPLETE,OnCheckPrize);
				if(PrizeLoader.hasEventListener(IOErrorEvent.IO_ERROR)) PrizeLoader.removeEventListener(IOErrorEvent.IO_ERROR,OnIoErrorCheckPrize);
				PrizeLoader._delete();
				PrizeLoader = null;
			}
		}
//-----------------------------------------------------------------------------------------------------
		public function ReloadQuests():void {
			// (Пере)загрузка списка квестов
//			QList.Clear();	// Очистка списка т.к. квесты могут поменять статус (завершиться)
			QList.Script = QuestsLoaderScript;
			QList.Load();
		}
//-----------------------------------------------------------------------------------------------------
		public function Refresh():void {
			// Перезагрузка списка квестов
//			QList.addEventListener(ObjectsList.REFRESHED, OnRefreshed);
			QList.addEventListener(LoadedObject.REFRESHED, OnRefreshed);
			QList.Refresh();
		}
//-----------------------------------------------------------------------------------------------------
		public function AddEventToListen(Obj:EventDispatcher,EventType:String):void {
			// Добавление события, которое может привести к завершению квеста, в прослушивание
			ListeningEvents.push([Obj,EventType]);
			Obj.addEventListener(EventType,QuestEventOccurse);
		}
//-----------------------------------------------------------------------------------------------------
		public function RemoveEventToListen(Obj:EventDispatcher,EventType:String):void {
			// Удаление прослушки события, которое может привести к завершению квеста
			for(var i:uint=0;i<ListeningEvents.length;i++) {
				if(ListeningEvents[i]!=null&&ListeningEvents[i]!=undefined) {
					if(ListeningEvents[i][0]==Obj&&ListeningEvents[i][1]==EventType) {
						ListeningEvents[i][0].removeEventListener(ListeningEvents[i][1],QuestEventOccurse);
						ListeningEvents[i].splice(0,2);
						ListeningEvents[i] = null;
						ListeningEvents.splice(i,1);
						break;
					}
				}
			}
		}
//-----------------------------------------------------------------------------------------------------
		public function QuestEventOccurse(e:Event):void {
			// Произошло событие влияющее на условия выполнения квестов
//Vn.Vn.Cons.Add(e.type);
			// Проверяем по всем активным квестам
			var NeedCheckPrize:Boolean = false;
			for(var i:uint=0;i<QList.All.length;i++) {
				// Отработать событие
				if(QList.All[i].Type==QuestVn.ACTIVE) {
					if(QList.All[i].QuestEventOccurse(e)==true) NeedCheckPrize = true;
				}
			}
			if(NeedCheckPrize==true) CheckPrize();
		}
//-----------------------------------------------------------------------------------------------------
		public function CheckPrize():void {
			// Проверка не получены ли какие-то призы по квестам
			// Вызывается когда выполняется какое-нибудь условие по квестам
//Vn.Vn.Cons.Add("check prize");
			PrizeLoader = new PHPLoader();
			PrizeLoader.addEventListener(Event.COMPLETE,OnCheckPrize);
			PrizeLoader.addEventListener(IOErrorEvent.IO_ERROR,OnIoErrorCheckPrize);
			PrizeLoader.Load(PrizeLoaderScript);
		}
//-----------------------------------------------------------------------------------------------------
		private function ShowQuestWindow(Wnd:QuestPrizeWindow):void {
			// Показ окна
			if(QWindow==null) {
				QWindow = Wnd;
				QWindow.addEventListener(VnWindow.CLOSED,OnWindowClosed);
				QWindow.NeedPlace = true;
				Vn.Interplanety.VnSceneI.addChild(QWindow);
			}
		}
//-----------------------------------------------------------------------------------------------------
		private function CloseQuestWindow():void {
			// Закрытие окна
			if(QWindow!=null) {
				QWindow.removeEventListener(VnWindow.CLOSED,OnWindowClosed);
				Vn.Interplanety.VnSceneI.removeChild(QWindow);
				QWindow._delete();
				QWindow = null;
			}
		}
//-----------------------------------------------------------------------------------------------------
		public function CheckQuestsAvailableOnPlanet(SObject:InteractiveSpaceObject):Boolean {
			// Проверка, имеются ли на данном космическом объекте непринятые квесты
			for(var i:uint=0;i<QList.All.length;i++) {
				if(QList.All[i].Planet==SObject.Id&&QList.All[i].Type==QuestVn.FREE) return true;
			}
			return false;
		}
//-----------------------------------------------------------------------------------------------------
		public function QuestAcceptedByUser(AcceptedQuest:QuestVn):void {
			// Квест AcceptedQuest принят пользователем
			AcceptedQuest.Type = QuestVn.ACTIVE;
			AcceptedQuest.Load();
			dispatchEvent(new EvQuestAcceptedByUser(QuestManager.QUEST_ACCEPTED_BY_USER,AcceptedQuest));
		}
//-----------------------------------------------------------------------------------------------------
		public function GetQuestById(Id:uint):QuestVn {
			// Возвращает указатель на квест по Id квеста
			for (var i:uint = 0; i < QList.All.length; i++) {
				if (QList.All[i].Id == Id) {
					return QList.All[i];
					break;
				}
			}
			return null;
		}
//-----------------------------------------------------------------------------------------------------
		public function IsQuestActive(Id:uint):Boolean {
			// Проверяет, есть ли активный (незавершенный) квест с Id
			var Quest:QuestVn = GetQuestById(Id);
			if (Quest != null && Quest.Type == QuestVn.ACTIVE) return true;
			else return false;
		}
//-----------------------------------------------------------------------------------------------------
// Обработка событий
//-----------------------------------------------------------------------------------------------------
		private function OnRefreshed(e:Event):void {
			// Обновлены данные по квестам
//			QList.removeEventListener(ObjectsList.REFRESHED, OnRefreshed);
			QList.removeEventListener(LoadedObject.REFRESHED, OnRefreshed);
			// Проверить призы
			CheckPrize();
		}
//-----------------------------------------------------------------------------------------------------
		private function OnCheckPrize(e:Event):void {
			// Сообщения получены - получаем только одно сообщение за один раз
			// Если есть открытое окно - по второму разу не получаем
			if(QWindow==null) {
				// Обработать данные
				try {
					var Data:XML = new XML(e.target.data);
				}
				catch(e1:Error) {
					trace(e.target.data);
				}
				// Разобрать призы - указать каждому, что нужно обновить
				for each (var Node:XML in Data.*) {
					if(Node.nodeKind()=="element") {
						var Wnd:QuestPrizeWindow;
						if(Node.name()=="text") {
							// Text
							Wnd = new QuestWindow();	// Окно текста квестов
						}
						else {
							// Prize
							Wnd = new PrizeWindow();	// Окно призов
						}
						Wnd.LoadFromXML(Data);
						ShowQuestWindow(Wnd);
//						QList.ById(uint(Data.attribute("quest_id"))).Refresh();	// Обновить данные по квесту (т.к. мог произойти переход на следующий этап, а квест грузится только до текущего этапа)
					}
				}
				System.disposeXML(Data);
			}
			// Удалить загрузчки
			if (PrizeLoader != null) {
				PrizeLoader.removeEventListener(Event.COMPLETE,OnCheckPrize);
				PrizeLoader.removeEventListener(IOErrorEvent.IO_ERROR, OnIoErrorCheckPrize);
				PrizeLoader._delete();
				PrizeLoader = null;
			}
		}
//-----------------------------------------------------------------------------------------------------
		private function OnIoErrorCheckPrize(e:Event):void {
			// Ошибка получения данных
			// Вывести сообщение
			Vn.Interplanety.Cons.Add(TextDictionary.Text(117));	// Системная ошибка
			// Удалить загрузчик
			if (PrizeLoader != null) {
				PrizeLoader.removeEventListener(Event.COMPLETE,OnCheckPrize);
				PrizeLoader.removeEventListener(IOErrorEvent.IO_ERROR,OnIoErrorCheckPrize);
				PrizeLoader._delete();
				PrizeLoader = null;
			}
		}
//-----------------------------------------------------------------------------------------------------
		private function OnWindowClosed(e:Event):void {
			// Закрытие окна
			CloseQuestWindow();
			// По закрытии окна проверить еще раз, нет ли других призов
			CheckPrize();
		}
//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------
		public function get Quests():QuestsList {
			return QList;	// Список квестов
		}
//-----------------------------------------------------------------------------------------------------
		public function get PrizeWindowVisible():Boolean {
			// true - окно с призами открыто, false - нет окна
			if (QWindow != null) return true;
			else return false;
		}
//-----------------------------------------------------------------------------------------------------
	}
}