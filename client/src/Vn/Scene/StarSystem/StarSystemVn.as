package Vn.Scene.StarSystem {
	// "Звездная система"
//-----------------------------------------------------------------------------------------------------
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.system.System;
	import flash.utils.getDefinitionByName;
	import Vn.Actions.Action;
	import Vn.Actions.ActionSCX;
	import Vn.Actions.ActionSCY;
	import Vn.Common.SC;
	import Vn.Common.DynamicObjectsVn;
	import Vn.Math.Vector2;
	import Vn.Objects.VnObject;
	import Vn.Objects.VnObjectD;
	import Vn.Objects.VnObjectL;
	import Vn.Objects.VnObjectR;
	import Vn.Objects.VnObjectSA;
	import Vn.Objects.VnObjectT;
	import Vn.Objects.VnObjectU;
//	import Vn.SpaceObjects.SpaceObjectManagerVn;
//	import Vn.SpaceObjects.InteractiveSpaceObjectR;
	import Vn.SpaceObjects.InteractiveSpaceObjectRO;
	import Vn.SpaceObjects.InteractiveSpaceObjectVO;
	import Vn.Ships.Routes.ShipRoute;
	import Vn.SpaceObjects.InteractiveSpaceObjectRC;
	import Vn.SpaceObjects.Orbit.OrbitImage;
	import Vn.SpaceObjects.Orbit.OrbitR;
	import Vn.SpaceObjects.SpaceObject;
	import Vn.System.Console;
	import Vn.System.PHPLoader;
	import Vn.User.User;
	import Vn.Interplanety;
//-----------------------------------------------------------------------------------------------------
	public class StarSystemVn extends VnObjectR {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		protected var ObjectList:Array;			// Массив всех объектов
		protected var InfoLoader:PHPLoader;		// Загрузчик
		protected var l_LoadScript:String;		// Скрипт для загрузки
		protected var ClickedFlag:Boolean;		// Флаг для предобработки события "клик мышки" true - второй проход, обрабатывать в OnClick не нужно
		private var lMouseOverObject:EventDispatcher;	// Текущий объект, на который навели курсор мышки
		protected var OldX:Number;				// Предыдущее положение курсора мышки (чтобы на создавать новые события скролла если курсор из области скролла не выходил)
		protected var OldY:Number;
		private var lPressedKeysArray:Array;	// Массив с нажатыми клавиатурными клавишами (чтобы отлавливать только первое нажатие)
		// Константы событий
		public static const LOADED:String = "EvStarSystemLoaded";	// Данные загружены
		public static const FAIL:String = "EvStarSystemLoadedFail";	// Данные НЕ загружены
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function StarSystemVn() {
			// Конструктор родителя
			super();
			// Конструктор
			ObjectList = new Array();
			InfoLoader = new PHPLoader();		// Загрузчик
			lPressedKeysArray = new Array();
			// Основные переменные
			ClickedFlag = false;
			// Задаем размеры
			SetLocalPosition(Vn.Interplanety.Width/2.0,Vn.Interplanety.Height/2.0);
			// По-умолчанию курсор в центре
			OldX = Vn.Interplanety.Width/2.0;
			OldY = Vn.Interplanety.Height/2.0;
			// Событие показа/скрытия орбит
			Vn.Interplanety.VnUser.addEventListener(User.SHOW_ORBITS_CHANGE,OnShowOrbitsChange);
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		override public function _delete():void {
			// Деструктор
			// Снять слушатель настроек
			Vn.Interplanety.VnUser.removeEventListener(User.SHOW_ORBITS_CHANGE,OnShowOrbitsChange);
			// Удалить объекты по списку
			ObjectList = null;
			// Обнулить счетчик FPS
			if(FPS!=null) FPS = null;
			// Удалить объекты
			InfoLoader._delete();
			InfoLoader = null;
			// Очистить массив с нажатыми клавиатурными клавишами
			lPressedKeysArray.splice(0);
			// Деструктор родителя
			super._delete();
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		public function Clear():void {
			// Очистка системы
			ClickedFlag = false;
			OldX = Vn.Interplanety.Width / 2.0;
			OldY = Vn.Interplanety.Height / 2.0;
		}
//-----------------------------------------------------------------------------------------------------
		public function Load(NewStarSystemId:uint):void {
			// Загрузка звездной системы
			Id = NewStarSystemId;
			InfoLoader.addEventListener(Event.COMPLETE,OnComplete);
			InfoLoader.addEventListener(IOErrorEvent.IO_ERROR,OnIoError);
			InfoLoader.AddVariable("StarSystemId",String(Id));
			InfoLoader.Load(l_LoadScript);
		}
//-----------------------------------------------------------------------------------------------------
		public function Resize():void {
			// Изменение размера
			SetLocalPosition(Vn.Interplanety.Width / 2.0, Vn.Interplanety.Height / 2.0);
		}
//-----------------------------------------------------------------------------------------------------
		protected function CreateFromXML(Data:XML):void {
			// Создание сцены из XML
			var AddChildLater:Array = new Array();	// Временный массив для объектов для которых нельзя выполнить addChild т.к. его parent  еще не создан
			for each (var Node:XML in Data.*) {
				if(Node.nodeKind()=="element") {
					// Создать объект по текстовому названию класса
					var ClassReference:Class = getDefinitionByName(DynamicObjectsVn.FullName(Node.name())) as Class;
					var Instance:Object = new ClassReference();
					// Добавить полученный объект в сцену
					Add(VnObject(Instance));
					// Заполнить его данными
					if(FPS!=null) VnObjectT(Instance).FPS = FPS;
					VnObject(Instance).Id = Node.child("id");	// Id из sector_main
					if (Instance is SpaceObject) SpaceObject(Instance).SpaceObjectId = Node.attribute("id");	// Реальный Id из таблицы объекта (spaceobject_id)
					if(Node.child("fly_enable").length()>0&&Node.child("fly_enable")!="F") FlyEnableObject(InteractiveSpaceObjectRC(Instance));
					// Загрузка данных в объект
					VnObjectL(Instance).LoadFromXML(Node);
					if(Node.child("sub_id").length()>0&&Node.child("sub_id")!="0") {
						// Подчиненные объекты
						// Считаем sub_id = Trace для SpaceObject
						var Parent:VnObject = GetById(uint(Node.child("sub_id")));
						if(Parent==null) AddChildLater.push([VnObject(Instance),uint(Node.child("sub_id")),uint(Node.child("s_point_z"))]);
						else {
							Parent.addChild(VnObject(Instance));
//							if (Parent is InteractiveSpaceObjectRO) SpaceObject(Instance).Trace = Orbit(Parent);
							SpaceObject(Instance).Trace = SpaceObject(Parent);
						}
					}
					else {
						// Объекты без подчинения
						addChild(VnObject(Instance));
						VnObjectT(Instance).MoveIntoParent(Number(Node.child("s_point_x")),Number(Node.child("s_point_y")),true);
					}
				}
			}
			// Для объектов для которых не был выполнен addChild - выполнить
			for(var i:uint=0;i<AddChildLater.length;) {
				GetById(AddChildLater[i][1]).addChild(AddChildLater[i][0]);
				if(AddChildLater[i][0] is SpaceObject) SpaceObject(AddChildLater[i][0]).Trace = SpaceObject(GetById(AddChildLater[i][1]));
				AddChildLater[i].splice(0,3);
				AddChildLater.splice(i,1);
			}
			// Обновить положение объектов (иначе при первом показе некоторые еще не успеют обновить положение)
			Update();
		}
//-----------------------------------------------------------------------------------------------------
		protected function FlyEnableObject(SObj:InteractiveSpaceObjectRC):void {
			// Указание на то, что SObj доступен для полетов
			// Переопределяется в StarSystemReal
		}
//-----------------------------------------------------------------------------------------------------
		public function Add(Obj:VnObject):void {
			// Добавление объекта
			// Добавить в общий массив
			var Add:Boolean = true;
			for(var i:uint=0;i<ObjectList.length;i++) {
				if(ObjectList[i]==Obj) {
					Add = false;
					break;
				}
			}
			if(Add==true) ObjectList.push(Obj);
		}
//-----------------------------------------------------------------------------------------------------
		public function GetById(SearchId:uint):VnObject {
			// Получение указателя на объект по его Id
			for (var i:uint = 0; i < ObjectList.length; i++) {
				if(ObjectList[i].Id==SearchId) {
					return ObjectList[i];
					break;
				}
			}
			return null;
		}
//-----------------------------------------------------------------------------------------------------
		public function GetBySpaceObjectId(SearchId:uint):VnObject {
			// Получение указателя на объект по его SpaceObjectId
			for(var i:uint=0;i<ObjectList.length;i++) {
				if(ObjectList[i].SpaceObjectId==SearchId) {
					return ObjectList[i];
					break;
				}
			}
			return null;
		}
//-----------------------------------------------------------------------------------------------------
		public function Remove(Obj:VnObject):void {
			// Удаление объекта без уничтожения
			// Удалить всех чайлдов объекта
			for (var i:uint = 0; i < Obj.numChildren; i++ ) {
				var Child:DisplayObject = Obj.getChildAt(i);
				// Только для космических объектов (иначе под удаление попадают битмапы и т.п.)
				if(Child is SpaceObject) Remove(VnObject(Child));
			}
			// Удалить сам объект
			for (i = 0; i < ObjectList.length; i++) {
				if(ObjectList[i]==Obj) {
					// Удалить из массива
					ObjectList[i].parent.removeChild(ObjectList[i]);
					ObjectList.splice(i,1);
					break;
				}
			}
		}
//-----------------------------------------------------------------------------------------------------
		protected function Delete(Obj:VnObject):void {
			// Удаление объекта с его уничтожением
			// Удалить всех чайлдов объекта
			for (var i:uint = 0; i < Obj.numChildren; i++ ) {
				var Child:DisplayObject = Obj.getChildAt(i);
				// Только для космических объектов (иначе под удаление попадают битмапы и т.п.)
				if(Child is SpaceObject) Delete(VnObject(Child));
			}
			// Уничтожить объект
			for (i = 0; i < ObjectList.length; i++) {
				if(ObjectList[i]==Obj) {
					ObjectList[i].parent.removeChild(ObjectList[i]);
					ObjectList[i]._delete();
					// Удалить из массива
					ObjectList.splice(i,1);
					break;
				}
			}
		}
//-----------------------------------------------------------------------------------------------------
		public function Update():void {
			// Обновление сцены
			RunAction();
			// Обновить все объекты сцены
			for(var i:uint=0;i<ObjectList.length;i++) {
				if(ObjectList[i]!=null) {
					// Обновление анимации
					if(ObjectList[i] is VnObjectSA) VnObjectSA(ObjectList[i]).PlayAnimation();
					// Обновление состояния объектов
					if(ObjectList[i] is VnObjectU) VnObjectU(ObjectList[i]).Update();
				}
			}
		}
//-----------------------------------------------------------------------------------------------------
		public function GetMaxObjectsZIndex():uint {
			// Возвращает максимальный индекс глубины объекта сцены, чтобы следующие объекты ставить выше него
			// Считаем, что нужно ставить выше Звезды и Станций (все SpaceObjects)
			var Index:uint = 0;
			for(var i:uint = 0;i<numChildren;i++) {
				if(getChildAt(i) is SpaceObject && Index <= getChildIndex(getChildAt(i)))
				Index = getChildIndex(getChildAt(i))
			}
			return Index;
		}
//-----------------------------------------------------------------------------------------------------
		protected function GetObjectUnderPoint(vX:Number, vY:Number):* {
			// Возвращает верхний объект системы по указанным координатам с учетом прозрачности
			// Координаты задаются в глобальной системе
			// Получить массив объектов под точкой (parent чтобы бралось все с Vn что не принадлежит сцене, например окна и кнопки интерфейса)
			var ObjArr:Array = stage.getObjectsUnderPoint(new Point(vX,vY));
//			for(var m1:uint=0;m1<ObjArr.length;m1++) {
//				trace(ObjArr[m1] + " - " + ObjArr[m1].parent);
//			}
//			trace("++++++++++++++++++++");
			// Очистка массива от объектов кторые не нужно проверять на hitTest
			// Если в объектах VnText (TextField) используется htmlText - в них появляются какие-то Sprite и Bitmap которые также учитываются в getObjectsUnderPoint
			// Консоль также исключаем из проверки
			// Также исключить из проверки объекты, которые в данный момент перетаскиваются мышкой (планеты и орбиты приходится контролировать отдельно т.к. планета = битмап + объект, а в орбите рисуется приямо по объекту
			for(var m:uint=0;m<ObjArr.length;m++) {
//				if (!(ObjArr[m].parent is DisplayObjectContainer) || ObjArr[m] is Console || ((ObjArr[m].parent is VnObjectR) && ObjArr[m].parent.Dragging == true) || (ObjArr[m] is OrbitImage && ObjArr[m].Dragging == true)) {
				if (!(ObjArr[m].parent is DisplayObjectContainer) || ObjArr[m] is Console || ((ObjArr[m].parent is VnObjectR) && ObjArr[m].parent.DragCont.Dragging == true)) {
					ObjArr.splice(m,1);
					m--;	// т.к. splice сдвигает строчки на место удаленной
				}
			}
//			for(var m2:uint=0;m2<ObjArr.length;m2++) {
//				trace(ObjArr[m2]+" - "+ObjArr[m2].parent);
//			}
//			trace("--------------------");
			// Отсортировать по глубине по возрастанию
			ObjArr.sort(ZSort);
			// Проверить правильность выбора т.к клик по картинке != клику по содержащему ее объекту
			for(var j:uint=0;j<ObjArr.length;j++) {
				if (ObjArr[j] is Bitmap) ObjArr[j] = ObjArr[j].parent; // Т.к. выбор в массив осуществляется до уровня Bitmap - привести найденные Bitmap к конкретным объектам
				if (ObjArr[j].parent is SpaceObject) ObjArr[j] = ObjArr[j].parent;	// Если это картинка в SpaceObject - привести к объекту
				if (ObjArr[j] is OrbitImage) ObjArr[j] = ObjArr[j].parent.parent;	// Для орбит - привести к орбите (орбита.контейнер.изображение)

			}
//			for(var m1:uint=0;m1<ObjArr.length;m1++) {
//				trace(ObjArr[m1]);
//			}
//			trace("====================");
			// Ищем верхний, удовлетворяющий hitTest по каждому конкретному объекту
			for(var i:uint=0;i<ObjArr.length;i++) {
				var Rez:Boolean = false;
				Rez = ObjArr[i].hitTestPoint(vX,vY,true);
//				trace(ObjArr[i].toString()+" - "+Rez.toString());
				if (Rez == true) {
//					trace("Rez: "+ObjArr[i].toString());
					return ObjArr[i];
					break;
				}
			}
			return null;	// null - ничего под точкой нет
		}
//-----------------------------------------------------------------------------------------------------
		private static function ZSort(A:Object,B:Object):Number {
			// Сравнение двух объектов по глубине
			if(A.stage==null&&B.stage==null) return 0;	// Оба не добавлены в список - равны
			if(A.stage==null) return -1;				// Добавленный в список - выше недобавленного
			if(B.stage==null) return -1;
			// Оба в списке - нормальный вариант
			// Дойти до общего парента и сравнить индексы
			var P1:Object = A;
			var P2:Object = B;
			while(P1.parent!=null) {
				while(P2.parent!=null) {
					if(P1.parent==P2.parent) {
						// Отработать
						if(P1.parent.getChildIndex(P1)>P1.parent.getChildIndex(P2)) {
							return -1;	// A выше B
						}
						else {
							if(P1.parent.getChildIndex(P1)==P1.parent.getChildIndex(P2)) {
								// Индексы равны - если А чайлд B или наоборот
								if(A.hasOwnProperty("contains")&&A.contains(B)) return 1;	// hasOwnProperty нужен т.к. могут проверяться объекты типа VnText не могущие иметь чайлдов
								else return -1;
							}
							if(P1.parent.getChildIndex(P1)<P1.parent.getChildIndex(P2)) {
								return 1;	// A ниже B
							}
						}
					}
					P2 = P2.parent;
				}
				P1 = P1.parent;
				P2 = B;
			}
			return 0;
		}
//-----------------------------------------------------------------------------------------------------
		public function CoordinatesInSystemByScreen(vScreenCoord:Vector2):Vector2 {
			// Возвращает координаты точки в системе по экранным координатам
			var StarSystemPos:Vector2 = GetPosition();
			var StarSystem00Pos:Vector2 = new Vector2(StarSystemPos.X-Width05,StarSystemPos.Y-Height05);
			var NewPos:Vector2 = new Vector2();
			Vector2.Vec2Subtract(StarSystem00Pos, vScreenCoord, NewPos);
			return NewPos;
		}
//-----------------------------------------------------------------------------------------------------
// Обработка событий
//-----------------------------------------------------------------------------------------------------
		protected function OnComplete(e:Event):void {
			// Данные по сектору загружены
			InfoLoader.removeEventListener(Event.COMPLETE,OnComplete);
			InfoLoader.removeEventListener(IOErrorEvent.IO_ERROR,OnIoError);
			// Создать сектор по полученным данным
			try {
				var SectorData:XML = new XML(e.target.data);
			}
			catch (e1:Error) {
				trace(e.target.data);
			}
			CreateFromXML(SectorData);
			System.disposeXML(SectorData);
		}
//-----------------------------------------------------------------------------------------------------
		protected function OnIoError(e:IOErrorEvent):void {
			// Ошибка получения данных по сектору
			InfoLoader.removeEventListener(Event.COMPLETE,OnComplete);
			InfoLoader.removeEventListener(IOErrorEvent.IO_ERROR,OnIoError);
			// Сцена на загрузилась
			_delete();
			dispatchEvent(new Event(StarSystemVn.FAIL));
		}
//-----------------------------------------------------------------------------------------------------
		protected function OnShowOrbitsChange(e:Event):void {
			// Изменение отображения орбит
			for (var i:uint = 0; i < ObjectList.length; i++) {
				// Перерисовка орбит и маршрутов
				if (ObjectList[i] is InteractiveSpaceObjectRO || ObjectList[i] is InteractiveSpaceObjectVO || ObjectList[i] is ShipRoute) VnObjectD(ObjectList[i]).Redraw();
			}
		}
//-----------------------------------------------------------------------------------------------------
		override protected function OnAddToStage(e:Event):void {
			// При добавлении в список отображения
			super.OnAddToStage(e);
			// Перехватывать OnClick для правильного выбора объектов с учетом прозрачности
			stage.addEventListener(MouseEvent.CLICK,OnClick,true);
			stage.addEventListener(MouseEvent.MOUSE_MOVE,OnMouseMove);
			stage.addEventListener(Event.MOUSE_LEAVE,OnMouseLeave);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, OnMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, OnMouseUp);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, OnKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, OnKeyUp);
		}
//-----------------------------------------------------------------------------------------------------
		override protected function OnRemoveFromStage(e:Event):void {
			// При удалении из списка отображения
			super.OnRemoveFromStage(e);
			// Снять отлов OnClick
			stage.removeEventListener(KeyboardEvent.KEY_UP, OnKeyUp);
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, OnKeyDown);
			stage.removeEventListener(MouseEvent.MOUSE_UP, OnMouseUp);
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, OnMouseDown);
			stage.removeEventListener(Event.MOUSE_LEAVE,OnMouseLeave);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE,OnMouseMove);
			stage.removeEventListener(MouseEvent.CLICK,OnClick,true);
		}
