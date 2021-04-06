// globals and chess board drawing
var tileSize = 60;
var files = 8, ranks = 8;
var white = "#f0ce99", black = "#8a613f";
var whiteSide = "w", blackSide = "b";
var notationOffset = 10;
var notationColor, notationTextStyle = "10px", weirdnessMultiplier = "5" // for whatever reason, some offsets have to be divided by this so it looks less weird. dunno why.

// piece handling and selection
var pieceList = Array.apply(null, Array(files*ranks)); // sets array of length 64 with all values set to null
var fromSpace = null, toSpace = null;
var selectionColor = "rgba(34, 139, 34, 0.3)", lastMoveColor = "rgba(255, 255, 0, 0.3)";
