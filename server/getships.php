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
$UserShips = $Doc->createElement('UserShips');
$ShipsList->GetShipsXML($_SESSION["vn_id"],$Doc,$UserShips);
	// ---
$Doc->appendChild($UserShips);
	// ������� ��������������� XML
//$file = fopen ("getships.xml","w+");
//fputs($file, $Doc->saveXML());
echo $Doc->saveXML();
?>