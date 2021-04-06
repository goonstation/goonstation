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

function handleLastMoveSquare(lastFrom, lastTo){
	clearCanvas("lastMoveSquares")
	drawSingleSquare(lastFrom, "lastMoveSquares", lastMoveColor);
	drawSingleSquare(lastTo, "lastMoveSquares", lastMoveColor);
}

function drawSingleSquare(squarePosition, selectedCanvas, selectedColor){
	var drawSquareFile = squarePosition % ranks, drawSquareRank = Math.floor(squarePosition/ranks);
	var selectionCanvas = document.getElementById(selectedCanvas);
	var selectionctx = selectionCanvas.getContext('2d');
	selectionctx.fillStyle = selectedColor;
	selectionctx.fillRect((tileSize*drawSquareFile), (tileSize*drawSquareRank), tileSize, tileSize);
}

function clearCanvas(clrCanvas){
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
