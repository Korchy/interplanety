<?php
//---------------------------------
// Отдать заголовок - 404 "не найдено"
header("HTTP/1.0 404 Not Found");
//---------------------------------
require_once("include/language.inc.php");
//---------------------------------
session_start();
//---------------------------------
// Переключение языка
$Lang = new Language();	// Объект для перевода
$Lang->CheckLang("err404");
?>
<html>
<head>
<?php
echo "<title>".$Lang->Text(1)."</title>\r\n";
?>
<link href=/include/vn.css type=text/css rel=stylesheet>
<meta http-equiv="content-type" content="text/html; charset=Windows-1251">
</head>
<body background=/fon.gif>
<center>
<table width=1000 height=600 border=0 cellpading=1 callspacing=1>
	<tr height=25><td colspan=2><a href="/err404?changelang=rus"><img src="/lang_rus.jpg" border=0></a>&nbsp;<a href="/err404?changelang=eng"><img src="/lang_eng.jpg" border=0></a></td></tr>
	<tr><td height=100 colspan=2 align=right>&nbsp;</td></tr>
	<?php
	echo "<tr><td width=50%>&nbsp;</td><td><b><i><font size=6>".$Lang->Text(97)."</font></b>"."<br>".$Lang->Text(98)."</i></td></tr>\r\n";
	echo "<tr align=center><td colspan=2><p><a href=/login><i>".$Lang->Text(14)."</i></a></td></tr>\r\n";
	?>
</table>
</form>
</center>
</body>
</html>