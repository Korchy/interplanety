package Vn.Graphic {
	// Класс - список всех графических объектов
//-----------------------------------------------------------------------------------------------------
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import Vn.Graphic.ImgInfo;
	import Vn.System.PHPLoader;
	import Vn.Graphic.VnImage;
//-----------------------------------------------------------------------------------------------------
	public class GraphicManager extends EventDispatcher {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		private static var ImageList:Array = new Array();	// Массив изображений
		private var InfoLoader:PHPLoader;		// Загрузка данных о графике
		private var ScriptInfo:String;			// Скрипт для загрузки
		private var PreloadImageList:Array;		// Массив изображений, которые нужно загружать сразу
		// Константы событий
		public static const INFO_LOADED:String = "EvGraphicManamgerInfoLoaded";	// Идентификатор "данные о графике загружены"
		public static const INFO_FAIL:String = "EvGraphicManagerInfoFail";		// Идентификатор "данные о графике НЕ загружены"
		public static const PRELOAD_LOADED:String = "EvGraphicManamgerPreloadLoaded";	// Все предзагружаемые изображения загрузились
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function GraphicManager() {
			// Конструктор предка
			super();
			// Конструктор
			ScriptInfo = "getgraphics.php";
			InfoLoader = new PHPLoader();
			PreloadImageList = new Array();
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		public function _delete():void {
			// Деструктор
			// Загрузчик данных
			if(InfoLoader!=null) {
				if(InfoLoader.hasEventListener(Event.COMPLETE)) InfoLoader.removeEventListener(Event.COMPLETE,OnInfoComplete);
				if(InfoLoader.hasEventListener(IOErrorEvent.IO_ERROR)) InfoLoader.removeEventListener(IOErrorEvent.IO_ERROR,OnInfoIoError);
				InfoLoader._delete();
				InfoLoader = null;
			}
			// Удалить изображения
			for(var i:uint=0;i<ImageList.length;) {
				if(ImageList[i]!=null&&ImageList[i]!=undefined) {
					ImageList[i]._delete();
					ImageList[i] = null;
				}
				ImageList.splice(i,1);
			}
			// Массив изображений для предзагрузки только очищаем т.к. в нем указатели на те же изображения, что и в ImageList
			if(PreloadImageList!=null) {
				for(var i1:uint=0;i1<PreloadImageList.length;) {
					PreloadImageList.splice(i1,1);
				}
				PreloadImageList = null;
			}
			// Деструктор предка
//			super._delete();
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		public function LoadInfo():void {
			// Получить данные о графике
			InfoLoader.addEventListener(Event.COMPLETE,OnInfoComplete);
			InfoLoader.addEventListener(IOErrorEvent.IO_ERROR,OnInfoIoError);
			InfoLoader.Load(ScriptInfo);
		}
//-----------------------------------------------------------------------------------------------------
		public function GetImageById(Id:uint):VnImage {
			// Получить изображение по Id
			for(var i:uint=0;i<ImageList.length;i++) {
				if(ImageList[i]!=null&&ImageList[i]!=undefined) {
					if(ImageList[i].Info.Id==Id) {
						// Если изображение не загружено данными - загрузить
						if(VnImage(ImageList[i]).Loaded==false) VnImage(ImageList[i]).LoadData();
						// Вернуть указатель на изображение
						return ImageList[i];
					}
				}
			}
			return GetImageById(129);	// Если не найдено - возвращаем дефолтное
		}
//-----------------------------------------------------------------------------------------------------
		public function GetImageByType(ObjectType:String,ObjectId:uint,Cx:uint,Cy:uint,Frames:uint=1):VnImage {
			// Получить изображение по типу
			for(var i:uint=0;i<ImageList.length;i++) {
				if(ImageList[i]!=null&&ImageList[i]!=undefined) {
//					if(ImageList[i].Info.ObjectType==ObjectType&&ImageList[i].Info.ObjectId==ObjectId&&ImageList[i].Info.Cx==Cx&&ImageList[i].Info.Cy==Cy&&ImageList[i].Info.Frames==Frames) {
					if(ImageList[i].Info.ObjectType==ObjectType&&ImageList[i].Info.ObjectId==ObjectId&&ImageList[i].Info.Cx==Cx&&ImageList[i].Info.Cy==Cy) {
						// Если изображение не загружено данными - загрузить
						if(VnImage(ImageList[i]).Loaded==false) VnImage(ImageList[i]).LoadData();
						// Вернуть указатель на изображение
						return ImageList[i];
					}
				}
			}
			return GetImageById(129);	// Если не найдено - возвращаем дефолтное
		}
//-----------------------------------------------------------------------------------------------------
		public function GetImageByName(Name:String):VnImage {
			// Получить изображение по имени
			for(var i:uint=0;i<ImageList.length;i++) {
				if(ImageList[i]!=null&&ImageList[i]!=undefined) {
					if(ImageList[i].Info.Name==Name) {
						// Если изображение не загружено данными - загрузить
						if(VnImage(ImageList[i]).Loaded==false) VnImage(ImageList[i]).LoadData();
						// Вернуть указатель на изображение
						return ImageList[i];
					}
				}
			}
			return GetImageById(129);	// Если не найдено - возвращаем дефолтное
		}
//-----------------------------------------------------------------------------------------------------
		private function Preload():void {
			// Вызвать предзагрузку определенных изображений
			if(PreloadImageList.length!=0) {
				// Грузим изображения одно за другим
				if(PreloadImageList[0].Loaded==false&&PreloadImageList[0].LoadInProgerss==false) {
					PreloadImageList[0].addEventListener(VnImage.DATA_LOADED,OnImageLoaded);
					PreloadImageList[0].addEventListener(VnImage.DATA_FAIL,OnImageLoaded);	// Если изображение не загрузилось (физически нет картинки) - все равно продолжаем работу
					PreloadImageList[0].LoadData();
				}
				else {
					PreloadImageList.splice(0,1);
					Preload();
				}
			}
			else {
				// Все предзагружаемые изображения загрузились
				PreloadImageList = null;
				dispatchEvent(new Event(GraphicManager.PRELOAD_LOADED));
			}
		}
//-----------------------------------------------------------------------------------------------------
// Обработка событий
//-----------------------------------------------------------------------------------------------------
		private function OnInfoComplete(e:Event):void {
			// Данные о графике получены
			var InfoArray:Array = String(e.target.data).split(";");
			for(var i:uint=0;i<InfoArray.length;i++) {
				// Новое изображение
				var NewImage:VnImage = new VnImage();
				// Info по изображению
				var NewImgInfo:ImgInfo = new ImgInfo();
				var ImageInfoArray:Array = InfoArray[i].split(",");
				NewImgInfo.Id = uint(ImageInfoArray[0]);
				NewImgInfo.ObjectType = ImageInfoArray[1];
				NewImgInfo.ObjectId = uint(ImageInfoArray[2]);
				NewImgInfo.Cx = uint(ImageInfoArray[3]);
				NewImgInfo.Cy = uint(ImageInfoArray[4]);
				NewImgInfo.Path = ImageInfoArray[5];
				NewImgInfo.Name = ImageInfoArray[6];
				NewImgInfo.Ext = ImageInfoArray[7];
				NewImgInfo.Frames = uint(ImageInfoArray[8]);
				NewImage.Info = NewImgInfo;
//				NewImage.LoadData();
				// Занести в массив изображений
				ImageList.push(NewImage);
				if(ImageInfoArray[9]=="T") PreloadImageList.push(NewImage);	// Для предзагрузки
			}
			// Отсоединить слушатели и отправить событие загрузки данных
			InfoLoader.removeEventListener(Event.COMPLETE,OnInfoComplete);
			InfoLoader.removeEventListener(IOErrorEvent.IO_ERROR,OnInfoIoError);
			dispatchEvent(new Event(GraphicManager.INFO_LOADED));
			// Отдельным потоком начинаем грузить графику по массиву предзагрузки
			Preload();
		}
//-----------------------------------------------------------------------------------------------------
		private function OnInfoIoError(e:Event):void {
			// Ошибка получения данных о графике
			InfoLoader.removeEventListener(Event.COMPLETE,OnInfoComplete);
			InfoLoader.removeEventListener(IOErrorEvent.IO_ERROR,OnInfoIoError);
			dispatchEvent(new Event(GraphicManager.INFO_FAIL));
		}
//-----------------------------------------------------------------------------------------------------
		private function OnImageLoaded(e:Event):void {
			// Загрузка данных в изображение
			e.target.removeEventListener(VnImage.DATA_LOADED,OnImageLoaded);
			e.target.removeEventListener(VnImage.DATA_FAIL,OnImageLoaded);
			PreloadImageList.splice(0,1);
			Preload();
		}
//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------

//-----------------------------------------------------------------------------------------------------
	}
}