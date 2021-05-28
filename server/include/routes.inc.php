<?php
//---------------------------------
require_once("dbconnected_vn.inc.php");
require_once("servertime.inc.php");
require_once("common.inc.php");
require_once("user.inc.php");
require_once("quests.inc.php");
require_once("socketio_vn.inc.php");
require_once("vector2.inc.php");
require_once("starsystem_vn.inc.php");
//---------------------------------
class URoutes extends DBConnectedVn
{
	private $Comm;
	private $StarSystem;

	function __construct() {
		// ����������� ��������
		parent::__construct();
		// �����������
		$this->Comm = new Common();
		$this->StarSystem = new StarSystemVn();
	}

	function __destruct() {
		// ����������
		unset($this->Comm);
		unset($this->StarSystem);
		// ���������� ��������
		parent::__destruct();
	}

	function CreateRoute($PlanetId,$ShipId) {
		// �������� �������� ��� ������� $ShipId �� ������� $PlanetId (spaceobject_id)
		if($PlanetId==0||$ShipId==0) return "F";
		// ������� �����
		$ServTime = new ServerTime();
		$STime = $ServTime->GetServerTime();
		// ��������� �� �������� �� ������� ������ = ������� ����������
		// � ��� ������� ��������� �� ������� � �� � ������
		$PlanetA = 0;		// ���� �������� - ��������� ������� ������
		$this->Sql->SqlQuery = "select a_planet,b_planet from vn_user_ships where id=".$this->Sql->Escape($ShipId).";";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			while($tmp = $SQLRez->fetch_array()) {
				if($tmp["a_planet"]==$PlanetId||$tmp["a_planet"]!=$tmp["b_planet"]) {
					$this->Sql->FreeResult($SQLRez);
					return "F";
				}
				else $PlanetA = $tmp["a_planet"];
			}
			$this->Sql->FreeResult($SQLRez);
		}
		// ��������� ����������� ������� �� ������
		$Usr = new UserVn();
		$UserLevel = $Usr->GetUserLevel($_SESSION["vn_id"]);
		$PlanetLevel = 0;
		$this->Sql->SqlQuery = "select pr.level from vn_planet_r pr where pr.spaceobject_id='".$this->Sql->Escape($PlanetId)."';";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			while($tmp = $SQLRez->fetch_array()) {
				$PlanetLevel = $tmp["level"];
			}
			$this->Sql->FreeResult($SQLRez);
		}
		if($PlanetLevel>$UserLevel) return "F";
		// ��� ������� ��������� - ������� �������
		$PlanetB = $PlanetId;
		// ����� ��������
//echo $PlanetA."<p>";
//echo $PlanetB."<p>";
//echo $ShipId."<p>";
		$DestTime = $STime + $this->CountFlyTimeAB($PlanetA,$PlanetB,$ShipId)*1000;		// � ������������
