package Vn.Interface.Window {
	// Окно закрывающееся по выполнении скрипта
//-----------------------------------------------------------------------------------------------------
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import Vn.Interplanety;
	import Vn.System.PHPLoader;
	import Vn.Interface.Button.Button;
	import Vn.Text.TextDictionary;
//-----------------------------------------------------------------------------------------------------
	public class VnWindowS extends VnWindow {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		private var OkButton:Button;		// Кнопка ОК
		private var InfoLoader:PHPLoader;	// Объект для обращения к скриптам PHP
		protected var Script:String;		// Скрипт закрытия окна
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function VnWindowS() {
			// Конструктор предка
			super();
			// Конструктор
			// OK
			OkButton = new Button();
			OkButton.ReLoadById(50);	// start
			OkButton.Type = Button.BUTTON_TXT;
			OkButton.Name = 71;
			OkButton.Text = TextDictionary.Text(71);	// После ReLoad т.к выравнивается по центру
			addChild(OkButton);
			OkButton.addEventListener(MouseEvent.CLICK,OkClick);		
			// Загрузчик
			InfoLoader = new PHPLoader();
			Script = "";
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		override public function _delete():void {
			// Деструктор
			OkButton.removeEventListener(MouseEvent.CLICK,OkClick);
			removeChild(OkButton);
			OkButton._delete();
			OkButton = null;
			// Загрузчик
			if(InfoLoader!=null) {
				if(InfoLoader.hasEventListener(Event.COMPLETE)) InfoLoader.removeEventListener(Event.COMPLETE,OnInfoLoaded);
				if(InfoLoader.hasEventListener(IOErrorEvent.IO_ERROR)) InfoLoader.removeEventListener(IOErrorEvent.IO_ERROR,OnIoErrorInfoLoaded);
				InfoLoader._delete();
				InfoLoader = null;
			}
			// Деструктор предка
			super._delete();
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		override public function Close():void {
			// Закрыть окно
			// Выполнить скрирт
			InfoLoader.addEventListener(Event.COMPLETE,OnInfoLoaded);
			InfoLoader.addEventListener(IOErrorEvent.IO_ERROR,OnIoErrorInfoLoaded);
			SetScriptParams();
			InfoLoader.Load(Script);
		}
//-----------------------------------------------------------------------------------------------------
		protected function SetScriptParams():void {
			// Задание входных параметров для скрипта
			// Переопределяется в наследниках
		}
//-----------------------------------------------------------------------------------------------------
		protected function AddScriptParam(Name:String,Value:String):void {
			// Добавление входного параметра для скрипта
			InfoLoader.AddVariable(Name,Value);
		}
//-----------------------------------------------------------------------------------------------------
		protected function ValidClose(e:Event):Boolean {
			// Проверка данных, которые возвратил выполненный скрипт
			if(e.target.data=="T") {
				// Вернул "Т" - нормальная отработка
				return true;
			}
			else return false;
		}
//-----------------------------------------------------------------------------------------------------
// Обработка событий
//-----------------------------------------------------------------------------------------------------
		private function OkClick(e:Event):void {
			// Нажатие OK
			Close();	// Закрыть окно
		}		
//-----------------------------------------------------------------------------------------------------
		private function OnInfoLoaded(e:Event):void {
			// Скрипт закрытия окна выполнен
			// Отсоединить слушатели и отправить сообщение
			InfoLoader.removeEventListener(Event.COMPLETE,OnInfoLoaded);
			InfoLoader.removeEventListener(IOErrorEvent.IO_ERROR,OnIoErrorInfoLoaded);
			// Отработать при закрытии
			OnClose();
			// Отправить сообщение о необходимости закрытия окна
			if(ValidClose(e)==true) {
				dispatchEvent(new Event(VnWindow.CLOSED));
			}
		}
//-----------------------------------------------------------------------------------------------------
		private function OnIoErrorInfoLoaded(e:IOErrorEvent):void {
			// Ошибка выполнения скрипта закрытия окна
			Vn.Interplanety.Cons.Add(TextDictionary.Text(117));	// Системная ошибка
			InfoLoader.removeEventListener(Event.COMPLETE,OnInfoLoaded);
			InfoLoader.removeEventListener(IOErrorEvent.IO_ERROR,OnIoErrorInfoLoaded);
		}
//-----------------------------------------------------------------------------------------------------
		override protected function OnAddToStage(e:Event):void {
			// При добавлении в список отображения
			super.OnAddToStage(e);
			// Поставить кнопку на место
			OkButton.MoveIntoParent(Width05,Height-OkButton.Height05-20,true);// На 20 pix от нижнего края
		}
//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------

//-----------------------------------------------------------------------------------------------------
	}
}