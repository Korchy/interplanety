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
		// Конструктор родителя
		parent::__construct();
		// Конструктор
		$this->Comm = new Common();
		$this->StarSystem = new StarSystemVn();
	}

	function __destruct() {
		// Деструктор
		unset($this->Comm);
		unset($this->StarSystem);
		// Деструктор родителя
		parent::__destruct();
	}

	function CreateRoute($PlanetId,$ShipId) {
		// Создание маршрута для корабля $ShipId до планеты $PlanetId (spaceobject_id)
		if($PlanetId==0||$ShipId==0) return "F";
		// Текущее время
		$ServTime = new ServerTime();
		$STime = $ServTime->GetServerTime();
		// Проверить не является ли планета старта = планете назначения
		// и что корабль находится на планете а не в полете
		$PlanetA = 0;		// Если доступно - запомнить планету старта
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
		// Проверить доступность планеты по уровню
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
		// Все условия соблюдены - создать маршрут
		$PlanetB = $PlanetId;
		// Время прибытия
//echo $PlanetA."<p>";
//echo $PlanetB."<p>";
//echo $ShipId."<p>";
		$DestTime = $STime + $this->CountFlyTimeAB($PlanetA,$PlanetB,$ShipId)*1000;		// В милисекундах
//echo ($DestTime-$STime)."<br>";
//echo (($DestTime-$STime)/1000)." сек<br>";
//echo (($DestTime-$STime)/1000/60)." min<br>";
//echo (($DestTime-$STime)/1000/60/60)." hours<br>";
		if($DestTime==$STime) return "F";
		// Создать маршрут
		$this->Sql->SqlQuery = "update vn_user_ships set b_planet=".$this->Sql->Escape($PlanetId).", a_time=".$STime.", b_time=".$DestTime." where id=".$this->Sql->Escape($ShipId).";";
		$this->Sql->Exec();
		return "T";
	}

	function CountPlanetPos($ObjectId,$Time,$RealPos) {
		// Получить положение планеты/объекта $ObjectId (spaceobject_id) в момент времени $Time
		// $RealPos = true - вычисляем реальное положение, = false - визуальное
		// Вычисление положения носителя если несколько уровневый спутник
		// Варианты могут быть:
		//		отдельно объект с координатами
		//		объект - орбита - объект (может быть много уровней вложенности)
		$ParentOffset = new Vector2(0,0);
		$ParOffset = new Vector2(0,0);
		$this->Sql->SqlQuery = "select sm.s_point_x as own_x, sm.s_point_y as own_y, sor.k_real as own_k_real, sm2.spaceobject_id as parent_id, sm2.sub_id as parent_sub_id, sm2.s_point_x as parent_x, sm2.s_point_y as parent_y, sor2.k_real as parent_k_real from vn_starsystem sm left outer join vn_starsystem sm1 on sm.sub_id=sm1.id left outer join vn_starsystem sm2 on sm1.sub_id=sm2.id left outer join vn_spaceobject_r sor on sm.spaceobject_id=sor.spaceobject_id left outer join vn_spaceobject_r sor2 on sm2.spaceobject_id=sor2.spaceobject_id where sm.spaceobject_id='".$this->Sql->Escape($ObjectId)."';";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			while($tmp = $SQLRez->fetch_array()) {
				switch($tmp["parent_sub_id"]) {
					case null:
						// Отдельный объект с координатами
						$Rez = new Vector2();
						if($RealPos==false) $Rez = new Vector2($tmp["own_x"],$tmp["own_y"]);
						else $Rez = new Vector2($tmp["own_x"]*$tmp["own_k_real"],$tmp["own_y"]*$tmp["own_k_real"]);
						$this->Sql->FreeResult($SQLRez);
						return $Rez;
						break;
					case 0:
						// Дошли до основания (центральной звезды)
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
						// Получить суммарное смещение со всех предков
						$ParOffset = $this->CountPlanetPos($tmp["parent_id"],$Time,$RealPos);
				}
				$ParentOffset->X += $ParOffset->X;
				$ParentOffset->Y += $ParOffset->Y;
			}
			$this->Sql->FreeResult($SQLRez);
		}
		// Вычисление положения планеты $ObjectId (spaceobject_id) на ее орбите
		$this->Sql->SqlQuery = "select sor.k_real, o.radius_s, o.radius_l, o.angle, o.speed from vn_starsystem sm left outer join vn_starsystem sm1 on sm.sub_id=sm1.id inner join vn_orbit o on sm1.spaceobject_id=o.spaceobject_id inner join vn_spaceobject_r sor on sm1.spaceobject_id=sor.spaceobject_id where sm.spaceobject_id='".$this->Sql->Escape($ObjectId)."';";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			$tmp = $SQLRez->fetch_array();
			// Данные по орбите
			$RadiusL = $tmp["radius_l"];
			if($RealPos==true) $RadiusL = $RadiusL*$tmp["k_real"];
			$RadiusS = $tmp["radius_s"];
			if($RealPos==true) $RadiusS = $RadiusS*$tmp["k_real"];
			$RadiusSL = ($RadiusL+$RadiusS)/2.0;					// Усредненный радиус
			$Ang = -$tmp["angle"]*M_PI/180;							// Угол наклона эллипса
			$LinSpeed = round($tmp["speed"]*$Time/$RadiusSL,2);	// Линейная скорость движения
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
		// Возвращает смещение объекта (spaceobject_id) относительно центра (вычисляется по сумме средних радиусов)
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
		// Получить время полета (в сек.) между планетами $PlanetA и $PlanetB (spaceobject_id) для корабля пользователя $ShipId
		// Считается так: берем текущее расстояние между планетами. Считаем процентное соотношение его в промежутке от минимального до
		// максимального расстояния между этими планетами (мин и макс расстояния считаются по среднему радиусу, когда планеты рядом и
		// когда они на противополжных сторонах). Берем перелет на мин. расстояние, считаем от него полученный процент. К полному мин.
		// расстоянию добавляем полученное. Итого перелет лежит в пределах: мин. расстояние - 2 мин. расстояния, регулируется в зависимости
		// от текущего расстояния между планетами
		$ServTime = new ServerTime();
		$STime = $ServTime->GetServerTime();
		$Pa = $this->CountPlanetPos($PlanetA,$STime,true);
