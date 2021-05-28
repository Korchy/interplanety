package Vn.Interface.List {
	// Класс List - набор строк
//-----------------------------------------------------------------------------------------------------
	import flash.events.Event;
//-----------------------------------------------------------------------------------------------------
	public class List extends VnObjectR {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		private var ListArray:Array;		// Массив строк (объектов VnTextI)
		private var Scroll:ScrollBar;		// Скроллбар
		private var ScrollV:uint;			// Номер первого отображаемого объекта в списке ListArray
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function List(NewWidth:uint=100,NewHeight:uint=100) {
			// Конструктор предка
			super();
			// Конструктор
			SetLocalPosition(NewWidth/2,NewHeight/2);
			ListArray = new Array(0);
			ScrollV = 0;
			// Скроллбар
			Scroll = new ScrollBar(10,NewHeight-10);
			addChild(Scroll);
			Scroll.MoveIntoParent(Width-Scroll.Width05,Height05,true);
			Scroll.addEventListener(ScrollBar.SCROLLING,OnScrolling);
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		override public function _delete():void {
			// Деструктор
			// Скроллбар
			Scroll.removeEventListener(ScrollBar.SCROLLING,OnScrolling);
			removeChild(Scroll);
			Scroll._delete();
			Scroll = null;
			// Список строк
			for(var i:uint=0;i<ListArray.length;) {
				if(ListArray[i]!=null&&ListArray[i]!=undefined) {
					removeChild(ListArray[i]);
					ListArray[i]._delete();
					ListArray.splice(i,1);
				}
			}
			// Деструктор предка
			super._delete();
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		public function Add(NewObject:Object):void {
			NewObject.Width = Width-Scroll.Width;
			ListArray.push(NewObject);
			Refresh();
		}
//-----------------------------------------------------------------------------------------------------
		private function Refresh():void {
			// Переопределить отображаемые объекты
			if(ListArray.length==0) return;
			// Убрать все отображенное
			for(var j:uint=0;j<ListArray.length;j++) {
				if(ListArray[j].stage!=null) removeChild(ListArray[j]);
			}
			// Добавить все видимое
			for(var i:uint=0;i<VisibleCount;i++) {
				var P:uint = ScrollV+i;
				if(ListArray[P]!=null&&ListArray[P]!=undefined) {
					addChild(ListArray[P]);
					ListArray[P].MoveIntoParent(ListArray[0].Width05,i*ListArray[0].Height+ListArray[0].Height05,true);
				}
			}
			
		}
//-----------------------------------------------------------------------------------------------------
// Обработка событий
//-----------------------------------------------------------------------------------------------------
		public function OnScrolling(e:Event):void {
			// При скроллировании
			// Пересчитать первый видимый объект
			var Interv:int = ListArray.length-VisibleCount+1;	// Кол-во вариантов показа строк
			if(Interv>0) {
				var IntervD:Number = 1/Interv;						// Высота одного варианта в долях (от 0 до 1)
				var ScrollOffset:Number = Scroll.Offset;
				if(ScrollOffset==1.0) ScrollOffset = 0.99;		// Т.к. при 1 перескакивает на следующую строчку
				ScrollV = Math.floor(ScrollOffset/IntervD);		// Сколько вариантов (получается номер варианта) содержится в значении, что показывает скроллбар
			}
			else ScrollV = 0;
			Refresh();
		}
//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------
		public function set Width(Value:uint):void {
			SetLocalPosition(Value/2,Height05);
			Scroll.MoveIntoParent(Width-Scroll.Width05,Height05,true);
			for(var i:uint=0;i<ListArray.length;i++) {
				if(ListArray[i]!=null&&ListArray[i]!=undefined) {
					ListArray[i].Width = Width-Scroll.Width;
				}
			}
		}
//-----------------------------------------------------------------------------------------------------
		public function set Height(Value:uint):void {
			SetLocalPosition(Width05,Value/2);
			Scroll.SetLocalPosition(10,(Value-10)/2);
		}
//-----------------------------------------------------------------------------------------------------
		public function get VisibleCount():uint {
			// Количество отображаемых объектов (в зависимости от размеров компонента)
			if(ListArray.length==0) return 0;
			return Math.round(Height/ListArray[0].Height);
		}
//-----------------------------------------------------------------------------------------------------
		public function get All():Array {
			return ListArray;	// Указатель на массив объектов
		}
//-----------------------------------------------------------------------------------------------------
		public function get Length():uint {
			// Общее кол-во объектов
			return ListArray.length;
		}
//-----------------------------------------------------------------------------------------------------
	}
}