package Vn.Virtual.Prizes {
//-----------------------------------------------------------------------------------------------------
// Кнопка "Виртуальные призы"
//-----------------------------------------------------------------------------------------------------
	import flash.events.Event;
	import Vn.Interface.Button.ButtonW;
	import Vn.Interface.Button.ButtonWFuncVn;
	import Vn.Interface.Window.VnWindow;
	import Vn.Scene.StarSystem.StarSystemVirtualVn;
	import Vn.Interplanety;
//-----------------------------------------------------------------------------------------------------
	public class PrizesButtonVn extends ButtonW {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function PrizesButtonVn() {
			// Конструктор предка
			super();
			// Конструктор
			Name = 185;			// Призы
			ReLoadById(181);	// virtual_prizes
			WindowFunc.SceneAttach = false;
			WindowFunc.addEventListener(ButtonWFuncVn.WINDOWOPENED,OnWindowOpened);
			WindowFunc.addEventListener(ButtonWFuncVn.WINDOWCLOSED,OnWindowClosed);
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		override public function _delete():void {
			// Деструктор
			WindowFunc.removeEventListener(ButtonWFuncVn.WINDOWOPENED,OnWindowOpened);
			WindowFunc.removeEventListener(ButtonWFuncVn.WINDOWCLOSED,OnWindowClosed);
			// Деструктор предка
			super._delete();
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		override protected function CreateWindow():VnWindow {
			// Создать окно с призами
			// Если режим в виртуальной системе не VIEW - окно не показывать
			if (StarSystemVirtualVn(Interplanety.Universe.CurrentStarSystem).Mode == StarSystemVirtualVn.MODE_VIEW) {
				var SubWindow:VnWindow = new PrizesWindowVn();
				SubWindow.Leader = this;
				return SubWindow;
			}
			return null;
		}
//-----------------------------------------------------------------------------------------------------
		private function OnWindowOpened(e:Event):void {
			// При открытии окна
			// Изменить режим системы на ADD
			StarSystemVirtualVn(Interplanety.Universe.CurrentStarSystem).Mode = StarSystemVirtualVn.MODE_ADD;
		}
//-----------------------------------------------------------------------------------------------------
		private function OnWindowClosed(e:Event):void {
			// При закрытии окна
			// Перевести систему в режим VIEW
			if(Interplanety.Universe!=null) {
				if (StarSystemVirtualVn(Interplanety.Universe.CurrentStarSystem).Mode == StarSystemVirtualVn.MODE_ADD) StarSystemVirtualVn(Interplanety.Universe.CurrentStarSystem).Mode = StarSystemVirtualVn.MODE_VIEW;
			}
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