package Vn.Interface.List {
//-----------------------------------------------------------------------------------------------------
// Страничный компонент со списком объектов с изображениями
//-----------------------------------------------------------------------------------------------------
	import flash.events.Event;
	import Vn.Math.Vector2;
	import Vn.Interface.Pages.PageControl;
	import Vn.Interface.Scroll.ScrollPagesB;
	import Vn.Objects.VnObjectR;
//-----------------------------------------------------------------------------------------------------
	public class ImageList extends VnObjectR {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		private var PControl:PageControl;	// Страничный компонент
		private var Scroller:ScrollPagesB;	// Скроллер страниц
		private var Dx:uint;				// Смещение левого верхнего объекта от левого верхнего угла по X
		private var Dy:uint;				// Смещение левого верхнего объекта от левого верхнего угла по Y
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function ImageList(vNewSize:Vector2) {
			// Конструктор предка
			super();
			// Конструктор
			SetLocalPosition(vNewSize.X / 2.0, vNewSize.Y / 2.0);
			PControl = new PageControl();
			// Скроллер страниц
			Scroller = new ScrollPagesB(vNewSize);
			Scroller.addEventListener(ScrollPagesB.NEXT,ButtonNextClicked);
			Scroller.addEventListener(ScrollPagesB.PREV,ButtonPrevClicked);
			addChild(Scroller);
			// Страница
			Dx = Scroller.ClientX;	// Расстояние от кнопок
			Dy = Scroller.ClientY;
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		override public function _delete():void {
			// Деструктор
			PControl._delete();
			PControl = null;
			// Скроллер страниц
			Scroller.removeEventListener(ScrollPagesB.NEXT,ButtonNextClicked);
			Scroller.removeEventListener(ScrollPagesB.PREV,ButtonPrevClicked);
			removeChild(Scroller);
			Scroller._delete();
			Scroller = null;
			// Деструктор предка
			super._delete();
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		public function ReSize(NewSize:Vector2):void {
			// Изменить размеры
			SetLocalPosition(NewSize.X / 2.0, NewSize.Y / 2.0);
			if(Scroller!=null) Scroller.ReSize(NewSize);
			Refresh();
		}
//-----------------------------------------------------------------------------------------------------
		public function Refresh():void {
			// Обновить показ страницы
			if(parent!=null) {
				ClearCurrentPage();
				ShowCurrentPage();
			}
		}
//-----------------------------------------------------------------------------------------------------
		public function Add(Element:*):void {
			// Добавление элемента в страничный компонент
			PControl.Add(Element);
			if (CurrentPage == Pages) Refresh();	// Если показана последняя страница - обновить показ
		}
//-----------------------------------------------------------------------------------------------------
		public function AddWithoutRefresh(Element:*):void {
			// Добавление элемента в страничный компонент без обновления отображения
			// Для занесения нескольких элементов подряд, чтобы не перерисовывать при добавлении каждого
			// Автоматический Refresh после добавления не вызывается - вызвать его отдельно
			PControl.Add(Element);
		}
//-----------------------------------------------------------------------------------------------------
		public function Remove(Element:*):void {
			// Удаление элемента из страничного компонента (без удаления самого элемента)
			PControl.Remove(Element);
			Refresh();	// обновить показ
		}
//-----------------------------------------------------------------------------------------------------
		public function Delete(Element:*):void {
			// Удаление элемента из страничного компонента (с удалением самого элемента)
			PControl.Delete(Element);
			Refresh();	// обновить показ
		}
//-----------------------------------------------------------------------------------------------------
		public function DeleteById(Id:uint):void {
			// Удаление элемента из страничного компонента по его Id (с удалением самого элемента)
			PControl.DeleteById(Id);
			Refresh();	// обновить показ
		}
//-----------------------------------------------------------------------------------------------------
		public function GetById(Id:uint):* {
			// Возвращает элемент списк по его Id
			return PControl.GetById(Id);
		}
//-----------------------------------------------------------------------------------------------------
		public function Clear():void {
			// Очистка списка
			PControl.Clear();
		}
//-----------------------------------------------------------------------------------------------------
		protected function ClearCurrentPage():void {
			// Очистить страницу (убрать элементы без удаления)
			for(var i:uint=0;i<Length;i++) {
				if(Objects[i].parent!=null) removeChild(Objects[i]);
			}
		}
//-----------------------------------------------------------------------------------------------------
		protected function ShowCurrentPage():void {
			// Показать страницу с текущим номером Page
			// На странице отображается по ElementsG объектов в ElementsV рядов
			var FirstX:uint = Dx;	// Положение левого верхнего угла первого индикатора
			var FirstY:uint = Dy;
			for (var i:uint = CurrentPageStartInd(); i < CurrentPageEndInd(); i++) {
				if (Objects[i].parent == null) {
					addChild(Objects[i]);
					Objects[i].MoveIntoParent(FirstX+Objects[i].Width05,FirstY+Objects[i].Height05,true);
					FirstX += Objects[i].Width+DDx;
					if((i+1)%ElementsG==0) {
						FirstX = Dx;
						FirstY += Objects[i].Height+DDy;
					}
				}
			}
		}
//-----------------------------------------------------------------------------------------------------
		protected function ShowPage(PageNumber:uint):void {
			// Показ страницы № PageNumber
		if (PageNumber < 1 || PageNumber > Pages) PageNumber = 1;
			CurrentPage = PageNumber;
			Refresh();
		}
//-----------------------------------------------------------------------------------------------------
		protected function CurrentPageStartInd():uint {
			// Возвращает индекс объекта в массиве для первого элемента, который нужно вывести на страницу
			return (CurrentPage-1)*ElementsV*ElementsG;
		}
//-----------------------------------------------------------------------------------------------------
		protected function CurrentPageEndInd():uint {
			// Возвращает индекс объекта в массиве для последнего элемента, который нужно вывести на страницу
			var EndInd:uint	 = CurrentPageStartInd()+ElementsV*ElementsG;
			if(EndInd>Length) EndInd = Length;
			return EndInd;
		}
//-----------------------------------------------------------------------------------------------------
		public function Update():void {
			// Обновление состояния
			PControl.Update();
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
		protected function ButtonPrevClicked(e:Event):void {
			if(CurrentPage>1) {
				ClearCurrentPage();
				CurrentPage--;
				ShowCurrentPage();
			}
		}
//-----------------------------------------------------------------------------------------------------
		protected function ButtonNextClicked(e:Event):void {
			if(CurrentPage<Pages) {
				ClearCurrentPage();
				CurrentPage++;
				ShowCurrentPage();
			}
		}
//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------
		public function get ElementsG():uint {
			// Кол-во элементов по горизонтали
			if (Length > 0) return Math.floor((Width - 2 * Dx) / (Objects[0].Width));
			else return 0;
		}
//-----------------------------------------------------------------------------------------------------
		public function get ElementsV():uint {
			// Кол-во элементов по вертикали
			if (Length > 0) return Math.floor((Height - 2 * Dy) / (Objects[0].Height));
			else return 0;
		}
//-----------------------------------------------------------------------------------------------------
		public function get DDx():uint {
			// Промежуток между объектами по горизонтали
			if (Length > 0) return Math.floor((Width - 2 * Dx - Objects[0].Width * ElementsG) / (ElementsG - 1));
			else return 0;
		}
//-----------------------------------------------------------------------------------------------------
		public function get DDy():uint {
			// Промежуток между объектами по вертикали
			if (Length > 0) return Math.floor((Height - 2 * Dy - Objects[0].Height * ElementsV) / (ElementsV - 1));
			else return 0;
		}
//-----------------------------------------------------------------------------------------------------
		public function get Pages():uint {
			// Количество страниц
			if (Length > 0 && ElementsG != 0 && ElementsV != 0) return Math.ceil(Length / (ElementsV * ElementsG));
			else return 1;
		}
//-----------------------------------------------------------------------------------------------------
		public function get CurrentPage():uint {
			// Текущая страница
			return PControl.CurrentPage;
		}
//-----------------------------------------------------------------------------------------------------
		public function set CurrentPage(Value:uint):void {
			// Номер текущей страницы
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