<?php
//---------------------------------
// �����-������
//---------------------------------
require_once("commonsocketserver_vn.inc.php");
require_once("mysqliex.inc.php");
require_once("common.inc.php");
//---------------------------------
class SocketServerVn extends CommonSocketServerVn
{
	
	var $Sql;				// ������ ��� ������ � ��
	public static $PIDFileName = "/var/www/vn/tmp/socketserver.pid";	// ���� �������� ���������� �.�. �������� ������� ��� ������ ������������� = �����;
	
	public function __construct() {
		// ����������� ��������
		parent::__construct();
		// �����������
		$this->SetLog("/var/www/vn/tmp/socketserver.log");
		$this->SocketPort = 33307;	// ���� ������ �������
	}

	public function __destruct() {
		// ����������
		
		// ���������� ��������
		parent::__destruct();
	}

	public function ReadData($Socket,$Data) {
		// ������ ��������� �� ������
		if($this->ClientSockets[1][$Socket]=="") {
			// ������ ��������� �� ��������������������� ������� - ������� �� � ����� ������ (������ ������������� ������������)
			$this->ClientSockets[2][$Socket] = $this->ClientSockets[2][$Socket].$Data;
		}
		else {
			// ������ ��������� �� ������������������� ������� - ������� �� � ���� ��� ����������� ���������
			$this->Sql->SqlQuery = "update vn_user_connections set read_buff=concat(read_buff,\"".$this->Sql->Escape($Data)."\") where user_id=\"".$this->Sql->Escape($this->ClientSockets[1][$Socket])."\";";
			$this->Sql->Exec();
		}
	}
	
	public function ReadDataErr($Socket) {
		// ������ ������ ������ �� ������ (������ ����������)
		$SocketLastErr = socket_last_error($Socket);
		if($SocketLastErr!=0) $this->Log("ERR:	socket_read (".$SocketLastErr.") ".socket_strerror($SocketLastErr));
		// ������� ����� �������
		if($this->ClientSockets[1][$Socket]!="") {
			// ���� ���������� ������������������ ������
			$this->Sql->SqlQuery = "update vn_user_connections set user_online=\"F\" where user_id=\"".$this->Sql->Escape($this->ClientSockets[1][$Socket])."\";";
			$this->Sql->Exec();
		}
		$this->ShutDownSocket($Socket);
	}

	public function ProcessReceivedData() {
		// ��������� ���������� ������ (� ������ ����� ���� ������ ������������� ������������, ��� ��������� ���� � vn_user_connections)
		// ������ ������ ���� � �������: <001 id="999">
		foreach($this->ClientSockets[0] as $UCl) {
			$ClData = $this->ClientSockets[2][$UCl];
			if($ClData!="") {
				if(strlen($ClData)>=4&&substr($ClData,0,4)!="<001") {
					// ������ ���-�� ����� - �������� ����������
					$this->ShutDownSocket($UCl);
					continue;
				}
				if(substr($ClData,strlen($ClData)-1,1)==">") {	// ">" - ����������� ������, ������ ��� ������ ������ ��������
					// ����� ��������� �������
					$Id = substr($ClData,1,3);
					$Comm = new Common();
					$Params = $Comm->StringToKeyedArray(substr($ClData,5,-1)," ","=");
					// ������ - ������������� ������������
					$UserId = $Params["id"];
					// ���������, �� ���� �� ��� �������� �� ����� �� id (��� ����, ���������� ����� �����, ��� ������� ���������� ����� �� �������� � ������ ��� ������/������)
					// ���� ������� ��� ��� - ������� ���
					$OldSocket = $this->GetSocketByUserId($UserId);
					if($OldSocket!=null) $this->ShutDownSocket($OldSocket);
					// ��������� ������ �������� ������ ������������
					$this->ClientSockets[1][$UCl] = $UserId;
					$this->ClientSockets[2][$UCl] = "";
					$this->Sql->SqlQuery = "update vn_user_connections set user_online=\"T\" where user_id='".$this->Sql->Escape($UserId)."';";
					$this->Sql->Exec();
				}
			}
		}
	}
	
	public function ProcessSendingData() {
		// ��������� ������������ ������
		// ��������� ������ � ������� ������������������ �������������
		$this->Sql->SqlQuery = "select user_id,write_buff from vn_user_connections where user_online=\"T\" and write_buff like \"%>%\";";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			while($tmp = $SQLRez->fetch_array()) {
				// ����� ��������� �� ����� �� id ������������
				$Ind = array_search($tmp["user_id"],$this->ClientSockets[1]);
				$SocketId = $this->ClientSockets[0][$Ind];
				// ������ ��� ������
				$DataToWrite = substr($tmp["write_buff"],0,strrpos($tmp["write_buff"],">")+1)."\n\0";
				$DataLength = strlen($DataToWrite);
				$BytesWritten = @socket_write($SocketId,$DataToWrite,$DataLength);
				// ������� ������ �.�. ���� ���������� ����� �� ��������� ��� ��������� - �������� warning: unable to write to socket [32]: Broken pipe
				// ������ ������ - � ��� (��� ����������� ���������������)
				$SocketLastErr = socket_last_error($SocketId);
				if($SocketLastErr!=0&&$SocketLastErr!=32) $this->Log("ERR:	socket_write (".$SocketLastErr.") ".socket_strerror($SocketLastErr));
				if($BytesWritten===false) {
					// ���������� ����� ���������� (� ������ ������������ �� ������ ������� ������ � ����� � ������������ ��������)
					$this->Sql->SqlQuery = "update vn_user_connections set user_online=\"F\" where user_id=".$this->Sql->Escape($tmp["user_id"]).";";
					$this->Sql->Exec();
					$this->ShutDownSocket($SocketId);
				}
				else {
					// ������ ������� ��������
					$RemainingData = substr($tmp["write_buff"],$BytesWritten);
					$this->Sql->SqlQuery = "update vn_user_connections set write_buff=substring(write_buff,".($BytesWritten-1).") where user_id=".$this->Sql->Escape($tmp["user_id"]).";";
					$this->Sql->Exec();
				}
			}
			$this->Sql->FreeResult($SQLRez);
		}
	}

	public function MLConstruct() {
		// ������������ � �� - � ������� �������� �.�. ��� ���������� �������� ���������� � ����� ����������� � ����� ������ � � �����-��������� �� ��������
		$this->Sql = new MySqliEx();
		$this->Sql->Connect();
		$this->Sql->Fastcharset();
		$this->Sql->SetUnsignedSubstraction();
	}
	
	public function MLDestruct() {
		// ���������� �� ��
		// �������� ������� ������������������ �����������
		$this->Sql->SqlQuery = "update vn_user_connections set user_online='F' where user_online='T';";
		$this->Sql->Exec();
		// ������������� �� ��
		$this->Sql->Disconnect();
		unset($this->Sql);
	}
}
?>