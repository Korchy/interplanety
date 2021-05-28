package Vn.Common {
	// Класс
//-----------------------------------------------------------------------------------------------------
	import flash.geom.Matrix;
	import Vn.Math.Vector2;
	import Vn.Objects.VnObjectT;
	import Vn.Interplanety;
//-----------------------------------------------------------------------------------------------------
	public class Common {
//-----------------------------------------------------------------------------------------------------
// Переменные
//-----------------------------------------------------------------------------------------------------
		
//-----------------------------------------------------------------------------------------------------
// Конструктор
//-----------------------------------------------------------------------------------------------------
		public function Common() {
			super();
		}
//-----------------------------------------------------------------------------------------------------
// Деструктор - вызывать самому, автоматически не вызывается
//-----------------------------------------------------------------------------------------------------
		public function _delete():void {
			
		}
//-----------------------------------------------------------------------------------------------------
// Функции
//-----------------------------------------------------------------------------------------------------
		public static function LeadingNull(Str:String,Count:uint):String {
			// Добавление нужного числа нулей ("0") в начало строки Str чтобы кол-во символов в строке стало Count
			if(Str.length>=Count) return Str;
			while(Str.length!=Count) {
				Str = "0"+Str;
			}
			return Str;
		}
//-----------------------------------------------------------------------------------------------------
		public static function GetPath(Str:String):String {
			// Возвращает путь до имени файла, если строка Str представляет собой полный путь к файлу
			return Str.substring(0,Str.lastIndexOf("/")+1);
		}
//-----------------------------------------------------------------------------------------------------
		public static function GetName(Str:String):String {
			// Возвращает имя файла, если строка Str представляет собой полный путь к файлу
			return Str.substring(Str.lastIndexOf("/")+1,Str.lastIndexOf("."));
		}
//-----------------------------------------------------------------------------------------------------
		public static function GetExt(Str:String):String {
			// Возвращает расширение файла, если строка Str представляет собой полный путь к файлу
			return Str.substring(Str.lastIndexOf(".")+1);
		}
//-----------------------------------------------------------------------------------------------------
		public static function SubstrCount(Str:String,SubStr:String):int {
			// Количество подстрок в строке
			var Rez:int = 0;
			var FPos:int = Str.indexOf(SubStr,0);
			var LPos:int = Str.lastIndexOf(SubStr);
			while(FPos!=LPos) {
				Rez++;
				FPos = Str.indexOf(SubStr,FPos+1);
			}
			return Rez;
		}
//-----------------------------------------------------------------------------------------------------
		public static function Round(Value:Number,Signs:uint):Number {
			// Округление до нужного числа знаков
			var Kof:Number = Math.pow(10,Signs);
			return Math.round(Value*Kof)/Kof;
		}
//-----------------------------------------------------------------------------------------------------
		public static function Round005(Value:Number):Number {
			// Округление до ближайшего числа кратного 0.05
			var Rez:Number = 0.0;
			var Ost:Number = Math.abs(Value%0.05);
			if(Ost>=0.025) Rez = Value - Ost + 0.05;
			else Rez = Value - Ost;
			return Common.Round(Rez,2);	// Округление до 2 знака т.к. в предыдущей строчке опять действия с Number, которые могу вызывать погрешность
		}
//-----------------------------------------------------------------------------------------------------
		public static function SubObjPlace(Par:VnObjectT,Sub:VnObjectT):Vector2 {
			// Нахождение места для дочернего объекта Sub относительно объекта Par так, чтобы Sub не выходил за край сцены
			// Возвращает результат - смещение относительно центра Par (для функции MoveIntoParent)
			// Объекты Par и Sub должны совпадат центрами
			// Проверяются четыре положения для Sub по диагоналям от Par
			if(Par.GetPosition().X+Par.Width05+Sub.Width>Vn.Interplanety.Width) {
				if(Par.GetPosition().y-Par.Height05-Sub.Height>0) {
					// левый верхний угол
					return new Vector2(-Par.Width05-Sub.Width05,-Par.Height05-Sub.Height05);
				}
				else {
					// левый нижний угол
					return new Vector2(-Par.Width05-Sub.Width05,Par.Height05+Sub.Height05);
				}
			}
			else {
				if(Par.GetPosition().Y-Par.Height05-Sub.Height>0) {
					// правй верхний угол
					return new Vector2(Par.Width05+Sub.Width05,-Par.Height05-Sub.Height05);
				}
				else {
					// правый нижний угол
					return new Vector2(Par.Width05+Sub.Width05,Par.Height05+Sub.Height05);
				}
			}
		}
//-----------------------------------------------------------------------------------------------------
		public static function StringToKeyedArray(InputString:String,Delimiter:String,KeyValueDelimiter:String):Object {
			// Возвращает ассоциативный массив, созданный из строки, разбитой в соответствии с форматом ключ="значение"
			var Rez:Object = new Object();
			var Pairs:Array = InputString.split(Delimiter);
			for each (var Element:String in Pairs) {
				var KVDPos:uint = Element.indexOf(KeyValueDelimiter);
				var Key:String = Element.substr(0, KVDPos);
				var Value:String = Element.substr(KVDPos + KeyValueDelimiter.length);
				Value = Value.replace(/"/g, "");	// Убрать кавычки у значений
				Rez[Key] = Value;
			}
			return Rez;
		}
//-----------------------------------------------------------------------------------------------------
	}
}