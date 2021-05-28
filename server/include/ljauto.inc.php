<?php
//---------------------------------
// LiveJournal (livejournal.com) автоматизация работы
//---------------------------------
require_once("htmlex.inc.php");
//---------------------------------
class LjAuto
{
	
	private $UserName;		// Логин пользователя
	private $UserPassword;	// Пароль пользователя
	private $Socket;		// Сокет-соединение с сервером Lj
	
	public function __construct() {
		// Конструктор родителя
		
		// Конструктор
		$this->UserName = "user";
		$this->UserPassword = "password";
		$this->OpenConnection();
	}

	public function __destruct() {
		// Деструктор
		$this->CloseConnection();
		// Деструктор родителя
		
	}
	
	private function OpenConnection() {
		// Открыть сокет-соединение с сервером Lj
		$this->Socket = fsockopen("www.livejournal.com", 80, $e, $s, 5);
		if(!$this->Socket) echo "LjAuto - Failed to open socket";
	}
	
	private function CloseConnection() {
		// Закрыть открытое сокет-соединение
		if($this->Socket) fclose($this->Socket);
		$this->Socket = null;
	}
	
	public function AddPost($Title, $Text, $Tags) {
		// Добавление поста. Текст должен приходить в кодировке utf-8
		// Открыть сокет-соединение
		$this->OpenConnection();
		// Подготовить формат поста
		$Hx = new HTMLEx();
		$Text = $Hx->TextToEncodedHtml($Text);	// Нельзя делать через htmlentities т.к. он кодирует и русские буквы
		$Body = $this->RequestBody($Title, $Text, $Tags);
		$Header = $this->RequestHeader(strlen($Body));
		// Отправить пост на сервер через установленное соединение
		$Rez = fwrite($this->Socket, $Header.$Body);
		$Rez = "Bites written: ".$Rez."\r\n";
		if($Rez===false) echo "LjAuto - Failed to write to socket";
		// Получить ответ от сервера
		while(!feof($this->Socket)) {
			$Rez = $Rez.fgets($this->Socket, 128); 
			flush();
		}
		// Закрыть сокет-соединение
		$this->CloseConnection();
		// Возвращаются результаты выполнения запроса
		return $Rez;
	}
	
	private function RequestBody($Title, $Text, $Tags) {
		// Возвращает отформатированное тело для отправки поста
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
		// Возвращает отформатированный заголовок для отправления поста
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