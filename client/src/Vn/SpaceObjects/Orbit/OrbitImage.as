﻿package Vn.SpaceObjects.Orbit {
	// Изображение орбиты. Нужно отдельным классом т.к. подсчет орбиты ведется из расчета, что ее центр (точка 0,0) в центре эллипса, а рисуется - ее центр в левом верхнем угле
	// При этом если главный класс орбиты занимается отрисовкой, при addChild орбит в несколько уровней для каждого последующего уровня сохраняется поворот от предыдущего, чего быть не должно.
//-----------------------------------------------------------------------------------------------------
	import Vn.Objects.VnObjectD;
	import Vn.Math.pNumber;
	import Vn.Math.Vector2;
	import Vn.Interplanety;
//-----------------------------------------------------------------------------------------------------
	public class OrbitImage extends VnObjectD {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		private var RadiusL:Number;		// Большой радиус эллипса
		private var RadiusS:Number;		// Малый радиус эллипса
		private var Angle:Number;		// Угол наклона эллипса от горизонтали
		private var lLineColor:uint;		// Цвет линии
		private var lLineAlpha:Number;	// Прозрачность линии
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function OrbitImage() {
			super();
			NeedPlace = true;	// Выровнять по центру парента
			// Параметры по умолчанию
			Angle = 0.0;
			SetRadius(100.0, 100.0);
			lLineColor = 0x444444;
			lLineAlpha = 0.5;
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		override public function _delete():void {
			
			// Деструктор родителя
			super._delete();
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		public function SetRadius(NewL:Number,NewS:Number):void {
			// Установить новые радиусы эллипса
			if(NewL>=0.0&&NewS>=0.0) {
				RadiusL = NewL;
				RadiusS = NewS;
				SetLocalPosition(NewL,NewS);
				if(parent!=null) RePlace();	// Если добавлен в список отображения - перецентрировать
				Redraw();
			}
		}
//-----------------------------------------------------------------------------------------------------
		public function SetAngle(NewA:Number):void {
			// Установить новый угол наклона эллипса
			var pAng:pNumber = new pNumber(NewA-Angle);
//			RotateAroundAxis(new Vector2(RadiusL,RadiusS),pAng,true);
			RotateAroundAxis(GetPosition(),pAng,true);
			Angle = NewA;
			Redraw();
		}
//-----------------------------------------------------------------------------------------------------
		override protected function Draw():void {
			// Отрисовка объекта
			if (Vn.Interplanety.VnUser.ShowOrbits == true) {
				// Линия для отображения
				graphics.lineStyle(1, lLineColor, lLineAlpha);
//				graphics.drawRect(0, 0, Width, Height);		// Квадрат для отладки
				graphics.drawEllipse(0, 0, RadiusL * 2.0, RadiusS * 2.0);
				// Линия для выбора - более толстая, рисуется прозрачной. Только для отслеживания событий наведения/ухода курсора (чтобы не играть в пиксельхантинг с тонкой линией)
				graphics.lineStyle(15, lLineColor, 0.0);
				graphics.drawEllipse(0,0,RadiusL*2.0,RadiusS*2.0);
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
		
//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------
		
//-----------------------------------------------------------------------------------------------------
	}
}