package Vn.Common {
//-----------------------------------------------------------------------------------------------------
	// Класс - список всех динамически создаваемых объектов.
	// Необходим т.к. функция getDefinitionByName не может создать объект не встроенного во флеш класса
	// если этот класс не включен в проект. Включение в проект обеспечивается упоминанием класса в коде.
	// При появлении нового класса - прописать его имя в функции.
//-----------------------------------------------------------------------------------------------------
	import Vn.Ships.Modules.ShipModuleDD;
	import Vn.Ships.Modules.ShipModuleTU;
	import Vn.Ships.Modules.ShipModuleTF;
	import Vn.SpaceObjects.Orbit.OrbitR;
	import Vn.SpaceObjects.Orbit.OrbitV;
	import Vn.SpaceObjects.Planets.PlanetR;
	import Vn.SpaceObjects.Planets.PlanetV;
	import Vn.SpaceObjects.Stars.StarR;
	import Vn.SpaceObjects.Stars.StarV;
	import Vn.SpaceObjects.Stations.StationR;
	import Vn.SpaceObjects.Stations.StationV;
	import Vn.SpaceObjects.Stations.Shipyard.ShipyardR;
	import Vn.SpaceObjects.Stations.Shipyard.ShipyardV;
	import Vn.Quests.Conditions.QuestConditionFlyVn;
	import Vn.Quests.Conditions.QuestConditionBuyCargoVn;
	import Vn.Quests.Conditions.QuestConditionSellCargoVn;
	import Vn.Quests.Conditions.QuestConditionLevelUpVn;
//-----------------------------------------------------------------------------------------------------
	public class DynamicObjectsVn {
// Переменные
//-----------------------------------------------------------------------------------------------------
		private static var FullNameClasses:Object;	// Список классов с полными именами, включая путь к пакету
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function DynamicObjectsVn() {
			super();
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		public function _delete():void {
			super._delete();
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		private static function VnDynamicObjectsList():void {
			// Функция, которая нигде никогда не вызывается.
			// Просто хранит в себе перечень классов для вызова getDefinitionByName в проекте
			OrbitR;				// Орбита
			OrbitV;
			PlanetR;			// Планета
			PlanetV;
			StarR;				// Звезда
			StarV;
			StationR;			// Станция
			StationV;
			ShipyardR;			// Верфь
			ShipyardV;
			// Квестовые условия
			QuestConditionFlyVn;				// Fly
			QuestConditionBuyCargoVn;			// BuyCargo
			QuestConditionSellCargoVn;			// SellCargo
			QuestConditionLevelUpVn;			// LevelUp
			// Модули корабля
			ShipModuleDD;		// Детектор повреждений
			ShipModuleTU;		// Танк универсальный
			ShipModuleTF;		// Танк топливный
		}
//-----------------------------------------------------------------------------------------------------
		public static function Init():void {
			// Инициализация списка классов
			// Так как getDefinitionByName требует полного указания имени класса с пакетом - указать пакеты
			if (FullNameClasses == null) {
				FullNameClasses = new Object();
				FullNameClasses["OrbitR"] = "Vn.SpaceObjects.Orbit.OrbitR";
				FullNameClasses["OrbitV"] = "Vn.SpaceObjects.Orbit.OrbitV";
				FullNameClasses["PlanetR"] = "Vn.SpaceObjects.Planets.PlanetR";
				FullNameClasses["PlanetV"] = "Vn.SpaceObjects.Planets.PlanetV";
				FullNameClasses["StarR"] = "Vn.SpaceObjects.Stars.StarR";
				FullNameClasses["StarV"] = "Vn.SpaceObjects.Stars.StarV";
				FullNameClasses["StationR"] = "Vn.SpaceObjects.Stations.StationR";
				FullNameClasses["StationV"] = "Vn.SpaceObjects.Stations.StationV";
				FullNameClasses["ShipyardR"] = "Vn.SpaceObjects.Stations.Shipyard.ShipyardR";
				FullNameClasses["ShipyardV"] = "Vn.SpaceObjects.Stations.Shipyard.ShipyardV";
				FullNameClasses["Fly"] = "Vn.Quests.Conditions.QuestConditionFlyVn";
				FullNameClasses["BuyCargo"] = "Vn.Quests.Conditions.QuestConditionBuyCargoVn";
				FullNameClasses["SellCargo"] = "Vn.Quests.Conditions.QuestConditionSellCargoVn";
				FullNameClasses["LevelUp"] = "Vn.Quests.Conditions.QuestConditionLevelUpVn";
				FullNameClasses["ShipModuleDD"] = "Vn.Ships.Modules.ShipModuleDD";
				FullNameClasses["ShipModuleTU"] = "Vn.Ships.Modules.ShipModuleTU";
				FullNameClasses["ShipModuleTF"] = "Vn.Ships.Modules.ShipModuleTF";
			}
		}
//-----------------------------------------------------------------------------------------------------
		public static function FullName(vName:String):String {
			// Возврат полного имени класса (с пакетом)
			if (FullNameClasses != null) {
				if (FullNameClasses[vName] != null && FullNameClasses[vName] != undefined) {
					return FullNameClasses[vName];
				}
			}
			return vName;
		}
//-----------------------------------------------------------------------------------------------------
	}
}