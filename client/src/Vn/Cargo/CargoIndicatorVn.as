package Vn.Cargo {
//-----------------------------------------------------------------------------------------------------
// Класс "Индикатор груза"
//-----------------------------------------------------------------------------------------------------
	import flash.events.AVDictionaryDataEvent;
	import flash.events.Event;
	import Vn.Common.LoadStatusVn;
	import Vn.Indicator.IndicatorVn;
	import Vn.Industry.Industry;
	import Vn.Interface.Text.VnTextI;
	import Vn.Objects.Var.LoadedObject;
	import Vn.Objects.VnObjectS;
	import Vn.Scene.StarSystem.StarSystemRealVn;
	import Vn.Interplanety;
//-----------------------------------------------------------------------------------------------------
	public class CargoIndicatorVn extends IndicatorVn {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		protected var lImg:VnObjectS;			// Указатель на изображение груза
		protected var lTypeImg:VnObjectS;		// Изображение типа груза
		protected var lSellCount:VnTextI;		// Количество
		protected var lSellPrice:VnTextI;		// Цена продажи (за эту цену груз будет передан на другой объект)
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function CargoIndicatorVn(vOwner:Object) {
			// Конструктор предка
			super(vOwner, 60, 30);	// 120 x 60
			// Конструктор
			lImg = null;
			lTypeImg = null;
			lSellCount = null;
			lSellPrice = null;
//			LoadFromOwner();	// Заполнить индикатор объектами через Owner
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		override public function _delete():void {
			// Деструктор
			if(lImg!=null) {
				removeChild(lImg);
				lImg._delete();
			}
			lImg = null;
			if (lTypeImg != null) {
				removeChild(lTypeImg);
				lTypeImg._delete();
			}
			lTypeImg = null;
			if (lSellCount != null) {
				removeChild(lSellCount);
				lSellCount._delete();
			}
			lSellCount = null;
			if (lSellPrice != null) {
				removeChild(lSellPrice);
				lSellPrice._delete();
			}
			lSellPrice = null;
			// Деструктор предка
			super._delete();
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		public function LoadFromOwner():void {
			// Заполнение данными из владельца
			var CurrentIndustry:Industry = Industry(Interplanety.Universe.IndustryManager.ById(CargoVn(Owner).industryId));
			if (CurrentIndustry.Status != LoadStatusVn.LOADED) {
				CurrentIndustry.addEventListener(Industry.LOADED, OnIndustryLoaded);
			}
			else Fill(CurrentIndustry);
		}
//-----------------------------------------------------------------------------------------------------
		public function Fill(vIndustry:Industry):void {
			// Заполнение индикатора информацией
			// vIndustry всегда загружен
			Id = vIndustry.Id;	// У индикатора тот же id, что и у груза
			lImg = vIndustry.Image.Clone();	// Через Clone т.к. нужно присоединять addChild в разые окна одновременно
			addChild(lImg);
			lImg.MoveIntoParent(lImg.Width05, Height - lImg.Height05);
			lTypeImg = vIndustry.TypeImage.Clone();
			addChild(lTypeImg);
			lTypeImg.MoveIntoParent(Width - lTypeImg.Width05, lTypeImg.Height05);	// Правый верхний угол
			lSellPrice = new VnTextI(Width-lImg.Width, 20);
			lSellPrice.ReLoadById(29);	// gold
			lSellPrice.Text = String(SellPrice);
			addChild(lSellPrice);
			lSellPrice.MoveIntoParent(lImg.Width + lSellPrice.Width05, Height - lSellPrice.Height05, true);
			lSellCount = new VnTextI(Width-lImg.Width, 20);
			lSellCount.ReLoadById(197);	// count20x20i
			lSellCount.Text = String(CargoVn(Owner).Volume);
			addChild(lSellCount);
			lSellCount.MoveIntoParent(lImg.Width + lSellCount.Width05, Height - lSellPrice.Height - lSellCount.Height05, true);
		}
//-----------------------------------------------------------------------------------------------------
// Обработка событий
//-----------------------------------------------------------------------------------------------------
		private function OnIndustryLoaded(e:Event):void {
			// Отслеживание загрузки ранее незагруженной Industry
			e.target.removeEventListener(Industry.LOADED, OnIndustryLoaded);
			Fill(Industry(e.target));
		}
//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------
		public function get SellPrice():uint {
			return CargoVn(Owner).Price;
		}
//-----------------------------------------------------------------------------------------------------
	}
}