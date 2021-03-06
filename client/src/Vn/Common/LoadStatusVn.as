package Vn.Common {
//-----------------------------------------------------------------------------------------------------
// Класс - перечень статусов загрузки объекта
//-----------------------------------------------------------------------------------------------------

//-----------------------------------------------------------------------------------------------------
	public class LoadStatusVn {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		// Константы
		public static const NOT_LOADED:uint = 0;	// Данные не загружены
		public static const LOADED:uint = 1;		// Данные загружены
		public static const IN_PROGRESS:uint = 2;	// Загрузка в процессе
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function LoadStatusVn() {
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
		
//-----------------------------------------------------------------------------------------------------
// Обработка событий
//-----------------------------------------------------------------------------------------------------

//-----------------------------------------------------------------------------------------------------
// Методы get/set для установки значений переменных
//-----------------------------------------------------------------------------------------------------

//-----------------------------------------------------------------------------------------------------
	}
}