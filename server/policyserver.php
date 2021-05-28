<?php
//---------------------------------
// Policy-������
//
// ������ ���� �������� ��� ������� ����������� ����� �����-������
//
// ������ 15 ����� ����������� �� ���������������� ������������ �� cron
//	*/15 * * * * /usr/bin/php -q /var/www/vn/policyserver.php 2>/tmp/cron.tmp
//
// ��������� - � ���������� stop
// /usr/bin/php -q /var/www/vn/policyserver.php stop
//---------------------------------
require_once("include/policyserver_vn.inc.php");
//---------------------------------
if(!isset($_SERVER['HTTP_HOST'])||$_SERVER['HTTP_HOST']!="interplanety_local") {
	// ��� ��������� ������� ������������� ����������
	chdir('/var/www/vn');
	}
// ������ �������
if(!isset($argv[1])) $argv[1]="start";
switch($argv[1]) {
	case "start":	// start - ������
		if(PolicyServerVn::IsRunning()==false) {
			$Server = new PolicyServerVn();
			if($Server->Init()!=false) $Server->Start();
			else unset($Server);
		}
		break;
	case "stop":	// stop - ���������
		if(file_exists(PolicyServerVn::$PIDFileName)==true) {
			// ���� PID-���� ����������
			$FilePID = (int)file_get_contents(PolicyServerVn::$PIDFileName);
			posix_kill($FilePID,3);	// 3 = SIGQUIT
		}
		break;
}
?>