package Vn.ScreenShot 
{
//-----------------------------------------------------------------------------------------------------
// Класс кнопки для создания скриншота
//-----------------------------------------------------------------------------------------------------
	import flash.display.BitmapData;
	import flash.display.JPEGEncoderOptions;
	import flash.events.Event;
	import flash.events.EventPhase;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import Vn.System.ExternalInterfaceVn;
//	import flash.external.ExternalInterface;
//	import flash.net.navigateToURL;
//	import flash.net.URLRequest;
//	import flash.net.URLRequestMethod;
//	import flash.net.URLVariables;
	import flash.utils.ByteArray;
	import Vn.Interface.Button.Button;
	import Vn.Interplanety;
	import Vn.System.ByteArrayUploader;
	import Vn.Text.TextDictionary;
//-----------------------------------------------------------------------------------------------------
	public class ScreenShotButtonVn extends Button {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		private var ScreenShotUploader:ByteArrayUploader;	// Загрузчик скриншота на сервер
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function ScreenShotButtonVn() {
			// Конструктор родителя
			super();
			// Конструктор
			Name = 203;			// SnapShot
			ReLoadById(187);	// screenshot.png
			ScreenShotUploader = new ByteArrayUploader();
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		override public function _delete():void {
			// Деструктор
			if (ScreenShotUploader.hasEventListener(ByteArrayUploader.BYTEARRAY_UPLOADED)) ScreenShotUploader.removeEventListener(ByteArrayUploader.BYTEARRAY_UPLOADED, OnSuccess);
			if (ScreenShotUploader.hasEventListener(ByteArrayUploader.BYTEARRAY_IO_ERROR)) ScreenShotUploader.removeEventListener(ByteArrayUploader.BYTEARRAY_IO_ERROR, OnIOError);
			if (ScreenShotUploader.hasEventListener(ByteArrayUploader.BYTEARRAY_SECURITY_ERROR)) ScreenShotUploader.removeEventListener(ByteArrayUploader.BYTEARRAY_SECURITY_ERROR, OnSecurityError);
			ScreenShotUploader._delete();
			ScreenShotUploader = null;
			// Деструктор родителя
			super._delete();
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		
//-----------------------------------------------------------------------------------------------------
// Обработка событий
//-----------------------------------------------------------------------------------------------------
		override protected function OnClick(e:MouseEvent):void {
			// Нажатие
			if(e.eventPhase==EventPhase.AT_TARGET) {
				// Создание скриншота со звездной системы
				// Отрисовать звездную систему в BitmapData
				var BData:BitmapData = new BitmapData(Interplanety.Universe.CurrentStarSystem.Width, Interplanety.Universe.CurrentStarSystem.Height,false,0x00000000);
				BData.draw(Interplanety.Universe.CurrentStarSystem, Interplanety.Universe.CurrentStarSystem.transform.matrix.clone());
				// Конвертация в формат JPG
				var Image:ByteArray = new ByteArray();
				// При ошибке Variable flash.display::JPEGEncoderOptions is not defined при компиляции под FP версии выше 13 - в Project - Properties - Compiler options - Additional compiler options добавить строчку -swf-version=18
				BData.encode(new Rectangle(0, 0, Interplanety.Universe.CurrentStarSystem.Width, Interplanety.Universe.CurrentStarSystem.Height), new JPEGEncoderOptions(100), Image);
				// Отправить на сервер
				ScreenShotUploader.Data = Image;
				ScreenShotUploader.addEventListener(ByteArrayUploader.BYTEARRAY_UPLOADED, OnSuccess);
				ScreenShotUploader.addEventListener(ByteArrayUploader.BYTEARRAY_IO_ERROR, OnIOError);
				ScreenShotUploader.addEventListener(ByteArrayUploader.BYTEARRAY_SECURITY_ERROR, OnSecurityError);
				var Rez:Boolean = ScreenShotUploader.Upload();
			}
		}
//-----------------------------------------------------------------------------------------------------
		private function OnSuccess(e:Event):void {
			// Загрузка выполнена
			ScreenShotUploader.removeEventListener(ByteArrayUploader.BYTEARRAY_UPLOADED, OnSuccess);
			ScreenShotUploader.removeEventListener(ByteArrayUploader.BYTEARRAY_IO_ERROR, OnIOError);
			ScreenShotUploader.removeEventListener(ByteArrayUploader.BYTEARRAY_SECURITY_ERROR, OnSecurityError);
			// Открыть скрин в отдельном окне
/*			var Request:URLRequest = new URLRequest();
			Request.url = Vn.Interplanety.HomeDir + "vssscr.php";
			Request.method = URLRequestMethod.POST;
			var Variables:URLVariables = new URLVariables();
			Request.data = Variables;
			if (Interplanety.SId != null && Interplanety.SId.VnSessionId != "0") Request.data["session_id"] = Interplanety.SId.VnSessionId;
			navigateToURL(Request, "_blank");
*/
			// Через ExternalInterface а не через navigateToURL т.к. navigateToURL с параметром _blank открывает в хроме и опере действительно в новом окне, а не в новой вкладке
/*			if (ExternalInterface.available) {
				ExternalInterface.call("window.open", "vssscr.php", "_blank");
				var browserAgent:String = ExternalInterface.call("function (){return navigator.userAgent;}");
				Interplanety.Cons.Add(browserAgent);
			}
			*/
			var ExtInt:ExternalInterfaceVn = new ExternalInterfaceVn();
			ExtInt.OpenNewTab("vssscr.php");
		}
//-----------------------------------------------------------------------------------------------------
		private function OnIOError(e:Event):void {
			// IO Error
			ScreenShotUploader.removeEventListener(ByteArrayUploader.BYTEARRAY_UPLOADED, OnSuccess);
			ScreenShotUploader.removeEventListener(ByteArrayUploader.BYTEARRAY_IO_ERROR, OnIOError);
			ScreenShotUploader.removeEventListener(ByteArrayUploader.BYTEARRAY_SECURITY_ERROR, OnSecurityError);
			Interplanety.Cons.Add(TextDictionary.Text(117));	// Системная ошибка
		}
//-----------------------------------------------------------------------------------------------------
		private function OnSecurityError(e:Event):void {
			// Security Error
			ScreenShotUploader.removeEventListener(ByteArrayUploader.BYTEARRAY_UPLOADED, OnSuccess);
			ScreenShotUploader.removeEventListener(ByteArrayUploader.BYTEARRAY_IO_ERROR, OnIOError);
			ScreenShotUploader.removeEventListener(ByteArrayUploader.BYTEARRAY_SECURITY_ERROR, OnSecurityError);
			Interplanety.Cons.Add(TextDictionary.Text(117));	// Системная ошибка
		}
//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------

//-----------------------------------------------------------------------------------------------------
	}
}