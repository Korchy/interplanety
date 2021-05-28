<?php
//---------------------------------
require_once("starsystem_vn.inc.php");
require_once("quests.inc.php");
require_once("xmlex.inc.php");
	// include ���� �������� ����������� �������� �������, ������� ��������� �� ����� �� vn_object
require_once("starv.inc.php");
require_once("orbitv.inc.php");
require_once("planetv.inc.php");
//---------------------------------
class StarSystemVVn extends StarSystemVn
{

	public function __construct() {
		// ����������� ��������
		parent::__construct();
		// �����������
		$this->XEx = new XMLEx();
	}

	public function __destruct() {
		// ����������
		unset($this->XEx);
		// ���������� ��������
		parent::__destruct();
	}
	
	public function GetStarSystemXML($Id) {
		// ���������� � ������� XML ������ �� ����������� �������� ����������� �������� �������
		// ���� $Id==null - ������������ ��� �������, ���� ��� - ������ ���� ������ � ������ Id
		$UserId = $_SESSION["vn_id"];	// id ������������
		$Doc = new DOMDocument('1.0','utf-8');
		$Sector = $Doc->createElement('V');
		if($Id==null) {
			// ������� ������ �� ��� �������
			$this->Sql->SqlQuery = "select uss.id, uss.sub_id, uss.s_point_x, uss.s_point_y, uss.s_point_z, uss.spaceobject_id, so.type from vn_user_starsystem uss left outer join vn_spaceobject so on uss.spaceobject_id=so.id where (!isnull(uss.sub_id) or !isnull(uss.s_point_x)) and uss.user_id='".$this->Sql->Escape($UserId)."' order by id, sub_id;";
		}
		else {
			// ������� ������ ������ �� ������ ������� � $Id
			$this->Sql->SqlQuery = "select uss.id, uss.sub_id, uss.s_point_x, uss.s_point_y, uss.s_point_z, uss.spaceobject_id, so.type from vn_user_starsystem uss left outer join vn_spaceobject so on uss.spaceobject_id=so.id where uss.id='".$this->Sql->Escape($Id)."' and uss.user_id='".$this->Sql->Escape($UserId)."';";
		}
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			// ������� �� ���������� ������ XML-��������
			while($tmp = $SQLRez->fetch_array()) {
				// ��� ������� ������� ���� ����
				// �������� ���� � ������� �� ������� �������
				$SO = new $tmp["type"]();
				// ��� ����������� ����� - �� id � vn_user_starsystem �.�. ��� ��� spaceobject=24, � ��������� ������������� ������������� �� id � ������� ������������
				if($tmp["type"]=="OrbitV") $SOXML = $SO->GetFullInfo($tmp["spaceobject_id"],$tmp["id"]);
				else $SOXML = $SO->GetInfo($tmp["spaceobject_id"]);
				// � ������ ��������������� ��� ������� ���� �������� ������ �� vn_user_starsystem
				// spaceobject_id � ��������
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
				// �������� ���������� ���� � ������ ����������� �� ������� � ������
				$Sector->appendChild($Doc->importNode($SOXML->documentElement,true));
			}
			$this->Sql->FreeResult($SQLRez);
		}
		$Doc->appendChild($Sector);
		return $Doc;
	}

	public function GetItemsFromStorageXML($UserId) {
		// ���������� ������ ������ �� ��������� ����������� �������� �������
		// ������ XML
		$Doc = new DOMDocument('1.0','utf-8');
		$Storage = $Doc->createElement('vs');
		// �������� ������
		$this->Sql->SqlQuery = "select uss.spaceobject_id from vn_user_starsystem uss where (isnull(uss.sub_id) and isnull(uss.s_point_x)) and uss.user_id='".$this->Sql->Escape($UserId)."' group by uss.spaceobject_id;";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			// ������� �� ���������� ������ XML-��������
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
		// ���������� ������ �� ����� c $SpaceObjectId
		$Doc = new DOMDocument('1.0','utf-8');
		// �� $Id � ������� �������� ������
		$this->Sql->SqlQuery = "select count(uss.id) as stack, so.type from vn_user_starsystem uss inner join vn_spaceobject so on uss.spaceobject_id=so.id where (isnull(uss.sub_id) and isnull(uss.s_point_x)) and uss.spaceobject_id='".$this->Sql->Escape($SpaceObjectId)."' and uss.user_id='".$this->Sql->Escape($UserId)."' group by uss.spaceobject_id;";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			// ������� �� ���������� ������ XML-��������
			while($tmp = $SQLRez->fetch_array()) {
				$Node = $Doc->createElement($tmp["type"]);
				// �������� ���� � ������� �� ������� �������
				$SO = new $tmp["type"]();
				$SOXML = $SO->GetInfo($SpaceObjectId);
				// �������� ���������� � �����
				$StackNode = $Doc->createElement("stack");
				$StackValue = $Doc->createTextNode($tmp["stack"]);
				$StackNode->appendChild($StackValue);
				$SOXML->documentElement->appendChild($SOXML->importNode($StackNode,true));
				// �������� ���� � ������� �� ������� � ����� ������
				$Doc->appendChild($Doc->importNode($SOXML->documentElement,true));
			}
			$this->Sql->FreeResult($SQLRez);
		}
		return $Doc;
	}
	
	public function ConvertPrizeObjectFromStorage($SpaceObjectId,$SubId,$NewX,$NewY,$NewZ) {
		// �������������� ����������� ���� � ������ ����������� �������� �������
		$UserId = $_SESSION["vn_id"];	// id ������������
		// ���� ��������� ������ � ������ spaceobject_id
		$ConvId = null;
		$ConvType = null;
		$this->Sql->SqlQuery = "select uss.id, so.type from vn_user_starsystem uss left outer join vn_spaceobject so on uss.spaceobject_id=so.id where uss.spaceobject_id='".$this->Sql->Escape($SpaceObjectId)."' and (isnull(uss.sub_id) and isnull(uss.s_point_x)) and uss.user_id='".$this->Sql->Escape($UserId)."' limit 1;";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			// ������� �� ���������� ������ XML-��������
			while($tmp = $SQLRez->fetch_array()) {
				$ConvId = $tmp["id"];
				$ConvType = $tmp["type"];
			}
			$this->Sql->FreeResult($SQLRez);
		}
		if($ConvId==null) return "0";
		// ��������� ���� �������� ����������������� ����: �� ����������� ��� �� ������
		if($SubId!="null") {
			// �������� �������� �� ������
			// ��������� ��� $SubId
			$this->Sql->SqlQuery = "select so.type from vn_user_starsystem uss left outer join vn_spaceobject so on uss.spaceobject_id=so.id where uss.id='".$this->Sql->Escape($SubId)."' and uss.user_id='".$this->Sql->Escape($UserId)."';";
			$this->Sql->Exec();
			if($SQLRez = $this->Sql->SqlRez) {
				while($tmp = $SQLRez->fetch_array()) {
					$SubType = $tmp["type"];
					// ���������, ��� �� ������ ��� $SubId ����� ��������� $ConvId
					// �� ������ ����� ������ ��� ������
					// ������ ����� ������ �� ��� ������
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
		// Id ������� - ������� ������
		$this->Sql->SqlQuery = "update vn_user_starsystem set sub_id=".$this->Sql->Escape($SubId).", s_point_x=".$this->Sql->Escape($NewX).", s_point_y=".$this->Sql->Escape($NewY).", s_point_z=".$this->Sql->Escape($NewZ)." where id='".$this->Sql->Escape($ConvId)."';";
		$this->Sql->Exec();
		// ����� �������� ������� �������� � XML ������ �� ���� ��� �������� �������
		return $this->GetStarSystemXML($ConvId);
	}

	public function ConvertPrizeObjectToStorage($Id,$UserId) {
		// �������������� ������ ����������� �������� ������� � ����������� ����
		// ���������� XML � ������������������ Id ������ ��� ��������� �� ������
		$XMLDoc = new DOMDocument('1.0','utf-8');
		// �.�. ������ ����� ���� �� ������� - ������� Id ���� ��������, ������� ����� �� �������
		$AllId = $this->GetChildrens($Id);	// Id �������� � ������� �� ��� ��������
		// ������� �� ��� �� �������
		$this->Sql->SqlQuery = "update vn_user_starsystem set sub_id=null, s_point_x=null, s_point_y=null, s_point_z=null where id in(".$this->Sql->Escape($AllId).");";
		$this->Sql->Exec();
		if($this->Sql->SqlRez) {
			// �������� �������
			$Storage = $XMLDoc->createElement('vs');
			// �� ������ Id �������� ������ ������ (SpaceObjectId)
			$this->Sql->SqlQuery = "select uss.spaceobject_id from vn_user_starsystem uss where id in(".$this->Sql->Escape($AllId).") group by uss.spaceobject_id;";
			$this->Sql->Exec();
			if($SQLRez = $this->Sql->SqlRez) {
				// ������� �� ���������� ������ XML-��������
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
			$this->XEx->CreateXMLErr("117",$XMLDoc);	// "��������� �������"
		}
		return $XMLDoc;
	}
	
	public function ReplacePrizeObject($Id,$SubId,$NewX,$NewY,$NewZ) {
		// ����������� ������� � ����������� �������
		// ��������� - ������ �� ������ ������ ��� �� �����������
		if($this->CheckParentEnable($Id,$SubId)==true) {
			// �� ������
			$NewX = "null";
			$NewY = "null";
			$NewZ = "null";
		}
		else {
			// �� ����������
			$SubId = "null";
		}
		$XMLDoc = new DOMDocument('1.0','utf-8');
		$this->Sql->SqlQuery = "update vn_user_starsystem set sub_id=".$this->Sql->Escape($SubId).", s_point_x=".$this->Sql->Escape($NewX).", s_point_y=".$this->Sql->Escape($NewY).", s_point_z=".$this->Sql->Escape($NewZ)." where id='".$this->Sql->Escape($Id)."';";
		$this->Sql->Exec();
		if($this->Sql->SqlRez) {
			// �������� �������
			$RootNode = $XMLDoc->createElement("Rez");
			$Node = $XMLDoc->createElement("Id");
			$Value = $XMLDoc->createTextNode($Id);
			$Node->appendChild($Value);
			$RootNode->appendChild($Node);
			if($SubId!="null") {
				// ������� � �������
				$Node = $XMLDoc->createElement("SubId");
				$Value = $XMLDoc->createTextNode($SubId);
				$Node->appendChild($Value);
				$RootNode->appendChild($Node);
			}
			else {
				// ������� � �����������
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
//			$this->XEx->CreateXMLErr("0",$XMLDoc);	// ��� ������ (0)
		}
		else {
			// ������
			$this->XEx->CreateXMLErr("196",$XMLDoc);	// "������ �����������"
		}
		return $XMLDoc;
	}
	
	public function GetChildrens($Id) {
		// �������� ������ ���� ��������, ������� ����� �� �������
		// ���������� ������ � Id ����� �������
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
		// ��������, ����� �� ���� ������ � $ChildId ������� ������� � $ParentId (����� �� $ChildId ��������� �� $ParentId)
		// ���������� ture - �����, false - ���
		// �� null ������� ������
		if($ParentId=="null") return false;	// �� �����
		// ������ ������� �� ���� �� �������
		$AllChildren = ",".$this->GetChildrens($ChildId).",";	// Id �������� � ������� �� ��� ��������
		if(substr_count($AllChildren,",".$ParentId.",")>0) return false;
		// �������� �� �����
		$ChildType = "";
		$ParentType = "";
		// �������� ��� �������
		$this->Sql->SqlQuery = "select so.type from vn_user_starsystem uss inner join vn_spaceobject so on uss.spaceobject_id=so.id where uss.id='".$this->Sql->Escape($ParentId)."';";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			while($tmp = $SQLRez->fetch_array()) {
				$ParentType = $tmp["type"];
			}
			$this->Sql->FreeResult($SQLRez);
		}
		// �������� ��� ������
		$this->Sql->SqlQuery = "select so.type from vn_user_starsystem uss inner join vn_spaceobject so on uss.spaceobject_id=so.id where uss.id='".$this->Sql->Escape($ChildId)."';";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			while($tmp = $SQLRez->fetch_array()) {
				$ChildType = $tmp["type"];
			}
			$this->Sql->FreeResult($SQLRez);
		}
		// �� ������ ����� ������ ��� ������
		// ������ ����� ������ �� ��� ������
		if($ParentType=="OrbitV" || $ChildType=="OrbitV") {
			return true;	// �����
		}
		else {
			return false;	// �� �����
		}
	}
	
	public function GetBonusInfo($Id, $UserId) {
		// �������� ������ �� ������ �� ������������ ������� c $Id (vn_user_starsystem.id)
		$XMLDoc = new DOMDocument('1.0','utf-8');
		$this->Sql->SqlQuery = "select uss.id, sov.bonus, cast(sov.bonus_interval-(unix_timestamp(now())-unix_timestamp(uss.bonus_getted)) AS SIGNED) as dest from vn_user_starsystem uss left outer join vn_spaceobject_v sov on uss.spaceobject_id=sov.spaceobject_id where uss.user_id='".$this->Sql->Escape($UserId)."' and uss.id='".$this->Sql->Escape($Id)."';";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			while($tmp = $SQLRez->fetch_array()) {
				if(!is_null($tmp["bonus"])) {
					$XMLDoc->loadXML($tmp["bonus"]);
					$TimeRemain = 0;	// �������� ������� (� ���)
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
		// ��������� ������ $UserId ����� �� ������������ ������� c $Id (vn_user_starsystem.id)
		$XMLDoc = new DOMDocument('1.0','utf-8');
		$this->Sql->SqlQuery = "select uss.id, sov.bonus, cast(sov.bonus_interval-(unix_timestamp(now())-unix_timestamp(uss.bonus_getted)) AS SIGNED) as dest from vn_user_starsystem uss left outer join vn_spaceobject_v sov on uss.spaceobject_id=sov.spaceobject_id where uss.user_id='".$this->Sql->Escape($UserId)."' and uss.id='".$this->Sql->Escape($Id)."';";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			while($tmp = $SQLRez->fetch_array()) {
				if(!is_null($tmp["bonus"])) {
					// ��������
					// ������ �� ��������� ��������?
					if(!is_null($tmp["dest"])&&$tmp["dest"]>0) {
						// ����� ��� �� ������
						$this->XEx->CreateXMLErr("198",$XMLDoc);	// "��������� �������� �� ��������"
						break;
					}
					// �������� �������� - �������� ����� ������������
					$Qst = new Quests();
					$Qst->AddPrize($UserId,null,null,$tmp["bonus"]);
					$this->XEx->CreateXMLErr("0",$XMLDoc);	// ��� ������ (0) - ������ ���������
					// ������������� ����� ���������
					$this->Sql->SqlQuery = "update vn_user_starsystem set bonus_getted=now() where user_id='".$this->Sql->Escape($UserId)."' and id='".$this->Sql->Escape($Id)."';";
					$this->Sql->Exec();
				}
			}
			$this->Sql->FreeResult($SQLRez);
		}
		return $XMLDoc;
	}
	
	public function GetVirtualObject($SpaceObjectId, $UserId) {
		// ������ ������������ $UserId ������ ����������� ������� ���� $SpaceObjectId
		// ��������� ��� (������/������)
		$this->Sql->SqlQuery = "select type from vn_spaceobject where id='".$this->Sql->Escape($SpaceObjectId)."';";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			while($tmp = $SQLRez->fetch_array()) {
				// ����� � vn_user_starsystem
				$this->Sql->SqlQuery = "insert into vn_user_starsystem (user_id, spaceobject_id) values ('".$this->Sql->Escape($UserId)."', '".$this->Sql->Escape($SpaceObjectId)."');";
				$this->Sql->Exec();
				// ��� ����� - ���������� ������
				if($tmp["type"]=="OrbitV") {
					// ������ � vn_user_starsystem_orbits_v
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