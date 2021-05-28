<?php
//---------------------------------
// Класс User
//---------------------------------
require_once("dbconnected_vn.inc.php");
require_once("quests.inc.php");
//require_once("phpbbauto.inc.php");
require_once("starsystemv_vn.inc.php");
require_once("facebookauto.inc.php");
require_once("config.inc.php");
require_once("common.inc.php");
require_once("postsaver.inc.php");
require_once("ships.inc.php");
//---------------------------------
class UserVn extends DBConnectedVn
{
	
	public function __construct() {
		// Конструктор родителя
		parent::__construct();
		// Конструктор
		
	}

	public function __destruct() {
		// Деструктор
		
		// Деструктор родителя
		parent::__destruct();
	}
	
	public function Login() {
		// Попытка логина пользователя
		$Err = "VN_ERR";	// Не переданы данные
		if(PostSaver::IsPostSaved(basename($_SERVER['PHP_SELF'])) == true) PostSaver::RestorePost(basename($_SERVER['PHP_SELF']));	// Восстановить $_POST (если он был сохранен для учета редиректов при логине через соц-сети)
		// Логин через Facebook (до обычного логина т.к. через форму идут те же данные)
		if(isset($_POST["fbbutton_x"])) {
			// Дать пользователю залогиниться в Facebook
			if(PostSaver::IsPostSaved(basename($_SERVER['PHP_SELF'])) == false) PostSaver::SavePost(basename($_SERVER['PHP_SELF']));	// Сохранить $_POST
			$Conf = new Config(Common::IncDir()."/config.xml");
			$Fb = new FacebookAuto();
			$Fb->SetFacebookApplication($Conf->Data["facebook"]["loginapp"]["id"], $Conf->Data["facebook"]["loginapp"]["secret"]);	// подключить приложение
			$Fb->GetFacebookSessionForLogin("http://www.interplanety.ru/login");	// залогиниться в facebook
			// Получить Id пользователя в Facebook
			$Fb->GetFbUserProfile();
			$FbUserId = "fb".$Fb->FbUserProfile->getId();
			// По Id из Facebook получить данные для логина
			$this->Sql->SqlQuery = "select * from vn_user where social_id = '".$this->Sql->Escape($FbUserId)."';";
			$this->Sql->Exec();
			if($SQLRez = $this->Sql->SqlRez) {
				if($this->Sql->Rows($SQLRez)==1) {
					// Если уже зарегистрирован
					$tmp = $SQLRez->fetch_array();
					$_SESSION["vn_id"] = $tmp["id"];
					$_SESSION["vn_rights"] = $tmp["type"];
					$_SESSION["vn_login"] = $tmp["login"];
					// Проверить не истекли ли права если доступ премиум
					$this->CheckRights($_SESSION["vn_id"]);
					// Обновить дату последнего захода
					$this->UpdateLastLoginDate($_SESSION["vn_id"]);
					$Err = "VN_OK";
				}
				elseif($this->Sql->Rows($SQLRez)==0) {
					// Первый заход
					// Зарегистрировать
					$NewUserId = $this->CreateNewUser($Fb->FbUserProfile->getName(), NULL, $Fb->FbUserProfile->getProperty("email"), $FbUserId);
					// Залогинить
					$_SESSION["vn_id"] = $NewUserId;
					$_SESSION["vn_rights"] = "F";	// Новый пользователь создается с правами F
					$_SESSION["vn_login"] = $Fb->FbUserProfile->getName();
					$this->UpdateLastLoginDate($NewUserId);
					// Новый пользователь зарегистрирован
					$Err = "VN_OK";
				}
				$this->Sql->FreeResult($SQLRez);
			}
			PostSaver::ClearSavedPost(basename($_SERVER['PHP_SELF']));
//			$Fb->ResetFacebookSession();
			return $Err;
		}
		// Просто логин
		if(isset($_POST["vn_login"])&&$_POST["vn_login"]!=''&&isset($_POST["vn_password"])&&$_POST["vn_password"]!='') {
			$this->Sql->SqlQuery = "select * from vn_user where login='".$this->Sql->Escape($_POST["vn_login"])."' and password=password('".$this->Sql->Escape($_POST["vn_password"])."');";
			$this->Sql->Exec();
			if($SQLRez = $this->Sql->SqlRez) {
				if($this->Sql->Rows($SQLRez)==1) {
					$tmp = $SQLRez->fetch_array();
					$_SESSION["vn_id"] = $tmp["id"];
					$_SESSION["vn_rights"] = $tmp["type"];
					$_SESSION["vn_login"] = $tmp["login"];
					// Проверить не истекли ли права если доступ премиум
					$this->CheckRights($_SESSION["vn_id"]);
					// Обновить дату последнего захода
					$this->UpdateLastLoginDate($_SESSION["vn_id"]);
					$Err = "VN_OK";
				}
				else $Err = "VN_LOGIN_INCORRECT";
				$this->Sql->FreeResult($SQLRez);
			}
			return $Err;
		}
		// Логин через регистрацию нового пользователя - регистрируем и сразу залогиниваемся
		if(isset($_POST["vn_newlogin"])&&$_POST["vn_newlogin"]!=''&&isset($_POST["vn_newpassword"])&&$_POST["vn_newpassword"]!='') {
			// Проверить правильность
			$Err = "";
			if(!(isset($_POST["vn_licen_accepted"])&&$_POST["vn_licen_accepted"]=="on")) $Err = $Err."VN_LICENCE_NOT_ACCEPTED";			// Не приняты условия
			if($this->UserExists($_POST["vn_newlogin"])==true) $Err = $Err."VN_LOGIN_EXISTS";		// Логин уже существует
			if($this->EmailExists($_POST["vn_newemail"])==true) $Err = $Err."VN_EMAIL_EXISTS";		// Email уже существует
			if($_POST["vn_newpassword"]!=$_POST["vn_newpassword_conf"]) $Err = $Err."VN_PASSWORD_NOT_EQUAL";	// Пароль и подтверждение не совпадают
			if(!isset($_POST["vn_hfield"])||$_POST["vn_hfield"]!='') $Err = $Err."VN_BOT_DETECTED";	// Пытается зарегистрироваться бот - Если поля hfield нет (форма отправлена без генерации ее с помощью JavaScript-функции) или оно не пустое (бот заполняет все поля)
			if($Err == "") {
				// Создать нового пользователя
				$NewUserId = $this->CreateNewUser($_POST["vn_newlogin"], $_POST["vn_newpassword"], $_POST["vn_newemail"]);
				// Сразу залогиниваем его
				$_SESSION["vn_id"] = $NewUserId;
				$_SESSION["vn_rights"] = "F";	// Новый пользователь создается с правами F
				$_SESSION["vn_login"] = $_POST["vn_newlogin"];
				$this->UpdateLastLoginDate($NewUserId);
				// Создать пользователя на форуме. Не активен до подтверждения Email
//				$PhpBB = new PhpbbAuto();
//				$PhpBB->CreateNewUser($_POST["vn_newlogin"], $_POST["vn_newpassword"], $_POST["vn_newemail"], true, true);
				// Новый пользователь зарегистрирован
				$Err = "VN_OK";
			}
		}
		return $Err;
	}
	
