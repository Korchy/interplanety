<?php
//---------------------------------
// Этот скрипт дергается Cron'ом 1 раз в минуту
//---------------------------------
require_once("include/industry.inc.php");
require_once("include/happy.inc.php");
require_once("include/routes.inc.php");
//---------------------------------
if(!isset($_SERVER['HTTP_HOST'])||$_SERVER['HTTP_HOST']!="localhost") {
	// Для реального сервера устанавливаем директорию
	chdir('/var/www/vn');
	}
// Обновление производства
$Ind = new Industry();
$Ind->Produce();	// Производство продукции
// Обновить показатель довольства на планете
$PHappy = new Happy();
$PHappy->Update();
// Проверить на окончание маршрутов
$Routes = new URoutes();
$Routes->CheckFinish();
?>
