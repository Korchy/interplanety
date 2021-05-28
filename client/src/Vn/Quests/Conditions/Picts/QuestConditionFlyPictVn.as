package Vn.Quests.Conditions.Picts {
	// "Инструктаж"
//-----------------------------------------------------------------------------------------------------
//	import Vn.Vn;
	import Vn.Objects.VnObjectS;
	import Vn.Text.TextDictionary;
//-----------------------------------------------------------------------------------------------------
	public class QuestConditionFlyPictVn extends QuestConditionPictVn {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		private var PlanetA:VnObjectS;	// Планета старта
		private var PlanetB:VnObjectS;	// Планета назначения
		private var ShipImg:VnObjectS;	// Изображения корабля
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function QuestConditionFlyPictVn() {
			// Конструктор предка
			super();
			// Конструктор
			PlanetA = null;
			PlanetB = null;
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
			// Действия с полученными данными для загрузки
			// Планета старта
			if (Node.child("PlanetA").length() > 0) {
				PlanetA = new VnObjectS();
				PlanetA.ReloadByType("Planet",uint(Node.child("PlanetA")),10,10);
				addChild(PlanetA);
				PlanetA.MoveIntoParent(PlanetA.Width05, PlanetA.Height05, true);
			}
			// Планета назначения
			PlanetB = new VnObjectS();
			PlanetB.ReloadByType("Planet",uint(Node.child("PlanetB")),20,20);
			addChild(PlanetB);
			PlanetB.MoveIntoParent(Width-PlanetB.Width05,Height-PlanetB.Height05-15,true);
			// Корабль
			ShipImg = new VnObjectS();
			ShipImg.ReloadByType("Ship",1,14,14);	// Изображение корабля - МККДС-1 28x28
			addChild(ShipImg);
			ShipImg.MoveIntoParent(Width05,Height05-15,true);
			// Описание
			Desc.Text = TextDictionary.Text(130)+"\n";
			if(PlanetA!=null) Desc.Text += TextDictionary.Text(131)+": "+TextDictionary.Text(Node.child("PlanetAName"))+"\n";
			Desc.Text += TextDictionary.Text(132)+": "+TextDictionary.Text(Node.child("PlanetBName"));
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