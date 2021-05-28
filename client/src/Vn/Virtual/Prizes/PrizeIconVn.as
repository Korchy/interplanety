package Vn.Virtual.Prizes {
//-----------------------------------------------------------------------------------------------------
// Контейнер с картинкой приза и количеством призов в стеке
//-----------------------------------------------------------------------------------------------------
	import flash.events.Event;
	import flash.events.MouseEvent;
	import Vn.Common.LoadStatusVn;
	import Vn.Interface.Text.VnText;
	import Vn.Math.Vector2;
	import Vn.Objects.VnObjectS;
	import Vn.Objects.VnObjectT;
	import Vn.Objects.VnObjectR;
	import Vn.Objects.Var.LoadedObject;
	import Vn.Scene.StarSystem.StarSystemVirtualVn;
	import Vn.SpaceObjects.SpaceObject;
	import Vn.Text.TextDictionary;
	import Vn.Virtual.Prizes.PrizesImageListVn;
	import Vn.Interplanety;
//-----------------------------------------------------------------------------------------------------
	public class PrizeIconVn extends VnObjectR {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		private var lPrize:PrizeVn;		// Указатель на приз
		private var lPict:VnObjectS;	// Картинка 60х60
		private var lStackAmount:VnText;		// Текст - количество в стеке
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function PrizeIconVn(CurrentPrize:PrizeVn) {
			// Конструктор предка
			super();
			// Конструктор
			lPrize = CurrentPrize;
			lPrize.addEventListener(PrizeVn.STACK_AMOUNT_CHANGED, OnStackAmountChanged);
			Id = lPrize.SpaceObjectId;	// Id берется из SpaceObjectId приза
			SetLocalPosition(30, 30 + 7);	// Размеры 60 (картинка) х 60 (картинка) + 14 (текст)
			lPict = new VnObjectS();
			lPict.NeedPlace = true;
			lStackAmount = new VnText();
			lStackAmount.Align = VnText.NONE;
			lStackAmount.TextAlign = VnText.CENTER;
			lStackAmount.y = 60;
			lStackAmount.width = 60;
			lStackAmount.height = 14;
			addChild(lStackAmount);
			// Т.к. приз может быть не загружен данными - загрузить
			if (CurrentPrize.Status != LoadStatusVn.LOADED) {
				CurrentPrize.addEventListener(LoadedObject.LOADED, OnPrizeLoaded);
				CurrentPrize.addEventListener(LoadedObject.FAIL, OnPrizeFail);
				if (CurrentPrize.Status != LoadStatusVn.IN_PROGRESS) CurrentPrize.Load();
			}
			else Init();
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		override public function _delete():void {
			// Деструктор
			removeChild(lPict);
			lPict._delete();
			lPict = null;
			removeChild(lStackAmount);
			lStackAmount._delete();
			lStackAmount = null;
			lPrize.removeEventListener(PrizeVn.STACK_AMOUNT_CHANGED, OnStackAmountChanged);
			lPrize = null;
			if (hasEventListener(MouseEvent.MOUSE_DOWN)) removeEventListener(MouseEvent.MOUSE_DOWN, OnMouseDown);
			if (hasEventListener(MouseEvent.MOUSE_UP)) removeEventListener(MouseEvent.MOUSE_UP, OnMouseUp);
			// Деструктор предка
			super._delete();
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		private function Init():void {
			// Заполнение данными из приза
			// Картинка приза
			lPict.ReLoadById(lPrize.Image.ImageInfo.Id);
			addChild(lPict);
			// Количество в стеке
			OnStackAmountChanged(null);
			// События для перетаскивания призов в виртуальную систему
			addEventListener(MouseEvent.MOUSE_DOWN, OnMouseDown);
			addEventListener(MouseEvent.MOUSE_UP, OnMouseUp);
		}
//-----------------------------------------------------------------------------------------------------
// Обработка событий
//-----------------------------------------------------------------------------------------------------
		private function OnMouseDown(e:MouseEvent):void {
			// Зажали кнопку мышки - начать перетаскивание
			lPict.DragCont.MouseDown(e);	// Контроль за перетаскиванием, чтобы исключить объект из проверки на курсор мышки (в StarSystem.GetObjectUnderPoint)
			lPict.startDrag();
		}
//-----------------------------------------------------------------------------------------------------
		private function OnMouseUp(e:MouseEvent):void {
			// Отпустили кнопку мышки - закончено перетаскивание
			lPict.stopDrag();
			lPict.DragCont.MouseUp(e);	// Контроль за drag
			// Проверить, что вытащили за пределы окна (parent.parent - список.окно, смотрим по размерам окна)
			var ParentCenter:Vector2 = VnObjectT(parent.parent).GetPosition();
			var ParentW05:Number = VnObjectT(parent.parent).Width05;
			var ParentH05:Number = VnObjectT(parent.parent).Height05;
			if (e.stageX > ParentCenter.X + ParentW05 || e.stageX < ParentCenter.X - ParentW05 || e.stageY > ParentCenter.Y + ParentH05 || e.stageY < ParentCenter.Y - ParentH05) {
				// За пределами окна - пробуем ковертировать приз в объект
				// Точка над которой сбросили
				var StarSystemPos:Vector2 = Vn.Interplanety.Universe.CurrentStarSystem.GetPosition();
				var StarSystem00Pos:Vector2 = new Vector2(StarSystemPos.X-Vn.Interplanety.Universe.CurrentStarSystem.Width05,StarSystemPos.Y-Vn.Interplanety.Universe.CurrentStarSystem.Height05);
				var NewPos:Vector2 = new Vector2();
				Vector2.Vec2Subtract(StarSystem00Pos, new Vector2(e.stageX, e.stageY), NewPos);
				// Объект над которым сбросили
				var NewTrace:SpaceObject = Interplanety.Universe.CurrentStarSystem.OverSpaceObject;
				// Конвертировать
				if (NewTrace != null) lPrize.ConvertFromStorageToObject(NewPos, NewTrace.Id);
				else lPrize.ConvertFromStorageToObject(NewPos);
			}
			else {
				// Осталась внутри окна - вернуть на место (обновить список)
				PrizesImageListVn(parent).Refresh();
			}
		}
//-----------------------------------------------------------------------------------------------------
		private function OnPrizeLoaded(e:Event):void {
			// Приз дозагружен данными
			lPrize.removeEventListener(LoadedObject.LOADED, OnPrizeLoaded)
			lPrize.removeEventListener(LoadedObject.FAIL, OnPrizeFail)
			// Заполнить пиктограмму данными
			Init();
		}
//-----------------------------------------------------------------------------------------------------
		private function OnPrizeFail(e:Event):void {
			// Ошибка дозагрузки приза данными
			lPrize.removeEventListener(LoadedObject.LOADED, OnPrizeLoaded)
			lPrize.removeEventListener(LoadedObject.FAIL, OnPrizeFail)
		}
//-----------------------------------------------------------------------------------------------------
		private function OnStackAmountChanged(e:Event):void {
			// При изменении количества в стеке
			lStackAmount.Text = TextDictionary.Text(186) + " " + String(lPrize.StackAmount);
			lPict.RePlace();	// Вернуть иконку в исходное положение
		}
//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------
		public function get StackAmount():uint {
			// Количество призов в стеке
			return lPrize.StackAmount;
		}
//-----------------------------------------------------------------------------------------------------
	}
}