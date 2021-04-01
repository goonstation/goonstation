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

/obj/item/chessbox
	name = "chessmen box"
	desc = "if you see this, everything has gone disastrously wrong, please send a bug report."
	icon = 'icons/obj/items/chess.dmi'
	var/affinity //black or white, for setting the piece colour dispensed by a box
	var/spawnType

	// context menu vars
	contextLayout = new /datum/contextLayout/instrumental(16)
	var/list/datum/contextAction/chessActions

	// box contents and the pieces that are spawned
	var/list/boxContents
	var/list/possiblePieces = list("king","queen","bishop","knight","rook","pawn","draughtsman")

	proc/closeBox()
		icon_state = "[affinity]box"

	proc/spawnPiece(spawnType)
		var/obj/item/chessman/piece = new
		piece.pieceAffinity = "[affinity]" // sets created piece affinity
		piece.pieceType = "[spawnType]" // sets created piece type
		piece.setPieceInfo(src) // set piece information based on box and type
		piece.set_loc(src)

	/proc/setExamine(var/obj/item/chessbox/box)
		box.desc = "An ornate wooden box designed to contain [box.affinity] pieces for chess and checkers."
		if(box.contents.len <= 0)
			box.desc = "[box.desc] There is nothing in it."
		else
			box.desc = "[box.desc] It contains [box.contents.len] pieces."

	proc/updateChessActions() // the name of this proc is very apt.
		chessActions = list()
		chessActions += new /datum/contextAction/chess/takeOne
		chessActions += new /datum/contextAction/chess/takeMultiple
		chessActions += new /datum/contextAction/chess/dispenseChess
		chessActions += new /datum/contextAction/chess/dispenseDraughts
		chessActions += new /datum/contextAction/chess/closeBox
		chessActions += new /datum/contextAction/chess/close

	proc/grabPiece()
		// return if box is empty
		if(contents.len <= 0)
			boutput(usr, "The box is completely empty!")
			return false

		// create an alphabeticall sorted list of pieces in the box
		var/list/pieceListSorted = sortNames(contents)
		pieceListSorted.Add("CANCEL")
		var/selectedType = input(usr,"Pick a piece type:","CHEEEESS") in pieceListSorted
		if(selectedType == "CANCEL")
			return false
		// return if you walk away >:(
		else if(!in_interact_range(src, usr))
			return false

		for(var/i in 1 to contents.len)
			if(selectedType == contents[i].name)
				usr.put_in_hand_or_drop(contents[i])
				src.visible_message("[usr] removes the [selectedType] from the [src.name].")
				if(contents.len <=0 ) // bodge because FUCK
					return false
				else
					return

	proc/grabOne()
		grabPiece()
		setExamine(src)

	proc/grabMany()
		while(grabPiece() == null)
			grabPiece()
		setExamine(src)

	proc/grabChess()

	proc/grabDraughts()

	New() // sets piece numbers and icon state on instantiaion
		..()
		icon_state = "[affinity]box"
		boxContents = list(1,2,2,2,2,8,12)

		// spawns in the piece numbers based on boxContents
		var/pieceTypeAmount
		for(var/i in 1 to boxContents.len) // for every item in the boxContents list
			pieceTypeAmount = boxContents[i]
			for(var/j in 1 to pieceTypeAmount) // for the number of pieces of a single type
				spawnPiece(possiblePieces[i])

		setExamine(src)

	attack_hand(mob/user as mob)
		// open box if closed
		if(icon_state == "[affinity]box")
			icon_state = "[affinity]box-open"

		updateChessActions()
		user.showContextActions(chessActions, src)

	attackby(var/obj/item/chessman/piece, var/mob/user)
		// check chess piece for correct affinity, then places it into box's contents
		if(istype(piece,/obj/item/chessman))
			if(piece.pieceAffinity != affinity)
				boutput(user, "That doesn't belong in this box!")
				return
			else
				user.u_equip(piece)
				piece.set_loc(src)
				src.visible_message("[usr] places [piece.name] in the [src.name].")

	MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob) //handles piling pieces into a chessbox
		if(istype(O,/obj/item/chessman))
			user.visible_message("[user.name] scoops chess pieces into the [src.name]!")
			SPAWN_DBG(0.05 SECONDS)
				for(var/obj/item/chessman/piece in range(1, user))
					if(piece.pieceAffinity != affinity)
						continue
					if(piece.loc == user)
						user.u_equip(piece)
					piece.set_loc(src)
					sleep(0.05 SECONDS)

	MouseDrop(mob/user as mob) // because picking up boxes is cool
		if((istype(user,/mob/living/carbon/human))&&(!user.stat)&&!(src in user.contents))
			user.put_in_hand_or_drop(src)

	// black box
	black
		name = "black chess box"
		affinity = "black"

	white
		name = "white chess box"
		affinity = "white"
