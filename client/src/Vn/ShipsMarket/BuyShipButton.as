﻿package Vn.ShipsMarket {
//-----------------------------------------------------------------------------------------------------
// Кнопка "Покупка корабля"
//-----------------------------------------------------------------------------------------------------
	import flash.events.MouseEvent;
	import Vn.Interface.Button.ButtonL;
	import Vn.Interface.Button.Button;
	import Vn.Interface.List.ImageListSelect;
	import Vn.Math.Vector2;
	import Vn.Objects.VnObjectT;
	import Vn.Text.TextDictionary;
//-----------------------------------------------------------------------------------------------------
	public class BuyShipButton extends ButtonL {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		private var lMarketShipsPage:ImageListSelect;	// Указатель на список кораблей рынка
		private var lPlanetId:uint;						// Id планеты, на которой совершается покупка
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function BuyShipButton(vMarketShipsPage:ImageListSelect, vPlanetId:uint) {
			// Конструктор предка
			super();
			// Конструткор
			lMarketShipsPage = vMarketShipsPage;
			lPlanetId = vPlanetId;
			NeedPlace = true;
			ReLoadById(132);	// buyshipbutton
			Script = "buyship.php";
			// Текст
			Type = Button.BUTTON_TXT;
			Text = TextDictionary.Text(66);	// После ReLoad т.к выравнивается по центру
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
		override protected function GetPlace():Vector2 {
			// Местоположение - на 60 pix влево от центра х центр + 5 pix
			if(stage!=null) {
				// Если добавлена в список отображения - определить место
				return new Vector2(VnObjectT(parent).Width05-Width05-5,VnObjectT(parent).Height05);
			}
			else {
				// Если не добавлена - 0,0
				return new Vector2(0.0,0.0);
			}
		}
//-----------------------------------------------------------------------------------------------------
		override protected function setScriptParams():void {
			// Параметры
			addScriptParam("ShipId", String(BuyShipContainer(lMarketShipsPage.Selected).ShipType));
			addScriptParam("PlanetId", String(lPlanetId));
		}
//-----------------------------------------------------------------------------------------------------
// Обработка событий
//-----------------------------------------------------------------------------------------------------
		override protected function OnClick(e:MouseEvent):void {
			// При нажатии - выполнить скрипт
			// Если выбран корабль
			if(lMarketShipsPage.Selected != null) {
				super.OnClick(e);
			}
		}
//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------

//-----------------------------------------------------------------------------------------------------
	}
}