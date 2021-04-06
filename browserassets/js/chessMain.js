window.onload = function() {
	document.body.scroll="no";
	drawBoard();
}

loadFEN(); // starting FEN for testing

// event listeners that trigger when an piece is dragged and when a piece is dropped. or, at least, they're meant to!
document.addEventListener("dragstart", function(event){
	processMovement(event);
});
document.addEventListener("dragover", function(event){event.preventDefault();});
document.addEventListener("drop", function(event){
    processMovement(event);
    event.preventDefault();
});
