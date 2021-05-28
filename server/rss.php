<?php
//---------------------------------
require_once("include/rss.inc.php");
//---------------------------------
header("Content-Type: application/xml");	// XML
//---------------------------------
$Rss = new RssVn();
$Rss->EchoHeader();
$Rss->EchoBody(15);
$Rss->EchoFooter();
?>