	public function Logoff() {
		// Разлогин пользователя
		if(isset($_SESSION["vn_id"])) unset($_SESSION["vn_id"]);
		if(isset($_SESSION["vn_login"])) unset($_SESSION["vn_login"]);
		if(isset($_SESSION["vn_rights"])) unset($_SESSION["vn_rights"]);
		$Fb = new FacebookAuto();
		$Fb->ResetFacebookSession();
	}
	
	public function UserExists($Login) {
		// Проверить логин на существование
		if($Login=="") return true;
		// Проверить в игре
		$Rez = false;
		$this->Sql->SqlQuery = "select login from vn_user where login='".$this->Sql->Escape($Login)."';";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			if($this->Sql->Rows($SQLRez)>0) $Rez = true;
			$this->Sql->FreeResult($SQLRez);
		}
		// Проверить на форуме
//		$PhpBB = new PhpbbAuto();
//		if($PhpBB->UserExists($Login)==true) $Rez = true;
		return $Rez;
	}
	
	public function EmailExists($Email) {
		// Проверить Email на существование
		if($Email=="") return true;
		// В игре
		$Rez = false;
		$this->Sql->SqlQuery = "select email from vn_user where email='".$this->Sql->Escape($Email)."';";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			if($this->Sql->Rows($SQLRez)>0) $Rez = true;
			$this->Sql->FreeResult($SQLRez);
		}
		// На форуме
