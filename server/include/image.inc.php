<?php
//---------------------------------
require_once("dbconnected_vn.inc.php");
//---------------------------------
class Image extends DBConnectedVn
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
	
	public function GetImagesInfo() {
		// Получить текстовые данные по всей графике
		$Rez = " ";
		$this->Sql->SqlQuery = "select id,object_type,object_id,center_x,center_y,img_path,img_name,img_ext,frames,preload from vn_graphic;";
		$this->Sql->Exec();
		if($SQLRez = $this->Sql->SqlRez) {
			while($tmp = $SQLRez->fetch_array()) {
				$Rez = $Rez.$tmp["id"].",".$tmp["object_type"].",".$tmp["object_id"].",".$tmp["center_x"].",".$tmp["center_y"].",".$tmp["img_path"].",".$tmp["img_name"].",".$tmp["img_ext"].",".$tmp["frames"].",".$tmp["preload"].";";
			}
			$this->Sql->FreeResult($SQLRez);
		}
		return substr($Rez,1);
	}
}
?>