package Vn.Market {
//-----------------------------------------------------------------------------------------------------
// Кнопка продажи груза (продукции)
//-----------------------------------------------------------------------------------------------------
	import flash.events.MouseEvent;
	import Vn.Cargo.CargoVn;
	import Vn.Interface.Button.Button;
	import Vn.Interface.Button.ButtonL;
	import Vn.Interface.Edit.EditN;
	import Vn.Interplanety;
	import Vn.Market.Events.EvCargoTrade;
	import Vn.Scene.StarSystem.StarSystemRealVn;
	import Vn.Ships.Cargo.ShipCargoIndicator;
	import Vn.Ships.Cargo.ShipCargoListVn;
	import Vn.Text.TextDictionary;
//-----------------------------------------------------------------------------------------------------
	public class SellCargoButton extends ButtonL {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		private var lShipCargoList:ShipCargoListVn;	// Список груза на корабле
		private var lDealCount:EditN;				// Счетчик с кол-вом продаваемого
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function SellCargoButton(vShipCargoList:ShipCargoListVn, vDealCount:EditN) {
			// Конструктор предка
			super();
			// Конструктор
			lShipCargoList = vShipCargoList;
			lDealCount = vDealCount;
			ReLoadById(50);	// start
			Type = Button.BUTTON_TXT;
			Text = TextDictionary.Text(67);	// "Продать" (После ReLoad т.к выравнивается по центру)
			Script = "sell.php";
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		override public function _delete():void {
			// Деструктор
			lDealCount = null;
			lShipCargoList = null;
			// Деструктор предка
			super._delete();
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		override protected function OnClick(e:MouseEvent):void {
			// Нажатие на кнопку
			// Предварительные проверки
			// Все выбрано
			if (lShipCargoList == null || lShipCargoList.Selected == null) {
				Interplanety.Cons.Add(TextDictionary.Text(207));	// Байта: - Укажите груз и корабль.
				e.stopImmediatePropagation();
				return;
			}
			var cargoToSell:CargoVn =  CargoVn(ShipCargoIndicator(lShipCargoList.Selected).Owner);
			// Нельзя продать 0 и больше чем есть груза
			if (lDealCount.Value == 0 || lDealCount.Value > cargoToSell.Volume) {
				Interplanety.Cons.Add(TextDictionary.Text(121));	// Байта: - Такого количества нет в наличии
				e.stopImmediatePropagation();
				return;
			}
			super.OnClick(e);
		}
//-----------------------------------------------------------------------------------------------------
		override protected function onLoad(vData:XML):void {
			// Продажа совершена
			StarSystemRealVn(Interplanety.Universe.CurrentStarSystem).Market.dispatchEvent(new EvCargoTrade(EvCargoTrade.SELL, uint(vData.child("cargo")), uint(vData.child("count")), uint(vData.child("source")), uint(vData.child("planet"))));
		}
//-----------------------------------------------------------------------------------------------------
		override protected function onFail(vData:XML):void {
			// Ошибка при совершении покупки
			Interplanety.Cons.Add(TextDictionary.Text(uint(vData)));
		}
//-----------------------------------------------------------------------------------------------------
		override protected function setScriptParams():void {
			// Задание входных параметров скрипта
			addScriptParam("cargoId", String(CargoVn(ShipCargoIndicator(lShipCargoList.Selected).Owner).Id));	// Id груза (vn_usership_cargo.id)
			addScriptParam("sellingCount", String(lDealCount.Value));
		}
//-----------------------------------------------------------------------------------------------------
// Обработка событий
//-----------------------------------------------------------------------------------------------------
		
//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------

//-----------------------------------------------------------------------------------------------------
	}
}