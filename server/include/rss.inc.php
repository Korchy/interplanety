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
		// ����������� ��������
		parent::__construct();
		// �����������
		
	}

	public function __destruct() {
		// ����������
		
		// ���������� ��������
		parent::__destruct();
	}
	
	public function AddPost($Title, $Text, $TextS, $TextLnk) {
		// ���������� ����� � ����� RSS
		$Html = new HTMLEx();
		$TextS = $Html->TextToEncodedHtml($TextS);
		$TextLnk = $Html->UrlToTxt($TextLnk);
		$this->Sql->SqlQuery = "insert into vn_news (title, info_s, info, info_link) values ('".$this->Sql->Escape($Title)."','".$this->Sql->Escape($TextS)."','".$this->Sql->Escape($Text)."','".$this->Sql->Escape($TextLnk)."');";
		$this->Sql->Exec();
	}
	
	public function EchoHeader() {
		// ����� ���������
		echo "<?xml version=\"1.0\" encoding=\"windows-1251\" ?>\n\r";
		echo "<rss version=\"2.0\">\n\r";
		echo "	<channel>\n\r";
		echo "		<title>Interplanety</title>\n\r";									// ���������
		echo "		<category>Games</category>\n\r";									// ���������
		echo "		<link>http://www.interplanety.ru</link>\n\r";						// ������ �� ����
		echo "		<copyright>".date("Y").",Interplanety"."</copyright>\n\r";			// ��������
		echo "		<description>Interplanety news and updates</description>\n\r";		// ��������
		$PubDate = $this->LastChanged();
		echo "		<lastBuildDate>".$PubDate."</lastBuildDate>\n\r";					// ���� ���������� ���������
		echo "		<language>ru</language>\n\r";										// ����
		echo "		<pubDate>".$PubDate."</pubDate>\n\r";								// ���� ����������
		echo "		<docs>http://blogs.law.harvard.edu/tech/rss</docs>\n\r";			// ������������ rss
		echo "		<managingEditor>interplanety@interplanety.ru</managingEditor>\n\r";	// ����� ��������� ��������
		echo "		<webMaster>interplanety@interplanety.ru</webMaster>\n\r";			// ����� ����������� ���������
		echo "		<ttl>60</ttl>\n\r";													// ��������� ����� � ���, ����� ������� ����� ��������� rss-����� �� ��������� ���������
		echo "		<image>\n\r";														// ����������� ��� ������ 88x31
		echo "			<url>http://www.interplanety.ru/graphic/banner/Interplanety_88x31.jpg</url>\n\r";
		echo "			<title>Interplanety</title>\n\r";								// title � link ������ ��������� � ������ � channel
		echo "			<link>http://www.interplanety.ru</link>\n\r";
		echo "		</image>\n\r";
	}
	
	public function EchoBody($NewsCount) {
		// ����� ������� � ���������� $NewsCount
		// �������� ������
		$this->Sql->SqlQuery = "select id, title, info_s, info_link, inpdate from vn_news order by inpdate desc limit ".$NewsCount.";";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			while($tmp = $SQLRez->fetch_array()) {
				// �� ������ ������� ������� ���� ������
				echo "		<item>\n\r";
				echo "			<title>".$tmp["title"]."</title>\n\r";												// ��������� �������
				echo "			<link>".$tmp["info_link"]."</link>\n\r";											// ������ �� ������ ����� �������
				echo "			<description>".$tmp["info_s"]."</description>\n\r";		// ������� ����������
				echo "			<category>News and updates</category>\n\r";											// ���������
				echo "			<pubDate>".date("r",strtotime($tmp["inpdate"]))."</pubDate>\n\r";					// ���� ����������
				echo "			<guid>".$tmp["id"]."</guid>\n\r";													// ���������� �������������
				echo "		</item>\n\r";
			}
			$this->Sql->FreeResult($SQLRez);
		}
	}
	
	public function EchoFooter() {
		// ����� �������
		echo "	</channel>\n\r";
		echo "</rss>\n\r";
	}
	
	public function LastChanged() {
		// ����� ���������� ����������
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