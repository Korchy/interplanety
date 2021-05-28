<?php
//---------------------------------
// LiveJournal (livejournal.com) ������������� ������
//---------------------------------
require_once("htmlex.inc.php");
//---------------------------------
class LjAuto
{
	
	private $UserName;		// ����� ������������
	private $UserPassword;	// ������ ������������
	private $Socket;		// �����-���������� � �������� Lj
	
	public function __construct() {
		// ����������� ��������
		
		// �����������
		$this->UserName = "user";
		$this->UserPassword = "password";
		$this->OpenConnection();
	}

	public function __destruct() {
		// ����������
		$this->CloseConnection();
		// ���������� ��������
		
	}
	
	private function OpenConnection() {
		// ������� �����-���������� � �������� Lj
		$this->Socket = fsockopen("www.livejournal.com", 80, $e, $s, 5);
		if(!$this->Socket) echo "LjAuto - Failed to open socket";
	}
	
	private function CloseConnection() {
		// ������� �������� �����-����������
		if($this->Socket) fclose($this->Socket);
		$this->Socket = null;
	}
	
	public function AddPost($Title, $Text, $Tags) {
		// ���������� �����. ����� ������ ��������� � ��������� utf-8
		// ������� �����-����������
		$this->OpenConnection();
		// ����������� ������ �����
		$Hx = new HTMLEx();
		$Text = $Hx->TextToEncodedHtml($Text);	// ������ ������ ����� htmlentities �.�. �� �������� � ������� �����
		$Body = $this->RequestBody($Title, $Text, $Tags);
		$Header = $this->RequestHeader(strlen($Body));
		// ��������� ���� �� ������ ����� ������������� ����������
		$Rez = fwrite($this->Socket, $Header.$Body);
		$Rez = "Bites written: ".$Rez."\r\n";
		if($Rez===false) echo "LjAuto - Failed to write to socket";
		// �������� ����� �� �������
		while(!feof($this->Socket)) {
			$Rez = $Rez.fgets($this->Socket, 128); 
			flush();
		}
		// ������� �����-����������
		$this->CloseConnection();
		// ������������ ���������� ���������� �������
		return $Rez;
	}
	
	private function RequestBody($Title, $Text, $Tags) {
		// ���������� ����������������� ���� ��� �������� �����
		$Body = '<?xml version="1.0"?>
		<methodCall>
			<methodName>LJ.XMLRPC.postevent</methodName>
			<params>
				<param>
					<value>
						<struct>
							<member>
								<name>username</name>
								<value>
									<string>'.$this->UserName.'</string>
								</value>
							</member>
							<member>
								<name>password</name>
								<value>
									<string>'.$this->UserPassword.'</string>
								</value>
							</member>
							<member>
								<name>event</name>
								<value>
									<string>'.$Text.'</string>
								</value>
							</member>
							<member>
								<name>subject</name>
								<value>
									<string>'.$Title.'</string>
								</value>
							</member>
							<member>
								<name>lineendings</name>
								<value>
									<string>pc</string>
								</value>
							</member>
							<member>
								<name>year</name>
								<value>
									<int>'.date("Y").'</int>
								</value>
							</member>
							<member>
								<name>mon</name>
								<value>
									<int>'.date("m").'</int>
								</value>
							</member>
							<member>
								<name>day</name>
								<value>
									<int>'.date("d").'</int>
								</value>
							</member>
							<member>
								<name>hour</name>
								<value>
									<int>'.date("H").'</int>
								</value>
							</member>
							<member>
								<name>min</name>
								<value>
									<int>'.date("i").'</int>
								</value>
							</member>
							<member>
								<name>props</name>
								<value>
									<struct>
										<member>
											<name>taglist</name>
											<value>
												<string>'.$Tags.'</string>
											</value>
										</member>
									</struct>
								</value>
							</member>
						</struct>
					</value>
				</param>
			</params>
		</methodCall>';
		return $Body;
	}
	
	private function RequestHeader($BodyLength) {
		// ���������� ����������������� ��������� ��� ����������� �����
		$Header = "POST /interface/xmlrpc HTTP/1.0\r\n";
		$Header = $Header."User-Agent: XMLRPC Client 1.0\r\n";
		$Header = $Header."Host: www.livejournal.com\r\n";
		$Header = $Header."Content-Type: text/xml\r\n";
		$Header = $Header."Content-Length: ".$BodyLength."\r\n";
		$Header = $Header."\r\n";
		return html_entity_decode($Header);
	}
}
?>