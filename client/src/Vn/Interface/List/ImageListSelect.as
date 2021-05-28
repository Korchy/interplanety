package Vn.Interface.List {
//-----------------------------------------------------------------------------------------------------
// Список объектов ImageList с выбором отдельного объекта
//-----------------------------------------------------------------------------------------------------
	import flash.events.Event;
	import flash.events.MouseEvent;
	import Vn.Math.Vector2;
	import Vn.Objects.VnObjectT;
//-----------------------------------------------------------------------------------------------------
	public class ImageListSelect extends ImageList {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		private var SelectedObject:Object;	// Выделенноый объект в списке Objects
		// Константы событий
		public static const SELECTION_CHANGED:String = "EvPagesSelectChanged";	// Идентификатор "изменен выбранный объект"
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function ImageListSelect(Center:Vector2) {
			// Конструктор предка
			super(Center);
			// Конструктор
			// Если окно на один элемент - он выделен, иначе выделения нет
			Selected = null;
			// Добавить слушатель на выделения
			for(var i:uint=0;i<Length;i++) {
				Objects[i].addEventListener(MouseEvent.CLICK, OnChangeSelection);
			}
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		override public function _delete():void {
			// Деструтор
			SelectedObject = null;
			// Убрать слушатель на выделения
			for(var i:uint=0;i<Length;i++) {
				Objects[i].removeEventListener(MouseEvent.CLICK, OnChangeSelection);
			}
			// Деструктор предка
			super._delete();
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		override public function Add(Element:*):void {
			// Добавление элемента в страничный компонент
			// Слушаем клики для выделения
			Element.addEventListener(MouseEvent.CLICK,OnChangeSelection);
			// Обновить страницу
			super.Add(Element);
			// Выбранный элемент
			if(ElementsV==1&&ElementsG==1&&Selected==null) Selected = Objects[0];
		}
//-----------------------------------------------------------------------------------------------------
		override public function Delete(Element:*):void {
			// Удаление элемента из страничного компонента
			// Снять выделение
			ClearSelection();
			// Снять слушатель кликов для выделения
			Element.removeEventListener(MouseEvent.CLICK,OnChangeSelection);
			// Обновить страницу
			super.Delete(Element);
		}
//-----------------------------------------------------------------------------------------------------
		override public function DeleteById(Id:uint):void {
			// Удаление элемента из страничного компонента по его Id
			for(var i:uint=0;i<Length;i++) {
				if(Objects[i].Id==Id) {
					Delete(Objects[i]);
					break;
				}
			}
		}
//-----------------------------------------------------------------------------------------------------
		public function SelectByNum(vNum:uint):Boolean {
			// Выбор по порядковому номеру
			if (Objects[vNum] != null && Objects[vNum] != undefined) {
				Selected = Objects[vNum];
				return true;
			}
			return false;
		}
//-----------------------------------------------------------------------------------------------------
		override public function Clear():void {
			// Очистка списка
			Selected = null;
			super.Clear();
		}
//-----------------------------------------------------------------------------------------------------
		private function ClearSelection():void {
			// Снятие выбора
			// Если страница на один объект - он всегда остается выбран
			if(ElementsV==1&&ElementsG==1) {
				if(Selected!=Objects[CurrentPage-1]) Selected = Objects[CurrentPage-1];
			}
			else {
				if (Selected != null) Selected = null;
			}
		}
//----------------------------------------------------------------------------------------------------
		protected function DrawItemSelection(SelectedItem:Object):void {
			// Отрисовка выделения объекта SelectedItem
			// Переопределяется в наследниках
		}
//-----------------------------------------------------------------------------------------------------
		protected function ClearItemSelection():void {
			// Удаление отрисовки выделения объекта
			// Переопределяется в наследниках
		}
//-----------------------------------------------------------------------------------------------------
// Обработка событий
//-----------------------------------------------------------------------------------------------------
		override protected function ButtonPrevClicked(e:Event):void {
			// Кнопка "назад"
			// При переключении - снять выбор
			ClearSelection();
			super.ButtonPrevClicked(e);
		}
//-----------------------------------------------------------------------------------------------------
		override protected function ButtonNextClicked(e:Event):void {
			// Кнопка "вперед"
			// При переключении - снять выбор
			ClearSelection();
			super.ButtonNextClicked(e);
		}
//-----------------------------------------------------------------------------------------------------
		private function OnChangeSelection(e:Event):void {
			// Смена выбора
			Selected = e.currentTarget;
//			ClearItemSelection();
//			DrawItemSelection(Selected);
		}
//-----------------------------------------------------------------------------------------------------
		override protected function OnAddToStage(e:Event):void {
			// При добавлении в список отображения
			super.OnAddToStage(e);
			// Если есть выделенный объект - перерисовать выделение
			if (Selected != null) {
				ClearItemSelection();
				DrawItemSelection(Selected);
			}
		}
//-----------------------------------------------------------------------------------------------------
		override protected function OnRemoveFromStage(e:Event):void {
			// При удалении из списка отображения
			super.OnRemoveFromStage(e);
			// Если было выделение - очистить
			ClearItemSelection();
		}
//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------
		public function get Selected():Object {
			return SelectedObject;
		}
//-----------------------------------------------------------------------------------------------------
		public function set Selected(Value:Object):void {
			if (Selected != Value) {
				ClearItemSelection();		// Снять отрисовку выделения
				SelectedObject = Value;
				if (Value != null && (ElementsV > 1 || ElementsG > 1)) DrawItemSelection(Value);	// Отрисовать выделение у объекта e.currentTarget
			}
			// Сгенерировать событие изменения выбора
			dispatchEvent(new Event(SELECTION_CHANGED));
		}
//-----------------------------------------------------------------------------------------------------
	}
}