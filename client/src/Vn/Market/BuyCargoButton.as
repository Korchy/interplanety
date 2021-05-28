package Vn.Market {
//-----------------------------------------------------------------------------------------------------
// Кнопка покупки продукции (груза)
//-----------------------------------------------------------------------------------------------------
	import flash.events.MouseEvent;
	import Vn.Cargo.CargoVn;
	import Vn.Industry.ISOCargoIndicator;
	import Vn.Interface.Button.Button;
	import Vn.Interface.Button.ButtonL;
	import Vn.Interface.Edit.EditN;
	import Vn.Interplanety;
	import Vn.Market.Events.EvCargoTrade;
	import Vn.Objects.Var.ObjectViewVn;
	import Vn.Scene.StarSystem.StarSystemRealVn;
	import Vn.Ships.Ship;
	import Vn.Ships.ShipsListVn;
	import Vn.Text.TextDictionary;
//-----------------------------------------------------------------------------------------------------
	public class BuyCargoButton extends ButtonL {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		private var lISOCargoList:ISORCCargoListVn;	// Список продукции на планете
		private var lShipsList:ShipsListVn;			// Список кораблей на планете
		private var lDealCount:EditN;				// Счетчик с кол-вом покупаемого
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function BuyCargoButton(vISOCargoList:ISORCCargoListVn, vShipsList:ShipsListVn, vDealCount:EditN) {
			// Конструктор предка
			super();
			// Конструктор
			lISOCargoList = vISOCargoList;
			lShipsList = vShipsList;
			lDealCount = vDealCount;
			ReLoadById(50);	// start
			Type = Button.BUTTON_TXT;
			Text = TextDictionary.Text(66);	// После ReLoad т.к выравнивается по центру
			Script = "buy.php";
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		override public function _delete():void {
			// Деструктор
			lDealCount = null;
			lISOCargoList = null;
			lShipsList = null;
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
			if (lISOCargoList.Selected == null || lShipsList.Selected == null) {
				Interplanety.Cons.Add(TextDictionary.Text(207));	// Байта: - Укажите груз и корабль.
				e.stopImmediatePropagation();
				return;
			}
			var cargoToBuy:CargoVn =  CargoVn(ISOCargoIndicator(lISOCargoList.Selected).Owner);
			// Нельзя купить 0 и больше чем есть на планете
			if (lDealCount.Value == 0 || lDealCount.Value > cargoToBuy.Volume) {
				Interplanety.Cons.Add(TextDictionary.Text(121));	// Байта: - Такого количества нет в наличии
				e.stopImmediatePropagation();
				return;
			}
			// Нельзя купить больше, чем есть денег
			if (Interplanety.VnUser.MoneyCount < lDealCount.Value * cargoToBuy.Price) {
				Interplanety.Cons.Add(TextDictionary.Text(113));	// Байта: - Не хватает денег.
				e.stopImmediatePropagation();
				return;
			}
			// Нельзя купить больше чем есть сободного места
			var freeShipCargoVolume:uint = Ship(ObjectViewVn(lShipsList.Selected).Owner).freeCargoSpace(cargoToBuy.Type);
			if (lDealCount.Value > freeShipCargoVolume) {
				Interplanety.Cons.Add(TextDictionary.Text(123));	// Байта: - Не хватает свободного места.
				e.stopImmediatePropagation();
				return;
			}
			// Предварительные проверки пройдены
			super.OnClick(e);
		}
//-----------------------------------------------------------------------------------------------------
		override protected function onLoad(vData:XML):void {
			// Покупка совершена
			StarSystemRealVn(Interplanety.Universe.CurrentStarSystem).Market.dispatchEvent(new EvCargoTrade(EvCargoTrade.BUY, uint(vData.child("cargo")), uint(vData.child("count")), uint(vData.child("planet")), 0));
		}
//-----------------------------------------------------------------------------------------------------
		override protected function onFail(vData:XML):void {
			// Ошибка при совершении покупки
			Interplanety.Cons.Add(TextDictionary.Text(uint(vData)));
		}
//-----------------------------------------------------------------------------------------------------
		override protected function setScriptParams():void {
			// Задание входных параметров скрипта
			addScriptParam("IndustryId", String(CargoVn(ISOCargoIndicator(lISOCargoList.Selected).Owner).Id));	// Id производства в системе (vn_starsystem_industry.id)
			addScriptParam("BuyingCount", String(lDealCount.Value));
			addScriptParam("ShipId", String(Ship(ObjectViewVn(lShipsList.Selected).Owner).Id));
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