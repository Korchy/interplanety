<?php
//---------------------------------
require_once("include/ships.inc.php");
//---------------------------------
if (isset($_REQUEST['session_id'])) {
	session_id($_REQUEST['session_id']);
}
session_start();
// ���� ��� ����������� - �������� �� �������� �����������
if(!isset($_SESSION["vn_id"])) {
	session_destroy();
	header("Location: login");
}
//---------------------------------
$ShipsList = new Ships();
	// ������ � �������� ���������� � ���� XML-���������
$Doc = new DOMDocument('1.0','utf-8');
	// �������
$SellingShips = $Doc->createElement('SellingShips');
$ShipsList->GetBuyingShipsXML($_SESSION["vn_id"],$Doc,$SellingShips);
	// ---
$Doc->appendChild($SellingShips);
	// ������� ��������������� XML
//$file = fopen ("getbuyingships.xml","w+");
//fputs($file, $Doc->saveXML());
echo $Doc->saveXML();
?>
