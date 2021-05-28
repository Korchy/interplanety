<?php
//---------------------------------
//require_once("mysql.inc.php");
//---------------------------------
class Crystals
{

	public function __construct() {
		// Конструктор
		
	}

	public function __destruct() {
		// Деструктор
		
	}

	public function BuyCrystalsRate() {
		// Возвращает курс покупки кристаллов за золото (кол-во золота нужное на покупку 1 кристалла)
		return 2000;
	}

	public function SellCrystalsRate() {
		// Возвращает курс продажи кристаллов за золото (кол-во золота получаемое с продажи 1 кристалла)
		return 100;
	}
}
?>