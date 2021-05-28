package Vn.Industry {
//-----------------------------------------------------------------------------------------------------
// Производство
//-----------------------------------------------------------------------------------------------------
	import flash.events.Event;
	import flash.system.System;
	import Vn.Objects.Var.LoadedObject;
	import Vn.Objects.VnObjectS;
//-----------------------------------------------------------------------------------------------------
	public class Industry extends LoadedObject {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		private var lType:uint;					// Тип производства (тип контейнера на корабле)
		private var lIndustryTypeImage:VnObjectS;	// Изображение типа производства
		private var IndustryName:uint;			// Название производства
		private var IndustryImage:VnObjectS;	// Изображение
		// Константы сообщений
		public static const LOADED:String = "EvIndustryLoaded";	// Данные загружены
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function Industry(vId:uint) {
			// Конструктор предка
			super();
			// Конструктор
			Id = vId;
			Name = 0;
			Script = "getindustry.php";
			IndustryImage = new VnObjectS();
			lIndustryTypeImage = new VnObjectS();
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		override public function _delete():void {
			// Деструктор
			IndustryImage._delete();
			IndustryImage = null;
			lIndustryTypeImage._delete();
			lIndustryTypeImage = null;
			// Деструктор предка
			super._delete();
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		override protected function SetScriptParams():void {
			// Установка параметров загрузчика
			AddScriptParam("IndustryId",String(Id));
		}
//-----------------------------------------------------------------------------------------------------
// Обработка событий
//-----------------------------------------------------------------------------------------------------
		override protected function OnComplete(e:Event):void {
			// Данные о объекте производства получены
			try {
				var Data:XML = new XML(e.target.data);
			}
			catch (e1:Error) {
				trace(e.target.data);
				trace("------");
				trace(e1.toString());
				trace("------");
			}
			Name = uint(Data.child("name"));
			Type = uint(Data.child("type"));
			TypeImage.addEventListener(VnObjectS.LOADED, OnLoaded);
			TypeImage.ReLoadById(uint(Data.child("typeimg30x30")));
			Image.addEventListener(VnObjectS.LOADED, OnLoaded);
			Image.ReLoadById(uint(Data.child("img")));
			System.disposeXML(Data);
		}
//-----------------------------------------------------------------------------------------------------
		private function OnLoaded(e:Event):void {
			// Полная загрузка объекта
			e.target.removeEventListener(VnObjectS.LOADED, OnLoaded);
			if (Image.Loaded == true && TypeImage.Loaded == true) {
//				Image.removeEventListener(VnObjectS.LOADED, OnLoaded);
//				TypeImage.removeEventListener(VnObjectS.LOADED, OnLoaded);
				dispatchEvent(new Event(Industry.LOADED));
			}
		}
//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------
		public function get Type():uint {
			return lType;
		}
//-----------------------------------------------------------------------------------------------------
		public function set Type(Value:uint):void {
			lType = Value;
		}
//-----------------------------------------------------------------------------------------------------
		public function get Name():uint {
			return IndustryName;
		}
//-----------------------------------------------------------------------------------------------------
		public function set Name(Value:uint):void {
			IndustryName = Value;
		}
//-----------------------------------------------------------------------------------------------------
		public function get Image():VnObjectS {
			return IndustryImage;
		}
//-----------------------------------------------------------------------------------------------------
		public function get TypeImage():VnObjectS {
			return lIndustryTypeImage;
		}
//-----------------------------------------------------------------------------------------------------
	}
}