<?php
//---------------------------------
// PhpBB автоматизация работы с форумом
//---------------------------------
require_once("dbconnected_vn.inc.php");
require_once("common.inc.php");
//---------------------------------
// Назначить необходимые глобальные константы
define('IN_PHPBB', true);
$phpbb_root_path = Common::ForumDir().'/';
$phpEx = 'php';
// Вызвать необходимые глобальные модули (т.к. phpbb - частично процедурный)
require($phpbb_root_path."common.php");	// Вызов создания постов от имени пользователя - получение разных глобальных данных
require_once($phpbb_root_path."includes/functions_posting.php");	// Для submit_post
require_once($phpbb_root_path."includes/functions_user.php");		// Для работы с user_add
require_once($phpbb_root_path."includes/functions_messenger.php");	// Для работы с $messenger
//---------------------------------
class PhpbbAuto extends DBConnectedVn
{
	
	public $ForumHostPath;		// Путь к форуму (c домена)
	public $DBName;				// Название базы данных форума
	public $StayLogin;			// true - оставаться залогиненным после завершения действий, false - закрыть сессию
	
	public function __construct() {
		// Конструктор родителя
		parent::__construct();
		// Конструктор
		$this->ForumHostPath = $_SERVER['HTTP_HOST']."/forum/";
		$this->DBName = "vnforum";
		$this->StayLogin = false;
	}

	public function __destruct() {
		// Деструктор
		if($this->StayLogin==false) $this->CloseUserSession();
		// Деструктор родителя
		parent::__destruct();
	}
	
	public function OpenUserSession($UserId) {
		// Открытие сессии для пользователя $UserId
		global $user;	// Т.к. обращение идет к глобальным объектам (созданным в процедурном коде) - обозначить как глобальные
		global $auth;
		$user->session_begin(false); // no update_session_page
		$user->session_create($UserId, false, false, false);
		$auth->acl($user->data);
		$user->setup();
	}
	
	public function CloseUserSession() {
		// Закрытие сессии для текущего пользователя
		global $user;	// Т.к. $user - глобальный объект
		$user->session_kill();
	}
	
	public function CreatePost($ForumId, $TopicId, $Title, $Text) {
		// Создание поста на форуме $ForumId в теме $TopicId от имени текущего пользователя с текстом $Text. Передавать в кодировке Utf-8
		// Для создания поста сначала нужно открыть сессию для пользователя через OpenUserSession
		// Заголовок и тело поста
		// Переменные для submit_post
		$poll = $uid = $bitfield = $options = ''; 
		generate_text_for_storage($Title, $uid, $bitfield, $options, false, false, false);
		generate_text_for_storage($Text, $uid, $bitfield, $options, true, true, true);
		$data = array( 
			'forum_id'			=> $ForumId,
			'topic_id'			=> $TopicId,
			'icon_id'			=> false,
			'enable_bbcode'		=> true,
			'enable_smilies'	=> true,
			'enable_urls'		=> true,
			'enable_sig'		=> true,
			'message'			=> $Text,
			'message_md5'		=> md5($Text),
			'bbcode_bitfield'	=> $bitfield,
			'bbcode_uid'		=> $uid,
			'post_edit_locked'	=> 0,
			'topic_title'		=> $Title,
			'notify_set'		=> false,
			'notify'			=> false,
			'post_time' 		=> 0,
			'forum_name'		=> '',
			'enable_indexing'	=> true,
		);
		// Отправка поста
		submit_post('reply', $Title, '', POST_NORMAL, $poll, $data);
		// Возвращается ссылка на созданный пост
		return "http://".$_SERVER['HTTP_HOST']."/forum/viewtopic.php?f=".$ForumId."&t=".$TopicId."&p=".$data['post_id']."#p".$data['post_id'];
		}
		
