<?php
//---------------------------------
// Вконтакте (vk.com) автоматизация работы
// Для взаимодействия с vk api нужно:
//	создать приложение в vk
//		разработчикам (внизу страницы) - создать приложение
//			название: interplanet
//			тип: standalone
//			во вкладке "настройки" прописать:
//				OpenApi
//					Адрес сайта:	http://www.interplanety.ru
//					Тематика:		игры
//					Базовый домен:	interplanety.ru
//			Сохраняем id приложения
//	Для получения AccessToken вызвать один раз провести авторизацию - потом переделать через curl, чтобы проводилась каждый раз автоматом
//		Создать файл и выполнить код:
//			$Vk = new VkAuto();
//			$VkParams = array('offline','wall');
//			$Vk->ApiGetAccessToken($VkParams);
//		После логина и нажатия "разрешить" в строке браузера будет ссылка, в которой есть AccessToken и UserId - вставить их в код
//			(Можно было бы автоматически, но redirect_uri должен быть от vk, иначе не дает доступа к стене сообщений)
//		Каждая повтораня авторизация создает новый AccessToken
//	Далее работа с vk api осуществляется через методы класса
//---------------------------------
require_once("dbconnected_vn.inc.php");
require_once("htmlex.inc.php");
//---------------------------------
class VkAuto extends DBConnectedVn
{
	
	private $AppId;	// Id приложения в vk
	private $AccessToken;	// AccessToken vk
	private $UserId;	// Id пользователя vk
	private $GroupId;	// Id сообщества или группы (берется из адресной строки при переходе в группу)
	
	public function __construct() {
		// Конструктор родителя
		parent::__construct();
		// Конструктор
		$this->AppId = '111';
		$this->AccessToken = '222';
		$this->UserId = '333';
		$this->GroupId = '-444';	// Перед Id группы ставится тире
	}

	public function __destruct() {
		// Деструктор
		
		// Деструктор родителя
		parent::__destruct();
	}
	
	
	public function ApiGetAccessToken($Params) {
		// Авторизация в vk api
		$AuthParams = array(
			'client_id' => $this->AppId,
			'scope' => implode(',',$Params),
			'redirect_uri' => 'https://oauth.vk.com/blank.html',	// Стандартный для vk. Если ставить свой - не дает разрешения на работу со стеной
			'response_type' => 'token'
		);
		// Редирект на сайт vk для получения AccessToken (будет в строке браузера в параметрах)
		header("Content-type: text/html; charset=utf-8");
		header("Location: https://oauth.vk.com/authorize?".urldecode(http_build_query($AuthParams)));
//		// Попытка сделать получение AccessToken с возвратом с сервера vk. Когда будет curl попробовать сделать через него.
//		echo file_get_contents("https://oauth.vk.com/authorize?".urldecode(http_build_query($AuthParams)));
	}
	
	private function ApiExec($FunctionName, array $Params = array()) {
		// Выполнение функции api для vk.com с именем $FunctionName и параметрами, указанными в массиве $Params
		$Params['access_token'] = $this->AccessToken;
		$Content = file_get_contents('https://api.vk.com/method/'.$FunctionName.'?'.http_build_query($Params));
		return $Content;
	}
	
	public function AddPost($Text, $Link = "") {
		// Добавление поста с текстом $Text на стену. $Link - ссылка на основной источник данных.
		// Текст передавать в кодировке utf-8
		$Params = array(
			'owner_id' => $this->GroupId,
			'from_group' => 1,	// 1 - запись делается от имени группы, 0 - от имени пользователя
			'message' => $Text	// Текст идет в кодировке Utf-8
		);
		if($Link!="") {
			// Ссылку - в текстовый вид. Т.к. ссылка идет через параметры GET, чтобы параметры ссылки не смешивались с параметрами самого запроса
			$Hx = new HTMLEx();
			$Params['attachments'] = $Hx->UrlToTxt($Link);
		}
		$Rez = json_decode($this->ApiExec("wall.post",$Params));
		$NewPostId = $Rez->response->post_id;
		return $NewPostId;
	}
	
	public function CheckByExternUrl($ExternUrl, $CheckCount = 1) {
		// Проверить, существует ли пост с приложенной ссылкой $ExternUrl. Проверяется $CheckCount последних постов.
		$Params = array(
			'owner_id' => $this->GroupId,
			'count' => $CheckCount
		);
//		$Posts = $this->ApiExec("wall.get",$Params);
//		echo $Posts;
//		return true;
		// Ссылку - в текстовый вид 2 раза - т.к. в vk ссылка уходила в текстовом виде и приходит обратно еще раз конвертированная в текстовый вид
		$Hx = new HTMLEx();
		$ExternUrl = $Hx->UrlToTxt($ExternUrl);
		$ExternUrl = $Hx->UrlToTxt($ExternUrl);
		$Posts = json_decode($this->ApiExec("wall.get",$Params));
		$Rez = false;
		for($i=1; $i<=$CheckCount; $i++) {
			if(isset($Posts->response[$i]->media->share_url)&&$Posts->response[$i]->media->share_url==$ExternUrl) {
				$Rez = true;
				break;
			}
		}
		return $Rez;
	}
}
?>