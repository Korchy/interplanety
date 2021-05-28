<?php
//---------------------------------
// Socket-������
//
// ������ 15 ����� ����������� �� ���������������� ������������ �� cron
//	*/15 * * * * /usr/bin/php -q /var/www/vn/socketserver.php 2>/tmp/cron.tmp
//
// ��������� - � ���������� stop
// /usr/bin/php -q /var/www/vn/socketserver.php stop
//---------------------------------
require_once("include/socketserver_vn.inc.php");
//---------------------------------
if(!isset($_SERVER['HTTP_HOST'])||$_SERVER['HTTP_HOST']!="interplanety_local") {
	// ��� ��������� ������� ������������� ����������
	chdir('/var/www/vn');
	}
// ������ �������
if(!isset($argv[1])) $argv[1]="start";
switch($argv[1]) {
	case "start":	// start - ������
		if(SocketServerVn::IsRunning()==false) {
			$Server = new SocketServerVn();
			if($Server->Init()!=false) $Server->Start();
			unset($Server);
		}
		break;
	case "stop":	// stop - ���������
		if(file_exists(SocketServerVn::$PIDFileName)==true) {
			// ���� PID-���� ����������
			$FilePID = (int)file_get_contents(SocketServerVn::$PIDFileName);
			posix_kill($FilePID,3);	// 3 = SIGQUIT
		}
		break;
}
?>