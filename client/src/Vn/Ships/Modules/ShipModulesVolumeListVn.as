package Vn.Ships.Modules {
//-----------------------------------------------------------------------------------------------------
// Страничный компонент со списком типов модулей на корабле и их объемов
//-----------------------------------------------------------------------------------------------------
	import Vn.Interface.List.ImageList;
	import Vn.Math.Vector2;
	import Vn.Ships.Ship;
//-----------------------------------------------------------------------------------------------------
	public class ShipModulesVolumeListVn extends ImageList {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function ShipModulesVolumeListVn(vSize:Vector2) {
			// Конструктор предка
			super(vSize);
			// Конструктор
			
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
		public function Load(vShip:Ship):void {
			// Загрузка данных по модулям на корабле vShip
			Clear();	// Очистить, что что уже было
			for each (var CurrentModule:ShipModule in vShip.ModulesManager.All) {
//				if (CurrentModule.Type != "DD") {	// Модуль прочности не нужен для торговли
					var CurrenIndicator:ShipModuleIndicator = CurrentModule.GetModuleIndicator();
					if(Length>0) {
						var AlreadyInList:Boolean = false;
						for each (var CInd:ShipModuleIndicator in Objects) {
							if (CInd.Owner.Type == CurrenIndicator.Owner.Type) {
								CInd.FreeVolume += CurrenIndicator.FreeVolume;
								AlreadyInList = true;
								CurrenIndicator._delete();
								break;
							}
						}
						if (AlreadyInList == false) Add(CurrenIndicator);
					}
					else Add(CurrenIndicator);
//				}
			}
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