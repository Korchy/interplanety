package Vn.Ships {
//-----------------------------------------------------------------------------------------------------
// Менеджер кораблей
//-----------------------------------------------------------------------------------------------------
	import Vn.List.ObjectsListLVn;
	import Vn.Connections.Events.EvReceivedServerData;
	import Vn.Scene.StarSystem.StarSystemRealVn;
	import Vn.Ships.Routes.Events.EvRouteFinish;
	import Vn.SpaceObjects.InteractiveSpaceObjectRC;
	import Vn.Text.TextDictionary;
	import Vn.Common.Common;
	import Vn.Interplanety;
//-----------------------------------------------------------------------------------------------------
	public class ShipsManager extends ObjectsListLVn  {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function ShipsManager() {
			// Конструктор предка
			super();
			// Конструктор
			Vn.Interplanety.CManager.addEventListener(EvReceivedServerData.RECEIVED_SERVER_DATA, OnReceivedServerData);
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, Sавтоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		override public function _delete():void {
			// Деструктор
			Vn.Interplanety.CManager.removeEventListener(EvReceivedServerData.RECEIVED_SERVER_DATA, OnReceivedServerData);
			// Деструктор предка
			super._delete();
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		override protected function CreateListFromXML(Data:XML):void {
			// Создание списка по полученным XML-данным
			for each (var Node:XML in Data.*) {
				if(Node.nodeKind()=="element") {
					var UserShip:Ship = new Ship();
					UserShip.LoadFromXML(Node);
					Add(UserShip);
				}
			}
		}
//-----------------------------------------------------------------------------------------------------
		private function RouteFinished(FinishedRouteInfo:String):void {
			// Обработать завершение маршрута
			var Info:Object = Common.StringToKeyedArray(FinishedRouteInfo.substring(5, FinishedRouteInfo.length - 1), " ", "=");
			// Обновить данные для корабля
			var CurrentShip:Ship = Ship(StarSystemRealVn(Vn.Interplanety.Universe.CurrentStarSystem).Ships.ById(uint(Info["id"])));
			var PlanetAId:uint = CurrentShip.PlanetA.SpaceObjectId;	// Для генерации события
			CurrentShip.PlanetA = CurrentShip.PlanetB;	// Планета старта = планете назначения -> корабль сел на планету
			if (CurrentShip.VRoute != null) CurrentShip.DeleteVisualRoute();	// Удалить визуальный маршрут
			// Сгенерировать событие о завершении маршрута
			dispatchEvent(new EvRouteFinish(EvRouteFinish.ROUTE_FINISH,PlanetAId,CurrentShip.PlanetB.SpaceObjectId));
			// Добавить в консоль сообщение о прибытии
			Vn.Interplanety.Cons.Add(TextDictionary.Text(CurrentShip.Name) + " " + TextDictionary.Text(78) + " " + String(CurrentShip.Id) + " " + InteractiveSpaceObjectRC(Vn.Interplanety.Universe.CurrentStarSystem.GetById(CurrentShip.PlanetB.Id)).ArrivedText());
			// Обновить значение опыта
			Vn.Interplanety.VnUser.RefreshExp();
		}
//-----------------------------------------------------------------------------------------------------
		public function HasRoute(PlanetAId:uint, PlanetBId:uint):Boolean {
			// Проверка: есть-ли маршрут между этими двумя планетами из A в B (направление соблюдается)
			for (var i:uint = 0; i < All.length; i++) {
				if (Ship(All[i]).PlanetA.SpaceObjectId == PlanetAId && Ship(All[i]).PlanetB.SpaceObjectId == PlanetBId) {
					return true;
					break;
				}
			}
			return false;
		}
//-----------------------------------------------------------------------------------------------------
// Обработка событий
//-----------------------------------------------------------------------------------------------------
		private function OnReceivedServerData(e:EvReceivedServerData):void {
			// Получены данные с сервера
			// Проверить - есть ли данные о завершенных маршрутах
			var FinishedRoutes:String = e.Data;
			var FinishedRouteSP:int = FinishedRoutes.indexOf("<002");
			while (FinishedRouteSP != -1) {
				// Обработать последовательно данные о завершенных маршрутах
				FinishedRoutes = FinishedRoutes.substr(FinishedRouteSP);
				var FinishedRouteEP:int = FinishedRoutes.indexOf(">");
				var CurrentFinishedRoute:String = FinishedRoutes.substr(0, FinishedRouteEP+1);
				RouteFinished(CurrentFinishedRoute);
				FinishedRoutes = FinishedRoutes.substr(FinishedRouteEP + 1);
				FinishedRouteSP = FinishedRoutes.indexOf("<002");
			}
		}
//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------
		
//-----------------------------------------------------------------------------------------------------
	}
}