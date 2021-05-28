<?php
//---------------------------------
session_start();
//---------------------------------
require_once("include/user.inc.php");
require_once("include/loginform.inc.php");
require_once("include/language.inc.php");
require_once("include/analytics.inc.php");
//---------------------------------
// Юзер
$User = new UserVn();
// Выбор языка
$Lang = new Language();	// Объект для перевода
$Lang->CheckLang("login");
//echo $_SESSION["vn_user"]->Lang;
// Объект для аналитики
$Analytics = new AnalyticsVn();
// Форма логина/регистрации
$LoginForm = new LoginFormVn();
echo "<html>\r\n";
echo "<head>\r\n";
echo $Analytics->GoogleAnalytics();
?>
<link rel="icon" href="favicon.ico" type="image/x-icon"> 
<link rel="shortcut icon" href="favicon.ico" type="image/x-icon">
<link rel="alternate" type="application/rss+xml" title="Interplanety.ru RSS" href="rss">
<link rel="image_src" href="http://www.interplanety.ru/graphic/banner/interplanety3.png" />
<?php
echo "<title>".$Lang->Text(93)."</title>\r\n";
echo "<link href=\"include/vn.css\" type=text/css rel=stylesheet>\r\n";			// Общий css
echo "<link href=\"include/tooltip.css\" type=text/css rel=stylesheet>\r\n";	// css для всплывающей подсказки
echo "<meta http-equiv=\"content-type\" content=\"text/html; charset=windows-1251\">\r\n";
echo "<meta name=\"keywords\" content=\"".$Lang->Text(99)."\">\r\n";
echo "<meta name=\"Description\" content=\"".$Lang->Text(91)."\">\r\n";
echo "<meta property=\"og:title\" content=\"Interplanety\">\r\n";
echo "<meta property=\"og:type\" content=\"game\">\r\n";
echo "<meta property=\"og:url\" content=\"http://www.interplanety.ru\">\r\n";
echo "<meta property=\"og:image\" content=\"http://www.interplanety.ru/graphic/banner/interplanety3.png\">\r\n";
echo "<meta property=\"og:description\" content=\"".$Lang->Text(91)."\">\r\n";
echo "<script type=\"text/javascript\" src=\"include/tooltip.js\"></script>\r\n";	// Скрипт для всплывающей подсказки
$LoginForm->ShowRegisterFormByJs();	// Скрипт для добавления скрытого поля в форму регистрации при первом вызове
$LoginForm->CheckPasswordConfirmJs();	// Скрипт для проверки правильности подтверждения пароля
$LoginForm->AjaxHeader();
// Авторизация
if(!isset($_SESSION["vn_id"])) {
	// первое открытие или попытка логина/регистрации
	$Err = $User->Login();
	if($Err=="VN_OK") {
		// Нормальный логин - переход на index.php
		header("Location: index.php");
	}
	else {
//		echo $Err."<hr>";
		// Первое открытие или вход с ошибкой - выводим форму для логина
		echo "</head>\r\n";
		echo "<body background=fon.gif>\r\n";
		echo "<center>\r\n";
		$LoginForm->RegisterActionPage = "login";
		$LoginForm->LoginActionPage = "login";	// Страницы обработки
		echo "<table width=1000 border=0>\r\n";
		echo "<tr height=25><td colspan=2><a href=login?changelang=rus><img src=lang_rus.jpg border=0></a>&nbsp;<a href=login?changelang=eng><img src=lang_eng.jpg border=0></a></td></tr>\r\n";
		// itemscope, itemprop - разметка метаданных (взято с google webmaster)
		echo "<tr><td width=50%>&nbsp</td><td itemscope itemtype=\"http://schema.org/SoftwareApplication\"><b><i><font size=6><span itemprop=\"name\">".$Lang->Text(2)."</span></b></font><br><font size=2><span itemprop=\"applicationCategory\">".$Lang->Text(101)."</span> - ".$Lang->Text(182)."</font></i></td></tr>\r\n";
		echo "</table>";
		echo "<table width=1000 height=600 border=0 background=login.jpg style='border-radius: 20px;'>\r\n";
		echo "<tr height=260><td align=center>\r\n";
			$LoginForm->ShowLoginForm($Err);
		echo "</td></tr>";
		echo "<tr><td align=center valign=top width=50%>\r\n";
			$LoginForm->ShowRegisterForm($Err);
		echo "</td></tr>\r\n";
		echo "</table>\r\n";
		echo "<table width=1000 border=0>\r\n";
		echo "<tr><td align=center><font size=-1><i><a href=/about>".$Lang->Text(103)."</a>&nbsp;&nbsp;&nbsp;<a href=licen>".$Lang->Text(88)."</a></i></font></td></tr>";
		echo "</table>\r\n";
		echo "</center>\r\n";
		echo $Analytics->YandexMetrikaCounter();
		echo "</body>\r\n";
		$LoginForm->AjaxFooter();
	}
}
else {
	// vn_id есть - выход из текущего сеанса
	// Удалить переменные и закрыть саму сессию
	$User->Logoff();
	if(isset($_SESSION[$Lang->LangName])) unset($_SESSION[$Lang->LangName]);
	session_destroy();
	// Вернуть на первую страницу
/*	echo "<meta http-equiv=\"Refresh\" content=\"0; URL=login\">";
	echo "<meta http-equiv=\"content-type\" content=\"text/html; charset=Windows-1251\">";
	echo "</head>";
	echo "<body>";
	echo "</body>";
	echo "</html>";
*/
	header("Location: login");
	echo "</head>";
}
echo "</html>";
?>