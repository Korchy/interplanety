function seml() {
	var mArray = new Array();
	mArray[0] = 'interplanety';
	document.getElementById('seml').innerHTML = mArray[0]+'@'+mArray[0]+".ru";
	document.getElementById('seml').href = "mailto: "+mArray[0]+'@'+mArray[0]+".ru";
	document.getElementById('seml').onclick = function(e){};
}