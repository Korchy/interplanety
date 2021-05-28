<?php
//---------------------------------
// �����-������ (�����������)
//---------------------------------
require_once("daemon.inc.php");
//---------------------------------
class CommonSocketServerVn extends Daemon
{
	
	var $SocketPort;		// ���� ������
	var $MaxClients;		// ����������� ���������� ���-�� �������� (���� ������ - ����� � ����������� ����� �����)
	var $MasterSocket;		// ������-����� (������� � ������������ �����������)
	var $ClientSockets;		// ������ ���������� � ��������-���������
	public static $PIDFileName = "/var/www/vn/tmp/commonsocketserver.pid";	// ���� �������� ���������� �.�. �������� ������� ��� ������ ������������� = �����;
	
	public function __construct() {
		// ����������� ��������
		parent::__construct();
		// �����������
		$this->SetLog("/var/www/vn/tmp/commonsocketserver.log");
		$this->IterationDelay = 400;	// �������� �������� �� 40 �� - ����������� 25 ��� � �������
		$this->SocketPort = 33307;	// ��������� �������� ������� ����
		$this->MaxClients = 1000;	// ������ 247 ��� ����� �� ���������� (������ ����������� php)
	}

	public function __destruct() {
		// ����������
		// ������� ������ � ������� ��������-������, ����� �� ��������� ��� ������������� ������
		if($this->PID>0) {
			// ������� ������-�����
			$this->ShutDownSocket($this->MasterSocket);
			unset($this->MasterSocket);
			// �������� ������ �����������
			foreach($this->ClientSockets[0] as $SocketId) {
				$this->ShutDownSocket($SocketId);
			}
			unset($this->ClientSockets[0]);
			unset($this->ClientSockets[1]);
			unset($this->ClientSockets[2]);
			unset($this->ClientSockets[3]);
			unset($this->ClientSockets);
		}
		// ���������� ��������
		parent::__destruct();
	}
	public function Init() {
		// ������������� �����-�������
		if($this->IsRunning()==false) {
			// ������������� �������� ������ ��� ������� ������� (����� ������ � ����������� ��� ��� ���������� ������� �� ������� �������������)
			// ������� ������-�����
			$this->MasterSocket = socket_create(AF_INET,SOCK_STREAM,SOL_TCP);
			socket_set_option($this->MasterSocket,SOL_SOCKET,SO_REUSEADDR,1);	// ����� ��� ������� ����� ����� ���������� ������ ������ unable to bind address [98]: Address alredy in use
			if(socket_bind($this->MasterSocket,0,$this->SocketPort)==false) {
				// ���� ���������� � ����� ��������� �����-������, �������� ������: unable to bind address [98]: Address already in use
				// �.�. ���������� � ����������� ��������-��������� ������������ � ��������� -> ��� ������ �� ��������
				$SocketLastErr = socket_last_error($this->MasterSocket);
				$this->Log("ERR:	socket_bind (".$SocketLastErr.") ".socket_strerror($SocketLastErr));
				// ������� ������-�����
				$this->ShutDownSocket($this->MasterSocket);
				unset($this->MasterSocket);
				return false;
			}
			socket_listen($this->MasterSocket);
			socket_set_nonblock($this->MasterSocket);	// ������������� �������������, ����� socket_select �� �������� ��� ��������� ������������� � ������ ������
			// �������: ������ � 4 ������
			$this->ClientSockets = array();
			$this->ClientSockets[0] = array();	// ��������� �� �����
			$this->ClientSockets[1] = array();	// id ������������
			$this->ClientSockets[2] = array();	// ����� ������ �� ������
			$this->ClientSockets[3] = array();	// ����� ������ � �����
			return true;
		}
		return false;
	}
	
	public function Start() {
		// ������ ������
		if(PHP_OS=="WINNT") {
			// ��� Windows - �� ���������
			
		}
		else {
			// ��� Debian (�������) - ���������������� � ��������� ������
			// ����������� � ������ ������
			parent::Start();
		}
	}
	
