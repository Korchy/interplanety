package Vn.Quests.Conditions.Picts {
	// "Продажа груза"
//-----------------------------------------------------------------------------------------------------
	import Vn.Objects.VnObjectS;
	import Vn.Scene.StarSystem.StarSystemRealVn;
	import Vn.Text.TextDictionary;
//	import Vn.Vn;
//-----------------------------------------------------------------------------------------------------
	public class QuestConditionSellCargoPictVn extends QuestConditionPictVn {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		private var PlanetA:VnObjectS;	// Планета старта
		private var PlanetB:VnObjectS;	// Планета назначения
		private var CargoImg:VnObjectS;	// Изображения груза
		private var ShipImg:VnObjectS;	// Изображения корабля
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function QuestConditionSellCargoPictVn() {
			// Конструктор предка
			super();
			// Конструктор
			PlanetA = null;
			PlanetB = null;
			CargoImg = null;
			ShipImg = null;
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
			if(PlanetB!=null) {
				if(PlanetB.parent!=null) removeChild(PlanetB);
				PlanetB._delete();
				PlanetB = null;
			}
			if(CargoImg!=null) {
				if(CargoImg.parent!=null) removeChild(CargoImg);
				CargoImg._delete();
				CargoImg = null;
			}
			if(ShipImg!=null) {
				if(ShipImg.parent!=null) removeChild(ShipImg);
				ShipImg._delete();
				ShipImg = null;
			}
			// Деструктор предка
			super._delete();
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		override protected function OnComplete(Node:XML):void {
			// Загрузка из XML
			// Планета старта
			if (Node.child("PlanetA").length() > 0) {
				PlanetA = new VnObjectS();
				PlanetA.ReloadByType("Planet",uint(Node.child("PlanetA")),10,10);
				addChild(PlanetA);
				PlanetA.MoveIntoParent(PlanetA.Width05, PlanetA.Height05, true);
			}
			// Планета назначения
			if (Node.child("PlanetB").length() > 0) {
				PlanetB = new VnObjectS();
				PlanetB.ReloadByType("Planet",uint(Node.child("PlanetB")),20,20);
				addChild(PlanetB);
				PlanetB.MoveIntoParent(Width-PlanetB.Width05,Height-PlanetB.Height05-15,true);
			}
			// Груз
			CargoImg = new VnObjectS();
			CargoImg.ReloadByType("Industry",uint(Node.child("CargoId")),12,12);
			addChild(CargoImg);
			CargoImg.MoveIntoParent(CargoImg.Width05,Height-CargoImg.Height05-15,true);
			// Корабль
			ShipImg = new VnObjectS();
			ShipImg.ReloadByType("Ship",1,14,14);	// Изображение корабля - МККДС-1 28x28
			addChild(ShipImg);
			ShipImg.MoveIntoParent(Width05-5,Height05-15,true);
			// Описание
			Desc.Text = TextDictionary.Text(135)+"\n";
			if(PlanetA!=null) Desc.Text += TextDictionary.Text(134)+": "+TextDictionary.Text(uint(Node.child("PlanetAName")))+"\n";
			if(PlanetB!=null) Desc.Text += TextDictionary.Text(136)+": "+TextDictionary.Text(uint(Node.child("PlanetBName")))+"\n";
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