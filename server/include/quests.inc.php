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
		// ����������� ��������
		parent::__construct();
		// �����������
		
	}

	public function __destruct() {
		// ����������
		
		// ���������� ��������
		parent::__destruct();
	}

	function GetQuests($UserId,$XMLDoc,$RootNode) {
		// �������� � XML-�������� $XMLDoc � ���� $RootNode ������ �� �������
		// ������� ������������
		$Usr = new UserVn();
		$UserLevel = $Usr->GetUserLevel($UserId);
		// �������� ���������� �� �������
		$this->Sql->SqlQuery = "select q.id, q.name, q.level, q.img, q.planet, q.enable, q.intro, uq.type from vn_quests q left outer join (select uqc.quest_id, \"A\" as type from vn_user_quests_conditions uqc where user_id=".$this->Sql->Escape($UserId)." union select uqf.quest_id, \"F\" as type from vn_user_quests_finished uqf where user_id=".$this->Sql->Escape($UserId).") uq on q.id=uq.quest_id where q.level<=".$this->Sql->Escape($UserLevel).";";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			// ��������� �� �������� (A) � ����������� (F)
			$A = $XMLDoc->createElement("A");	// ��������
			$F = $XMLDoc->createElement("F");	// �����������
			$N = $XMLDoc->createElement("N");	// ����������
			// �� �������
			while($tmp = $SQLRez->fetch_assoc()) {
				$Quest = $XMLDoc->createElement("quest");
				while (list($key, $val) = each($tmp)) {
					switch($key) {
						case "id":	// id (id ������ � vn_quests) - � ��������
							$Quest->setAttribute("id",$val);
							break;
						case "name":	// name - � ��������
							$Quest->setAttribute($key,$val);
							break;
						case "type":	// type ������������ �����
							break;
						case "enable":	// enable ������������ �����
							break;
						case "planet":	// planet ��������� ������ ���� �� 0
							if($val!=0) {
								$Node = $XMLDoc->createElement($key);
								$Value = $XMLDoc->createTextNode($val);
								$Node->appendChild($Value);
								$Quest->appendChild($Node);
							}
							break;
						case "intro":	// introl ��������� ������ ���� �� null
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
			// ���� ������ ���� - �������� � ������
			if($A->childNodes->length>0) $RootNode->appendChild($A);
			if($F->childNodes->length>0) $RootNode->appendChild($F);
			if($N->childNodes->length>0) $RootNode->appendChild($N);
		}
	}

	function GetQuest($UserId,$QuestId,$XMLDoc,$RootNode) {
		// �������� � XML-�������� $XMLDoc � ���� $RootNode ������ �� ������ $QuestId
		// �������� ���������� �� ������ $QuestId
		// ������� ����
		$CurrentStage = 999;	// 999 - ����������� �����
		$this->Sql->SqlQuery = "select max(uqc.stage) as current_stage from vn_user_quests_conditions uqc where uqc.quest_id=".$this->Sql->Escape($QuestId)." and uqc.user_id=".$this->Sql->Escape($UserId).";";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			while($tmp = $SQLRez->fetch_array()) {
				if($tmp["current_stage"]!=null) $CurrentStage = $tmp["current_stage"];
			}
			$this->Sql->FreeResult($SQLRez);
		}
		// ������ �� ������
		$this->Sql->SqlQuery = "select qc1.stage, uqc.condition, qc1.easy, qc1.easy_prize, qc1.normal, qc1.normal_prize, qc1.hard, qc1.hard_prize from (select ".$this->Sql->Escape($UserId)." as user_id, qc.quest_id, qc.stage, qc.easy, qc.easy_prize, qc.normal, qc.normal_prize, qc.hard, qc.hard_prize from vn_quests_conditions qc where qc.quest_id=".$this->Sql->Escape($QuestId)." and qc.stage<=".$this->Sql->Escape($CurrentStage).") as qc1 left outer join vn_user_quests_conditions uqc on qc1.quest_id=uqc.quest_id and qc1.stage=uqc.stage and qc1.user_id=uqc.user_id;";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			// �� ������ ������
			while($tmp = $SQLRez->fetch_assoc()) {
				$StageNode = $XMLDoc->createElement("stage");
				$StageNode->setAttribute("id",$tmp["stage"]);
				$RootNode->appendChild($StageNode);
				// ������ �� ����������� �����
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
								// � $DiffNode �������� ������ � ��������� � �������
								// �������� �������
								$DiffNode = $XMLDoc->createElement($key);
								$StageNode->appendChild($DiffNode);
								$Usl = new DOMDocument();
								$Usl->loadXML($val);
								// �������� ��������� ��������� �������
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
									// ���� ��������
									if($CurrentStage>$tmp["stage"]) {
										foreach($Usl->firstChild->childNodes as $Node) {
											$Node->nodeValue = $Node->nodeValue."/".$Node->nodeValue;
										}
									}
								}
								// �������� � ������
								$DiffNode->appendChild($XMLDoc->importNode($Usl->documentElement,true));
								// �������� �����
								if($tmp[$key."_prize"]!=null) {
									$Prize = new DOMDocument();
									$Prize->loadXML($tmp[$key."_prize"]);
									// �������� � ������
									$DiffNode->appendChild($XMLDoc->importNode($Prize->documentElement,true));
								}
							}
					}
				}
			}
			$this->Sql->FreeResult($SQLRez);
			// CurrentStage - � �������
			$RootNode->setAttribute("c_stage",$CurrentStage);
		}
	}
	
	function AcceptQuest($UserId,$QuestId,$StageId) {
		// �������� ������ $QuestId ������������� ������� � ����� $StageId
		// ��������� �� ��� �� ��� ������� ���� ����� �� ���� �����
		$this->Sql->SqlQuery = "select quest_id from vn_user_quests_conditions where user_id=".$this->Sql->Escape($UserId)." and quest_id=".$this->Sql->Escape($QuestId)." and stage=".$this->Sql->Escape($StageId).";";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			$Rows = $this->Sql->Rows($SQLRez);
			$this->Sql->FreeResult($SQLRez);
			if($Rows>0) return;	// ��� ���� - �������
		}
		// �������
		$this->Sql->SqlQuery = "select stage, easy, easy_prize, normal, normal_prize, hard, hard_prize from vn_quests_conditions where quest_id=".$this->Sql->Escape($QuestId)." and stage>=".$this->Sql->Escape($StageId)." order by stage;";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			while($tmp = $SQLRez->fetch_array()) {
				if($tmp["easy"]==null) {
					// ��������� ����
					$this->AddPrize($UserId,$QuestId,$tmp["stage"],$tmp["easy_prize"]);
				}
				else {
					// �������
					$Condition = new DOMDocument();
					// ����� ������������ �������
					if($tmp["hard"]!=null) $Condition->loadXML($tmp["hard"]);
					else {
						if($tmp["normal"]!=null) $Condition->loadXML($tmp["normal"]);
						else $Condition->loadXML($tmp["easy"]);
					}
					// �������� ���
					$ConditionNodes = $Condition->firstChild->childNodes;	// <Fly></Fly><Buy></Buy>
					foreach($ConditionNodes as $CNode) {	// <Fly></Fly>
						$CNode->nodeValue = 0;
					}	
					// �������� ������������
					$this->Sql->SqlQuery = "insert into vn_user_quests_conditions (user_id,quest_id,stage,`condition`) values (".$UserId.",".$QuestId.",".$tmp["stage"].",'".$Condition->saveHTML()."');";
					$this->Sql->Exec();
					break;	// ����� ������ ������ �������
				}
			}
			$this->Sql->FreeResult($SQLRez);
		}
	}
	
	function FormFinishConditionFly($PlanetA,$PlanetB) {
		// ������������ ������� ��� ��������� � �������� ������� �� ������� $PlanetB (spaceobject_id)
		return "<condition><Fly PlanetA=\"".$PlanetA."\" PlanetB=\"".$PlanetB."\">1</Fly></condition>";
	}
	
	function FormFinishConditionBuyCargo($CargoId, $CargoValue, $PlanetA) {
		// �������: ������� ����� $CargoId (vn_industry.id) �� ������� $PlanetA (vn_spaceobject.id) � ���������� $CargoValue
		return "<condition><BuyCargo CargoId=\"".$CargoId."\" PlanetA=\"".$PlanetA."\">".$CargoValue."</BuyCargo></condition>";
	}
	
	function FormFinishConditionSellCargo($CargoId, $CargoValue, $PlanetA, $PlanetB) {
		// �������: ������� ����� $CargoId (vn_industry.id) �� ������� $PlanetB (vn_spaceobject.id) ���������� �� ������� $PlanetA (vn_spaceobject.id) � ���������� $CargoValue
		return "<condition><SellCargo CargoId=\"".$CargoId."\" PlanetA=\"".$PlanetA."\" PlanetB=\"".$PlanetB."\">".$CargoValue."</SellCargo></condition>";
	}
	
	function FormFinishConditionLevelUp($Level) {
		// �������: �������� ������ ������������
		return "<condition><LevelUp>".$Level."</LevelUp></condition>";
	}
	
	function CheckFinishConditions($UserId,$CheckingCondition) {
		// �������� ������� ���������� ������� �������� $CheckingCondition � ��������� �� ���������� ������
		// ������� ������������
		$Usr = new UserVn();
		$UserLevel = $Usr->GetUserLevel($UserId);
		// ����������� �������
		$Condition = new DOMDocument();
		$Condition->loadXML($CheckingCondition);
		$CNode = $Condition->firstChild->firstChild;	// $Cond = <Fly>...</Fly>
		$CondNodeName = $CNode->nodeName;	// Fly
		// �������� ������ � vn_user_quests_conditions
		$this->Sql->SqlQuery = "select uq.id, uq.quest_id, q.level, uq.stage, uq.condition, qc.easy, qc.easy_prize, qc.normal, qc.normal_prize, qc.hard, qc.hard_prize from vn_user_quests_conditions uq left outer join vn_quests_conditions qc on uq.quest_id=qc.quest_id and uq.stage=qc.stage left outer join vn_quests q on uq.quest_id=q.id where uq.user_id=".$this->Sql->Escape($UserId).";";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			while($tmp = $SQLRez->fetch_array()) {
				// �� ������ �������
				if($tmp["level"]<=$UserLevel) {
					// ���� ����� ������������� �� ������ ������������
					$UserCondition0 = new DOMDocument();			// UserConditon �� ���������� �������� $CheckingCondition
					$UserCondition0->loadXML($tmp["condition"]);
					$UserCondition = new DOMDocument();				// UserConditon ����������� �������� $CheckingCondition
					$UserCondition->loadXML($tmp["condition"]);
					// �������� $UserCondition �������� $CheckingCondition
					$Updated = false;
					// �� ���� �������� $UserCondition ���� ��� �� ��������������� $Condition
					$UCList = $UserCondition->getElementsByTagName($CondNodeName);	// $UCList = <Fly>...</Fly><Fly>...</Fly><Fly>...</Fly>
					foreach($UCList as $UCNode) {	// $UCNode = <Fly>...</Fly>
						// ��������� �� ������������ ���� ��������� � �� ��������
						$AllAttrEqual = true;
						foreach($UCNode->attributes as $UCAttr) {
						// �� ���� ��������� UCNode ��������� ��� ����� �� �������� ���� � CNode � �������� �����. ���� � UCNode ���� � � CNode ��� ��� ����, �� �������� ������ - �� ��� ����.
							$AttrEqual = false;
							foreach($CNode->attributes as $CAttr) {
								if($UCAttr->nodeName==$CAttr->nodeName&&$UCAttr->nodeValue==$CAttr->nodeValue) {
									// ������ ������� � CNode
									$AttrEqual = true;
									break;
								}
							}
							if($AttrEqual==false) {	// ���� ������� � CNode �� ������ - ��� �������� �� ��������� - �� ��� ����
								$AllAttrEqual = false;
								break;
							}
						}
						if($AllAttrEqual==true) {
							// ������ ������ ���� (�� ������������ ���������) - �������� ���
							$UCNode->nodeValue = $UCNode->nodeValue + $CNode->nodeValue;
							$Updated = true;	// ���� ����������
						}
					}
					if($Updated==true) {
						// ������� ���������� - ��������� �� ������������� ����� ������
						$Easy = new DOMDocument();
						$Easy->loadXML($tmp["easy"]);
						$ECheck0 = $this->CompareConditionsXML($UserCondition0,$Easy);
						$ECheck = $this->CompareConditionsXML($UserCondition,$Easy);
						if($ECheck0==false&&$ECheck==true) {
							// ������� ����� Easy
							// �������� ����
							$this->AddPrize($UserId,$tmp["quest_id"],$tmp["stage"],$tmp["easy_prize"]);
						}
						$NCheck = false;
						if($tmp["normal"]!=null) {
							$Normal = new DOMDocument();
							$Normal->loadXML($tmp["normal"]);
							$NCheck0 = $this->CompareConditionsXML($UserCondition0,$Normal);
							$NCheck = $this->CompareConditionsXML($UserCondition,$Normal);
							if($NCheck0==false&&$NCheck==true) {
							// ������� ����� Normal
							// �������� ����
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
							// ������� ����� Hard
							// �������� ����
							$this->AddPrize($UserId,$tmp["quest_id"],$tmp["stage"],$tmp["hard_prize"]);
							}
						}
						// �������� �������
						if(($ECheck==true&&$tmp["normal"]==null&&$tmp["hard"]==null)||($NCheck==true&&$tmp["hard"]==null)||($HCheck==true)) {
							// ���� �������� - ������� �������
							$this->Sql->SqlQuery = "delete from vn_user_quests_conditions where id=".$this->Sql->Escape($tmp["id"]).";";
							$this->Sql->Exec();
							// �������� �� ���������� ����� ������
							$this->QuestFinished($UserId,$tmp["quest_id"],$tmp["stage"]+1);
						}
						else {
							// �������� �������
							$this->Sql->SqlQuery = "update vn_user_quests_conditions set `condition`='".$this->Sql->Escape($UserCondition->saveHTML())."' where id=".$this->Sql->Escape($tmp["id"]).";";
							$this->Sql->Exec();
						}
						// ���� ��� ������� ����� Easy - �������� ����� ����
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
		// ���������� ��� ������� � XML-�������. ������� ��� Condition ������ Base (����� true) ���� � Condition ���� ��� ���� �� Base
		// � ��� Value � ��������������� ����� Condition >= Value � ��� �� ����� Base
		$Rez = true;	// "C>B";
		// ����� ����� ���� �� ���� ���� � Base, ������� > ���� � Condition ��� �������� ��� � Condition - ����� B>C
		// �� ���� ����� Base
		$BaseNodes = $Base->firstChild->childNodes;	// <Fly></Fly><Buy></Buy>
		foreach($BaseNodes as $BaseNode) {	// <Fly></Fly>
			$NodeFound = false;	// true - ���� ������. ���� ������ ���� � Condition �� ������� - Base > Condition
//			echo "---<br>Base: ".$BaseNode->nodeName." - ".$BaseNode->nodeValue."<br>";
			// ��������� ������ ���� Base
			// ���� ����� �� � Condition
			$CList = $Condition->getElementsByTagName($BaseNode->nodeName);	//<Fly>...</Fly><Fly>...</Fly> ��� Base->nodeName = "Fly"
			foreach($CList as $CNode) {	// <Fly></Fly>
//				echo "-Cond: ".$CNode->nodeName." - ".$CNode->nodeValue."<br>";
				// Condition ����� �������, ������ ���� � ������� Base ���� ��� ��������� ������� Condition � �� �������� �����
				// ���� � Condition-���� ���������� ���-�� ��������� � Base-����� - ������� ������, ���� ������ - ��������� � ���������� ����
				if($BaseNode->attributes->length==$CNode->attributes->length) {
//					echo "--Base-Cond Attr->length: ".$BaseNode->attributes->length." - ".$CNode->attributes->length."<br>";
					$AllAttrEqual = true;
					foreach($BaseNode->attributes as $BaseAttr) {
					// �� ���� ��������� Base-���� ��������� ��� ����� �� �������� ���� � Condition-���� � �������� �����. ���� � Base ���� � � Condition ��� ��� ����, �� �������� ������ - �� ��� ����.
//						echo "---BaseAttr: ".$BaseAttr->nodeName." - ".$BaseAttr->nodeValue."<br>";
						$AttrEqual = false;
						foreach($CNode->attributes as $CAttr) {
//							echo "----CAttr: ".$CAttr->nodeName." - ".$CAttr->nodeValue."<br>";
							if($BaseAttr->nodeName==$CAttr->nodeName&&$BaseAttr->nodeValue==$CAttr->nodeValue) {
								// ������ ������� � Condition ����
								$AttrEqual = true;
								break;
							}
						}
						if($AttrEqual==false) {	// ���� ������� � Condition-���� �� ������ - ��� �������� �� ��������� - �� ��� ����
							$AllAttrEqual = false;
							break;
						}
					}
					if($AllAttrEqual==true) {
						// ������ ������ ���� (�� ������������ ���������)
						$NodeFound = true;
						if($BaseNode->nodeValue>$CNode->nodeValue) $Rez = false;	// "B>C";
						break;
					}
				}
			}
			if($NodeFound==false) {
				// B>C �.�. ����������� ��� ���� Condition � �� ���� �� ������� � ���� Base (� Base ����, � Condition ���) (�������� Easy ���������� � Normal)
				$Rez = false;	// "B>C";
				break;
			}
		}
		return $Rez;
	}
	
	function AddPrize($UserId,$QuestId,$StageId,$PrizeString) {
		// �������� ������������ ����� �� ���������� ������
		if($PrizeString!=null&&$PrizeString!="")  {
			$TextDoc = new DOMDocument();	// ��� ���������� ������ ������
			$Text = $TextDoc->createElement('text');
			$TextDoc->appendChild($Text);
			$Prize = new DOMDocument();	// ��� ���������� ������ ������
			$Prize->loadXML($PrizeString);
			$PrizeNodes = $Prize->firstChild->childNodes;	// <Gold></Gold><Crystals></Crystals>
			$Usr = new UserVn();
			foreach($PrizeNodes as $Node) {	// <Gold></Gold>
				switch($Node->nodeName) {
					case "Text":		// Text - ��������� ��������� ������� � �������������� ����� ��������
						$Text->appendChild($TextDoc->importNode($Node,true));
						break;
					case "Gold":		// ������
						$Usr->UpdateMoney($UserId,$Node->nodeValue);
						break;
					case "Crystals":	// ���������
						$Usr->UpdateCrystals($UserId,$Node->nodeValue);
						break;
					case "Exp":			// ����
						$Usr->UpdateExp($UserId,$Node->nodeValue);
						break;
					case "Ship":		// �������
						// ���� ��� �������� - ������ �� ������
						if($Node->attributes->getNamedItem("type")!=NULL&&$Node->attributes->getNamedItem("type")->nodeValue=="a") break;
						// ���� ���� - ��������� ������������
						$ShipsManager = new Ships();
						// �������
						$NewShip = 1;
						$NewShipId = $Node->attributes->getNamedItem("Id")->nodeValue;
						if($NewShipId!=NULL) $NewShip = $NewShipId;
						// �������
						$DestPlanet = 9;										// �� 10 ������ - �������� �� ����
						if($Usr->GetUserLevel($UserId)>=10) $DestPlanet = 22;	// ����� �������� ����� - �������� � �����
						// �������� ������� ������������
						$ShipsManager->AddShipToUser($UserId,$NewShip,$DestPlanet,$DestPlanet);
						break;
					case "Quest":		// ����� �����
						$NewQuestId = $Node->attributes->getNamedItem("Id")->nodeValue;
						$this->AcceptQuest($UserId,$NewQuestId,1);	// � 1 �����
						break;
					default:
						// ��� ���������� (������ �������� � �� �����) ������ �� ������
						// ������� type="�" ��������� � ���� vn_quests_conditons
				}
			}
			// �������� ����� - ��� ������ ��������� ������������
			if($QuestId!=null && $StageId!=null) {
				// ������� ��������� ��������� - ��� ������������ �������� (����� � �� � foreach �.�. ����� ���� ���������)
				$TextNodes = $Prize->getElementsByTagName("Text");
				if($TextNodes->length!=0) {
					$TextNodeToDel = $TextNodes->item(0);
					$TextNodeToDel->parentNode->removeChild($TextNodeToDel);
				}
				// �������� � vn_user_quests_prize ������ � ������
				if($Prize->firstChild->childNodes->length!=0) {
					// ���� � $Prize ���� ���-�� ����� Text - ��������
					$this->Sql->SqlQuery = "insert into vn_user_quests_prize (user_id,quest_id,stage,prize,`order`) values (".$this->Sql->Escape($UserId).",".$this->Sql->Escape($QuestId).",".$this->Sql->Escape($StageId).",'".$this->Sql->Escape($Prize->saveHTML())."',1);";
					$this->Sql->Exec();
				}
				// �������� � vn_user_quests_prize ������ � ��������� ����������
				if($TextDoc->firstChild->childNodes->length!=0) {
					$this->Sql->SqlQuery = "insert into vn_user_quests_prize (user_id,quest_id,stage,prize,`order`) values (".$this->Sql->Escape($UserId).",".$this->Sql->Escape($QuestId).",".$this->Sql->Escape($StageId).",'".$this->Sql->Escape($TextDoc->saveHTML())."',0);";
					$this->Sql->Exec();
				}
			}
		}
	}
	
	function GetQuestsPrize($UserId,$XMLDoc,$RootNode) {
		// �������� � XML-�������� $XMLDoc � ���� $RootNode ������ �� ������� ����� �� �����
		// �������� ���������� �� ������� ������ �� �������� ���� ����
		$this->Sql->SqlQuery = "select uqp.id, q.name, uqp.quest_id, uqp.stage, uqp.prize from vn_user_quests_prize uqp left outer join vn_quests q on uqp.quest_id=q.id where uqp.user_id=".$this->Sql->Escape($UserId)." order by uqp.quest_id, uqp.stage, uqp.`order` limit 1;";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			while($tmp = $SQLRez->fetch_assoc()) {
				while (list($key, $val) = each($tmp)) {
					switch($key) {
						case "id":	// id - � ������� RootNode
							$RootNode->setAttribute($key,$val);
							break;
						case "quest_id":	// quest_id - � ������� RootNode
							$RootNode->setAttribute($key,$val);
							break;
						case "stage":	// stage - � ������� RootNode
							$RootNode->setAttribute($key,$val);
							break;
						case "name":	// name - � ������� RootNode
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
		// ������������� ��� ����� � Id = $PrizeId �������� - ������� �� �� ������� ������
		$this->Sql->SqlQuery = "delete from vn_user_quests_prize where id=".$this->Sql->Escape($PrizeId).";";
		$this->Sql->Exec();
		return "T";
	}
	
	function QuestFinished($UserId,$QuestId,$StageId) {
		// �������� �� ���������� ������������� $UserId ������ $QuestId �� ����� $StageId
		if($StageId==1) return;
		// ���� �� � ����� ������ ��������� ����
		$this->Sql->SqlQuery = "select quest_id, stage from vn_quests_conditions where quest_id=".$this->Sql->Escape($QuestId)." and stage=".$this->Sql->Escape($StageId).";";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			if($this->Sql->Rows($SQLRez)==0) {
				// ������� 0 ����� - ������ ���������� ����� ��� - ����� ��������
				$this->Sql->SqlQuery = "insert into vn_user_quests_finished (user_id,quest_id) values (".$this->Sql->Escape($UserId).",".$this->Sql->Escape($QuestId).");";
				$this->Sql->Exec();
			}
			$this->Sql->FreeResult($SQLRez);
		}
	}
	
	function AcceptDynamicQuest($UserId,$QuestId,$XMLDoc) {
		// �������� ������������� $UserId ������������� ������ $QuestId
		$Usr = new UserVn();
		$XEx = new XMLEx();
		// ��������� �� ����������� ��������
		// ����� ������ �� ������
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
		if($UserLevel<$QuestLevel) return $XEx->CreateXMLErr("177",$XMLDoc);	// "������� ������� ������� �����"
		// �������� �������� - ������� �����
		$this->AcceptQuest($UserId,$QuestId,1);
		// ������� ������ �� ��������� ������
		$XEx->CreateXMLErr("0",$XMLDoc);	// 0 - ��� ������ (����� ������)
	}
}
?>