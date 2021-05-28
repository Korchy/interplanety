package Vn.Interface.Text {
	// Класс Текст
//-----------------------------------------------------------------------------------------------------
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.net.URLRequest;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormatAlign;
	import flash.text.Font;
	import Vn.Common.SC;
	import Vn.Fonts.FontsManagerVn;
//-----------------------------------------------------------------------------------------------------
	public class VnText extends TextField {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		private var ObjectId:uint;	// Id
		public static const STATIC:uint = 0;
		public static const INPUT:uint = 1;
		public static const NONE:uint = 0;
		public static const LEFT:uint = 1;
		public static const RIGHT:uint = 2;
		public static const CENTER:uint = 3;
		public static const JUSTIFY:uint = 4;
		private var VnTextFormat:TextFormat;	// Форматирование текста
		private var MaximalWidth:uint;	// Максимальная ширина тектового поля. Если = 0 - не исплользуется.
		private static var CommonFontName:String = "Arial";	// Дефолтный шрифт
		private var FontNameL:String;	// Название шрифта
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function VnText() {
			// Конструктор предка
			super();
			// Конструктор
			VnTextFormat = new TextFormat();
			Align = LEFT;
			Type = STATIC;
			selectable = false;
			textColor = SC.TEXT_COLOR;
			if((Font.enumerateFonts(false)).length!=0) embedFonts = true;	// Если встроенные шрифты есть - использовать их
			FontName = "Arial";	// По-умолчанию Arial
			FontSize = 12;		// По-умолчанию 12
			Id = 0;
			MaxWidth = 0;
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		public function _delete():void {
			// Деструктор
			VnTextFormat = null;
			// Деструкторк предка
//			super._delete();
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		
//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------
		public function get Id():uint {
			return ObjectId;
		}
//-----------------------------------------------------------------------------------------------------
		public function set Id(Value:uint):void {
			ObjectId = Value;
		}
//-----------------------------------------------------------------------------------------------------
		public function set Align(Value:uint):void {
			switch(Value) {
				case 0:
					autoSize = TextFieldAutoSize.NONE;
					break;
				case 1:
					autoSize = TextFieldAutoSize.LEFT;
					break;
				case 2:
					autoSize = TextFieldAutoSize.RIGHT;
					break;
				case 3:
					autoSize = TextFieldAutoSize.CENTER;
					break;
			}
		}
//-----------------------------------------------------------------------------------------------------
		public function set Type(Value:uint):void {
			switch(Value) {
				case 0:
					type = TextFieldType.DYNAMIC;
					break;
				case 1:
					type = TextFieldType.INPUT
					break;
			}
		}
//-----------------------------------------------------------------------------------------------------
		public function set TextAlign(Value:uint):void {
			// Выравнивание текста в компоненте (только при Align = NONE)
			switch(Value) {
				case 0:
				case 1:
					VnTextFormat.align = TextFormatAlign.LEFT;
					break;
				case 2:
					VnTextFormat.align = TextFormatAlign.RIGHT;
					break;
				case 3:
					VnTextFormat.align = TextFormatAlign.CENTER;
					break;
				case 4:
					VnTextFormat.align = TextFormatAlign.JUSTIFY;
					break;
			}
			setTextFormat(VnTextFormat);
		}
//-----------------------------------------------------------------------------------------------------
		public function get FontSize():uint {
//			var FSize:uint = 12;
//			if(VnTextFormat.size!=null) FSize = uint(VnTextFormat.size);
//			return FSize;	// Размер шрифта
			return uint(VnTextFormat.size);
		}
//-----------------------------------------------------------------------------------------------------
		public function set FontSize(Value:uint):void {
			VnTextFormat.size = Value;
			VnTextFormat.font = FontsManagerVn.CorrectFontName(FontName,FontSize);
			setTextFormat(VnTextFormat);
		}
//-----------------------------------------------------------------------------------------------------
		public function get FontName():String {
			return FontNameL;	// Назвение шрифта ("Arial")
		}
//-----------------------------------------------------------------------------------------------------
		public function set FontName(Value:String):void {
			// Проверяем, есть ли такой встроенный шрифт (шрифты берутся из внешней SWF)
			FontNameL = Value;
			VnTextFormat.font = FontsManagerVn.CorrectFontName(FontName,FontSize);
			setTextFormat(VnTextFormat);
		}
//-----------------------------------------------------------------------------------------------------
		public function get Text():String {
			return text;	// Текст
		}
//-----------------------------------------------------------------------------------------------------
		public function set Text(Value:String):void {
			text = Value;
			setTextFormat(VnTextFormat);
//			if(MaxWidth!=0&&width>MaxWidth) width = MaxWidth;
		}
//-----------------------------------------------------------------------------------------------------
		public function get HtmlText():String {
			return htmlText;	// Текст в формате HTML
		}
//-----------------------------------------------------------------------------------------------------
		public function set HtmlText(Value:String):void {
			htmlText = Value;
			setTextFormat(VnTextFormat);
		}
//-----------------------------------------------------------------------------------------------------
		public function set Leading(Value:uint):void {
			VnTextFormat.leading = Value;	// Межстрочный интервал
			setTextFormat(VnTextFormat);
		}
//-----------------------------------------------------------------------------------------------------
		public function get Width():uint {
			return width;	// Ширина
		}
//-----------------------------------------------------------------------------------------------------
		public function set Width(Value:uint):void {
			width = Value;
		}
//-----------------------------------------------------------------------------------------------------
		public function get Height():uint {
			return height;	// Высота
		}
//-----------------------------------------------------------------------------------------------------
		public function set Height(Value:uint):void {
			height = Value;
		}
//-----------------------------------------------------------------------------------------------------
		public function get Border():Boolean {
			return border;	// Рамка
		}
//-----------------------------------------------------------------------------------------------------
		public function set Border(Value:Boolean):void {
			border = Value;
		}
//-----------------------------------------------------------------------------------------------------
		public function get BorderColor():int {
			return borderColor;	// Цвет рамки
		}
//-----------------------------------------------------------------------------------------------------
		public function set BorderColor(Value:int):void {
			borderColor = Value;
		}
//-----------------------------------------------------------------------------------------------------
		public function get MaxWidth():uint {
			return MaximalWidth;	// Максимальная ширина
		}
//-----------------------------------------------------------------------------------------------------
		public function set MaxWidth(Value:uint):void {
			MaximalWidth = Value;
		}
//-----------------------------------------------------------------------------------------------------
		public function get Color():uint {
			return textColor;	// Цвет текста
		}
//-----------------------------------------------------------------------------------------------------
		public function set Color(Value:uint):void {
			textColor = Value;
		}
//-----------------------------------------------------------------------------------------------------
	}
}