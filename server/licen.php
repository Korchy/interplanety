<?php
//---------------------------------
//session_start();
//---------------------------------
require_once("include/language.inc.php");
//---------------------------------
// Выбор языка
$Lang = new Language();	// Объект для перевода
$Lang->CheckLang("licen");
?>
<html>
<head>
<?php
echo "<title>".$Lang->Text(1)."</title>";
?>
<link href="include/vn.css" type=text/css rel=stylesheet>
<meta http-equiv="content-type" content="text/html; charset=Windows-1251">
<script type="text/javascript" src="include/seml.js"></script>
<?php
// Текст
echo "</head>\n";
echo "<body background=fon.gif>\n";
echo "<center>\n";
echo "<table width=1000 border=0 cellpading=1 callspacing=1>\n";
echo "<tr height=25><td colspan=2><a href=licen?changelang=rus><img src=lang_rus.jpg border=0></a>&nbsp<a href=licen?changelang=eng><img src=lang_eng.jpg border=0></a></tr>\n";
echo "<tr height=100><td colspan=2><b>".$Lang->Text(88)."</b><br><hr align=left width=40%></td></tr>\n";
echo "<tr><td colspan=2 align=justify>".$Lang->Text(96)."</td></tr>\n";
echo "<tr><td width=40%>&nbsp</td><td><a href=login><i>".$Lang->Text(14)."</i></a></td></tr>\n";
echo "</table>\n";
echo "</center>\n";
echo "</body>\n";
?>
</html>