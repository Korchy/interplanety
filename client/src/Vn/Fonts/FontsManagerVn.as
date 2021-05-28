package Vn.Fonts 
{
	// Класс: Менджер шрифтов
//-----------------------------------------------------------------------------------------------------
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLRequest;
	import flash.text.Font;
//-----------------------------------------------------------------------------------------------------
	public class FontsManagerVn extends EventDispatcher {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		private var FontsLoader:Loader;			// Загрузчик шрифтовой флешки
		private var FontsLoaderInfo:LoaderInfo;
		private var FontsLoaded:Boolean;		// true - флешка со шрифтами загружена
		// Константы событий
		public static const FONTS_LOADED:String = "EvFontsLoaded";	// Идентификатор "данные загружены"
		public static const FONTS_FAIL:String = "EvFontsFail";		// Идентификатор "данные НЕ загружены"
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function FontsManagerVn() {
			// Конструктор родителя
			super();
			// Конструктор
			FontsLoaded = false;
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		public function _delete():void {
			// Деструктор
			
			// Деструктор родителя
//			super._delete();
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		public function LoadFontsFromExternalSWF(Value:String):void {
			// Загрузить swf со шрифтами
			if (FontsLoaded == false) {
				FontsLoader = new Loader();
				FontsLoaderInfo = FontsLoader.contentLoaderInfo;
				FontsLoaderInfo.addEventListener(Event.COMPLETE, OnFontsLoaded);
				FontsLoader.load(new URLRequest(Value));
			}
		}
//-----------------------------------------------------------------------------------------------------
		private function OnFontsLoaded(e:Event):void {
			// SWF со шрифтами загружена
			if(FontsLoaded==false) {
				Font.registerFont(Class(LoaderInfo(e.target).applicationDomain.getDefinition("Arial10")));
				Font.registerFont(Class(LoaderInfo(e.target).applicationDomain.getDefinition("Arial12")));
				Font.registerFont(Class(LoaderInfo(e.target).applicationDomain.getDefinition("Arial12I")));
				Font.registerFont(Class(LoaderInfo(e.target).applicationDomain.getDefinition("Arial12B")));
				FontsLoaded = true;
				FontsLoaderInfo.removeEventListener(Event.COMPLETE, OnFontsLoaded);
				dispatchEvent(new Event(FontsManagerVn.FONTS_LOADED));
			}
		}
//-----------------------------------------------------------------------------------------------------
		public static function CorrectFontName(vFontName:String, vFontSize:uint=12):String {
			// Проверка, есть ли такой встроенный (загруженный из сторонней SWF) шрифт заданного размера
			// если есть - возвращает его имя, если нет - возвращает исходное имя шрифта
			var EmbeddedFonts:Array = Font.enumerateFonts(false);
			for (var i:uint = 0; i < EmbeddedFonts.length; i++) {
				if (Font(EmbeddedFonts[i]).fontName == vFontName + "_" + String(vFontSize) + "pt_st") {
					return vFontName + "_" + String(vFontSize) + "pt_st";
				}
			}
			return vFontName;
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