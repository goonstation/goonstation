// CHESS PIECE LICENCE INFORMATION
// Source: https://en.wikipedia.org/wiki/User:Cburnett/GFDL_images/Chess
// Author: Cburnett
// Licenced under CC BY-SA 3.0
// Modified from original by DisturbHerb

var chessboardID = "chessboard"
var tileSize = 60;
var files = 8, ranks = 8;
var white = "#f0ce99", black = "#8a613f";
var whiteSide = "W", blackSide = "B";
var notationOffset = 10;
var notationColor, notationTextStyle = "10px", weirdnessMultiplier = "5" // for whatever reason, some offsets have to be divided by this so it looks less weird. dunno why.
// DEBUG
var pieceImageString

function byond() { // i have no idea what this does.
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

/* createPiece = function(position, pieceColor, pieceType) { // file and rank start at zero, small-brain.
	var file = position % ranks, rank = Math.floor(position/ranks);
	var pieceCanvas = document.getElementById('chesspieces');
	var piecectx = pieceCanvas.getContext('2d');
	var pieceImage = new Image();
	pieceImage.onload = function() {
		piecectx.drawImage(pieceImage, ((tileSize)*file), ((tileSize)*rank), tileSize, tileSize);
	}
	var pieceFileName = pieceType + pieceColor
	pieceImage.src = ('{{resource("images/chessboard/' + pieceFileName + '.png")}}'); // ugh FUCK
} */

drawPiece = function(position, pieceColor, pieceType) { // file and rank start at zero, small-brain.
	var file = position % ranks, rank = Math.floor(position/ranks);
	var pieceImage = pieceType + pieceColor;
	// this next part's gonna be a long one.
	// DEBUG PLEASE IGNORE
	// <image src="{{resource("images/chessboard/bb.png")}}" class='piece' style='width: 60px; height: 60px; transform: translate(0px,0px);'>
	// <image src="{{resource("images/chessboard/bb.png")}}" class='piece' style='width: 80px; height: 80px; transform: translate(60px,60px);'>
	//var text = "&lt;image src=\"{{resource(\"images/chessboard/"+pieceImage+".png\")}}\" class=\'piece\' style=\'width: "+tileSize+"px; height: "+tileSize+"px; transform: translate("+(file*tileSize)+"px,"+(rank*tileSize)+"px);'&gt;";
	//document.getElementById("debug").innerHTML = text;
	pieceImageString = "<image src=\""+imagesPath+pieceImage+".png\")}}\" class=\'piece\' style=\'width: "+tileSize+"px; height: "+tileSize+"px; transform: translate("+(file*tileSize)+"px,"+(rank*tileSize)+"px);'>";
	$("#chesspieces").append(pieceImageString);
}

Number.isInteger = Number.isInteger || function(value) { // fuck IE
	return typeof value === 'number' &&
	  isFinite(value) &&
	  Math.floor(value) === value;
  };

drawBoard = function() {
	var canvas = document.getElementById('chessboard');
	var ctx = canvas.getContext('2d');
	for(var rank = 0; rank < ranks; ++rank) { // for each rank on the board
		for(var file = 0; file < files; ++file)	{ // for each file in the rank
			ctx.fillStyle = ((file+rank)%2==0) ? white:black; // ternary for setting colour based on board space even-ness
			ctx.fillRect((tileSize*file), (tileSize*rank), tileSize, tileSize);
			if((rank + 1)== ranks){
				var coordinateString = (String.fromCharCode((file) + 65));
				notationColor = ((file) % 2 == 0)? white:black;
				ctx.fillStyle = notationColor;
				ctx.font = notationTextStyle;
				ctx.fillText(coordinateString.toLowerCase(), ((file * tileSize) + tileSize - notationOffset), ((ranks * tileSize) - (notationOffset/weirdnessMultiplier)));
			}
		}
		notationColor = ((rank + 1) % 2 == 0)? white:black;
		ctx.fillStyle = notationColor;
		ctx.font = notationTextStyle;
		ctx.fillText(String(ranks - rank), (notationOffset/weirdnessMultiplier), ((rank * tileSize) + notationOffset)); // places algebraic values for ranks
	}
}

loadFEN = function(positionalFEN) { // FUCK YEAAAH YOU CAN IMPORT FEN STRINGS NOW!
	var fenBoard = positionalFEN.split("");
	var selectedFile = 0, selectedRank = 0, selectedPieceType = 0, selectedPieceColor = 0;
	for(var i = 0; i < fenBoard.length; i++){
		if(fenBoard[i] == "/"){ // go to next rank at end of file
			selectedFile = 0;
			selectedRank++;
		} else if(Number.isInteger(parseInt(fenBoard[i]))){ // skip the number of spaces allotted by an integer in the FEN string
			selectedFile += parseInt(fenBoard[i]);
		} else {
			selectedPieceColor = (fenBoard[i] == fenBoard[i].toUpperCase()) ? whiteSide:blackSide; // set piece colour based on
			selectedPieceType = fenBoard[i].toLowerCase();
			drawPiece((selectedFile + (selectedRank * files)), selectedPieceColor, selectedPieceType);
			selectedFile++;
		}
	}
}

window.onload = function() {
	document.body.scroll="no";
	drawBoard();
}

//loadFEN("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR"); // starting FEN for testing
drawPiece(0, "b", "b");
