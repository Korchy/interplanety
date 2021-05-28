<?php
//---------------------------------
require_once("starsystem_vn.inc.php");
require_once("quests.inc.php");
require_once("xmlex.inc.php");
	// include всех объектов виртуальной звездной системы, объекты генерятся по имени из vn_object
require_once("starv.inc.php");
require_once("orbitv.inc.php");
require_once("planetv.inc.php");
//---------------------------------
class StarSystemVVn extends StarSystemVn
{

	public function __construct() {
		// Конструктор родителя
		parent::__construct();
		// Конструктор
		$this->XEx = new XMLEx();
	}

	public function __destruct() {
		// Деструктор
		unset($this->XEx);
		// Деструктор родителя
		parent::__destruct();
	}
	
	public function GetStarSystemXML($Id) {
		// Возвращает в формате XML данные по действующим объектам виртуальной звездной системы
		// Если $Id==null - возвращается вся система, если нет - только один объект с нужным Id
		$UserId = $_SESSION["vn_id"];	// id пользователя
		$Doc = new DOMDocument('1.0','utf-8');
		$Sector = $Doc->createElement('V');
		if($Id==null) {
			// Вернуть данные по все системе
			$this->Sql->SqlQuery = "select uss.id, uss.sub_id, uss.s_point_x, uss.s_point_y, uss.s_point_z, uss.spaceobject_id, so.type from vn_user_starsystem uss left outer join vn_spaceobject so on uss.spaceobject_id=so.id where (!isnull(uss.sub_id) or !isnull(uss.s_point_x)) and uss.user_id='".$this->Sql->Escape($UserId)."' order by id, sub_id;";
		}
		else {
			// Вернуть данные только по одному объекту с $Id
			$this->Sql->SqlQuery = "select uss.id, uss.sub_id, uss.s_point_x, uss.s_point_y, uss.s_point_z, uss.spaceobject_id, so.type from vn_user_starsystem uss left outer join vn_spaceobject so on uss.spaceobject_id=so.id where uss.id='".$this->Sql->Escape($Id)."' and uss.user_id='".$this->Sql->Escape($UserId)."';";
		}
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			// Создать по полученным данным XML-документ
			while($tmp = $SQLRez->fetch_array()) {
				// Для каждого объекта свой узел
				// Получить узел с данными из таблицы объекта
				$SO = new $tmp["type"]();
				// Для виртуальных орбит - по id в vn_user_starsystem т.к. они все spaceobject=24, а параметры редактируются пользователем по id в системе пользователя
				if($tmp["type"]=="OrbitV") $SOXML = $SO->GetFullInfo($tmp["spaceobject_id"],$tmp["id"]);
				else $SOXML = $SO->GetInfo($tmp["spaceobject_id"]);
				// В каждый сгенерированный для объекта узел добавить данные из vn_user_starsystem
				// spaceobject_id в аттрибут
				$SOXML->documentElement->setAttribute("id",$tmp["spaceobject_id"]);
				// id
				$SubNode = $Doc->createElement("id");
				$Value = $Doc->createTextNode($tmp["id"]);
				$SubNode->appendChild($Value);
				$SOXML->documentElement->appendChild($SOXML->importNode($SubNode,true));
				// sub_id
				if(!is_null($tmp["sub_id"])) {
					$SubNode = $Doc->createElement("sub_id");
					$Value = $Doc->createTextNode($tmp["sub_id"]);
					$SubNode->appendChild($Value);
					$SOXML->documentElement->appendChild($SOXML->importNode($SubNode,true));
				}
				// s_point_x
				if(!is_null($tmp["s_point_x"])) {
					$SubNode = $Doc->createElement("s_point_x");
					$Value = $Doc->createTextNode($tmp["s_point_x"]);
					$SubNode->appendChild($Value);
					$SOXML->documentElement->appendChild($SOXML->importNode($SubNode,true));
				}
				// s_point_y
				if(!is_null($tmp["s_point_y"])) {
					$SubNode = $Doc->createElement("s_point_y");
					$Value = $Doc->createTextNode($tmp["s_point_y"]);
					$SubNode->appendChild($Value);
					$SOXML->documentElement->appendChild($SOXML->importNode($SubNode,true));
				}
				// s_point_z
				if(!is_null($tmp["s_point_z"])) {
					$SubNode = $Doc->createElement("s_point_z");
					$Value = $Doc->createTextNode($tmp["s_point_z"]);
					$SubNode->appendChild($Value);
					$SOXML->documentElement->appendChild($SOXML->importNode($SubNode,true));
				}
				// Добавить полученный узел с полной информацией по объекту в дерево
				$Sector->appendChild($Doc->importNode($SOXML->documentElement,true));
			}
			$this->Sql->FreeResult($SQLRez);
		}
		$Doc->appendChild($Sector);
		return $Doc;
	}

	public function GetItemsFromStorageXML($UserId) {
		// Возвращает список призов из хранилища виртуальной звездной системы
		// Объект XML
		$Doc = new DOMDocument('1.0','utf-8');
		$Storage = $Doc->createElement('vs');
		// Получить данные
		$this->Sql->SqlQuery = "select uss.spaceobject_id from vn_user_starsystem uss where (isnull(uss.sub_id) and isnull(uss.s_point_x)) and uss.user_id='".$this->Sql->Escape($UserId)."' group by uss.spaceobject_id;";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			// Создать по полученным данным XML-документ
			while($tmp = $SQLRez->fetch_array()) {
				$Node = $Doc->createElement("soid");
				$Value = $Doc->createTextNode($tmp["spaceobject_id"]);
				$Node->appendChild($Value);
				$Storage->appendChild($Node);
			}
			$this->Sql->FreeResult($SQLRez);
		}
		$Doc->appendChild($Storage);
		return $Doc;
	}
	
	public function GetPrizeXML($SpaceObjectId,$UserId) {
		// Возвращает данные по призу c $SpaceObjectId
		$Doc = new DOMDocument('1.0','utf-8');
		// По $Id в системе получить данные
		$this->Sql->SqlQuery = "select count(uss.id) as stack, so.type from vn_user_starsystem uss inner join vn_spaceobject so on uss.spaceobject_id=so.id where (isnull(uss.sub_id) and isnull(uss.s_point_x)) and uss.spaceobject_id='".$this->Sql->Escape($SpaceObjectId)."' and uss.user_id='".$this->Sql->Escape($UserId)."' group by uss.spaceobject_id;";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			// Создать по полученным данным XML-документ
			while($tmp = $SQLRez->fetch_array()) {
				$Node = $Doc->createElement($tmp["type"]);
				// Получить узел с данными из таблицы объекта
				$SO = new $tmp["type"]();
				$SOXML = $SO->GetInfo($SpaceObjectId);
				// Добавить количество в стеке
				$StackNode = $Doc->createElement("stack");
				$StackValue = $Doc->createTextNode($tmp["stack"]);
				$StackNode->appendChild($StackValue);
				$SOXML->documentElement->appendChild($SOXML->importNode($StackNode,true));
				// Добавить узел с данными по объекту в общий список
				$Doc->appendChild($Doc->importNode($SOXML->documentElement,true));
			}
			$this->Sql->FreeResult($SQLRez);
		}
		return $Doc;
	}
	
	public function ConvertPrizeObjectFromStorage($SpaceObjectId,$SubId,$NewX,$NewY,$NewZ) {
		// Конвертировать виртуальный приз в объект виртуальной звездной системы
		$UserId = $_SESSION["vn_id"];	// id пользователя
		// Ищем свободный объект с нужным spaceobject_id
		$ConvId = null;
		$ConvType = null;
		$this->Sql->SqlQuery = "select uss.id, so.type from vn_user_starsystem uss left outer join vn_spaceobject so on uss.spaceobject_id=so.id where uss.spaceobject_id='".$this->Sql->Escape($SpaceObjectId)."' and (isnull(uss.sub_id) and isnull(uss.s_point_x)) and uss.user_id='".$this->Sql->Escape($UserId)."' limit 1;";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			// Создать по полученным данным XML-документ
			while($tmp = $SQLRez->fetch_array()) {
				$ConvId = $tmp["id"];
				$ConvType = $tmp["type"];
			}
			$this->Sql->FreeResult($SQLRez);
		}
		if($ConvId==null) return "0";
		// Проверить куда помещать сконвертированный приз: по координатам или по орбите
		if($SubId!="null") {
			// Пытаемся посадить на орбиту
			// Проверить тип $SubId
			$this->Sql->SqlQuery = "select so.type from vn_user_starsystem uss left outer join vn_spaceobject so on uss.spaceobject_id=so.id where uss.id='".$this->Sql->Escape($SubId)."' and uss.user_id='".$this->Sql->Escape($UserId)."';";
			$this->Sql->Exec();
			if($SQLRez = $this->Sql->SqlRez) {
				while($tmp = $SQLRez->fetch_array()) {
					$SubType = $tmp["type"];
					// Проверить, что на данный тип $SubId можно поставить $ConvId
					// На орбиты можно вешать что угодно
					// Орбиты можно вешать на что угодно
					if($SubType=="OrbitV" || $ConvType=="OrbitV") {
						$NewX = "null";
						$NewY = "null";
						$NewZ = "null";
					}
					else {
						$SubId = "null";
					}
				}
				$this->Sql->FreeResult($SQLRez);
			}
		}
		// Id получен - создать объект
		$this->Sql->SqlQuery = "update vn_user_starsystem set sub_id=".$this->Sql->Escape($SubId).", s_point_x=".$this->Sql->Escape($NewX).", s_point_y=".$this->Sql->Escape($NewY).", s_point_z=".$this->Sql->Escape($NewZ)." where id='".$this->Sql->Escape($ConvId)."';";
		$this->Sql->Exec();
		// После создания объекта получить в XML данные по нему для передачи клиенту
		return $this->GetStarSystemXML($ConvId);
	}

	public function ConvertPrizeObjectToStorage($Id,$UserId) {
		// Конвертировать объект виртуальной звездной системы в виртуальный приз
		// Возвращаем XML с сконвертированными Id призов или сообщение об ошибке
		$XMLDoc = new DOMDocument('1.0','utf-8');
		// Т.к. объект может быть не верхним - собрать Id всех объектов, которые висят на текущем
		$AllId = $this->GetChildrens($Id);	// Id текущего и висящих на нем объектов
		// Удалить их все из системы
		$this->Sql->SqlQuery = "update vn_user_starsystem set sub_id=null, s_point_x=null, s_point_y=null, s_point_z=null where id in(".$this->Sql->Escape($AllId).");";
		$this->Sql->Exec();
		if($this->Sql->SqlRez) {
			// Измеения внесены
			$Storage = $XMLDoc->createElement('vs');
			// По списку Id получить список призов (SpaceObjectId)
			$this->Sql->SqlQuery = "select uss.spaceobject_id from vn_user_starsystem uss where id in(".$this->Sql->Escape($AllId).") group by uss.spaceobject_id;";
			$this->Sql->Exec();
			if($SQLRez = $this->Sql->SqlRez) {
				// Создать по полученным данным XML-документ
				while($tmp = $SQLRez->fetch_array()) {
					$Node = $XMLDoc->createElement("soid");
					$Value = $XMLDoc->createTextNode($tmp["spaceobject_id"]);
					$Node->appendChild($Value);
					$Storage->appendChild($Node);
				}
				$this->Sql->FreeResult($SQLRez);
			}
			$XMLDoc->appendChild($Storage);
		}
		else {
			$this->XEx->CreateXMLErr("117",$XMLDoc);	// "Системная обшибка"
		}
		return $XMLDoc;
	}
	
	public function ReplacePrizeObject($Id,$SubId,$NewX,$NewY,$NewZ) {
		// Перемещение объекта в виртуальной системе
		// Проверить - вешаем на другой объект или по координатам
		if($this->CheckParentEnable($Id,$SubId)==true) {
			// На объект
			$NewX = "null";
			$NewY = "null";
			$NewZ = "null";
		}
		else {
			// На координаты
			$SubId = "null";
		}
		$XMLDoc = new DOMDocument('1.0','utf-8');
		$this->Sql->SqlQuery = "update vn_user_starsystem set sub_id=".$this->Sql->Escape($SubId).", s_point_x=".$this->Sql->Escape($NewX).", s_point_y=".$this->Sql->Escape($NewY).", s_point_z=".$this->Sql->Escape($NewZ)." where id='".$this->Sql->Escape($Id)."';";
		$this->Sql->Exec();
		if($this->Sql->SqlRez) {
			// Измеения внесены
			$RootNode = $XMLDoc->createElement("Rez");
			$Node = $XMLDoc->createElement("Id");
			$Value = $XMLDoc->createTextNode($Id);
			$Node->appendChild($Value);
			$RootNode->appendChild($Node);
			if($SubId!="null") {
				// Цепляли к объекту
				$Node = $XMLDoc->createElement("SubId");
				$Value = $XMLDoc->createTextNode($SubId);
				$Node->appendChild($Value);
				$RootNode->appendChild($Node);
			}
			else {
				// Цепляли к координатам
				$Node = $XMLDoc->createElement("X");
				$Value = $XMLDoc->createTextNode($NewX);
				$Node->appendChild($Value);
				$RootNode->appendChild($Node);
				$Node = $XMLDoc->createElement("Y");
				$Value = $XMLDoc->createTextNode($NewY);
				$Node->appendChild($Value);
				$RootNode->appendChild($Node);
			}
			$XMLDoc->appendChild($RootNode);
//			$this->XEx->CreateXMLErr("0",$XMLDoc);	// Нет ошибки (0)
		}
		else {
			// Ошибка
			$this->XEx->CreateXMLErr("196",$XMLDoc);	// "Ошибка перемещения"
		}
		return $XMLDoc;
	}
	
	public function GetChildrens($Id) {
		// Получить список всех объектов, которые висят на текущем
		// Возвращает строку с Id через запятую
		$AllId = "";
		$this->Sql->SqlQuery = "select id, sub_id from vn_user_starsystem where sub_id='".$this->Sql->Escape($Id)."';";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			while($tmp = $SQLRez->fetch_array()) {
				if($AllId=="") $AllId = $this->GetChildrens($tmp["id"]);
				else $AllId = $AllId.",".$this->GetChildrens($tmp["id"]);
			}
			$this->Sql->FreeResult($SQLRez);
		}
		if($AllId=="") return $Id;
		else return $AllId.",".$Id;
	}
	
	public function CheckParentEnable($ChildId, $ParentId) {
		// Проверка, может ли быть объект с $ChildId чайлдом объекта с $ParentId (можно ли $ChildId поставить на $ParentId)
		// Возвращает ture - может, false - нет
		// На null цеплять нельзя
		if($ParentId=="null") return false;	// Не может
		// Нельзя цеплять на свою же цепочку
		$AllChildren = ",".$this->GetChildrens($ChildId).",";	// Id текущего и висящих на нем объектов
		if(substr_count($AllChildren,",".$ParentId.",")>0) return false;
		// Проверка по типам
		$ChildType = "";
		$ParentType = "";
		// Получить тип парента
		$this->Sql->SqlQuery = "select so.type from vn_user_starsystem uss inner join vn_spaceobject so on uss.spaceobject_id=so.id where uss.id='".$this->Sql->Escape($ParentId)."';";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			while($tmp = $SQLRez->fetch_array()) {
				$ParentType = $tmp["type"];
			}
			$this->Sql->FreeResult($SQLRez);
		}
		// Получить тип чайлда
		$this->Sql->SqlQuery = "select so.type from vn_user_starsystem uss inner join vn_spaceobject so on uss.spaceobject_id=so.id where uss.id='".$this->Sql->Escape($ChildId)."';";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			while($tmp = $SQLRez->fetch_array()) {
				$ChildType = $tmp["type"];
			}
			$this->Sql->FreeResult($SQLRez);
		}
		// На орбиты можно вешать что угодно
		// Орбиты можно вешать на что угодно
		if($ParentType=="OrbitV" || $ChildType=="OrbitV") {
			return true;	// Может
		}
		else {
			return false;	// Не может
		}
	}
	
	public function GetBonusInfo($Id, $UserId) {
		// Получить данные по бонусу от виртуального объекта c $Id (vn_user_starsystem.id)
		$XMLDoc = new DOMDocument('1.0','utf-8');
		$this->Sql->SqlQuery = "select uss.id, sov.bonus, cast(sov.bonus_interval-(unix_timestamp(now())-unix_timestamp(uss.bonus_getted)) AS SIGNED) as dest from vn_user_starsystem uss left outer join vn_spaceobject_v sov on uss.spaceobject_id=sov.spaceobject_id where uss.user_id='".$this->Sql->Escape($UserId)."' and uss.id='".$this->Sql->Escape($Id)."';";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			while($tmp = $SQLRez->fetch_array()) {
				if(!is_null($tmp["bonus"])) {
					$XMLDoc->loadXML($tmp["bonus"]);
					$TimeRemain = 0;	// Осталось времени (в сек)
					if(!is_null($tmp["dest"])) {
						$TimeRemain = $tmp["dest"];
						if($TimeRemain<0) $TimeRemain=0;
					}
					$XMLDoc->firstChild->setAttribute("dest",$TimeRemain);
				}
			}
			$this->Sql->FreeResult($SQLRez);
		}
		return $XMLDoc;
	}
	
	public function GetBonus($Id, $UserId) {
		// Зачислить игроку $UserId бонус от виртуального объекта c $Id (vn_user_starsystem.id)
		$XMLDoc = new DOMDocument('1.0','utf-8');
		$this->Sql->SqlQuery = "select uss.id, sov.bonus, cast(sov.bonus_interval-(unix_timestamp(now())-unix_timestamp(uss.bonus_getted)) AS SIGNED) as dest from vn_user_starsystem uss left outer join vn_spaceobject_v sov on uss.spaceobject_id=sov.spaceobject_id where uss.user_id='".$this->Sql->Escape($UserId)."' and uss.id='".$this->Sql->Escape($Id)."';";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			while($tmp = $SQLRez->fetch_array()) {
				if(!is_null($tmp["bonus"])) {
					// Проверки
					// Прошел ли временной интервал?
					if(!is_null($tmp["dest"])&&$tmp["dest"]>0) {
						// Время еще не прошло
						$this->XEx->CreateXMLErr("198",$XMLDoc);	// "Временной интервал не завершен"
						break;
					}
					// Проверки пройдены - добавить призы пользователю
					$Qst = new Quests();
					$Qst->AddPrize($UserId,null,null,$tmp["bonus"]);
					$this->XEx->CreateXMLErr("0",$XMLDoc);	// Нет ошибки (0) - Бонусы зачислены
					// Зафиксировать время получения
					$this->Sql->SqlQuery = "update vn_user_starsystem set bonus_getted=now() where user_id='".$this->Sql->Escape($UserId)."' and id='".$this->Sql->Escape($Id)."';";
					$this->Sql->Exec();
				}
			}
			$this->Sql->FreeResult($SQLRez);
		}
		return $XMLDoc;
	}
	
	public function GetVirtualObject($SpaceObjectId, $UserId) {
		// Выдать пользователю $UserId объект виртуальной системы вида $SpaceObjectId
		// Проверить тип (объект/орбита)
		$this->Sql->SqlQuery = "select type from vn_spaceobject where id='".$this->Sql->Escape($SpaceObjectId)."';";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			while($tmp = $SQLRez->fetch_array()) {
				// Даные в vn_user_starsystem
				$this->Sql->SqlQuery = "insert into vn_user_starsystem (user_id, spaceobject_id) values ('".$this->Sql->Escape($UserId)."', '".$this->Sql->Escape($SpaceObjectId)."');";
				$this->Sql->Exec();
				// Для орбит - добавочные данные
				if($tmp["type"]=="OrbitV") {
					// Данные в vn_user_starsystem_orbits_v
					$this->Sql->SqlQuery = "select max(id) as max_id from vn_user_starsystem where user_id='".$this->Sql->Escape($UserId)."';";
					$this->Sql->Exec();
					if($SQLRez1 = $this->Sql->SqlRez) {
						while($tmp1 = $SQLRez1->fetch_array()) {
							$this->Sql->SqlQuery = "insert into vn_user_starsystem_orbits_v (user_starsystem_id) values ('".$this->Sql->Escape($tmp1["max_id"])."');";
							$this->Sql->Exec();
						}
						$this->Sql->FreeResult($SQLRez1);
					}
				}
			}
			$this->Sql->FreeResult($SQLRez);
		}
	}
}
?>