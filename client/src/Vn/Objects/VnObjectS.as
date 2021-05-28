package Vn.Objects {
	// Класс объект - спрайт
//-----------------------------------------------------------------------------------------------------
	import flash.events.Event;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import Vn.Graphic.ImgInfo;
	import Vn.Interplanety;
	import Vn.Math.Vector2;
	import Vn.Graphic.VnImage;
//-----------------------------------------------------------------------------------------------------
	public class VnObjectS extends VnObjectL {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		protected var Image:VnImage;		// Укзатель на изображение
		protected var CurrentFrame:uint;	// Номер текущего кадра
		public var Img:Bitmap;				// Указатель на текущее рабочее изображение
		// Константы сообщений
		public static const LOADED:String = "EvVnObjectSLoaded";	// Данные загружены
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function VnObjectS() {
			// Конструктор предка
			super();
			// Конструктор
			CurrentFrame = 0;
			Image = new VnImage();
			SetLocalPosition(Image.Info.Cx,Image.Info.Cy);	// Установить новый центр
			Img = new Bitmap();
			addChild(Img);
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		override public function _delete():void {
			// Деструктор
			removeChild(Img);
			Img = null;
			if(Image.hasEventListener(VnImage.DATA_LOADED)) Image.removeEventListener(VnImage.DATA_LOADED,OnImageLoaded);
			Image = null;	// Сам объект не удаляется, им занимается GraphicManager
			// Деструктор предка
			super._delete();
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		public function ReLoadById(NewId:uint):void {
			// Перезагрузить изображение по Id
//			Id = NewId;
			Image = Vn.Interplanety.Graphic.GetImageById(NewId);
			SetLocalPosition(Image.Info.Cx,Image.Info.Cy);
			// Если изображение не загружено данными - загрузить
			if(Image.Loaded==false) {
//if (Image.Info.Id == 17) trace("earth (space object)");
				Image.addEventListener(VnImage.DATA_LOADED, OnImageLoaded);
			}
			else {
				OnImageLoaded(null);
			}
		}
//-----------------------------------------------------------------------------------------------------
		public function ReloadByType(ObjectType:String,ObjectId:uint=0,Cx:uint=20,Cy:uint=20):void {
			// Перезагрузить изображение по типу
			Image = Vn.Interplanety.Graphic.GetImageByType(ObjectType,ObjectId,Cx,Cy);
			SetLocalPosition(Image.Info.Cx,Image.Info.Cy);
			// Если изображение не загружено данными - загрузить
			if(Image.Loaded==false) {
				Image.addEventListener(VnImage.DATA_LOADED,OnImageLoaded);
			}
			else {
				OnImageLoaded(null);
			}
		}
//-----------------------------------------------------------------------------------------------------
		public function ReloadByImage(NewImage:VnImage):void {
			// Перезагрузить изображение из VnImage
			Image = NewImage;
			SetLocalPosition(Image.Info.Cx,Image.Info.Cy);
			// Если изображение не загружено данными - загрузить
			if(Image.Loaded==false) {
				Image.addEventListener(VnImage.DATA_LOADED, OnImageLoaded);
//				Image.LoadData();
			}
			else {
				OnImageLoaded(null);
			}
		}
//-----------------------------------------------------------------------------------------------------
		public function ShowFrame(FrameNumber:uint):void {
			CurrentFrame = FrameNumber;
			if(Img.bitmapData!=Image.Data[CurrentFrame]) {
				Img.bitmapData = Image.Data[CurrentFrame];
				Img.smoothing = true;
			}
		}
//-----------------------------------------------------------------------------------------------------
		override public function hitTestPoint(x:Number,y:Number,shapeFlag:Boolean=false):Boolean {
			// Переопределение hitTestPoint на работу с пикселами
			// x,y приходят в глобальных координатах
			if(shapeFlag==false) return super.hitTestPoint(x,y,shapeFlag);
			else {
				// Проверка по пикселам
				var LocalPoint:Vector2 = GlobalToLocal(new Vector2(x,y));
				return Img.bitmapData.hitTest(new Point(0,0),0x00,Point(LocalPoint));
			}
		}
//-----------------------------------------------------------------------------------------------------
		public function Clone():VnObjectS {
			// Создает копию текущего объекта и возвращает указатель на нее
			var CloneSprite:VnObjectS = new VnObjectS();
			// Скопировать данные
			CloneSprite.Image = Image;
			CloneSprite.CurrentFrame = CurrentFrame;
			CloneSprite.Img.bitmapData = Img.bitmapData;
			CloneSprite.Img.smoothing = true;
			CloneSprite.SetLocalPosition(Image.Info.Cx,Image.Info.Cy);
			return CloneSprite;
		}
//-----------------------------------------------------------------------------------------------------
// Обработка событий
//-----------------------------------------------------------------------------------------------------
		private function OnImageLoaded(e:Event):void {
			if(Image.hasEventListener(VnImage.DATA_LOADED)) {
				Image.removeEventListener(VnImage.DATA_LOADED,OnImageLoaded);
			}
			ShowFrame(CurrentFrame);
			dispatchEvent(new Event(VnObjectS.LOADED));
		}
//-----------------------------------------------------------------------------------------------------
		override protected function OnAddToStage(e:Event):void {
			// При добавлении в список отображения
			// Выровнять центр объекта по центру того объекта, к которому добавляем
//if(SpaceObjectId == 7) trace("addtostage");
//if(SpaceObjectId == 7) trace(NeedPlace);
			if (NeedPlace == true) RePlace();
		}
//-----------------------------------------------------------------------------------------------------
		override protected function OnRemoveFromStage(e:Event):void {
			// При удалении из списка отображения
//			trace("c");
		}
//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------
		public function get ImageInfo():ImgInfo {
			return Image.Info;
		}
//-----------------------------------------------------------------------------------------------------
		public function get Loaded():Boolean {
			return Image.Loaded;
		}
//-----------------------------------------------------------------------------------------------------
	}
}