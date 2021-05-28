package Vn.Ships {
	// Класс "Окно "Информация о корбале"
//-----------------------------------------------------------------------------------------------------
	import Vn.Common.SC;
	import Vn.Interface.Window.VnWindowB;
	import Vn.Objects.VnObjectSA;
	import Vn.Interface.Text.VnText;
	import Vn.Text.TextDictionary;
//	import Vn.Vn;
//-----------------------------------------------------------------------------------------------------
	public class ShipInfoWindow extends VnWindowB {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		private var ShipImg:VnObjectSA;	// Изображение корабля
		private var RegN:VnText;		// Регистровый номер
		private var SpeedTxt:VnText;	// Скорость
		private var TanksTxt:VnText;	// Кол-во танков
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function ShipInfoWindow(PShip:Ship) {
			// В параметре - указатель на корабль
			// Конструктор предка
			super();
			// Загрузка графики
			Name = 56;
			Caption.Text = TextDictionary.Text(PShip.Name);
			SetLocalPosition(200,75);
			// Изображение корабля
			ShipImg = new VnObjectSA;
			ShipImg.ReLoadById(PShip.Img200x150);
			addChild(ShipImg);
			ShipImg.MoveIntoParent(100,130.0,true);
			ShipImg.AnimationType = SC.ANIM_CIRCLE;
			// Текст
			RegN = new VnText();
			RegN.Text = TextDictionary.Text(78)+": "+String(PShip.Id);
			RegN.x = 220;
			RegN.y = 30;
			addChild(RegN);
			SpeedTxt = new VnText();
			SpeedTxt.Text = TextDictionary.Text(57)+": "+String(PShip.Speed)+" "+TextDictionary.Text(58);
			SpeedTxt.x = 220;
			SpeedTxt.y = 50;
			addChild(SpeedTxt);
			TanksTxt = new VnText();
			TanksTxt.Text = TextDictionary.Text(59)+": "+String(PShip.volume);
			TanksTxt.x = 220;
			TanksTxt.y = 70;
			addChild(TanksTxt);
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		override public function _delete():void {
			if(ShipImg!=null) {
				removeChild(ShipImg);
				ShipImg._delete();
				ShipImg = null;
			}
			removeChild(RegN);
			RegN._delete();
			RegN = null;
			removeChild(SpeedTxt);
			SpeedTxt._delete();
			SpeedTxt = null;
			removeChild(TanksTxt);
			TanksTxt._delete();
			TanksTxt = null;
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