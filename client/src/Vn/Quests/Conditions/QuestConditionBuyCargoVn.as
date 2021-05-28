package Vn.Quests.Conditions {
	// "Покупка груза"
//-----------------------------------------------------------------------------------------------------
	import flash.events.Event;
//	import Vn.Vn;
	import Vn.Market.Events.EvCargoTrade;
	import Vn.Quests.Conditions.Picts.QuestConditionBuyCargoPictVn;
//-----------------------------------------------------------------------------------------------------
	public class QuestConditionBuyCargoVn extends QuestConditionVn {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		private var PlanetAId:uint;	// Id планеты старта (из SectorMain)
		private var CargoId:uint;	// Id груза
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function QuestConditionBuyCargoVn() {
			// Конструктор предка
			super();
			// Конструктор
			PlanetAId = 0;
			lEventType = EvCargoTrade.BUY;
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		override public function _delete():void {
			// Деструктор
			
			// Деструктор предка
			super._delete();
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		override public function Load(Data:XML):void {
			// Загрузка из XML
			// Планета покупки
			if(Data.attribute("PlanetA").length()!=0) {
				PlanetAId = uint(Data.attribute("PlanetA"));	// Id из SectorMain
			}
			// Груз
			CargoId = uint(Data.attribute("CargoId"));
			// Количество
			var ValueArr:Array = String(Data).split("/");
			lValue = uint(ValueArr[1]);
			// Текущее количество
			lCurrentValue = uint(ValueArr[0]);
		}
//-----------------------------------------------------------------------------------------------------
		override protected function CreatePict():void {
			// Создание пиктограммы
			var ParamObject:Object = new Object();
			if(PlanetAId!=0) ParamObject["PlanetAId"] = PlanetAId;
			ParamObject["CargoId"] = CargoId;
			lPict = new QuestConditionBuyCargoPictVn();
			lPict.Text = String(CurrentValue)+"/"+String(Value);
			lPict.Load(ParamObject);
		}
//-----------------------------------------------------------------------------------------------------
		override public function QuestEventOccurse(e:Event):void {
			// Произошло событие влияющее на условия выполнения квеста
			var CEvent:EvCargoTrade = EvCargoTrade(e);
			if(CargoId==CEvent.CargoId&&PlanetAId==CEvent.PlanetAId) {
				lCurrentValue += CEvent.Count;
			}
			if(lCurrentValue>lValue) lCurrentValue = lValue;
			// Обновить пиктограмму
			if(lPict!=null) lPict.Text = String(CurrentValue)+"/"+String(Value);
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