package Vn.SpaceObjects {
//-----------------------------------------------------------------------------------------------------
// Менеджер SpaceObject. Содержит список SpaceObject по всей вселенной
// Через менеджер пока только для реальной звездной системы
//		т.к. для виртуальной id будут повторяться
//	-> В будущем сделать такой же менеджер и для виртуальной системы
//-----------------------------------------------------------------------------------------------------
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.utils.getDefinitionByName;
	import flash.system.System;
	import Vn.Common.DynamicObjectsVn;
	import Vn.Events.EventVn;
	import Vn.Interplanety;
	import Vn.List.ObjectsListLVn;
	import Vn.System.PHPLoader;
	import Vn.Text.TextDictionary;
//-----------------------------------------------------------------------------------------------------
	public class SpaceObjectManagerVn extends ObjectsListLVn {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		private var lSOLoaders:Array;	// Массив загрузчиков SpaceObject (чтобы не удалялись в процессе загрузки сборщиком мусора)
		private var lCreateListIndexes:Array;	// Список индексов объектов, создаваемых через CreateListFromXML
		private var lSOLoaderScript:String;	// Скрипт для загрузки конкретного SpaceObject
		// Константы сообщений
		public static const STAR_SYSTEM_LOADED:String = "EvSpaceObjectManagerStarSystemLoaded";		// Загружены данные по StarSystem
		public static const SPACE_OBJECT_LOADED:String = "EvSpaceObjectManagerSpaceObjectLoaded";	// Загружены данные по конкретному SpaceObject
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function SpaceObjectManagerVn() {
			// Конструктор предка
			super();
			// Конструктор
			Script = "getstarsystem.php";
			lSOLoaderScript = "getspaceobject.php";
			lSOLoaders = new Array();
			lCreateListIndexes = new Array();
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, Sавтоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		override public function _delete():void {
			// Деструктор
			Clear();
			lSOLoaders = null;
			lCreateListIndexes = null;
			// Деструктор предка
			super._delete();
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		override public function Clear():void {
			// Очистка
			while (lSOLoaders.length > 0) {
				if (lSOLoaders[0] != null && lSOLoaders[0] != undefined) {
					if (PHPLoader(lSOLoaders[0]).hasEventListener(Event.COMPLETE)) PHPLoader(lSOLoaders[0]).removeEventListener(Event.COMPLETE, onSOLoaded);
					if (PHPLoader(lSOLoaders[0]).hasEventListener(IOErrorEvent.IO_ERROR)) PHPLoader(lSOLoaders[0]).removeEventListener(IOErrorEvent.IO_ERROR, onSOIOError);
					PHPLoader(lSOLoaders[0])._delete();
					lSOLoaders[0] = null;
				}
				lSOLoaders.splice(0, 1);
			}
			while (lCreateListIndexes.length > 0) {
				lCreateListIndexes.splice(0, 1);
			}
			super.Clear()
		}
//-----------------------------------------------------------------------------------------------------
		override public function Add(NewObject:Object):void {
			// Добавление объекта в список
			Delete(SpaceObject(NewObject).Id);
			All.push(NewObject);
		}
//-----------------------------------------------------------------------------------------------------
		override public function Delete(vId:uint):void {
			// Удаление объекта из списка
			for (var i:uint = 0; i < All.length; i++) {
				if (SpaceObject(All[i]).Id == vId) {
					// Если объект грузится - отменить загрузку
					for (var i1:uint = 0; i1 < lSOLoaders.length; i1++) {
						if (PHPLoader(lSOLoaders[i1]).Id == vId) {
							if (PHPLoader(lSOLoaders[i1]).hasEventListener(Event.COMPLETE)) PHPLoader(lSOLoaders[i1]).removeEventListener(Event.COMPLETE, onSOLoaded);
							if (PHPLoader(lSOLoaders[i1]).hasEventListener(IOErrorEvent.IO_ERROR)) PHPLoader(lSOLoaders[i1]).removeEventListener(IOErrorEvent.IO_ERROR, onSOIOError);
							PHPLoader(lSOLoaders[i1])._delete();
							lSOLoaders[i1] = null;
							lSOLoaders.splice(i1, 1);
							break;
						}
					}
					var LoaderIndex:uint = lCreateListIndexes.indexOf(vId);
					if (lCreateListIndexes.length > 0 && LoaderIndex != -1) {
						lCreateListIndexes.splice(LoaderIndex, 1);
					}
					// Удалить сам объект
					SpaceObject(All[i])._delete();
					All[i] = null;
					All.splice(i, 1);
					break;
				}
			}
		}
//-----------------------------------------------------------------------------------------------------
		public function LoadFromStarSystem(vStarSystemId:uint):void {
			// Загрузка всех SpaceObject входящих в звездную систему StarSystemId
			AddScriptParam("StarSystemId", String(vStarSystemId));
			Load();
		}
//-----------------------------------------------------------------------------------------------------
		override protected function CreateListFromXML(Data:XML):void {
			// Создание списка по полученным XML-данным
			for each (var Node:XML in Data.*) {
				if (Node.nodeKind() == "element") {
					var CurrentSpaceObject:SpaceObject = SpaceObject(ById(uint(Node.attribute("id"))));
					if (CurrentSpaceObject.Loaded == false) {
						lCreateListIndexes.push(CurrentSpaceObject.Id);
					}
				}
			}
			if (lCreateListIndexes.length == 0) OnStarSystemListLoaded();
		}
//-----------------------------------------------------------------------------------------------------
		private function OnStarSystemListLoaded():void {
			// Завершение загрузки набора объектов SpaceObject для звездной системы
			// Проверить связки всех SpaceObject между собой
			for each(var currentSpaceObject:SpaceObject in All) {
				if (currentSpaceObject.TraceId != 0) {
					var parentOfCurrentSpaceObject:SpaceObject = SpaceObject(ById(currentSpaceObject.TraceId));
					parentOfCurrentSpaceObject.addChild(currentSpaceObject);
					currentSpaceObject.Trace = parentOfCurrentSpaceObject;
				}
			}
			// Отправить сообщение
			dispatchEvent(new Event(SpaceObjectManagerVn.STAR_SYSTEM_LOADED));
		}
//-----------------------------------------------------------------------------------------------------
		override public function ById(vId:uint):Object {
			// Возвратить указатель на объект по его Id в системе
			var RetObject:SpaceObject = SpaceObject(super.ById(vId));
			if (RetObject == null) {
				RetObject = new SpaceObject();
				RetObject.Id = vId;
				LoadSpaceObjectData(RetObject);
				Add(RetObject);
			}
			return RetObject;
		}
//-----------------------------------------------------------------------------------------------------
		private function LoadSpaceObjectData(vSpaceObject:SpaceObject):void {
			// Загрузка данных по конкретному SpaceObject
			var SOLoader:PHPLoader = new PHPLoader();
			SOLoader.Id = vSpaceObject.Id;
			SOLoader.AddVariable("Id", String(vSpaceObject.Id));
			SOLoader.addEventListener(Event.COMPLETE, onSOLoaded);
			SOLoader.addEventListener(IOErrorEvent.IO_ERROR, onSOIOError);
			lSOLoaders.push(SOLoader);
			SOLoader.Load(lSOLoaderScript);
		}
//-----------------------------------------------------------------------------------------------------
		private function LoadSpaceObjectFromXML(vId:uint, vNode:XML):void {
			// Получены данные по конкретному SpaceObject, который лежит в All[vId]
			if (vNode.nodeKind() == "element") {
				// Пересоздать объект нужным классом
				var ClassReference:Class = getDefinitionByName(DynamicObjectsVn.FullName(vNode.name())) as Class;
				All[vId] = new ClassReference();
				// Заполнить данными
				All[vId].FPS = Interplanety.Universe.FPS;
				All[vId].LoadFromXML(vNode);
			}
		}
//-----------------------------------------------------------------------------------------------------
// Обработка событий
//-----------------------------------------------------------------------------------------------------
		private function onSOLoaded(e:Event):void {
			// Получены данные по конкретному SpaceObject
			PHPLoader(e.target).removeEventListener(Event.COMPLETE, onSOLoaded);
			PHPLoader(e.target).removeEventListener(IOErrorEvent.IO_ERROR, onSOIOError);
			// Полученные данные
			try {
				var Data:XML = new XML(e.target.data);
			}
			catch (e1:Error) {
				trace(e.target.data);
				trace("------");
				trace(e1.toString());
				trace("------");
			}
			// Обработать данные
			var i:uint = KeyById(PHPLoader(e.target).Id);	// Получить индекс объекта в общем списке
			LoadSpaceObjectFromXML(i, Data);	// его нужно пересоздать с правильными данными
			// Отправка сообщения о завершении загрузки по конкретному SpaceObject
			dispatchEvent(new EventVn(SpaceObjectManagerVn.SPACE_OBJECT_LOADED, All[i]));
			// Очистка временных данных
			System.disposeXML(Data);
			//  Почистить загрузочные массивы
			var LoaderIndex:uint = lCreateListIndexes.indexOf(PHPLoader(e.target).Id);
			if (lCreateListIndexes.length > 0 && LoaderIndex != -1) {
				lCreateListIndexes.splice(LoaderIndex, 1);
				if (lCreateListIndexes.length == 0) OnStarSystemListLoaded();
			}
			LoaderIndex = lSOLoaders.indexOf(PHPLoader(e.target));
			PHPLoader(e.target)._delete();
			if(LoaderIndex != -1) {
				lSOLoaders[LoaderIndex] = null;
				lSOLoaders.splice(LoaderIndex, 1);
			}
		}
//-----------------------------------------------------------------------------------------------------
		private function onSOIOError(e:IOErrorEvent):void {
			// Ошибка получения данных по конкретному SpaceObject
			PHPLoader(e.target).removeEventListener(Event.COMPLETE, onSOLoaded);
			PHPLoader(e.target).removeEventListener(IOErrorEvent.IO_ERROR, onSOIOError);
			//  Почистить загрузочные массивы
			var LoaderIndex:uint = lCreateListIndexes.indexOf(PHPLoader(e.target).Id);
			if (lCreateListIndexes.length > 0 && LoaderIndex != -1) {
				lCreateListIndexes.splice(LoaderIndex, 1);
				if (lCreateListIndexes.length == 0) OnStarSystemListLoaded();
			}
			LoaderIndex = lSOLoaders.indexOf(PHPLoader(e.target));
			PHPLoader(e.target)._delete();
			if(LoaderIndex != -1) {
				lSOLoaders[LoaderIndex] = null;
				lSOLoaders.splice(LoaderIndex, 1);
			}
			// Системная ошибка
			Interplanety.Cons.Add(TextDictionary.Text(117));
		}
//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------
		
//-----------------------------------------------------------------------------------------------------
	}
}