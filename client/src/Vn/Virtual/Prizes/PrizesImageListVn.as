package Vn.Virtual.Prizes {
//-----------------------------------------------------------------------------------------------------
// Страничный компонент со списком иконок с призами
//-----------------------------------------------------------------------------------------------------
	import flash.events.Event;
	import Vn.Interface.List.ImageList;
	import Vn.Math.Vector2;
	import Vn.Scene.StarSystem.StarSystemVirtualVn;
	import Vn.Virtual.Prizes.PrizeIconVn;
	import Vn.Virtual.Prizes.Events.PrizeManagerEventVn;
	import Vn.Interplanety;
//-----------------------------------------------------------------------------------------------------
	public class PrizesImageListVn extends ImageList {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		private var lPrizesManager:PrizesManagerVn;	// Указатель на менеджер призов
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function PrizesImageListVn(Size:Vector2) {
			// Конструктор предка
			super(Size);
			// Конструктор
			lPrizesManager = StarSystemVirtualVn(Vn.Interplanety.Universe.CurrentStarSystem).PrizesManager;
			// Слушать PrizeManager на предмет дозагрузки призов
			lPrizesManager.addEventListener(PrizesManagerVn.PRIZES_LOAD_SUCCESS,OnPrizesLoaded);
			lPrizesManager.addEventListener(PrizeManagerEventVn.FROM_STORAGE_TO_OBJECT_FAIL, OnPrizeFromStorageToObjectFail);
			lPrizesManager.addEventListener(PrizeManagerEventVn.FROM_STORAGE_TO_OBJECT_SUCCESS, OnPrizeFromStorageToObjectSuccess);
			// Создать пиктограммы для уже загруженных призов
			CreatePrizesIcons();
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		override public function _delete():void {
			// Деструктор
			lPrizesManager.removeEventListener(PrizeManagerEventVn.FROM_STORAGE_TO_OBJECT_SUCCESS, OnPrizeFromStorageToObjectSuccess);
			lPrizesManager.removeEventListener(PrizeManagerEventVn.FROM_STORAGE_TO_OBJECT_FAIL, OnPrizeFromStorageToObjectFail);
			lPrizesManager.removeEventListener(PrizesManagerVn.PRIZES_LOAD_SUCCESS, OnPrizesLoaded);
			lPrizesManager = null;
			// Деструктор предка
			super._delete();
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
/*		override protected function ShowCurrentPage():void {
			// Контроль дозагрузки при выводе очередной страницы
			// Если страница последняя (элементов на странице меньше чем всего на ней помещается)
			if (CurrentPageEndInd() - CurrentPageStartInd() < ElementsG * ElementsV) {
				// И призов в списке меньше чем всего у пользователя
//				if (Amount < lPrizesManager.TotalPrizes) {
//					lPrizesManager.LoadPrizesBlock();
//				}
			}
			// Обновить страницу
			super.ShowCurrentPage();
		}*/
//-----------------------------------------------------------------------------------------------------
		private function CreatePrizesIcons():void {
			// Создание пиктограмм для призов по списку
			var AllPrizes:Array = lPrizesManager.Prizes;	// Список призов
			for (var i:uint = Length; i < AllPrizes.length; i++) {
				if (GetById(AllPrizes[i].SpaceObjectId) == null) {
					// Добавляем только с уникальными Id (используется SpaceObjectId)
					var CurrentIcon:PrizeIconVn = new PrizeIconVn(PrizeVn(AllPrizes[i]));
					AddWithoutRefresh(CurrentIcon);
				}
			}
			Refresh();
		}
//-----------------------------------------------------------------------------------------------------
// Обработка событий
//-----------------------------------------------------------------------------------------------------
		private function OnPrizesLoaded(e:Event):void {
			// Произошла дозагрузка призов
			// Добавить в список дозагруженный блок
			CreatePrizesIcons();
		}
//-----------------------------------------------------------------------------------------------------
		private function OnPrizeFromStorageToObjectSuccess(e:PrizeManagerEventVn):void {
			// Приз сконвертирован из хранилища в объект системы
			// Убрать из списка
			for (var i:uint = 0; i < Length; i++) {
				if (Objects[i].Id == e.Data) {
					DeleteById(e.Data);	// Refresh вызывается при удалении
				}
			}
		}
//-----------------------------------------------------------------------------------------------------
		private function OnPrizeFromStorageToObjectFail(e:Event):void {
			// Ошибка конвертации приза из хранилища в объект системы
			// Обновить список
			Refresh();
		}
//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------
/*		public function get Amount():uint {
			// Количество призов
			// Считается не как количество в списке т.к. призы могут быть стековыми
			var Amount:uint = 0;
			for (var i:uint = 0; i < Length; i++) {
				Amount += PrizeIconVn(Objects[i]).StackAmount;
			}
			return Amount;
		}*/
//-----------------------------------------------------------------------------------------------------
	}
}