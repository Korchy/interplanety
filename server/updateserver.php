<?php
//---------------------------------
// Update-������
//
// ������ 15 ����� ����������� �� ���������������� ������������ �� cron
//	*/15 * * * * /usr/bin/php -q /var/www/vn/updateserver.php 2>/tmp/cron.tmp
//
// ��������� - � ���������� stop
// /usr/bin/php -q /var/www/vn/updateserver.php stop
//---------------------------------
require_once("include/updateserver_vn.inc.php");
//---------------------------------
if(!isset($_SERVER['HTTP_HOST'])||$_SERVER['HTTP_HOST']!="interplanety_local") {
	// ��� ��������� ������� ������������� ����������
	chdir('/var/www/vn');
	}
// ������ ������� ����������
if(!isset($argv[1])) $argv[1]="start";
switch($argv[1]) {
	case "start":	// start - ������
		if(UpdateServerVn::IsRunning()==false) {
			$Server = new UpdateServerVn();
			$Server->Start();
			}
		break;
	case "stop":	// stop - ���������
		if(file_exists(UpdateServerVn::$PIDFileName)==true) {
			// ���� PID-���� ����������
			$FilePID = (int)file_get_contents(UpdateServerVn::$PIDFileName);
			posix_kill($FilePID,3);	// 3 = SIGQUIT
		}
		break;
}
?>