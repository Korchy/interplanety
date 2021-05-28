<?php
//---------------------------------
// Форма для логина/регистрации
//---------------------------------
require_once("include/language.inc.php");
//---------------------------------
class LoginFormVn
{
	
	public $Lang;	// Объект для перевода
	public $LoginActionPage;	// Страница для обработки логина
	public $RegisterActionPage;	// Страница для обработки регистрации
	
	public function __construct() {
		// Конструктор
		$this->Lang = new Language();
		$this->LoginActionPage = "#";
		$this->RegisterActionPage = "#";
	}

	public function __destruct() {
		// Деструктор
		unset($this->Lang);
	}
	
	public function ShowLoginForm($Err) {
		// Вывод формы для логина. В $Err передается ошибка, если нужно что-то выделить на форме
		echo "<form action='".$this->LoginActionPage."' method=post>\r\n";
		echo "<table width=310 height=100 border=0 rules=none style='border-radius: 20px; background-color: rgba(0,0,0,0.5);'>\r\n";
		// Login
		echo "<tr><td align=right width=150 height=30>".$this->Lang->Text(3).": </td><td  align=left><input type=text name=vn_login ";
		if(isset($_POST["vn_login"])&&$_POST["vn_login"]!="") echo "value=".$_POST["vn_login"]." ";
		echo "style='width:150'></td><td width=20>&nbsp</td></tr>\r\n";
		// Password
		echo "<tr><td align=right height=30>".$this->Lang->Text(4).": </td><td  align=left><input type=password name=vn_password style='width:150'></td>";
		if(strpos($Err,"VN_LOGIN_INCORRECT")!==false) echo "<td><img onmouseover=\"ShowToolTip(this,event,'".$this->Lang->Text(106)."');\" onmouseout=\"HideToolTip(this);\" src='exclamation.gif'></td></tr>\r\n";
		else echo "<td>&nbsp</td></tr>\r\n";
		// ВХОД
		echo "<tr align=center><td colspan=2 height=30><input type=submit name=button value='".$this->Lang->Text(6)."' style='width:225'> <input type=image src=graphic/icons/facebooklogin.png name=fbbutton></td><td>&nbsp</td></tr>\r\n";
		echo "</table>\r\n";
		echo "</form>\r\n";
	}
	public function ShowRegisterForm($Err) {
		// Вывод формы для регистрации нового пользователя. В $Err передается ошибка, если нужно что-то выделить на форме
		// При первом выводе форма скрыта, открывается через JavaScript-функцию
		if(!isset($_POST["vn_register"])) {
			// Кнопка открытия формы (для отсекания ботов вместо капчи - проверка, включен-ли JavaScript. Если выключен - форма не будет отображена)
			echo "<table id='vn_show_register_form_button' width=340 height=40 border=0 rules=none style='border-radius: 20px; background-color: rgba(0,0,0,0.5);'><tr><td align=center>";
			echo "<input type=submit value='".$this->Lang->Text(10)."' style='width:300' onclick='javascript:ShowRegisterForm();'>\r\n";
			echo "</td></tr></table>";
			echo "<form action='".$this->RegisterActionPage."' method=post>\r\n";
			echo "<table width=340 height=200 border=0 rules=none id='vn_register_form' style='display:none; border-radius: 20px; background-color: rgba(0,0,0,0.7);'>\r\n";
		}
		else {
			echo "<form action='".$this->RegisterActionPage."' method=post>\r\n";
			echo "<table width=340 height=200 border=0 rules=none id='vn_register_form' style='border-radius: 20px; background-color: rgba(0,0,0,0.7);'>\r\n";
		}
		// NewLogin
		echo "<tr><td align=right width=150 height=30>".$this->Lang->Text(3).": </td><td  align=left><input type=text name=vn_newlogin class=\"send\" ";
		if(isset($_POST["vn_newlogin"])&&$_POST["vn_newlogin"]!="") echo "value=".$_POST["vn_newlogin"]." ";
		echo "style='width:150'></td>";
		echo "<td width=25><img id=vn_newlogin_err onmouseover=\"ShowToolTip(this,event,'".$this->Lang->Text(9)."');\" onmouseout=\"HideToolTip(this);\" src='exclamation.gif'";
		if(strpos($Err,"VN_LOGIN_EXISTS")===false) echo " style='display:none'";
		echo "></td></tr>\r\n";
		// NewPassword
		echo "<tr><td align=right height=30>".$this->Lang->Text(4).": </td><td  align=left><input type=password name=vn_newpassword id=vn_newpassword oninput='javascript:CheckPasswordConfirm();'";
		if(isset($_POST["vn_newpassword"])&&$_POST["vn_newpassword"]!="") echo "value=".$_POST["vn_newpassword"]." ";
		echo "style='width:150'></td><td>&nbsp</td></tr>\r\n";
		// NewPasswordConfirm
		echo "<tr><td align=right height=30>".$this->Lang->Text(200).": </td><td align=left><input type=password name=vn_newpassword_conf id=vn_newpassword_conf oninput='javascript:CheckPasswordConfirm();'";
		if(isset($_POST["vn_newpassword_conf"])&&$_POST["vn_newpassword_conf"]!="") echo "value=".$_POST["vn_newpassword_conf"]." ";
		echo "style='width:150'></td>";
		echo "<td><img id=vn_password_confirm onmouseover=\"ShowToolTip(this,event,'".$this->Lang->Text(201)."');\" onmouseout=\"HideToolTip(this);\" src='exclamation.gif'";
		if(strpos($Err,"VN_PASSWORD_NOT_EQUAL")==false) echo " style='display:none'";
		echo "></td></tr>\r\n";
		// NewEmail
		echo "<tr><td align=right height=30>".$this->Lang->Text(12).": </td><td  align=left><input type=text name=vn_newemail class=\"send\" ";
		if(isset($_POST["vn_newemail"])&&$_POST["vn_newemail"]!="") echo "value=".$_POST["vn_newemail"]." ";
		echo "style='width:150'></td>";
		echo "<td><img id=vn_newemail_err onmouseover=\"ShowToolTip(this,event,'".$this->Lang->Text(202)."');\" onmouseout=\"HideToolTip(this);\" src='exclamation.gif'";
		if(strpos($Err,"VN_EMAIL_EXISTS")===false)  echo " style='display:none'";
		echo "></td></tr>\r\n";
		// Hidden - скрытое поле для отсекания ботов (вместо капчи). При первом вызове - заполняется из JavaScript-функции ShowRegisterFormByJs->ShowRegisterForm
		if(!isset($_POST["vn_register"])) echo "<tr style='display:none'><td align=right id='vn_hfield_name'>&nbsp;</td><td align=left id='vn_hfield_value'>&nbsp;</td><td>&nbsp;</td></tr>";
		else echo "<tr style='display:none'><td align=right id='vn_hfield_name'>Телефон</td><td align=left id='vn_hfield_value'><input type=text name=vn_hfield value='".$_POST["vn_hfield"]."' style='width:150'></td><td>&nbsp;</td></tr>";
		// Licence
		echo "<tr height=30><td colspan=2 width=300 align=center><input type=checkbox name=vn_licen_accepted";
		if(isset($_POST["vn_licen_accepted"])&&$_POST["vn_licen_accepted"]!="") echo " checked";
		echo "><small>".$this->Lang->Text(87)."</small></td>\r\n";
		if(strpos($Err,"VN_LICENCE_NOT_ACCEPTED")!==false) echo "<td><img onmouseover=\"ShowToolTip(this,event,'".$this->Lang->Text(92)."');\" onmouseout=\"HideToolTip(this);\" src='exclamation.gif'></td></tr>\r\n";
		else echo "<td>&nbsp</td></tr>\r\n";
		// РЕГИСТРАЦИЯ
		echo "<tr align=center><td colspan=3 height=30><input type=submit name=vn_register value='".$this->Lang->Text(13)."' style='width:300'></td></tr>\r\n";
		echo "</table>\r\n";
		echo "</form>\r\n";
	}
	
