<?php
//---------------------------------
require_once("include/trade.inc.php");
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
// ������� ���������
//---------------------------------
$cargoId = 0;			// vn_usership_cargo.id
$sellingCount = 0;
if(isset($_REQUEST['cargoId'])) $cargoId = $_REQUEST['cargoId'];
if(isset($_REQUEST['sellingCount'])) $sellingCount = $_REQUEST['sellingCount'];
//---------------------------------
// �������
// ������ ������������ � ���� XML-���������
//---------------------------------
$Sell = new Trade();
$Rez = $Sell->SellDeal($_SESSION["vn_id"], $cargoId, $sellingCount);
//$file = fopen ("sell.xml","w+");
//fputs($file, $Rez->saveXML());
echo $Rez->saveXML();
?>