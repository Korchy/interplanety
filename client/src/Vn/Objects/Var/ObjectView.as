package Vn.Objects.Var {
//-----------------------------------------------------------------------------------------------------
// Спрайт с подписью
// !!! Использовать вместо этого класса ObjectViewVn !!!
//-----------------------------------------------------------------------------------------------------
	import Vn.Objects.VnObjectSA;
	import Vn.Interface.Text.VnText;
//	import Vn.Debug.ImgBorder;
//-----------------------------------------------------------------------------------------------------
	public class ObjectView extends VnObjectSA {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		private var LinkedObject:Object;	// Указатель на сам объект
		private var IdentifyText:VnText;	// Дополнительный текст для идентификации объекта
		private var IdentifyTextPlace:Boolean;	// Расположение IdentifyText (false - левый верхни угол, true - под изображением)
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function ObjectView(LObject:Object) {
			// Конструктор предка
			super();
			// Конструктор
			LinkedObject = LObject;
			IdentifyText = new VnText();
//			IdentifyText.border = true;
			IdentifyText.Align = VnText.NONE;
			addChild(IdentifyText);
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		override public function _delete():void {
			// Деструктор
			LinkedObject = null;
			removeChild(IdentifyText);
			IdentifyText._delete();
			IdentifyText = null;
			// Деструктор предка
			super._delete();
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		override public function ReLoadById(NewId:uint):void {
			// Переопределение загрузки изображения
			super.ReLoadById(NewId);
			// Размеры подписи
			IdentifyText.width = Image.Info.Cx * 2;
			if(TextPlace==true) {
				IdentifyText.y = Image.Info.Cy*2;
				IdentifyText.Align = VnText.CENTER;
				SetLocalPosition(Image.Info.Cx,Image.Info.Cy+IdentifyText.height/2);
			}
//			ImgBorder.DrawBorder(this);
//			IdentifyText.Border = true;
		}
//-----------------------------------------------------------------------------------------------------
		override public function ReloadByType(ObjectType:String,ObjectId:uint=0,Cx:uint=20,Cy:uint=20):void {
			// Переопределение загрузки изображения
			super.ReloadByType(ObjectType,ObjectId,Cx,Cy);
			// Размеры подписи
			IdentifyText.width = Image.Info.Cx*2;
			if(TextPlace==true) {
				IdentifyText.y = Image.Info.Cy*2;
				IdentifyText.Align = VnText.CENTER;
				SetLocalPosition(Image.Info.Cx,Image.Info.Cy+IdentifyText.height/2);
			}
		}
//-----------------------------------------------------------------------------------------------------
/*
		override protected function Draw():void {
			// Отрисовка объекта
			graphics.lineStyle(1,0x444444,0.5);
			graphics.drawRect(0,0,Width,Height);
		}
//-----------------------------------------------------------------------------------------------------
		override protected function OnAddToStage(e:Event):void {
			// При добавлении в список отображения
			super.OnAddToStage(e);
			Draw();
		}
*/
//-----------------------------------------------------------------------------------------------------
// Обработка событий
//-----------------------------------------------------------------------------------------------------
		
//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------
		public function get Owner():Object {
			return LinkedObject;
		}
//-----------------------------------------------------------------------------------------------------
		public function set Text(Value:String):void {
			IdentifyText.Text = Value;
			IdentifyText.FontSize = 10;
		}
//-----------------------------------------------------------------------------------------------------
		public function get TextPlace():Boolean {
			return IdentifyTextPlace;
		}
//-----------------------------------------------------------------------------------------------------
		public function set TextPlace(Value:Boolean):void {
			IdentifyTextPlace = Value;
		}
//-----------------------------------------------------------------------------------------------------
	}
}