//-----------------------------------------------------------------------------------------------------
		protected function OnClick(e:MouseEvent):void {
			// Клик мышки
			if (stage == null) return;	// OnClick отрабатывает раньше OnRemoveFromStage
			// Если был действительный drag - не обрабатываем click
			if (DragCont.Dragged == true) {
				DragCont.Click(e);
				ClickedFlag = false;
				e.stopImmediatePropagation();
				return;
			}
			// Обработать click
			if(ClickedFlag==false) {
				// Первый проход - обработка (проверка по какому объекту был клик с учетом прозрачности)
				var ClickedObject:EventDispatcher = EventDispatcher(GetObjectUnderPoint(e.stageX, e.stageY));
				if (ClickedObject != null && e.target != ClickedObject) {
					ClickedFlag = true;
					e.stopImmediatePropagation();
					ClickedObject.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
				}
			}
			else {
				// Второй проход - клик уже по правильному объекту с учетом прозрачности вышестоящих
				// Ничего не делать, только сбросить флаг
				ClickedFlag = false;
			}
//			if (DragCont.Dragged == true) DragCont.Click(e);	// Для контроля за drag'ом
//			trace(Vn.Vn.VnUser.Level);
//			trace(e.target.GetPosition());
//			trace(e.target.parent.GetPosition());
//			Vn.Vn.Cons.Add(GetPosition().toString());
//			Vn.Vn.Cons.Add(e.target.GlobalPosition.toString());
//			if (e.target is SpaceObject) Vn.Vn.Cons.Add(SpaceObject(e.target).CountRealPos().toString());
//			trace(e.target.Image.Info);
//			trace(e.target.Id);

		}
