package Vn.Scene.StarSystem {
//-----------------------------------------------------------------------------------------------------
// Класс "Виртуальная звездная система"
//-----------------------------------------------------------------------------------------------------
	import flash.events.Event;
	import flash.events.EventPhase;
	import flash.events.MouseEvent;
	import flash.events.IOErrorEvent;
	import flash.system.System;
	import Vn.Events.EventVn;
	import Vn.Interface.Button.RadioButtonVn;
	import Vn.Math.Vector2;
	import Vn.Objects.VnObject;
	import Vn.SpaceObjects.Orbit.OrbitV;
	import Vn.SpaceObjects.SpaceObject;
	import Vn.SpaceObjects.InteractiveSpaceObjectV;
	import Vn.System.PHPLoader;
	import Vn.Text.TextDictionary;
	import Vn.Virtual.Prizes.PrizesManagerVn
	import Vn.Virtual.Prizes.Events.PrizeManagerEventVn;
	import Vn.Interplanety;
//-----------------------------------------------------------------------------------------------------
	public class StarSystemVirtualVn extends StarSystemVn {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		private var lPrizesManager:PrizesManagerVn;	// Менеджер призов
		private var lDeletingObject:SpaceObject;	// Удаляемый в данный момент объект (нельзя использовать OverObject т.к. он может смениться за время отклика от сервера)
		private var lDeletingScript:String;			// Скрипт для удаления объекта (конвертации объекта в приз)
		private var lDeletingConverter:PHPLoader;	// Конвертер для удаления объекта
		private var lReplaceScript:String;			// Скрипт для перемещения объекта
		private var lReplaceConverter:PHPLoader;	// Конвертер для перемещения объекта
		private var lMode:uint;						// Режим работы системы
		// Константы
		public static const MODE_VIEW:uint = 0;		// Стандартный режим (просмотр)
		public static const MODE_DELETE:uint = 1;	// Режим удаления объектов
		public static const MODE_MODIFY:uint = 2;	// Режим изменения параметров объектов
		public static const MODE_MOVE:uint = 3;		// Режим перемещения объектов
		public static const MODE_ADD:uint = 4;		// Режим добавления объектов
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function StarSystemVirtualVn() {
			// Конструктор родителя
			super();
			// Конструктор
			Id = 0;
			Name = 183;	// "Виртуальная вселенная"
			lMode = MODE_VIEW;	// Стандартный режим
			l_LoadScript = "getstarsystemvirtual.php";
			lPrizesManager = new PrizesManagerVn();
			lPrizesManager.addEventListener(PrizeManagerEventVn.FROM_STORAGE_TO_OBJECT_ADD_TO_SYSTEM, OnAddObjectToSystem);
			lDeletingObject = null;
			lDeletingScript = "convertprizeobjecttostorage.php";
			lDeletingConverter = null;
			lReplaceScript = "replaceprizeobject.php";
			lReplaceConverter = null;
			if (Interplanety.VnSceneI.PrizesButtonMD != null) Interplanety.VnSceneI.PrizesButtonMD.addEventListener(RadioButtonVn.CHANGED, OnPrizesButtonMDClick);	// Слушаем кнопки переключения режимов
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		override public function _delete():void {
			// Деструктор
			Clear();
			Mode = MODE_VIEW;	// Если были включены другие режимы - отключить
			Interplanety.VnSceneI.PrizesButtonMD.removeEventListener(RadioButtonVn.CHANGED, OnPrizesButtonMDClick);
			lPrizesManager.removeEventListener(PrizeManagerEventVn.FROM_STORAGE_TO_OBJECT_ADD_TO_SYSTEM, OnAddObjectToSystem);
			lPrizesManager._delete();
			lPrizesManager = null;
			lDeletingObject = null;
			if (lDeletingConverter != null) {
				if (lDeletingConverter.hasEventListener(Event.COMPLETE)) lDeletingConverter.removeEventListener(Event.COMPLETE, OnConvertObjectToStorageComplete);
				if (lDeletingConverter.hasEventListener(IOErrorEvent.IO_ERROR)) lDeletingConverter.removeEventListener(IOErrorEvent.IO_ERROR, OnConvertObjectToStorageError);
				lDeletingConverter._delete();
				lDeletingConverter = null;
			}
			if (lReplaceConverter != null) {
				if (lReplaceConverter.hasEventListener(Event.COMPLETE)) lReplaceConverter.removeEventListener(Event.COMPLETE, OnReplaceObjectComplete);
				if (lReplaceConverter.hasEventListener(IOErrorEvent.IO_ERROR)) lReplaceConverter.removeEventListener(IOErrorEvent.IO_ERROR, OnReplaceObjectError);
				lReplaceConverter._delete();
				lReplaceConverter = null;
			}
			// Деструктор родителя
			super._delete();
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		override public function Clear():void {
			// Очистка системы
			// Пока не сделан менеджер для виртуальных SpaceObject - все целиком удаляется
			// Если система в процессе загрузки - оборвать
			if (InfoLoader.hasEventListener(Event.COMPLETE)) InfoLoader.removeEventListener(Event.COMPLETE, OnComplete);
			if (InfoLoader.hasEventListener(IOErrorEvent.IO_ERROR)) InfoLoader.removeEventListener(IOErrorEvent.IO_ERROR, OnIoError);
			// Очистить список объектов с их удалением
			// Первый проход - поснимать из списка отображаемых объектов
			for(var i:uint=0;i<ObjectList.length;i++) {
				if(ObjectList[i]!=null&&ObjectList[i]!=undefined) {
					if(ObjectList[i].parent!=null) ObjectList[i].parent.removeChild(ObjectList[i]);
				}
			}
			// Второй проход - физически их удалить
			for(i=0;i<ObjectList.length;) {
				if(ObjectList[i]!=null&&ObjectList[i]!=undefined) {
					ObjectList[i]._delete();
					ObjectList.splice(i,1);
				}
			}
			// Очистка родителя
			super.Clear();
		}
//-----------------------------------------------------------------------------------------------------
		public function ConvertOverObjectToStorage(e:MouseEvent):void {
			// Сконвертировать объект (выделенный курсором) в приз: удалить из системы и поместить в хранилище
			// Удялять последовательно по одному объекту
			if (lDeletingObject == null && OverSpaceObject != null) {
				lDeletingObject = OverSpaceObject;
				lDeletingConverter = new PHPLoader();
				lDeletingConverter.AddVariable("Id", String(lDeletingObject.Id));	// Id объекта в виртуальной системе
				lDeletingConverter.addEventListener(Event.COMPLETE, OnConvertObjectToStorageComplete);
				lDeletingConverter.addEventListener(IOErrorEvent.IO_ERROR, OnConvertObjectToStorageError);
				lDeletingConverter.Load(lDeletingScript);
			}
		}
//-----------------------------------------------------------------------------------------------------
		public function MoveObject(e:EventVn):void {
			lReplaceConverter = new PHPLoader();
			var NewPos:Vector2 = CoordinatesInSystemByScreen(e.Data[1]);	// Преобразовать координаты из экранных в координаты системы
			lReplaceConverter.AddVariable("Id", String(e.Data[0]));		// Id объекта который перемещается
			lReplaceConverter.AddVariable("SubId", String(e.Data[2]));	// Id объекта к которому цепляется перемещаемый объект
			lReplaceConverter.AddVariable("X", String(NewPos.X));		// X координата точки, куда ставить
			lReplaceConverter.AddVariable("Y", String(NewPos.Y));		// Y координата точки, куда ставить
			lReplaceConverter.addEventListener(Event.COMPLETE, OnReplaceObjectComplete);
			lReplaceConverter.addEventListener(IOErrorEvent.IO_ERROR, OnReplaceObjectError);
			lReplaceConverter.Load(lReplaceScript);
		}
//-----------------------------------------------------------------------------------------------------
// Обработка событий
//-----------------------------------------------------------------------------------------------------
		override protected function OnComplete(e:Event):void {
			// Данные по сектору загружены
			super.OnComplete(e);
			// Вся звездная система загружена
			dispatchEvent(new Event(StarSystemVn.LOADED));
		}
//-----------------------------------------------------------------------------------------------------
		override protected function OnMouseDown(e:MouseEvent):void {
			// Зажатие кнопки мышки
			DragCont.MouseDown(e);	// Для контроля за drag'ом
			// В MODE_VIEW перетаскивание системы за только за пустое место (stage) или за SpaceObject, в других режимах - только за пустое место (stage)
			if (Mode == MODE_VIEW && (e.target == stage || e.target.parent is SpaceObject) || (Mode != MODE_VIEW && e.target == stage)) {
				startDrag();
			}
		}
//-----------------------------------------------------------------------------------------------------
		public function OnAddObjectToSystem(e:PrizeManagerEventVn):void {
			// Добавить объект в виртуальную систему по данным из XML
			// Блок XML такой же, какие приходят при загрузке системы
			CreateFromXML(XML(e.Data));
			// Т.к. объект добавляется в систему в моде MODE_ADD - объекту тоже присвоить MODE_ADD
			if (Mode == MODE_ADD) {
				var AddedObjectId:uint = uint(XML(e.Data).children()[0].child("id"));
				var AddedObject:InteractiveSpaceObjectV = InteractiveSpaceObjectV(GetById(AddedObjectId));
				AddedObject.Mode = InteractiveSpaceObjectV.MODE_ADD;
			}
		}
//-----------------------------------------------------------------------------------------------------
		public function EnableObjectBackLighting():void {
			// Включить подсветку объектов
			for (var i:uint = 0; i < ObjectList.length; i++) {
				// Только для SpaceObject т.к. в систему могут быть загнаны и окна (чтобы были поверх всех объектов)
				if(ObjectList[i] is SpaceObject) ObjectList[i].BackLightable = true;
			}
		}
//-----------------------------------------------------------------------------------------------------
		public function DisableObjectBackLighting():void {
			// Включить подсветку объектов
			for (var i:uint = 0; i < ObjectList.length; i++) {
				if(ObjectList[i] is SpaceObject) ObjectList[i].BackLightable = false;
			}
		}
//-----------------------------------------------------------------------------------------------------
		private function OnConvertObjectToStorageComplete(e:Event):void {
			// Объект успешно удален в хранилище призов
			try {
				var Data:XML = new XML(e.target.data);
			}
			catch (e1:Error) {
				trace(e.target.data);
			}
			// Обработать полученные данные
			// Data.name() будет или ERR - ошибка, или VS - список сконвертированных призов
			if(Data.name()!="ERR") {
				// Удалить объекты из системы
				Delete(lDeletingObject);
				// Обновить список призов в менеджере призов
				lPrizesManager.LoadFromXML(Data);
			}
			else {
				// Ошибка
				Vn.Interplanety.Cons.Add(TextDictionary.Text(uint(Data)));
			}
			System.disposeXML(Data);
			// Очистка загрузчика
			lDeletingConverter.removeEventListener(Event.COMPLETE, OnConvertObjectToStorageComplete);
			lDeletingConverter.removeEventListener(IOErrorEvent.IO_ERROR, OnConvertObjectToStorageError);
			lDeletingConverter._delete();
			lDeletingConverter = null;
			lDeletingObject = null;
		}
//-----------------------------------------------------------------------------------------------------
		private function OnConvertObjectToStorageError(e:IOErrorEvent):void {
			// Ошибка удаления объекта в хранилице призов
			lDeletingConverter.removeEventListener(Event.COMPLETE, OnConvertObjectToStorageComplete);
			lDeletingConverter.removeEventListener(IOErrorEvent.IO_ERROR, OnConvertObjectToStorageError);
			lDeletingConverter._delete();
			lDeletingConverter = null;
			lDeletingObject = null;
			Interplanety.Cons.Add(TextDictionary.Text(188));	// "Ошибка удаления объекта"
		}
//-----------------------------------------------------------------------------------------------------
		private function OnReplaceObjectComplete(e:Event):void {
			// Объект успешно перемещен на новое место
			try {
				var Data:XML = new XML(e.target.data);
			}
			catch (e1:Error) {
				trace(e.target.data);
			}
			// Обработать полученные данные
			// Data.name() будет или ERR - ошибка, или указание, куда перецеплять объект
			if(Data.name()!="ERR") {
				// Переместить на клиенте
				var CurrentObject:SpaceObject = SpaceObject(GetById(uint(Data.child("Id"))));
				if (Data.child("SubId").length() > 0 && Data.child("SubId") != "0") {
					// Переместили на объект
					CurrentObject.parent.removeChild(CurrentObject);
					var ParentObject:SpaceObject = SpaceObject(GetById(uint(Data.child("SubId"))));
					CurrentObject.Trace = ParentObject;
					ParentObject.addChild(CurrentObject);
				}
				else {
					// Переместили на координаты
					CurrentObject.parent.removeChild(CurrentObject);
					CurrentObject.Trace = null;
					InteractiveSpaceObjectV(CurrentObject).StatCoordinates = new Vector2(Number(Data.child("X")),Number(Data.child("Y")));
					addChild(CurrentObject);
					CurrentObject.MoveIntoParent(Number(Data.child("X")),Number(Data.child("Y")),true);
				}
			}
			else {
				// Ошибка
				Vn.Interplanety.Cons.Add(TextDictionary.Text(uint(Data)));
			}
			System.disposeXML(Data);
			// Очистка загрузчика
			lReplaceConverter.removeEventListener(Event.COMPLETE, OnConvertObjectToStorageComplete);
			lReplaceConverter.removeEventListener(IOErrorEvent.IO_ERROR, OnConvertObjectToStorageError);
			lReplaceConverter._delete();
			lReplaceConverter = null;
		}
//-----------------------------------------------------------------------------------------------------
		private function OnReplaceObjectError(e:IOErrorEvent):void {
			// Ошибка перемещения объекта на новое место
			// На клиенте ничего не делаем
			
			// Очистка загрузчика
			lReplaceConverter.removeEventListener(Event.COMPLETE, OnConvertObjectToStorageComplete);
			lReplaceConverter.removeEventListener(IOErrorEvent.IO_ERROR, OnConvertObjectToStorageError);
			lReplaceConverter._delete();
			lReplaceConverter = null;
		}
//-----------------------------------------------------------------------------------------------------
		private function OnPrizesButtonMDClick(e:Event):void {
			// Сигнал от кнопок переключения режимов
			if(e.eventPhase==EventPhase.AT_TARGET) {
				switch(e.target.Pressed) {
					case -1: {
						// Ничего не нажато - режим VIEW
						Mode = MODE_VIEW;
						break;
					}
					case 0: {
						// режим модификации
						Mode = MODE_MODIFY;
						break;
					}
					case 1: {
						// режим удаления
						Mode = MODE_DELETE;
						break;
					}
					case 2: {
						// режим перемещения
						Mode = MODE_MOVE;
						break;
					}
				}
			}
		}
//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------
		public function get PrizesManager():PrizesManagerVn {
			// Менеджер призов
			return lPrizesManager;
		}
//-----------------------------------------------------------------------------------------------------
		public function get Mode():uint {
			// Режим работы системы
			return lMode;
		}
//-----------------------------------------------------------------------------------------------------
		public function set Mode(vValue:uint):void {
			if (lMode == vValue) return;
			if (vValue != MODE_VIEW) Mode = MODE_VIEW;	// Сначала очистка (ставим стандартный режим) потом - выставить нужный режим
			switch(vValue) {
				case MODE_VIEW: {
					switch(lMode) {
						case MODE_DELETE: {
							// Очистить режим DELETE
							for (var i1:uint = 0; i1 < ObjectList.length; i1++) {
								ObjectList[i1].Mode = InteractiveSpaceObjectV.MODE_VIEW;
							}
							removeEventListener(MouseEvent.CLICK, ConvertOverObjectToStorage);
							break;
						}
						case MODE_MODIFY: {
							// Очистить режим MODIFY
							for (var i:uint = 0; i < ObjectList.length; i++) {
								ObjectList[i].Mode = InteractiveSpaceObjectV.MODE_VIEW;
							}
							break;
						}
						case MODE_MOVE: {
							// Очистить режим MOVE
							for (var i2:uint = 0; i2 < ObjectList.length; i2++) {
								ObjectList[i2].Mode = InteractiveSpaceObjectV.MODE_VIEW;
							}
							removeEventListener(InteractiveSpaceObjectV.PRIZE_MOVED, MoveObject);
							break;
						}
						case MODE_ADD: {
							// Очистить режим ADD
							for (var i7:uint = 0; i7 < ObjectList.length; i7++) {
								ObjectList[i7].Mode = InteractiveSpaceObjectV.MODE_VIEW;
							}
							break;
						}
					}
					break;
				}
				case MODE_DELETE: {
					// Режим удаления объектов
					for (var i3:uint = 0; i3 < ObjectList.length; i3++) {
						ObjectList[i3].Mode = InteractiveSpaceObjectV.MODE_DELETE;
					}
					addEventListener(MouseEvent.CLICK, ConvertOverObjectToStorage);
					break;
				}
				case MODE_MODIFY: {
					// Режим изменения параметров объектов
					for (var i4:uint = 0; i4 < ObjectList.length; i4++) {
						// Пока только для виртуальных орбит - включить подсветку и интерактивное окно
						ObjectList[i4].Mode = InteractiveSpaceObjectV.MODE_MODIFY;
					}
					break;
				}
				case MODE_MOVE: {
					// Режим перемещения объектов
					for (var i5:uint = 0; i5 < ObjectList.length; i5++) {
						ObjectList[i5].Mode = InteractiveSpaceObjectV.MODE_MOVE;
					}
					addEventListener(InteractiveSpaceObjectV.PRIZE_MOVED, MoveObject);
					break;
				}
				case MODE_ADD: {
					// Режим добавления объектов
					for (var i6:uint = 0; i6 < ObjectList.length; i6++) {
						ObjectList[i6].Mode = InteractiveSpaceObjectV.MODE_ADD;
					}
					break;
				}
			}
			lMode = vValue;
		}
//-----------------------------------------------------------------------------------------------------
	}
}