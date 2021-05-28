<?php
//---------------------------------
// Socket-сервер
//
// Каждые 15 минут проверяется на функционирование перезапуском из cron
//	*/15 * * * * /usr/bin/php -q /var/www/vn/socketserver.php 2>/tmp/cron.tmp
//
// Остановка - с параметром stop
// /usr/bin/php -q /var/www/vn/socketserver.php stop
//---------------------------------
require_once("include/socketserver_vn.inc.php");
//---------------------------------
if(!isset($_SERVER['HTTP_HOST'])||$_SERVER['HTTP_HOST']!="interplanety_local") {
	// Для реального сервера устанавливаем директорию
	chdir('/var/www/vn');
	}
// Запуск сервера
if(!isset($argv[1])) $argv[1]="start";
switch($argv[1]) {
	case "start":	// start - запуск
		if(SocketServerVn::IsRunning()==false) {
			$Server = new SocketServerVn();
			if($Server->Init()!=false) $Server->Start();
			unset($Server);
		}
		break;
	case "stop":	// stop - остановка
		if(file_exists(SocketServerVn::$PIDFileName)==true) {
			// Если PID-файл существует
			$FilePID = (int)file_get_contents(SocketServerVn::$PIDFileName);
			posix_kill($FilePID,3);	// 3 = SIGQUIT
		}
		break;
}
?>