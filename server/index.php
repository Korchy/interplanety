<?php
//---------------------------------
require("include/language.inc.php");
//---------------------------------
session_start();
//---------------------------------
// Если нет авторизации - вернутся на страницу авторизации
if(!isset($_SESSION["vn_id"])) {
	session_destroy();
	header("Location: login");
}
// Переключение языка
$Lang = new Language();	// Объект для перевода
$Lang->CheckLang("index");
?>
<html>
<head>
<link rel="icon" href="favicon.ico" type="image/x-icon"> 
<link rel="shortcut icon" href="favicon.ico" type="image/x-icon">
<link rel="alternate" type="application/rss+xml" title="Interplanety.ru RSS" href="rss">
<?php
echo "<title>".$Lang->Text(1)."</title>";
//echo session_id();
?>
<link href="include/vn.css" type=text/css rel=stylesheet>
<meta http-equiv="content-type" content="text/html; charset=Windows-1251">
<?php
echo "<meta name=\"keywords\" content=\"".$Lang->Text(99)."\">";
?>
<script type="text/javascript">
function SetFocusToFlash() {
	if (navigator.userAgent.match(/MSIE/)) document.Vn.focus();
	else document.getElementById("Vn1").focus();
}
</script>
</head>
<body background=fon.gif onLoad='javascript:SetFocusToFlash();'>
<center>
<table width=100% height=100% border=0 cellpading=0 callspacing=0>
<tr><td>
<table width=100% height=100% border=1 cellpading=0 callspacing=0 bgcolor=000000>
<tr><td>
	<object classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000" codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=9,0,0,0" width="100%" height="100%" id="Vn" align="middle">
	<param name="allowScriptAccess" value="sameDomain" />
	<param name="allowFullScreen" value="false" />
	<param name="movie" value="Vn.swf" />
	<param name="flashvars" value="session_id=<?php echo session_id(); ?>">
	<param name="quality" value="autohigh" />
	<embed src="Vn.swf" flashvars="session_id=<?php echo session_id(); ?>" quality="autohigh" width="100%" height="100%" name="Vn" id="Vn1" wmode="opaque" align="middle" allowScriptAccess="sameDomain" allowFullScreen="false" type="application/x-shockwave-flash" pluginspage="http://www.macromedia.com/go/getflashplayer"/>
	</object>
</td></tr>
</table>
</td></tr>
<?php
echo "<tr height=30><td align=center><font size=-1><i><a href=/forum>".$Lang->Text(100)."</a>&nbsp;&nbsp;&nbsp;<a href=licen>".$Lang->Text(88)."</a></i></font></td></tr>";
?>
</td></tr>
</table>
</center>
</body>
</html>