//-----------------------------------------------------------------------------------------------------
		protected function OnMouseMove(e:MouseEvent):void {
			// Движение курсора
			// Отправка события MOUSE_OVER/MOUSE_OUT не происходит, когда курсор наводится на объект, находящийся под другим, но видимый за счет прозрачности верхнего - нужно обрабатывать
			var OverObject:EventDispatcher = EventDispatcher(GetObjectUnderPoint(e.stageX, e.stageY));
			// Проверить на уход курсора с объекта
			// Объект тот же, кому идет событие (верхний) он получит MOUSE_OUT стандартным путем
			if (lMouseOverObject == e.target) lMouseOverObject = null;
			// Объект на который наведен курсор теперь другой или null - значит был уход с текущего - отправить текущему MOUSE_OUT
			if (lMouseOverObject != OverObject && lMouseOverObject != null) {
//trace("out "+lMouseOverObject.toString());
				lMouseOverObject.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_OUT));
				lMouseOverObject = null;
			}
			// Курсор наведен на новй объект. Если он равен e.target (верхний) он получит событие MOUSE_OVER стандартным путем. Иначе - отправить MOUSE_OVER
			if (OverObject != null && e.target != OverObject) {
				OverObject.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_OVER));
				lMouseOverObject = OverObject;
//trace("over "+lMouseOverObject.toString());
			}
			// Обработать скроллинг
			if(DragCont.Dragging==false) {
				var HBorder:Number = Vn.Interplanety.Width-SC.ScrollBorder;
				var VBorder:Number = Vn.Interplanety.Height-SC.ScrollBorder;
				// Скролл по оси X
				if(e.stageX>=HBorder&&OldX<HBorder) {
					// Добавить скролл влево
					var NewAction:Action = new ActionSCX(false,false);
					AddAction(NewAction);
				}
				if(e.stageX<=SC.ScrollBorder&&OldX>SC.ScrollBorder) {
					// Добавить скролл вправо
					NewAction = new ActionSCX(true,false);
					AddAction(NewAction);
				}
				// Скролл по оси Y
				if(e.stageY>=VBorder&&OldY<VBorder) {
					// Добавить скролл вверх
					NewAction = new ActionSCY(false,false);
					AddAction(NewAction);
				}
				if(e.stageY<=SC.ScrollBorder&&OldY>SC.ScrollBorder) {
					// Добавить скролл вниз
					NewAction = new ActionSCY(true,false);
					AddAction(NewAction);
				}
				// Конец скролла
				if (e.stageX > SC.ScrollBorder && e.stageX < HBorder && ((OldX <= SC.ScrollBorder || OldX >= HBorder) || (lPressedKeysArray[37] == null || lPressedKeysArray[37] == undefined || lPressedKeysArray[37] == false ) && (lPressedKeysArray[39] == null || lPressedKeysArray[39] == undefined || lPressedKeysArray[39] == false))) {
					// Убрать скролл вправо-влево
					RemoveAction("ACT_SCX");
				}
				if (e.stageY > SC.ScrollBorder && e.stageY < VBorder && ((OldY <= SC.ScrollBorder || OldY >= VBorder) || (lPressedKeysArray[38] == null || lPressedKeysArray[38] == undefined || lPressedKeysArray[38] == false ) && (lPressedKeysArray[40] == null || lPressedKeysArray[40] == undefined || lPressedKeysArray[40] == false))) {
					// Убрать скролл вверх-вниз
					RemoveAction("ACT_SCY");
				}
			}
			// После всех проверок обновить OldX и OldY
			OldX = e.stageX;
			OldY = e.stageY;
		}
