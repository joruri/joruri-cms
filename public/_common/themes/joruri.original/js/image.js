/* Function for Image
 *  - Swap image file
 */



function findObjByName(name)
{
	var i;
	if(document[name]){
		return document[name];
	}
	if(document.all && document.all[name]){
		return document.all[name];
	}
	for(i=0; i < document.forms.length; i++){
		if(document.forms[i][name]){
			return document.forms[i][name];
		}
	}
	return null;
}


/* Swap image */
var imgSrc = new Array();
var imgObj = new Array();

function swapImg()
{
	var i;
	var j = 0;
	var a = swapImg.arguments;

	restoreImg();

	for(i=0; i<a.length; i+=2){
		var obj = findObjByName(a[i]);
		if(obj != null){
			imgObj[j] = obj;
			imgSrc[j] = obj.src;
			j++;
			obj.src = a[i+1];
		}
	}
}

function restoreImg()
{
	var i;
	for(i=0; i<imgObj.length; i++){
		imgObj[i].src = imgSrc[i];
	}
	imgSrc = new Array();
	imgObj = new Array();
}


/* Chenge Style */
var styleClass = new Array();
var styleObj   = new Array();

function swapStyle()
{
	var i;
	var j = 0;
	var a = swapStyle.arguments;

	restoreStyle();

	for(i=0; i<a.length; i+=2){
		var obj = document.getElementById(a[i]);
		if(obj != null){
			styleObj[j]   = obj;
			styleClass[j] = obj.className;
			j++;
			obj.className = a[i+1];
		}
	}
}

function swapStyleByObj()
{
	var i;
	var j = 0;
	var a = swapStyleByObj.arguments;

	restoreStyle();

	for(i=0; i<a.length; i+=2){
		var obj = a[i];
		if(obj != null){
			styleObj[j]   = obj;
			styleClass[j] = obj.className;
			j++;
			obj.className = a[i+1];
		}
	}
}

function restoreStyle()
{
	var i;
	for(i=0; i<styleObj.length; i++){
		styleObj[i].className = styleClass[i];
	}
	styleClass = new Array();
	styleObj   = new Array();
}
////•¶ŽšŠg‘åEk¬//////////////////////////////////////////////////////////////////////////////
var target = "container";	//*•¶ŽšŠg‘åEk¬‘ÎÛƒGƒŠƒAiID–¼j
//
function setCookie(s){
	cName = "GD_FontSize=";
	exp = new Date();
	exp.setTime(exp.getTime() + 31536000000);
	document.cookie = cName + s + "; path=/; expires=" + exp.toGMTString();
}
//
function setFontSize(par) {
	if(!par || par=="") par = "100";
	document.getElementById(target).style.fontSize = par+'%';
	setCookie(par);
	setFontIcon(par);
}
function setFontIcon(zoom) {
	var bpath = '../image2/';
	if (zoom == "120") {
		document.getElementById('icon120').src = bpath+'bt_ml_b.gif';
		document.getElementById('icon100').src = bpath+'bt_mm_a.gif';
		document.getElementById('icon90').src  = bpath+'bt_ms_a.gif';

	} else if (zoom == "90") {
		document.getElementById('icon120').src = bpath+'bt_ml_a.gif';
		document.getElementById('icon100').src = bpath+'bt_mm_a.gif';
		document.getElementById('icon90').src  = bpath+'bt_ms_b.gif';
	} else {
		document.getElementById('icon120').src = bpath+'bt_ml_a.gif';
		document.getElementById('icon100').src = bpath+'bt_mm_b.gif';
		document.getElementById('icon90').src  = bpath+'bt_ms_a.gif';
	}
}
//
////•¶ŽšŠg‘åEk¬//////////////////////////////////////////////////////////////////////////////

