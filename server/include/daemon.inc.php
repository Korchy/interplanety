<?php
//---------------------------------
// ����� - ����� ��� ���������� �������� � ������� ������
//---------------------------------
require_once("log.inc.php");
require_once("servertime.inc.php");
//---------------------------------
class Daemon
{
	var $PID;			// ������������� ��������
	public static $PIDFileName = "tmp/daemon.pid";	// ���� � ��������������� ��������
	var $LogFile;
	var $Running;	// ���� - ��������� ��������
	var $IterationDelay;	// �������� ����� ������������ �������� � ��
	
	public function __construct() {
		// �����������
		set_time_limit(0);	// ����� ���������� - ����������
		$PID = -2;	// ����������� �������������
		$this->Running = false;
		$this->IterationDelay = 1000;
	}

	public function __destruct() {
		// ����������
	}

	public function Start() {
		// ������������� ������
		$this->Log("START DAEMON");
		// ��������� �� ������� �� ��� �������
		if($this->IsRunning()==true) {
			$this->Log("DOUBLE START");
			return false;
		}
		// �������������� �������
		if($this->Daemonize()==false) return false;
		// ��������� ������� ����
		$this->MLConstruct();	// ���������� �������� �� ������ ��������� ����� (������������� �����-���� �������� � ������� ��������)
		$STime = new ServerTime();
		$LastTime = $STime->GetServerTime();
		while($this->Running==true) {
			// ������� ����
			$this->Iteration();
			// ��������
			$CurrentTime = $STime->GetServerTime();
			$Delay = $this->IterationDelay - ($CurrentTime - $LastTime);
			$LastTime = $CurrentTime;
			if($Delay<=0) $Delay = 1;
			usleep($Delay*1000);	// �������� �� $IterationDelay ����� ����� ����������� �� ���������� �������� ����� (*1000 �.�. usleep ������ � ������������� (1/1000 �����������))
		}
		$this->MLDestruct();	// ���������� �������� �� ���������� ��������� ����� (��������������� �����-���� �������� � ������� ��������)
		return true;
	}
	
	public function Stop() {
		// ���������� ������
		if(file_exists(static::$PIDFileName)) unlink(static::$PIDFileName);	// ������� PID-����
		$this->Running = false;		// ���������� ������� ����
		$this->Log("STOP DAEMON");
	}
	
	public function Iteration() {
		// �������� ������ �����
		
	}
	
	public function Daemonize() {
		// ����������� ��������
		$Rez = false;
		// �������� ������ �����-�������
		$CurrentPID = pcntl_fork();
		switch($CurrentPID) {
			case -1:
				// ������
				$this->Log("FORK ERR");
				break;
			case 0:	
				// ������ �����-�������
				// ��� ������� �����-�������� - ����������� �����������
				umask(0);
				chdir("/");
				// �������� ������ �����-�������
				if(posix_setsid()>=0) {	// ���������� �� ���������
					$CurrentPID = pcntl_fork();
					switch($CurrentPID) {
						case -1:
							// ������
							$this->Log("FORK2 ERR");
							break;
						case 0:
							// ������ �����-�������
							$this->PID = posix_getpid();
							// ��������� PID � ����
							if(file_put_contents(static::$PIDFileName,$this->PID)>0) {
								// ������������ ��������� ��������
								declare(ticks = 1);
								pcntl_signal(SIGTERM,array(&$this,"ProcessSigterm"));	// ���������� ��������
								pcntl_signal(SIGQUIT,array(&$this,"ProcessSigquit"));	// ���������� ��������
								pcntl_signal(SIGCHLD,array(&$this,"ProcessSigchld"));	// �������-���� ����������
								// ����������� ������ �������
								$this->Running = true;
								$Rez = true;
							}
							break;
						default:
							// >0 ������ �����-������� - ���������
					}
				}
				break;
			default:
				// >0 ������������ ������� - ���������
		}
		return $Rez;
	}
	
	public static function IsRunning() {
		// �������� �� ��, ��� ������� ��� �����������
		$Rez = false;
		if(file_exists(static::$PIDFileName)==true) {
			// ���� PID-���� ����������
			$FilePID = (int)file_get_contents(static::$PIDFileName);
			if($FilePID>0&&posix_kill($FilePID,0)==true) {
				// ������� ��������
				$Rez = true;
			}
			else {
				// ������� �� ��� �������
				unlink(static::$PIDFileName);	// ������� PID-����, ���������� �� ����������� �������
				$Rez = false;
			}
		}
		return $Rez;
	}
	
	public function SetLog($String) {
		// ����������� ����
		$this->LogFile = new Log($String);
	}
	
	public function Log($String) {
		// ���������� ������ � ���
		if($this->LogFile!=null) $this->LogFile->Add($String);
	}
	
	public function ProcessSigterm() {
		// ��������� ������� SIGTERM
		$this->Stop();
	}
	public function ProcessSigquit() {
		// ��������� ������� SIGQUIT
		$this->Stop();
	}
	public function ProcessSigchld() {
		// ��������� ������� SIGCHLD
		// ���������� �����-�������
		while(pcntl_waitpid(-1,$status,WNOHANG)>0);
	}
	
	public function MLConstruct() {
		// Main Loop Constructor ���� �����-�� ������� ����� ���������������� ������ � ������� ��������
	}
	
	public function MLDestruct() {
		// Main Loop Destructor - �������� ��������, ��������� � MLConstruct
	}

}
?>