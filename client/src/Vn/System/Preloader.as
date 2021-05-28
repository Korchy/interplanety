package Vn.System {
	// Preloader
//-----------------------------------------------------------------------------------------------------
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import Vn.Interface.ProgressBar.ProgressBar;
	import Vn.Objects.VnObjectS;
	import Vn.Objects.VnObjectR;
	import Vn.Graphic.ImgInfo;
	import Vn.Graphic.VnImage;
//-----------------------------------------------------------------------------------------------------
	public class Preloader extends VnObjectR {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		private var ImgI:VnImage;	// Данные по центральной картинке
		private var Img:VnObjectS;	// Спарайт с центральной картинкой
		private var PBar:ProgressBar;	// ProgerssBar
		private var CheckArray:Array;	// Массив для контроля объектов с прелоудом
		private var FillEnable:Boolean;	// true - можно добавлять объекты для контроля, false - нет
		// Константы событий
		public static const ALL_PRELOADED:String = "EvPreloaderAllLoaded";	// Все загружено
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function Preloader() {
			// Конструктор родителя
			super();
			// Конструктор
			SetLocalPosition(110,66);
			// Загрузить изображение
			ImgI = new VnImage();
			var ImgItxt:ImgInfo = new ImgInfo();
			ImgItxt.Path = "graphic/interface";
			ImgItxt.Name = "preloader";
			ImgItxt.Cx = 110;
			ImgItxt.Cy = 66;
			ImgI.Info = ImgItxt;	// Конструктор копирования
			ImgI.LoadData();
			// Загруженное изображение поместить в спрайт. Показать спрайт.
			Img = new VnObjectS();
			Img.ReloadByImage(ImgI);
			addChild(Img);
			// ProgerssBar
			PBar = new ProgressBar(100,15);
			addChild(PBar);
			PBar.MoveIntoParent(180,30,true);
			// Загрузка
			FillEnable = false;
			CheckArray = new Array(0);
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		override public function _delete():void {
			// Деструктор
			PBar._delete();
			PBar = null;
			if(Img.parent!=null) removeChild(Img);
			Img._delete();
			Img = null;
			ImgI._delete();
			ImgI = null;
			// Очистка загрузок
			for(var i:uint=0;i<CheckArray.length;) {
				if(CheckArray[i]!=undefined&&CheckArray[i]!=null) {
					if(CheckArray[i][0].hasEventListener(CheckArray[i][1])) CheckArray[i][0].removeEventListener(CheckArray[i][1],OnLoaded);
					CheckArray[i].splice(0,3);
					CheckArray[i] = null;
					CheckArray.splice(i,1);
				}
			}
			CheckArray = null;
			// Деструктор родителя
			super._delete();
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		public function AddToCheck(Obj:EventDispatcher,EventType:String):void {
			// Добавляем слежение за объектом Obj, который бросит событие EventType когда загрузить перлоадные данные
			if(FillEnable==true) {
				// Добавить в массив
				CheckArray.push([Obj,EventType,false]);
				PBar.IncreaceAllScale();
				// Ожидать события
				Obj.addEventListener(EventType,OnLoaded);
			}
		}
//-----------------------------------------------------------------------------------------------------
		public function StartFill():void {
			// Разрешаем добавлять объекты для контроля прелоада
			FillEnable = true;
		}
//-----------------------------------------------------------------------------------------------------
		public function EndFill():void {
			// Все объекты для контроля прелоада добавлены
			FillEnable = false;
			// Проверить не загрузилось ли уже все к моменту завершения добавления
			CheckLoaded();
		}
//-----------------------------------------------------------------------------------------------------
		private function CheckLoaded():void {
			// Проверить все ли объекты загрузили свои прелоады
			// Если загрузили - отправить событие
			if(FillEnable==false&&CheckArray.length==0) dispatchEvent(new Event(Preloader.ALL_PRELOADED));
		}
//-----------------------------------------------------------------------------------------------------
// Обработка событий
//-----------------------------------------------------------------------------------------------------
		private function OnLoaded(e:Event):void {
			// Загружена вся предзагружаемая информация объектом e.target
			// Убрать из массива и снять слушатель
			for(var i:uint=0;i<CheckArray.length;i++) {
				if(CheckArray[i][0]==e.target&&CheckArray[i][1]==e.type) {
//trace(CheckArray[i][0]);
					PBar.IncreaceCurrentScale();
					CheckArray[i].splice(0,3);
					CheckArray[i] = null;
					e.target.removeEventListener(e.type,OnLoaded);
					CheckArray.splice(i,1);
					break;
				}
			}
			// Проверить не завершились ли все загрузки
			CheckLoaded();
		}
//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------
		public function get EnableFill():Boolean {
			return FillEnable;
		}
//-----------------------------------------------------------------------------------------------------
	}
}