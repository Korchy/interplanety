package Vn.Quests.Conditions {
	// "Перелет"
//-----------------------------------------------------------------------------------------------------
	import flash.events.Event;
//	import Vn.Vn;
	import Vn.Ships.Routes.Events.EvRouteFinish;
	import Vn.Quests.Conditions.Picts.QuestConditionFlyPictVn;
//-----------------------------------------------------------------------------------------------------
	public class QuestConditionFlyVn extends QuestConditionVn {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		private var PlanetAId:uint;	// Id планеты старта (из SectorMain)
		private var PlanetBId:uint;	// Id планеты назначения (из SectorMain)
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function QuestConditionFlyVn() {
			// Конструктор предка
			super();
			// Конструктор
			lEventType = EvRouteFinish.ROUTE_FINISH;
			PlanetAId = 0;
			PlanetBId = 0;
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
			// Планета старта
			if(Data.attribute("PlanetA").length()!=0) {
				PlanetAId = uint(Data.attribute("PlanetA"));	// spacobject_id
			}
			// Планета назначения
			if(Data.attribute("PlanetB").length()!=0) {
				PlanetBId = uint(Data.attribute("PlanetB"));	// spaceobject_id
			}
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
			ParamObject["PlanetBId"] = PlanetBId;
			lPict = new QuestConditionFlyPictVn();
			lPict.Text = String(CurrentValue)+"/"+String(Value);
			lPict.Load(ParamObject);
		}
//-----------------------------------------------------------------------------------------------------
		override public function QuestEventOccurse(e:Event):void {
			// Произошло событие влияющее на условия выполнения квеста
			var CEvent:EvRouteFinish = EvRouteFinish(e);
			if((PlanetAId==0||PlanetAId==CEvent.PlanetAId)&&PlanetBId==CEvent.PlanetBId) {
				lCurrentValue++;
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