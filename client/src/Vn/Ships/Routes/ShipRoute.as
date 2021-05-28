package Vn.Ships.Routes {
	// Маршрут корабля (визуальное сопровождение)
	// Получаем в виде кривой Безье по трем опорным точкам. 1 и 3 точки - планеты старта и назначения
	// вторая точка - на середине между этими планетами +- 20*N pix если есть N маршрутов между этими
	// планетами
//-----------------------------------------------------------------------------------------------------
	import flash.events.Event;
	import flash.events.MouseEvent;
	import Vn.Interplanety;
	import Vn.Math.Vector2;
	import Vn.Objects.VnObjectU;
	import Vn.Objects.VnObjectS;
	import Vn.Scene.StarSystem.StarSystemRealVn;
	import Vn.Ships.Ship;
//-----------------------------------------------------------------------------------------------------
	public class ShipRoute extends VnObjectU {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		private var P11:Vector2;	// 1 опорная точка
		private var P22:Vector2;	// 2 опорная точка
		private var P33:Vector2;	// 3 опорная точка
		private var ParentShip:Ship;	// Указатель на корабль для которого создается маршрут
		private var Pict:VnObjectS;	// Изображение корабля
		private var IsSelected:Boolean;	// true - маршрут выбран
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function ShipRoute(PShip:Ship) {
			// Конструктор предка
			super();
			// Корабль
			ParentShip = PShip;
			// Инициализация точек
			P11 = new Vector2(0,0);
			P22 = new Vector2(0,0);
			P33 = new Vector2(0,0);
			// Присвоить маршруту Id, чтобы иметь постоянное отличие от др. маршрутов между текущими планетами (для вычисления 2 опорной точки)
			// Находим наименьший свободный и занимаем его
			var Ships:Array = StarSystemRealVn(Vn.Interplanety.Universe.CurrentStarSystem).Ships.All;	// Все корабли
			var RoutesArray:Array = new Array(1);
			for (var i:uint = 0; i < Ships.length; i++) {
				if(Ships[i].VRoute!=null&&(Ships[i].PlanetA==ParentShip.PlanetA&&Ships[i].PlanetB==ParentShip.PlanetB||Ships[i].PlanetB==ParentShip.PlanetA&&Ships[i].PlanetA==ParentShip.PlanetB)) {
					RoutesArray[Ships[i].VRoute.Id]=true;
				}
			}
			var RId:int = RoutesArray.indexOf(undefined);
			if(RId!=-1) Id = RId;
			else Id = RoutesArray.length;
			// Расчитать точки для корабля
			var Pos:Vector2 = ParentShip.PlanetA.GetPosition();
			SetP1(Pos.x,Pos.y);
			Pos = ParentShip.PlanetB.GetPosition();
			SetP3(Pos.x,Pos.y);
			// Изображение
			Pict = new VnObjectS();
			Pict.ReLoadById(ParentShip.Img28x28);
			addChild(Pict);
			UpdatePict();
			// Выбор
			Selected = false;
			// Регистрация событий
			Pict.addEventListener(MouseEvent.CLICK,OnPictClick);
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		override public function _delete():void {
			Clear();
			// Разрегистрация событий
			Pict.removeEventListener(MouseEvent.CLICK,OnPictClick);
			// Объекты
			ParentShip = null;
			// Опорные точки
			P11._delete();
			P11 = null;
			P22._delete();
			P22 = null;
			P33._delete();
			P33 = null;
			// Изображение
			removeChild(Pict);
			Pict._delete();
			Pict = null;
			// Деструктор предка
			super._delete();
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		public function SetP1(X:Number,Y:Number):void {
			P11.x = X;
			P11.y = Y;
//			// Т.к. рисование идет относительно точки регистрации родительского контейнера
//			if(stage!=null) {
//				P11.x += VnObjectT(parent).Width05 - VnObjectT(parent).GetPosition().X;
//				P11.y += VnObjectT(parent).Height05 - VnObjectT(parent).GetPosition().Y;
//			}
			CountP2();	// Пересчитать опорную точку 2
		}
//-----------------------------------------------------------------------------------------------------
		public function CountP2():void {
			// Получение опорной точки для построения кривой маршрута
//trace(P1.toString());
//trace(P3.toString());
			var Ships:Array = StarSystemRealVn(Vn.Interplanety.Universe.CurrentStarSystem).Ships.All;	// Все корабли
			// Получить P2 при 0 других маршрутов между текущими планетами (на середине прямой)
			var P20:Vector2 = new Vector2();
			Vector2.Vec2Subtract(P3,P1,P20);
//trace(P20.toString());
			var Offset:Vector2 = new Vector2();
			Vector2.Vec2Normal(P20,Offset);	// Перпендикуляр к P20 - смещение
//trace(Offset.toString());
			P20.Vec2Mult(0.5);
//trace(P20.toString());
			Vector2.Vec2Add(P3,P20,P20);
//trace(P20.toString());
			// По Id смещаем P20 для учета кол-ва других маршрутов между этими планетами
			if(Id!=0) {
				if(Id%2==0) {
					Offset.Vec2Mult(60+60*(Id-2)/2);
//trace(Offset.toString());
				}
				else {
					Offset.Vec2Mult(60+60*(Id-1)/2);
//trace(Offset.toString());
					Offset.Vec2Revers();
//trace(Offset.toString());
				}
				Vector2.Vec2Add(P20,Offset,P20);
//trace(P20.toString());
			}
			// Установить P2
			SetP2(P20.x,P20.y);
//trace(P2.toString());
//trace("---");
		}
//-----------------------------------------------------------------------------------------------------
		public function SetP2(X:Number,Y:Number):void {
			P22.x = X;
			P22.y = Y;
			Redraw();	// Перерисовать
		}
//-----------------------------------------------------------------------------------------------------
		public function SetP3(X:Number,Y:Number):void {
			P33.x = X;
			P33.y = Y;
			CountP2();	// Пересчитать опорную точку 2
		}
//-----------------------------------------------------------------------------------------------------
		public function GetPx(Proc:uint):Vector2 {
			// Найти точку на кривой Безье в зависимости от процентов Proc
			var Otn:Number = Proc/100;	// Проценты (0-100) - в отношение (0-1)
			var V1:Vector2 = P1.Vec2Clone();
			V1.Vec2Mult(Math.pow(1-Otn,2));
			var V2:Vector2 = P2.Vec2Clone();
			V2.Vec2Mult(2*Otn*(1-Otn));
			var V3:Vector2 = P3.Vec2Clone();
			V3.Vec2Mult(Math.pow(Otn,2));
			var Vx:Vector2 = new Vector2();
			Vector2.Vec2Add(V1,V2,Vx);
			Vector2.Vec2Add(Vx,V3,Vx);
			return Vx;
		}
//-----------------------------------------------------------------------------------------------------
		override public function Update():void {
			// Обновление состояния объекта
//trace("------ "+Pict.GetPosition().toString());
			super.Update();
			// Пересчитать линию
			var Pos:Vector2 = ParentShip.PlanetA.GetPosition();

//if(ParentShip.PlanetA.Id==20) trace(String(ParentShip.PlanetA.Id)+"  "+Pos.toString()+"  "+P1.toString());

			if(Pos.x!=P1.x||Pos.y!=P1.y) SetP1(Pos.x,Pos.y);
			Pos = ParentShip.PlanetB.GetPosition();
			if(Pos.x!=P3.x||Pos.y!=P3.y) SetP3(Pos.x,Pos.y);
			// Пересчитать положение картинки
			UpdatePict();
		}
//-----------------------------------------------------------------------------------------------------
		private function UpdatePict():void {
			// Пересчитать положение картинки
			// GlobalToLocalA используется потому что точки Р1-Р3 считаются в глобальных координатах
			var CurrentPictPoint:Vector2 = GlobalToLocalA(GetPx(ParentShip.FlyingProc));
//			var PictPoint:Vector2 = Pict.GetPosition();
//			if(PictPoint.x!=CurrentPictPoint.x||PictPoint.y!=CurrentPictPoint.y) {
				Pict.MoveIntoParent(CurrentPictPoint.X,CurrentPictPoint.Y,true);
//			}
		}
//-----------------------------------------------------------------------------------------------------
		override protected function Draw():void {
			// Отрисовка объекта
			if(Vn.Interplanety.VnUser.ShowOrbits==true||Selected==true) {
				
//if(ParentShip.PlanetA.Id==20) trace(ParentShip.PlanetB.GetPosition().toString()+"	"+P3.toString());
			// Т.к. рисование идет относительно точки регистрации родительского контейнера
//			if(stage!=null) {
/*
				P11.x += VnObjectT(parent).Width05 - VnObjectT(parent).GetPosition().X;
				P11.y += VnObjectT(parent).Height05 - VnObjectT(parent).GetPosition().Y;
				P22.x += VnObjectT(parent).Width05 - VnObjectT(parent).GetPosition().X;
				P22.y += VnObjectT(parent).Height05 - VnObjectT(parent).GetPosition().Y;
				P33.x += VnObjectT(parent).Width05 - VnObjectT(parent).GetPosition().X;
				P33.y += VnObjectT(parent).Height05 - VnObjectT(parent).GetPosition().Y;
*/
//			}

//var X1:Number = P1.x - VnObjectT(parent).GetPosition().X;
//var Y1:Number = P1.y - VnObjectT(parent).GetPosition().Y;
var NP1:Vector2 = GlobalToLocalA(new Vector2(P1.x,P1.y));
var NP2:Vector2 = GlobalToLocalA(new Vector2(P2.x,P2.y));
var NP3:Vector2 = GlobalToLocalA(new Vector2(P3.x,P3.y));
/*
var X2:Number = P2.x - VnObjectT(parent).GetPosition().X;
var Y2:Number = P2.y - VnObjectT(parent).GetPosition().Y;
var X3:Number = P3.x - VnObjectT(parent).GetPosition().X;
var Y3:Number = P3.y - VnObjectT(parent).GetPosition().Y;
*/
//trace(VnObjectT(parent).GetPosition());
				graphics.lineStyle(1,0x444444,0.5);
//				graphics.lineStyle(1,0xf8d830,0.5);
/*
				graphics.moveTo(P1.x,P1.y);
				graphics.curveTo(P2.x,P2.y,P3.x,P3.y);
*/
//				graphics.moveTo(P1.x-VnObjectT(parent).GetPosition().X,P1.y-VnObjectT(parent).GetPosition().Y);
//				graphics.curveTo(P2.x-VnObjectT(parent).GetPosition().X,P2.y-VnObjectT(parent).GetPosition().Y,P3.x-VnObjectT(parent).GetPosition().X,P3.y-VnObjectT(parent).GetPosition().Y);


//				graphics.moveTo(X1,Y1);
				graphics.moveTo(NP1.X,NP1.Y);
//				graphics.curveTo(X2,Y2,X3,Y3);
				graphics.curveTo(NP2.X,NP2.Y,NP3.X,NP3.Y);

			}
		}
//-----------------------------------------------------------------------------------------------------
		override public function Clear():void {
			// Очистка объекта
			graphics.clear();
		}
//-----------------------------------------------------------------------------------------------------
// Обработка событий
//-----------------------------------------------------------------------------------------------------
		protected function OnPictClick(e:Event):void {
			// Выбор маршрута
			Selected = !Selected;
			Redraw();
		}
//-----------------------------------------------------------------------------------------------------
		override protected function OnAddToStage(e:Event):void {
			// Пересчет положения картинки корабля, чтобы скомпенсировать появившиеся concatenatedMatrix т.к. траектория считается в глобальных координатах
			super.OnAddToStage(e);
			UpdatePict();
		}
//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------
		public function get P1():Vector2 {
			return P11;
		}
//-----------------------------------------------------------------------------------------------------
		public function get P2():Vector2 {
			return P22;
		}
//-----------------------------------------------------------------------------------------------------
		public function get P3():Vector2 {
			return P33;
		}
//-----------------------------------------------------------------------------------------------------
		public function get Selected():Boolean {
			return IsSelected;
		}
//-----------------------------------------------------------------------------------------------------
		public function set Selected(Value:Boolean):void {
			IsSelected = Value;
		}
//-----------------------------------------------------------------------------------------------------
	}
}