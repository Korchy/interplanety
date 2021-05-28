package Vn.Interface.CountDown 
{
//-----------------------------------------------------------------------------------------------------
// Счетчик обратного отсчета
//-----------------------------------------------------------------------------------------------------
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import Vn.Common.Common;
	import Vn.Interface.Text.VnText;
//-----------------------------------------------------------------------------------------------------
	public class CountDownVn extends VnText {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		private var lTimer:Timer;	// Таймер обратного отсчета
		private var lCurrentValue:int;	// Текущее значение
		// Константы событий
		public static const COUNTDOWNFINISHED:String = "EvCountDownFinished";	// Отсчет закончен
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function CountDownVn(vStartValue:int, vFrequency:uint) {
			// Конструктор родителя
			super();
			// Конструктор
			lCurrentValue = vStartValue;
			SetText();
			if (vStartValue > 0) {
				lTimer = new Timer(vFrequency);
				lTimer.addEventListener(TimerEvent.TIMER, OnTimer);
				lTimer.start();
			}
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		override public function _delete():void {
			// Деструктор
			if (lTimer != null) {
				lTimer.stop();
				lTimer.removeEventListener(TimerEvent.TIMER, OnTimer);
				lTimer = null;
			}
			// Деструктор родителя
			super._delete();
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		private function SetText():void {
			// Преобразовать секунды в ЧЧ:ММ:СС для помещения в текстовое поле
			var H:Number = Math.floor(lCurrentValue/(60*60));	// часов
			var M:Number = Math.floor((lCurrentValue-H*60*60)/60);	// минут
			var S:Number = lCurrentValue - H*60*60 - M*60; 			// секунд
			Text = Common.LeadingNull(String(H), 2) + ":" + Common.LeadingNull(String(M), 2) + ":" + Common.LeadingNull(String(S), 2);
		}
//-----------------------------------------------------------------------------------------------------
		private function CountDownFinished():void {
			// Счетчик дошел до 0
			// Таймер больше не нужен
			lTimer.stop();
			lTimer.removeEventListener(TimerEvent.TIMER, OnTimer);
			lTimer = null;
			// Отправить событие
			dispatchEvent(new Event(CountDownVn.COUNTDOWNFINISHED));
		}
//-----------------------------------------------------------------------------------------------------
// Обработка событий
//-----------------------------------------------------------------------------------------------------
		private function OnTimer(e:TimerEvent):void {
			// Срабатываение таймера
			lCurrentValue --;
			SetText();
			if (lCurrentValue == 0) CountDownFinished();	// Дошли до 0
		}
//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------
		public function get DestTime():int {
			return lCurrentValue;
		}
//-----------------------------------------------------------------------------------------------------
	}
}