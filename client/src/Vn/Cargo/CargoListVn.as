package Vn.Cargo {
//-----------------------------------------------------------------------------------------------------
// Страничный компонент со списком грузов для торговли
//-----------------------------------------------------------------------------------------------------
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import Vn.Objects.Var.LoadedObject;
	import Vn.Interface.List.ImageListSelectQ;
	import Vn.Math.Vector2;
	import Vn.SpaceObjects.ISOCargoManagerVn;
//	import Vn.Debug.SpeedCheck;
//-----------------------------------------------------------------------------------------------------
	public class CargoListVn extends ImageListSelectQ {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		private var lOwner:Object;	// Указатель на родитель (планету/корабль)
		private var lLastShownPage:uint;	// Номер последней показанной страницы
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function CargoListVn(vSize:Vector2) {
			// Конструктор предка
			super(vSize);
			// Конструктор
			lOwner = null;
			lLastShownPage = 1;
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		override public function _delete():void {
			// Деструктор
			if (lOwner != null) {
				if(IUnitWithCargoVn(lOwner).CargoManager.hasEventListener(LoadedObject.LOADED)) IUnitWithCargoVn(lOwner).CargoManager.removeEventListener(LoadedObject.LOADED, OnLoadComplete);
				if(IUnitWithCargoVn(lOwner).CargoManager.hasEventListener(LoadedObject.FAIL)) IUnitWithCargoVn(lOwner).CargoManager.removeEventListener(LoadedObject.LOADED, OnLoadComplete);
				lOwner = null;
			}
			// Деструктор предка
			super._delete();
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		override public function Clear():void {
			// Очистка списка
			lLastShownPage = 1;
			super.Clear();
		}
//-----------------------------------------------------------------------------------------------------
		public function Load(vOwner:Object):void {
			// Загрузка данных по товарам на планете/корабле
			Clear();
//SpeedCheck.AddPoint("CargoList - Load");
// Видимая задержка между открытием окна MarketWindow и выводом списка товаров видимо здесь - получение данных по сети.
			lOwner = vOwner;
			IUnitWithCargoVn(lOwner).CargoManager.addEventListener(LoadedObject.LOADED, OnLoadComplete);
			IUnitWithCargoVn(lOwner).CargoManager.addEventListener(LoadedObject.FAIL, OnLoadIoError);
			IUnitWithCargoVn(lOwner).CargoManager.Load();
		}
//-----------------------------------------------------------------------------------------------------
		public function reLoad():void {
			// Обновление (перезагрузка с сервера) данных по товарам на планете/корабле
			lLastShownPage = CurrentPage;	// Сохранить номер страницы для показа
			super.Clear();
			IUnitWithCargoVn(lOwner).CargoManager.addEventListener(LoadedObject.LOADED, OnLoadComplete);
			IUnitWithCargoVn(lOwner).CargoManager.addEventListener(LoadedObject.FAIL, OnLoadIoError);
			IUnitWithCargoVn(lOwner).CargoManager.Load();
		}
//-----------------------------------------------------------------------------------------------------
		protected function OnCargoRefreshed(vOwner:Object):void {
			// По завршении обновления данных по грузам
			// Переопределяется в наследниках
		}
//-----------------------------------------------------------------------------------------------------
// Обработка событий
//-----------------------------------------------------------------------------------------------------
		private function OnLoadComplete(e:Event):void {
			// Данные по производствам загружены
//SpeedCheck.AddPoint("CargoList - OnLoadComplete");
//SpeedCheck.TraceTime();
			OnCargoRefreshed(lOwner);
			ShowPage(lLastShownPage);	// Показывать последнюю просмотренную страницу
			e.target.removeEventListener(LoadedObject.LOADED, OnLoadComplete);
			e.target.removeEventListener(LoadedObject.FAIL, OnLoadIoError);
		}
//-----------------------------------------------------------------------------------------------------
		private function OnLoadIoError(e:IOErrorEvent):void {
			// Ошибка загрузки данных по производствам
			e.target.removeEventListener(LoadedObject.LOADED, OnLoadComplete);
			e.target.removeEventListener(LoadedObject.FAIL, OnLoadIoError);
		}
//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------
		public function get owner():Object {
			return lOwner;
		}
//-----------------------------------------------------------------------------------------------------
	}
}