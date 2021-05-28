<?php
//---------------------------------
// Расширенный класс для работы с HTML
//---------------------------------
//require_once("mysql.inc.php");
//---------------------------------
class HTMLEx
{

	public function __construct() {
		// Конструктор
		
	}

	public function __destruct() {
		// Деструктор
		
	}
	
	public function TextToEncodedHtml($Text) {
		// Перевод текста в формат HTML для RSS (Нельзя использовать htmlentities т.к. он кодирует и русские буквы)
		// Замена переносов (сначала, чтобы угловые скобки потом преобразовались в метасимволы)
		$Text = str_replace("\r\n\r\n","<p>",$Text);
		$Text = str_replace("\r\n","<br>",$Text);
		// Замена символов
		$HTMLSymbols = array("<" => "&lt;", ">" => "&gt;", '"' => "&quot;", "&" => "&amp;");
		$Text=strtr($Text, $HTMLSymbols);
		return $Text;
	}
	
	public function UrlToTxt($Url) {
		// Преобразование Url из формата ссылки в текстовый вид
		$Symbols = array("&" => "&amp;");
		return strtr($Url, $Symbols);
	}
	
	public function TxtToUrl($Url) {
		// Преобразование Url из текстового вида в формат ссылки
		$Symbols = array("&amp;" => "&");
		return strtr($Url, $Symbols);
	}
}
?>