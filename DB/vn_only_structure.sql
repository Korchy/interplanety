-- phpMyAdmin SQL Dump
-- version 4.9.0.1
-- https://www.phpmyadmin.net/
--
-- Время создания: Апр 04 2021 г., 09:02

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES cp1251 */;

--
-- База данных
--

-- --------------------------------------------------------

--
-- Структура таблицы `vn_graphic`
--

CREATE TABLE `vn_graphic` (
  `id` int(10) UNSIGNED NOT NULL COMMENT 'Id',
  `object_type` varchar(50) DEFAULT NULL COMMENT 'Тип объекта к которому относится изображение',
  `object_id` int(10) UNSIGNED DEFAULT NULL COMMENT 'Id объекта в его таблице',
  `center_x` int(10) NOT NULL COMMENT 'X координата локального центра',
  `center_y` int(10) NOT NULL COMMENT 'Y координата локального центра',
  `img_path` varchar(50) NOT NULL COMMENT 'Путь к рисунку',
  `img_name` varchar(50) NOT NULL COMMENT 'Название рисунка',
  `img_ext` char(3) NOT NULL DEFAULT 'png' COMMENT 'Расширение рисунка',
  `frames` smallint(5) UNSIGNED NOT NULL DEFAULT '1' COMMENT 'Количество кадров в анимации',
  `preload` enum('F','T') NOT NULL DEFAULT 'F' COMMENT 'T - загружается сразу, F - загружается по первому использованию в программе',
  `desc` varchar(50) NOT NULL COMMENT 'Описание',
  `inpdate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Дата занесения'
) ENGINE=InnoDB DEFAULT CHARSET=cp1251 COMMENT='Данные по графике объектов (спрайтам)';

-- --------------------------------------------------------

--
-- Структура таблицы `vn_industry`
--

CREATE TABLE `vn_industry` (
  `id` int(10) UNSIGNED NOT NULL COMMENT 'Id',
  `name` int(10) UNSIGNED NOT NULL DEFAULT '0' COMMENT 'Название',
  `type` int(10) UNSIGNED DEFAULT NULL COMMENT 'Тип (vn.ship_modules.id)',
  `level` int(10) UNSIGNED NOT NULL DEFAULT '0' COMMENT 'Уровень игрока с которого открывается производство',
  `base_price` smallint(5) UNSIGNED NOT NULL DEFAULT '1' COMMENT 'Базовая цена',
  `img` int(10) UNSIGNED DEFAULT NULL COMMENT 'Id графического объекта',
  `desc` varchar(50) NOT NULL COMMENT 'Описание',
  `inpdate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Дата занесения'
) ENGINE=InnoDB DEFAULT CHARSET=cp1251 COMMENT='Типы объектов';

-- --------------------------------------------------------

--
-- Структура таблицы `vn_level`
--

CREATE TABLE `vn_level` (
  `id` int(10) UNSIGNED NOT NULL COMMENT 'Id',
  `level` int(10) UNSIGNED NOT NULL DEFAULT '0' COMMENT 'Уровень',
  `exp` int(10) UNSIGNED NOT NULL DEFAULT '0' COMMENT 'Опыт',
  `expl` int(10) UNSIGNED NOT NULL DEFAULT '0' COMMENT 'Опыта до следующего уровня',
  `opt_time` int(10) UNSIGNED NOT NULL COMMENT 'Оптимальное время перелета на текущем уровне (сек.)',
  `desc` varchar(100) NOT NULL DEFAULT '' COMMENT 'Описание',
  `inpdate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Дата занесения'
) ENGINE=InnoDB DEFAULT CHARSET=cp1251 COMMENT='Уровни';

-- --------------------------------------------------------

--
-- Структура таблицы `vn_news`
--

CREATE TABLE `vn_news` (
  `id` int(10) UNSIGNED NOT NULL COMMENT 'Id',
  `title` varchar(100) DEFAULT NULL COMMENT 'Заголовок',
  `info_s` text COMMENT 'Краткая информация',
  `info` text COMMENT 'Информация',
  `info_link` varchar(250) DEFAULT NULL COMMENT 'Ссылка на полный текст на форуме',
  `inpdate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Дата занесения'
) ENGINE=InnoDB DEFAULT CHARSET=cp1251 COMMENT='Новости и обновления';

-- --------------------------------------------------------

--
-- Структура таблицы `vn_orbit`
--

CREATE TABLE `vn_orbit` (
  `id` int(10) UNSIGNED NOT NULL COMMENT 'Id',
  `spaceobject_id` int(10) UNSIGNED NOT NULL COMMENT 'id в vn_spaceobject',
  `radius_s` int(10) UNSIGNED NOT NULL COMMENT 'Малый радиус',
  `radius_l` int(10) UNSIGNED NOT NULL COMMENT 'Большой радиус',
  `angle` int(10) NOT NULL COMMENT 'Угол наклона',
  `speed` float NOT NULL COMMENT 'Скорость движения по орбите'
) ENGINE=InnoDB DEFAULT CHARSET=cp1251 COMMENT='Реестр орбит';

-- --------------------------------------------------------

--
-- Структура таблицы `vn_planet`
--

CREATE TABLE `vn_planet` (
  `id` int(10) UNSIGNED NOT NULL COMMENT 'Id',
  `spaceobject_id` int(10) UNSIGNED NOT NULL COMMENT 'id в vn_spaceobject',
  `name` int(10) UNSIGNED NOT NULL COMMENT 'Название - ссылка на vn_text',
  `img` int(10) UNSIGNED NOT NULL COMMENT 'Изображение (Id в vn_graphic)'
) ENGINE=InnoDB DEFAULT CHARSET=cp1251 COMMENT='Реестр планет';

-- --------------------------------------------------------

--
-- Структура таблицы `vn_planet_r`
--

