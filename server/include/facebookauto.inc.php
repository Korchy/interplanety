<?php
//---------------------------------
// Facebook автоматизация работы с сетью - SDK v.4.
// Для работы необходимы файлы в директории facebook_sdk4 (скачаны с https://github.com/facebook/facebook-php-sdk-v4/archive/4.0-dev.zip)
// В основном файле должна быть активирована сессия: session_start();
//
//	Автопостинг на бизнес-страницу в Facebook:
//		Зарегистрировать приложение
//			залогиниться от имени пользователя (не бизнес-страницы)
//			Перейти по адресу https://developers.facebook.com/apps
//			Зарегистрироваться как разработчик (1 раз)
//				нажать Register
//				по требованию указать телефон для получения кода подтверждения (просто цифры: 926-111-11-11...) и ввести код
//			Apps -> Create New App
//				Display Name: NNN
//				Namespace не указывать
//				Category: Apps for pages
//				Получаем AppId и AppSecret
//				Ввести контактрый e-mail
//				В ststus and revuew - включить переключатель (сделать приложение публичным)
//			Добавить canvas url - на этот url будут редиректиться сообщения от facebook
//				Settings -> Add platform -> Facebook Canvas
//					Canvas url = http://www.interplanety.ru/
//					Secure url = https://www.interplanety.ru/
//			Использование:
//				$F = new FacebookAuto();
//				$F->SetFacebookApplication('AppId', 'AppSecret');	// подключить приложение
//				$F->GetFacebookSession('Адрес на который вернуться после логина в Facebook');	// залогиниться в facebook
//				$F->PostOnUserBusinessPageTimeLine('Id бизнес-страницы', 'Текст', 'Ссылка', 'Заголовок');
//				$F->ResetFacebookSession();
//		
//			Для логина пользователей через facebook создавал приложение For web (а не Canvas); Add Platform - не создавал
//---------------------------------
require_once("dbconnected_vn.inc.php");
require_once("facebook_sdk4/Entities/AccessToken.php");
require_once("facebook_sdk4/FacebookSession.php");
require_once("facebook_sdk4/HttpClients/FacebookHttpable.php");
require_once("facebook_sdk4/HttpClients/FacebookCurl.php");
require_once("facebook_sdk4/HttpClients/FacebookCurlHttpClient.php");
require_once("facebook_sdk4/FacebookResponse.php");
require_once("facebook_sdk4/FacebookRequest.php");
require_once("facebook_sdk4/FacebookRedirectLoginHelper.php");
require_once("facebook_sdk4/FacebookSDKException.php");
require_once("facebook_sdk4/FacebookRequestException.php");
require_once("facebook_sdk4/FacebookServerException.php");
require_once("facebook_sdk4/FacebookPermissionException.php");
require_once("facebook_sdk4/FacebookAuthorizationException.php");
require_once("facebook_sdk4/GraphObject.php");
require_once("facebook_sdk4/GraphSessionInfo.php");
require_once("facebook_sdk4/GraphUser.php");
//---------------------------------
use Facebook\FacebookSession;
use Facebook\FacebookRedirectLoginHelper;
use Facebook\FacebookRequestException;
use Facebook\FacebookRequest;
use Facebook\GraphUser;
//---------------------------------
class FacebookAuto extends DBConnectedVn
{
	private $FbUserSession;	// Сессия пользователя на facebook
	public $FbUserProfile;	// Массив с данными профиля пользователя facebook
	private $FbUserPermissions;	// Массив с данными прав пользователя facebook
	
	public function __construct() {
		// Конструктор родителя
		parent::__construct();
		// Конструктор
		$this->FbUserSession = null;
		$this->FbUserProfile = null;
		$this->FbUserPermissions = null;
	}

	public function __destruct() {
		// Деструктор
		unset($this->FbUserSession);
		unset($this->FbUserPermissions);
		// Деструктор родителя
		parent::__destruct();
	}
	
	public function SetFacebookApplication($AppId, $AppSecret) {
		// Установка приложения facebook, через которое будет осуществляться взаимодействие с пользователем
		FacebookSession::setDefaultApplication($AppId, $AppSecret);
	}
	
	public function GetFacebookSessionForPost($RedirectUrl) {
		// Получение сессии Facebook с правами для авто постинга
		$Permissions = array(
//			'scope'  => 'publish_actions,publish_stream,manage_pages'	// Права для поста на страницы
			'scope'  => 'publish_actions,manage_pages'	// Права для поста на страницы
		);
		$this->GetFacebookSession($RedirectUrl, $Permissions);
	}
	
	public function GetFacebookSessionForLogin($RedirectUrl) {
		// Получение сессии Facebook с правами для залогинивания
		$Permissions = array(
			'scope'  => 'email'	// Права на логин
		);
		$this->GetFacebookSession($RedirectUrl, $Permissions);
	}
	