//echo $PlanetA.": X=".$Pa->X." Y=".$Pa->Y."<p>";
		$Pb = $this->CountPlanetPos($PlanetB,$STime,true);
//echo $PlanetB."B: X=".$Pb->X." Y=".$Pb->Y;
		// Расстоянием между планетами
		$V = Vector2::Vec2Subtract($Pa,$Pb);
		$L = $V->Length();
		// Макс. и Мин. расстояния между планетами
		$PaOffset = $this->CountMROffset($PlanetA);
//echo $PlanetA." A MROffset= ".$PaOffset."<p>";
		$PbOffset = $this->CountMROffset($PlanetB);
//echo $PlanetB." B MROffset= ".$PbOffset."<p>";
		$LMax = $PaOffset+$PbOffset;
		$LMin = abs($PaOffset-$PbOffset);
		// Процентное значение для текущего расстояния отночительно максимального (д.б. всегда >= 1)
		$Proc = $L/$LMax;
		// Берем мин. расстояние и увеличиваем в соответствии с процентом от максимального
		$L = $LMin+$LMin*$Proc;
//echo $L."<p>";
		// Учесть скорость корабля
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
		// Проверка перелетов на звершение (для всех пользователей разом) - вызывается через UpdateServer.php
		// Если полет закончен (время b_time меньше текущего) - обновить (опыт считаем 2 exp за 1 секунду состоявшегося полета)
		// Время сервера
		$ServTime = new ServerTime();
		$STime = $ServTime->GetServerTime();
		// PID процесса. Нужет т.к. обработка маршрутов может занять времени больше чем промежуток между вызовами Update и одновременно будет работать больше одного процесса
		if(PHP_OS=="WINNT") $PID = 1;	// В Windows всегда один процесс
		else $PID = posix_getpid();
		// Заблокировать текущие данные
		$this->Sql->SqlQuery = "update vn_user_ships set `lock`=".$PID." where a_planet!=b_planet and b_time<=".$STime." and `lock`=0;";
		$this->Sql->Exec();
		// Обновить данные
		$this->Sql->SqlQuery = "select id,user_id,a_planet,b_planet,a_time,b_time from vn_user_ships where `lock`=".$PID.";";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			while($tmp = $SQLRez->fetch_array()) {
				// Сгенерировать данные о прибытии для отправки пользователю
				$SIO = new SocketIOVn();
				$SIO->SendOP($tmp["user_id"],SocketIOVn::FinishedRouteOP($tmp["id"]));
				// Обновить опыт пользователя
				$Usr = new UserVn();
//				$Usr->UpdateExp($tmp["user_id"],ceil(($tmp["b_time"]-$tmp["a_time"])/500));	// "/500" = 2 ед в сек.
				$UserLevel = $Usr->GetUserLevel($tmp["user_id"]);
				$UserShipsCount = $Usr->GetShipsCount($tmp["user_id"]);
				$UserFlightTime = ceil(($tmp["b_time"]-$tmp["a_time"])/1000);	// Время перелета в секундах - т.к. далее опыт считается в ед. за секунду
				$Usr->UpdateExp($tmp["user_id"],$this->ExpForFlight($UserFlightTime,$UserLevel,$UserShipsCount));
				// Обновить квесты
				$Qst = new Quests();
				$Cond = $Qst->FormFinishConditionFly($tmp["a_planet"],$tmp["b_planet"]);
				$Qst->CheckFinishConditions($tmp["user_id"],$Cond);
				// Очистить маршрут
				$this->Sql->SqlQuery = "update vn_user_ships set a_planet=b_planet,a_time=0,b_time=0,`lock`=0 where id=".$tmp["id"].";";
				$this->Sql->Exec();
			}
			$this->Sql->FreeResult($SQLRez);
		}
	}
	
	function ExpForFlight($FlightTime, $Level, $ShipsCount) {
		// Возвращает кол-во опыта за время перелета $FlightTime (сек.)
		// Считается так: для каждого уровня пользователя есть свое оптимальное время полета.
		// Если время перелета корабля равно оптимальному - пользователь получает 1 ед. опыта за 1 секунду перелета
		// Если время больше оптимального - пользователь получает кол-во опыта за оптимальное время
		// Если время меньше оптимального - пользователь получает только часть опыта (из соотношения оптимального к реальному)
		// Полученное кол-во опыта делится на кол-во кораблей у пользователя (т.к. считается для одного корабля)
		// Получить оптимальное время на данном уровне
		$TimeOpt = 0;
		$this->Sql->SqlQuery = "select opt_time from vn_level where level='".$this->Sql->Escape($Level)."';";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			while($tmp = $SQLRez->fetch_array()) {
				$TimeOpt = $tmp["opt_time"];
			}
			$this->Sql->FreeResult($SQLRez);
		}
		// Берем оптимальное время за 100%, считаем сколько от него будет реальное время перелета
		// Если время меньше оптимального - берем отношение
		// Если время полета больше оптимального - берем оптимальное время
		if($FlightTime<$TimeOpt) $TimeProc = $FlightTime/$TimeOpt;
		else $TimeProc = $TimeOpt/$FlightTime;
		// Опыт берем: 1 опыта за секунду перелета
		$Exp = $FlightTime;
		// В реальности получаем только подсчитанный процент
		$Exp = $Exp*$TimeProc;
		// Опыт делится на количество кораблей в наличии у пользователя
		$Exp = $Exp/$ShipsCount;
		$Exp = ceil($Exp);
		if($Exp<=1) $Exp = 1;
		return $Exp;
	}
}
?>