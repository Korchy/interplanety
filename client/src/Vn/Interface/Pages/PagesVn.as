package Vn.Interface.Pages {
	// Страничный компонент с размещением объктов на разных страницах
//-----------------------------------------------------------------------------------------------------
	import flash.events.Event;
	import Vn.Math.Vector2;
	import Vn.Common.SC;
	import Vn.Interface.Pages.PageControl;
	import Vn.Interface.Text.VnText;
	import Vn.Objects.VnObjectR;
//-----------------------------------------------------------------------------------------------------
	public class PagesVn extends VnObjectR {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		private var PControl:PageControl;	// Страничный компонент
		private var PageTxt:VnText;			// Текстовый номер страницы
		private var ShowPageTxt:Boolean;	// true - показывать номер страницы, false - нет
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function PagesVn(vNewSize:Vector2) {
			// Конструктор предка
			super();
			// Конструктор
			SetLocalPosition(vNewSize.X / 2.0, vNewSize.Y / 2.0);
			PControl = new PageControl();
			// Номер текущей страницы
			PageTxt = new VnText();
			PageTxt.x = Width05;	// Размещение по центру внизу
			PageTxt.y = Height-20;
			PageTxt.textColor = SC.BLACK;
			ShowPageNumber = false;
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		override public function _delete():void {
			// Деструктор
			Clear();
			PControl._delete();
			PControl = null;
			if(PageTxt.parent!=null) removeChild(PageTxt);
			PageTxt._delete();
			PageTxt = null;
			// Деструктор предка
			super._delete();
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		public function Clear():void {
			// Очистка компонента - удаление всех объектов из массива
			for(var i:uint=0;i<Length;) {
				if(Objects[i]!=null&&Objects[i]!=undefined) {
					if(Objects[i][0].parent!=null) removeChild(Objects[i][0]);
					Objects[i][0]._delete();
					Objects.splice(i,1);
				}
			}
			CurrentPage = 1;
		}
//-----------------------------------------------------------------------------------------------------
		public function Refresh():void {
			// Обновить показ страницы
			if(parent!=null) {
				ShowCurrentPage();
			}
		}
//-----------------------------------------------------------------------------------------------------
		public function Add(Element:*,PageNumber:uint,Cx:uint,Cy:uint):void {
			// Добавление элемента в страничный компонент
			// Создать скроку, описывающую положение элемента на странице
			var ElementDesc:Array = new Array();
			ElementDesc.push(Element);				// [0]
			ElementDesc.push(PageNumber);			// [1]
			ElementDesc.push(Cx);					// [2]
			ElementDesc.push(Cy);					// [3]
			// Добавить ее в массив эелементов
			PControl.Add(ElementDesc);
			if (CurrentPage == Pages) Refresh();	// Если показана последняя страница - обновить показ
		}
//-----------------------------------------------------------------------------------------------------
		protected function ClearCurrentPage():void {
			// Очистить страницу (убрать элементы без удаления)
			for(var i:uint=0;i<Length;i++) {
				if(Objects[i][1]!=CurrentPage&&Objects[i][0].parent!=null) removeChild(Objects[i][0]);
			}
		}
//-----------------------------------------------------------------------------------------------------
		protected function ShowCurrentPage():void {
			// Показать страницу с текущим номером Page
			PageTxt.Text = String(CurrentPage);
			// Убрать не относящееся к странице и показать то что к ней относится
			for(var i:uint=0;i<Length;i++) {
				if(Objects[i][1]!=CurrentPage&&Objects[i][0].parent!=null) {
					removeChild(Objects[i][0]);
				}
				if(Objects[i][1]==CurrentPage&&Objects[i][0].parent==null) {
					// Если это элемент с этой страницы - добавить его
					addChild(Objects[i][0]);
					Objects[i][0].MoveIntoParent(Objects[i][2], Objects[i][3], true);
				}
			}
		}
//-----------------------------------------------------------------------------------------------------
		public function ShowPage(PageToShow:uint):void {
			// Показать страницу с номером
			CurrentPage = PageToShow;
			ShowCurrentPage();
		}
//-----------------------------------------------------------------------------------------------------
// Обработка событий
//-----------------------------------------------------------------------------------------------------
		override protected function OnAddToStage(e:Event):void {
			// При добавлении в список отображения
			ShowCurrentPage();
		}
//-----------------------------------------------------------------------------------------------------
		override protected function OnRemoveFromStage(e:Event):void {
			// При удалении из списка отображения
			ClearCurrentPage();
		}
//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------
		public function get ShowPageNumber():Boolean {
			return ShowPageTxt;
		}
//-----------------------------------------------------------------------------------------------------
		public function set ShowPageNumber(Value:Boolean):void {
			if(Value==true&&PageTxt.parent==null) addChild(PageTxt);
			if(Value==false&&PageTxt.parent!=null) removeChild(PageTxt);
		}
//-----------------------------------------------------------------------------------------------------
		public function get Pages():uint {
			// Количество страниц
			var PagesCount:uint = 1;
			for (var i:uint = 0; i < Length; i++) {
				if (Objects[i][1] > PagesCount) PagesCount = Objects[i][1];
			}
			return PagesCount;
		}
//-----------------------------------------------------------------------------------------------------
		public function get CurrentPage():uint {
			// Текущая страница
			return PControl.CurrentPage;
		}
//-----------------------------------------------------------------------------------------------------
		public function set CurrentPage(Value:uint):void {
			PControl.CurrentPage = Value;
		}
//-----------------------------------------------------------------------------------------------------
		public function get Objects():Array {
			// Массив объектов списка
			return PControl.Objects;
		}
//-----------------------------------------------------------------------------------------------------
		public function get Length():uint {
			// Длина списка
			return PControl.Length;
		}
//-----------------------------------------------------------------------------------------------------
	}
}