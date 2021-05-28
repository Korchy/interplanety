<?php
//---------------------------------
require_once("dbconnected_vn.inc.php");
require_once("user.inc.php");
require_once("ships.inc.php");
require_once("xmlex.inc.php");
//---------------------------------
class Quests extends DBConnectedVn
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

	function GetQuests($UserId,$XMLDoc,$RootNode) {
		// Добавить в XML-документ $XMLDoc в узел $RootNode данные по квестам
		// Уровень пользователя
		$Usr = new UserVn();
		$UserLevel = $Usr->GetUserLevel($UserId);
		// Получить информацию по квестам
		$this->Sql->SqlQuery = "select q.id, q.name, q.level, q.img, q.planet, q.enable, q.intro, uq.type from vn_quests q left outer join (select uqc.quest_id, \"A\" as type from vn_user_quests_conditions uqc where user_id=".$this->Sql->Escape($UserId)." union select uqf.quest_id, \"F\" as type from vn_user_quests_finished uqf where user_id=".$this->Sql->Escape($UserId).") uq on q.id=uq.quest_id where q.level<=".$this->Sql->Escape($UserLevel).";";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			// Разделить на принятые (A) и завершенные (F)
			$A = $XMLDoc->createElement("A");	// Активные
			$F = $XMLDoc->createElement("F");	// Завершенные
			$N = $XMLDoc->createElement("N");	// Непринятые
			// По квестам
			while($tmp = $SQLRez->fetch_assoc()) {
				$Quest = $XMLDoc->createElement("quest");
				while (list($key, $val) = each($tmp)) {
					switch($key) {
						case "id":	// id (id квеста в vn_quests) - в параметр
							$Quest->setAttribute("id",$val);
							break;
						case "name":	// name - в параметр
							$Quest->setAttribute($key,$val);
							break;
						case "type":	// type используется далее
							break;
						case "enable":	// enable используется далее
							break;
						case "planet":	// planet добавляем только если не 0
							if($val!=0) {
								$Node = $XMLDoc->createElement($key);
								$Value = $XMLDoc->createTextNode($val);
								$Node->appendChild($Value);
								$Quest->appendChild($Node);
							}
							break;
						case "intro":	// introl добавляем только если не null
							if($val!=NULL) {
								$Node = $XMLDoc->createElement($key);
								$Value = $XMLDoc->createTextNode($val);
								$Node->appendChild($Value);
								$Quest->appendChild($Node);
							}
							break;
						default:
							$Node = $XMLDoc->createElement($key);
							$Value = $XMLDoc->createTextNode($val);
							$Node->appendChild($Value);
							$Quest->appendChild($Node);
					}
				}
				if($tmp["type"]=="A"&&$tmp["enable"]=="T") $A->appendChild($Quest);
				if($tmp["type"]=="F") $F->appendChild($Quest);
				if($tmp["type"]==NULL&&$tmp["enable"]=="T") $N->appendChild($Quest);
			}
			$this->Sql->FreeResult($SQLRez);
			// Если квесты есть - добавить в список
			if($A->childNodes->length>0) $RootNode->appendChild($A);
			if($F->childNodes->length>0) $RootNode->appendChild($F);
			if($N->childNodes->length>0) $RootNode->appendChild($N);
		}
	}

	function GetQuest($UserId,$QuestId,$XMLDoc,$RootNode) {
		// Добавить в XML-документ $XMLDoc в узел $RootNode данные по квесту $QuestId
		// Получить информацию по квесту $QuestId
		// Текущий этап
		$CurrentStage = 999;	// 999 - завершенный квест
		$this->Sql->SqlQuery = "select max(uqc.stage) as current_stage from vn_user_quests_conditions uqc where uqc.quest_id=".$this->Sql->Escape($QuestId)." and uqc.user_id=".$this->Sql->Escape($UserId).";";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			while($tmp = $SQLRez->fetch_array()) {
				if($tmp["current_stage"]!=null) $CurrentStage = $tmp["current_stage"];
			}
			$this->Sql->FreeResult($SQLRez);
		}
		// Данные по квесту
		$this->Sql->SqlQuery = "select qc1.stage, uqc.condition, qc1.easy, qc1.easy_prize, qc1.normal, qc1.normal_prize, qc1.hard, qc1.hard_prize from (select ".$this->Sql->Escape($UserId)." as user_id, qc.quest_id, qc.stage, qc.easy, qc.easy_prize, qc.normal, qc.normal_prize, qc.hard, qc.hard_prize from vn_quests_conditions qc where qc.quest_id=".$this->Sql->Escape($QuestId)." and qc.stage<=".$this->Sql->Escape($CurrentStage).") as qc1 left outer join vn_user_quests_conditions uqc on qc1.quest_id=uqc.quest_id and qc1.stage=uqc.stage and qc1.user_id=uqc.user_id;";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			// По этапам квеста
			while($tmp = $SQLRez->fetch_assoc()) {
				$StageNode = $XMLDoc->createElement("stage");
				$StageNode->setAttribute("id",$tmp["stage"]);
				$RootNode->appendChild($StageNode);
				// Данные по конкретному этапу
				while (list($key, $val) = each($tmp)) {
					switch($key) {
						case "stage":
							break;
						case "condition":
							break;
						case "easy_prize":
							break;
						case "normal_prize":
							break;
						case "hard_prize":
							break;
						default:
							// easy,normal,hard
							if($val!=null) {
								// В $DiffNode собираем дерево с условиями и призами
								// Добавить условия
								$DiffNode = $XMLDoc->createElement($key);
								$StageNode->appendChild($DiffNode);
								$Usl = new DOMDocument();
								$Usl->loadXML($val);
								// Добавить насколько выполнены условия
								if($tmp["condition"]!=null) {
									$Cond = new DOMDocument();
									$Cond->loadXML($tmp["condition"]);
									foreach($Usl->firstChild->childNodes as $Node) {
										$XMLExt = new XMLEx();
										$UserNode = $XMLExt->FindEqualNode($Cond->firstChild,$Node);
										if($UserNode!=null)	{
											if($UserNode->nodeValue>=$Node->nodeValue) $Node->nodeValue = $Node->nodeValue."/".$Node->nodeValue;
											else $Node->nodeValue = $UserNode->nodeValue."/".$Node->nodeValue;
										}
									}
								}
								else {
									// Этап завершен
									if($CurrentStage>$tmp["stage"]) {
										foreach($Usl->firstChild->childNodes as $Node) {
											$Node->nodeValue = $Node->nodeValue."/".$Node->nodeValue;
										}
									}
								}
								// Положить в дерево
								$DiffNode->appendChild($XMLDoc->importNode($Usl->documentElement,true));
								// Добавить призы
								if($tmp[$key."_prize"]!=null) {
									$Prize = new DOMDocument();
									$Prize->loadXML($tmp[$key."_prize"]);
									// Положить в дерево
									$DiffNode->appendChild($XMLDoc->importNode($Prize->documentElement,true));
								}
							}
					}
				}
			}
			$this->Sql->FreeResult($SQLRez);
			// CurrentStage - в атрибут
			$RootNode->setAttribute("c_stage",$CurrentStage);
		}
	}
	
	function AcceptQuest($UserId,$QuestId,$StageId) {
		// Принятие квеста $QuestId пользователем начиная с этапа $StageId
		// Проверить не был ли уже принять этот квест на этом этапе
		$this->Sql->SqlQuery = "select quest_id from vn_user_quests_conditions where user_id=".$this->Sql->Escape($UserId)." and quest_id=".$this->Sql->Escape($QuestId)." and stage=".$this->Sql->Escape($StageId).";";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			$Rows = $this->Sql->Rows($SQLRez);
			$this->Sql->FreeResult($SQLRez);
			if($Rows>0) return;	// Уже есть - возврат
		}
		// Добавть
		$this->Sql->SqlQuery = "select stage, easy, easy_prize, normal, normal_prize, hard, hard_prize from vn_quests_conditions where quest_id=".$this->Sql->Escape($QuestId)." and stage>=".$this->Sql->Escape($StageId)." order by stage;";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			while($tmp = $SQLRez->fetch_array()) {
				if($tmp["easy"]==null) {
					// Начальные окна
					$this->AddPrize($UserId,$QuestId,$tmp["stage"],$tmp["easy_prize"]);
				}
				else {
					// Условие
					$Condition = new DOMDocument();
					// Взять максимальное условие
					if($tmp["hard"]!=null) $Condition->loadXML($tmp["hard"]);
					else {
						if($tmp["normal"]!=null) $Condition->loadXML($tmp["normal"]);
						else $Condition->loadXML($tmp["easy"]);
					}
					// Обнулить его
					$ConditionNodes = $Condition->firstChild->childNodes;	// <Fly></Fly><Buy></Buy>
					foreach($ConditionNodes as $CNode) {	// <Fly></Fly>
						$CNode->nodeValue = 0;
					}	
					// Записать пользователю
					$this->Sql->SqlQuery = "insert into vn_user_quests_conditions (user_id,quest_id,stage,`condition`) values (".$UserId.",".$QuestId.",".$tmp["stage"].",'".$Condition->saveHTML()."');";
					$this->Sql->Exec();
					break;	// Пишем только первое условие
				}
			}
			$this->Sql->FreeResult($SQLRez);
		}
	}
	
	function FormFinishConditionFly($PlanetA,$PlanetB) {
		// Сформировать условие для сравнения с условием прилета на планету $PlanetB (spaceobject_id)
		return "<condition><Fly PlanetA=\"".$PlanetA."\" PlanetB=\"".$PlanetB."\">1</Fly></condition>";
	}
	
	function FormFinishConditionBuyCargo($CargoId, $CargoValue, $PlanetA) {
		// Условие: Покупка груза $CargoId (vn_industry.id) на планете $PlanetA (vn_spaceobject.id) в количестве $CargoValue
		return "<condition><BuyCargo CargoId=\"".$CargoId."\" PlanetA=\"".$PlanetA."\">".$CargoValue."</BuyCargo></condition>";
	}
	
	function FormFinishConditionSellCargo($CargoId, $CargoValue, $PlanetA, $PlanetB) {
		// Условие: Продажа груза $CargoId (vn_industry.id) на планете $PlanetB (vn_spaceobject.id) купленного на планете $PlanetA (vn_spaceobject.id) в количестве $CargoValue
		return "<condition><SellCargo CargoId=\"".$CargoId."\" PlanetA=\"".$PlanetA."\" PlanetB=\"".$PlanetB."\">".$CargoValue."</SellCargo></condition>";
	}
	
	function FormFinishConditionLevelUp($Level) {
		// Условие: Поднятие уровня пользователя
		return "<condition><LevelUp>".$Level."</LevelUp></condition>";
	}
	
	function CheckFinishConditions($UserId,$CheckingCondition) {
		// Обновить условия завершения квестов условием $CheckingCondition и проверить на завершение кветов
		// Уровень пользователя
		$Usr = new UserVn();
		$UserLevel = $Usr->GetUserLevel($UserId);
		// Проверяемое условие
		$Condition = new DOMDocument();
		$Condition->loadXML($CheckingCondition);
		$CNode = $Condition->firstChild->firstChild;	// $Cond = <Fly>...</Fly>
		$CondNodeName = $CNode->nodeName;	// Fly
		// Обновить данные в vn_user_quests_conditions
		$this->Sql->SqlQuery = "select uq.id, uq.quest_id, q.level, uq.stage, uq.condition, qc.easy, qc.easy_prize, qc.normal, qc.normal_prize, qc.hard, qc.hard_prize from vn_user_quests_conditions uq left outer join vn_quests_conditions qc on uq.quest_id=qc.quest_id and uq.stage=qc.stage left outer join vn_quests q on uq.quest_id=q.id where uq.user_id=".$this->Sql->Escape($UserId).";";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			while($tmp = $SQLRez->fetch_array()) {
				// По каждой строчке
				if($tmp["level"]<=$UserLevel) {
					// Если квест соответствует по уровню пользователю
					$UserCondition0 = new DOMDocument();			// UserConditon до обновления условием $CheckingCondition
					$UserCondition0->loadXML($tmp["condition"]);
					$UserCondition = new DOMDocument();				// UserConditon обновленный условием $CheckingCondition
					$UserCondition->loadXML($tmp["condition"]);
					// Обновить $UserCondition условием $CheckingCondition
					$Updated = false;
					// По всем условиям $UserCondition ищем нет ли соответсвующего $Condition
					$UCList = $UserCondition->getElementsByTagName($CondNodeName);	// $UCList = <Fly>...</Fly><Fly>...</Fly><Fly>...</Fly>
					foreach($UCList as $UCNode) {	// $UCNode = <Fly>...</Fly>
						// Проверить на соответствие всех атрибутов и их значений
						$AllAttrEqual = true;
						foreach($UCNode->attributes as $UCAttr) {
						// по всем атрибутам UCNode проверяем что такие же атрубуты есть в CNode и значения равны. Если в UCNode есть а в CNode нет или есть, но значение другое - не тот узел.
							$AttrEqual = false;
							foreach($CNode->attributes as $CAttr) {
								if($UCAttr->nodeName==$CAttr->nodeName&&$UCAttr->nodeValue==$CAttr->nodeValue) {
									// Найден атрибут в CNode
									$AttrEqual = true;
									break;
								}
							}
							if($AttrEqual==false) {	// Если атрибут в CNode не найден - все атрибуты не совпадают - не тот узел
								$AllAttrEqual = false;
								break;
							}
						}
						if($AllAttrEqual==true) {
							// Найден нужный узел (по соответствию атрибутов) - обновить его
							$UCNode->nodeValue = $UCNode->nodeValue + $CNode->nodeValue;
							$Updated = true;	// Было обновление
						}
					}
					if($Updated==true) {
						// Условие изменилось - проверить на перешагивание этапа квеста
						$Easy = new DOMDocument();
						$Easy->loadXML($tmp["easy"]);
						$ECheck0 = $this->CompareConditionsXML($UserCondition0,$Easy);
						$ECheck = $this->CompareConditionsXML($UserCondition,$Easy);
						if($ECheck0==false&&$ECheck==true) {
							// Переход через Easy
							// Добавить приз
							$this->AddPrize($UserId,$tmp["quest_id"],$tmp["stage"],$tmp["easy_prize"]);
						}
						$NCheck = false;
						if($tmp["normal"]!=null) {
							$Normal = new DOMDocument();
							$Normal->loadXML($tmp["normal"]);
							$NCheck0 = $this->CompareConditionsXML($UserCondition0,$Normal);
							$NCheck = $this->CompareConditionsXML($UserCondition,$Normal);
							if($NCheck0==false&&$NCheck==true) {
							// Переход через Normal
							// Добавить приз
							$this->AddPrize($UserId,$tmp["quest_id"],$tmp["stage"],$tmp["normal_prize"]);
							}
						}
						$HCheck = false;
						if($tmp["hard"]!=null) {
							$Hard = new DOMDocument();
							$Hard->loadXML($tmp["hard"]);
							$HCheck0 = $this->CompareConditionsXML($UserCondition0,$Hard);
							$HCheck = $this->CompareConditionsXML($UserCondition,$Hard);
							if($HCheck0==false&&$HCheck==true) {
							// Переход через Hard
							// Добавить приз
							$this->AddPrize($UserId,$tmp["quest_id"],$tmp["stage"],$tmp["hard_prize"]);
							}
						}
						// Обновить условие
						if(($ECheck==true&&$tmp["normal"]==null&&$tmp["hard"]==null)||($NCheck==true&&$tmp["hard"]==null)||($HCheck==true)) {
							// Этап завершен - удалить условие
							$this->Sql->SqlQuery = "delete from vn_user_quests_conditions where id=".$this->Sql->Escape($tmp["id"]).";";
							$this->Sql->Exec();
							// Проверка на завершение всего квеста
							$this->QuestFinished($UserId,$tmp["quest_id"],$tmp["stage"]+1);
						}
						else {
							// Обновить условие
							$this->Sql->SqlQuery = "update vn_user_quests_conditions set `condition`='".$this->Sql->Escape($UserCondition->saveHTML())."' where id=".$this->Sql->Escape($tmp["id"]).";";
							$this->Sql->Exec();
						}
						// Если был переход через Easy - добавить новый этап
						if($ECheck0==false&&$ECheck==true) {
							$this->AcceptQuest($UserId,$tmp["quest_id"],$tmp["stage"]+1);
						}
					}
				}
			}
			$this->Sql->FreeResult($SQLRez);
		}
	}
	
	function CompareConditionsXML($Condition,$Base) {
		// Сравниваем два условия в XML-формате. Считаем что Condition больше Base (возвр true) если в Condition есть все узлы из Base
		// и все Value в соответствующих узлах Condition >= Value в тех же узлах Base
		$Rez = true;	// "C>B";
		// Нужно найти хотя бы один узел в Base, который > узла в Condition или которого нет в Condition - тогда B>C
		// По всем узлам Base
		$BaseNodes = $Base->firstChild->childNodes;	// <Fly></Fly><Buy></Buy>
		foreach($BaseNodes as $BaseNode) {	// <Fly></Fly>
			$NodeFound = false;	// true - узел найден. Если такого узла в Condition не найдено - Base > Condition
//			echo "---<br>Base: ".$BaseNode->nodeName." - ".$BaseNode->nodeValue."<br>";
			// Проверяем каждый узел Base
			// Ищем такой же в Condition
			$CList = $Condition->getElementsByTagName($BaseNode->nodeName);	//<Fly>...</Fly><Fly>...</Fly> при Base->nodeName = "Fly"
			foreach($CList as $CNode) {	// <Fly></Fly>
//				echo "-Cond: ".$CNode->nodeName." - ".$CNode->nodeValue."<br>";
				// Condition будет искомым, только если в условии Base есть все артрибуты условия Condition и их значения равны
				// Если в Condition-узле одинаковое кол-во атрибутов с Base-узлом - смотрим дальше, если разное - переходим к следующему узлу
				if($BaseNode->attributes->length==$CNode->attributes->length) {
//					echo "--Base-Cond Attr->length: ".$BaseNode->attributes->length." - ".$CNode->attributes->length."<br>";
					$AllAttrEqual = true;
					foreach($BaseNode->attributes as $BaseAttr) {
					// по всем атрибутам Base-узла проверяем что такие же атрубуты есть в Condition-узле и значения равны. Если в Base есть а в Condition нет или есть, но значение другое - не тот узел.
//						echo "---BaseAttr: ".$BaseAttr->nodeName." - ".$BaseAttr->nodeValue."<br>";
						$AttrEqual = false;
						foreach($CNode->attributes as $CAttr) {
//							echo "----CAttr: ".$CAttr->nodeName." - ".$CAttr->nodeValue."<br>";
							if($BaseAttr->nodeName==$CAttr->nodeName&&$BaseAttr->nodeValue==$CAttr->nodeValue) {
								// Найден атрибут в Condition узле
								$AttrEqual = true;
								break;
							}
						}
						if($AttrEqual==false) {	// Если атрибут в Condition-узле не найден - все атрибуты не совпадают - не тот узел
							$AllAttrEqual = false;
							break;
						}
					}
					if($AllAttrEqual==true) {
						// Найден нужный узел (по соответствию атрибутов)
						$NodeFound = true;
						if($BaseNode->nodeValue>$CNode->nodeValue) $Rez = false;	// "B>C";
						break;
					}
				}
			}
			if($NodeFound==false) {
				// B>C т.к. просмотрели все узлы Condition и ни один не подошел к узлу Base (в Base есть, в Condition нет) (например Easy сравниваем с Normal)
				$Rez = false;	// "B>C";
				break;
			}
		}
		return $Rez;
	}
	
	function AddPrize($UserId,$QuestId,$StageId,$PrizeString) {
		// Добавить пользователю призы за завершение квеста
		if($PrizeString!=null&&$PrizeString!="")  {
			$TextDoc = new DOMDocument();	// Для отдельного вывода текста
			$Text = $TextDoc->createElement('text');
			$TextDoc->appendChild($Text);
			$Prize = new DOMDocument();	// Для отдельного вывода призов
			$Prize->loadXML($PrizeString);
			$PrizeNodes = $Prize->firstChild->childNodes;	// <Gold></Gold><Crystals></Crystals>
			$Usr = new UserVn();
			foreach($PrizeNodes as $Node) {	// <Gold></Gold>
				switch($Node->nodeName) {
					case "Text":		// Text - заносится отдельной строкой и обрабатывается потом отдельно
						$Text->appendChild($TextDoc->importNode($Node,true));
						break;
					case "Gold":		// Деньги
						$Usr->UpdateMoney($UserId,$Node->nodeValue);
						break;
					case "Crystals":	// Кристаллы
						$Usr->UpdateCrystals($UserId,$Node->nodeValue);
						break;
					case "Exp":			// Опыт
						$Usr->UpdateExp($UserId,$Node->nodeValue);
						break;
					case "Ship":		// Корабли
						// Если это открытие - ничего не делаем
						if($Node->attributes->getNamedItem("type")!=NULL&&$Node->attributes->getNamedItem("type")->nodeValue=="a") break;
						// Если приз - присвоить пользователю
						$ShipsManager = new Ships();
						// Корабль
						$NewShip = 1;
						$NewShipId = $Node->attributes->getNamedItem("Id")->nodeValue;
						if($NewShipId!=NULL) $NewShip = $NewShipId;
						// Планета
						$DestPlanet = 9;										// До 10 уровня - доставка на Луну
						if($Usr->GetUserLevel($UserId)>=10) $DestPlanet = 22;	// После открытия верфи - забирать с верфи
						// Добавить корабль пользователю
						$ShipsManager->AddShipToUser($UserId,$NewShip,$DestPlanet,$DestPlanet);
						break;
					case "Quest":		// Новый квест
						$NewQuestId = $Node->attributes->getNamedItem("Id")->nodeValue;
						$this->AcceptQuest($UserId,$NewQuestId,1);	// С 1 этапа
						break;
					default:
						// Для остального (просто открытие а не призы) ничего не делаем
						// атрибут type="а" добавляем в базе vn_quests_conditons
				}
			}
			// Добавить призы - для вывода сообщений пользователю
			if($QuestId!=null && $StageId!=null) {
				// Удалить текстовые сообщения - они записываются отдельно (здесь а не в foreach т.к. иначе цикл сбивается)
				$TextNodes = $Prize->getElementsByTagName("Text");
				if($TextNodes->length!=0) {
					$TextNodeToDel = $TextNodes->item(0);
					$TextNodeToDel->parentNode->removeChild($TextNodeToDel);
				}
				// Добавить в vn_user_quests_prize данные о призах
				if($Prize->firstChild->childNodes->length!=0) {
					// Если в $Prize было что-то кроме Text - добавить
					$this->Sql->SqlQuery = "insert into vn_user_quests_prize (user_id,quest_id,stage,prize,`order`) values (".$this->Sql->Escape($UserId).",".$this->Sql->Escape($QuestId).",".$this->Sql->Escape($StageId).",'".$this->Sql->Escape($Prize->saveHTML())."',1);";
					$this->Sql->Exec();
				}
				// Добавить в vn_user_quests_prize данные о текстовых сообщениях
				if($TextDoc->firstChild->childNodes->length!=0) {
					$this->Sql->SqlQuery = "insert into vn_user_quests_prize (user_id,quest_id,stage,prize,`order`) values (".$this->Sql->Escape($UserId).",".$this->Sql->Escape($QuestId).",".$this->Sql->Escape($StageId).",'".$this->Sql->Escape($TextDoc->saveHTML())."',0);";
					$this->Sql->Exec();
				}
			}
		}
	}
	
	function GetQuestsPrize($UserId,$XMLDoc,$RootNode) {
		// Добавить в XML-документ $XMLDoc в узел $RootNode данные по первому призу за квест
		// Получить информацию по первому квесту по которому есть приз
		$this->Sql->SqlQuery = "select uqp.id, q.name, uqp.quest_id, uqp.stage, uqp.prize from vn_user_quests_prize uqp left outer join vn_quests q on uqp.quest_id=q.id where uqp.user_id=".$this->Sql->Escape($UserId)." order by uqp.quest_id, uqp.stage, uqp.`order` limit 1;";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			while($tmp = $SQLRez->fetch_assoc()) {
				while (list($key, $val) = each($tmp)) {
					switch($key) {
						case "id":	// id - в атрибут RootNode
							$RootNode->setAttribute($key,$val);
							break;
						case "quest_id":	// quest_id - в атрибут RootNode
							$RootNode->setAttribute($key,$val);
							break;
						case "stage":	// stage - в атрибут RootNode
							$RootNode->setAttribute($key,$val);
							break;
						case "name":	// name - в атрибут RootNode
							$RootNode->setAttribute($key,$val);
							break;
						case "prize":
							$Prize = new DOMDocument();
							$Prize->loadXML($val);
							$RootNode->appendChild($XMLDoc->importNode($Prize->documentElement,true));
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

	function QuestsPrizeGetted($PrizeId) {
		// Подтверждение что призы с Id = $PrizeId получены - удалить их из таблицы призов
		$this->Sql->SqlQuery = "delete from vn_user_quests_prize where id=".$this->Sql->Escape($PrizeId).";";
		$this->Sql->Exec();
		return "T";
	}
	
	function QuestFinished($UserId,$QuestId,$StageId) {
		// Проверка на завершение пользователем $UserId квеста $QuestId на этапе $StageId
		if($StageId==1) return;
		// Есть ли у этого квеста следующий этап
		$this->Sql->SqlQuery = "select quest_id, stage from vn_quests_conditions where quest_id=".$this->Sql->Escape($QuestId)." and stage=".$this->Sql->Escape($StageId).";";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			if($this->Sql->Rows($SQLRez)==0) {
				// Вернули 0 строк - значит следующего этапа нет - квест завершен
				$this->Sql->SqlQuery = "insert into vn_user_quests_finished (user_id,quest_id) values (".$this->Sql->Escape($UserId).",".$this->Sql->Escape($QuestId).");";
				$this->Sql->Exec();
			}
			$this->Sql->FreeResult($SQLRez);
		}
	}
	
	function AcceptDynamicQuest($UserId,$QuestId,$XMLDoc) {
		// Принятие пользователем $UserId динамического квеста $QuestId
		$Usr = new UserVn();
		$XEx = new XMLEx();
		// Проверить на возможность принятия
		// Квест больше по уровню
		$UserLevel = $Usr->GetUserLevel($UserId);
		$QuestLevel = 0;
		$this->Sql->SqlQuery = "select q.level from vn_quests q where q.id='".$this->Sql->Escape($QuestId)."';";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			while($tmp = $SQLRez->fetch_array()) {
				$QuestLevel = $tmp["level"];
			}
			$this->Sql->FreeResult($SQLRez);
		}
		if($UserLevel<$QuestLevel) return $XEx->CreateXMLErr("177",$XMLDoc);	// "Уровень задания слишком высок"
		// Проверки пройдены - принять квест
		$this->AcceptQuest($UserId,$QuestId,1);
		// Вернуть данные по принятому квесту
		$XEx->CreateXMLErr("0",$XMLDoc);	// 0 - нет ошибки (квест принят)
	}
}
?>