//-----------------------------------------------------------------------------------------------------
		private function OnKeyDown(e:KeyboardEvent):void {
			// Нажатие клавиши на клавиатуре
			if (lPressedKeysArray[e.keyCode] == null || lPressedKeysArray[e.keyCode] == undefined || lPressedKeysArray[e.keyCode] == false) {
				lPressedKeysArray[e.keyCode] = true;
				var NewAction:Action;
				// Добавить скролл влево
				if (e.keyCode == 37) {
					RemoveAction("ACT_SCX");
					NewAction = new ActionSCX(true,false);
					AddAction(NewAction);
				}
				if(e.keyCode == 39) {
					// Добавить скролл вправо
					RemoveAction("ACT_SCX");
					NewAction = new ActionSCX(false,false);
					AddAction(NewAction);
				}
				if(e.keyCode == 38) {
					// Добавить скролл вверх
					RemoveAction("ACT_SCY");
					NewAction = new ActionSCY(true,false);
					AddAction(NewAction);
				}
				if(e.keyCode == 40) {
					// Добавить скролл вниз
					RemoveAction("ACT_SCY");
					NewAction = new ActionSCY(false,false);
					AddAction(NewAction);
				}
			}
		}
//-----------------------------------------------------------------------------------------------------
		private function OnKeyUp(e:KeyboardEvent):void {
			// Отпускание клавиши на клавиатуре
			if (lPressedKeysArray[e.keyCode] == true) {
				lPressedKeysArray[e.keyCode] = false;
				// Убрать скролл вправо-влево
				if (e.keyCode == 37 || e.keyCode == 39) {
					RemoveAction("ACT_SCX");
				}
				if (e.keyCode == 38 || e.keyCode == 40) {
					RemoveAction("ACT_SCY");
				}
			}
		}
