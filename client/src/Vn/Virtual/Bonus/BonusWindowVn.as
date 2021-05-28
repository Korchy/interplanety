package Vn.Virtual.Bonus {
//-----------------------------------------------------------------------------------------------------
// Окно получения бонусов с виртуального объекта
//-----------------------------------------------------------------------------------------------------
	import flash.events.MouseEvent;
	import flash.system.System;
	import Vn.Interface.Button.OkButtonVn;
	import Vn.Interface.CountDown.CountDownVn;
	import Vn.Interface.List.ImageList;
	import Vn.Interface.Text.VnText;
	import Vn.Interface.Window.VnWindowLS;
	import Vn.Math.Vector2;
	import Vn.Objects.Var.ObjectView;
	import Vn.Objects.VnObjectT;
	import Vn.SpaceObjects.InteractiveSpaceObjectVC;
	import Vn.Synchronize.Refresher;
	import Vn.Text.TextDictionary;
	import Vn.Vn.Events.EvAppResize;
	import Vn.Interplanety;
//-----------------------------------------------------------------------------------------------------
	public class BonusWindowVn extends VnWindowLS {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		private var Owner:InteractiveSpaceObjectVC;	// Объект, который вызывал окно
		private var lOkButton:OkButtonVn;	// Кнопка OK
		private var Bonuses:ImageList;		// Список бонусов
		private var lBounusesData:XML;		// Данные по бонусам
		private var lTimeCounter:CountDownVn;	// Счетчик времени
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function BonusWindowVn(vOwner:InteractiveSpaceObjectVC) {
			// Конструктор предка
			Owner = vOwner;	// До конструктора предка т.к. используется в переопределенных функциях предка
			super("getbonusinfo.php");
			// Конструктор
			Name = 197;	// "Бонус"
			Caption.Text = TextDictionary.Text(Name)+": "+TextDictionary.Text(Owner.Name);
			SetLocalPosition(140, 90);
			SaverScript = "getbonus.php";
			// OK
			lOkButton = new OkButtonVn();
			addChild(lOkButton);
			lOkButton.addEventListener(MouseEvent.CLICK, OnOkButtonClick);
			// Список бонусов
			lBounusesData = null;
			Bonuses = new ImageList(new Vector2(Width, 60));
			addChild(Bonuses);
			Bonuses.MoveIntoParent(Width05, Height05);	// По центру
			// Счетчик
			lTimeCounter = null;
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		override public function _delete():void {
			// Деструктор
			// Сетчик
			if (lTimeCounter != null) {
				removeChild(lTimeCounter);
				lTimeCounter._delete();
				lTimeCounter = null;
			}
			// Список бонусов
			removeChild(Bonuses);
			Bonuses._delete();
			Bonuses = null;
			if(lBounusesData!=null) System.disposeXML(lBounusesData);
			lBounusesData = null;
			// OK
			lOkButton.removeEventListener(MouseEvent.CLICK, OnOkButtonClick);
			removeChild(lOkButton);
			lOkButton._delete();
			lOkButton = null;
			// Деструктор предка
			super._delete();
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		override protected function GetPlace():Vector2 {
			// Местоположение по середине экрана на 5 пикс. от низа
			return new Vector2(VnObjectT(parent).Width05, VnObjectT(parent).Height-Height05-5);
		}
//-----------------------------------------------------------------------------------------------------
		override protected function SetLoaderScriptParams():void {
			// Установка параметров скрипта для загрузки
			AddLoaderScriptParam("Id",String(Owner.Id));				// Id объекта (user_starsystem_id)
		}
//-----------------------------------------------------------------------------------------------------
		override protected function OnLoad(vData:*):void {
			// Отработка загруженных данных
			try {
				var Data:XML = new XML(vData);
			}
			catch (e1:Error) {
				trace(vData);
			}
			// Список бонусов
			if(lBounusesData!=null) System.disposeXML(lBounusesData);
			lBounusesData = Data;
			// Вывести на экран
			if (Data.children().length() > 0) {
				for each (var Node:XML in Data.children()) {
					if(Node.nodeKind()=="element") {
						// Для каждого приза получить графическое представление
						var OView:ObjectView = new ObjectView(null);
						OView.TextPlace = true;
						OView.ReloadByType(Node.name());
						OView.Text = Node.valueOf();
						Bonuses.Add(OView);
					}
				}
				// Счетчик времени
				lTimeCounter = new CountDownVn(int(Data.attribute("dest")), 1000);
				addChild(lTimeCounter);
				lTimeCounter.x = Width05-lTimeCounter.Width/2.0;
				lTimeCounter.y = 40;
				lTimeCounter.Align = VnText.CENTER;
				lTimeCounter.TextAlign = VnText.CENTER;
			}
		}
//-----------------------------------------------------------------------------------------------------
		override protected function SetSaverScriptParams():void {
			// Установка параметров скрипта для сохранения
			AddSaverScriptParam("Id",String(Owner.Id));		// Id объекта (user_starsystem_id)
		}
//-----------------------------------------------------------------------------------------------------
		override protected function OnSaved(vData:*):void {
			// Отработка после сохранения данных
			try {
				var Data:XML = new XML(vData);
			}
			catch (e1:Error) {
				trace(vData);
			}
			if(Data.name()=="ERR") {
				if(uint(Data)!=0) {
					// Если корневой узел ERR и значение != 0 - возвращена ошибка
					Vn.Interplanety.Cons.Add(TextDictionary.Text(uint(Data)));
				}
				else {
					// Если ERR=0 - бонусы зачислены
					// По списку бонусов обновить атрибуты пользователя
					for each (var Node:XML in lBounusesData.children()) {
						if(Node.nodeKind()=="element") {
							Refresher.Refresh(Node.name());
						}
					}
				}
			}
		}
//-----------------------------------------------------------------------------------------------------
// Обработка событий
//-----------------------------------------------------------------------------------------------------
		override protected function OnApplicationResize(e:EvAppResize):void {
			// Отработка при изменении размеров окна приложения
			RePlace();	// Сохранить местоположение
		}
//-----------------------------------------------------------------------------------------------------
		private function OnOkButtonClick(e:MouseEvent):void {
			// Нажатие ОК
			if (lTimeCounter != null && lTimeCounter.DestTime == 0) Save();
			else Close();
		}
//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------

//-----------------------------------------------------------------------------------------------------
	}
}