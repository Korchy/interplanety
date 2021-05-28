package Vn.System 
{
//-----------------------------------------------------------------------------------------------------
// Класс для работы с ExternalInterface и navigateToURL
//-----------------------------------------------------------------------------------------------------
	import flash.external.ExternalInterface;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import Vn.Interplanety;
//-----------------------------------------------------------------------------------------------------
	public class ExternalInterfaceVn {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		// Виды браузеров
		public static const BROWSER_UNAVAILABLE:uint = 0;
		public static const BROWSER_OTHER:uint = 1;
		public static const BROWSER_IE:uint = 2;
		public static const BROWSER_CHROME:uint = 3;
		public static const BROWSER_FIREFOX:uint = 4;
		public static const BROWSER_OPERA:uint = 5;
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function ExternalInterfaceVn() {
			// Конструктор родителя
			
			// Конструктор
			
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
		public function OpenNewTab(Script:String):Boolean {
			// Открытие новой вкладки и выполнение в ней скрипта Script
			if (ExternalInterface.available) {
				switch (BrowserName()) {
					case BROWSER_IE:
						// Для IE - через navigateToURL
						CallNavigateToUrl(Script);
						break;
					case BROWSER_OPERA:
						// Для OPERA - через navigateToURL
						CallNavigateToUrl(Script);
						break;
					default:
						// Для остальных - через ExternalInterface
						CallExternalInterface(Script);
						break;
				}
				return true;
			}
			return false;
		}
//-----------------------------------------------------------------------------------------------------
		public function BrowserName():uint {
			// Возвращает браузер пользователя
			if (ExternalInterface.available) {
				var Rez:String = (ExternalInterface.call("function (){return navigator.userAgent;}")).toUpperCase();
				if (Rez != null && Rez.indexOf("MSIE")>=0) return BROWSER_IE;
				else if (Rez != null && Rez.indexOf("CHROME") >= 0) {
						if(Rez.indexOf("OPR/")>=0) return BROWSER_OPERA;
						else return BROWSER_CHROME;
					}
				else if (Rez != null && Rez.indexOf("FIREFOX")>=0) return BROWSER_FIREFOX;
				else if (Rez != null && Rez.indexOf("OPERA")>=0) return BROWSER_OPERA;
				else return BROWSER_OTHER;
			}
			else return BROWSER_UNAVAILABLE;
		}
//-----------------------------------------------------------------------------------------------------
		private function CallNavigateToUrl(Script:String):void {
			// Вызов через NavigateToURL
			var Request:URLRequest = new URLRequest();
			Request.url = Vn.Interplanety.HomeDir + Script;
			Request.method = URLRequestMethod.POST;
			var Variables:URLVariables = new URLVariables();
			Request.data = Variables;
			if (Interplanety.SId != null && Interplanety.SId.VnSessionId != "0") Request.data["session_id"] = Interplanety.SId.VnSessionId;
			navigateToURL(Request, "_blank");
		}
//-----------------------------------------------------------------------------------------------------
		private function CallExternalInterface(Script:String):void {
			// Вызов через ExternalInterface
			ExternalInterface.call("window.open", Script, "_blank");
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