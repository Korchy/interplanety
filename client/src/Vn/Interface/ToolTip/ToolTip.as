package Vn.Interface.ToolTip {
	// Всплывающая подсказка
//-----------------------------------------------------------------------------------------------------
	import flash.events.Event;
	import Vn.Math.Vector2;
	import Vn.Common.Common;
	import Vn.Common.SC;
	import Vn.Objects.VnObjectR;
	import Vn.Objects.VnObjectT;
	import Vn.Interface.Text.VnText;
//-----------------------------------------------------------------------------------------------------
	public class ToolTip extends VnObjectR {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		private var ToolTipText:VnText;	// Текст
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function ToolTip() {
			// Конструктор предка
			super();
			// Конструктор
			NeedPlace = true;
//			SetLocalPosition(50,50);
			// Текст
			ToolTipText = new VnText();
			ToolTipText.border = true;
			ToolTipText.textColor = SC.BLACK;
			ToolTipText.background = true;
			ToolTipText.backgroundColor = SC.YELLOW;
			addChild(ToolTipText);
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		override public function _delete():void {
			// Деструктор
			// Текст
			if(ToolTipText.parent!=null) removeChild(ToolTipText);
			ToolTipText._delete();
			ToolTipText = null;
			// Деструктор предка
			super._delete();
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		override protected function GetPlace():Vector2 {
			// Возвращает местоположение объекта
			if(parent!=null) {
				// Если добавлен в список отображения - по центру парента
				var NewPos:Vector2 = Common.SubObjPlace(VnObjectT(parent),this);
				return new Vector2(NewPos.X+VnObjectT(parent).Width05,NewPos.Y+VnObjectT(parent).Height05);
			}
			else {
				// Если не добавлен - 0,0
				return new Vector2(0.0,0.0);
			}
		}
//-----------------------------------------------------------------------------------------------------
// Обработка событий
//-----------------------------------------------------------------------------------------------------
		override protected function OnAddToStage(e:Event):void {
			// При добавлении в список отображения
			SetLocalPosition(ToolTipText.Width/2.0,ToolTipText.Height/2.0);
			super.OnAddToStage(e);
		}
//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------
		public function get Text():String {
			return ToolTipText.Text;
		}
//-----------------------------------------------------------------------------------------------------
		public function set Text(Value:String):void {
			ToolTipText.Text = Value;
//			ToolTipText.Size = 10;
		}
//-----------------------------------------------------------------------------------------------------
	}
}