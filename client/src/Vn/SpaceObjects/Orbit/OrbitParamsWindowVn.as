package Vn.SpaceObjects.Orbit {
//-----------------------------------------------------------------------------------------------------
// Окно редактирования параметров орбиты
//-----------------------------------------------------------------------------------------------------
	import flash.events.Event;
	import Vn.Common.SC;
	import Vn.Interface.Edit.EditN;
	import Vn.Interface.Text.VnText;
	import Vn.Interface.Window.VnWindowA;
	import Vn.Math.Vector2;
	import Vn.Objects.VnObjectT;
	import Vn.Text.TextDictionary;
	import Vn.Vn.Events.EvAppResize;
//-----------------------------------------------------------------------------------------------------
	public class OrbitParamsWindowVn extends VnWindowA {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		private var Owner:OrbitV;	// Объект (указатель на орбиту), который вызывал окно
		private var RadiusLOld:Number;	// Старые параметры орбиты (до момента открытия окна)
		private var RadiusSOld:Number;
		private var AngleOld:Number;
		private var SpeedOld:Number;
		private var RadiusLNewTxt:VnText;
		private var RadiusLNew:EditN;
		private var RadiusSNewTxt:VnText;
		private var RadiusSNew:EditN;
		private var AngleNewTxt:VnText;
		private var AngleNew:EditN;
		private var SpeedNewTxt:VnText;
		private var SpeedNew:EditN;
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function OrbitParamsWindowVn(vOwner:OrbitV) {
			// Конструктор предка
			super();
			// Конструктор
			Owner = vOwner;
			// Сохранить старые параметры (для возможности отмены)
			RadiusLOld = Owner.RadiusL;
			RadiusSOld = Owner.RadiusS;
			AngleOld = Owner.Angle;
			SpeedOld = Owner.Speed;
			Name = 190;	// "Параметры орбиты"
			Caption.Text = TextDictionary.Text(Name);
			SetLocalPosition(140, 100);
			Script = "updateorbitvparameters.php";
			// Большой радиус
			RadiusLNewTxt = new VnText();
			RadiusLNewTxt.Color = SC.BLACK;
			RadiusLNewTxt.Text = TextDictionary.Text(193);	// "Большой радиус"
			addChild(RadiusLNewTxt);
			RadiusLNewTxt.x = 40;
			RadiusLNewTxt.y = 40;
			RadiusLNew = new EditN();
			RadiusLNew.Type = EditN.TYPE_UINT;
			addChild(RadiusLNew);
			RadiusLNew.MoveIntoParent(200,50);
			RadiusLNew.Min = 20;
			RadiusLNew.Max = 2000;
			RadiusLNew.Value = RadiusLOld;
			RadiusLNew.addEventListener(Event.CHANGE, OnParametersChange);
			// Малый радиус
			RadiusSNewTxt = new VnText();
			RadiusSNewTxt.Color = SC.BLACK;
			RadiusSNewTxt.Text = TextDictionary.Text(194);	// "Малый радиус"
			addChild(RadiusSNewTxt);
			RadiusSNewTxt.x = 40;
			RadiusSNewTxt.y = 70;
			RadiusSNew = new EditN();
			RadiusSNew.Type = EditN.TYPE_UINT;
			addChild(RadiusSNew);
			RadiusSNew.MoveIntoParent(200,80);
			RadiusSNew.Min = 20;
			RadiusSNew.Max = 2000;
			RadiusSNew.Value = RadiusSOld;
			RadiusSNew.addEventListener(Event.CHANGE, OnParametersChange);
			// Угол наклона
			AngleNewTxt = new VnText();
			AngleNewTxt.Color = SC.BLACK;
			AngleNewTxt.Text = TextDictionary.Text(192);	// "Угол наклона"
			addChild(AngleNewTxt);
			AngleNewTxt.x = 40;
			AngleNewTxt.y = 100;
			AngleNew = new EditN();
			RadiusSNew.Type = EditN.TYPE_UINT;
			addChild(AngleNew);
			AngleNew.MoveIntoParent(200,110);
			AngleNew.Min = 0;
			AngleNew.Max = 360;
			AngleNew.Value = AngleOld;
			AngleNew.addEventListener(Event.CHANGE, OnParametersChange);
			// Скорость
			SpeedNewTxt = new VnText();
			SpeedNewTxt.Color = SC.BLACK;
			SpeedNewTxt.Text = TextDictionary.Text(57);	// "Скорость"
			addChild(SpeedNewTxt);
			SpeedNewTxt.x = 40;
			SpeedNewTxt.y = 130;
			SpeedNew = new EditN();
			SpeedNew.Type = EditN.TYPE_NUMBER;
			addChild(SpeedNew);
			SpeedNew.MoveIntoParent(200,140);
			SpeedNew.Value = SpeedOld;
			SpeedNew.Min = -10.0;
			SpeedNew.Max = 10.0;
			SpeedNew.IDVAlue = 0.001;
			SpeedNew.addEventListener(Event.CHANGE, OnParametersChange);
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		override public function _delete():void {
			// Деструктор
			// Большой радиус
			removeChild(RadiusLNewTxt);
			RadiusLNewTxt._delete();
			RadiusLNewTxt = null;
			removeChild(RadiusLNew);
			RadiusLNew._delete();
			RadiusLNew = null;
			// Малый радиус
			removeChild(RadiusSNewTxt);
			RadiusSNewTxt._delete();
			RadiusSNewTxt = null;
			removeChild(RadiusSNew);
			RadiusSNew._delete();
			RadiusSNew = null;
			// Угол наклона
			removeChild(AngleNewTxt);
			AngleNewTxt._delete();
			AngleNewTxt = null;
			removeChild(AngleNew);
			AngleNew._delete();
			AngleNew = null;
			// Скорость
			removeChild(SpeedNewTxt);
			SpeedNewTxt._delete();
			SpeedNewTxt = null;
			removeChild(SpeedNew);
			SpeedNew._delete();
			SpeedNew = null;
			// Деструктор предка
			super._delete();
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		override protected function GetPlace():Vector2 {
			// Местоположение по середине экрана на 5 пикс. от низа
			return new Vector2(VnObjectT(parent).Width05, VnObjectT(parent).Height-Height05-5);
		}
//-----------------------------------------------------------------------------------------------------
		override protected function SetCheckingOnServerParameters():void {
			// Установка параметров скрипта для проверки на сервере
			AddServerParameter("Id",String(Owner.Id));				// Id орбиты (user_starsystem_id)
			AddServerParameter("RadiusL",String(RadiusLNew.Value));	// Большой радиус
			AddServerParameter("RadiusS",String(RadiusSNew.Value));	// Малый радиус
			AddServerParameter("Angle",String(AngleNew.Value));		// Угол
			AddServerParameter("Speed",String(SpeedNew.Value));		// Скорость
		}
//-----------------------------------------------------------------------------------------------------
		private function ResetParameters():void {
			// Вернуть параметры к прежним
			Owner.SetAngle(AngleOld);					// Сначала угол, потом радиусы (иначе неправильно пересчитывает поворот орбиты - пытается повернуться вокруг уже изменившегося центра)
			Owner.SetRadius(RadiusLOld, RadiusSOld);
			Owner.SetSpeed(SpeedOld);
		}
//-----------------------------------------------------------------------------------------------------
		override protected function Declined():void {
			// Условие НЕ принято
			ResetParameters();
			Close();	// Закрыть окно
		}
//-----------------------------------------------------------------------------------------------------
		override protected function Accepted(Data:XML):void {
			// Условие принято
			RadiusLOld = Owner.RadiusL;	// Сделать старые параметры = текущиим, чтобы при закрытии окна не было сброса
			RadiusSOld = Owner.RadiusS;
			AngleOld = Owner.Angle;
			SpeedOld = Owner.Speed;
			Close();	// Закрыть окно
		}
//-----------------------------------------------------------------------------------------------------
// Обработка событий
//-----------------------------------------------------------------------------------------------------
		private function OnParametersChange(e:Event):void {
			// При изменении параметров
			// Применить к орбите
			Owner.SetRadius(RadiusLNew.Value, RadiusSNew.Value);
			Owner.SetAngle(AngleNew.Value);
			Owner.SetSpeed(SpeedNew.Value);
		}
//-----------------------------------------------------------------------------------------------------
		override protected function OnApplicationResize(e:EvAppResize):void {
			// Отработка при изменении размеров окна приложения
			RePlace();	// Сохранить местоположение
		}
//-----------------------------------------------------------------------------------------------------
		override protected function OnClose():void {
			// При закрытии окна
			ResetParameters();
		}
//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------

//-----------------------------------------------------------------------------------------------------
	}
}