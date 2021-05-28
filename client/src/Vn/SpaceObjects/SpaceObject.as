package Vn.SpaceObjects {
//-----------------------------------------------------------------------------------------------------
// Класс: все космические объекты (все, включая орбиты)
//-----------------------------------------------------------------------------------------------------
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.EventPhase;
	import flash.filters.GlowFilter;
	import flash.filters.BitmapFilterQuality;
	import Vn.Math.Vector2;
	import Vn.Objects.VnObjectD;
	import Vn.Objects.VnObjectL;
	import Vn.Synchronize.ServerTime;
//-----------------------------------------------------------------------------------------------------
	public class SpaceObject extends VnObjectL {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		private var lSpaceObjectId:uint;	// spaceobject_id
		private var lStarSystemId:uint;		// Id звездной системы, в которой находится данный объект
		private var lLoaded:Boolean;		// false - не загружен, true - загружен
		private var ObjectTrace:SpaceObject;		// Траектория движения
		private var lTraceId:uint;			// Id траэктории
		protected var l_X:Number;			// X - координата местоположения, если стационарный объект
		protected var l_Y:Number;			// Y - координата местоположения, если стационарный объект
		protected var l_Z:Number;			// Z - координата местоположения, если стационарный объект (пока не используется)
		protected var lSpaceObjectImage:VnObjectD;	// Изображение
		private var lBackLinghtable:Boolean;	// true - подсветка при наведении, false - не подсвечивается
		// Константы сообщений
		public static const LOADED:String = "EvSpaceObjectLoaded";	// Завершена загрузка данных
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function SpaceObject() {
			// Конструктор предка
			super();
			// Конструктор
			Loaded = false;
			Name = 29;	// "Undefined"
			lTraceId = 0;
			ObjectTrace = null;
			l_X = 0.0;
			l_Y = 0.0;
			l_Z = 0.0;
			lSpaceObjectImage = null;
			BackLightable = false;
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		override public function _delete():void {
			// Деструктор
			lSpaceObjectImage = null;
			// Деструктор предка
			super._delete();
			}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		override public function LoadFromXML(Data:XML):void {
			// Заполнение данными из XML
			Name = uint(Data.child("name"));
			lTraceId = uint(Data.child("sub_id"));
			lStarSystemId = uint(Data.child("ss_id"));
			Id = uint(Data.child("id"));
			SpaceObjectId = uint(Data.attribute("id"));
			if(Data.child("s_point_x").length()>0) l_X = Number(Data.child("s_point_x"));
			if(Data.child("s_point_y").length()>0) l_Y = Number(Data.child("s_point_y"));
			if (Data.child("s_point_z").length() > 0) l_Z = Number(Data.child("s_point_z"));
			Loaded = true;
		}
//-----------------------------------------------------------------------------------------------------
		override public function Update():void {
			// Изменение состояния
			super.Update();
			// Пересчет положения на орбите
			if(Trace!=null) {
				var NewPos:Vector2;
				if(ServerTime.Time != 0.0) NewPos = Trace.CountPos(ServerTime.Time);
				else NewPos = Trace.CountPos(1.0);
//if (SpaceObjectId == 7) trace(NewPos.toString());
				MoveInto(NewPos);
			}
			// Отыгрыш анимации
			PlayAnimation();
		}
//-----------------------------------------------------------------------------------------------------
		protected function PlayAnimation():void {
			// Проигрыш анимации - переопределяется в наследниках
		}
//-----------------------------------------------------------------------------------------------------
		private function OnMouseOver(e:MouseEvent):void {
			// Перерисовка объекта
			if(e.eventPhase==EventPhase.AT_TARGET) {
				if(BackLightable==true) {
					var glow:GlowFilter = new GlowFilter();
					glow.color = 0x00ffff;
					glow.alpha = 1;
					glow.blurX = 5;
					glow.blurY = 5;
					glow.quality = BitmapFilterQuality.MEDIUM;
					lSpaceObjectImage.filters = [glow];
					lSpaceObjectImage.Redraw();
				}
			}
		}
//-----------------------------------------------------------------------------------------------------
		private function OnMouseOut(e:MouseEvent):void {
			// Перерисовка объекта
			if (e.eventPhase == EventPhase.AT_TARGET) {
				if (lSpaceObjectImage.filters != []) {
					lSpaceObjectImage.filters = [];
					lSpaceObjectImage.Redraw();
				}
			}
		}
//-----------------------------------------------------------------------------------------------------
		public function CountPos(Time:Number):Vector2 {
			// Вовзращает текущее положение для чайлда
			return GetPosition();
			}
//-----------------------------------------------------------------------------------------------------
// Обработка событий
//-----------------------------------------------------------------------------------------------------
		override protected function OnAddToStage(e:Event):void {
			// При добавлении в список отображения
			super.OnAddToStage(e);
			// Движение мышки
			addEventListener(MouseEvent.MOUSE_OVER, OnMouseOver);
			addEventListener(MouseEvent.MOUSE_OUT, OnMouseOut);
		}
//-----------------------------------------------------------------------------------------------------
		override protected function OnRemoveFromStage(e:Event):void {
			// При удалении из списка отображения
			// Убрать обработку сообщений мышки
			removeEventListener(MouseEvent.MOUSE_OVER, OnMouseOver);
			removeEventListener(MouseEvent.MOUSE_OUT, OnMouseOut);
			super.OnRemoveFromStage(e);
		}
//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------
		public function get SpaceObjectId():uint {
			return lSpaceObjectId;	// spaceobject_id
		}
//-----------------------------------------------------------------------------------------------------
		public function set SpaceObjectId(Value:uint):void {
			lSpaceObjectId = Value;
		}
//-----------------------------------------------------------------------------------------------------
		public function get Loaded():Boolean {
			return lLoaded;		// Индикатор загруженности данными
		}
//-----------------------------------------------------------------------------------------------------
		public function set Loaded(Value:Boolean):void {
			lLoaded = Value;
		}
//-----------------------------------------------------------------------------------------------------
		public function get Trace():SpaceObject {	// Орбита
			return ObjectTrace;
		}
//-----------------------------------------------------------------------------------------------------
		public function set Trace(Value:SpaceObject):void {
			ObjectTrace = Value;
		}
//-----------------------------------------------------------------------------------------------------
		public function get BackLightable():Boolean {	// Подсветка
			return lBackLinghtable;
		}
//-----------------------------------------------------------------------------------------------------
		public function set BackLightable(Value:Boolean):void {
			lBackLinghtable = Value;
		}
//-----------------------------------------------------------------------------------------------------
		public function get StatCoordinates():Vector2 {	// Координаты местоположения (если стационарный объект)
			return new Vector2(l_X, l_Y);
		}
//-----------------------------------------------------------------------------------------------------
		public function get TraceId():uint {	// Id траэктории
			return lTraceId;
		}
//-----------------------------------------------------------------------------------------------------
		public function get StarSystemId():uint {	// Id звездной системы
			return lStarSystemId;
		}
//-----------------------------------------------------------------------------------------------------
	}
}