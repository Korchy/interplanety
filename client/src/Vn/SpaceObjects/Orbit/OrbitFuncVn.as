package Vn.SpaceObjects.Orbit {
//-----------------------------------------------------------------------------------------------------
// Обрита (функционал)
//-----------------------------------------------------------------------------------------------------
	import Vn.Common.Common;
	import Vn.Math.Vector2;
	import Vn.Objects.VnObjectT;
	import Vn.Scene.StarSystem.StarSystemVn;
	import Vn.SpaceObjects.SpaceObject;
//-----------------------------------------------------------------------------------------------------
	public class OrbitFuncVn {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		private var lRadiusL:Number;		// Большой радиус эллипса
		private var lRadiusS:Number;		// Малый радиус эллипса
		private var lAngle:Number;			// Угол наклона эллипса от горизонтали
		private var lSpeed:Number;			// Скорость движения по орбите
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function OrbitFuncVn() {
			// Конструктор предка
			super();
			// Конструктор
			SetRadius(100.0, 100.0);
			lAngle = 0.0;
			lSpeed = 0.001;
			}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		public function _delete():void {
			// Деструктор
			
			// Деструктор предка
//			super._delete();
			}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		public function SetRadius(NewL:Number,NewS:Number):void {
			// Установить новые радиусы эллипса
			if(NewL>=0.0&&NewS>=0.0) {
				lRadiusL = NewL;
				lRadiusS = NewS;
			}
		}
//-----------------------------------------------------------------------------------------------------
		public function SetAngle(NewA:Number):void {
			// Установить новый угол наклона эллипса
			lAngle = NewA;
		}
//-----------------------------------------------------------------------------------------------------
		public function SetSpeed(NewS:Number):void {
			// Установить новую скорость движения по эллипсу
			lSpeed = NewS;
		}
//-----------------------------------------------------------------------------------------------------
		public function CountPos(vParent:SpaceObject, Time:Number):Vector2 {
			// Вычислить положение объекта на орбите в момент времени Time (мс)
			// vParent - собственно сама орбита, к которой относится данный функционал
			// Получить положение носителя ниже уровнем
			var ParOffset:Vector2;
			if (vParent.parent is StarSystemVn) {
				// Орбита кинута непосредственно на звездную систему
				ParOffset = vParent.GetPosition();
			}
			else {
				// Орбита висит на другом SpaceObject
				var ParOrbit:SpaceObject;
				if (vParent.Trace != null) ParOrbit = vParent.Trace;	// Орбита кинута на другую орбиту (без планеты)
				else ParOrbit = SpaceObject(vParent.parent).Trace;		// Орбита кинута на планету
				if(ParOrbit!=null) ParOffset = ParOrbit.CountPos(Time);
				else ParOffset = new Vector2(SpaceObject(vParent.parent).GetPosition().x, SpaceObject(vParent.parent).GetPosition().y);
			}
			// Получить собственное положение с учетом положения носителя
//if(SpaceObjectId == 6) trace(ParOffset);
			return CountPositionOnEllipse(Time, ParOffset, 1.0);
		}
//-----------------------------------------------------------------------------------------------------
		public function CountPositionOnEllipse(Time:Number,ParentOffset:Vector2,Scale:Number):Vector2 {
			// Вычисление положения планеты на эллиптической орбите в зависимости от размеров орбиты и скорости дв-я планеты в момент времени Time
			// ParentOffset - смещение центра орбиты
			// Scale - масштабирование
			var RL:Number = lRadiusL * Scale;
			var RS:Number = lRadiusS * Scale;
			var SSpeed:Number = lSpeed * Scale;
			var RadiusSL:Number = (RL+RS)/2.0;		// Усредненный радиус
			var Ang:Number = -lAngle*Math.PI/180;				// Угол наклона эллипса
			var LinSpeed:Number = Common.Round(SSpeed*Time/RadiusSL,2);	// Линейная скорость движения
			var as0:Number = Common.Round(Math.sin(Ang),2);		// Округление до 2 знака - попытка борьбы с вибрацией. Не поможет - убрать.
			var ac0:Number = Common.Round(Math.cos(Ang),2);
			var x0:Number = Common.Round(RL*Math.cos(LinSpeed),2);
			var y0:Number = Common.Round(RS*Math.sin(LinSpeed),2);
			var NewX:Number = Math.round(x0*ac0+y0*as0+ParentOffset.x);	// X,Y округляем до целого
			var NewY:Number = Math.round( -x0 * as0 + y0 * ac0 + ParentOffset.y);
//if(SpaceObjectId == 6) trace(new Vector2(NewX, NewY).toString());
			return new Vector2(NewX, NewY);
		}
//-----------------------------------------------------------------------------------------------------
// Обработка событий
//-----------------------------------------------------------------------------------------------------
		
//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------
		public function get RadiusAverage():Number {
			return (lRadiusL+lRadiusS)/2.0;
		}
//-----------------------------------------------------------------------------------------------------
		public function get RadiusL():Number {
			// Большой радиус
			return lRadiusL;
		}
//-----------------------------------------------------------------------------------------------------
		public function get RadiusS():Number {
			// Малый радиус
			return lRadiusS;
		}
//-----------------------------------------------------------------------------------------------------
		public function get Angle():Number {
			// Угол наклона
			return lAngle;
		}
//-----------------------------------------------------------------------------------------------------
		public function get Speed():Number {
			// Скорость движения по орбите
			return lSpeed;
		}
//-----------------------------------------------------------------------------------------------------
	}
}