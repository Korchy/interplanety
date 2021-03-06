package Vn.Interface.Button {
//-----------------------------------------------------------------------------------------------------
// Кнопка "OK"
//-----------------------------------------------------------------------------------------------------
	import Vn.Math.Vector2;
	import Vn.Text.TextDictionary;
	import Vn.Objects.VnObjectT;
//-----------------------------------------------------------------------------------------------------
	public class OkButtonVn extends Button {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function OkButtonVn() {
			// Конструктор предка
			super();
			// Конструктор
			NeedPlace = true;
			ReLoadById(50);	// start
			// Текст
			Type = Button.BUTTON_TXT;
			Text = TextDictionary.Text(199);	// "OK"
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
			// Местоположение - по центру parent на 20 pix вверх от его нижнего края
			if(stage!=null) {
				// Если добавлена в список отображения - определить место
				return new Vector2(VnObjectT(parent).Width05,VnObjectT(parent).Height-Height05-20);
			}
			else {
				// Если не добавлена - 0,0
				return new Vector2(0.0,0.0);
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