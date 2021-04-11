// globals and chess board drawing
var tileSize = 60;
var files = 8, ranks = 8;
var white = "#f0ce99", black = "#8a613f";
var whiteSide = "white", blackSide = "black";
var imagesPath = "{{resource('images/chessboard/)}}";
var notationOffset = 10;
var notationColor, notationTextStyle = "10px", weirdnessMultiplier = "5" // for whatever reason, some offsets have to be divided by this so it looks less weird. dunno why.

// piece handling and selection
var pieceList
var fromSpace, toSpace;
var selectionColor = "rgba(34, 139, 34, 0.7)", lastMoveColor = "rgba(255, 255, 0, 0.3)";
var selectionSquare, lastMoveFromPos, lastMoveToPos;

function byond() { // used for sending instructions to chess_board.dm
	url = "?src=" + srcRef;
	currentIsKey = true;
	for(let i = 0; i < arguments.length; i++) {
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
function drawBoard() {
	let canvas = document.getElementById('chessboard');
	let ctx = canvas.getContext('2d');
	for(let rank = 0; rank < ranks; ++rank) { // for each rank on the board
		for(let file = 0; file < files; ++file)	{ // for each file in the rank
			ctx.fillStyle = ((file+rank)%2==0) ? white:black; // ternary for setting colour based on board space even-ness
			ctx.fillRect((tileSize*file), (tileSize*rank), tileSize, tileSize);
			if((rank + 1)== ranks){
				let coordinateString = (String.fromCharCode((file) + 65));
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
	drawHighlights();
}

function drawHighlights(){ // draws the highlight squares when initialised
	clearCanvas("lastMoveSquares"); // clear selectionSquares canvas
	lastMoveFromPos = parseInt(lastmovejson[0]);
	lastMoveToPos = parseInt(lastmovejson[1]);
	drawSingleSquare(lastMoveFromPos, "lastMoveSquares", lastMoveColor);
	drawSingleSquare(lastMoveToPos, "lastMoveSquares", lastMoveColor);
}

function drawSingleSquare(squarePosition, selectedCanvas, selectedColor){ // draws a single square of a certain colour at a certain position on the board
	let drawSquareFile = squarePosition % ranks, drawSquareRank = Math.floor(squarePosition/ranks);
	let selectionCanvas = document.getElementById(selectedCanvas);
	let selectionctx = selectionCanvas.getContext('2d');
	selectionctx.fillStyle = selectedColor;
	selectionctx.fillRect((tileSize*drawSquareFile), (tileSize*drawSquareRank), tileSize, tileSize);
}

function clearCanvas(clrCanvas){ // clears the canvas used in the argument
	let clearCanvas = document.getElementById(clrCanvas);
	let clearctx = clearCanvas.getContext('2d');
	clearctx.clearRect(0, 0, clearCanvas.width, clearCanvas.height);
}

//////////////////PIECE DRAWING//////////////////
// CHESS PIECE LICENCE INFORMATION
// Source: https://en.wikipedia.org/wiki/User:Cburnett/GFDL_images/Chess
// Author: Cburnett
// Licenced under CC BY-SA 3.0
// Modified from original by DisturbHerb

// Draughts pieces drawn by DisturbHer

// following vars are how i have to import the piece images because i have no other choice
// these damn things make me want to *cry*
var pieceImageList = [
	"{{resource("images/chessboard/kingblack.png")}}",
	"{{resource("images/chessboard/queenblack.png")}}",
	"{{resource("images/chessboard/bishopblack.png")}}",
	"{{resource("images/chessboard/knightblack.png")}}",
	"{{resource("images/chessboard/rookblack.png")}}",
	"{{resource("images/chessboard/pawnblack.png")}}",
	"{{resource("images/chessboard/draughtsmanblack.png")}}",
	"{{resource("images/chessboard/kingwhite.png")}}",
	"{{resource("images/chessboard/queenwhite.png")}}",
	"{{resource("images/chessboard/bishopwhite.png")}}",
	"{{resource("images/chessboard/knightwhite.png")}}",
	"{{resource("images/chessboard/rookwhite.png")}}",
	"{{resource("images/chessboard/pawnwhite.png")}}",
	"{{resource("images/chessboard/draughtsmanwhite.png")}}"
];

Number.isInteger = Number.isInteger || function(value) { // fuck IE
	return typeof value === 'number' &&
	  isFinite(value) &&
	  Math.floor(value) === value;
  }

function drawPiece(position, pieceName) { // file and rank start at zero, small-brain.
	let file = position % ranks, rank = Math.floor(position/ranks);
	let sourceString;
	let pieceImageListLen = pieceImageList.length;
	for(let i = 0; i < pieceImageListLen; i++){
		if((pieceImageList[i].search(pieceName)) != -1){
			sourceString = pieceImageList[i];
			break;
		}
	}
	// this next part's gonna be a long one.
	let pieceImageString = "<image src=\""+sourceString+"\" class=\'piece\' style=\'width: "+tileSize+"px; height: "+tileSize+"px; transform: translate("+(file*tileSize)+"px,"+(rank*tileSize)+"px);'>";
	$("#chesspieces").append(pieceImageString);
}

function initialisePieces() { // function for initialising chess pieces after... every... move.
	clearPieces();
	console.log(pieceList);
	for(let i = 0; i < pieceList.length; i++){
		if(pieceList[i] != null) {
			drawPiece(i, pieceList[i]);
		}
	}
}

function clearPieces(){document.getElementById("chesspieces").innerHTML = "";}

//////////////////PIECE INTERACTION//////////////////
function processClick(event){
	var selectedSpace = getClickedPos(event);
	if(!Number.isInteger(selectedSpace)){ // if clicked space isn't valid
	clearCanvas("selectionSquares"); // clear selectionSquares canvas
			console.log("invalid space");
			return;
	}
	else if(fromSpace == null){
		if(!pieceList[selectedSpace]){
			clearCanvas("selectionSquares"); // clear selectionSquares canvas
			byond("command","checkHand","position",selectedSpace);
			return;
		}
		else{
			console.log("no fromSpace; processing movement");
			processMovement(selectedSpace);
		}
	}
	else{
		console.log("no toSpace/all other cases; processing movement");
		processMovement(selectedSpace);
	}
}

function processMovement(clickedPiece){ // fired on-click
	if(!Number.isInteger(fromSpace)){ // if no fromSpace has been selected prior, set clicked square to fromSpace
		fromSpace = clickedPiece;
		drawSingleSquare(clickedPiece, "selectionSquares", selectionColor); // draw selection square at selected position
		return;
	}
	else if(!Number.isInteger(toSpace)){ // if no toSpace has been selected, which, hm...
		toSpace = clickedPiece;
		if(toSpace == fromSpace){ // if toSpace and fromSpace are the same, revert everything
			fromSpace = null, toSpace = null;
			clearCanvas("selectionSquares"); // clear selectionSquares canvas
			return;
		}
		if(pieceList[toSpace]) // check if there's a piece on the square a piece is moving to
		{
			byond("command","capture","capturedPosition",toSpace); // send command to eject captured piece from board
		}
		pieceList[toSpace] = pieceList[fromSpace]; // change the piece positions in the array
		pieceList[fromSpace] = null;
		byond("command","changePos","fromPosition",fromSpace,"toPosition",toSpace); // communicates change in position to chess_board.dm
		fromSpace = null, toSpace = null; // reset letiables, time to start this again
	}
}

function deleteClickedPiece(event){ // deletes piece under cursor when fired
	let pieceToDelete = getClickedPos(event);
	clearCanvas("selectionSquares"); // clear selectionSquares canvas
	if(!pieceList[pieceToDelete]){
		return;
	}
	if(!Number.isInteger(pieceToDelete)){ // if clicked space isn't valid
		return;
	}
	byond("command","remove","position",pieceToDelete);
}

// get mouse position with event listeners
function getClickedPos(event) {
	event = event || window.event;
	let boardX = (event.pageX - $('#chessboard').offset().left);
	let boardY = (event.pageY - $('#chessboard').offset().top);
	if(boardX < 0 || boardX > (files*tileSize)|| boardY < 0 || boardY > (ranks*tileSize)){
		return;
	}
	let clickedFile = Math.floor(boardX/tileSize);
	let clickedRank = Math.floor(boardY/tileSize);
	let clickedSpace = ((clickedRank * files) + clickedFile);
	return clickedSpace;
}

////////////////////////////////////////////////////////////////////////
window.onload = function() {
	document.body.scroll="no";
	byond("command","bodge"); // bodge o'clock! it's a glorified fucking sanity check, because i'm going insane
	drawBoard(); // draws the board
	initialisePieces(); // draws the pieces on the board
	document.addEventListener("click", function(event){ // event listener that triggers when the board is clicked
		processClick(event);
	});
	document.addEventListener("contextmenu", function(event){ // event listener that triggers upon right-clicking to facilitate piece deletion
		deleteClickedPiece(event);
		event.preventDefault();
	});
}

window.onunload = function() { // tells BYOND to remove the player from the list of users viewing the board, which SHOULD work if the sanity check doesn't pass
  byond("command","close");
}
