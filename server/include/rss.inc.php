<?php
//---------------------------------
// RSS
//---------------------------------
require_once("dbconnected_vn.inc.php");
require_once("htmlex.inc.php");
//---------------------------------
class RssVn extends DBConnectedVn
{
	
	public function __construct() {
		// Конструктор родителя
		parent::__construct();
		// Конструктор
		
	}

	public function __destruct() {
		// Деструктор
		
		// Деструктор родителя
		parent::__destruct();
	}
	
	public function AddPost($Title, $Text, $TextS, $TextLnk) {
		// Добавление поста в ленту RSS
		$Html = new HTMLEx();
		$TextS = $Html->TextToEncodedHtml($TextS);
		$TextLnk = $Html->UrlToTxt($TextLnk);
		$this->Sql->SqlQuery = "insert into vn_news (title, info_s, info, info_link) values ('".$this->Sql->Escape($Title)."','".$this->Sql->Escape($TextS)."','".$this->Sql->Escape($Text)."','".$this->Sql->Escape($TextLnk)."');";
		$this->Sql->Exec();
	}
	
	public function EchoHeader() {
		// Вывод заголовка
		echo "<?xml version=\"1.0\" encoding=\"windows-1251\" ?>\n\r";
		echo "<rss version=\"2.0\">\n\r";
		echo "	<channel>\n\r";
		echo "		<title>Interplanety</title>\n\r";									// Заголовок
		echo "		<category>Games</category>\n\r";									// Категория
		echo "		<link>http://www.interplanety.ru</link>\n\r";						// Ссылка на сайт
		echo "		<copyright>".date("Y").",Interplanety"."</copyright>\n\r";			// Копирайт
		echo "		<description>Interplanety news and updates</description>\n\r";		// Описание
		$PubDate = $this->LastChanged();
		echo "		<lastBuildDate>".$PubDate."</lastBuildDate>\n\r";					// Дата последнего изменения
		echo "		<language>ru</language>\n\r";										// Язык
		echo "		<pubDate>".$PubDate."</pubDate>\n\r";								// Дата публикации
		echo "		<docs>http://blogs.law.harvard.edu/tech/rss</docs>\n\r";			// Спецификация rss
		echo "		<managingEditor>interplanety@interplanety.ru</managingEditor>\n\r";	// Почта редактора контента
		echo "		<webMaster>interplanety@interplanety.ru</webMaster>\n\r";			// Почта технической поддержки
		echo "		<ttl>60</ttl>\n\r";													// Указывает время в мин, через которое нужно проверять rss-канал на появление изменений
		echo "		<image>\n\r";														// Изображение для канала 88x31
		echo "			<url>http://www.interplanety.ru/graphic/banner/Interplanety_88x31.jpg</url>\n\r";
		echo "			<title>Interplanety</title>\n\r";								// title и link должны совпадать с тегами в channel
		echo "			<link>http://www.interplanety.ru</link>\n\r";
		echo "		</image>\n\r";
	}
	
	public function EchoBody($NewsCount) {
		// Вывод анонсов в количестве $NewsCount
		// Получить данные
		$this->Sql->SqlQuery = "select id, title, info_s, info_link, inpdate from vn_news order by inpdate desc limit ".$NewsCount.";";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			while($tmp = $SQLRez->fetch_array()) {
				// По каджой новости создать блок данных
				echo "		<item>\n\r";
				echo "			<title>".$tmp["title"]."</title>\n\r";												// Заголовок новости
				echo "			<link>".$tmp["info_link"]."</link>\n\r";											// Ссылка на полный текст новости
				echo "			<description>".$tmp["info_s"]."</description>\n\r";		// Краткая информация
				echo "			<category>News and updates</category>\n\r";											// Категория
				echo "			<pubDate>".date("r",strtotime($tmp["inpdate"]))."</pubDate>\n\r";					// Дата публикации
				echo "			<guid>".$tmp["id"]."</guid>\n\r";													// Уникальный идентификатор
				echo "		</item>\n\r";
			}
			$this->Sql->FreeResult($SQLRez);
		}
	}
	
	public function EchoFooter() {
		// Вывод подвала
		echo "	</channel>\n\r";
		echo "</rss>\n\r";
	}
	
	public function LastChanged() {
		// Время последнего обновления
		$MaxDate = NULL;
		$this->Sql->SqlQuery = "select max(inpdate) as maxdate from vn_news;";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			while($tmp = $SQLRez->fetch_array()) {
				 $MaxDate = $tmp["maxdate"];
			}
			$this->Sql->FreeResult($SQLRez);
		}
		return date("r",strtotime($MaxDate));
	}
}
?>