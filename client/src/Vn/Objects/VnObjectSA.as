﻿package Vn.Objects {
	// Класс "спрайт с анимацией"
//-----------------------------------------------------------------------------------------------------
	import flash.utils.getTimer;	// Для работы с getTimer
	import Vn.Common.SC;
//-----------------------------------------------------------------------------------------------------
	public class VnObjectSA extends VnObjectS {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		private var lAnimationSpeed:uint;	// Скорость смены кадров (кол-во мс. до следующей смены кадра)
		private var AnimationTime:uint;		// Текущее кол-во мс. до следующего кадра
		private var AnimType:uint;		// Тип анимации
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function VnObjectSA() {
			// Конструктор предка
			super();
			// Конструктор
			AnimationSpeed = 100;
			AnimType = SC.ANIM_NONE;
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
		public function PlayAnimation():void {
			// Проигрывание анимации
			if(AnimType==SC.ANIM_NONE) return;
			// Если есть кадры - поставить следующий кадр
			var CurrentTime:uint = getTimer();	// Кол-во мс. с момента запуска
			var TimeDiff:uint = CurrentTime - AnimationTime;
			if(TimeDiff>=AnimationSpeed) {
				// Смена кадра
				CurrentFrame++;
				if(CurrentFrame>=Image.Info.Frames) CurrentFrame = 0;
				ShowFrame(CurrentFrame);
				AnimationTime = CurrentTime;
			}
		}
//-----------------------------------------------------------------------------------------------------
		override public function ReLoadById(NewId:uint):void {
			// Перезагрузить изображение по Id
			super.ReLoadById(NewId);
			if(Image.Info.Frames==1&&AnimationType!=SC.ANIM_NONE) AnimationType = SC.ANIM_NONE;
		}
//-----------------------------------------------------------------------------------------------------
		override public function ReloadByType(ObjectType:String,ObjectId:uint=0,Cx:uint=20,Cy:uint=20):void {
			// Перезагрузить изображение по типу
			super.ReloadByType(ObjectType,ObjectId,Cx,Cy);
			if(Image.Info.Frames==1&&AnimationType!=SC.ANIM_NONE) AnimationType = SC.ANIM_NONE;
		}
//-----------------------------------------------------------------------------------------------------
// Обработка событий
//-----------------------------------------------------------------------------------------------------

//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------
		public function get AnimationType():uint {
			return AnimType;
		}
//-----------------------------------------------------------------------------------------------------
		public function set AnimationType(Value:uint):void {
			AnimType = Value;
		}
//-----------------------------------------------------------------------------------------------------
		public function get AnimationSpeed():uint {
			return lAnimationSpeed;	// Скорость смены кадров анимации (задержка между кадрами)
		}
//-----------------------------------------------------------------------------------------------------
		public function set AnimationSpeed(Value:uint):void {
			lAnimationSpeed = Value;
		}
//-----------------------------------------------------------------------------------------------------
	}
}