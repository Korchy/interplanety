package Vn.Quests {
//-----------------------------------------------------------------------------------------------------
// Кнопка вызова информации для отдельного квеста
//-----------------------------------------------------------------------------------------------------
	import flash.events.Event;
	import Vn.Interface.Button.ButtonW;
	import Vn.Interface.Button.ButtonWFuncVn;
	import Vn.Interface.Window.VnWindow;
	import Vn.Interface.Window.VnWindowA;
//-----------------------------------------------------------------------------------------------------
	public class QuestToAcceptButton extends ButtonW {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		private var QuestsManager:QuestManager;	// Указатель на Квест-менеджер
		private var QuestToAccept:QuestVn;	// Квест, вызываемый по этой кнопке
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function QuestToAcceptButton(vQuestsManager:QuestManager,vQuestToAccept:QuestVn) {
			// Конструктор родителя
			super();
			// Конструктор
			QuestToAccept = vQuestToAccept;
			QuestsManager = vQuestsManager;
			ReLoadById(QuestToAccept.ImageId);
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
			// Деструктор родителя
			super._delete();
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		override protected function CreateWindow():VnWindow {
			// Создать окно
			var NewWindow:VnWindow = new QuestToAcceptWindow(QuestToAccept);
			NewWindow.Leader = this;
			return NewWindow;
		}
//-----------------------------------------------------------------------------------------------------
// Обработка событий
//-----------------------------------------------------------------------------------------------------
		private function QuestAccepted(e:Event):void {
			// Квест принят
			QuestsManager.QuestAcceptedByUser(QuestToAccept);
			if(Window!=null) Window.Close();
		}
//-----------------------------------------------------------------------------------------------------
		private function QuestDeclined(e:Event):void {
			// Квест отклонен
			if (Window != null) Window.Close();
		}
//-----------------------------------------------------------------------------------------------------
		private function OnWindowOpened(e:Event):void {
			// При открытии окна
			Window.addEventListener(VnWindowA.ACCEPTED,QuestAccepted);
			Window.addEventListener(VnWindowA.DECLINED,QuestDeclined);
		}
//-----------------------------------------------------------------------------------------------------
		private function OnWindowClosed(e:Event):void {
			// При закрытии окна
			Window.removeEventListener(VnWindowA.ACCEPTED,QuestAccepted);
			Window.removeEventListener(VnWindowA.DECLINED,QuestDeclined);
		}
//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------
		
//-----------------------------------------------------------------------------------------------------
	}
}