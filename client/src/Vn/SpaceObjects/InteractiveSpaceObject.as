package Vn.SpaceObjects {
//-----------------------------------------------------------------------------------------------------
// Добавление в космические объекты возможности взаимодействия с ними через открытие управляющего окна
//-----------------------------------------------------------------------------------------------------
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.EventPhase;
	import Vn.Interface.Button.ButtonWFuncVn;
	import Vn.Interface.Window.VnWindow;
	import Vn.Quests.QuestVn;
	import Vn.SpaceObjects.SpaceObject;
	import Vn.Interplanety;
//-----------------------------------------------------------------------------------------------------
	public class InteractiveSpaceObject extends SpaceObject {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		private var lInteraction:Boolean;		// true - интерактивное окно подключено, false - нет
		private var lButtonWFunc:ButtonWFuncVn;	// Указатель на функционал управления окном
		protected var lInteractiveWindowSceneAttach:Boolean;	// true - интерактивное окно крепится к сцене, false - к интерфейсу
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function InteractiveSpaceObject() {
			// Конструктор предка
			super();
			// Конструктор
			lInteraction = false;
			lInteractiveWindowSceneAttach = true;		// Интерактивное окно крепится к сцене
			}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		override public function _delete():void {
			// Деструктор
			if (lInteraction == true) Interaction = false;
			// Деструктор предка
			super._delete();
			}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		private function CreateInteractiveWindow():VnWindow {
			// Создать окно. Нужный тип выбирается в функции CreateWindow
			var NewWindow:VnWindow = CreateWindow();	// Создать окно нужного типа
			NewWindow.Leader = lSpaceObjectImage;		// Лидер - картинка
			return NewWindow;
		}
//-----------------------------------------------------------------------------------------------------
		protected function CreateWindow():VnWindow {
			// Переопределяется в наследниках - создание окна нужного типа
			var NewWindow:VnWindow = new ISOCommonWindow(this);	// Окно общего типа
//			NewWindow.Leader = this;
			return NewWindow;
		}
//-----------------------------------------------------------------------------------------------------
		public function QuestsToAccept():Array {
			// Возвращает массив с квестами, которые можно принять на текущем космическом объекте
			var PlanetQuests:Array = new Array();
			for(var i:uint=0;i<Vn.Interplanety.Universe.QuestsManager.Quests.Length;i++) {
				if(Vn.Interplanety.Universe.QuestsManager.Quests.All[i].Type==QuestVn.FREE&&Vn.Interplanety.Universe.QuestsManager.Quests.All[i].Planet==Id) {
					PlanetQuests.push(Vn.Interplanety.Universe.QuestsManager.Quests.All[i]);
				}
			}
			return PlanetQuests;
		}
//-----------------------------------------------------------------------------------------------------
		override public function Update():void {
			// Обновление
			super.Update();
			if (lButtonWFunc != null) lButtonWFunc.Update();
		}
//-----------------------------------------------------------------------------------------------------
// Обработка событий
//-----------------------------------------------------------------------------------------------------
		protected function OnClick(e:MouseEvent):void {
			// Нажатие
			if(e.eventPhase==EventPhase.AT_TARGET) {
				lButtonWFunc.OpenCloseWindow();
			}
		}
//-----------------------------------------------------------------------------------------------------
		override protected function OnRemoveFromStage(e:Event):void {
			// При удалении из списка отображения
			if(lInteraction==true) {
				// Закрыть окно, если оно было открыто
				if (lButtonWFunc.WindowShown == true) lButtonWFunc.OpenCloseWindow();
			}
			super.OnRemoveFromStage(e);
		}
//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------
		public function get Interaction():Boolean {
			// Включено/выключено интерактивное окно
			return lInteraction;
		}
//-----------------------------------------------------------------------------------------------------
		public function set Interaction(vValue:Boolean):void {
			if (lInteraction == vValue) return;
			switch(vValue) {
				case true: {
					// Включить интерактивное окно
					lButtonWFunc = new ButtonWFuncVn();
					lButtonWFunc.SceneAttach = lInteractiveWindowSceneAttach;
					lButtonWFunc.CreateWindowFunction = CreateInteractiveWindow;
					addEventListener(MouseEvent.CLICK, OnClick);
					break;
				}
				case false: {
					// Отключить интерактивное окно
					removeEventListener(MouseEvent.CLICK, OnClick);
					lButtonWFunc._delete();
					lButtonWFunc = null;
					break;
				}
			}
			lInteraction = vValue;
		}
//-----------------------------------------------------------------------------------------------------
		public function get InteractiveWindow():VnWindow {
			// Указатель на интерактивное окно
			if (lInteraction == true) return lButtonWFunc.Window;
			else return null;
		}
//-----------------------------------------------------------------------------------------------------
	}
}