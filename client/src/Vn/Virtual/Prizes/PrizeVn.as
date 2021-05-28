package Vn.Virtual.Prizes {
	// Менеджер призов
//-----------------------------------------------------------------------------------------------------
	import flash.events.Event;
	import flash.system.System;
	import Vn.Math.Vector2;
	import Vn.Objects.Var.LoadedObject;
	import Vn.Objects.VnObjectS;
	import Vn.SpaceObjects.SpaceObject;
	import Vn.Trade.PriceVn;
	import Vn.Virtual.Prizes.Events.PrizeManagerEventVn;
//-----------------------------------------------------------------------------------------------------
	public class PrizeVn extends LoadedObject {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		private var lSOId:uint;			// SpaceObjectId
		private var lName:uint;			// Название (id в TextDictionary)
		private var lPrice:PriceVn;		// Цена
		private var lImg:VnObjectS;		// Изображение приза 60x60
		private var lStackAmount:uint;	// Количество одинаковых призов в стеке
		// Константы событий
		public static const STACK_AMOUNT_CHANGED:String = "EvStackAmountChanged";	// Изменилось кол-во в стеке
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function PrizeVn(vSpaceObjectId:uint ) {
			// Конструктор предка
			super();
			// Конструктор
			lSOId = vSpaceObjectId;
			lName = 0;
			lPrice = new PriceVn();
			lImg = new VnObjectS();
			lStackAmount = 1;	// По умолчанию 1
			Script = "getprize.php";
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		override public function _delete():void {
			// Деструктор
			lPrice._delete();
			lPrice = null;
			lImg._delete();
			lImg = null;
			// Деструктор предка
			super._delete();
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		override protected function SetScriptParams():void {
			// Параметры загрузки
			AddScriptParam("SpaceObjectId", String(SpaceObjectId));
		}
//-----------------------------------------------------------------------------------------------------
		override protected function OnComplete(e:Event):void {
			// Данные по призу загружены
			try {
				var Data:XML = new XML(e.target.data);
			}
			catch(e1:Error) {
				trace(e.target.data);
			}
			LoadFromXML(Data);
			System.disposeXML(Data);
		}
//-----------------------------------------------------------------------------------------------------
		override protected function OnRefresh(e:Event):void {
			// Загружены обновленные данные по призу
			OnComplete(e);
		}
//-----------------------------------------------------------------------------------------------------
		private function LoadFromXML(Data:XML):void {
			// Заполнение данными из XML
			lName = uint(Data.child("name"));
			if(Data.child("img_60x60").length()>0) lImg.ReLoadById(uint(Data.child("img_60x60")));
			lPrice.Amount = uint(Data.child("price"));
			if (Data.child("price") == "G")	lPrice.Type = PriceVn.GOLD;
			else lPrice.Type = PriceVn.CRYSTALS;
			if(Data.child("stack").length()>0) lStackAmount = uint(Data.child("stack"));
		}
//-----------------------------------------------------------------------------------------------------
		public function ConvertFromStorageToObject(vNewPlace:Vector2, vNewTraceId:uint=0):void {
			// Извлечь приз из хранилища и создать как объект в виртуальной системе
			// NewPlace - в глобальной системе координат
			var InfoArr:Array = new Array();
			InfoArr.push(vNewPlace);	// Координаты положения
			if(vNewTraceId==0) InfoArr.push("null");	// Орбита
			else InfoArr.push(vNewTraceId);
			// Дать указание PrizeManager конвертировать приз
			dispatchEvent(new PrizeManagerEventVn(PrizeManagerEventVn.FROM_STORAGE_TO_OBJECT_TRY, InfoArr));
		}
//-----------------------------------------------------------------------------------------------------
// Обработка событий
//-----------------------------------------------------------------------------------------------------
		public function get SpaceObjectId():uint {
			// SpaceObjectId
			return lSOId;
		}
//-----------------------------------------------------------------------------------------------------
		public function get Name():uint {
			// Название
			return lName;
		}
//-----------------------------------------------------------------------------------------------------
		public function get Price():uint {
			// Цена
			return lPrice.Amount;
		}
//-----------------------------------------------------------------------------------------------------
		public function get PriceType():uint {
			// Тип цены (золото/кристаллы)
			return lPrice.Type;
		}
//-----------------------------------------------------------------------------------------------------
		public function get Image():VnObjectS {
			// Изображение
			return lImg;
		}
//-----------------------------------------------------------------------------------------------------
		public function get StackAmount():uint {
			// Количество одинаковых призов в стеке
			return lStackAmount;
		}
//-----------------------------------------------------------------------------------------------------
		public function set StackAmount(Value:uint):void {
			lStackAmount = Value;
			dispatchEvent(new Event(PrizeVn.STACK_AMOUNT_CHANGED));
		}
//-----------------------------------------------------------------------------------------------------
	}
}