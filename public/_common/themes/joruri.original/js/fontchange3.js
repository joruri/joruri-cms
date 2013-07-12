var x = 1.0;

function sizeChangeB(){
	if(x <= 1.2){
		x = x + 0.05;
		document.body.style.fontSize = x +"em";
	}
}

function sizeChangeS(){
	if(x >= 0.8){
		x = x - 0.05;
		document.body.style.fontSize = x +"em";
	}
}
