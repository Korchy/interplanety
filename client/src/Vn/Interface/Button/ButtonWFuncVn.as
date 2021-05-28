package Vn.Interface.Button {
//-----------------------------------------------------------------------------------------------------
// Отдельная часть функционала кнопки, по нажатию на которую создается и удаляется окно
//-----------------------------------------------------------------------------------------------------
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import Vn.Interplanety;
	import Vn.Objects.VnObject;
	import Vn.Interface.Window.VnWindow;
	import Vn.Objects.VnObjectT;
//-----------------------------------------------------------------------------------------------------
	public class ButtonWFuncVn extends EventDispatcher {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		private var lEnabled:Boolean;		// true - доступно, false - заблокированно
		private var lSubWindow:VnWindow;	// Указатель на генерируемое окно
		private var lWindowShown:Boolean;	// true - окно показано, false - скрыто
		private var lSceneAttach:Boolean;	// true - addChild генерируемого окна к сцене, false - к инетерфейсу
		private var lCreateWindowFunction:Function;		// Указатель на функцию создания окна
		// Константы событий
		public static const WINDOWOPENED:String = "EvButtonWFuncWindowOpened";	// При открытии окна
		public static const WINDOWCLOSED:String = "EvButtonWFuncWindowClosed";	// При закрытии окна
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function ButtonWFuncVn() {
			// Конструктор родителя
			super();
			// Коструктор
			lEnabled = true;
			lWindowShown = false;
			lSceneAttach = true;
			lCreateWindowFunction = null;
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		public function _delete():void {
			// Деструктор
			if (lSubWindow != null) lSubWindow.Close();
			lSubWindow = null;
			lCreateWindowFunction = null;
			// Деструктор родителя
//			super._delete();
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		public function OpenCloseWindow():void {
			// Показать/закрыть окно
			if (lEnabled == true && lWindowShown == false) OpenWindow();
			else CloseWindow();
		}
//-----------------------------------------------------------------------------------------------------
		protected function OpenWindow():void {
			// Открытие окна
			lSubWindow = lCreateWindowFunction();
			if (lSubWindow != null) {
				AttachWindow();
				dispatchEvent(new Event(ButtonWFuncVn.WINDOWOPENED));
			}
		}
//-----------------------------------------------------------------------------------------------------
		public function CloseWindow():void {
			// Зактытие окна (окну - сообщи мне, что ты хочешь закрыться)
			if (lWindowShown == true) {
				lSubWindow.Close();
			}
		}
//-----------------------------------------------------------------------------------------------------
		protected function AttachWindow():void {
			// Присоединение окна
			// Цепляем к сцене чтобы окно всегда было сверху
			lSubWindow.addEventListener(VnWindow.CLOSED, OnWindowClosed);
			if (lSceneAttach == true) Vn.Interplanety.Universe.CurrentStarSystem.addChild(lSubWindow);	// Окно цепляется к сцене
			else Vn.Interplanety.VnSceneI.addChild(lSubWindow);	// Окно цепляется к интерфейсу
			lWindowShown = true;
		}
//-----------------------------------------------------------------------------------------------------
// Обработка событий
//-----------------------------------------------------------------------------------------------------
		private function OnWindowClosed(e:Event):void {
			// Закрытие окна
			if(lSubWindow!=null) {
				dispatchEvent(new Event(ButtonWFuncVn.WINDOWCLOSED));
				lSubWindow.removeEventListener(VnWindow.CLOSED,OnWindowClosed);
				if(lSceneAttach==true) Vn.Interplanety.Universe.CurrentStarSystem.removeChild(lSubWindow);	// Если окно цеплялось к сцене
				else Vn.Interplanety.VnSceneI.removeChild(lSubWindow);	// Окно цеплялось к интерфейсу
				lSubWindow._delete();
				lSubWindow = null;
			}
			lWindowShown = false;
		}
//-----------------------------------------------------------------------------------------------------
		public function Update():void {
			// Обновление
			if (lWindowShown == true) lSubWindow.Update();	// Обновить окно
		}
//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------
		public function set Enabled(Value:Boolean):void {
			if (Value == false) CloseWindow();
			lEnabled = Value;
		}
//-----------------------------------------------------------------------------------------------------
		public function set CreateWindowFunction(Value:Function):void {
			// Функция создания окна
			lCreateWindowFunction = Value;
		}
//-----------------------------------------------------------------------------------------------------
		public function get CreateWindowFunction():Function {
			// Функция создания окна
			return lCreateWindowFunction;
		}
//-----------------------------------------------------------------------------------------------------
		public function set Leader(vValue:VnObjectT):void {
			// Лидер для окна
			if (lSubWindow != null) lSubWindow.Leader = vValue;
		}
//-----------------------------------------------------------------------------------------------------
		public function get WindowShown():Boolean {
			// Окно открыто/закрыто
			return lWindowShown;
		}
//-----------------------------------------------------------------------------------------------------
		public function get Window():VnWindow {
			// Указатель на окно
			return lSubWindow;
		}
//-----------------------------------------------------------------------------------------------------
		public function set Window(vValue:VnWindow):void {
			// Указатель на окно
			lSubWindow = vValue;
		}
//-----------------------------------------------------------------------------------------------------
		public function set SceneAttach(vValue:Boolean):void {
			// Присоединение к сцене/интерфейсу
			lSceneAttach = vValue;
		}
//-----------------------------------------------------------------------------------------------------
	}
}