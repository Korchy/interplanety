package Vn.Ships.Routes {
//-----------------------------------------------------------------------------------------------------
	// Окно создания маршрута
//-----------------------------------------------------------------------------------------------------
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import Vn.Math.Vector2;
	import Vn.SpaceObjects.InteractiveSpaceObjectRC;
	import Vn.System.PHPLoader;
	import Vn.Interface.Window.VnWindowB;
	import Vn.Interface.List.ImageListSelect;
	import Vn.Interface.List.ImageListSelectAB;
	import Vn.Interface.Button.Button;
	import Vn.Ships.Ship;
	import Vn.Text.TextDictionary;
	import Vn.Scene.StarSystem.StarSystemRealVn;
	import Vn.Synchronize.ServerTime;
	import Vn.Dock.ShipsWindow;
	import Vn.Interplanety;
//-----------------------------------------------------------------------------------------------------
	public class AddRouteWindow extends VnWindowB {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		private var lPages:ImageListSelect;	// Страничный компонент для размещения пиктограмм планет назначения
		private var lStartRoute:StartRouteButton;	// Кнопка старта маршрута
		private var RouteCreator:PHPLoader;	// Загрузчик для создания маршрута на сервере
		private var CurrentShip:Ship;	// Корабль для которого прокладывается маршрут
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function AddRouteWindow(PShip:Ship) {
			// В параметре - указатель на корабль
			// Конструктор предка
			super();
			CurrentShip = PShip;
			// Загрузка графики
			Name = 52;
			Caption.Text = TextDictionary.Text(Name);
			SetLocalPosition(181, 60);
			// Страничный компонент
			lPages = new ImageListSelectAB(new Vector2(Width,Height-WorkSpace.Y));
			addChild(lPages);
			lPages.MoveIntoParent(Width05,WorkSpace.Y+lPages.Height05,true);	// По верхнему краю Workspace
			// Создать пиктограммы для планет
			for (var i:uint = 0; i < StarSystemRealVn(Vn.Interplanety.Universe.CurrentStarSystem).FlyEnable.length; i++) {
//trace(InteractiveSpaceObjectRC(StarSystemRealVn(Vn.Interplanety.Universe.CurrentStarSystem).FlyEnable[i]).Id);
				var Pl:InteractiveSpaceObjectRC = InteractiveSpaceObjectRC(StarSystemRealVn(Vn.Interplanety.Universe.CurrentStarSystem).FlyEnable[i]);	// Планета
				// Если планета доступна по уровню для полетов и не является планетой старта
				if(Pl.Level<=Vn.Interplanety.VnUser.Level&&PShip.PlanetA.SpaceObjectId!=Pl.SpaceObjectId) {
					var PlanetP:DestTime = new DestTime();
					PlanetP.SPlanet = Pl;
					var Img:uint = Pl.Img30x30;
					PlanetP.Pict.ReLoadById(Img);
					PlanetP.CountDestTime(PShip.PlanetA, Pl, PShip);
					lPages.Add(PlanetP);
//					PlanetP.DTime.Text = String(InteractiveSpaceObjectRC(StarSystemRealVn(Vn.Interplanety.Universe.CurrentStarSystem).FlyEnable[i]).Id);
				}
			}
			// Отсортировать список по времени
			lPages.Objects.sort(DestTime.TimeSort);
			lPages.Refresh();
			// Кнопка старта
			lStartRoute = new StartRouteButton();
			addChild(lStartRoute);
			lStartRoute.addEventListener(Button.CLICKED,CreateRoute);
			// Создание маршрута
			RouteCreator = new PHPLoader();	// Загрузчик
			RouteCreator.addEventListener(Event.COMPLETE,OnCRComplete);
			RouteCreator.addEventListener(IOErrorEvent.IO_ERROR,OnCRIoError);
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		override public function _delete():void {
			// Убрать страничный компонент
			removeChild(lPages);
			lPages._delete();
			lPages = null;
			// Кнопка старта
			lStartRoute.removeEventListener(Button.CLICKED,CreateRoute);
			removeChild(lStartRoute);
			lStartRoute._delete();
			lStartRoute = null;
			// Создание маршрута
			RouteCreator.removeEventListener(Event.COMPLETE,OnCRComplete);
			RouteCreator.removeEventListener(IOErrorEvent.IO_ERROR,OnCRIoError);
			RouteCreator._delete();
			RouteCreator = null;
			// Деструктор предка
			super._delete();
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
	
//-----------------------------------------------------------------------------------------------------
// Обработка событий
//-----------------------------------------------------------------------------------------------------
		private function CreateRoute(e:Event):void {
			// Создать маршрут
			if(lPages.Selected!=null) {
				// Нужно передать серверу корабль и планету назначения
				RouteCreator.AddVariable("PlanetId",String(lPages.Selected.SPlanet.SpaceObjectId));
				RouteCreator.AddVariable("UserShipId",String(CurrentShip.Id));
				// Создать маршрут
				RouteCreator.Load("createroute.php");
			}
		}
//-----------------------------------------------------------------------------------------------------
		protected function OnCRComplete(e:Event):void {
			// Маршрут создан
			if(e.target.data=="T") {
				// Маршрут создан
				// Изменить данные по кораблю
				CurrentShip.PlanetB = lPages.Selected.SPlanet;	// Планета назначения
				var STime:Number = ServerTime.Time;
				CurrentShip.TimeA = STime;
				CurrentShip.TimeB = STime + lPages.Selected.FlyTime * 1000;	// Перевести в мс
				// Убрать корабль из списка в окне кораблей
				ShipsWindow(Leader.parent.parent.parent).RemoveElement(CurrentShip);
				// Создать визуальный маршрут
				CurrentShip.CreateVisualRoute();
				// Закрыть окно
				Close();
			}
			else {
				// Маршрут не создан
				Vn.Interplanety.Cons.Add(TextDictionary.Text(54));
			}
		}
//-----------------------------------------------------------------------------------------------------
		protected function OnCRIoError(e:Event):void {
			// Ошибка создания маршрута
			
		}
//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------
		public function get Pages():ImageListSelect {
			// Указатель на страничный компонент
			return lPages;
		}
//-----------------------------------------------------------------------------------------------------
		public function get StartRouteBtn():StartRouteButton {
			// Указатель на кнопку старта маршрута
			return lStartRoute;
		}
//-----------------------------------------------------------------------------------------------------
	}
}