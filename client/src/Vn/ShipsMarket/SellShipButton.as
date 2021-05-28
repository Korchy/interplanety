﻿package Vn.ShipsMarket {
//-----------------------------------------------------------------------------------------------------
// Кнопка "Продажа корабля"
//-----------------------------------------------------------------------------------------------------
	import flash.events.MouseEvent;
	import Vn.Interface.Button.Button;
	import Vn.Interface.Button.ButtonL;
	import Vn.Interface.List.ImageListSelect;
	import Vn.Math.Vector2;
	import Vn.Objects.VnObjectT;
	import Vn.Text.TextDictionary;
//-----------------------------------------------------------------------------------------------------
	public class SellShipButton extends ButtonL {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		private var lUserShipsPage:ImageListSelect;	// Указатель на список кораблей пользователя
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function SellShipButton(vUserShipsPage:ImageListSelect) {
			// Конструктор предка
			super();
			// Конструктор
			lUserShipsPage = vUserShipsPage;
			NeedPlace = true;
			ReLoadById(131);	// sellshipbutton
			Script = "sellship.php";
			// Текст
			Type = Button.BUTTON_TXT;
			Text = TextDictionary.Text(67);	// После ReLoad т.к выравнивается по центру
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
		override protected function setScriptParams():void {
			// Параметры
			addScriptParam("ShipId", String(SellShipContainer(lUserShipsPage.Selected).Id));
		}
//-----------------------------------------------------------------------------------------------------
		override protected function GetPlace():Vector2 {
			// Местоположение - на 60 pix вправо от центра х центр + 5 pix
			if(stage!=null) {
				// Если добавлена в список отображения - определить место
				return new Vector2(VnObjectT(parent).Width05+Width05+5,VnObjectT(parent).Height05);
			}
			else {
				// Если не добавлена - 0,0
				return new Vector2(0.0,0.0);
			}
		}
//-----------------------------------------------------------------------------------------------------
		override protected function OnClick(e:MouseEvent):void {
			// При нажатии - выполнить скрипт
			// Если параметр ShipId!=null (корабль выбран)
			if(lUserShipsPage.Selected != null) {
				super.OnClick(e);
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