	private function GetFacebookSession($RedirectUrl, $Permissions) {
		// Получение сессии пользователя Facebook, если ее нет - дать залогиниться, потом идет автоматический возврат на $RedirectUrl
		// Если токен сессии пользователя Facebook уже получена и сохранена в сессии - восстановить из него
		if(isset($_SESSION)&&isset($_SESSION["fb_token"])) {
			$this->FbUserSession = new FacebookSession($_SESSION["fb_token"]);
			try {
				if(!$this->FbUserSession->validate()) {
					$this->FbUserSession = null;
				}
			}
			catch(Exception $Err) {
				$this->FbUserSession = null;
				echo "Validate session error: ".$Err->getCode()." ".$Err->getMessage();	// Другие ошибки
			}
		}
		// Если сессия не восстановлена - получить новую с сайта facebook
		if($this->FbUserSession == null) {
			$LoginHelper = new FacebookRedirectLoginHelper($RedirectUrl);
			try {
				$GettedSession = $LoginHelper->getSessionFromRedirect();
			}
			catch(FacebookRequestException $Err) {
				echo "Facebook request exception: ".$Err->getCode()." ".$Err->getMessage();	// Facebook вернул ошибку
			}
			catch(Exception $Err) {
				echo "Other error: ".$Err->getCode()." ".$Err->getMessage();	// Другие ошибки
			}
			if(isset($GettedSession)) {
				// Сохранить токен сесси Facebook в сессии и возврат на $RedirectUrl
				$_SESSION["fb_token"] = $GettedSession->getToken();
				header("Location: ".$RedirectUrl);
				exit();
			}
			else {
				// Перекинуть на страницу логина пользователя в facebook, оттуда будет автоматический возврат на $RedirectUrl
				$FacebookLoginUrl = $LoginHelper->getLoginUrl($Permissions);
				header("Location: ".$FacebookLoginUrl);
				exit();
			}
		}
	}
	
	public function ResetFacebookSession() {
		// Сброс сессии Facebook.
		if(isset($_SESSION)&&isset($_SESSION["fb_token"])) unset($_SESSION["fb_token"]);
	}
	
	public function GetFbUserProfile() {
		// Получить данные пользователя Facebook
		if($this->FbUserSession!=null) {
			try {
				$Request = new FacebookRequest($this->FbUserSession, 'GET', '/me');
				$Response = $Request->execute();
				$GraphObject = $Response->getGraphObject(GraphUser::className());
				$this->FbUserProfile = $GraphObject;
			}
			catch(FacebookRequestException $Err) {
				echo "Facebook request exception: ".$Err->getCode()." ".$Err->getMessage();
			}   
		}
	}

	private function GetFbUserPermissions() {
		// Получить права пользователя Facebook
		if($this->FbUserSession!=null) {
			try {
				$Request = new FacebookRequest($this->FbUserSession, 'GET', '/me/permissions');
				$Response = $Request->execute();
				$GraphObject = $Response->getGraphObject();
				$this->FbUserPermissions = $GraphObject;
			}
			catch(FacebookRequestException $Err) {
				echo "Facebook request exception: ".$Err->getCode()." ".$Err->getMessage();
			}   
		}
	}
	
	public function PostOnUserTimeLine($Text, $Link = null, $Caption = null) {
		// Создание поста с текстом $Text в летне пользователя
		if($this->FbUserSession!=null) {
			try {
				$PostData = array();
				$PostData["message"] = $Text;
				if($Link!=null) $PostData["link"] = $Link;
				if($Caption!=null) $PostData["caption"] = $Caption;
				$Request = new FacebookRequest($this->FbUserSession, 'POST', '/me/feed', $PostData);
				$Response = $Request->execute();
				$GraphObject = $Response->getGraphObject();
			}
			catch(FacebookRequestException $Err) {
				echo "Facebook request exception: ".$Err->getCode()." ".$Err->getMessage();
			}   
		}
	}
	
	public function UploadPhotoToUserAlbum($FilePath, $Text) {
		// Загрузка картинки в альбомы пользователя. Картинка попадает в первый альбом.
		// Путь к файлу задается как: "/var/www/vn/graphic/banner/Interplanety_600x600.jpg"
		if($this->FbUserSession!=null) {
			try {
				$PostData = array(
					"source" => "@".$FilePath,
					"message" => $Text
				);
				$Request = new FacebookRequest($this->FbUserSession, 'POST', '/me/photos', $PostData);
				$Response = $Request->execute();
				$GraphObject = $Response->getGraphObject();
				echo "Uploaded.<p>";
			}
			catch(FacebookRequestException $Err) {
				echo "Facebook request exception: ".$Err->getCode()." ".$Err->getMessage();
			}   
		}
	}
	
	private function GetBusinessPageAccessToken($BusinessPageId) {
		// Получить AccessToken для бизнес-странички по ее Id
		$BusinessAccessToken = null;
		if($this->FbUserSession!=null) {
			try {
				$Request = new FacebookRequest($this->FbUserSession, 'GET', '/'.$BusinessPageId, array("fields" => "access_token"));
				$Response = $Request->execute();
				$GraphObject = $Response->getGraphObject()->asArray();
				$BusinessAccessToken = $GraphObject["access_token"];
			}
			catch(FacebookRequestException $Err) {
				echo "Facebook request exception: ".$Err->getCode()." ".$Err->getMessage();
			}   
		}
		return $BusinessAccessToken;
	}
	
	public function PostOnUserBusinessPageTimeLine($BusinessPageId, $Text, $Link = null, $Caption = null) {
		// Создание поста с текстом $Text на бизнес-страничке с $BusinessPageId
		if($this->FbUserSession!=null) {
			try {
				// Получить AccessToken для бизнес-странички
				$AccessToken = $this->GetBusinessPageAccessToken($BusinessPageId);
				// Сделать пост на бизнес-страничку
				$PostData = array();
				$PostData["message"] = $Text;
				if($Link!=null) $PostData["link"] = $Link;
				if($Caption!=null) $PostData["caption"] = $Caption;
				$PostData["access_token"] = $AccessToken;
				$Request = new FacebookRequest($this->FbUserSession, 'POST', '/'.$BusinessPageId.'/feed', $PostData);
				$Response = $Request->execute();
				$GraphObject = $Response->getGraphObject();
			}
			catch(FacebookRequestException $Err) {
				echo "Facebook request exception: ".$Err->getCode()." ".$Err->getMessage();
			}
		}
	}
}
?>