package Vn.Virtual.Prizes {
	// Менеджер призов
//-----------------------------------------------------------------------------------------------------
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.EventDispatcher;
	import flash.system.System;
	import Vn.Common.LoadStatusVn;
	import Vn.Interplanety;
	import Vn.Objects.Var.LoadedObject;
	import Vn.System.PHPLoader;
	import Vn.Virtual.Prizes.Events.PrizeManagerEventVn;
//-----------------------------------------------------------------------------------------------------
	public class PrizesManagerVn extends EventDispatcher {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		private var lPrizesLoader:PHPLoader;	// Загрузчик призов
		private var lLoaderScript:String;		// Скрипт для загрузки
		private var lPrizes:Array;				// Массив со списком призов
		private var lPrizesConverter:PHPLoader;	// Конвертер призов из хранилища в объект виртуальной системы
		private var lConverterScript:String;	// Скнипт для конвертации
		// Константы сообщений
		public static const PRIZES_LOAD_SUCCESS:String = "EvPrizesLoadedSuccess";		// Загрузка завершена
		public static const PRIZES_LOAD_FAIL:String = "EvPrizesLoadedFail";				// Ошибка загрузки
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function PrizesManagerVn() {
			// Конструктор предка
			super();
			// Конструктор
			lLoaderScript = "getstarsystemvirtualstorage.php";
			lPrizesLoader = new PHPLoader();
			LoadPrizes();	// Создать список призов
			lPrizes = new Array();
			lConverterScript = "convertprizeobjectfromstorage.php";
			lPrizesConverter = new PHPLoader();
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		public function _delete():void {
			// Деструктор
			if(lPrizesLoader.hasEventListener(Event.COMPLETE)) lPrizesLoader.removeEventListener(Event.COMPLETE,OnLoadPrizesComplete);
			if(lPrizesLoader.hasEventListener(IOErrorEvent.IO_ERROR)) lPrizesLoader.removeEventListener(IOErrorEvent.IO_ERROR,OnLoadPrizesIoError);
			lPrizesLoader._delete();
			lPrizesLoader = null;
			if(lPrizesConverter.hasEventListener(Event.COMPLETE)) lPrizesConverter.removeEventListener(Event.COMPLETE,OnPrizeConverted);
			if(lPrizesConverter.hasEventListener(IOErrorEvent.IO_ERROR)) lPrizesConverter.removeEventListener(IOErrorEvent.IO_ERROR,OnPrizeConvertedError);
			lPrizesConverter._delete();
			lPrizesConverter = null;
			// Очистить список призов
			for(var i:uint=0;i<lPrizes.length;) {
				if (lPrizes[i] != null && lPrizes[i] != undefined) {
					lPrizes[i].removeEventListener(PrizeManagerEventVn.FROM_STORAGE_TO_OBJECT_TRY, OnObjectFromStorage);
					lPrizes[i]._delete();
				}
				lPrizes.splice(i,1);
			}
			// Деструктор предка
//			super._delete();
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		public function LoadPrizes():void {
			// Загрузить список призов
			lPrizesLoader.addEventListener(Event.COMPLETE,OnLoadPrizesComplete);
			lPrizesLoader.addEventListener(IOErrorEvent.IO_ERROR,OnLoadPrizesIoError);
			lPrizesLoader.Load(lLoaderScript);
		}
//-----------------------------------------------------------------------------------------------------
		public function AddBySOId(vSOId:uint):void {
			// Добавление в список призов приза с указанным SpaceObjectId
			var CurrentPrize:PrizeVn = GetBySOId(vSOId);
			if(CurrentPrize==null) {
				// Такого приза нет в списке - создать
				CurrentPrize = new PrizeVn(vSOId);
//				CurrentPrize.Load();	// Загрузить данные по призу (пока грузится только при создании иконки в списке в окне призов)
				CurrentPrize.addEventListener(PrizeManagerEventVn.FROM_STORAGE_TO_OBJECT_TRY, OnObjectFromStorage);
				lPrizes.push(CurrentPrize);
			}
			else {
				// Если такой приз в списке уже есть и был загружен - обновить данные (чтобы получить новое значение стека)
				if (CurrentPrize.Status == LoadStatusVn.LOADED) CurrentPrize.Refresh();
			}
		}
//-----------------------------------------------------------------------------------------------------
		private function GetBySOId(vSOId:uint):PrizeVn {
			// Найти приз по его SpaceObjectId
			for (var i:uint; i < PrizesAmount; i++) {
				if (Prizes[i].SpaceObjectId == vSOId) {
					return Prizes[i];
					break;
				}
			}
			return null;
		}
//-----------------------------------------------------------------------------------------------------
		private function DeleteBySOId(vSOId:uint):void {
			// Удалить приз по его SpaceObjectId
			for (var i:uint = 0; i < PrizesAmount; i++) {
				if (lPrizes[i].SpaceObjectId == vSOId) {
					lPrizes[i].removeEventListener(PrizeManagerEventVn.FROM_STORAGE_TO_OBJECT_TRY, OnObjectFromStorage);
					lPrizes[i]._delete();
					lPrizes.splice(i, 1);
					break;
				}
			}
		}
//-----------------------------------------------------------------------------------------------------
// Обработка событий
//-----------------------------------------------------------------------------------------------------
		private function OnLoadPrizesComplete(e:Event):void {
			// Данные получены
			lPrizesLoader.removeEventListener(Event.COMPLETE,OnLoadPrizesComplete);
			lPrizesLoader.removeEventListener(IOErrorEvent.IO_ERROR, OnLoadPrizesIoError);
			// Заполнить массив загруженными призами
			try {
				var Data:XML = new XML(e.target.data);
			}
			catch(e1:Error) {
				trace(e.target.data);
			}
			LoadFromXML(Data);
			System.disposeXML(Data);
			// Данные загружены
			dispatchEvent(new Event(PrizesManagerVn.PRIZES_LOAD_SUCCESS));
		}
//-----------------------------------------------------------------------------------------------------
		public function LoadFromXML(Data:XML):void {
			// Создание списка призов из XML
			for each (var Node:XML in Data.*) {
				// По каждому узлу добавляем приз в список
				if (Node.nodeKind() == "element") AddBySOId(uint(Node));	// soid
			}
		}
//-----------------------------------------------------------------------------------------------------
		private function OnLoadPrizesIoError(e:IOErrorEvent):void {
			// Ошибка получения данных
			lPrizesLoader.removeEventListener(Event.COMPLETE,OnLoadPrizesComplete);
			lPrizesLoader.removeEventListener(IOErrorEvent.IO_ERROR,OnLoadPrizesIoError);
			dispatchEvent(new Event(PrizesManagerVn.PRIZES_LOAD_FAIL));
		}
//-----------------------------------------------------------------------------------------------------
		private function OnObjectFromStorage(e:PrizeManagerEventVn):void {
			// Указание сконвертировать приз в объект виртуальной системы из хранилища
			// На сервер уходят и координаты и предполагаемая орбита, сервер возвращает правильную привязку (или к координатам или к орбите)
			lPrizesConverter.AddVariable("SOId",String(e.currentTarget.SpaceObjectId));	// SpaceObjectId приза, сгенерировавшего событие
			lPrizesConverter.AddVariable("X",String(e.Data[0].X));	// Координаты нового места
			lPrizesConverter.AddVariable("Y",String(e.Data[0].Y));
			lPrizesConverter.AddVariable("SubId",e.Data[1]);		// Id орбиты, если цепляем объект на орбиту
			lPrizesConverter.addEventListener(Event.COMPLETE,OnPrizeConverted);
			lPrizesConverter.addEventListener(IOErrorEvent.IO_ERROR,OnPrizeConvertedError);
			lPrizesConverter.Load(lConverterScript);
		}
//-----------------------------------------------------------------------------------------------------
		private function OnPrizeConverted(e:Event):void {
			// Приз сконвертирован в объект виртуальной системы
			lPrizesConverter.removeEventListener(Event.COMPLETE,OnPrizeConverted);
			lPrizesConverter.removeEventListener(IOErrorEvent.IO_ERROR, OnPrizeConvertedError);
			// Создать его в виртуальной звездной системе
			if (e.target.data != "0") {
				// Объект создан на сервере, получены данные для создания в клиенте
				var SpaceObjectId:uint = uint(PHPLoader(e.target).GetVariable("SOId"));	// spaceobject_id приза
				// Создать в виртуальной системе по полученным данным
				dispatchEvent(new PrizeManagerEventVn(PrizeManagerEventVn.FROM_STORAGE_TO_OBJECT_ADD_TO_SYSTEM, e.target.data));
				// Удалить (уменьшить на 1 кол-во в стеке) сконвертированный приз
				for (var i:uint = 0; i < Prizes.length; i++) {
					if (Prizes[i].SpaceObjectId == SpaceObjectId) {
						if (Prizes[i].StackAmount > 1) {
							Prizes[i].StackAmount--;
						}
						else {
							// Удалить приз
							DeleteBySOId(SpaceObjectId);
							// Команда для списка призов - обновить (удалить иконку)
							dispatchEvent(new PrizeManagerEventVn(PrizeManagerEventVn.FROM_STORAGE_TO_OBJECT_SUCCESS, SpaceObjectId));
						}
					}
				}
			}
			else {
				// На сервере не удалось создать объект
				dispatchEvent(new Event(PrizeManagerEventVn.FROM_STORAGE_TO_OBJECT_FAIL));
			}
		}
//-----------------------------------------------------------------------------------------------------
		private function OnPrizeConvertedError(e:IOErrorEvent):void {
			// Ошибка конвертирования приза
			lPrizesConverter.removeEventListener(Event.COMPLETE,OnPrizeConverted);
			lPrizesConverter.removeEventListener(IOErrorEvent.IO_ERROR, OnPrizeConvertedError);
			dispatchEvent(new Event(PrizeManagerEventVn.FROM_STORAGE_TO_OBJECT_FAIL));
		}
//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------
		public function get PrizesAmount():uint {
			// Загруженное кол-во призов
			return lPrizes.length;
		}
//-----------------------------------------------------------------------------------------------------
		public function get Prizes():Array {
			// Массив с призами
			return lPrizes;
		}
//-----------------------------------------------------------------------------------------------------
	}
}