//		$PhpBB = new PhpbbAuto();
//		if($PhpBB->EmailExists($Email)==true) $Rez = true;
		return $Rez;
	}
	
	public function CreateNewUser($Login, $Password, $Email, $SocialId = NULL) {
		// Создание нового пользователя
		// vn_user
		if($SocialId == NULL) {
			// Обычная регистрация
			$this->Sql->SqlQuery = "insert into vn_user (login,password,email) values ('".$this->Sql->Escape($Login)."',PASSWORD('".$this->Sql->Escape($Password)."'),'".$this->Sql->Escape($Email)."');";
		}
		else {
			// Регистрация через facebook
			$this->Sql->SqlQuery = "insert into vn_user (login, email, social_id) values ('".$this->Sql->Escape($Login)."', '".$this->Sql->Escape($Email)."', '".$this->Sql->Escape($SocialId)."');";
		}
		$this->Sql->Exec();
		// Вернуть Id
		$this->Sql->SqlQuery = "select id from vn_user where login='".$this->Sql->Escape($Login)."'; ";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			$tmp = $SQLRez->fetch_array();
			$UserId = $tmp["id"];
			$this->Sql->FreeResult($SQLRez);
		}
		// vn_user_connections
		$this->Sql->SqlQuery = "insert into vn_user_connections (user_id,read_buff,write_buff) values ('".$UserId."','','');";
		$this->Sql->Exec();
		// vn_user_opt
		$this->Sql->SqlQuery = "insert into vn_user_opt (user_id) values ('".$UserId."');";
		$this->Sql->Exec();
		// vn_user_data
		$this->Sql->SqlQuery = "insert into vn_user_data (user_id) values ('".$UserId."');";
		$this->Sql->Exec();
		// vn_user_ships
		// Пока тест - выдается МККДС-1 Prot. Потом будет выдаваться простой МККДС-1
		$ShipsManager = new Ships();
		$ShipsManager->AddShipToUser($UserId, 2, 9, 9);	// МККДС-1 Prot (2) на Луну (9)
		// vn_user_quests
		$Qst = new Quests();
		$Qst->AcceptQuest($UserId,1,1);	// Интро
		$Qst->AcceptQuest($UserId,2,1);	// LevelUp
		// vn_user_starsystem
		// Пока тест - выдаются 5 бонусных планет и 5 орбит
		$USSV = new StarSystemVVn();
		$USSV->GetVirtualObject(27, $UserId);	// Солнце
		$USSV->GetVirtualObject(28, $UserId);	// Земля
		$USSV->GetVirtualObject(29, $UserId);	// Луна
		$USSV->GetVirtualObject(30, $UserId);	// Венера
		$USSV->GetVirtualObject(31, $UserId);	// Марс
		$USSV->GetVirtualObject(24, $UserId);	// Виртуальная орбита
		$USSV->GetVirtualObject(24, $UserId);	// Виртуальная орбита
		$USSV->GetVirtualObject(24, $UserId);	// Виртуальная орбита
		$USSV->GetVirtualObject(24, $UserId);	// Виртуальная орбита
		// Вернуть полученный $UserId
		return $UserId;
	}
	
	public function DeleteOldUsers() {
		// Удаление старых пользователей (inpdate,lastlogin,premdate < now() + 3650 дней) - пока пользователей мало - периуд удаления = 10 лет незахода
		// Выполняем при регистрации нового пользователя
		$this->Sql->SqlQuery = "delete from vn_user where (inpdate + interval 3650 day > now() or lastlogin + interval 3650 day > now() or premdate + interval 3650 day > now()) is null;";
		$this->Sql->Exec();
	}

	public function GetOptionsXML($Id,$XMLDoc,$RootNode) {
		// Получить список настроек пользователя по его id в виде XML-узлов (добавить в $XMLDoc в узел $RootNode)
		$Rez = "";
		$this->Sql->SqlQuery = "select vn_user.id,vn_user_opt.show_orb from vn_user inner join vn_user_opt on vn_user.id=vn_user_opt.user_id where vn_user.id='".$this->Sql->Escape($Id)."';";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			while($tmp = $SQLRez->fetch_assoc()) {
				while (list($key, $val) = each($tmp)) {
					switch($key) {
						case "id":	// id - не выводим
							break;
						default:
							$Node = $XMLDoc->createElement($key);
							$Value = $XMLDoc->createTextNode($val);
							$Node->appendChild($Value);
							$RootNode->appendChild($Node);
					}
				}
			}
			$this->Sql->FreeResult($SQLRez);
		}
	}

	public function SaveOptions($Id) {
		// Сохранить настройки пользователя по его id
		$this->Sql->SqlQuery = "update vn_user_opt set show_orb='".$this->Sql->Escape($_REQUEST['show_orb'])."'  where vn_user_opt.user_id='".$this->Sql->Escape($Id)."';";
		$this->Sql->Exec();
	}

	public function GetDataXML($Id,$XMLDoc,$RootNode) {
		// Получить данные пользователя по его id в виде XML-узлов (добавить в $XMLDoc в узел $RootNode)
		$Rez = "";
		$this->Sql->SqlQuery = "select u.id, ud.level, ud.exp, l.exp as next_level_exp, ud.money, ud.crystals from vn_user u inner join vn_user_data ud on u.id = ud.user_id left outer join vn_level l on (ud.level+1)=l.level where u.id='".$this->Sql->Escape($Id)."';";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			while($tmp = $SQLRez->fetch_assoc()) {
				while (list($key, $val) = each($tmp)) {
					switch($key) {
						case "id":	// id - не выводим
							break;
						default:
							$Node = $XMLDoc->createElement($key);
							if($val==NULL) $Value = $XMLDoc->createTextNode("0");	// Next_level_exp на максимальном уровне
							else $Value = $XMLDoc->createTextNode($val);
							$Node->appendChild($Value);
							$RootNode->appendChild($Node);
					}
				}
			}
			$this->Sql->FreeResult($SQLRez);
		}
	}

	public function GetUserLevel($UserId) {
		// Получить уровень пользователя по его id
		$Rez = 0;
		$this->Sql->SqlQuery = "select ud.level from vn_user u inner join vn_user_data ud on u.id = ud.user_id where u.id='".$this->Sql->Escape($UserId)."';";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			while($tmp = $SQLRez->fetch_array()) {
				$Rez = $tmp["level"];
			}
			$this->Sql->FreeResult($SQLRez);
		}
		return $Rez;
	}
	
	public function GetUserGold($UserId) {
		// Получить деньги пользователя по его id
		$Rez = 0;
		$this->Sql->SqlQuery = "select ud.money from vn_user_data ud where ud.user_id='".$this->Sql->Escape($UserId)."';";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			while($tmp = $SQLRez->fetch_array()) {
				$Rez = $tmp["money"];
			}
			$this->Sql->FreeResult($SQLRez);
		}
		return $Rez;
	}
	
	public function UpdateMoney($UserId,$Money) {
		// Добавить пользователю $Money денег
		$this->Sql->SqlQuery = "update vn_user_data set money = money + ".$this->Sql->Escape($Money)." where user_id=".$this->Sql->Escape($UserId).";";
		$this->Sql->Exec();
	}

	public function GetUserCrystals($UserId) {
		// Получить кристаллы пользователя по его id
		$Rez = 0;
		$this->Sql->SqlQuery = "select ud.crystals from vn_user_data ud where ud.user_id='".$this->Sql->Escape($UserId)."';";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			while($tmp = $SQLRez->fetch_array()) {
				$Rez = $tmp["crystals"];
			}
			$this->Sql->FreeResult($SQLRez);
		}
		return $Rez;
	}

	public function UpdateCrystals($UserId,$Crystals) {
		// Добавить пользователю $Crystals кристаллов
		$this->Sql->SqlQuery = "update vn_user_data set crystals = crystals + ".$this->Sql->Escape($Crystals)." where user_id=".$this->Sql->Escape($UserId).";";
		$this->Sql->Exec();
	}

	public function GetUserExp($UserId) {
		// Получить опыт пользователя по его id
		$Rez = 0;
		$this->Sql->SqlQuery = "select ud.exp from vn_user_data ud where ud.user_id='".$this->Sql->Escape($UserId)."';";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			while($tmp = $SQLRez->fetch_array()) {
				$Rez = $tmp["exp"];
			}
			$this->Sql->FreeResult($SQLRez);
		}
		return $Rez;
	}

	public function GetNextLevelExp($Level) {
		// Получить количество опыта для перехода на следующий уровень с уровня $Level
		$Rez = 0;
		$this->Sql->SqlQuery = "select l.exp from vn_level l where l.level=".$this->Sql->Escape($Level)."+1;";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			while($tmp = $SQLRez->fetch_array()) {
				$Rez = $tmp["exp"];
			}
			$this->Sql->FreeResult($SQLRez);
		}
		return $Rez;
	}
	
	public function GetShipsCount($Id) {
		// Получить количество кораблей пользователя по его id
		$Rez = 0;
		$this->Sql->SqlQuery = "select count(id) as ships_count from vn_user_ships where user_id='".$this->Sql->Escape($Id)."';";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			while($tmp = $SQLRez->fetch_array()) {
				$Rez = $tmp["ships_count"];
			}
			$this->Sql->FreeResult($SQLRez);
		}
		return $Rez;
	}
	
	public function UpdateExp($UserId,$Exp) {
		// Обновить опыт игрока $UserId - добавить $Exp опыта
		// Обновить опыт
		$this->Sql->SqlQuery = "update vn_user_data set exp=exp+".$this->Sql->Escape($Exp)." where user_id=".$this->Sql->Escape($UserId).";";
		$this->Sql->Exec();
		// Если произошел переход за уровень  - поднять уровень
		// Проверить
		$this->Sql->SqlQuery = "select ud.level,ud.exp,l.level as new_level,l.exp as level_up_exp from vn_user_data ud left outer join vn_level l on ud.exp>=l.exp where user_id=".$this->Sql->Escape($UserId)." order by l.exp desc limit 1;";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			while($tmp = $SQLRez->fetch_array()) {
				if($tmp["level"]<$tmp["new_level"]&&$tmp["exp"]>=$tmp["level_up_exp"]) {
					// Если опыта больше чем нужно на уровень - обновить
					$this->Sql->SqlQuery = "update vn_user_data set level=".$tmp["new_level"]." where user_id=".$this->Sql->Escape($UserId).";";
					$this->Sql->Exec();
					// Обновить условия квестов
					$Qst = new Quests();
					for($i=0; $i<($tmp["new_level"]-$tmp["level"]); $i++) {
						// Рост уровня в квесте засчитывать по 1 уровню, чтобы не было скачков через несколько уровней (можно перескочить через получение квестов и т.п.)
						$Cond = $Qst->FormFinishConditionLevelUp(1);
						$Qst->CheckFinishConditions($UserId,$Cond);
					}
				}
			}
			$this->Sql->FreeResult($SQLRez);
		}
	}
	
	public function CheckRights($Id) {
		// Проверка на права доступа для премиум аккаунта
		$this->Sql->SqlQuery = "select type, premdate from vn_user where id='".$this->Sql->Escape($Id)."';";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			$tmp = $SQLRez->fetch_array();
			// Права Р и (срок премиума до конца дня < текущего времени) -> отключить премиум
			if($tmp["type"]=='P'&&strtotime($tmp["premdate"])+86400<time()) {
				$this->StopPremium($Id);
			}
			// Права F и (срок премиума до конца дня > текущего времени) -> включить премиум
			if($tmp["type"]=='F'&&$tmp["premdate"]!="0000-00-00"&&strtotime($tmp["premdate"])+86400>=time()) {
				$this->OpenPremium($Id);
			}
			$this->Sql->FreeResult($SQLRez);
		}
	}

	public function StopPremium($Id) {
		// Остановить премиум для пользователя $Id
		$this->Sql->SqlQuery = "update vn_user set type='F' where id='".$this->Sql->Escape($Id)."';";
		$this->Sql->Exec();
		$_SESSION["vn_rights"] = 'F';
	}

	public function OpenPremium($Id) {
		// Открыть премиум для пользователя $Id
		$this->Sql->SqlQuery = "update vn_user set type='P' where id='".$this->Sql->Escape($Id)."';";
		$this->Sql->Exec();
		$_SESSION["vn_rights"] = 'P';
	}

	public function UpdateLastLoginDate($Id) {
		// Обновить дату последнего захода для пользователя $Id
		$this->Sql->SqlQuery = "update vn_user set lastlogin=now() where id='".$this->Sql->Escape($Id)."';";
		$this->Sql->Exec();
	}
}
?>