//-----------------------------------------------------------------------------------------------------
		protected function OnMouseLeave(e:Event):void {
			// Выход курсора за пределы флешки
			// Убрать скролл
			RemoveAction("ACT_SCX")
			RemoveAction("ACT_SCY")
			// Сбросить старое положение курсора в центр, чтобы скролл возобновлялся после возвращения
			OldX = Vn.Interplanety.Width/2.0;
			OldY = Vn.Interplanety.Height / 2.0;
			// Убрать drag
			if (DragCont.Dragging == true) {
				stopDrag();
				DragCont.MouseUp(null);
				DragCont.Click(null);
			}
		}
//-----------------------------------------------------------------------------------------------------
		protected function OnMouseDown(e:MouseEvent):void {
			// Зажатие кнопки мышки
			DragCont.MouseDown(e);	// Для контроля за drag'ом
			// Разрешается перетаскивание только за пустое место (stage) или за SpaceObject (планеты и орбиты) (чтобы можно было перетаскивать что-то в окнах не таская систему)
			if (e.target == stage || e.target.parent is SpaceObject) startDrag();
		}
//-----------------------------------------------------------------------------------------------------
		private function OnMouseUp(e:MouseEvent):void {
			// Отжатие кнопки мышки
			if(DragCont.Dragging==true) {
				stopDrag();
			}
			DragCont.MouseUp(e);	// Для контроля за drag'ом
			if (e.target == stage) DragCont.Click(e);	// т.к. click не отрабатывается при перетаскивании за пустое место
		}
//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------
		public function get OverSpaceObject():SpaceObject {
			// SpaceObject, на котором есть текущее наведение мышкой
			// Проверка нужна т.к. lMouseOverObject может быть не только SpaceObject, но и например VnWindow
			if (lMouseOverObject is SpaceObject) return SpaceObject(lMouseOverObject);
			else return null;
		}
//-----------------------------------------------------------------------------------------------------
	}
}