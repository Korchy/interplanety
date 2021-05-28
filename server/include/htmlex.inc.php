<?php
//---------------------------------
// ����������� ����� ��� ������ � HTML
//---------------------------------
//require_once("mysql.inc.php");
//---------------------------------
class HTMLEx
{

	public function __construct() {
		// �����������
		
	}

	public function __destruct() {
		// ����������
		
	}
	
	public function TextToEncodedHtml($Text) {
		// ������� ������ � ������ HTML ��� RSS (������ ������������ htmlentities �.�. �� �������� � ������� �����)
		// ������ ��������� (�������, ����� ������� ������ ����� ��������������� � �����������)
		$Text = str_replace("\r\n\r\n","<p>",$Text);
		$Text = str_replace("\r\n","<br>",$Text);
		// ������ ��������
		$HTMLSymbols = array("<" => "&lt;", ">" => "&gt;", '"' => "&quot;", "&" => "&amp;");
		$Text=strtr($Text, $HTMLSymbols);
		return $Text;
	}
	
	public function UrlToTxt($Url) {
		// �������������� Url �� ������� ������ � ��������� ���
		$Symbols = array("&" => "&amp;");
		return strtr($Url, $Symbols);
	}
	
	public function TxtToUrl($Url) {
		// �������������� Url �� ���������� ���� � ������ ������
		$Symbols = array("&amp;" => "&");
		return strtr($Url, $Symbols);
	}
}
?>