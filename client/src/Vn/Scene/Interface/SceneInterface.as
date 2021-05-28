package Vn.Scene.Interface {
// Класс Инетрфейс сцены
//-----------------------------------------------------------------------------------------------------
	import flash.events.Event;
	import flash.events.MouseEvent;
	import Vn.Common.SC;
	import Vn.Math.Vector2;
	import Vn.Scene.StarSystem.VirtualStarSystemButton;
	import Vn.Objects.VnObjectU;
	import Vn.Options.OptionsButton;
	import Vn.Quests.Journal.JournalButton;
	import Vn.ScreenShot.ScreenShotButtonVn;
	import Vn.Ships.ShipsButton;
	import Vn.User.User;
	import Vn.User.Attributes.Gold;
	import Vn.User.Attributes.Crystals;
	import Vn.User.Attributes.Experience;
	import Vn.Virtual.Prizes.PrizesButtonMDVn;
	import Vn.Virtual.Prizes.PrizesButtonVn;
	import Vn.Interplanety;
//-----------------------------------------------------------------------------------------------------
	public class SceneInterface extends VnObjectU {	// Интерфейс сцены
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		protected var MoneyInd:MoneyInfo;		// Индикатор денег
		protected var CrystalsInd:CrystalsInfo;	// Индикатор кристаллов
		protected var LevelInd:LevelInfo;		// Индикатор уровня
		protected var OptionsBtn:OptionsButton;	// Кнопка настроек
		protected var ShipsBtn:ShipsButton;		// Кнопка кораблей
		protected var JournalBtn:JournalButton;	// Кнопка бортового журнала
		protected var l_VUButton:VirtualStarSystemButton;	// Кнопка "Виртуальная вселенная"
		protected var ExitBtn:ExitButton;		// Кнопка выхода
		protected var SCBtn:SceneCenterButton;	// Кнопка центрирования сцены
		protected var l_PrizesButton:PrizesButtonVn;	// Кнопка "Призы"
		protected var lPrizesButtonMD:PrizesButtonMDVn;	// Контейнер с кнопками "удалить приз" и "изменить параметры приза"
		protected var lScreenShotButton:ScreenShotButtonVn;	// Кнопка "Создать скриншот"
		// Константы событий
		public static const LOADED:String = "EvSceneInterfaceLoaded";	// Идентификатор "нитерфейс сцены загружен"
		public static const FAIL:String = "EvSceneInterfaceFail";		// Идентификатор "интерфейс сценаы НЕ загружен"
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function SceneInterface() {
			// Конструктор предка
			super();
			// Конструктор
			// Основные переменные
			Name = 105;
			// Размеры = сцене
			SetLocalPosition(Vn.Interplanety.Width/2.0,Vn.Interplanety.Height/2.0);
			// Объекты интерфейса
			MoneyInd = null;
			CrystalsInd = null;
			LevelInd = null;
			OptionsBtn = null;
			ShipsBtn = null;
			JournalBtn = null;
			l_VUButton = null;
			l_PrizesButton = null;
			lPrizesButtonMD = null;
			lScreenShotButton = null;
			ExitBtn = null;
			SCBtn = null;
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		override public function _delete():void {
			// Деструктор
			// Индикатор денег
			if(MoneyInd!=null) {
				removeChild(MoneyInd);
				MoneyInd._delete();
				MoneyInd = null;
			}
			// Индикатор кристаллов
			if(CrystalsInd!=null) {
				removeChild(CrystalsInd);
				CrystalsInd._delete();
				CrystalsInd = null;
			}
			// Индикатор уровня
			if(LevelInd!=null) {
				removeChild(LevelInd);
				LevelInd._delete();
				LevelInd = null;
			}
			// Кнопка настроек
			if(OptionsBtn!=null) {
				removeChild(OptionsBtn);
				OptionsBtn._delete();
				OptionsBtn = null;
			}
			// Кнопка кораблей
			if(ShipsBtn!=null) {
				removeChild(ShipsBtn);
				ShipsBtn._delete();
				ShipsBtn = null;
			}
			// Кнопка бортового журнала
			if(JournalBtn!=null) {
				removeChild(JournalBtn);
				JournalBtn._delete();
				JournalBtn = null;
			}
			// Кнопка "Виртуальная вселенная"
			if(l_VUButton!=null) {
				removeChild(l_VUButton);
				l_VUButton._delete();
				l_VUButton = null;
			}
			// Кнопка "Виртуальные призы"
			if(l_PrizesButton!=null) {
				removeChild(l_PrizesButton);
				l_PrizesButton._delete();
				l_PrizesButton = null;
			}
			// Кнопки удаления/изменения параметров призов
			if(lPrizesButtonMD!=null) {
				removeChild(lPrizesButtonMD);
				lPrizesButtonMD._delete();
				lPrizesButtonMD = null;
			}
			// Кнопка "Скриншот"
			if(lScreenShotButton!=null) {
				removeChild(lScreenShotButton);
				lScreenShotButton._delete();
				lScreenShotButton = null;
			}
			// Кнопка центрирования сцены
			if(SCBtn!=null) {
				removeChild(SCBtn);
				SCBtn._delete();
				SCBtn = null;
			}
			// Кнопка выхода
			if(ExitBtn!=null) {
				removeChild(ExitBtn);
				ExitBtn._delete();
				ExitBtn = null;
			}
			// Деструктор предка
			super._delete();
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		public function Load():void {
			// Загрузка интерфейса
			// Кнопка "Выход"
			ExitBtn = new ExitButton();
			addChild(ExitBtn);
			// Кнопка "Центрирование сцены"
			SCBtn = new SceneCenterButton();
			addChild(SCBtn);
			// Индикатор денег
			MoneyInd = Gold.CreateIndicator();
			addChild(MoneyInd);
			Vn.Interplanety.VnUser.dispatchEvent(new Event(User.GOLD_CHANGED));	// Для обновления значения (т.к. индикатор создается после юзера)
			// Индикатор кристаллов
			CrystalsInd = Crystals.CreateIndicator();
			addChild(CrystalsInd);
			Vn.Interplanety.VnUser.dispatchEvent(new Event(User.CRYSTALS_CHANGED));	// Для обновления значения (т.к. индикатор создается после юзера)
			// Индикатор уровня
			LevelInd = Experience.CreateIndicator();
			addChild(LevelInd);
			Vn.Interplanety.VnUser.dispatchEvent(new Event(User.EXP_CHANGED));	// Для обновления значения (т.к. индикатор создается после юзера)
			// Кнопка настроек
			OptionsBtn = new OptionsButton();
			addChild(OptionsBtn);
			// Кнопка кораблей
			ShipsBtn = new ShipsButton();
			addChild(ShipsBtn);
			// Кнопка бортового журнала
			JournalBtn = new JournalButton();
			addChild(JournalBtn);
			// Кнопка "Виртуальная вселенная"
			l_VUButton = new VirtualStarSystemButton();
			addChild(l_VUButton);
			// Разместить
			Resize();
			// Все загружено
			OnComplete(null);
		}
//-----------------------------------------------------------------------------------------------------
		public function Resize():void {
			// Переставить элементы интерфейса в зависимости от нового размера игровой области
			SetLocalPosition(Vn.Interplanety.Width/2.0,Vn.Interplanety.Height/2.0);
			// Кнопка "Выход"
			if(ExitBtn!=null) ExitBtn.MoveInto(new Vector2(Width-ExitBtn.Width05-SC.ScrollBorder,ExitBtn.Height05+SC.ScrollBorder));
			// Кнопка "Центрирование сцены"
			if(SCBtn!=null) SCBtn.MoveInto(new Vector2(ExitBtn.GetPosition().X-SCBtn.Width-5.0,ExitBtn.GetPosition().Y));	// Слева от ExitBtn
			// Индикатор денег
			if(MoneyInd!=null) MoneyInd.MoveInto(new Vector2(150,15));
			// Индикатор кристаллов
			if(CrystalsInd!=null) CrystalsInd.MoveInto(new Vector2(300,15));
			// Индикатор уровня
			if(LevelInd!=null) LevelInd.MoveInto(new Vector2(470,15));
			// Кнопка настроек
			if(OptionsBtn!=null) OptionsBtn.MoveInto(new Vector2(Vn.Interplanety.Width-38,90));
			// Кнопка кораблей
			if(ShipsBtn!=null) ShipsBtn.MoveInto(new Vector2(Vn.Interplanety.Width-38,130));
			// Кнопка бортового журнала
			if(JournalBtn!=null) JournalBtn.MoveInto(new Vector2(Vn.Interplanety.Width-38,170));
			// Кнопка "Виртуальная вселенная"
			if(l_VUButton!=null) l_VUButton.MoveInto(new Vector2(Vn.Interplanety.Width-38,210));
			// Кнопка "Виртуальные призы"
			if(l_PrizesButton!=null) l_PrizesButton.MoveInto(new Vector2(Vn.Interplanety.Width-38,250));
			// Кнопки удаления/изменения параметров призов
			if (lPrizesButtonMD != null) lPrizesButtonMD.MoveInto(new Vector2(Interplanety.Width - 38, 290));
			// Кнопка "Скриншот"
			if(lScreenShotButton!=null) lScreenShotButton.MoveInto(new Vector2(Vn.Interplanety.Width-38,330));
		}
//-----------------------------------------------------------------------------------------------------
		override public function Update():void {
			// Обновление
			// Обновляем только корабли (для проигрыша анимации)
			if (ShipsBtn != null) ShipsBtn.Update();	// Кнопка кораблей
		}
//-----------------------------------------------------------------------------------------------------
		public function DisableRealStarSystemButtons():void {
			// Заблокировать кнопки для Реальной звездной системы
			if (ShipsBtn.Enabled == true) ShipsBtn.Enabled = false;	// Корабли
			// Показать кнопки для виртуальной системы
			ShowVirtualStarSystemInterface();
		}
//-----------------------------------------------------------------------------------------------------
		public function EnableRealStarSystemButtons():void {
			// Разблокировать кнопки для Реальной звездной системы
			if (ShipsBtn.Enabled == false) ShipsBtn.Enabled = true;	// Корабли
			// Удалить кнопки для виртуальной системы
			HideVirtualStarSystemInterface();
		}
//-----------------------------------------------------------------------------------------------------
		private function ShowVirtualStarSystemInterface():void {
			// Показ кнопок интерфейся виртуальной звездной системы
			// Смотрим по кнопке призов
			if(l_PrizesButton==null) {
				l_PrizesButton = new PrizesButtonVn();
				addChild(l_PrizesButton);
				lPrizesButtonMD = new PrizesButtonMDVn();
				addChild(lPrizesButtonMD);
				lPrizesButtonMD.addEventListener(MouseEvent.CLICK, OnPrizesButtonMDClick);
				lScreenShotButton = new ScreenShotButtonVn();
				addChild(lScreenShotButton);
				Resize();
			}
		}
//-----------------------------------------------------------------------------------------------------
		private function HideVirtualStarSystemInterface():void {
			// Скрытие кнопок интерфейся виртуальной звездной системы
			if (l_PrizesButton != null) {
				removeChild(l_PrizesButton);
				l_PrizesButton._delete();
				l_PrizesButton = null;
				lPrizesButtonMD.removeEventListener(MouseEvent.CLICK, OnPrizesButtonMDClick);
				removeChild(lPrizesButtonMD);
				lPrizesButtonMD._delete();
				lPrizesButtonMD = null;
				removeChild(lScreenShotButton);
				lScreenShotButton._delete();
				lScreenShotButton = null;
				Resize();
			}
		}
//-----------------------------------------------------------------------------------------------------
// Обработка событий
//-----------------------------------------------------------------------------------------------------
		protected function OnComplete(e:Event):void {
			// Данные интерфейса загружены
			dispatchEvent(new Event(SceneInterface.LOADED));
		}
//-----------------------------------------------------------------------------------------------------
		protected function OnIoError(e:Event):void {
			// Ошибка получения данных интерфейса
			dispatchEvent(new Event(SceneInterface.FAIL));
		}
//-----------------------------------------------------------------------------------------------------
		private function OnPrizesButtonMDClick(e:MouseEvent):void {
			// Щелчок по кнопке удаления/изменения объектов виртуальной системы
			// Если было открыто окно призов - закрыть
			if (l_PrizesButton.WindowShown == true) l_PrizesButton.Window.Close();
		}
//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------
		public function get PrizesButtonMD():PrizesButtonMDVn {
			// Контейнер с управляющими кнопками призов
			return lPrizesButtonMD;
		}
//-----------------------------------------------------------------------------------------------------
	}
}