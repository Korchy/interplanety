package Vn.Quests.Journal {
	// "Листок" для информации по квесту
	// 2 строки - условия на данном уровне сложности
	// 1 строка - призы
//-----------------------------------------------------------------------------------------------------
	import Vn.Math.Vector2;
	import Vn.Objects.VnObjectT;
	import Vn.Quests.QuestDifficultyLevelVn;
//-----------------------------------------------------------------------------------------------------
	public class QuestSheet extends VnObjectT {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		private var Conditions:Array;	// Массив указателей на условия
		private var Prizes:Array;		// Массив указателей на призы
		private var ConditionsRows:uint;		// Кол-во строк на условия
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function QuestSheet(Size:Vector2) {
			// Конструктор предка
			super();
			// Конструктор
			SetLocalPosition(Size.X/2.0,Size.Y/2.0);
			ConditionsRows = 2;
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		override public function _delete():void {
			// Деструктор
			// Очистить массивы изображений
			for(var i:uint=0;i<Conditions.length;i++) {
				if(Conditions[i].Pict!=null&&Conditions[i].Pict.parent!=null) removeChild(Conditions[i].Pict);
			}
			Conditions = null;
			for(var i1:uint=0;i1<Prizes.length;i1++) {
				if(Prizes[i1].Pict30x30!=null&&Prizes[i1].Pict30x30.parent!=null) removeChild(Prizes[i1].Pict30x30);
			}
			Prizes = null;
			// Деструктор предка
			super._delete();
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		public function Load(DifficultyLevel:QuestDifficultyLevelVn):void {
			// Показать на экране списки призов и условий
			// Условия - верхний квадрат
			Conditions = DifficultyLevel.Conditions;
			var Cx:uint = 0;	// pix на отступ
			var Cy:uint = 0;
			var CurrentRow:uint = 0;
			for(var i:uint=0;i<Conditions.length;i++) {
				addChild(Conditions[i].Pict);
				Conditions[i].Pict.MoveIntoParent(Cx+Conditions[i].Pict.Width05,Cy+Conditions[i].Pict.Height05,true);
				Cy += Conditions[i].Pict.Height;
				CurrentRow++;
				if(CurrentRow>=ConditionsRows) {
					Cy = 0;
					Cx += Conditions[i].Pict.Width;
				}
			}
			// Призы - нижний квадрат
			Prizes = DifficultyLevel.Prizes;
			Cx = 0;	// pix на отступ
			Cy = ConditionsRows*Conditions[0].Pict.Height+15;	// Одно условие всегда есть плюс отступ 15 пикс.
			for(var i1:uint=0;i1<Prizes.length;i1++) {
				addChild(Prizes[i1].Pict30x30);
				Prizes[i1].Pict30x30.MoveIntoParent(Cx+Prizes[i1].Pict30x30.Width05,Cy+Prizes[i1].Pict30x30.Height05,true);
				Cx += Prizes[i1].Pict30x30.Width;
				if(Cx>Width) {
					Cx = 0;
					Cy += Prizes[i1].Pict30x30.Height;
				}
			}
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