package Vn.User {
//-----------------------------------------------------------------------------------------------------
// Класс User - пользователь
// Расширяем EventDispatcher чтобы генерировать события
//-----------------------------------------------------------------------------------------------------
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.EventDispatcher;
	import flash.system.System;
	import Vn.System.PHPLoader;
	import Vn.User.Attributes.Experience;
	import Vn.User.Attributes.Crystals;
	import Vn.User.Attributes.Gold;
	import Vn.User.Skin.SkinVn;
//-----------------------------------------------------------------------------------------------------
	public class User extends EventDispatcher {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		protected var UsLogin:String;		// Логин пользователя
		protected var UsId:uint;			// Id пользователя
		protected var UsType:String;		// Тип аккаунта пользователя (F,P,R)
		protected var UsLang:String;		// Язык пользователя
		// Настройки
		protected var UsShowOrbits:Boolean;	// Показывать орбиты
		private var lUserSkin:SkinVn;			// Цветовой "скин" пользователя
		// Данные
		private var UsExp:Experience;		// Опыт
		private var UsMoney:Gold;		// Деньги
		private var UsCrystals:Crystals;	// Кристаллы
		// Объект для обращения к скриптам PHP
		protected var InfoLoader:PHPLoader;		// Загрузка/сохранение данных
		// Константы событий
		public static const INFO_LOADED:String = "EvUserInfoLoaded";	// Идентификатор "данные о пользователе загружены"
		public static const INFO_FAIL:String = "EvUserInfoFail";		// Идентификатор "данные о пользователе НЕ загружены"
		public static const SHOW_ORBITS_CHANGE:String = "EvUserShowOrbitsChange";	// Идентификатор "изменился показ орбит"
		public static const LEVEL_UP:String = "EvUserLevelUp";	// Идентификатор "рост уровня"
		public static const CRYSTALS_CHANGED:String = "EvUserCrystalsChanged";	// Изменилось кол-во кристаллов
		public static const GOLD_CHANGED:String = "EvUserGoldChanged";	// Изменилось кол-во золота
		public static const EXP_CHANGED:String = "EvUserExpChanged";	// Изменилось кол-во опыта
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function User() {
			// Конструктор предка
			super();
			// Конструктор
			UsLogin = "";
			UsId = 0;
			UsType = "F";
			UsLang = "rus";
			InfoLoader = new PHPLoader();
			UsMoney = new Gold();
			UsCrystals = new Crystals();
			UsExp = new Experience();
			// Настройки
			ShowOrbits = true;
			lUserSkin = new SkinVn();
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		public function _delete():void {
			// Деструктор
			UsMoney._delete();
			UsMoney = null;
			UsCrystals._delete();
			UsCrystals = null;
			UsExp._delete();
			UsExp = null;
			lUserSkin._delete();
			lUserSkin = null;
			// Загрузчик
			if(InfoLoader!=null) {
				if(InfoLoader.hasEventListener(Event.COMPLETE)) InfoLoader.removeEventListener(Event.COMPLETE,OnComplete);
				if(InfoLoader.hasEventListener(IOErrorEvent.IO_ERROR)) InfoLoader.removeEventListener(IOErrorEvent.IO_ERROR,OnIoError);
				InfoLoader._delete();
				InfoLoader = null;
			}
			// Деструктор предка
//			super._delete();
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		public function GetInfo(Script:String):void {
			// Получить данные о пользователе через серверный скрипт Script на PHP
			InfoLoader.addEventListener(Event.COMPLETE,OnComplete);
			InfoLoader.addEventListener(IOErrorEvent.IO_ERROR,OnIoError);
			InfoLoader.Load(Script);
		}
//-----------------------------------------------------------------------------------------------------
		public function SaveOptions(Script:String):void {
			// Сохранить настройки пользователя через серверный скрипт Script на PHP
			// Показ орбит
			var ShowOrb:String = "T";
			if(ShowOrbits==false) ShowOrb = "F";
			InfoLoader.AddVariable("show_orb",ShowOrb);
			// Передать на сервер
			InfoLoader.Load(Script);
		}
//-----------------------------------------------------------------------------------------------------
		public function ChangeFinance(Count:int,Type:String):void {
			// Изменить деньги/кристаллы на количество Count
			if(Type=="C") CrystalsCount += Count;
			else MoneyCount += Count;
		}
//-----------------------------------------------------------------------------------------------------
		public function RefreshCrystals():void {
			// Обновить количество кристаллов из базы
			UsCrystals.Refresh();
		}
//-----------------------------------------------------------------------------------------------------
		public function RefreshGold():void {
			// Обновить количество золота из базы
			UsMoney.Refresh();
		}
//-----------------------------------------------------------------------------------------------------
		public function RefreshExp():void {
			// Обновить количество опыта из базы
			UsExp.Refresh();
		}
//-----------------------------------------------------------------------------------------------------
// Обработка событий
//-----------------------------------------------------------------------------------------------------
		protected function OnComplete(e:Event):void {
			// Данные о пользователе получены
			try {
				var UserData:XML = new XML(e.target.data);
			}
			catch(e1:Error) {
				trace(e.target.data);
			}
			for each (var Node:XML in UserData.*) {
				if(Node.nodeKind()=="element") {
					if(Node.name()=="UserInfo") {	// UserInfo
						Id = Node.child("id");
						Login = Node.child("login");
						Type = Node.child("rights");
						Lang = Node.child("lang");
					}
					if(Node.name()=="UserOptions") {	// UserOptions
						if(Node.child("show_orb")=="T") ShowOrbits = true;
						else ShowOrbits = false;
					}
					if(Node.name()=="UserData") {	// UserData
						Level = Node.child("level");
						NextLevelExp = Node.child("next_level_exp");
						ExpCount = Node.child("exp");
						MoneyCount = Node.child("money");
						CrystalsCount = Node.child("crystals");
					}
				}
			}
			System.disposeXML(UserData);
			// Отсоединить слушатели и отправить событие загрузки данных пользователя
			InfoLoader.removeEventListener(Event.COMPLETE,OnComplete);
			InfoLoader.removeEventListener(IOErrorEvent.IO_ERROR,OnIoError);
			dispatchEvent(new Event(User.INFO_LOADED));
		}
//-----------------------------------------------------------------------------------------------------
		protected function OnIoError(e:Event):void {
			// Ошибка получения данных о пользователе - выход
			InfoLoader.removeEventListener(Event.COMPLETE,OnComplete);
			InfoLoader.removeEventListener(IOErrorEvent.IO_ERROR,OnIoError);
			dispatchEvent(new Event(User.INFO_FAIL));
		}
//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------
		public function get Login():String {
			return UsLogin;
		}
//-----------------------------------------------------------------------------------------------------
		public function set Login(Value:String):void {
			UsLogin = Value;
		}
//-----------------------------------------------------------------------------------------------------
		public function get Id():uint {
			return UsId;
		}
//-----------------------------------------------------------------------------------------------------
		public function set Id(Value:uint):void {
			UsId = Value;
		}
//-----------------------------------------------------------------------------------------------------
		public function get Type():String {
			return UsType;
		}
//-----------------------------------------------------------------------------------------------------
		public function set Type(Value:String):void {
			UsType = Value;
		}
//-----------------------------------------------------------------------------------------------------
		public function get Lang():String {
			return UsLang;
		}
//-----------------------------------------------------------------------------------------------------
		public function set Lang(Value:String):void {
			UsLang = Value;
		}
//-----------------------------------------------------------------------------------------------------
		public function get ShowOrbits():Boolean {
			return UsShowOrbits;
		}
//-----------------------------------------------------------------------------------------------------
		public function set ShowOrbits(Value:Boolean):void {
			UsShowOrbits = Value;
			dispatchEvent(new Event(User.SHOW_ORBITS_CHANGE));
		}
//-----------------------------------------------------------------------------------------------------
		public function get Level():uint {
			return UsExp.Level;
		}
//-----------------------------------------------------------------------------------------------------
		public function set Level(Value:uint):void {
			if(Level!=Value) {
				// Изменение уровня
				UsExp.Level = Value;
			}
		}
//-----------------------------------------------------------------------------------------------------
		public function get ExpCount():uint {
			return UsExp.Count;
		}
//-----------------------------------------------------------------------------------------------------
		public function set ExpCount(Value:uint):void {
			UsExp.Count = Value;
			// Проверить на обновление квестов
		}
//-----------------------------------------------------------------------------------------------------
		public function get NextLevelExp():uint {
			return UsExp.NextLevel;
		}
//-----------------------------------------------------------------------------------------------------
		public function set NextLevelExp(Value:uint):void {
			UsExp.NextLevel = Value;
		}
//-----------------------------------------------------------------------------------------------------
		public function get MoneyCount():uint {
			return UsMoney.Count;
		}
//-----------------------------------------------------------------------------------------------------
		public function set MoneyCount(Value:uint):void {
			UsMoney.Count = Value;
		}
//-----------------------------------------------------------------------------------------------------
		public function get CrystalsCount():uint {
			return UsCrystals.Count;
		}
//-----------------------------------------------------------------------------------------------------
		public function set CrystalsCount(NewValue:uint):void {
			UsCrystals.Count = NewValue;
		}
//-----------------------------------------------------------------------------------------------------
		public function get Skin():SkinVn {
			// Указатель на skin пользователя
			return lUserSkin;
		}
//-----------------------------------------------------------------------------------------------------
	}
}