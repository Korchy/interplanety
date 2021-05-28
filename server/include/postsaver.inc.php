<?php
//---------------------------------
// Сохранение данных $_POST в сессии $_SESSION
//---------------------------------
class PostSaver
{

	public function __construct() {
		// Конструктор
		
	}

	public function __destruct() {
		// Деструктор
		
	}
	
	public static function SavePost($PageName) {
		// Сохранить $_POST в сессию
		if(isset($_SESSION)) {
			if(sizeof($_POST) !== 0) {
				// Удалить старые данные по странице
				if(isset($_SESSION["Post"][$PageName])) unset($_SESSION["Post"][$PageName]);
				// Сохранить текущие
				$_SESSION["Post"][$PageName] = array();
				$_SESSION["Post"][$PageName] = $_POST;
			}
		}
	}
	
	public static function RestorePost($PageName) {
		// Восстановить массив $_POST из сессии
		// Очистить $_POST
		foreach($_POST as $var => $value) {
			unset($_POST[$var]);
		}
		// Перекопировать в $_POST данные из сохраненных в сессии
		$_POST = $_SESSION["Post"][$PageName];
	}
	
	public static function ClearSavedPost($PageName) {
		// Удаление сохраненных в сессии данных $_POST
		if(isset($_SESSION)&&isset($_SESSION["Post"][$PageName])) unset($_SESSION["Post"][$PageName]);
	}
	
	public static function IsPostSaved($PageName) {
		// Проверка - сохранены ли данные $_POST в сессии
		if(isset($_SESSION)&&isset($_SESSION["Post"][$PageName])) return true;
		else return false;
	}
}
?>