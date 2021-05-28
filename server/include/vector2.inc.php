<?php
//---------------------------------
// ����� ��� ������ � ���������� ���������
//---------------------------------

//---------------------------------
class Vector2
{
	var $X;
	var $Y;
	
	public function __construct($NewX,$NewY) {
		// �����������
		$this->X = $NewX;
		$this->Y = $NewY;
	}

	public function __destruct() {
		// ����������
		
	}

	
	public function Length() {
		// ����� �������
		return sqrt($this->X * $this->X + $this->Y * $this->Y);
	}
	
	public static function Vec2Length($Vector) {
		// ����� ������� $Vector
		return sqrt($Vector->X * $Vector->X + $Vector->Y * $Vector->Y);
	}
	
	public function Subtract($NewVector) {
		// ������� ������ ����� $NewVector (��������� - � ������� ������)
		$this->X -= $NewVector->X;
		$this->Y -= $NewVector->Y;
	}
	
	public static function Vec2Subtract($Vec1,$Vec2) {
		// $Vec1 - $Vec2 (��������� ��������� �� $Vec2 � $Vec1)
		return new Vector2($Vec1->X - $Vec2->X, $Vec1->Y - $Vec2->Y);
	}
	
	public function Add($NewVector) {
		// ������� ������ ���� $NewVector
		$this->X += $NewVector->X;
		$this->Y += $NewVector->Y;
	}
	
	public static function Vec2Add($Vec1,$Vec2) {
		// $Vec1 + $Vec2
		return new Vector2($Vec1->X + $Vec2->X, $Vec1->Y + $Vec2->Y);
	}

}
?>