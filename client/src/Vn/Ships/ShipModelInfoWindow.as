package Vn.Ships {
	// Класс "Окно "Информация о модели корабля"
//-----------------------------------------------------------------------------------------------------
	import Vn.Common.SC;
	import Vn.Interface.Window.VnWindowB;
	import Vn.Objects.VnObjectSA;
	import Vn.Interface.Text.VnTextScroll;
	import Vn.Text.TextDictionary;
//-----------------------------------------------------------------------------------------------------
	public class ShipModelInfoWindow extends VnWindowB {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		private var ShipImg:VnObjectSA;		// Изображение корабля
		private var ShipDesc:VnTextScroll;	// Описание корабля
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function ShipModelInfoWindow(ShipData:XML) {
			// В параметре - указатель на корабль
			// Конструктор предка
			super();
			// Загрузка графики
			Name = 56;
			SetLocalPosition(200,75);
			// Изображение корабля
			ShipImg = new VnObjectSA;
			ShipImg.AnimationType = SC.ANIM_CIRCLE;
			// Текст
			ShipDesc = new VnTextScroll(180,110);
			addChild(ShipDesc);
			ShipDesc.TextColor = SC.BLACK;
			ShipDesc.MoveIntoParent(200+90,55+30,true);
			// Заполнить данными
			// Заголовок
			Caption.Text = TextDictionary.Text(uint(ShipData.child("name")));
			// Картинка
			ShipImg.ReLoadById(uint(ShipData.child("img")));
			addChild(ShipImg);
			ShipImg.MoveIntoParent(ShipImg.Width05,ShipImg.Height05+5,true);
			// Текст
			var DescTxt:String = TextDictionary.Text(55)+": "+ShipData.child("level")+"<br>";
			DescTxt += TextDictionary.Text(57)+": "+ShipData.child("speed")+"<br>";
			DescTxt += TextDictionary.Text(59)+": "+ShipData.child("tanks")+"<br>";
			DescTxt += TextDictionary.Text(110)+": "+ShipData.child("tanks_volume")+"<br>";
			ShipDesc.HtmlText = DescTxt;
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		override public function _delete():void {
			// Текст
			removeChild(ShipDesc);
			ShipDesc._delete();
			ShipDesc = null;
			// Картинка
			removeChild(ShipImg);
			ShipImg._delete();
			ShipImg = null;
			// Деструктор предка
			super._delete();
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		override public function Update():void {
			// Обновление состояния объекта
			super.Update();
			ShipImg.PlayAnimation();	// Анимация корабля
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