//echo ($DestTime-$STime)."<br>";
//echo (($DestTime-$STime)/1000)." ���<br>";
//echo (($DestTime-$STime)/1000/60)." min<br>";
//echo (($DestTime-$STime)/1000/60/60)." hours<br>";
		if($DestTime==$STime) return "F";
		// ������� �������
		$this->Sql->SqlQuery = "update vn_user_ships set b_planet=".$this->Sql->Escape($PlanetId).", a_time=".$STime.", b_time=".$DestTime." where id=".$this->Sql->Escape($ShipId).";";
		$this->Sql->Exec();
		return "T";
	}

	function CountPlanetPos($ObjectId,$Time,$RealPos) {
		// �������� ��������� �������/������� $ObjectId (spaceobject_id) � ������ ������� $Time
		// $RealPos = true - ��������� �������� ���������, = false - ����������
		// ���������� ��������� �������� ���� ��������� ��������� �������
		// �������� ����� ����:
		//		�������� ������ � ������������
		//		������ - ������ - ������ (����� ���� ����� ������� �����������)
		$ParentOffset = new Vector2(0,0);
		$ParOffset = new Vector2(0,0);
		$this->Sql->SqlQuery = "select sm.s_point_x as own_x, sm.s_point_y as own_y, sor.k_real as own_k_real, sm2.spaceobject_id as parent_id, sm2.sub_id as parent_sub_id, sm2.s_point_x as parent_x, sm2.s_point_y as parent_y, sor2.k_real as parent_k_real from vn_starsystem sm left outer join vn_starsystem sm1 on sm.sub_id=sm1.id left outer join vn_starsystem sm2 on sm1.sub_id=sm2.id left outer join vn_spaceobject_r sor on sm.spaceobject_id=sor.spaceobject_id left outer join vn_spaceobject_r sor2 on sm2.spaceobject_id=sor2.spaceobject_id where sm.spaceobject_id='".$this->Sql->Escape($ObjectId)."';";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			while($tmp = $SQLRez->fetch_array()) {
				switch($tmp["parent_sub_id"]) {
					case null:
						// ��������� ������ � ������������
						$Rez = new Vector2();
						if($RealPos==false) $Rez = new Vector2($tmp["own_x"],$tmp["own_y"]);
						else $Rez = new Vector2($tmp["own_x"]*$tmp["own_k_real"],$tmp["own_y"]*$tmp["own_k_real"]);
						$this->Sql->FreeResult($SQLRez);
						return $Rez;
						break;
					case 0:
						// ����� �� ��������� (����������� ������)
						if($RealPos==false) {
							$ParOffset->X = $tmp["parent_x"];
							$ParOffset->Y = $tmp["parent_y"];
						}
						else {
							$ParOffset->X = $tmp["parent_x"]*$tmp["parent_k_real"];
							$ParOffset->Y = $tmp["parent_y"]*$tmp["parent_k_real"];
						}
						break;
					default:
						// �������� ��������� �������� �� ���� �������
						$ParOffset = $this->CountPlanetPos($tmp["parent_id"],$Time,$RealPos);
				}
				$ParentOffset->X += $ParOffset->X;
				$ParentOffset->Y += $ParOffset->Y;
			}
			$this->Sql->FreeResult($SQLRez);
		}
		// ���������� ��������� ������� $ObjectId (spaceobject_id) �� �� ������
		$this->Sql->SqlQuery = "select sor.k_real, o.radius_s, o.radius_l, o.angle, o.speed from vn_starsystem sm left outer join vn_starsystem sm1 on sm.sub_id=sm1.id inner join vn_orbit o on sm1.spaceobject_id=o.spaceobject_id inner join vn_spaceobject_r sor on sm1.spaceobject_id=sor.spaceobject_id where sm.spaceobject_id='".$this->Sql->Escape($ObjectId)."';";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			$tmp = $SQLRez->fetch_array();
			// ������ �� ������
			$RadiusL = $tmp["radius_l"];
			if($RealPos==true) $RadiusL = $RadiusL*$tmp["k_real"];
			$RadiusS = $tmp["radius_s"];
			if($RealPos==true) $RadiusS = $RadiusS*$tmp["k_real"];
			$RadiusSL = ($RadiusL+$RadiusS)/2.0;					// ����������� ������
			$Ang = -$tmp["angle"]*M_PI/180;							// ���� ������� �������
			$LinSpeed = round($tmp["speed"]*$Time/$RadiusSL,2);	// �������� �������� ��������
			if($RealPos==true) $LinSpeed = round($tmp["speed"]*$tmp["k_real"]*$Time/$RadiusSL,2);
			$as0 = round(sin($Ang),2);
			$ac0 = round(cos($Ang),2);
			$x0 = round($RadiusL*cos($LinSpeed),2);
			$y0 = round($RadiusS*sin($LinSpeed),2);
			$NewX = round($x0*$ac0+$y0*$as0+$ParentOffset->X);
			$NewY = round(-$x0*$as0+$y0*$ac0+$ParentOffset->Y);
			$this->Sql->FreeResult($SQLRez);
			return new Vector2($NewX,$NewY);
		}
	}
	
	public function CountMROffset($PlanetId) {
		// ���������� �������� ������� (spaceobject_id) ������������ ������ (����������� �� ����� ������� ��������)
		$this->Sql->SqlQuery = "select sm.s_point_x as own_x, sm.s_point_y as own_y, sor.k_real as own_k_real, o.radius_l as orbit_radius_l, o.radius_s as orbit_radius_s, sor1.k_real as orbit_k_real, sm2.spaceobject_id as parent_id from vn_starsystem sm left outer join vn_starsystem sm1 on sm.sub_id=sm1.id left outer join vn_orbit o on sm1.spaceobject_id=o.spaceobject_id left outer join vn_starsystem sm2 on sm1.sub_id=sm2.id inner join vn_spaceobject_r sor on sm.spaceobject_id=sor.spaceobject_id left outer join vn_spaceobject_r sor1 on sm1.spaceobject_id=sor1.spaceobject_id where sm.spaceobject_id='".$this->Sql->Escape($PlanetId)."';";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			$tmp = $SQLRez->fetch_array();
			if(!is_null($tmp["parent_id"])) {
					$ParentOffset = $this->CountMROffset($tmp["parent_id"]);
					$Rez = round(($tmp["orbit_radius_l"]+$tmp["orbit_radius_s"])*$tmp["orbit_k_real"]/2 + $ParentOffset);
					$this->Sql->FreeResult($SQLRez);
					return $Rez;
				}
			else {
				$Rez = sqrt(($tmp["own_x"]*$tmp["own_x"])+($tmp["own_y"]*$tmp["own_y"]))*$tmp["own_k_real"];
				$this->Sql->FreeResult($SQLRez);
				return $Rez;
			}
		}
	}
	
	function CountFlyTimeAB($PlanetA,$PlanetB,$ShipId) {
		// �������� ����� ������ (� ���.) ����� ��������� $PlanetA � $PlanetB (spaceobject_id) ��� ������� ������������ $ShipId
		// ��������� ���: ����� ������� ���������� ����� ���������. ������� ���������� ����������� ��� � ���������� �� ������������ ��
		// ������������� ���������� ����� ����� ��������� (��� � ���� ���������� ��������� �� �������� �������, ����� ������� ����� �
		// ����� ��� �� �������������� ��������). ����� ������� �� ���. ����������, ������� �� ���� ���������� �������. � ������� ���.
		// ���������� ��������� ����������. ����� ������� ����� � ��������: ���. ���������� - 2 ���. ����������, ������������ � �����������
		// �� �������� ���������� ����� ���������
		$ServTime = new ServerTime();
		$STime = $ServTime->GetServerTime();
		$Pa = $this->CountPlanetPos($PlanetA,$STime,true);
//echo $PlanetA.": X=".$Pa->X." Y=".$Pa->Y."<p>";
		$Pb = $this->CountPlanetPos($PlanetB,$STime,true);
//echo $PlanetB."B: X=".$Pb->X." Y=".$Pb->Y;
		// ����������� ����� ���������
		$V = Vector2::Vec2Subtract($Pa,$Pb);
		$L = $V->Length();
		// ����. � ���. ���������� ����� ���������
		$PaOffset = $this->CountMROffset($PlanetA);
//echo $PlanetA." A MROffset= ".$PaOffset."<p>";
		$PbOffset = $this->CountMROffset($PlanetB);
//echo $PlanetB." B MROffset= ".$PbOffset."<p>";
		$LMax = $PaOffset+$PbOffset;
		$LMin = abs($PaOffset-$PbOffset);
		// ���������� �������� ��� �������� ���������� ������������ ������������� (�.�. ������ >= 1)
		$Proc = $L/$LMax;
		// ����� ���. ���������� � ����������� � ������������ � ��������� �� �������������
		$L = $LMin+$LMin*$Proc;
//echo $L."<p>";
		// ������ �������� �������
		$this->Sql->SqlQuery = "select s.speed from vn_user_ships us inner join vn_ship s on us.ship_id=s.id where us.id=".$this->Sql->Escape($ShipId).";";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			while($tmp = $SQLRez->fetch_array()) {
				$FlyTime = round($L/$tmp["speed"]);
			}
			$this->Sql->FreeResult($SQLRez);
		}
