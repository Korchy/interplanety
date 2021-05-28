// JavaScript Document
function galleryScroll(idButtonLeft,idButtonRight,idContainer){
	this.cnt=document.getElementById(idContainer);
	this.cnt._step=10;
	this.bl=document.getElementById(idButtonLeft);
	this.br=document.getElementById(idButtonRight);
	this.bl._setState=this.br._setState=function(state){
		if(!this._$.buttonInactiveClass)return;
		if(!this._isDefaultClassName){
			this._defaultClassName=this.className;
			this._isDefaultClassName=true;
		};
		this.className=state ? this._defaultClassName : this._$.buttonInactiveClass;
	};
	this.bl.onmousedown=function(){this._$.cnt._scroll(-1);};
	this.bl.onmouseup=function(){this._$.cnt._stopScroll();};
	this.br.onmousedown=function(){this._$.cnt._scroll(1);};
	this.br.onmouseup=function(){this._$.cnt._stopScroll();};
	this.cnt._stopScroll=function(){window.clearInterval(this._timerId);this._timerId=0;};
	this.cnt._scroll=function(direction){
		var leftDir=this.scrollLeft==0,
			rightDir=this.scrollLeft==this.scrollWidth-this.offsetWidth,
			isEnd=direction<0 ? leftDir : rightDir;
		if(this._timerId && isEnd)this._stopScroll();
		else if(!this._timerId && !isEnd)this._timerId=window.setInterval(function(o,direction){return function(){o._scroll(direction);}}(this,direction),30);
		this.scrollLeft+=this._step*direction;
		this._$.bl._setState(!leftDir);
		this._$.br._setState(!rightDir);
	};
	var func=function(o){return function(e){
		e=e||window.event;
		if(e.wheelDelta)o._scroll(-1*e.wheelDelta/120);
		else if(e.detail)o._scroll(e.detail/3);
		o._stopScroll();
		if(e.stopPropagation)e.stopPropagation();else e.cancelBubble=true;
		if(e.preventDefault)e.preventDefault();else e.returnValue=false;
	}}(this.cnt);
	if(this.cnt.attachEvent!=undefined)this.cnt.attachEvent('onmousewheel',func);
	else if(this.cnt.addEventListener)this.cnt.addEventListener('DOMMouseScroll',func,false);
	this.cnt.onmousewheel=func;
	
	for(i in this)if(this[i])this[i]._$=this;
	this.setButtonInactiveClass=function(className){
		this.buttonInactiveClass=className;
		this.bl._setState(false);
	};
	this.setShaders=function(png,width){
		var cnt=this.cnt.parentNode.insertBefore(document.createElement('div'),this.cnt),
			sh1=cnt.appendChild(document.createElement('div')),
			sh2=cnt.appendChild(document.createElement('div'));
		sh1.style.position=sh2.style.position=cnt.style.position='absolute';
		sh1.style.width=sh2.style.width=width+'px';
		sh1.style.height=sh2.style.height=this.cnt.offsetHeight+'px';
		sh1.style.background='url('+png+') repeat-y 0 0';
		sh2.style.background='url('+png+') repeat-y 100% 0';
		sh2.style.left=(this.cnt.offsetWidth-sh2.offsetWidth)+'px';
	};
};