	public function Iteration() {
		// ����������� ��������
		// ��������� ��������� ��������� �������
		$Read = $this->ClientSockets[0];					// ������ ���������� �������
		$Read[] = $this->MasterSocket;						// ������� � ������ ������-�����
		$ClientsCount = count($Read);						// ����� ���-�� �������������� ��������
		$ClientSocketChangedCount = socket_select($Read,$Write = NULL,$Except = NULL,0);
		if($ClientSocketChangedCount>0) {
			// ��������� ����������
			// ��������� ������-�����
			if(in_array($this->MasterSocket,$Read)) {
				// ��������� ������-����� - ����������� ������ �������
				if($ClientsCount<$this->MaxClients) {
					// ���������� ������ ������� � �������� ��� � ������ ��������
					$NewClient = socket_accept($this->MasterSocket);
					if($NewClient!=false) {
						socket_set_nonblock($NewClient);	// ������������� �������������, ����� socket_select �� �������� ��� ��������� ������������� � ������ ������
						$this->ClientSockets[0][$NewClient] = $NewClient;	// �����
						$this->ClientSockets[1][$NewClient] = "";			// id ������������
						$this->ClientSockets[2][$NewClient] = "";			// ����� ������
						$this->ClientSockets[3][$NewClient] = "";			// ����� ������
					}
					// ������� ������-����� �� ������ $Read �.�. � ���� ������ �� ��������/�������
					$MS = array_search($this->MasterSocket,$Read);
					unset($Read[$MS]);
				}
			}
			// ��������� ��������� ������ �� ��������
			foreach($Read as $Client) {
				// ������ ��������������� �� ������-�������
				$RData = socket_read($Client,1024);
				// ��������� '' ��� false - ������ ����������
				if($RData===''||$RData===false) {
					$this->ReadDataErr($Client);	// ������ ������
				}
				else {
					// ��������� ������ - ������� � ����� �����
					$RData = trim($RData);
//					print($RData."\n\r");
					if(strlen($RData)>0) {
						$this->ReadData($Client,$RData);
					}
				}
			}
		}
		// ��������� ���������� �� ������� ������
		$this->ProcessReceivedData();
		// ��������� ������������ �������� ������
		$this->ProcessSendingData();
	}
	
	public function ShutDownSocket($SSocket) {
		// ���������� �������� ������
		if(is_resource($SSocket)) {
			@socket_shutdown($SSocket,1);	// �������� ������ (������� ������ �.�. ���� ���������� ����� �� ��������� ��� ��������� - �������� warning: unable to shutdown socket [107]: Transport endpoint is not connected)
			$SocketLastErr = socket_last_error($SSocket);	// ������ ������ - � ��� (��� ����������� ���������������)
			if($SocketLastErr!=0&&$SocketLastErr!=107) $this->Log("ERR:	socket_shutdown(1) (".$SocketLastErr.") ".socket_strerror($SocketLastErr));
			usleep(500);					// ��������� ������
			@socket_shutdown($SSocket,0);	// �������� ������
			$SocketLastErr = socket_last_error($SSocket);	// ������ ������ - � ��� (��� ����������� ���������������)
			if($SocketLastErr!=0&&$SocketLastErr!=107) $this->Log("ERR:	socket_shutdown(0) (".$SocketLastErr.") ".socket_strerror($SocketLastErr));
			socket_close($SSocket);			// ������� �����
			unset($this->ClientSockets[0][$SSocket]);	// ����������� id ������
			unset($this->ClientSockets[1][$SSocket]);	// ����������� id ������������
			unset($this->ClientSockets[2][$SSocket]);	// ����������� ����� ������ ������
			unset($this->ClientSockets[3][$SSocket]);	// ����������� ����� ������ � �����
		}
	}
	
	public function ReadData($Socket,$Data) {
		// ������ ��������� �� ������ - ������� �� � ����� ������
		$this->ClientSockets[2][$Socket] = $this->ClientSockets[2][$Socket].$Data;
	}
	
	public function ReadDataErr($Socket) {
		// ������ ������ ������ �� ������ (������ ����������)
		// ������ - � ��� (��� ����������� ���������������)
		$SocketLastErr = socket_last_error($Socket);
		if($SocketLastErr!=0) $this->Log("ERR:	socket_read (".$SocketLastErr.") ".socket_strerror($SocketLastErr));
		// ������� ����� �������
		$this->ShutDownSocket($Socket);
	}
	
	public function ProcessReceivedData() {
		// ��������� ���������� ������
		
	}
	
	public function ProcessSendingData() {
		// ��������� ������������ ������
		
	}
	
	public function GetSocketByUserId($UserId) {
		// ���������� ����� �� Id ������������ (���� �� ������ ���������� null)
		foreach($this->ClientSockets[0] as $FSocket) {
			if($this->ClientSockets[1][$FSocket]==$UserId) {
				return $FSocket;
				break;
			}
		}
		return null;
	}
}
?>