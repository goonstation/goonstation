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