//echo $FlyTime."<p>";
		return $FlyTime;
	}

	function CheckFinish() {
		// �������� ��������� �� ��������� (��� ���� ������������� �����) - ���������� ����� UpdateServer.php
		// ���� ����� �������� (����� b_time ������ ��������) - �������� (���� ������� 2 exp �� 1 ������� ������������� ������)
		// ����� �������
		$ServTime = new ServerTime();
		$STime = $ServTime->GetServerTime();
		// PID ��������. ����� �.�. ��������� ��������� ����� ������ ������� ������ ��� ���������� ����� �������� Update � ������������ ����� �������� ������ ������ ��������
		if(PHP_OS=="WINNT") $PID = 1;	// � Windows ������ ���� �������
		else $PID = posix_getpid();
		// ������������� ������� ������
		$this->Sql->SqlQuery = "update vn_user_ships set `lock`=".$PID." where a_planet!=b_planet and b_time<=".$STime." and `lock`=0;";
		$this->Sql->Exec();
		// �������� ������
		$this->Sql->SqlQuery = "select id,user_id,a_planet,b_planet,a_time,b_time from vn_user_ships where `lock`=".$PID.";";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			while($tmp = $SQLRez->fetch_array()) {
				// ������������� ������ � �������� ��� �������� ������������
				$SIO = new SocketIOVn();
				$SIO->SendOP($tmp["user_id"],SocketIOVn::FinishedRouteOP($tmp["id"]));
				// �������� ���� ������������
				$Usr = new UserVn();
//				$Usr->UpdateExp($tmp["user_id"],ceil(($tmp["b_time"]-$tmp["a_time"])/500));	// "/500" = 2 �� � ���.
				$UserLevel = $Usr->GetUserLevel($tmp["user_id"]);
				$UserShipsCount = $Usr->GetShipsCount($tmp["user_id"]);
				$UserFlightTime = ceil(($tmp["b_time"]-$tmp["a_time"])/1000);	// ����� �������� � �������� - �.�. ����� ���� ��������� � ��. �� �������
				$Usr->UpdateExp($tmp["user_id"],$this->ExpForFlight($UserFlightTime,$UserLevel,$UserShipsCount));
				// �������� ������
				$Qst = new Quests();
				$Cond = $Qst->FormFinishConditionFly($tmp["a_planet"],$tmp["b_planet"]);
				$Qst->CheckFinishConditions($tmp["user_id"],$Cond);
				// �������� �������
				$this->Sql->SqlQuery = "update vn_user_ships set a_planet=b_planet,a_time=0,b_time=0,`lock`=0 where id=".$tmp["id"].";";
				$this->Sql->Exec();
			}
			$this->Sql->FreeResult($SQLRez);
		}
	}
	
	function ExpForFlight($FlightTime, $Level, $ShipsCount) {
		// ���������� ���-�� ����� �� ����� �������� $FlightTime (���.)
		// ��������� ���: ��� ������� ������ ������������ ���� ���� ����������� ����� ������.
		// ���� ����� �������� ������� ����� ������������ - ������������ �������� 1 ��. ����� �� 1 ������� ��������
		// ���� ����� ������ ������������ - ������������ �������� ���-�� ����� �� ����������� �����
		// ���� ����� ������ ������������ - ������������ �������� ������ ����� ����� (�� ����������� ������������ � ���������)
		// ���������� ���-�� ����� ������� �� ���-�� �������� � ������������ (�.�. ��������� ��� ������ �������)
		// �������� ����������� ����� �� ������ ������
		$TimeOpt = 0;
		$this->Sql->SqlQuery = "select opt_time from vn_level where level='".$this->Sql->Escape($Level)."';";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			while($tmp = $SQLRez->fetch_array()) {
				$TimeOpt = $tmp["opt_time"];
			}
			$this->Sql->FreeResult($SQLRez);
		}
		// ����� ����������� ����� �� 100%, ������� ������� �� ���� ����� �������� ����� ��������
		// ���� ����� ������ ������������ - ����� ���������
		// ���� ����� ������ ������ ������������ - ����� ����������� �����
		if($FlightTime<$TimeOpt) $TimeProc = $FlightTime/$TimeOpt;
		else $TimeProc = $TimeOpt/$FlightTime;
		// ���� �����: 1 ����� �� ������� ��������
		$Exp = $FlightTime;
		// � ���������� �������� ������ ������������ �������
		$Exp = $Exp*$TimeProc;
		// ���� ������� �� ���������� �������� � ������� � ������������
		$Exp = $Exp/$ShipsCount;
		$Exp = ceil($Exp);
		if($Exp<=1) $Exp = 1;
		return $Exp;
	}
}
?>