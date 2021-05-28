﻿package Vn.SpaceObjects.Orbit {
	// Класс
//-----------------------------------------------------------------------------------------------------
	import Vn.Math.Vector2;
	import Vn.SpaceObjects.InteractiveSpaceObjectRC;
	import Vn.SpaceObjects.InteractiveSpaceObjectRO;
	import Vn.SpaceObjects.SpaceObject;
	import Vn.Interplanety;
//-----------------------------------------------------------------------------------------------------
	public class OrbitR extends InteractiveSpaceObjectRO {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function OrbitR() {
			// Конструктор предка
			super();
			// Конструктор
			
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		override public function _delete():void {
			// Деструктор
			
			// Деструктор предка
			super._delete();
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		override public function CountRealPos(Time:Number=0.0):Vector2 {
			// Вычислить положение объекта на орбите в момент времени Time (мс)
			// Получить положение носителя ниже уровнем
			var ParOrbit:OrbitR = OrbitR(SpaceObject(parent).Trace);
			var ParOffset:Vector2 = new Vector2();
			if(ParOrbit!=null) ParOffset = ParOrbit.CountRealPos(Time);
			else {
				// В многоуровневой системе дошли до центра (звезды)
				// Т.к. StarSystem сдвинута так, чтобы ее 0.0 был в центре экрана, компенсировать сдвиг
				Vector2.Vec2Subtract(Vn.Interplanety.Universe.CurrentStarSystem.GetLocalPosition(), Vn.Interplanety.Universe.CurrentStarSystem.GetPosition(), ParOffset);
				// Получить положение как вектор из нуля StarSystem умноженный на коэффициент
				Vector2.Vec2Subtract(ParOffset, SpaceObject(parent).GetPosition(), ParOffset);
				ParOffset.Vec2Mult(l_RealScaleK);
			}
			// Получить собственное положение с учетом положения носителя
			return OrbitFunc.CountPositionOnEllipse(Time,ParOffset,l_RealScaleK);
		}
//-----------------------------------------------------------------------------------------------------
		override public function CountMROffset():Number {
			// Возвращает полное смещение объекта на орбите относительно центра системы (вычисляется по сумме средних радиусов)
			// Сумма средних реальных радиусов
			var Offset:Number = 0.0;
			// Если орбиты нескольких уровней вложенности + смещение центрального объекта
			Offset += InteractiveSpaceObjectRC(parent).CountMROffset();
			// Плюс собственный средний радиус
			Offset += RadiusAverage * l_RealScaleK;
			return Offset;
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