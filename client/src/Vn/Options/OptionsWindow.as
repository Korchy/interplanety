package Vn.Options {
	// Класс "Окно настроек"
//-----------------------------------------------------------------------------------------------------
	import flash.events.Event;
	import Vn.Interface.Window.VnWindowB;
	import Vn.Interface.Window.VnWindow;
	import Vn.Interface.CheckBox.CheckBox;
	import Vn.Text.TextDictionary;
	import Vn.Interplanety;
//-----------------------------------------------------------------------------------------------------
	public class OptionsWindow extends VnWindowB {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		private var ShowTrace:CheckBox;	// Настройка показывать/скрывать орбиты
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function OptionsWindow() {
			super();
			// Загрузка графики
			Name = 27;
			Caption.Text = TextDictionary.Text(Name);
			SetLocalPosition(110,45);
			// Флажок показывать/скрывать орбиты
			ShowTrace = new CheckBox();
			ShowTrace.Text = TextDictionary.Text(30);
			addChild(ShowTrace);
			ShowTrace.MoveIntoParent(WorkSpace.X+ShowTrace.Width05+10,WorkSpace.Y+ShowTrace.Height05+20,true);
			ShowTrace.Checked = Vn.Interplanety.VnUser.ShowOrbits;
			ShowTrace.addEventListener(CheckBox.CHANGED,OnShowTraceChanged);
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		override public function _delete():void {
			ShowTrace.removeEventListener(CheckBox.CHANGED,OnShowTraceChanged);
			removeChild(ShowTrace);
			ShowTrace._delete();
			// Деструктор предка
			super._delete();
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		override protected function OnClose():void {
			// При закрытии окна
			// Сохранить пользовательские настройки
			Vn.Interplanety.VnUser.SaveOptions("saveuseroptions.php");
		}
//-----------------------------------------------------------------------------------------------------
// Обработка событий
//-----------------------------------------------------------------------------------------------------
		public function OnShowTraceChanged(e:Event):void {
			Vn.Interplanety.VnUser.ShowOrbits = e.target.Checked;
		}
//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------

//-----------------------------------------------------------------------------------------------------
	}
}