	public function CreateNewUser($Login, $Password, $Mail, $ActivateByMail=false, $UserNew=false) {
		// Создание нового пользователя 
		// $ActivateByMail = false - автоактивирование, true - активация по почте
		// $UserNew = true - пользователь добавляется дополниельно в группу "новые пользователи" из которой уйдет после определенного числа сообщений
		if($ActivateByMail==false) {
			$user_row = array(
				'username'				=> $Login,
				'user_password'			=> phpbb_hash($Password),
				'user_email'			=> $Mail,
				'group_id'				=> 2,		// В группу - зарегистрированные пользователи
				'user_timezone'			=> +4.0,	// Временная зона +4 (Москва)
				'user_lang'				=> 'ru',
				'user_type'				=> USER_NORMAL,
				'user_ip'				=> $this->GetUserIp(),
				'user_regdate'			=> time(),
			);
			if($UserNew===true) {
				$user_row['user_new'] = 1;
				$user_row['group_id'] = 7;	// По умолчанию будет группа 7 - новые пользователи
			}
			
			$user_id = user_add($user_row);
			
			if($UserNew===true) {
				$this->AddUserToGroup($user_id, 2);	// Надо еще добавить и в зарегистрированные
			}
			
		}
		else {
			// Создается неактивный пользователь с подтверждением по e-mail
			// Переменные для user_row
			$user_actkey = md5(rand(0, 100) . time());
			$user_actkey = substr($user_actkey, 0, rand(8, 12));
			$user_row = array(
				'username'				=> $Login,
				'user_password'			=> phpbb_hash($Password),
				'user_email'			=> $Mail,
				'group_id'				=> 2,		// В группу - зарегистрированные пользователи
				'user_timezone'			=> +4.0,	// Временная зона +4 (Москва)
				'user_dst'				=> $is_dst,
				'user_lang'				=> 'ru',
				'user_type'				=> USER_INACTIVE,
				'user_actkey'			=> $user_actkey,
				'user_ip'				=> $this->GetUserIp(),
				'user_regdate'			=> time(),
				'user_inactive_reason'	=> INACTIVE_REGISTER,
				'user_inactive_time'	=> time(),
			);
			if($UserNew===true) {
				$user_row['user_new'] = 1;
				$user_row['group_id'] = 7;	// По умолчанию будет группа 7 - новые пользователи
			}
			
			$user_id = user_add($user_row);
			
			if($UserNew===true) {
				$this->AddUserToGroup($user_id, 2);	// Надо еще добавить и в зарегистрированные
			}
			
			if($user_id!==false) {
				// Отправить письмо об активации
				$this->SentActivationMail($user_id, $Mail, $user_actkey);
			}
		}
	}
	
	public function SentActivationMail($UserId) {
		// Отправка пользователю письма об активации
		// Получить данные пользователя
		$UData = $this->GetUserData($UserId);
		$email_template = 'user_welcome_inactive';
		$messenger = new messenger(false);
		$messenger->template($email_template, $UData['Lang']);
		$messenger->to($UData['Mail'], $UData['Name']);
		$messenger->assign_vars(array(
			'USERNAME'		=> htmlspecialchars_decode($UData['Name']),
			'U_ACTIVATE'	=> $this->ForumHostPath."ucp.php?mode=activate&u=".$UserId."&k=".$UData["ActKey"])
		);
		$messenger->send(NOTIFY_EMAIL);
	}
	
	public function ActivateNewRegisteredUser($UserId) {
		// Активация нового пользователя с $Userid
		user_active_flip('activate', $UserId);
	}
	
	public function AddUserToGroup($UserId, $GroupNumber) {
		// Добавление пользователя $UserId в группу с номером $GroupNumber
		group_user_add($GroupNumber,$UserId);
	}
	
	public function GetUserData($UserId) {
		// Получение данных по id пользователя
		// Беру напрямую из таблицы т.к. так и не разобрался, как взять данные для неактивированного пользователя средствами phpbb
		$UserData = array();
		$this->Sql->SqlQuery = "select * from ".$this->DBName.".phpbb_users where user_id='".$this->Sql->Escape($UserId)."';";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			while($tmp = $SQLRez->fetch_array()) {
				$UserData["Name"] = $tmp["username"];
				$UserData["Mail"] = $tmp["user_email"];
				$UserData["ActKey"] = $tmp["user_actkey"];
				$UserData["Lang"] = $tmp["user_lang"];
			}
			$this->Sql->FreeResult($SQLRez);
		}
		return $UserData;
	}
	
	public function UserExists($UserName) {
		// Проверка на существование пользователя с ником $UserName
		// Напрямую из базы
		$Rez = false;
		$this->Sql->SqlQuery = "select username from ".$this->DBName.".phpbb_users where username='".$this->Sql->Escape($UserName)."';";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			if($this->Sql->Rows($SQLRez)>0) $Rez = true;
			$this->Sql->FreeResult($SQLRez);
		}
		return $Rez;
	}
	
	public function EmailExists($Email) {
		// Проверка на существование пользователя с ником $UserName
		// Напрямую из базы
		$Rez = false;
		$this->Sql->SqlQuery = "select user_email from ".$this->DBName.".phpbb_users where user_email='".$this->Sql->Escape($Email)."';";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			if($this->Sql->Rows($SQLRez)>0) $Rez = true;
			$this->Sql->FreeResult($SQLRez);
		}
		return $Rez;
	}
	
	private function GetUserIp() {
		// Возвращает IP пользователя
		$Ip = '';
		if(!empty($_SERVER['HTTP_CLIENT_IP']))  $Ip = $_SERVER['HTTP_CLIENT_IP'];
		elseif(!empty($_SERVER['HTTP_X_FORWARDED_FOR'])) $Ip = $_SERVER['HTTP_X_FORWARDED_FOR'];
		else $Ip=$_SERVER['REMOTE_ADDR'];
		return $Ip;
	}
}
?>