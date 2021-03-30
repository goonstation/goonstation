/obj/item/chessboard
	name = "chess board"
	desc = "It's a board for playing chess! Or checkers... Or anything that uses an 8x8 checkered board..."
	icon = 'icons/obj/items/chess.dmi'
	icon_state = "chessboard"

/obj/item/chessman
	name = "chessman"
	desc = "A game piece for an 8x8 checkered board."
	icon = 'icons/obj/items/chess.dmi'
	icon_state = "king" // by default, otherwise there's n o t h i n g
	w_class = 1
	var/pieceAffinity // black, white
	var/pieceType // king, queen, bishop, etc.
	var/pieceName // string for naming a piece based on colour and type

	proc/setPieceInfo()
		// determining piece colour based on pieceAffinity
		switch(pieceAffinity)
			if("white")
				color = "#ffe39d"
			else
				color = "#815642"

		// determining piece name based on pieceAffinity and pieceType
		if(pieceAffinity in list("black", "white"))
			if(pieceType in list("king", "queen", "bishop", "knight", "rook", "pawn", "draughtsman"))
				icon_state = "[pieceType]"
				name = "[pieceAffinity] [pieceType]"
		else
			icon_state = "king"
			name = "broken chessman"
		..()

/obj/item/chessbox
	name = "chessmen box"
	desc = "if you see this, everything has gone disastrously wrong, please send a bug report."
	icon = 'icons/obj/items/chess.dmi'
	var/affinity //black or white, for setting the piece colour dispensed by a box
	var/spawnType
	var/pieceTotal

	var/list/boxContents
	var/list/possiblePieces = list("king","queen","bishop","knight","rook","pawn","draughtsman")

	proc/spawnPiece(spawnType)
		var/obj/item/chessman/piece = new
		piece.pieceAffinity = "[affinity]" // sets created piece affinity
		piece.pieceType = "[spawnType]" // sets created piece type
		piece.setPieceInfo(src) // set piece information based on box and type
		piece.set_loc(src)

	New() // sets piece numbers and icon state on instantiaion
		icon_state = "[affinity]box"
		boxContents = list(1,2,2,2,2,8,12)

		// spawns in the piece numbers based on boxContents
		var/pieceTypeAmount
		for(var/i in 1 to boxContents.len) // for every item in the boxContents list
			pieceTypeAmount = boxContents[i]
			for(var/j in 1 to pieceTypeAmount) // for the number of pieces of a single type
				spawnPiece(possiblePieces[i])

		pieceTotal = contents.len

	attack_self(mob/user as mob)
		if(icon_state == "[affinity]box")
			icon_state = "[affinity]box-open"
		else
			icon_state = "[affinity]box"

	attack_hand(mob/user as mob)
		// return if box is empty
		if(pieceTotal == 0)
			boutput(user, "The box is completely empty!")
			return

		// open box if closed
		if(icon_state == "[affinity]box")
			icon_state = "[affinity]box-open"

		// grabbing pieces from the box
		var/selectedType = input(usr,"Pick a piece type:","CHEEEESS") in possiblePieces
		var/wasPieceDrawn = 0 // probably really amateurish but i gotta have that condition SOMEHOW
		for(var/i in 1 to contents.len)	// hellish for loop for iterating through every entry in the box contents to find your dang piece
			if("[src.affinity] [selectedType]" == contents[i].name)
				user.put_in_hand_or_drop(contents[i])
				src.visible_message("[usr] removes a [affinity] [selectedType] from the [affinity] chess box.")
				wasPieceDrawn = 1
				return
		if(wasPieceDrawn != 1)
			boutput(user, "The box doesn't have another [selectedType]!")
			return

	attackby(var/obj/item/W, var/mob/user)
		// check chess piece for correct affinity, then places it into box's contents
		if(istype(W,/obj/item/chessman))
			if(findtext(W.name,src.affinity))
				user.u_equip(W)
				W.set_loc(src)
				src.visible_message("[usr] places a [W] in the [affinity] chess box.")
			else
				boutput(user, "That doesn't belong in this box!")

	MouseDrop(mob/user as mob) // because picking up boxes is cool
		if((istype(user,/mob/living/carbon/human))&&(!user.stat)&&!(src in user.contents))
			user.put_in_hand_or_drop(src)

	// black box
	black
		name = "black chess box"
		desc = "An ornate wooden box containing black pieces for chess and checkers."
		affinity = "black"

	white
		name = "white chess box"
		desc = "An ornate wooden box containing white pieces for chess and checkers."
		affinity = "white"
