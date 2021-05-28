package Vn.Quests.Prizes {
	// Квестовый приз
//-----------------------------------------------------------------------------------------------------
	import Vn.Objects.Var.ObjectView;
	import Vn.Text.TextDictionary;
//-----------------------------------------------------------------------------------------------------
	public class QuestPrizeVn {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		private var lTextDefinition:String;	// Текстовое описание (Gold, Crystals...)
		private var lDefinitionId:uint;		// Id приза как объекта
		private var lType:uint;				// Тип приза
		private var lCount:uint;			// Количество
		private var lPict30x30:ObjectView;		// Указатель на пиктограмму 30x30
		private var lPict40x40:ObjectView;		// Указатель на пиктограмму 40x40
		// Константы
		public static const ACHIEVEMENT:uint = 0;	// Достижение
		public static const PRIZE:uint = 1;			// Приз
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function QuestPrizeVn() {
			// Конструктор родителя
//			super();
			// Конструктор
			lTextDefinition = "Text";
			lDefinitionId = 0;
			lType = QuestPrizeVn.PRIZE;
			lCount = 0;
			lPict30x30 = null;
			lPict40x40 = null;
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		public function _delete():void {
			// Деструктор
			if(lPict30x30!=null) {
				if(lPict30x30.parent!=null) lPict30x30.parent.removeChild(lPict30x30);
				lPict30x30._delete();
				lPict30x30 = null;
			}
			if(lPict40x40!=null) {
				if(lPict40x40.parent!=null) lPict40x40.parent.removeChild(lPict40x40);
				lPict40x40._delete();
				lPict40x40 = null;
			}
			// Деструктор родителя
//			super._delete();
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		public function Load(Data:XML):void {
			// Заполнение данными
			lTextDefinition = Data.name();
			if(Data.attribute("Id").length()!=0) lDefinitionId = uint(Data.attribute("Id"));
			if(Data.attribute("type").length()!=0&&Data.attribute("type")=="a") lType = QuestPrizeVn.ACHIEVEMENT;
			lCount = uint(Data);
		}
//-----------------------------------------------------------------------------------------------------
// Обработка событий
//-----------------------------------------------------------------------------------------------------

//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------
		public function get TextDefinition():String {
			return lTextDefinition;	// Текстовое описание
		}
//-----------------------------------------------------------------------------------------------------
		public function get DefinitionId():uint {
			return lDefinitionId;	// Id приза как объекта
		}
//-----------------------------------------------------------------------------------------------------
		public function get Type():uint {
			return lType;	// Тип
		}
//-----------------------------------------------------------------------------------------------------
		public function get Count():uint {
			return lCount;	// Количество
		}
//-----------------------------------------------------------------------------------------------------
		public function get Pict30x30():ObjectView {
			if(lPict30x30==null) {	// Пиктограмма
				lPict30x30 = new ObjectView(this);
				lPict30x30.TextPlace = true;
				lPict30x30.ReloadByType(TextDefinition,DefinitionId,15,15);
				if(Type==QuestPrizeVn.ACHIEVEMENT) lPict30x30.Text = TextDictionary.Text(Count);
				else 
					if(Count==0) lPict30x30.Text = "";
					else lPict30x30.Text = String(Count);
			}
			return lPict30x30;
		}
//-----------------------------------------------------------------------------------------------------
		public function get Pict40x40():ObjectView {
			if(lPict40x40==null) {	// Пиктограмма
				lPict40x40 = new ObjectView(this);
				lPict40x40.TextPlace = true;
				lPict40x40.ReloadByType(TextDefinition,DefinitionId,20,20);
				if(Type==QuestPrizeVn.ACHIEVEMENT) lPict40x40.Text = TextDictionary.Text(Count);
				else lPict40x40.Text = String(Count);
			}
			return lPict40x40;
		}
//-----------------------------------------------------------------------------------------------------
	}
}