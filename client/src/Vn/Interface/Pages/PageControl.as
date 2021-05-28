package Vn.Interface.Pages {
	// Страничный компонент
	// По сути - массив и счетчик страниц
//-----------------------------------------------------------------------------------------------------
	import Vn.Math.Vector2;
	import Vn.Objects.VnObject;
	import Vn.Objects.VnObjectU;
//-----------------------------------------------------------------------------------------------------
	public class PageControl extends VnObject {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		protected var PObjectsList:Array;	// Массив указателей на объекты
		private var lCurrentPage:uint;		// Текущая страница
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function PageControl() {
			// Конструктор предка
			super();
			// Конструктор
			// Объекты
			PObjectsList = new Array();
			// Страница
			CurrentPage = 1;
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		override public function _delete():void {
			// Деструктор
			// Очищаем массив объектов
			Clear();
			PObjectsList = null;
			// Деструктор предка
			super._delete();
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		public function Clear():void {
			// Очистка компонента - удаление всех объектов из массива
			for(var i:uint=0;i<PObjectsList.length;) {
				if(PObjectsList[i]!=null&&PObjectsList[i]!=undefined) {
					if(PObjectsList[i].parent!=null) PObjectsList[i].parent.removeChild(PObjectsList[i]);
					PObjectsList[i]._delete();
				}
				PObjectsList.splice(i,1);
			}
			CurrentPage = 1;
		}
//-----------------------------------------------------------------------------------------------------
		public function Add(Element:*):void {
			// Добавление элемента в страничный компонент
			PObjectsList.push(Element);
		}
//-----------------------------------------------------------------------------------------------------
		public function Delete(Element:*):void {
			// Удаление элемента из страничного компонента (с удалением самого элемента)
			for(var i:uint=0;i<PObjectsList.length;i++) {
				if(PObjectsList[i]==Element) {
					if(PObjectsList[i].parent!=null) PObjectsList[i].parent.removeChild(PObjectsList[i]);
					PObjectsList[i]._delete();
					PObjectsList.splice(i,1);
					break;
				}
			}
		}
//-----------------------------------------------------------------------------------------------------
		public function DeleteById(Id:uint):void {
			// Удаление элемента из страничного компонента по его Id (с удалением самого элемента)
			for (var i:uint = 0; i < Length; i++) {
				if(PObjectsList[i].Id==Id) {
					if(PObjectsList[i].parent!=null) PObjectsList[i].parent.removeChild(PObjectsList[i]);
					PObjectsList[i]._delete();
					PObjectsList.splice(i,1);
					break;
				}
			}
		}
//-----------------------------------------------------------------------------------------------------
		public function Remove(Element:*):void {
			// Удаление элемента из страничного компонента (без удаления самого элемента)
			for(var i:uint=0;i<PObjectsList.length;i++) {
				if(PObjectsList[i]==Element) {
					if(PObjectsList[i].parent!=null) PObjectsList[i].parent.removeChild(PObjectsList[i]);
					PObjectsList.splice(i,1);
					break;
				}
			}
		}
//-----------------------------------------------------------------------------------------------------
		public function GetById(Id:uint):* {
			// Поиск элемента по Id
			var Rez:* = null;
			for (var i:uint = 0; i < PObjectsList.length; i++) {
				if (PObjectsList[i].Id == Id) {
					Rez = PObjectsList[i];
					break;
				}
			}
			return Rez;
		}
//-----------------------------------------------------------------------------------------------------
		public function Update():void {
			// Обновление
			for (var i:uint = 0; i < PObjectsList.length; i++) {
				if (PObjectsList[i] is VnObjectU) VnObjectU(PObjectsList[i]).Update();
			}
		}
//-----------------------------------------------------------------------------------------------------
// Обработка событий
//-----------------------------------------------------------------------------------------------------
		
//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------
		public function get Objects():Array {
			return PObjectsList;
		}
//-----------------------------------------------------------------------------------------------------
		public function get Length():uint {
			return PObjectsList.length;
		}
//-----------------------------------------------------------------------------------------------------
		public function get CurrentPage():uint {
			return lCurrentPage;	// Номер текущей страницы
		}
//-----------------------------------------------------------------------------------------------------
		public function set CurrentPage(Value:uint):void {
			lCurrentPage = Value;
		}
//-----------------------------------------------------------------------------------------------------
	}
}