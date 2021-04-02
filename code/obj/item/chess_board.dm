/obj/item/chessboard
	name = "chess board"
	desc = "It's a board for playing chess! Or checkers... Or anything that uses an 8x8 checkered board..."
	icon = 'icons/obj/items/chess.dmi'
	icon_state = "chessboard"
	var/list/openwindows = list()
	var/list/piecelist = list()

	proc/uiSetup()
		usr.Browse((grabResource("html/chess.htm")), "window=chess;size=595x595;border=0;can_resize=0;can_minimize=1;")

	attack_hand(mob/user as mob)
		if(!(user in src.openwindows) && istype(user,/mob/living/carbon/human) && !(src in user.contents))
			src.openwindows.Add(user)
		uiSetup()

	MouseDrop(mob/user as mob) // because picking up the board is cool
		if((istype(user,/mob/living/carbon/human))&&(!user.stat)&&!(src in user.contents))
			user.put_in_hand_or_drop(src)

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
	name = "STOP LOOKING AT ME"
	desc = "if you see this, everything has gone disastrously wrong, please send a bug report."
	icon = 'icons/obj/items/chess.dmi'
	var/affinity //black or white, for setting the piece colour dispensed by a box
	var/spawnType
	var/outputTarget

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
		box.desc = "A wooden box designed to contain [box.affinity] pieces for chess and checkers."
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
		chessActions += new /datum/contextAction/chess/grabBox
		chessActions += new /datum/contextAction/chess/closeBox
		chessActions += new /datum/contextAction/chess/close

	proc/checkEmpty(var/mob/user) // return if box is empty
		if(contents.len <= 0)
			boutput(user, "The box is completely empty!")
			return true

	proc/pieceInput(var/mob/user)
		if(!isnull(checkEmpty()))
			return
		else
			// create an alphabeticall sorted list of pieces in the box
			var/list/pieceListSorted = sortNames(contents)
			pieceListSorted.Add("CANCEL")
			var/selectedType = input(user,"Pick a piece type:","CHEEEESS") in pieceListSorted
			return selectedType

	proc/ejectPiece(var/obj/spawnedPiece, var/mob/user)
		if(isnull(outputTarget))
			user.put_in_hand_or_eject(spawnedPiece)
		else
			spawnedPiece.set_loc(outputTarget)

	proc/grabPiece(var/mob/user, var/obj/item/chessman/piece)
		if(!isnull(checkEmpty()))
			return
		else
			piece = pieceInput(user)
			if(piece == "CANCEL")
				return true
			// return if you walk away >:(
			if(!in_interact_range(src, user))
				return true
			for(var/i in 1 to contents.len)
				if(piece == contents[i].name)
					ejectPiece(contents[i], user)
					src.visible_message("[user] removes the [piece] from the [src.name].")
					return

	proc/grabSet(var/mob/user,chosenSet)
		if(!isnull(checkEmpty()))
			return true
		else
			var/pieceFound
			for(var/i in 1 to contents.len)
				if((contents[i].name != "[affinity] draughtsman" && chosenSet == "chess") || (contents[i].name == "[affinity] draughtsman" && chosenSet == "draughts"))
					ejectPiece(contents[i], user)
					pieceFound = true
					break
			if(pieceFound == true)
				return
			else
				return true

	proc/grabOne(var/mob/user)
		grabPiece(user)
		setExamine(src)

	proc/grabMany(var/mob/user)
		while(isnull(grabPiece(user)))
			setExamine(src)

	proc/grabChess(var/mob/user)
		while(isnull(grabSet(user,chosenSet = "chess")))
		setExamine(src)
		src.visible_message("[user] removes all of the remaining chessmen from [src.name].")

	proc/grabDraughts(var/mob/user)
		while(isnull(grabSet(user,chosenSet = "draughts")))
		setExamine(src)
		src.visible_message("[user] removes all of the remaining draughtsmen from [src.name].")

	proc/grabBox(mob/user as mob) // because picking up boxes is cool HA HA FUCK YOU, MAKE A CONTEXT ACTION
		if((istype(user,/mob/living/carbon/human))&&(!user.stat)&&!(src in user.contents))
			user.put_in_hand_or_drop(src)

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

		// update and show context actions
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
				src.visible_message("[user] places [piece.name] in the [src.name].")

	MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob) //handles piling pieces into a chessbox
		if(istype(O,/obj/item/chessman))
			user.visible_message("[user.name] scoops pieces into the [src.name]!")
			SPAWN_DBG(0.05 SECONDS)
				for(var/obj/item/chessman/piece in range(1, user))
					if(piece.pieceAffinity != affinity)
						continue
					if(piece.loc == user)
						user.u_equip(piece)
					piece.set_loc(src)
					sleep(0.05 SECONDS)
					setExamine(src)

	MouseDrop(over_object, src_location, over_location)
		if(!istype(usr,/mob/living/))
			boutput(usr, "<span class='alert'>Only living mobs are able to set the output target for [src].</span>")
			return

		if(get_dist(over_object,src) > 1)
			src.outputTarget = null
			boutput(usr, "<span class='alert'>[src] is too far away from the target!</span>")
			return

		if(get_dist(over_object,usr) > 1)
			boutput(usr, "<span class='alert'>You are too far away from the target!</span>")
			return

		if(istype(over_object,/obj/table/) || istype(over_object,/obj/rack/))
			var/obj/O = over_object
			src.outputTarget = O.loc
			boutput(usr, "<span class='notice'>You set [src] to output on top of [O]!</span>")
			return

		if(istype(over_object,/turf) && !over_object:density)
			src.outputTarget = over_object
			boutput(usr, "<span class='notice'>You set [src] to output to [over_object]!</span>")
			return

		if(istype(over_object,usr))
			src.outputTarget = null
			boutput(usr, "<span class='notice'>You will now pick up pieces from [src] normally!</span>")
			return

		else
			boutput(usr, "<span class='alert'>You can't use that as an output target.</span>")
		return

	proc/getOutputLocation() // returns a location to output tiles if the user's hands are full
		if (!src.outputTarget)
			return src.loc
		if (get_dist(src.outputTarget,src) > 1) // if outputTarget is more than 1 tile away from the box
			src.outputTarget = null
			return src.loc
		if(get_dist(usr,src > 1)) // if outputTarget is more than 1 tile away from the user
			src.outputTarget = null
			return src.loc
		if (istype(src.outputTarget,/turf/simulated/floor/)) // if outputTarget is over a floor
			return src.outputTarget
		else
			return src.loc

	black
		name = "black chess box"
		affinity = "black"

	white
		name = "white chess box"
		affinity = "white"
