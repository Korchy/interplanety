<?php
//---------------------------------
// Update-сервер
//
// Каждые 15 минут проверяется на функционирование перезапуском из cron
//	*/15 * * * * /usr/bin/php -q /var/www/vn/updateserver.php 2>/tmp/cron.tmp
//
// Остановка - с параметром stop
// /usr/bin/php -q /var/www/vn/updateserver.php stop
//---------------------------------
require_once("include/updateserver_vn.inc.php");
//---------------------------------
if(!isset($_SERVER['HTTP_HOST'])||$_SERVER['HTTP_HOST']!="interplanety_local") {
	// Для реального сервера устанавливаем директорию
	chdir('/var/www/vn');
	}
// Запуск сервера обновлений
if(!isset($argv[1])) $argv[1]="start";
switch($argv[1]) {
	case "start":	// start - запуск
		if(UpdateServerVn::IsRunning()==false) {
			$Server = new UpdateServerVn();
			$Server->Start();
			}
		break;
	case "stop":	// stop - остановка
		if(file_exists(UpdateServerVn::$PIDFileName)==true) {
			// Если PID-файл существует
			$FilePID = (int)file_get_contents(UpdateServerVn::$PIDFileName);
			posix_kill($FilePID,3);	// 3 = SIGQUIT
		}
		break;
}
?>