// CHESS PIECE LICENCE INFORMATION
// Source: https://en.wikipedia.org/wiki/User:Cburnett/GFDL_images/Chess
// Author: Cburnett
// Licenced under CC BY-SA 3.0
// Modified from original by DisturbHerb

var whitePieceList = [
	"{{resource("images/chessboard/kw.png")}}",
	"{{resource("images/chessboard/qw.png")}}",
	"{{resource("images/chessboard/bw.png")}}",
	"{{resource("images/chessboard/nw.png")}}",
	"{{resource("images/chessboard/rw.png")}}",
	"{{resource("images/chessboard/pw.png")}}",
];

var blackPieceList = [
	"{{resource("images/chessboard/kb.png")}}",
	"{{resource("images/chessboard/qb.png")}}",
	"{{resource("images/chessboard/bb.png")}}",
	"{{resource("images/chessboard/nb.png")}}",
	"{{resource("images/chessboard/rb.png")}}",
	"{{resource("images/chessboard/pb.png")}}",
];

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

Number.isInteger = Number.isInteger || function(value) { // fuck IE
	return typeof value === 'number' &&
	  isFinite(value) &&
	  Math.floor(value) === value;
  };

drawPiece = function(position, pieceType, pieceColor) { // file and rank start at zero, small-brain.
	var file = position % ranks, rank = Math.floor(position/ranks);
	var pieceImage = pieceType + pieceColor;
	var sourceString;
	switch(pieceColor){
		case whiteSide:
			var whitePieceListLen = whitePieceList.length;
			for(var i = 0; i < whitePieceListLen; i++){
				if((whitePieceList[i].search(pieceImage)) != -1){
					sourceString = whitePieceList[i];
					break;
				}
			}
		case blackSide:
			var blackPieceListLen = blackPieceList.length;
			for(var i = 0; i < blackPieceListLen; i++){
				if((blackPieceList[i].search(pieceImage)) != -1){
					sourceString = blackPieceList[i];
					break;
				}
			}
	}
	// this next part's gonna be a long one.
	pieceImageString = "<image src=\""+sourceString+"\" class=\'piece\' style=\'width: "+tileSize+"px; height: "+tileSize+"px; transform: translate("+(file*tileSize)+"px,"+(rank*tileSize)+"px);'>";
	$("#chesspieces").append(pieceImageString);
}

loadFEN = function(positionalFEN) { // FUCK YEAAAH YOU CAN IMPORT FEN STRINGS NOW!
	var positionalFEN = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR"; // starter FEN for testing
	var fenBoard = positionalFEN.split("");
	var selectedFile = 0, selectedRank = 0, selectedPieceType = 0, selectedPieceColor = 0;
	pieceList = Array.apply(null, Array(files*ranks));
	for(var i = 0; i < fenBoard.length; i++){
		if(fenBoard[i] == "/"){ // go to next rank at end of file
			selectedFile = 0;
			selectedRank++;
		} else if(Number.isInteger(parseInt(fenBoard[i]))){ // skip the number of spaces allotted by an integer in the FEN string
			selectedFile += parseInt(fenBoard[i]);
		} else {
			selectedPieceColor = (fenBoard[i] == fenBoard[i].toUpperCase()) ? whiteSide:blackSide; // set piece colour based on
			selectedPieceType = fenBoard[i].toLowerCase();
			pieceList[((selectedRank * ranks) + selectedFile)] = selectedPieceType + selectedPieceColor;
			selectedFile++;
		}
	}
	initialisePieces();
}

function initialisePieces() { // function for initialising chess pieces after... every... move.
	clearPieces();
	for(var i = 0; i < pieceList.length; i++){
		if(pieceList[i] != null) {
			var singlePieceArray = pieceList[i].split("");
			drawPiece(i, singlePieceArray[0], singlePieceArray[1]);
		}
	}
}

function clearPieces(){document.getElementById("chesspieces").innerHTML = "";}
