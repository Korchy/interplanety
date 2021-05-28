<?php
//---------------------------------
require_once("dbconnected_vn.inc.php");
//---------------------------------
class VNText extends DBConnectedVn
{

	public function __construct() {
		// Конструктор родителя
		parent::__construct();
		// Конструктор
		
	}

	public function __destruct() {
		// Деструктор
		
		// Деструктор родителя
		parent::__destruct();
	}

	public function GetDictionary() {
		// Получить список текстовых строк
		$Rez = " ";
		$this->Sql->SqlQuery = "select id,game_load,".$this->Sql->Escape($_SESSION["vn_lang"])." from vn_text order by id;";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			while($tmp = $SQLRez->fetch_array()) {
				if($tmp["game_load"]=='T') $Rez = $Rez.iconv("cp1251","utf-8",$tmp[$_SESSION["vn_lang"]])."#";
				else $Rez = $Rez."#";
			}
			$this->Sql->FreeResult($SQLRez);
		}
		return substr($Rez,1);
	}
}
?>