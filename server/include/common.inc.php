<?php
//---------------------------------
//require_once("mysql.inc.php");
//---------------------------------
class Common
{
	var $BaseShipSpeed = 100;

	public function __construct() {
		
	}

	public function __destruct() {
		
	}
	
	public static function RootDir() {
		if(PHP_OS=="WINNT") return "C:/Program Files/Apache2.2/htdocs/vn";
		else return "/var/www/vm";
	}
	
	public static function IncDir() {
		if(PHP_OS=="WINNT") return "C:/Program Files/Apache2.2/htdocs/vn/include";
		else return "/var/www/vm/include";
	}
	
	public static function ForumDir() {
		if(PHP_OS=="WINNT") return "C:/Program Files/Apache2.2/htdocs/vn/forum";
		else return "/var/www/vm/forum";
	}
	
	public static function TmpDir() {
		if(PHP_OS=="WINNT") return "C:/Program Files/Apache2.2/htdocs/vn/tmp";
		else return "/var/www/vm/tmp";
	}
	
	public static function VirtualSystemScreenDir() {
		if(PHP_OS=="WINNT") return "C:/Program Files/Apache2.2/htdocs/vn/scr";
		else return "/var/www/vm/scr";
	}
	
	public static function ProgramIdentificator() {
		return "interplanety";
	}
	
	public function Otn($Value,$Max,$Min) {
		if($Max==$Min) return 0;
		return ($Value-$Min)/($Max-$Min);
	}

	public function StringToKeyedArray($String,$Delimiter,$KeyValueDelimiter) {
		$Rez = array();
		$Pairs = explode($Delimiter,$String);
		foreach($Pairs as $P) {
			$KVDPos = strpos($P,$KeyValueDelimiter);
			$Ind = trim(substr($P,0,$KVDPos));
			$Value = trim(substr($P,$KVDPos+strlen($KeyValueDelimiter)));
			$Value = str_replace("\"","",$Value);
			$Rez[$Ind] = $Value;
		}
		return $Rez;
	}
	
}
?>
