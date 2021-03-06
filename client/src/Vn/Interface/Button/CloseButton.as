package Vn.Interface.Button {
	// Класс "Кнопка закрытия окна"
//-----------------------------------------------------------------------------------------------------
	import flash.events.MouseEvent;
	import flash.events.EventPhase;
	import Vn.Math.Vector2;
	import Vn.Objects.VnObjectT;
	import Vn.Interface.Window.VnWindow;
//-----------------------------------------------------------------------------------------------------
	public class CloseButton extends Button {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function CloseButton() {
			// Конструктор предка
			super();
			// Конструктор
			NeedPlace = true;
			Name = 26;
			ReLoadById(128);	// close
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		override public function _delete():void {
			// Деструктор
			
			// Деструктор предка
			super._delete();
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		override protected function GetPlace():Vector2 {
			// Возвращает местоположение кнопки
			if(stage!=null) {
				// Если добавлена в список отображения - правый верхний угол парента
				return new Vector2(VnObjectT(parent).Width,0);
			}
			else {
				// Если не добавлена - 0,0
				return new Vector2(0.0,0.0);
			}
		}
//-----------------------------------------------------------------------------------------------------
// Обработка событий
//-----------------------------------------------------------------------------------------------------
		override protected function OnClick(e:MouseEvent):void {
			// Нажатие
			if(e.eventPhase==EventPhase.AT_TARGET) {
				// Закрыть окно
				VnWindow(parent).Close();
			}
		}
//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------

//-----------------------------------------------------------------------------------------------------
	}
}