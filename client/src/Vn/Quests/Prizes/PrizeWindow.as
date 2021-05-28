package Vn.Quests.Prizes {
	// Окно с полученными по квесту призами/достижениями
//-----------------------------------------------------------------------------------------------------
	import Vn.Common.SC;
	import Vn.Math.Vector2;
	import Vn.Objects.VnObjectSA;
	import Vn.Interface.Text.VnText;
	import Vn.Interface.List.ImageList;
	import Vn.Text.TextDictionary;
	import Vn.Objects.Var.ObjectView;
	import Vn.Synchronize.Refresher;
//-----------------------------------------------------------------------------------------------------
	public class PrizeWindow extends QuestPrizeWindow {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		private var BaitaImg:VnObjectSA;	// Изображение Байты
		private var PrizesTxt:VnText;		// "Получены следующие призы:"
		private var Prizes:ImageList;		// Список полученных призов
		private var OpensTxt:VnText;		// "Доступно новое:"
		private var Opens:ImageList;		// Список новых возможностей
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function PrizeWindow() {
			// Конструктор предка
			super();
			// Конструктор
			SetLocalPosition(205,145);
			// Байта
			BaitaImg = new VnObjectSA();
			BaitaImg.ReLoadById(82);	// baita80x80i
			addChild(BaitaImg);
			BaitaImg.MoveIntoParent(BaitaImg.Width05+WorkSpace.X+5,BaitaImg.Height05+WorkSpace.Y+5,true);
			// Призы
			PrizesTxt = new VnText();
			PrizesTxt.x = 110;
			PrizesTxt.y = 30;
			PrizesTxt.textColor = SC.BLACK;
			PrizesTxt.Text = TextDictionary.Text(128);
			addChild(PrizesTxt);
			Prizes = new ImageList(new Vector2(200+60,60+10));
			// Открытия
			OpensTxt = new VnText();
			OpensTxt.x = 110;
			OpensTxt.y = 140;
			OpensTxt.textColor = SC.BLACK;
			OpensTxt.Text = TextDictionary.Text(129);
			addChild(OpensTxt);
			Opens = new ImageList(new Vector2(200+60,60+10));
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		override public function _delete():void {
			// Деструктор
			// Призы
			if(PrizesTxt.parent!=null) removeChild(PrizesTxt);
			PrizesTxt._delete();
			PrizesTxt = null;
			if(Prizes.parent!=null) removeChild(Prizes);
			Prizes._delete();
			Prizes = null;
			// Открытия
			if(OpensTxt.parent!=null) removeChild(OpensTxt);
			OpensTxt._delete();
			OpensTxt = null;
			if(Opens.parent!=null) removeChild(Opens);
			Opens._delete();
			Opens = null;
			// Байта
			removeChild(BaitaImg);
			BaitaImg._delete();
			BaitaImg = null;
			// Деструктор предка
			super._delete();
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		override public function LoadFromXML(Data:XML):void {
			// Загрузка данных из XML-узла
			PrizeId = uint(Data.attribute("id"));
			QuestId = uint(Data.attribute("quest_id"));
			QuestStage = uint(Data.attribute("stage"));
			Name = uint(Data.attribute("name"));
			Caption.Text = TextDictionary.Text(Name);
			// По каждому призу - сформировать информацию о его получении
			for each (var Node:XML in Data.children()[0].*) {
				if(Node.nodeKind()=="element") {
					// Для каждого приза получить графическое представление
					var OView:ObjectView = new ObjectView(null);
					OView.TextPlace = true;
					// Изображение
					var ImageId:uint = 0;
					if(Node.attribute("Id").length()!=0) ImageId = Node.attribute("Id");
					OView.ReloadByType(Node.name(),ImageId,20,20);
					// Текст
					if(Node.attribute("type")=="a") {
						// Открытия
						OView.Text = TextDictionary.Text(uint(Node));
						Opens.Add(OView);
						// Если не показаны - показать
						if (Opens.parent == null) {
							addChild(Opens);
							Opens.MoveIntoParent(110+Opens.Width05,OpensTxt.y+30+Opens.Height05,true);
						}
					}
					else {
						// Призы
						OView.Text = Node;
						Prizes.Add(OView);
						// Если не показаны - показать
						if (Prizes.parent == null) {
							addChild(Prizes);
							Prizes.MoveIntoParent(110+Prizes.Width05,PrizesTxt.y+30+Prizes.Height05,true);
						}
						// Обновить данные по призам
						Refresher.Refresh(Node.name());
					}
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