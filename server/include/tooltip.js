//------------------------------------------------------------------
// Отображение всплывающей подсказки
// Для работы необходим файл tooltip.css
// Использование:
// 	В <head> указать ссылки на файл со стилями и на этот файл:
//		<link href="tooltip.css" type=text/css rel=stylesheet>
//		<script type="text/javascript" src="tooltip.js"></script>
//	В месте вызова указать:
//		<div onmouseover="ShowToolTip(this, event, 'ToolTipText');" onmouseout="HideToolTip(this);">XXX</div>
//	или
//		<img onmouseover="ShowToolTip(this, event, 'ToolTipText');" onmouseout="HideToolTip(this);" src='XXX.jpg'>
//------------------------------------------------------------------
var tooltip = document.createElement("div");
function GetCursorPosition(e) {
	var X = 0;
	var Y = 0;
    if (document.all) {
        X = event.clientX + document.body.scrollLeft;
        Y = event.clientY + document.body.scrollTop;
    }
    else {
        X = e.pageX;
        Y = e.pageY;
    }
    tooltip.style.left = X + "px";
    tooltip.style.top = Y + "px";
    return true;
}
 
function ShowToolTip(Obj, Event, Text){
	AddEventListener('mousemove', Obj, GetCursorPosition);
	GetCursorPosition(Event);	// Дополнительный вызов т.к. в IE не отрабатывается вызов mousemove при первом наведении
    document.body.appendChild(tooltip);
    tooltip.id = "tooltip";
    tooltip.innerHTML = Text;
}
 
function HideToolTip(Obj) {
	RemoveEventListener('mousemove', Obj, GetCursorPosition);
    document.body.removeChild(document.getElementById(tooltip.id));
}

function AddEventListener(Event, Element, Function) {
	// Переопределение для совместимости со старыми версиями IE
	if (Element.addEventListener)  // Новые
		Element.addEventListener(Event, Function, false);
	else if (Element.attachEvent) { // Старые (IE)
		Element.attachEvent("on"+Event, Function);
	}
	else {
		Element[Event] = Function;
	}
}

function RemoveEventListener(Event, Element, Function) {
	// Переопределение для совместимости со старыми версиями IE
	if (Element.removeEventListener)  // Новые
		Element.removeEventListener(Event, Function, false);
	else if (Element.detachEvent) { // Старые (IE)
		Element.detachEvent("on"+Event, Function);
	}
	else {
		Element[Event] = Function;
	}
}