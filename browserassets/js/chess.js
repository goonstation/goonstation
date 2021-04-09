// globals and chess board drawing
var tileSize = 60;
var files = 8, ranks = 8;
var white = "#f0ce99", black = "#8a613f";
var whiteSide = "w", blackSide = "b";
var imagesPath = "{{resource('images/chessboard/)}}";
var notationOffset = 10;
var notationColor, notationTextStyle = "10px", weirdnessMultiplier = "5" // for whatever reason, some offsets have to be divided by this so it looks less weird. dunno why.

// piece handling and selection
var pieceList = Array.apply(null, Array(files*ranks)); // sets array of length 64 with all values set to null
var fromSpace = null, toSpace = null;
var selectionColor = "rgba(34, 139, 34, 0.3)", lastMoveColor = "rgba(255, 255, 0, 0.3)";

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

//////////////////BOARD DRAWING//////////////////

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

//////////////////PIECE DRAWING//////////////////
// CHESS PIECE LICENCE INFORMATION
// Source: https://en.wikipedia.org/wiki/User:Cburnett/GFDL_images/Chess
// Author: Cburnett
// Licenced under CC BY-SA 3.0
// Modified from original by DisturbHerb

// following vars are how i have to import the piece images because i have no other choice
// these damn things make me want to *cry*
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

Number.isInteger = Number.isInteger || function(value) { // fuck IE
	return typeof value === 'number' &&
	  isFinite(value) &&
	  Math.floor(value) === value;
  };

drawPiece = function(position, pieceType, pieceColor) { // file and rank start at zero, small-brain.
	var file = position % ranks, rank = Math.floor(position/ranks);
	var pieceImage = pieceType + pieceColor;
	var sourceString;
	switch(pieceColor){ // both cases check the piece type and piece colour given, and they draw the pieces to the board. it's terrible code, and i want to cry.
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

//THIS FUNCTION IS PRIMARILY USED FOR DEBUGGING PURPOSES AND TESTING HOW PIECES ARE DISPLAYED ON THE BOARD//
loadFEN = function(positionalFEN) {
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

//////////////////PIECE INTERACTION//////////////////
function processMovement(event){ // fired on-click
	var selectedSpace = getClickedPos(event);
	if(!Number.isInteger(selectedSpace)){ // if clicked space isn't valid
		return;
	} else if(!Number.isInteger(fromSpace)){ // if no fromSpace has been selected prior, set clicked square to fromSpace
		fromSpace = selectedSpace;
		if(!pieceList[fromSpace]){ // if clicked space is empty, return and set fromSpace to null
			fromSpace = null;
			return;
		}
		drawSingleSquare(parseInt(fromSpace), "selectionSquares", selectionColor); // draw selection square at fromSpace position
		return;
	} else if(!Number.isInteger(toSpace)){ // if no toSpace has been selected, which, hm...
		toSpace = selectedSpace;
		clearCanvas("selectionSquares"); // clear selectionSquares canvas
		if(toSpace == fromSpace){ // if toSpace and fromSpace are the same, revert everything
			fromSpace = null, toSpace = null;
			return;
		}
		pieceList[toSpace] = pieceList[fromSpace]; // change the piece positions in the array
		pieceList[fromSpace] = null;
		handleLastMoveSquare(fromSpace, toSpace); // draw highlights for last move made
		initialisePieces(); // redraw pieces on the board
		fromSpace = null, toSpace = null; // reset variables, time to start this again
	}
}

function deleteClickedPiece(event){ // deletes piece under cursor when fired
	var selectedSpace = getClickedPos(event);
	if(!Number.isInteger(selectedSpace)){ // if clicked space isn't valid
		return;
	}
	pieceList[selectedSpace] = null;
	clearCanvas("selectionSquares"); // clear selectionSquares canvas
	clearCanvas("lastMoveSquares"); // clear selectionSquares canvas
	initialisePieces();
}

function handleLastMoveSquare(lastFrom, lastTo){ // draw highlights for last move made
	clearCanvas("lastMoveSquares")
	drawSingleSquare(lastFrom, "lastMoveSquares", lastMoveColor);
	drawSingleSquare(lastTo, "lastMoveSquares", lastMoveColor);
}

function drawSingleSquare(squarePosition, selectedCanvas, selectedColor){ // draws a single square of a certain colour at a certain position on the board
	var drawSquareFile = squarePosition % ranks, drawSquareRank = Math.floor(squarePosition/ranks);
	var selectionCanvas = document.getElementById(selectedCanvas);
	var selectionctx = selectionCanvas.getContext('2d');
	selectionctx.fillStyle = selectedColor;
	selectionctx.fillRect((tileSize*drawSquareFile), (tileSize*drawSquareRank), tileSize, tileSize);
}

function clearCanvas(clrCanvas){ // clears the canvas used in the argument
	var clearCanvas = document.getElementById(clrCanvas);
	var clearctx = clearCanvas.getContext('2d');
	clearctx.clearRect(0, 0, clearCanvas.width, clearCanvas.height);
}

// get mouse position with event listeners
function getClickedPos(event) {
	event = event || window.event;
	var boardX = (event.pageX - $('#chessboard').offset().left);
	var boardY = (event.pageY - $('#chessboard').offset().top);
	if(boardX < 0 || boardX > (files*tileSize)|| boardY < 0 || boardY > (ranks*tileSize)){
		return;
	}
	var clickedFile = Math.floor(boardX/tileSize);
	var clickedRank = Math.floor(boardY/tileSize);
	var clickedSpace = ((clickedRank * files) + clickedFile);
	return clickedSpace;
}

window.onload = function() {
	document.body.scroll="no";
	drawBoard();
	//loadFEN("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR"); // starting FEN for testing
	document.addEventListener("click", function(event){ // event listener that triggers when the board is clicked
		processMovement(event);
	});
	document.addEventListener("contextmenu", function(event){ // event listener that triggers upon right-clicking to facilitate piece deletion
		deleteClickedPiece(event);
		event.preventDefault();
	});
}
