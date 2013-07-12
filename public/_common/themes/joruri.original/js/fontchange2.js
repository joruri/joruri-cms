//
window.onload = getCookie;

function getCookie(){
	zoom = "";
	cName = "GD_FontSize=";
	tmpCookie = document.cookie + ";";
	start = tmpCookie.indexOf(cName);
	if (start != -1)
	{
		end = tmpCookie.indexOf(";", start);
		zoom = tmpCookie.substring(start + cName.length, end);
		document.getElementById(target).style.fontSize = zoom+'%';
		setFontIcon(zoom);
	} else {
		document.getElementById(target).style.fontSize = "100%";
		setFontIcon('100');
	}
}
////ï∂éöägëÂÅEèkè¨//////////////////////////////////////////////////////////////////////////////
var target = "container";	//*ï∂éöägëÂÅEèkè¨ëŒè€ÉGÉäÉAÅiIDñºÅj
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
////ï∂éöägëÂÅEèkè¨//////////////////////////////////////////////////////////////////////////////

