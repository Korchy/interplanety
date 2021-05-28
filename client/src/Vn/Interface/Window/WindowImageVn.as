package Vn.Interface.Window {
//-----------------------------------------------------------------------------------------------------
// Подложка для окна (визуальный компонент)
// Нужно отдельным классом т.к. наложенный фильтр glow автоматически накладывается на всех чайлдов, а это не нужно
//-----------------------------------------------------------------------------------------------------
	import flash.filters.GlowFilter;
	import flash.filters.BitmapFilterQuality;
	import Vn.Interface.Background.BackgroundVn;
	import Vn.Interplanety;
	import Vn.Math.RectangleVn;
//-----------------------------------------------------------------------------------------------------
	public class WindowImageVn extends BackgroundVn {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function WindowImageVn() {
			// Конструктор предка
			super();
			// Конструктор
			BackgroundColor = Interplanety.VnUser.Skin.WindowBackgroundColor;
			BackgroundAlpha = Interplanety.VnUser.Skin.WindowAlpha;
			LineColor = BackgroundColor;
			LineAlpha = 0.5;
			LineThickness = 2;
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
		override protected function Draw():void {
			// Отрисовка объекта
			if(Rendered==true) {
				graphics.lineStyle(LineThickness, LineColor, LineAlpha);
				// Очертания всего окна (с заполнением)
				graphics.beginFill(BackgroundColor, BackgroundAlpha);
				graphics.moveTo(0,0);
				graphics.lineTo(Width,0);
				graphics.lineTo(Width,Height);
				graphics.lineTo(0,Height);
				graphics.lineTo(0,0);
				graphics.endFill();
				// Очертания рабочей области (двойная линия, внутренняя лииня идет по границе рабочей области, внешняя на 3 пикс. больше)
				var WorkSpace:RectangleVn = VnWindow(parent).WorkSpace;
				var IDx:int = 0;	// Смещение внутренней линии
				var ODx:int = 3;	// Смещение внешней линии
				// Внутренняя линия
				graphics.moveTo(WorkSpace.X,WorkSpace.Y);
				graphics.lineTo(Width-WorkSpace.X,WorkSpace.Y);
				graphics.lineTo(Width-WorkSpace.X,Height-ODx);
				graphics.moveTo(WorkSpace.X,Height-ODx);
				graphics.lineTo(WorkSpace.X, WorkSpace.Y);
				// Внешняя линия
				graphics.moveTo(WorkSpace.X-ODx,WorkSpace.Y-ODx);
				graphics.lineTo(Width-WorkSpace.X+ODx,WorkSpace.Y-ODx);
				graphics.lineTo(Width-WorkSpace.X+ODx,Height-ODx);
				graphics.moveTo(WorkSpace.X-ODx,Height-ODx);
				graphics.lineTo(WorkSpace.X-ODx,WorkSpace.Y-ODx);
				// Применить фильтр Glow
				var glow:GlowFilter = new GlowFilter();
				glow.color = BackgroundColor;
				glow.alpha = 1;
				glow.blurX = 15;
				glow.blurY = 15;
	//			glow.inner = false;
	//			glow.knockout = true;
	//			glow.strength = 4;
				glow.quality = BitmapFilterQuality.MEDIUM;
				filters = [glow];
			}
		}
//-----------------------------------------------------------------------------------------------------
// Обработка событий
//-----------------------------------------------------------------------------------------------------
		
//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------
	}
}