	public function ShowRegisterFormByJs() {
		// Скрипт на JavaScript для генерации дополнительного скрытого поля в форме регистрации и показа формы
		echo "<script type=\"text/javascript\">\r\n";
		echo "function ShowRegisterForm() {\r\n";
		echo "	document.getElementById('vn_show_register_form_button').style.display='none';\r\n";	// Скрыть кнопку
		echo "	document.getElementById('vn_register_form').style.display='block';\r\n";			// Показать форму
		// Создать скрытое поле
		echo "	document.getElementById('vn_hfield_name').innerHTML = 'Телефон';\r\n";
		echo "	var Hf = document.createElement('input');\r\n";
		echo "	Hf.setAttribute('type','text');\r\n";
		echo "	Hf.setAttribute('name','vn_hfield');\r\n";
		echo "	Hf.setAttribute('value','');\r\n";
		echo "	Hf.setAttribute('style','width:150');\r\n";
		echo "	document.getElementById('vn_hfield_value').innerHTML='';\r\n";
		echo "	document.getElementById('vn_hfield_value').appendChild(Hf);\r\n";
		echo "}\r\n";
		echo "</script>\r\n";
	}
	
	public function CheckPasswordConfirmJs() {
		// Скрипт на JavaScript для проверки подтверждения пароля
		echo "<script type=\"text/javascript\">\r\n";
		echo "function CheckPasswordConfirm() {\r\n";
		echo "	if(document.getElementById('vn_newpassword').value!=document.getElementById('vn_newpassword_conf').value) {;\r\n";
		echo "		document.getElementById('vn_password_confirm').style.display='block';\r\n";
		echo "	}\r\n";
		echo "	else {\r\n";
		echo "		document.getElementById('vn_password_confirm').style.display='none';\r\n";
		echo "	}\r\n";
		echo "}\r\n";
		echo "</script>\r\n";
	}
	
	public function AjaxHeader() {
		// Добавляет заголовок для использования интерактивной проверки данных формы на сервере с помощью Ajax
		echo "<script type=\"text/javascript\" src=\"https://ajax.googleapis.com/ajax/libs/jquery/1.7.2/jquery.min.js\"></script>\r\n";
	}
	
	public function AjaxFooter() {
		// Добавляет подвал для использования интерактивной проверки данных формы на сервере с помощью Ajax
		echo "<script type=\"text/javascript\">\r\n";
		echo "$('.send').on ('blur input propertychange',\r\n";	// При изменении значения в полях
		echo "	function(){\r\n";
		echo "		$.ajax({\r\n";
		echo "			type: \"POST\",\r\n";
		echo "			data: $(this).attr('name')+\"=\"+$(this).attr('value'),\r\n";
		echo "			url: \"checknewuservalid.php\",\r\n";
		echo "			success: function(responce) {\r\n";
		echo "				if(responce.split('=')[1]=='true') document.getElementById(responce.split('=')[0]+'_err').style.display='block';\r\n";
		echo "				else document.getElementById(responce.split('=')[0]+'_err').style.display='none';\r\n";
		echo "			}\r\n";
		echo "		});\r\n";
		echo "	}\r\n";
		echo ")\r\n";
		echo "</script>\r\n";
	}
}
?>