package Vn.Quests.Conditions {
	// "Продажа груза"
//-----------------------------------------------------------------------------------------------------
	import flash.events.Event;
//	import Vn.Vn;
	import Vn.Market.Events.EvCargoTrade;
	import Vn.Quests.Conditions.Picts.QuestConditionSellCargoPictVn;
//-----------------------------------------------------------------------------------------------------
	public class QuestConditionSellCargoVn extends QuestConditionVn {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		private var PlanetAId:uint;	// Id планеты старта (из SectorMain)
		private var PlanetBId:uint;	// Id планеты назначения (из SectorMain)
		private var CargoId:uint;	// Id груза
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function QuestConditionSellCargoVn() {
			// Конструктор предка
			super();
			// Конструктор
			PlanetAId = 0;
			PlanetBId = 0;
			lEventType = EvCargoTrade.SELL;
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
				PlanetAId = uint(Data.attribute("PlanetA"));	// spaceobject_id
			}
			// Планета продажи
			if(Data.attribute("PlanetB").length()!=0) {
				PlanetBId = uint(Data.attribute("PlanetB"));	// spaceobject_id
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
			if(PlanetBId!=0) ParamObject["PlanetBId"] = PlanetBId;
			ParamObject["CargoId"] = CargoId;
			lPict = new QuestConditionSellCargoPictVn();
			lPict.Text = String(CurrentValue) + "/" + String(Value);
			lPict.Load(ParamObject);
		}
//-----------------------------------------------------------------------------------------------------
		override public function QuestEventOccurse(e:Event):void {
			// Произошло событие влияющее на условие
			var CEvent:EvCargoTrade = EvCargoTrade(e);
			if(CargoId==CEvent.CargoId&&(PlanetAId==0||PlanetAId==CEvent.PlanetAId)&&(PlanetBId==0||PlanetBId==CEvent.PlanetBId)) {
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