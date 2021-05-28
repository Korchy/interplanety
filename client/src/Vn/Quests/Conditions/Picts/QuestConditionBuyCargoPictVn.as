package Vn.Quests.Conditions.Picts {
	// "Покупка груза"
//-----------------------------------------------------------------------------------------------------
//	import Vn.Vn;
	import Vn.Objects.VnObjectS;
	import Vn.Text.TextDictionary;
//-----------------------------------------------------------------------------------------------------
	public class QuestConditionBuyCargoPictVn extends QuestConditionPictVn {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		private var PlanetA:VnObjectS;	// Планета старта
		private var CargoImg:VnObjectS;	// Изображения груза
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function QuestConditionBuyCargoPictVn() {
			// Конструктор предка
			super();
			// Конструктор
			PlanetA = null;
			CargoImg = null;
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		override public function _delete():void {
			// Деструктор
			if(PlanetA!=null) {
				if(PlanetA.parent!=null) removeChild(PlanetA);
				PlanetA._delete();
				PlanetA = null;
			}
			if(CargoImg!=null) {
				if(CargoImg.parent!=null) removeChild(CargoImg);
				CargoImg._delete();
				CargoImg = null;
			}
			// Деструктор предка
			super._delete();
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		override protected function OnComplete(Node:XML):void {
			// Загрузка
			// Планета старта
			if (Node.child("PlanetA").length() > 0) {
				PlanetA = new VnObjectS();
				PlanetA.ReloadByType("Planet",uint(Node.child("PlanetA")),10,10);
				addChild(PlanetA);
				PlanetA.MoveIntoParent(PlanetA.Width05, PlanetA.Height05, true);
			}
			// Груз
			CargoImg = new VnObjectS();
			CargoImg.ReloadByType("Industry",uint(Node.child("CargoId")),20,20);
			addChild(CargoImg);
			CargoImg.MoveIntoParent(Width-CargoImg.Width05,Height-CargoImg.Height05-15,true);
			// Описание
			Desc.Text = TextDictionary.Text(133)+"\n";
			if(PlanetA!=null) Desc.Text += TextDictionary.Text(134)+": "+TextDictionary.Text(uint(Node.child("PlanetAName")))+"\n";
			Desc.Text += TextDictionary.Text(65)+": "+TextDictionary.Text(uint(Node.child("CargoName")));
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