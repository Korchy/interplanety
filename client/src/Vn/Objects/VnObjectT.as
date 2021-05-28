package Vn.Objects {
	// Класс объектов с возможностью трансформаций
//-----------------------------------------------------------------------------------------------------
	import flash.geom.Point;
	import flash.geom.Matrix;
	import Vn.Interface.Button.Button;
	import Vn.Interface.Button.CloseButton;
	import Vn.Math.pNumber;
	import Vn.Math.Vector2;
	import Vn.Math.Matrix2;
	import Vn.Scene.StarSystem.StarSystemRealVn;
	import Vn.Scene.StarSystem.StarSystemVn;
	import Vn.SpaceObjects.Planets.PlanetR;
	import Vn.SpaceObjects.SpaceObject;
	import Vn.SpaceObjects.Stars.StarR;
	import Vn.System.FPSCounter;
	import Vn.Interplanety;
//-----------------------------------------------------------------------------------------------------
	public class VnObjectT extends VnObjectA {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		// Скорости
		protected var ScrollSpeed:Number = 0.5;	// Скорость движения объекта (ед./мс.)
		protected var RotateSpeed:Number = 0.1;	// Скорость вращения объекта (ед./мс.)
		protected var ScaleSpeed:Number = 0.1;	// Скорость масштабирования объекта (ед./мс.)
		// Счетчик FPS
		private var FPSCnt:FPSCounter;
		// Положение объекта (его центр)
		private var Position:Vector2;
		// Положение объекта в глобальных координатах (нужно хранить т.к. LocalToGlobal не может корректно
		// перевести координаты при нескольких вызовах подряд из-за погрешности в tx,ty у concatenatedMatrix,
		// которая скорее всего появляется из-за округления tx,ty до 0.05 (twips))
//		public var GlobalPosition:Vector2;
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function VnObjectT() {
			// Конструктор родителя
			super();
			// Конструктор
			Position = new Vector2();	// Инициализация Position в 0,0
//			GlobalPosition = new Vector2();
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		override public function _delete():void {
			// Деструктор
			FPS = null;
			Position._delete();
			Position = null;
//			GlobalPosition._delete();
//			GlobalPosition = null;
			// Деструктор родителя
			super._delete();
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		public function GlobalToLocal(Vector:Vector2):Vector2 {
			// Переопределение globalToLocal на работу с Vector2
			// Также учитываем является объект чьим-нибудь чайлдом или нет
			var TransformedVector:Vector2 = new Vector2(Vector.X,Vector.Y);
			var P:Point = globalToLocal(Point(TransformedVector));
			TransformedVector.X = P.x;
			TransformedVector.Y = P.y;
			return TransformedVector;
		}
//-----------------------------------------------------------------------------------------------------
		public function GlobalToLocalA(Vector:Vector2):Vector2 {
			// Получение абсолютных координат точки Vector в системе координат объекта
			// Полностью убираем воздействие всех матриц (собственной и парентов)
			var TransformedVector:Vector2 = new Vector2(Vector.X,Vector.Y);
			// Домножить матрицу объекта на суммарную инвертированную матрицу
			var m:Matrix = transform.concatenatedMatrix.clone();
			m.invert();
			var P:Vector2 = new Vector2();
			Vector2.Vec2TransformCoord(TransformedVector,m,P);
			return P;
		}
//-----------------------------------------------------------------------------------------------------
		public function LocalToGlobal(Vector:Vector2):Vector2 {
			// Переопределение localToGlobal на работу с Vector2
			// Вроде бы правильно работает базовая функция
			var TransformedVector:Vector2 = new Vector2(Vector.X,Vector.Y);
			var P:Point = localToGlobal(Point(TransformedVector));
			TransformedVector.X = P.x;
			TransformedVector.Y = P.y;
			return TransformedVector;
		}
//-----------------------------------------------------------------------------------------------------
		public function IterationVay():Number {
			// Возвращает путь, который объект должен был пройти за итерацию цикла
			var Vay:Number = ScrollSpeed;
			if(FPS!=null) Vay *= FPS.GetFramesDiff();
			return Vay;
		}
//-----------------------------------------------------------------------------------------------------
		public function IterationAngle():Number {
			// Возвращает угол, на который объект должен был повернуть за итерацию цикла
			var Angle:Number = RotateSpeed;
			if(FPS!=null) Angle *= FPS.GetFramesDiff();
			return Angle;
		}
//-----------------------------------------------------------------------------------------------------
		public function IterationScale():Number {
			// Возвращает во сколько раз объект должен был быть отмасштабирован за итерацию цикла
			var Scale:Number = ScaleSpeed;
			if(FPS!=null) Scale *= FPS.GetFramesDiff();
			return Scale;
		}
//-----------------------------------------------------------------------------------------------------
		public function GetPosition():Vector2 {
			// Возвращает точку центра объекта в глобальных координатах
			var Pos:Vector2 = LocalToGlobal(new Vector2(Position.X,Position.Y));
//			Pos.x = Math.round(Pos.x);	// Position возвращаем в целом виде
//			Pos.y = Math.round(Pos.y);
			return Pos;
		}
//-----------------------------------------------------------------------------------------------------
		public function GetPositionLT():Vector2 {
			// Возвращает левую верхнюю точку объекта в глобальных координатах
			var Pos:Vector2 = LocalToGlobal(new Vector2(0.0, 0.0));
			return Pos;
		}
//-----------------------------------------------------------------------------------------------------
		public function GetLocalPosition():Vector2 {
			// Возвращает точку центра объекта в локальных координатах
			return Position;
		}
//-----------------------------------------------------------------------------------------------------
		public function SetLocalPosition(NewX:Number,NewY:Number):void {
			// Устанавливает новую точку центра объекта в локальных координатах
			Position.X = NewX;
			Position.Y = NewY;
		}
//-----------------------------------------------------------------------------------------------------
		public function GetLocalVecX():Vector2 {
			// Возвращает локальный вектор X объекта
			var P:Vector2 = new Vector2();
			Vector2.Vec2Add(GetLocalPosition(),new Vector2(1.0,0.0),P);
			return P;
		}
//-----------------------------------------------------------------------------------------------------
		public function GetVecX():Vector2 {
			// Возвращает вектор X объекта
			var P:Vector2 = LocalToGlobal(GetLocalVecX());
			return P;
		}
//-----------------------------------------------------------------------------------------------------
		public function GetLocalVecY():Vector2 {
			// Возвращает локальный вектор Y объекта
			var P:Vector2 = new Vector2();
			Vector2.Vec2Add(GetLocalPosition(),new Vector2(0.0,1.0),P);
			return P;
		}
//-----------------------------------------------------------------------------------------------------
		public function GetVecY():Vector2 {
			// Возвращает вектор Y объекта
			var P:Vector2 = LocalToGlobal(GetLocalVecY());
			return P;
		}
//-----------------------------------------------------------------------------------------------------
		public function GetMatrix():Matrix {
			// Возвращает указатель на матрицу трансформации объекта
			return transform.matrix;
		}
//-----------------------------------------------------------------------------------------------------
		public function GetMatrixT():Matrix {
			// Возвращает указатель на матрицу перемещений объекта
			var M:Matrix = transform.matrix.clone();
			M.a = 1;
			M.b = 0;
			M.c = 0;
			M.d = 1;
			return M;
		}
//-----------------------------------------------------------------------------------------------------
		public function GetConcatenatedMatrix():Matrix {
			// Возвращает указатель на concatenated-матрицу трансформации объекта
			return transform.concatenatedMatrix;
		}
//-----------------------------------------------------------------------------------------------------
		public function GetConcatenatedMatrixT():Matrix {
			// Возвращает указатель на concatenated-матрицу перемещений объекта
			var M:Matrix = parent.transform.concatenatedMatrix.clone();
			M.a = 1;
			M.b = 0;
			M.c = 0;
			M.d = 1;
			return M;
		}
//-----------------------------------------------------------------------------------------------------
// ТРАНСФОРМАЦИИ ОБЪЕКТА
//-----------------------------------------------------------------------------------------------------
		protected function CountWorldMatrix(M:Matrix):void {
			// Пересчет матрицы трансформации для объекта - объединение с существующей
			if(M==null||Matrix2.IsIdentity(M)==true) return;
			var w:Matrix = transform.matrix;
			w.concat(M);
			transform.matrix = w;
		}
//-----------------------------------------------------------------------------------------------------
		protected function SetWorldMatrix(M:Matrix):void {
			// Пересчет матрицы трансформации для объекта - замена существующей
			if(M==null) return;
			var w:Matrix = transform.matrix;
			if(Matrix2.Equal(w,M)==true) return;
			transform.matrix = M;
		}
//-----------------------------------------------------------------------------------------------------
//		public function MoveInto(NewX:int,NewY:int,Once:Boolean):Boolean {
//		public function MoveInto(NewX:Number,NewY:Number,Once:Boolean):Boolean {
		public function MoveInto(NewPos:Vector2, Once:Boolean=true):Boolean {
			// Перемещение объекта в точку NewX,NewY в глобальном пространстве
			// Если перемещаем в ту же точку - возврат
//			if (NewX == GlobalPosition.X && NewY == GlobalPosition.Y) return true;
//			if (GetPosition().X == NewX && GetPosition().Y == NewY) return true;	// Чтобы не гонять матрицы, если объект не сдвинулся с места
			if (GetPosition().X == NewPos.X && GetPosition().Y == NewPos.Y) return true;	// Чтобы не гонять матрицы, если объект не сдвинулся с места
//			// Сохранить новые глобальные координаты
//			GlobalPosition.X = NewX;
//			GlobalPosition.Y = NewY;
			// Перевести конечную точку в систему координат объекта
//			var EndPos:Vector2 = GlobalToLocal(new Vector2(NewX,NewY));
			var EndPos:Vector2 = GlobalToLocal(NewPos);
			// Перевести начальную точку в систему координат объекта
			var Pos:Vector2 = GlobalToLocal(GetPosition());
			return MoveFromInto(Pos,EndPos,Once);
		}
//-----------------------------------------------------------------------------------------------------
		public function MoveIntoParent(NewX:int,NewY:int,Once:Boolean=true):Boolean {
			// Перемещение объекта в точку NewX,NewY в системе координат родительского объекта
			// Конечная точка и так в системе координат предка
			var EndPos:Vector2 = new Vector2(NewX,NewY);
			// Перевести начальную точку в локальную систему координат предка
			var Pos:Vector2 = VnObjectT(parent).GlobalToLocal(new Vector2(GetPosition().X,GetPosition().Y));	// Если объект смещен нужно учитывать и его матрицу
			return MoveFromInto(Pos,EndPos,Once);
		}
//-----------------------------------------------------------------------------------------------------
		public function MoveIntoL(NewX:int,NewY:int,Once:Boolean):Boolean {
			// Перемещение объекта в точку NewX,NewY в локальном пространстве
			var EndPos:Vector2 = new Vector2(NewX,NewY);
			return MoveFromInto(GetLocalPosition(),EndPos,Once);
		}
//-----------------------------------------------------------------------------------------------------
		private function MoveFromInto(From:Vector2,Into:Vector2,Once:Boolean):Boolean {
			// Перемещение объекта в точку NewX,NewY в пространстве определяемом заданными векторами
			var End:Boolean = Once;
			// Вектор из From в Into
			var MoveVector:Vector2 = new Vector2();
			Vector2.Vec2Subtract(From, Into, MoveVector);
			if(Once==false) {
				// Получить путь, который объект должен был проийти за итерацию
				var Vay:Number = IterationVay();
				var MoveEndVector:Vector2 = MoveVector.Vec2Clone();
				// Вектор пути за итерацию
				MoveVector.Vec2Normalize();
				MoveVector.Vec2Mult(Vay);
				// Проверить - не конец ли это пути
				// Сравниваем длины векторов EndPosition-Position и MoveVector.
				// Если MoveVector больше - значит нужно переместиться уже в EndPosition
				if(MoveEndVector.Vec2Length()<=MoveVector.Vec2Length()) {
					// Пересчитать MoveVector на указывающий в EndPosition
					MoveVector = MoveEndVector;
					End = true;	// Достигли EndPosition
				}
			}
			// Получить матрицу трансформации для данных координат
			var matrix:Matrix = new Matrix();
			matrix.identity();
			matrix.translate(MoveVector.X,MoveVector.Y);
			// Применить полученную матрицу к объекту
			CountWorldMatrix(matrix);
			return End;
		}
//-----------------------------------------------------------------------------------------------------
		public function MoveOn(Axis:String,Length:pNumber,Once:Boolean):Boolean {
			// Перемещение объекта на Length вдоль локальный оси Axis
			if(Axis!="X"&&Axis!="Y"||Math.abs(Length.v)<0.05) return true;
			// Перемещение объекта
			var End:Boolean = Once;
			// Учесть уже имеющуюся матрицу трансформации
			var Pos:Vector2 = GetPosition();
			var Vx:Vector2 = GetVecX();
			var Vy:Vector2 = GetVecY();
			// Получить единичный вектор вдоль нужной оси в локальной системе координат
			var Loc:Vector2 = new Vector2();
			if(Axis=="X") Vector2.Vec2Subtract(Pos,Vx,Loc);
			else Vector2.Vec2Subtract(Pos,Vy,Loc);
			Loc.Vec2Normalize();
			// Полученный вектор привести к длине пути
			if(Once==false) {
				// Получить путь, который объект должен был пройти за время итерации
				var Vay:Number = IterationVay();
				if(Vay<Math.abs(Length.v)) {
				// Если путь за итерацию Vay меньше Length - передвигаем на Vay и уменьшаем Length
				if(Length.v<0.0) Vay = -Vay;
					Loc.Vec2Mult(Vay);
					Length.v -= Vay;
				}
				else {
					// Иначе передвигаем на Length
					Loc.Vec2Mult(Length.v);
					End = true;
				}
			}
			else Loc.Vec2Mult(Length.v);
			// Получить матрицу трансформации для данных координат
			var matrix:Matrix = new Matrix();
			matrix.identity();
			matrix.translate(Loc.X,Loc.Y);
			// Применить полученную матрицу к объекту
			CountWorldMatrix(matrix);
			// Скорректировать глобальные координаты
//			GlobalPosition.X = GetPosition().X;
//			GlobalPosition.Y = GetPosition().Y;
			return End;
		}
//-----------------------------------------------------------------------------------------------------
		public function RotateAround(Axis:Vector2,Angle:pNumber,Once:Boolean):Boolean {
			// Вращение объекта вокруг оси Axis заданой в глобальной системе координат на угол Angle
			// Перевести Axis в систему координат объекта
			var TransformedAxis:Vector2 = GlobalToLocal(Axis);
			return RotateAroundAxis(TransformedAxis,Angle,Once);
		}
//-----------------------------------------------------------------------------------------------------
		public function RotateAroundAxis(Axis:Vector2,Angle:pNumber,Once:Boolean):Boolean {
			// Вращение объекта вокруг оси Axis (в системе координат объекта) на угол Angle
			var End:Boolean = Once;
			// Поворот делается в 3 этапа: перенос в 0,0,0, поворот и перенос обратно в Axis
			// Матрица накопления трансформаций
			var MM:Matrix = new Matrix();
			MM.identity();
			// Перенос в 0,0,0
			var MoveVector:Vector2 = new Vector2();
			Vector2.Vec2Subtract(Axis,new Vector2(0.0,0.0),MoveVector);
			var matrix:Matrix = new Matrix();
			matrix.identity();
			matrix.translate(MoveVector.X, MoveVector.Y);
			MM.concat(matrix);
			// Поворот
			var RotAngle:Number = Angle.v;
			if(Once==false) {
				// Угол поворота за итерацию в градусах
				var Ang:Number = IterationAngle();
				// Если угол на который нужно повернуть больше Ang - поворачиваем на Ang
				if(Math.abs(Angle.v)>Ang) {
					if(Angle.v<0.0) RotAngle = -Ang;
					else RotAngle = Ang;
					Angle.v -= RotAngle;
				}
				else {
					Angle.v = 0.0;
					End = true;
				}
			}
			RotAngle *= Math.PI/180.0;
			// Получить матрицу вращения
			var Rot:Matrix = new Matrix();
			Rot.identity();
			Rot.rotate(RotAngle);
			MM.concat(Rot);
			// Вернутся обратно в Position
			matrix.identity();
			matrix.translate(-MoveVector.X, -MoveVector.Y);
			MM.concat(matrix);
			// Применить полученную матрицу к матрице объекта
			CountWorldMatrix(MM);
			return End;
		}
//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------
		public function get Width():uint {
			return 2*GetLocalPosition().X;	// Ширина
		}
//-----------------------------------------------------------------------------------------------------
		public function get Height():uint {
			return 2*GetLocalPosition().Y;	// Высота
		}
//-----------------------------------------------------------------------------------------------------
		public function get Width05():uint {
			return GetLocalPosition().X;	// Половина ширины
		}
//-----------------------------------------------------------------------------------------------------
		public function get Height05():uint {
			return GetLocalPosition().Y;	// Половина высоты
		}
//-----------------------------------------------------------------------------------------------------
		public function get OnScreen():Boolean {
			// Объект виден на экране (попадает в область экрана)
			if (GetPosition().X + Width05 > 0 && GetPosition().X - Width05 < Vn.Interplanety.Width && GetPosition().Y + Height05 > 0 && GetPosition().Y - Height05 < Vn.Interplanety.Height) return true;
			else return false;
		}
//-----------------------------------------------------------------------------------------------------
		public function get FPS():FPSCounter {
			return FPSCnt;	// Счетчик FPS
		}
//-----------------------------------------------------------------------------------------------------
		public function set FPS(Value:FPSCounter):void {
			FPSCnt = Value;
		}
//-----------------------------------------------------------------------------------------------------
	}
}