package Vn.Graphic {
	// Класс "Изображение"
//-----------------------------------------------------------------------------------------------------
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.EventDispatcher;
	import flash.net.URLRequest;
	import Vn.Common.Common;
//-----------------------------------------------------------------------------------------------------
	public class VnImage extends EventDispatcher {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		private var ImageInfo:ImgInfo;	// Данные по изображению
		private var Frames:Array;		// Массив с BitmapData с фреймами изображения
		private var FramesLoader:Loader;		// Загрузчик изображения
		private var FramesRequest:URLRequest;	// Request для загрузчика изображения
		private var CurrentLoadingFrame:int;	// Текущий загружаемый кадр; -1 - загрузки нет
		private var AllFramesLoaded:Boolean;	// true - Загружены все кадры
		// Константы событий
		public static const DATA_LOADED:String = "EvVnImageDataLoaded";	// Идентификатор данные загружены
		public static const DATA_FAIL:String = "EvVnImageDataFail";		// Идентификатор данные НЕ загружены
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function VnImage() {
			// Конструктор предка
			super();
			// Конструктор
			ImageInfo = new ImgInfo();
			Frames = new Array();
			CurrentLoadingFrame = -1;
			Loaded = false;
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		public function _delete():void {
			// Деструктор
			// Очистить Info
			ImageInfo._delete();
			ImageInfo = null;
			// Очистить массив фреймов
			ClearData();
			Frames = null;
			// Загрузчик данных
			if(FramesLoader!=null) {
				if(FramesLoader.contentLoaderInfo.hasEventListener(Event.COMPLETE)) FramesLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE,OnFramesLoadComplete);
				if(FramesLoader.contentLoaderInfo.hasEventListener(IOErrorEvent.IO_ERROR)) FramesLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,OnFramesLoadIoError);
				FramesLoader = null;
				FramesRequest = null;

			}
			// Деструктор предка
//			super._delete();
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		private function ClearData():void {
			// Очистка массива с BitmapData
			for(var i:uint=0;i<Frames.length;) {
				if(Frames[i]!=null&&Frames[i]!=undefined) Frames[i] = null;
				Frames.splice(i,1);
			}
		}
//-----------------------------------------------------------------------------------------------------
		public function LoadData():void {
			// Загрузка данных BitmapData в массив с фреймами
			if (CurrentLoadingFrame == -1) {	// Если загрузка уже не идет
				FramesLoader = new Loader();
				FramesLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,OnFramesLoadComplete);		// Событие окончания процесса загрузки данных
				FramesLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,OnFramesLoadIoError);	// Событие сбоя загрузки файла
				FramesRequest = new URLRequest();
				// Грузим последовательно по кадрам начиная с 0
				CurrentLoadingFrame = 0;
				LoadNextFrame();
			}
		}
//-----------------------------------------------------------------------------------------------------
		private function LoadNextFrame():void {
			// Загрузить следующий кадр
			// Если есть еще кадры - загружать дальше
			if(CurrentLoadingFrame<Info.Frames) {
				// Следующий кадр
				FramesRequest.url = Info.Path+"/"+Info.Name+Common.LeadingNull(String(CurrentLoadingFrame),2)+"."+Info.Ext;
				FramesLoader.load(FramesRequest);
			}
			else {
				// Кадров больше нет - больше ничего не загружаем
				CurrentLoadingFrame = -1;
				Loaded = true;
				FramesLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE,OnFramesLoadComplete);		// Событие окончания процесса загрузки данных
				FramesLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,OnFramesLoadIoError);	// Событие сбоя загрузки файла
				dispatchEvent(new Event(VnImage.DATA_LOADED));
			}
		}
//-----------------------------------------------------------------------------------------------------
// Обработка событий
//-----------------------------------------------------------------------------------------------------
		private function OnFramesLoadComplete(e:Event):void {
			// Загружен очередной фрейм
			// Если загрузка идет нормально - добавить полученный кадр в список
			Frames[CurrentLoadingFrame] = Bitmap(FramesLoader.content).bitmapData;
			FramesLoader.unload();
			CurrentLoadingFrame++;
			LoadNextFrame();
		}
//-----------------------------------------------------------------------------------------------------
		private function OnFramesLoadIoError(e:Event):void {
			// Очередной кадр НЕ получен
			if(CurrentLoadingFrame==0) {
				// Если не загружается первый кадр
				Loaded = false;
				FramesLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE,OnFramesLoadComplete);
				FramesLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, OnFramesLoadIoError);
				dispatchEvent(new Event(VnImage.DATA_FAIL));
				
			}
			else {
				// Если не грузится какой-то из серединных кадров - грузим следующий
				CurrentLoadingFrame++;
				LoadNextFrame();
			}
		}
//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------
		public function set Info(Value:ImgInfo):void {
			// Данные
			ImageInfo = Value;
			for(var i:uint=0;i<uint(ImageInfo.Frames);i++) {
				// Для каждого кадра создать указатель на BitmapData в массиве Frames
				var NewBitmapData:BitmapData;
				Frames.push(NewBitmapData);
			}
		}
//-----------------------------------------------------------------------------------------------------
		public function get Info():ImgInfo {
			return ImageInfo;
		}
//-----------------------------------------------------------------------------------------------------
		public function get Data():Array {
			return Frames;
		}
//-----------------------------------------------------------------------------------------------------
		public function set Loaded(Value:Boolean):void {
			// Изображение загружено данными
			AllFramesLoaded = Value;
		}
//-----------------------------------------------------------------------------------------------------
		public function get Loaded():Boolean {
			return AllFramesLoaded;
		}
//-----------------------------------------------------------------------------------------------------
		public function get LoadInProgerss():Boolean {
			// Идет процесс загрузки изображения данными
			if (CurrentLoadingFrame == -1) return false;
			else return true;
		}
//-----------------------------------------------------------------------------------------------------
	}
}