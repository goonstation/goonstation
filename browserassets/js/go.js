var initlist = json
//var initlist = JSON.parse(json)

//var s = 1 //placeholder
var main
var color

var globalx
var globaly
var globaltile

function byond() {
    url = "?src=" + srcRef;
    currentIsKey = true;
    for(var i = 0; i < arguments.length; i++) {
        if(currentIsKey)
            url += ";";
        else
            url += "=";
        url += arguments[i];
        currentIsKey = !currentIsKey;
    }
    console.log(url);
    const Http = new XMLHttpRequest();
    Http.open("GET", url);
    Http.send();
}

removepiece = function(position){
	var stonelist = document.getElementsByTagName("img");

	for(var i = 0; i<stonelist.length; i++) {
		if((stonelist[i].dataset.loc) && (stonelist[i].dataset.loc == position)) {
			stonelist[i].parentElement.removeChild(stonelist[i]);
			break;
		}
	}
}

var piececlick = function(e){
	e.preventDefault();
	var stone = e.srcElement;
	stone.parentElement.removeChild(stone);
	byond("command","remove","position",stone.dataset.loc,"color",stone.dataset.color);
}

createpiece = function(x,y,color,tile,type,position){
	if(type == null){
		type = "primary";
	}
	if(type == "secondary"){
		tile = document.getElementById(position)
		var coordinates = tile.coords.split(",");
		x = coordinates[0];
		y = coordinates[1];
	}
	var piece = document.createElement("img");
	piece.src = color == "white" ? "{{resource("images/go/gowhite.png")}}" : "{{resource("images/go/goblack.png")}}";
	piece.style.position = "absolute"
	piece.style.left = x+"px";
	piece.style.top = y+"px";
	piece.dataset.loc = tile.id;
	piece.dataset.color = color;
	piece.dataset.offsetx = tile.dataset.offsetx;
	piece.dataset.offsety = tile.dataset.offsety;
	piece.onclick = piececlick;
	main.appendChild(piece)
	if(type != "secondary"){
		byond("command","piecelog","offsetx",piece.dataset.offsetx,"offsety",piece.dataset.offsety,"position",tile.id,"color",color);
	}
}

checkhand = function(color){
	createpiece(globalx,globaly,color,globaltile);
	globalx = null;
	globaly = null;
	globatile = null;
}

var gridclick = function(e){
	e.preventDefault();
	var coordinates = e.srcElement.coords.split(",");
	globalx = coordinates[0];
	globaly = coordinates[1];
	globaltile = e.srcElement;

	byond("command","checkhand");
}

window.onload = function(e) {
	document.body.scroll="no";
	var map = document.getElementById("map");
	main = document.getElementById("main");
	var x = -10;
	var x2 = 30;
	var y = 31;
	var y2 = 71;
	var row = 0;
	var iterations = 13;
	var number = 0;
	var alphabet = new Array("A","B","C","D","E","F","G","H","I","J","K","L","M","N")
	for(var i = 0; i<169; i++) {
		var ar = document.createElement("area");
		ar.shape = "rect"
		if((iterations == 13) && (row != 0)) {
			x = -10;
			x2 = 30;
			y = 31;
			y2 = 71;
			for(var a = 0; a<row; a++) {
				y+=41;
				y2+=41;
			}
		}
		x += 41;
		x2 += 41;
		ar.coords = x+","+y+","+x2+","+y2
		number++
		ar.id = alphabet[row]+iterations;
		ar.dataset.offsetx = ((iterations-1)*2)
		ar.dataset.offsety = (row*2)
		ar.href = "https://google.com"
		ar.onclick = gridclick;
		map.appendChild(ar);
		if(iterations == 1){
			iterations = 13;
			row++;
		}else{
			iterations--;
		}
	}
	if(initlist && initlist.length){
		for(var i = 0; i<initlist.length; i++){
			var pos = document.getElementById(initlist[i].position)
			var coordinates = pos.coords.split(",");
			var x = coordinates[0];
			var y = coordinates[1];
			createpiece(x,y,initlist[i].color,pos);
		}
	}
}

window.onbeforeunload = windowclose;
function windowclose(){
   byond("command","close");
}
