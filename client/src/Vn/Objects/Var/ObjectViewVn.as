package Vn.Objects.Var {
//-----------------------------------------------------------------------------------------------------
// Изображение объекта со ссылкой на сам объект
// Использовать этот класс, а не ObjectView
//-----------------------------------------------------------------------------------------------------
	import Vn.Math.Vector2;
	import Vn.Objects.VnObjectT;
	import Vn.Interface.Text.VnText;
	import Vn.Objects.VnObjectSA;
//	import Vn.Debug.ImgBorder;
//-----------------------------------------------------------------------------------------------------
	public class ObjectViewVn extends VnObjectT {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		private var lOwner:Object;		// Указатель на сам объект
		private var lImage:VnObjectSA;	// Изображение объекта
		private var lText:VnText;		// Текст объекта
		private var lTextPlace:uint;	// Расположение IdentifyText (0 - левый верхни угол, 1 - под изображением по центру)
		// Константы
		public static const LT:uint = 0;	// Левый верхний угол
		public static const MB:uint = 1;	// Центр снизу
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function ObjectViewVn(vObject:Object, vSizeX:Number = 40.0, vSizeY:Number = 40.0) {
			// Конструктор предка
			super();
			// Конструктор
			lOwner = vObject;
			SetLocalPosition(vSizeX / 2.0, vSizeY / 2.0);
//			ImgBorder.DrawBorder(this);
			lImage = new VnObjectSA();
			addChild(lImage);
			lText = new VnText();
			lText.width = Width;
			lText.Align = VnText.NONE;
			lText.FontSize = 10;
//			lText.Border = true;
			addChild(lText);
			lTextPlace = LT;
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		override public function _delete():void {
			// Деструктор
			lOwner = null;
			removeChild(lText);
			lText._delete();
			lText = null;
			removeChild(lImage);
			lImage._delete();
			lImage = null
			// Деструктор предка
			super._delete();
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		public function SetImage(vImageId:uint):void {
			// Задание внешнего вида
			lImage.ReLoadById(vImageId);	// Загрузить изображение
//			ImgBorder.DrawBorder(lImage);
			lImage.MoveIntoParent(Width05, Height05, true);
		}
//-----------------------------------------------------------------------------------------------------
// Обработка событий
//-----------------------------------------------------------------------------------------------------
		
//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------
		public function get Owner():Object {
			return lOwner;
		}
//-----------------------------------------------------------------------------------------------------
		public function set Text(vValue:String):void {
			lText.Text = vValue;
		}
//-----------------------------------------------------------------------------------------------------
		public function set TextPlace(vValue:uint):void {
			switch(vValue) {
				case MB: {
					// Центр по низу
					lText.Align = VnText.CENTER;
					lImage.MoveIntoParent(Width05, Height05 - lText.Height / 2.0, true);
					lText.y = Height05 - lText.Height / 2.0 + lImage.Height05;
					break;
				}
				default: {
					// LB - Левый верхний угол
				}
			}
		}
//-----------------------------------------------------------------------------------------------------
	}
}