package Vn.Virtual.Prizes {
//-----------------------------------------------------------------------------------------------------
// Окно со списком призов
//-----------------------------------------------------------------------------------------------------
	import Vn.Interface.Window.VnWindowB;
	import Vn.Math.Vector2;
	import Vn.Objects.VnObjectT;
	import Vn.Scene.StarSystem.StarSystemVirtualVn;
	import Vn.Text.TextDictionary;
	import Vn.Virtual.Prizes.PrizesImageListVn;
	import Vn.Vn.Events.EvAppResize;
	import Vn.Interplanety;
//-----------------------------------------------------------------------------------------------------
	public class PrizesWindowVn extends VnWindowB {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		private var lImageList:PrizesImageListVn;	// Страничный компонент для размещения пиктограмм призов
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function PrizesWindowVn() {
			// Конструктор предка
			super();
			// Конструктор
			Name = 185;
			Caption.Text = TextDictionary.Text(Name);
			Sizeable = true;
			SetLocalPosition(Vn.Interplanety.Width / 2.0 - 30, Vn.Interplanety.Height / 6.0);
			// Список призов
			lImageList = new PrizesImageListVn(new Vector2(Width,Height-WorkSpace.Y));	// - заголовок окна
			addChild(lImageList);
			lImageList.MoveIntoParent(Width05,WorkSpace.Y+WorkSpace.Height05,true);
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		override public function _delete():void {
			// Деструктор
			// Убрать страничный компонент
			removeChild(lImageList);
			lImageList._delete();
			lImageList = null;
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
		override protected function ReSize(NewSize:Vector2=null):void {
			// Изменить размеры
			super.ReSize(NewSize);
			// Изменить размеры компонентов
			if (lImageList != null) {
				lImageList.ReSize(new Vector2(Width,Height-WorkSpace.Y));
				lImageList.MoveIntoParent(Width05,WorkSpace.Y+WorkSpace.Height05,true);
			}
		}
//-----------------------------------------------------------------------------------------------------
// Обработка событий
//-----------------------------------------------------------------------------------------------------
		override protected function OnApplicationResize(e:EvAppResize):void {
			// Отработка при изменении размеров окна
			// Размеры: ширина - по ширине окна минус 5 пикс по бокам
			ReSize(new Vector2(e.NewWidth - 60, e.NewHeight / 3.0));
		}
//-----------------------------------------------------------------------------------------------------
		override protected function OnClose():void {
			// Перевести систему в режим VIEW
			if(Interplanety.Universe!=null) {
				if (StarSystemVirtualVn(Interplanety.Universe.CurrentStarSystem).Mode == StarSystemVirtualVn.MODE_ADD) StarSystemVirtualVn(Interplanety.Universe.CurrentStarSystem).Mode = StarSystemVirtualVn.MODE_VIEW;
			}
			super.OnClose();
			}
//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------

//-----------------------------------------------------------------------------------------------------
	}
}