CREATE TABLE `vn_planet_r` (
  `id` int(10) UNSIGNED NOT NULL COMMENT 'Id',
  `spaceobject_id` int(10) UNSIGNED NOT NULL COMMENT 'id в vn_spaceobject',
  `img_20x20` int(10) UNSIGNED DEFAULT NULL COMMENT 'Изображение 20х20 (vn_graphic.id)',
  `img_24x24` int(11) DEFAULT NULL COMMENT 'Картинка 24x24 (vn_graphic.id)',
  `img_30x30` int(10) UNSIGNED DEFAULT NULL COMMENT 'Изображение 30x30 (в graphic)',
  `fly_enable` enum('F','T') NOT NULL DEFAULT 'T' COMMENT 'T - К нему можно летать, F - Нет',
  `level` int(10) UNSIGNED NOT NULL DEFAULT '0' COMMENT 'Уровень, с когорого доступна планета',
  `happy` float UNSIGNED NOT NULL DEFAULT '0' COMMENT 'Показатель довольства (от 0 до 1)'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Реестр реальных планет';

-- --------------------------------------------------------

--
-- Структура таблицы `vn_quests`
--

CREATE TABLE `vn_quests` (
  `id` int(10) UNSIGNED NOT NULL COMMENT 'Id',
  `name` int(10) UNSIGNED NOT NULL DEFAULT '1' COMMENT 'Название квеста (id в vn_text)',
  `level` int(10) UNSIGNED NOT NULL DEFAULT '0' COMMENT 'Уровень с которого доступен квест',
  `img` int(10) UNSIGNED DEFAULT NULL COMMENT 'Изображение 40x40',
  `planet` int(10) UNSIGNED NOT NULL DEFAULT '0' COMMENT 'Объект на котором брать квест (Id в vn_sector_main)',
  `enable` enum('F','T') NOT NULL DEFAULT 'F' COMMENT 'T - доступен, F - нет',
  `intro` int(10) UNSIGNED DEFAULT NULL COMMENT 'Вводное описание квеста (id в vn_text)',
  `desc` varchar(100) NOT NULL COMMENT 'Описание',
  `inpdate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Дата занесения'
) ENGINE=InnoDB DEFAULT CHARSET=cp1251 COMMENT='Настройки пользователей';

-- --------------------------------------------------------

--
-- Структура таблицы `vn_quests_conditions`
--

CREATE TABLE `vn_quests_conditions` (
  `id` int(10) UNSIGNED NOT NULL COMMENT 'Id',
  `quest_id` int(10) UNSIGNED NOT NULL COMMENT 'Id квеста (Id в vn_quests)',
  `stage` int(10) UNSIGNED NOT NULL DEFAULT '1' COMMENT 'Этап квеста',
  `easy` text COMMENT 'Простая сложность',
  `easy_prize` text COMMENT 'Награда за простую сложность',
  `normal` text COMMENT 'Нормальная сложность',
  `normal_prize` text COMMENT 'Награда за нормальную сложность',
  `hard` text COMMENT 'Высокая сложность',
  `hard_prize` text COMMENT 'Награда за высокую сложность',
  `desc` varchar(100) NOT NULL COMMENT 'Описание',
  `inpdate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Дата занесения'
) ENGINE=InnoDB DEFAULT CHARSET=cp1251 COMMENT='Условия выполнения квестов';

-- --------------------------------------------------------

--
-- Структура таблицы `vn_ship`
--

CREATE TABLE `vn_ship` (
  `id` int(10) UNSIGNED NOT NULL COMMENT 'Id',
  `level` int(10) UNSIGNED NOT NULL DEFAULT '0' COMMENT 'Уровень с которого доступен корабль',
  `name` int(10) UNSIGNED NOT NULL DEFAULT '0' COMMENT 'Название',
  `speed` float NOT NULL DEFAULT '0' COMMENT 'Скорость (ед./сек.)',
  `volume` int(10) UNSIGNED NOT NULL DEFAULT '0' COMMENT 'Общий объем свободного места на корабле',
  `price` int(10) UNSIGNED DEFAULT NULL COMMENT 'Цена',
  `price_type` enum('G','C') DEFAULT NULL COMMENT 'G - Gold, C - Crystals',
  `img40x40` int(10) UNSIGNED NOT NULL DEFAULT '33' COMMENT 'Id картинки',
  `img200x150` int(10) UNSIGNED NOT NULL DEFAULT '34' COMMENT 'Id большой картинки (с анимацией))',
  `img28x28` int(10) UNSIGNED NOT NULL DEFAULT '52' COMMENT 'Id изображения 28x28',
  `img30x30` int(10) UNSIGNED NOT NULL DEFAULT '145' COMMENT 'Id изображения 30x30',
  `desc` varchar(50) NOT NULL COMMENT 'Описание',
  `inpdate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Дата занесения'
) ENGINE=InnoDB DEFAULT CHARSET=cp1251 COMMENT='Корабли';

-- --------------------------------------------------------

--
-- Структура таблицы `vn_ship_modules`
--

CREATE TABLE `vn_ship_modules` (
  `id` int(10) UNSIGNED NOT NULL COMMENT 'id',
  `type` char(2) DEFAULT NULL COMMENT 'Тип модуля',
  `base_price` int(10) UNSIGNED NOT NULL COMMENT 'Цена за единицу объема',
  `base_price_type` enum('G','C') NOT NULL DEFAULT 'G' COMMENT 'Цена в G - золоте, C - кристаллах',
  `img30x30` int(10) UNSIGNED DEFAULT NULL COMMENT 'Изображение 30x30 (vn_graphic.id)',
  `desc` varchar(300) DEFAULT NULL COMMENT 'Описание'
) ENGINE=InnoDB DEFAULT CHARSET=cp1251 COMMENT='Справочник - типы модулей кораблей';

-- --------------------------------------------------------

--
-- Структура таблицы `vn_ship_modules_default`
--

CREATE TABLE `vn_ship_modules_default` (
  `id` int(10) UNSIGNED NOT NULL COMMENT 'id',
  `ship_id` int(10) UNSIGNED NOT NULL COMMENT 'Id корабля (vn_ship.id)',
  `type` int(10) UNSIGNED NOT NULL DEFAULT '1' COMMENT 'Тип модуля (vn_z_ship_module_types.id)',
  `mount` enum('C','M') NOT NULL DEFAULT 'C' COMMENT 'C - постоянный, M - съемный',
  `value` int(10) UNSIGNED NOT NULL DEFAULT '0' COMMENT 'Рабочее значение в кг. (объем танка, + к скорости и т.д.)'
) ENGINE=InnoDB DEFAULT CHARSET=cp1251 COMMENT='Танки, устанавливаемые на корабли по умолчанию';

-- --------------------------------------------------------

--
-- Структура таблицы `vn_ship_on_level`
--

CREATE TABLE `vn_ship_on_level` (
  `id` int(10) UNSIGNED NOT NULL COMMENT 'Id',
  `level` int(10) UNSIGNED NOT NULL DEFAULT '0' COMMENT 'Уровень',
  `ships` int(10) UNSIGNED NOT NULL DEFAULT '0' COMMENT 'Кол-во кораблей',
  `inpdate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Дата занесения'
) ENGINE=InnoDB DEFAULT CHARSET=cp1251 COMMENT='Доступно кораблей на уровень';

-- --------------------------------------------------------

--
-- Структура таблицы `vn_spaceobject`
--

CREATE TABLE `vn_spaceobject` (
  `id` int(10) UNSIGNED NOT NULL COMMENT 'id',
  `type` enum('OrbitR','OrbitV','StarR','StarV','PlanetR','PlanetV','StationR','StationV','ShipyardR','ShipyardV') NOT NULL COMMENT 'Тип объекта',
  `desc` varchar(50) NOT NULL COMMENT 'Описание',
  `inpdate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Дата ввода'
) ENGINE=InnoDB DEFAULT CHARSET=cp1251 COMMENT='Реестр всех космических объектов';

-- --------------------------------------------------------

--
-- Структура таблицы `vn_spaceobject_r`
--

CREATE TABLE `vn_spaceobject_r` (
  `id` int(10) UNSIGNED NOT NULL COMMENT 'id',
  `spaceobject_id` int(10) UNSIGNED NOT NULL COMMENT 'id в vn_spaceobject',
  `k_real` int(10) UNSIGNED NOT NULL COMMENT 'Коэффициент для получения реальных координат объекта или размеров орбиты',
  `inpdate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Дата ввода'
) ENGINE=InnoDB DEFAULT CHARSET=cp1251 COMMENT='Реестр виртуальных космических объектов';

-- --------------------------------------------------------

--
-- Структура таблицы `vn_spaceobject_v`
--

CREATE TABLE `vn_spaceobject_v` (
  `id` int(10) UNSIGNED NOT NULL COMMENT 'id',
  `spaceobject_id` int(10) UNSIGNED NOT NULL COMMENT 'id в vn_spaceobject',
  `price` int(10) UNSIGNED DEFAULT NULL COMMENT 'Цена',
  `price_type` enum('G','C') DEFAULT NULL COMMENT 'Цена в золоте/кристаллах',
  `img_60x60` int(10) UNSIGNED NOT NULL DEFAULT '129' COMMENT 'Изображение 60x60',
  `bonus` text COMMENT 'Бонус',
  `bonus_interval` int(20) UNSIGNED DEFAULT NULL COMMENT 'Интервал получения бонуса (в сек)',
  `inpdate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Дата ввода'
) ENGINE=InnoDB DEFAULT CHARSET=cp1251 COMMENT='Реестр виртуальных космических объектов';

-- --------------------------------------------------------

--
-- Структура таблицы `vn_star`
--

CREATE TABLE `vn_star` (
  `id` int(10) UNSIGNED NOT NULL COMMENT 'Id',
  `spaceobject_id` int(10) UNSIGNED NOT NULL COMMENT 'id в vn_spaceobject',
  `name` int(10) UNSIGNED NOT NULL COMMENT 'Название - ссылка на vn_text',
  `img` int(10) UNSIGNED NOT NULL COMMENT 'Изображение (Id в vn_graphic)'
) ENGINE=InnoDB DEFAULT CHARSET=cp1251 COMMENT='Реестр планет';

-- --------------------------------------------------------

--
-- Структура таблицы `vn_starsystem`
--

CREATE TABLE `vn_starsystem` (
  `id` int(10) UNSIGNED NOT NULL COMMENT 'Id',
  `sub_id` int(10) UNSIGNED DEFAULT NULL COMMENT 'Id подчинения - к какому Id цепляется данный Id',
  `starsystem_id` int(10) UNSIGNED NOT NULL DEFAULT '1' COMMENT 'Id звездной системы',
  `spaceobject_id` int(10) UNSIGNED NOT NULL DEFAULT '0' COMMENT 'id в vn_spaceobject',
  `s_point_x` int(11) DEFAULT NULL COMMENT 'X - координата начальной точки',
  `s_point_y` int(11) DEFAULT NULL COMMENT 'Y - координата начальной точки',
  `s_point_z` int(11) DEFAULT NULL COMMENT 'Глубина объекта в сцене (чем больше - тем выше). Отделение интерфейса от объектов.',
  `inpdate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Дата занесения'
) ENGINE=InnoDB DEFAULT CHARSET=cp1251 COMMENT='Сектор "Солнечная система"';

-- --------------------------------------------------------

--
-- Структура таблицы `vn_starsystem_industry`
--

CREATE TABLE `vn_starsystem_industry` (
  `id` int(10) UNSIGNED NOT NULL COMMENT 'Id',
  `spaceobject_id` int(10) UNSIGNED NOT NULL COMMENT 'id в vn_spaceobject',
  `industry_id` int(10) UNSIGNED NOT NULL DEFAULT '1' COMMENT 'Производство (Id в vn_industry)',
  `max` int(10) UNSIGNED NOT NULL DEFAULT '1000000' COMMENT 'Максимальное количество',
  `min` int(10) UNSIGNED NOT NULL DEFAULT '0' COMMENT 'Минимальное количество',
  `current_value` int(10) UNSIGNED NOT NULL DEFAULT '0' COMMENT 'Текущее количество',
  `production` int(10) UNSIGNED NOT NULL DEFAULT '10' COMMENT 'Производство (ед. в мин.)',
  `needs` int(10) UNSIGNED NOT NULL DEFAULT '10' COMMENT 'Потребление (ед. в мин.)',
  `last_updated` bigint(20) UNSIGNED NOT NULL DEFAULT '1357453900000' COMMENT 'Время (в мс.) последнего обновления текущих данных',
  `desc` varchar(50) NOT NULL COMMENT 'Описание',
  `inpdate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Дата занесения'
) ENGINE=InnoDB DEFAULT CHARSET=cp1251 COMMENT='Производства';

-- --------------------------------------------------------

--
-- Структура таблицы `vn_text`
--

CREATE TABLE `vn_text` (
  `id` int(10) UNSIGNED NOT NULL COMMENT 'Id',
  `game_load` enum('T','F') NOT NULL DEFAULT 'T' COMMENT 'Т - загрузка в игру сразу, F - по требованию',
  `rus` text NOT NULL COMMENT 'RUS',
  `eng` text NOT NULL COMMENT 'ENG'
) ENGINE=InnoDB DEFAULT CHARSET=cp1251 COMMENT='Текст';

-- --------------------------------------------------------

--
-- Структура таблицы `vn_user`
--

CREATE TABLE `vn_user` (
  `id` int(10) UNSIGNED NOT NULL COMMENT 'Id',
  `login` varchar(15) NOT NULL COMMENT 'Login',
  `password` char(41) DEFAULT NULL COMMENT 'Password',
  `type` enum('F','P','R') NOT NULL DEFAULT 'F' COMMENT 'F - Бесплатный (Free), P - Платный (Payed), R - Полный (Root)',
  `premdate` date NOT NULL DEFAULT '0000-00-00' COMMENT 'Дата окончания платного режима',
  `email` varchar(50) NOT NULL COMMENT 'E-mail',
  `inpdate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Дата регистрации',
  `lastlogin` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'Дата последнего захода',
  `social_id` varchar(50) DEFAULT NULL COMMENT 'Id пользователя в социальной сети'
) ENGINE=InnoDB DEFAULT CHARSET=cp1251 COMMENT='Пользователи';

-- --------------------------------------------------------

--
-- Структура таблицы `vn_user_connections`
--

CREATE TABLE `vn_user_connections` (
  `id` int(10) UNSIGNED NOT NULL COMMENT 'Id',
  `user_id` int(10) UNSIGNED NOT NULL COMMENT 'id пользователя',
  `user_online` enum('F','T') DEFAULT 'F' COMMENT 'F - отключен, T - подключен',
  `read_buff` text NOT NULL COMMENT 'буфер чтения',
  `write_buff` text NOT NULL COMMENT 'буфер записи'
) ENGINE=InnoDB DEFAULT CHARSET=cp1251 COMMENT='Текущие соединения пользователей';

-- --------------------------------------------------------

--
-- Структура таблицы `vn_user_data`
--

CREATE TABLE `vn_user_data` (
  `id` int(10) UNSIGNED NOT NULL COMMENT 'Id',
  `user_id` int(10) UNSIGNED NOT NULL COMMENT 'Id пльзователя (Id в vn_user)',
  `level` int(10) UNSIGNED NOT NULL DEFAULT '0' COMMENT 'Уровень',
  `exp` int(10) UNSIGNED NOT NULL DEFAULT '0' COMMENT 'Набранный опыт',
  `crystals` int(10) UNSIGNED NOT NULL DEFAULT '10' COMMENT 'Кристаллы',
  `money` int(10) UNSIGNED NOT NULL DEFAULT '100' COMMENT 'Деньги'
) ENGINE=InnoDB DEFAULT CHARSET=cp1251 COMMENT='Игровые данные пользователя';

-- --------------------------------------------------------

--
-- Структура таблицы `vn_user_opt`
--

CREATE TABLE `vn_user_opt` (
  `id` int(10) UNSIGNED NOT NULL COMMENT 'Id',
  `user_id` int(10) UNSIGNED NOT NULL COMMENT 'id пользователя (Id в vn_user)',
  `show_orb` enum('T','F') NOT NULL DEFAULT 'T' COMMENT 'T - показывать орбиты, F - нет'
) ENGINE=InnoDB DEFAULT CHARSET=cp1251 COMMENT='Настройки пользователей';

-- --------------------------------------------------------

--
-- Структура таблицы `vn_user_quests_conditions`
--

CREATE TABLE `vn_user_quests_conditions` (
  `id` int(10) UNSIGNED NOT NULL COMMENT 'Id',
  `user_id` int(10) UNSIGNED NOT NULL COMMENT 'id пользователя (Id в vn_user)',
  `quest_id` int(10) UNSIGNED NOT NULL DEFAULT '1' COMMENT 'Id квеста (в vn_quests)',
  `stage` int(10) UNSIGNED NOT NULL DEFAULT '1' COMMENT 'этап',
  `condition` text COMMENT '1 Этап'
) ENGINE=InnoDB DEFAULT CHARSET=cp1251 COMMENT='Настройки пользователей';

-- --------------------------------------------------------

--
-- Структура таблицы `vn_user_quests_finished`
--

CREATE TABLE `vn_user_quests_finished` (
  `id` int(10) UNSIGNED NOT NULL COMMENT 'Id',
  `user_id` int(10) UNSIGNED NOT NULL DEFAULT '1' COMMENT 'Id пользователя (Id в vn_user)',
  `quest_id` int(10) UNSIGNED DEFAULT NULL COMMENT 'Id квеста (в vn_quests)',
  `inpdate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Дата занесения'
) ENGINE=InnoDB DEFAULT CHARSET=cp1251 COMMENT='Завершенные квесты';

-- --------------------------------------------------------

--
-- Структура таблицы `vn_user_quests_prize`
--

CREATE TABLE `vn_user_quests_prize` (
  `id` int(10) UNSIGNED NOT NULL COMMENT 'Id',
  `user_id` int(10) UNSIGNED NOT NULL DEFAULT '0' COMMENT 'Id пользователя (Id в vn_user)',
  `quest_id` int(10) UNSIGNED NOT NULL COMMENT 'Id квеста (Id в vn_quests)',
  `stage` int(10) UNSIGNED NOT NULL DEFAULT '1' COMMENT 'Этап квеста',
  `prize` text COMMENT 'XML описание награды',
  `order` int(10) UNSIGNED NOT NULL DEFAULT '0' COMMENT 'Поле для сортировки внутри Stage (Текст должен выводиться раньше призов)'
) ENGINE=InnoDB DEFAULT CHARSET=cp1251 COMMENT='Сообщения пользователю о завершении квеста';

-- --------------------------------------------------------

--
-- Структура таблицы `vn_user_ships`
--

CREATE TABLE `vn_user_ships` (
  `id` int(10) UNSIGNED NOT NULL COMMENT 'Id',
  `lock` int(10) UNSIGNED NOT NULL DEFAULT '0' COMMENT 'Блокировка строки для обработки',
  `user_id` int(10) UNSIGNED NOT NULL COMMENT 'id пользователя (Id в vn_user)',
  `ship_id` int(10) UNSIGNED NOT NULL DEFAULT '1' COMMENT 'Id корабля в vn_ships',
  `a_planet` int(10) UNSIGNED NOT NULL DEFAULT '9' COMMENT 'Id стартовой планеты (из vn_spaceobject)',
  `b_planet` int(10) UNSIGNED NOT NULL DEFAULT '9' COMMENT 'Id конечной планеты (из vn_spaceobject)',
  `a_time` bigint(20) UNSIGNED NOT NULL DEFAULT '0' COMMENT 'Время старта с планеты A',
  `b_time` bigint(20) UNSIGNED NOT NULL DEFAULT '0' COMMENT 'Время прибытия на планету B'
) ENGINE=InnoDB DEFAULT CHARSET=cp1251 COMMENT='Настройки пользователей';

-- --------------------------------------------------------

--
-- Структура таблицы `vn_user_ships_cargo`
--

CREATE TABLE `vn_user_ships_cargo` (
  `id` int(10) UNSIGNED NOT NULL COMMENT 'id',
  `user_ship_id` int(10) UNSIGNED NOT NULL COMMENT 'Id корабля (vn_user_ships.id)',
  `cargo_id` int(10) UNSIGNED NOT NULL COMMENT 'Id груза (vn_industry.id)',
  `cargo_source` int(10) UNSIGNED NOT NULL COMMENT 'Планета покупки (vn_starsystem.id)',
  `cargo_volume` int(10) UNSIGNED NOT NULL COMMENT 'Объем груза (в кг.)',
  `cargo_price` int(10) UNSIGNED NOT NULL COMMENT 'Цена заплаченная за 1 ед. (1000 кг.) груза'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Груз на кораблях пользователя';

-- --------------------------------------------------------

--
-- Структура таблицы `vn_user_ships_modules`
--

CREATE TABLE `vn_user_ships_modules` (
  `id` int(10) UNSIGNED NOT NULL COMMENT 'id',
  `user_ship_id` int(10) UNSIGNED NOT NULL COMMENT 'Id корабля пользователя (vn_user_ships.id)',
  `type` int(10) UNSIGNED NOT NULL DEFAULT '1' COMMENT 'Тип модуля (vn_ship_modules.id)',
  `mount` enum('C','M') NOT NULL DEFAULT 'C' COMMENT 'C - постоянный, M - съемный',
  `value` int(10) UNSIGNED NOT NULL DEFAULT '0' COMMENT 'Рабочее значение в кг. (объем танка, + к скорости и т.д.)'
) ENGINE=InnoDB DEFAULT CHARSET=cp1251 COMMENT='Танки, устанавливаемые на корабли по умолчанию';

-- --------------------------------------------------------

--
-- Структура таблицы `vn_user_starsystem`
--

CREATE TABLE `vn_user_starsystem` (
  `id` int(10) UNSIGNED NOT NULL COMMENT 'Id',
  `sub_id` int(10) UNSIGNED DEFAULT NULL COMMENT 'Id подчинения - к какому Id цепляется данный Id',
  `user_id` int(10) UNSIGNED NOT NULL COMMENT 'Id пользователя',
  `spaceobject_id` int(10) UNSIGNED NOT NULL COMMENT 'id в vn_spaceobject',
  `s_point_x` int(11) DEFAULT NULL COMMENT 'X - координата начальной точки',
  `s_point_y` int(11) DEFAULT NULL COMMENT 'Y - координата начальной точки',
  `s_point_z` int(11) DEFAULT NULL COMMENT 'координата начальной точки',
  `bonus_getted` timestamp NULL DEFAULT NULL COMMENT 'Время последнего получения бонуса'
) ENGINE=InnoDB DEFAULT CHARSET=cp1251 COMMENT='Виртульные системы пользователей';

-- --------------------------------------------------------

--
-- Структура таблицы `vn_user_starsystem_orbits_v`
--

CREATE TABLE `vn_user_starsystem_orbits_v` (
  `id` int(10) UNSIGNED NOT NULL COMMENT 'Id',
  `user_starsystem_id` int(10) UNSIGNED NOT NULL COMMENT 'Id в vn_spaceobject',
  `radius_s` int(10) UNSIGNED NOT NULL DEFAULT '75' COMMENT 'Малый радиус',
  `radius_l` int(10) UNSIGNED NOT NULL DEFAULT '150' COMMENT 'Большой радиус',
  `angle` int(11) NOT NULL DEFAULT '45' COMMENT 'Угол наклона',
  `speed` float NOT NULL DEFAULT '0.001' COMMENT 'Скорость движения по орбите'
) ENGINE=InnoDB DEFAULT CHARSET=cp1251 COMMENT='Данные по виртуальным орбитам (просто вынесены в отд. табл.)';

--
-- Индексы сохранённых таблиц
--

--
-- Индексы таблицы `vn_graphic`
--
ALTER TABLE `vn_graphic`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `FileName` (`img_path`,`img_name`,`img_ext`);

--
-- Индексы таблицы `vn_industry`
--
ALTER TABLE `vn_industry`
  ADD PRIMARY KEY (`id`),
  ADD KEY `type` (`type`),
  ADD KEY `img` (`img`);

--
-- Индексы таблицы `vn_level`
--
ALTER TABLE `vn_level`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `level` (`level`);

--
-- Индексы таблицы `vn_news`
--
ALTER TABLE `vn_news`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `vn_orbit`
--
ALTER TABLE `vn_orbit`
  ADD PRIMARY KEY (`id`),
  ADD KEY `spaceobject_id` (`spaceobject_id`);

--
-- Индексы таблицы `vn_planet`
--
ALTER TABLE `vn_planet`
  ADD PRIMARY KEY (`id`),
  ADD KEY `spaceobject_id` (`spaceobject_id`);

--
-- Индексы таблицы `vn_planet_r`
--
ALTER TABLE `vn_planet_r`
  ADD PRIMARY KEY (`id`),
  ADD KEY `spaceobject_id` (`spaceobject_id`);

--
-- Индексы таблицы `vn_quests`
--
ALTER TABLE `vn_quests`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `vn_quests_conditions`
--
ALTER TABLE `vn_quests_conditions`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `vn_ship`
--
ALTER TABLE `vn_ship`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `vn_ship_modules`
--
ALTER TABLE `vn_ship_modules`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `type` (`type`),
  ADD KEY `img30x30` (`img30x30`);

--
-- Индексы таблицы `vn_ship_modules_default`
--
ALTER TABLE `vn_ship_modules_default`
  ADD PRIMARY KEY (`id`),
  ADD KEY `ship_id` (`ship_id`),
  ADD KEY `type` (`type`);

--
-- Индексы таблицы `vn_ship_on_level`
--
ALTER TABLE `vn_ship_on_level`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `level` (`level`);

--
-- Индексы таблицы `vn_spaceobject`
--
ALTER TABLE `vn_spaceobject`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `vn_spaceobject_r`
--
ALTER TABLE `vn_spaceobject_r`
  ADD PRIMARY KEY (`id`),
  ADD KEY `spaceobject_id` (`spaceobject_id`);

--
-- Индексы таблицы `vn_spaceobject_v`
--
ALTER TABLE `vn_spaceobject_v`
  ADD PRIMARY KEY (`id`),
  ADD KEY `spaceobject_id` (`spaceobject_id`);

--
-- Индексы таблицы `vn_star`
--
ALTER TABLE `vn_star`
  ADD PRIMARY KEY (`id`),
  ADD KEY `spaceobject_id` (`spaceobject_id`);

--
-- Индексы таблицы `vn_starsystem`
--
ALTER TABLE `vn_starsystem`
  ADD PRIMARY KEY (`id`),
  ADD KEY `iid` (`id`,`sub_id`),
  ADD KEY `spaceobject_id` (`spaceobject_id`);

--
-- Индексы таблицы `vn_starsystem_industry`
--
ALTER TABLE `vn_starsystem_industry`
  ADD PRIMARY KEY (`id`),
  ADD KEY `type` (`industry_id`),
  ADD KEY `spaceobject_id` (`spaceobject_id`);

--
-- Индексы таблицы `vn_text`
--
ALTER TABLE `vn_text`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `vn_user`
--
ALTER TABLE `vn_user`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `login` (`login`);

--
-- Индексы таблицы `vn_user_connections`
--
ALTER TABLE `vn_user_connections`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `vn_user_data`
--
ALTER TABLE `vn_user_data`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `vn_user_opt`
--
ALTER TABLE `vn_user_opt`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `vn_user_quests_conditions`
--
ALTER TABLE `vn_user_quests_conditions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `vn_user_quests_finished`
--
ALTER TABLE `vn_user_quests_finished`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `vn_user_quests_prize`
--
ALTER TABLE `vn_user_quests_prize`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `vn_user_ships`
--
ALTER TABLE `vn_user_ships`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `ship_id` (`ship_id`),
  ADD KEY `a_planet` (`a_planet`),
  ADD KEY `b_planet` (`b_planet`);

--
-- Индексы таблицы `vn_user_ships_cargo`
--
ALTER TABLE `vn_user_ships_cargo`
  ADD PRIMARY KEY (`id`),
  ADD KEY `cargo_id` (`cargo_id`),
  ADD KEY `cargo_source` (`cargo_source`),
  ADD KEY `user_ship_id` (`user_ship_id`);

--
-- Индексы таблицы `vn_user_ships_modules`
--
ALTER TABLE `vn_user_ships_modules`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_ship_id` (`user_ship_id`),
  ADD KEY `type` (`type`);

--
-- Индексы таблицы `vn_user_starsystem`
--
ALTER TABLE `vn_user_starsystem`
  ADD PRIMARY KEY (`id`),
  ADD KEY `iid` (`id`,`sub_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `spaceobject_id` (`spaceobject_id`);

--
-- Индексы таблицы `vn_user_starsystem_orbits_v`
--
ALTER TABLE `vn_user_starsystem_orbits_v`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_statsystem_id` (`user_starsystem_id`);

--
-- AUTO_INCREMENT для сохранённых таблиц
--

--
-- AUTO_INCREMENT для таблицы `vn_graphic`
--
ALTER TABLE `vn_graphic`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Id';

--
-- AUTO_INCREMENT для таблицы `vn_industry`
--
ALTER TABLE `vn_industry`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Id';

--
-- AUTO_INCREMENT для таблицы `vn_level`
--
ALTER TABLE `vn_level`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Id';

--
-- AUTO_INCREMENT для таблицы `vn_news`
--
ALTER TABLE `vn_news`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Id';

--
-- AUTO_INCREMENT для таблицы `vn_orbit`
--
ALTER TABLE `vn_orbit`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Id';

--
-- AUTO_INCREMENT для таблицы `vn_planet`
--
ALTER TABLE `vn_planet`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Id';

--
-- AUTO_INCREMENT для таблицы `vn_planet_r`
--
ALTER TABLE `vn_planet_r`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Id';

--
-- AUTO_INCREMENT для таблицы `vn_quests`
--
ALTER TABLE `vn_quests`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Id';

--
-- AUTO_INCREMENT для таблицы `vn_quests_conditions`
--
ALTER TABLE `vn_quests_conditions`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Id';

--
-- AUTO_INCREMENT для таблицы `vn_ship`
--
ALTER TABLE `vn_ship`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Id';

--
-- AUTO_INCREMENT для таблицы `vn_ship_modules`
--
ALTER TABLE `vn_ship_modules`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'id';

--
-- AUTO_INCREMENT для таблицы `vn_ship_modules_default`
--
ALTER TABLE `vn_ship_modules_default`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'id';

--
-- AUTO_INCREMENT для таблицы `vn_ship_on_level`
--
ALTER TABLE `vn_ship_on_level`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Id';

--
-- AUTO_INCREMENT для таблицы `vn_spaceobject`
--
ALTER TABLE `vn_spaceobject`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'id';

--
-- AUTO_INCREMENT для таблицы `vn_spaceobject_r`
--
ALTER TABLE `vn_spaceobject_r`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'id';

--
-- AUTO_INCREMENT для таблицы `vn_spaceobject_v`
--
ALTER TABLE `vn_spaceobject_v`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'id';

--
-- AUTO_INCREMENT для таблицы `vn_star`
--
ALTER TABLE `vn_star`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Id';

--
-- AUTO_INCREMENT для таблицы `vn_starsystem`
--
ALTER TABLE `vn_starsystem`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Id';

--
-- AUTO_INCREMENT для таблицы `vn_starsystem_industry`
--
ALTER TABLE `vn_starsystem_industry`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Id';

--
-- AUTO_INCREMENT для таблицы `vn_text`
--
ALTER TABLE `vn_text`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Id';

--
-- AUTO_INCREMENT для таблицы `vn_user`
--
ALTER TABLE `vn_user`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Id';

--
-- AUTO_INCREMENT для таблицы `vn_user_connections`
--
ALTER TABLE `vn_user_connections`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Id';

--
-- AUTO_INCREMENT для таблицы `vn_user_data`
--
ALTER TABLE `vn_user_data`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Id';

--
-- AUTO_INCREMENT для таблицы `vn_user_opt`
--
ALTER TABLE `vn_user_opt`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Id';

--
-- AUTO_INCREMENT для таблицы `vn_user_quests_conditions`
--
ALTER TABLE `vn_user_quests_conditions`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Id';

--
-- AUTO_INCREMENT для таблицы `vn_user_quests_finished`
--
ALTER TABLE `vn_user_quests_finished`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Id';

--
-- AUTO_INCREMENT для таблицы `vn_user_quests_prize`
--
ALTER TABLE `vn_user_quests_prize`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Id';

--
-- AUTO_INCREMENT для таблицы `vn_user_ships`
--
ALTER TABLE `vn_user_ships`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Id';

--
-- AUTO_INCREMENT для таблицы `vn_user_ships_cargo`
--
ALTER TABLE `vn_user_ships_cargo`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'id';

--
-- AUTO_INCREMENT для таблицы `vn_user_ships_modules`
--
ALTER TABLE `vn_user_ships_modules`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'id';

--
-- AUTO_INCREMENT для таблицы `vn_user_starsystem`
--
ALTER TABLE `vn_user_starsystem`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Id';

--
-- AUTO_INCREMENT для таблицы `vn_user_starsystem_orbits_v`
--
ALTER TABLE `vn_user_starsystem_orbits_v`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Id';

--
-- Ограничения внешнего ключа сохраненных таблиц
--

--
-- Ограничения внешнего ключа таблицы `vn_industry`
--
ALTER TABLE `vn_industry`
  ADD CONSTRAINT `vn_industry_ibfk_1` FOREIGN KEY (`type`) REFERENCES `vn_ship_modules` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `vn_industry_ibfk_2` FOREIGN KEY (`img`) REFERENCES `vn_graphic` (`id`) ON DELETE SET NULL;

--
-- Ограничения внешнего ключа таблицы `vn_orbit`
--
ALTER TABLE `vn_orbit`
  ADD CONSTRAINT `vn_orbit_ibfk_1` FOREIGN KEY (`spaceobject_id`) REFERENCES `vn_spaceobject` (`id`) ON DELETE CASCADE;

--
-- Ограничения внешнего ключа таблицы `vn_planet`
--
ALTER TABLE `vn_planet`
  ADD CONSTRAINT `vn_planet_ibfk_1` FOREIGN KEY (`spaceobject_id`) REFERENCES `vn_spaceobject` (`id`) ON DELETE CASCADE;

--
-- Ограничения внешнего ключа таблицы `vn_planet_r`
--
ALTER TABLE `vn_planet_r`
  ADD CONSTRAINT `vn_planet_r_ibfk_1` FOREIGN KEY (`spaceobject_id`) REFERENCES `vn_spaceobject` (`id`) ON DELETE CASCADE;

--
-- Ограничения внешнего ключа таблицы `vn_ship_modules`
--
ALTER TABLE `vn_ship_modules`
  ADD CONSTRAINT `vn_ship_modules_ibfk_1` FOREIGN KEY (`img30x30`) REFERENCES `vn_graphic` (`id`) ON DELETE SET NULL;

--
-- Ограничения внешнего ключа таблицы `vn_ship_modules_default`
--
ALTER TABLE `vn_ship_modules_default`
  ADD CONSTRAINT `vn_ship_modules_default_ibfk_1` FOREIGN KEY (`ship_id`) REFERENCES `vn_ship` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `vn_ship_modules_default_ibfk_2` FOREIGN KEY (`type`) REFERENCES `vn_ship_modules` (`id`) ON DELETE CASCADE;

--
-- Ограничения внешнего ключа таблицы `vn_spaceobject_r`
--
ALTER TABLE `vn_spaceobject_r`
  ADD CONSTRAINT `vn_spaceobject_r_ibfk_1` FOREIGN KEY (`spaceobject_id`) REFERENCES `vn_spaceobject` (`id`) ON DELETE CASCADE;

--
-- Ограничения внешнего ключа таблицы `vn_spaceobject_v`
--
ALTER TABLE `vn_spaceobject_v`
  ADD CONSTRAINT `vn_spaceobject_v_ibfk_1` FOREIGN KEY (`spaceobject_id`) REFERENCES `vn_spaceobject` (`id`) ON DELETE CASCADE;

--
-- Ограничения внешнего ключа таблицы `vn_star`
--
ALTER TABLE `vn_star`
  ADD CONSTRAINT `vn_star_ibfk_1` FOREIGN KEY (`spaceobject_id`) REFERENCES `vn_spaceobject` (`id`) ON DELETE CASCADE;

--
-- Ограничения внешнего ключа таблицы `vn_starsystem`
--
ALTER TABLE `vn_starsystem`
  ADD CONSTRAINT `vn_starsystem_ibfk_1` FOREIGN KEY (`spaceobject_id`) REFERENCES `vn_spaceobject` (`id`) ON DELETE CASCADE;

--
-- Ограничения внешнего ключа таблицы `vn_starsystem_industry`
--
ALTER TABLE `vn_starsystem_industry`
  ADD CONSTRAINT `vn_starsystem_industry_ibfk_1` FOREIGN KEY (`spaceobject_id`) REFERENCES `vn_spaceobject` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `vn_starsystem_industry_ibfk_2` FOREIGN KEY (`industry_id`) REFERENCES `vn_industry` (`id`) ON DELETE CASCADE;

--
-- Ограничения внешнего ключа таблицы `vn_user_connections`
--
ALTER TABLE `vn_user_connections`
  ADD CONSTRAINT `vn_user_connections_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `vn_user` (`id`) ON DELETE CASCADE;

--
-- Ограничения внешнего ключа таблицы `vn_user_data`
--
ALTER TABLE `vn_user_data`
  ADD CONSTRAINT `vn_user_data_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `vn_user` (`id`) ON DELETE CASCADE;

--
-- Ограничения внешнего ключа таблицы `vn_user_opt`
--
ALTER TABLE `vn_user_opt`
  ADD CONSTRAINT `vn_user_opt_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `vn_user` (`id`) ON DELETE CASCADE;

--
-- Ограничения внешнего ключа таблицы `vn_user_quests_conditions`
--
ALTER TABLE `vn_user_quests_conditions`
  ADD CONSTRAINT `vn_user_quests_conditions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `vn_user` (`id`) ON DELETE CASCADE;

--
-- Ограничения внешнего ключа таблицы `vn_user_quests_finished`
--
ALTER TABLE `vn_user_quests_finished`
  ADD CONSTRAINT `vn_user_quests_finished_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `vn_user` (`id`) ON DELETE CASCADE;

--
-- Ограничения внешнего ключа таблицы `vn_user_quests_prize`
--
ALTER TABLE `vn_user_quests_prize`
  ADD CONSTRAINT `vn_user_quests_prize_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `vn_user` (`id`) ON DELETE CASCADE;

--
-- Ограничения внешнего ключа таблицы `vn_user_ships`
--
ALTER TABLE `vn_user_ships`
  ADD CONSTRAINT `vn_user_ships_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `vn_user` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `vn_user_ships_ibfk_2` FOREIGN KEY (`ship_id`) REFERENCES `vn_ship` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `vn_user_ships_ibfk_3` FOREIGN KEY (`a_planet`) REFERENCES `vn_spaceobject` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `vn_user_ships_ibfk_4` FOREIGN KEY (`b_planet`) REFERENCES `vn_spaceobject` (`id`) ON DELETE CASCADE;

--
-- Ограничения внешнего ключа таблицы `vn_user_ships_cargo`
--
ALTER TABLE `vn_user_ships_cargo`
  ADD CONSTRAINT `vn_user_ships_cargo_ibfk_2` FOREIGN KEY (`cargo_id`) REFERENCES `vn_industry` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `vn_user_ships_cargo_ibfk_4` FOREIGN KEY (`user_ship_id`) REFERENCES `vn_user_ships` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `vn_user_ships_cargo_ibfk_5` FOREIGN KEY (`cargo_source`) REFERENCES `vn_starsystem` (`id`) ON DELETE CASCADE;

--
-- Ограничения внешнего ключа таблицы `vn_user_ships_modules`
--
ALTER TABLE `vn_user_ships_modules`
  ADD CONSTRAINT `vn_user_ships_modules_ibfk_1` FOREIGN KEY (`user_ship_id`) REFERENCES `vn_user_ships` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `vn_user_ships_modules_ibfk_2` FOREIGN KEY (`type`) REFERENCES `vn_ship_modules` (`id`) ON DELETE CASCADE;

--
-- Ограничения внешнего ключа таблицы `vn_user_starsystem`
--
ALTER TABLE `vn_user_starsystem`
  ADD CONSTRAINT `vn_user_starsystem_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `vn_user` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `vn_user_starsystem_ibfk_2` FOREIGN KEY (`spaceobject_id`) REFERENCES `vn_spaceobject` (`id`) ON DELETE CASCADE;

--
-- Ограничения внешнего ключа таблицы `vn_user_starsystem_orbits_v`
--
ALTER TABLE `vn_user_starsystem_orbits_v`
  ADD CONSTRAINT `vn_user_starsystem_orbits_v_ibfk_1` FOREIGN KEY (`user_starsystem_id`) REFERENCES `vn_user_starsystem` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
