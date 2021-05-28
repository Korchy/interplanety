<?php
//---------------------------------
//session_start();
//---------------------------------
require_once("include/language.inc.php");
//---------------------------------
// Выбор языка
$Lang = new Language();	// Объект для перевода
$Lang->CheckLang("about");
?>
<html>
<head>
<?php
echo "<title>".$Lang->Text(1)."</title>";
?>
<link href="include/vn.css" type=text/css rel=stylesheet>
<meta http-equiv="content-type" content="text/html; charset=Windows-1251">
<!-- Подключение скрипта для показа выбранного из галереи скриншота -->
<link href="gallery.css" rel="stylesheet" type="text/css" />
<script type="text/javascript" src="gallery.js"></script>
<script type="text/javascript">
todo.onload(function(){
    todo.gallery('gallery');
});
</script>
<!-- Подключение скрипта показа галереи скриншотов -->
<link href="gallery_scroll.css" rel="stylesheet" type="text/css" />
<script src="gallery_scroll.js" type="text/javascript"></script> 
<script type="text/javascript">
function initGalleryScroll(){
	var gs=new galleryScroll('buttonScrollLeft','buttonScrollRight','scrollContainer');
	gs.setButtonInactiveClass('inactive');
};
if(typeof document.attachEvent!='undefined')window.attachEvent('onload',initGalleryScroll);
else window.addEventListener('load',initGalleryScroll,false);
</script>
<?php
// Текст
echo "</head>\n";
echo "<body background=fon.gif>\n";
echo "<center>\n";
echo "<table width=1000 border=0 cellpading=1 callspacing=1>\n";
echo "<tr height=25><td colspan=3><a href=about?changelang=rus><img src=lang_rus.jpg border=0></a>&nbsp<a href=about?changelang=eng><img src=lang_eng.jpg border=0></a></tr>\n";
echo "<tr height=100><td colspan=3><b>".$Lang->Text(103)."</b><br><hr align=left width=40%></td></tr>\n";
echo "<tr><td colspan=3 align=center>".$Lang->Text(102)."</td></tr>\n";
echo "<tr>
<td><img id=buttonScrollLeft src=graphic/screenshots/gallery/button_arrow_left.gif width=38 height=38></td>
<td align=center valign=middle>\n";
echo "
	<div id=scrollContainer>
	<a href=graphic/screenshots/1.gif rel=gallery[1]><img src=graphic/screenshots/1s.gif width=167 height=100></a>
	<a href=graphic/screenshots/2.gif rel=gallery[1]><img src=graphic/screenshots/2s.gif width=167 height=100></a>
	<a href=graphic/screenshots/3.gif rel=gallery[1]><img src=graphic/screenshots/3s.gif width=167 height=100></a>
	<a href=graphic/screenshots/4.gif rel=gallery[1]><img src=graphic/screenshots/4s.gif width=167 height=100></a>
	<a href=graphic/screenshots/5.gif rel=gallery[1]><img src=graphic/screenshots/5s.gif width=167 height=100></a>
	<a href=graphic/screenshots/6.gif rel=gallery[1]><img src=graphic/screenshots/6s.gif width=167 height=100></a>
	<a href=graphic/screenshots/7.gif rel=gallery[1]><img src=graphic/screenshots/7s.gif width=167 height=100></a>
	<a href=graphic/screenshots/8.gif rel=gallery[1]><img src=graphic/screenshots/8s.gif width=167 height=100></a>
	<a href=graphic/screenshots/9.gif rel=gallery[1]><img src=graphic/screenshots/9s.gif width=167 height=100></a>
	</div>";
echo "</td>
<td><img id=buttonScrollRight src=graphic/screenshots/gallery/button_arrow_right.gif width=38 height=38></td>\n
</tr>\n";
echo "<tr><td colspan=3>&nbsp;</td></tr>\n";
echo "<tr><td colspan=3 align=justify>".$Lang->Text(104)."</td></tr>\n";
echo "<tr><td colspan=3>&nbsp;</td></tr>\n";
echo "<tr><td colspan=3 align=center><a href=login><i>".$Lang->Text(14)."</i></a></td></tr>\n";
echo "</table>\n";
echo "</center>\n";
echo "</body>\n";
?>
</html>
