package Vn.Tutorial {
//-----------------------------------------------------------------------------------------------------
// Класс для помощи в обучающем квесте "добро пожаловать на борт"
//-----------------------------------------------------------------------------------------------------
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import Vn.Cargo.CargoVn;
	import Vn.Dock.DButton;
	import Vn.Dock.ShipsWindow;
	import Vn.Industry.IButton;
	import Vn.Industry.ISOCargoIndicator;
	import Vn.Interplanety;
	import Vn.Market.MarketWindowVn;
	import Vn.Math.Vector2;
	import Vn.Objects.Var.LoadedObject;
	import Vn.Objects.VnObject;
	import Vn.Objects.VnObjectS;
	import Vn.Objects.VnObjectT;
	import Vn.Quests.QuestVn;
	import Vn.Scene.StarSystem.StarSystemRealVn;
	import Vn.Ships.Cargo.ShipCargoIndicator;
	import Vn.Ships.Routes.AddRouteButton;
	import Vn.Ships.Routes.AddRouteWindow;
	import Vn.Ships.Ship;
	import Vn.Ships.ShipManager;
	import Vn.SpaceObjects.InteractiveSpaceObject;
	import Vn.SpaceObjects.ISOCommonWindow;
//-----------------------------------------------------------------------------------------------------
	public class TutorialHelper extends VnObject {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		private var lArrow:VnObjectS;	// Стрелка
		private var lTimer:Timer;		// Таймер переключения стрелки
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function TutorialHelper() {
			// Конструктор предка
			super();
			// Конструктор
			lArrow = new VnObjectS();
			lArrow.ReLoadById(186);		// helparrow.png
			lTimer = new Timer(500);	// Частота - два раза в секунду
			lTimer.addEventListener(TimerEvent.TIMER,ShowHelpArrow);
			lTimer.start();
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		override public function _delete():void {
			// Деструктор
			if (lArrow.parent != null) lArrow.parent.removeChild(lArrow);
			lArrow._delete();
			lArrow = null;
			lTimer.stop();	// Остановить таймер
			lTimer.removeEventListener(TimerEvent.TIMER,ShowHelpArrow);
			lTimer = null;
			// Деструктор предка
			super._delete();
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		public function GetArrowTarget():VnObject {
			// Только для реальной звездной системы
			if (!(Interplanety.Universe.CurrentStarSystem is StarSystemRealVn)) return null;
			// Если прогрузились корабли пользователя
			if (StarSystemRealVn(Interplanety.Universe.CurrentStarSystem).Ships.Length <= 0) return null;
			// Поиск цели для указания стрелочкой
			var CurrentQuest:QuestVn = Interplanety.Universe.QuestsManager.GetQuestById(1);
			// Если открыто окно с текстом или призами - не показывать стрелку
			if (Interplanety.Universe.QuestsManager.PrizeWindowVisible == true) return null;
			// По этапам квеста
			var UserShip:Ship = Ship(StarSystemRealVn(Interplanety.Universe.CurrentStarSystem).Ships.All[0]);
			switch(CurrentQuest.ActiveStage.Id) {
				case 3: {
					// Перелет Луна - Земля
					// Корабль на Луне
					if (UserShip.PlanetA.SpaceObjectId == 9 && UserShip.PlanetB.SpaceObjectId == 9) {
						// Луна
						var Moon:InteractiveSpaceObject = InteractiveSpaceObject(Interplanety.Universe.CurrentStarSystem.GetBySpaceObjectId(9));
						if (Moon.InteractiveWindow != null) {
							// Есть окно
							// Кнопка "Док"
							var DockButton:DButton = ISOCommonWindow(Moon.InteractiveWindow).DockButton;
							if (DockButton.Window != null) {
								// Открыто окно ShipsWindow
								// Кнопка "+" в ShipManager
								var PlusButton:AddRouteButton = ShipManager(ShipsWindow(DockButton.Window).Pages.Objects[0]).AddRouteBnt;
								if (PlusButton.Window != null) {
									// Открыто окно AddRouteWindow
									// Если планета назначения выбрана
									if (AddRouteWindow(PlusButton.Window).Pages.Selected != null) {
										return AddRouteWindow(PlusButton.Window).StartRouteBtn;
									}
									else {
										// Планета не выбрана - покаать на иконку Земли
										return AddRouteWindow(PlusButton.Window).Pages.Objects[0];
									}
								}
								else return PlusButton;
							}
							else return DockButton;
						}
						else return Moon;
					}
					// Если перелет уже идет и открыто окно дока на Луне - на кнопку закрытия
					if (UserShip.PlanetA.SpaceObjectId != UserShip.PlanetB.SpaceObjectId) {
						if (InteractiveSpaceObject(Interplanety.Universe.CurrentStarSystem.GetBySpaceObjectId(9)).InteractiveWindow != null && ISOCommonWindow(InteractiveSpaceObject(Interplanety.Universe.CurrentStarSystem.GetBySpaceObjectId(9)).InteractiveWindow).DockButton.Window != null) return ISOCommonWindow(InteractiveSpaceObject(Interplanety.Universe.CurrentStarSystem.GetBySpaceObjectId(9)).InteractiveWindow).DockButton.Window.closeButton;
					}
					break;
				}
				case 4: {
					// Купить 5т. Зерна
					// Если осталось открытым окно дока на Луне - указать на закрытие
					if (InteractiveSpaceObject(Interplanety.Universe.CurrentStarSystem.GetBySpaceObjectId(9)).InteractiveWindow !=null && ISOCommonWindow(InteractiveSpaceObject(Interplanety.Universe.CurrentStarSystem.GetBySpaceObjectId(9)).InteractiveWindow).DockButton.Window != null) return ISOCommonWindow(InteractiveSpaceObject(Interplanety.Universe.CurrentStarSystem.GetBySpaceObjectId(9)).InteractiveWindow).DockButton.Window.closeButton;
					// Только для Easy-уровня
					if (CurrentQuest.ActiveStage.Easy.Finished != true) {
						// Корабль на Земле
						if (UserShip.PlanetA.SpaceObjectId == 7 && UserShip.PlanetB.SpaceObjectId == 7) {
							// Земля
							var Earth:InteractiveSpaceObject = InteractiveSpaceObject(Interplanety.Universe.CurrentStarSystem.GetBySpaceObjectId(7));
							if (Earth.InteractiveWindow != null) {
								// Есть окно
								// Кнопка "Рынок"
								var IndButton:IButton = ISOCommonWindow(Earth.InteractiveWindow).IndustryButton;
								if (IndButton.Window != null) {
									// Открыто окно рынка
									// Проверка, что список грузов загрузился
									if (MarketWindowVn(IndButton.Window).ISOCargoList == null || MarketWindowVn(IndButton.Window).ISOCargoList.Length == 0) return null;
									else {
										// Ничего не выбрано или выбрано не зерно
//										if (MarketWindowVn(IndButton.Window).ISOCargoList.Selected != MarketWindowVn(IndButton.Window).ISOCargoList.Objects[0]) return MarketWindowVn(IndButton.Window).ISOCargoList.Objects[0];
										if (MarketWindowVn(IndButton.Window).ISOCargoList.Selected != MarketWindowVn(IndButton.Window).ISOCargoList.GetById(1)) return MarketWindowVn(IndButton.Window).ISOCargoList.GetById(1);
										else {
											// Выбрано зерно - на кнопку "купить"
											return MarketWindowVn(IndButton.Window).buyCargoButton;
										}
									}
								}
								else return IndButton;
							}
							else return Earth;
						}
					}
					break;
				}
				case 5: {
					// Перелет Земля - Луна
					// Если осталось открытым окно рынка на Земле - указать на закрытие
					if (InteractiveSpaceObject(Interplanety.Universe.CurrentStarSystem.GetBySpaceObjectId(7)).InteractiveWindow != null && ISOCommonWindow(InteractiveSpaceObject(Interplanety.Universe.CurrentStarSystem.GetBySpaceObjectId(7)).InteractiveWindow).IndustryButton.Window != null) return ISOCommonWindow(InteractiveSpaceObject(Interplanety.Universe.CurrentStarSystem.GetBySpaceObjectId(7)).InteractiveWindow).IndustryButton.Window.closeButton;
					// Корабль на Земле
					if (UserShip.PlanetA.SpaceObjectId == 7 && UserShip.PlanetB.SpaceObjectId == 7) {
						// Луна
						Earth = InteractiveSpaceObject(Interplanety.Universe.CurrentStarSystem.GetBySpaceObjectId(7));
						if (Earth.InteractiveWindow != null) {
							// Есть окно
							// Кнопка "Док"
							DockButton = ISOCommonWindow(Earth.InteractiveWindow).DockButton;
							if (DockButton.Window != null) {
								// Открыто окно ShipsWindow
								// Кнопка "+" в ShipManager
								PlusButton = ShipManager(ShipsWindow(DockButton.Window).Pages.Objects[0]).AddRouteBnt;
								if (PlusButton.Window != null) {
									// Открыто окно AddRouteWindow
									// Если планета назначения выбрана
									if (AddRouteWindow(PlusButton.Window).Pages.Selected != null) {
										return AddRouteWindow(PlusButton.Window).StartRouteBtn;
									}
									else {
										// Планета не выбрана - покаать на иконку Луны
										return AddRouteWindow(PlusButton.Window).Pages.Objects[0];
									}
								}
								else return PlusButton;
							}
							else return DockButton;
						}
						else return Earth;
					}
					// Если перелет уже идет и открыто окно дока на Земле - на кнопку закрытия
					if (UserShip.PlanetA.SpaceObjectId != UserShip.PlanetB.SpaceObjectId) {
						if (InteractiveSpaceObject(Interplanety.Universe.CurrentStarSystem.GetBySpaceObjectId(7)).InteractiveWindow != null && ISOCommonWindow(InteractiveSpaceObject(Interplanety.Universe.CurrentStarSystem.GetBySpaceObjectId(7)).InteractiveWindow).DockButton.Window != null) return ISOCommonWindow(InteractiveSpaceObject(Interplanety.Universe.CurrentStarSystem.GetBySpaceObjectId(7)).InteractiveWindow).DockButton.Window.closeButton;
					}
					break;
				}
				case 6: {
					// Продать 5т. Зерна
					// Только для Easy-уровня
					if(CurrentQuest.ActiveStage.Easy.Finished != true) {
						// Если осталось открытым окно дока на Земле - указать на закрытие
						if (InteractiveSpaceObject(Interplanety.Universe.CurrentStarSystem.GetBySpaceObjectId(7)).InteractiveWindow != null && ISOCommonWindow(InteractiveSpaceObject(Interplanety.Universe.CurrentStarSystem.GetBySpaceObjectId(7)).InteractiveWindow).DockButton.Window != null) return ISOCommonWindow(InteractiveSpaceObject(Interplanety.Universe.CurrentStarSystem.GetBySpaceObjectId(7)).InteractiveWindow).DockButton.Window.closeButton;
						// Корабль на Луне
						if (UserShip.PlanetA.SpaceObjectId == 9 && UserShip.PlanetB.SpaceObjectId == 9) {
							// Луна
							Moon = InteractiveSpaceObject(Interplanety.Universe.CurrentStarSystem.GetBySpaceObjectId(9));
							if (Moon.InteractiveWindow != null) {
								// Есть окно
								// Кнопка "Производства"
								IndButton = ISOCommonWindow(Moon.InteractiveWindow).IndustryButton;
								if (IndButton.Window != null) {
									// Открыто окно рынка
									// Проверка, что список грузов на корабле загрузился
									if (MarketWindowVn(IndButton.Window).shipCargoList == null || MarketWindowVn(IndButton.Window).shipCargoList.Length == 0) return null;
									else {
										// Ничего не выбрано или выбрано не зерно
										if (MarketWindowVn(IndButton.Window).shipCargoList.Selected == null || CargoVn(ShipCargoIndicator(MarketWindowVn(IndButton.Window).shipCargoList.Selected).Owner).industryId != 1) return MarketWindowVn(IndButton.Window).shipCargoList.GetById(1);
										else {
											// Выбрано зерно - на кнопку "купить"
											return MarketWindowVn(IndButton.Window).sellCargoButton;
										}
									}
								}
								else return IndButton;
							}
							else return Moon;
						}
					}
					break;
				}
			}
			return null;
		}
//-----------------------------------------------------------------------------------------------------
		public function ShowHelpArrow(e:TimerEvent):void {
			// Скрытие/показ стрелки
			var Target:VnObject = GetArrowTarget();
			if(Target!=null) {
				if (lArrow.parent == null)	{
					Interplanety.VnSceneI.addChild(lArrow);	// Цеплять к VnInterface, чтобы стрелка была поверх всего
//					Interplanety.Universe.addChild(lArrow);
					var ArrowPos:Vector2 = new Vector2();
					Vector2.Vec2Subtract(lArrow.GetLocalPosition(), VnObjectT(Target).GetPositionLT(), ArrowPos);
					lArrow.MoveInto(ArrowPos);
				}
				else {
					Interplanety.VnSceneI.removeChild(lArrow);
				}
			}
			else {
				if (lArrow.parent != null) Interplanety.VnSceneI.removeChild(lArrow);
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