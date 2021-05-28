<?php
//---------------------------------
// Пакеты обмена данными
//---------------------------------
require_once("dbconnected_vn.inc.php");
//---------------------------------
class SocketIOVn extends DBConnectedVn
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
	
	public function SendOP($UserId,$Pack) {
		// Добавить исх. пакет на отправку пользователю
		$this->Sql->SqlQuery = "update vn_user_connections set write_buff=concat(write_buff,\"".$this->Sql->Escape($Pack)."\") where user_id=\"".$this->Sql->Escape($UserId)."\";";
		$this->Sql->Exec();
	}
	
	public function GetIP ($UserId) {
		// Прочитать вх. пакет, полученый от пользователя
		$Rez = "";
		$this->Sql->SqlQuery = "select read_buff from vn_user_connections where user_id=\"".$this->Sql->Escape($UserId)."\";";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			while($tmp = $SQLRez->fetch_array()) {
				$LastOgr = strrpos($tmp["read_buff"],">");
				if($LastOgr!==false) {
					// Получить все до последнего закрывающего ">"
					$Rez = substr($tmp["read_buff"],0,$LastOgr+1);
					// Удалить все до последнего закрывающего ">" в буфере полученных от пользователя данных
					$this->Sql->SqlQuery = "update vn_user_connections set read_buff=substring(read_buff,".($LastOgr-1).") where user_id=\"".$this->Sql->Escape($UserId)."\";";
					$this->Sql->Exec();
					}
			}
			$this->Sql->FreeResult($SQLRez);
		}
		return $Rez;
	}
	
	public static function PingOP() {
		// Пинг (исх)
		return "<000>";
	}
	
	public static function AuthIP($UserId) {
		// Авторизация (вх)
		return "<001 id=\"".$UserId."\">";
	}
	
	public static function FinishedRouteOP($ShipId) {
		// Завершение маршрута (исх)
		return "<002 id=\"".$ShipId."\">";
	}
}
?>