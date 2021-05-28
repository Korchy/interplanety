<?php
//---------------------------------
// Policy-сервер
//
// Отдает файл политики при попытке соединиться через сокет-сервер
//
// Каждые 15 минут проверяется на функционирование перезапуском из cron
//	*/15 * * * * /usr/bin/php -q /var/www/vn/policyserver.php 2>/tmp/cron.tmp
//
// Остановка - с параметром stop
// /usr/bin/php -q /var/www/vn/policyserver.php stop
//---------------------------------
require_once("include/policyserver_vn.inc.php");
//---------------------------------
if(!isset($_SERVER['HTTP_HOST'])||$_SERVER['HTTP_HOST']!="interplanety_local") {
	// Для реального сервера устанавливаем директорию
	chdir('/var/www/vn');
	}
// Запуск сервера
if(!isset($argv[1])) $argv[1]="start";
switch($argv[1]) {
	case "start":	// start - запуск
		if(PolicyServerVn::IsRunning()==false) {
			$Server = new PolicyServerVn();
			if($Server->Init()!=false) $Server->Start();
			else unset($Server);
		}
		break;
	case "stop":	// stop - остановка
		if(file_exists(PolicyServerVn::$PIDFileName)==true) {
			// Если PID-файл существует
			$FilePID = (int)file_get_contents(PolicyServerVn::$PIDFileName);
			posix_kill($FilePID,3);	// 3 = SIGQUIT
		}
		break;
}
?>