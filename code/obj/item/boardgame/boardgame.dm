/**
 * Defines, don't change these unless you have a good reason to do so.
 * Makes it easier to change the values later on and avoids typos.
 *
 * Most of these values are shared by both dm and tgui, so check both
 * areas when changing them.
 *
 *
 * A note from Github Copilot:
 */

#define MAP_TEXT_MOVE 0
#define MAP_TEXT_CAPTURE 1

#define DESIGN_CHECKERBOARD "checkerboard"

#define SOUND_MOVE "move"
#define SOUND_CAPTURE "capture"
#define SOUND_NEWGAME "newgame"

#define STYLING_TILECOLOR1 "tileColor1"
#define STYLING_TILECOLOR2 "tileColor2"
#define STYLING_OLDTILECOLOR1 "oldTileColor1"
#define STYLING_OLDTILECOLOR2 "oldTileColor2"
#define STYLING_BORDER "border"
#define STYLING_ASPECT "aspectRatio"
#define STYLING_NOTATIONS "useNotations"
#define STYLING_FLIPBUTTON "flipButton"

/**
 * # Boardgame
 */

/obj/item/boardgame
	name = "board game"
	desc = "A generic board game?"
	icon = 'icons/obj/items/gameboard.dmi'
	icon_state = "chessboard"

	flags = TGUI_INTERACTIVE
	w_class = W_CLASS_NORMAL
	two_handed = TRUE
	stamina_damage = 30
	stamina_cost = 20

	var/list/sounds = list(
		SOUND_MOVE = 'sound/impact_sounds/Wood_Tap.ogg',
		SOUND_CAPTURE = 'sound/effects/capture.ogg',
		SOUND_NEWGAME = 'sound/effects/sine_boop.ogg',
	)

	var/game = "chess"
	/// Used by TGUI to render a board design
	var/design = DESIGN_CHECKERBOARD

	/**
	 * Designate the size of the board
	 * Don't forget to update styling["aspectRatio"]
	 * if you want to keep the board autoscaling
	 */
	var/board_width = 8
	var/board_height = 8

	/// If true, pieces will be locked to the center of the tile they're on, otherwise they'll be free to move around
	var/lock_pieces_to_tile = TRUE

	/**
		* ## Boardgame styling
		* ```dm
		* src.styling[key] = value
		* ```
		*
		* Give the boardgame a custom look by using these key value pairs.
		*
		* ```dm
		* // Sets color of first tile
		* [STYLING_TILECOLOR1] = "#FFFFFF" or rgb(255, 255, 255)
		* ```
		*
		* ```dm
		* // Sets color of second tile
		* [STYLING_TILECOLOR2] = "#FFFFFF" or rgb(255, 255, 255)
		* ```
		*

		*
		* ```dm
		* // Sets color of the border
		* [STYLING_BORDER] = "#FFFFFF" or rgb(255, 255, 255)
		* ```
		*
		* ```dm
		* // Aspect ratio of the board. This is the ratio of the width to the height.
		* 1 = 1:1, 2 = 2:1, 0.5 = 1:2
		* [STYLING_ASPECT] = NUMBER
		* ```dm
		*
		* ```
		* // Whether to use chess-like notation around the board.
		* ...
		* [STYLING_NOTATIONS] = TRUE/FALSE
		* ````
		* The following keys are used by the boardgame itself and changes itself.
		* ```dm
		* // Sets original color of first tile
		* [STYLING_OLDTILECOLOR1] = "#FFFFFF" or rgb(255, 255, 255)
		* ```
		*
		* ```dm
		* // Sets original color of first tile
		* [STYLING_OLDTILECOLOR2] = "#FFFFFF" or rgb(255, 255, 255)
		* ```
		*/
	var/list/styling = list(
		STYLING_TILECOLOR1 = rgb(240, 217, 181),
		STYLING_OLDTILECOLOR1 = rgb(240, 217, 181),
		STYLING_OLDTILECOLOR2 = rgb(181, 136, 99),
		STYLING_TILECOLOR2 = rgb(181, 136, 99),
		STYLING_BORDER = rgb(131, 100, 74),
		STYLING_ASPECT = 1,
		STYLING_NOTATIONS = TRUE,
		STYLING_FLIPBUTTON = TRUE,
	)

	/**
	 * # Boardgame Data and State
	 */
	var/list/active_users = list()
	// Pieces layer
	var/list/pieces = list()
	var/list/lastMovedPiece = list()



	New()
		..()
		// Store old styling if there is any reason to reset the board
		src.styling[STYLING_OLDTILECOLOR1] = src.styling[STYLING_TILECOLOR1]
		src.styling[STYLING_OLDTILECOLOR2] = src.styling[STYLING_TILECOLOR2]

	/**
	 * Reset the board to its color scheme, in case it has been changed
	 */
	proc/resetColorStyling()
		src.styling[STYLING_TILECOLOR1] = src.styling[STYLING_OLDTILECOLOR1]
		src.styling[STYLING_TILECOLOR2] = src.styling[STYLING_OLDTILECOLOR2]

	proc/posToNotationString(x, y)
		// Convert a position to a chess notation string
		// eg. x:1, y:1 -> A1
		// if x > 26, it will use AA, AB, AC, etc.
		// Create a split list of the alphabet
		var/list/letters = splittext("ABCDEFGHIJKLMNOPQRSTUVWXYZ", "")
		var/letterBuffer = ""
		for(var/i = 1 to x)
			if (i % length(letters) == 0)
				letterBuffer += letters[length(letters)]
			else
				letterBuffer += letters[i % length(letters)]

		return "[letterBuffer][y]"

	proc/applyGNot(gnot)
		// Like FEN but comma seperated
		// Example GNOT of a 3x3 board: P,P,P,3,p,p,p the true length is 9

		// Clear the board
		src.pieces = list()

		// Split the string into a list
		var/list/gnot_pieces = splittext(gnot, ",")
		var/piece_index = 1 // Used to keep track of the piece we're on, a number increases it by that value
		for (var/piece in gnot_pieces)
			// If the piece is a number, increase the index by that number
			if (isnum(text2num_safe(piece)))
				// Get value of piece, string to number
				piece_index += text2num_safe(piece)
				continue
			// If the piece is a letter or string
			if (piece)
				// Get the x and y of the piece
				var/x = ((piece_index - 1) % board_width)
				var/y = round((piece_index - 1) / board_width)
				// Add the piece to the list
				src.createPiece(piece, x, y)
				// Increase the index by 1
				piece_index += 1

		playsound(src.loc, src.sounds[SOUND_NEWGAME], 30, 1)

	proc/uniquePieceId()
		// create a unique random id for a piece when adding it to the board
		var/id = ""
		while ((id == "") || (id in src.pieces))
			id = "[rand(1000, 99999)]"
		return id

	proc/createPiece(code, x, y)
		if (x < 0 || x >= src.board_width || y < 0 || y >= src.board_height)
			return

		// Delete any piece if there is one at the position
		src.removePieceAt(x, y)

		var/id = src.uniquePieceId()
		src.pieces[id] = list(
			"id" = id,
			"code" = code,
			"x" = x,
			"y" = y,
			"prevX" = x,
			"prevY" = y,
			"selected" = null, // Piece on the board selected
			"lastSelected" = null, // Last piece selected by the user
			"palette" = null, // Code of the palette
		)
		playsound(src.loc, src.sounds[SOUND_MOVE], 30, 1)


	proc/setPalette(ckey, code)
		// Clear selected piece
		if(src.active_users[ckey]["selected"])
			src.active_users[ckey]["selected"] = null
		src.active_users[ckey]["palette"] = code

	proc/clearPalette(ckey)
		src.active_users[ckey]["palette"] = null

	proc/getActivePalette(ckey)
		return src.active_users[ckey]["palette"]

	proc/getPieceById(id)
		return src.pieces[id]

	proc/removePiece(piece)
		src.pieces.Remove(piece)


	proc/removePieceById(piece)
		src.removePiece(src.getPieceById(piece))

	proc/removePieceAt(x, y)
		if (x < 0 || x >= src.board_width || y < 0 || y >= src.board_height)
			return

		var/newX = x
		var/newY = y

		if(src.lock_pieces_to_tile)
			newX = round(x)
			newY = round(y)

		for (var/piece in src.pieces)
			if (src.pieces[piece]["x"] == newX && src.pieces[piece]["y"] == newY)
				src.pieces.Remove(piece)
				return

	proc/selectPiece(ckey, pieceId)
		var/piece = src.getPieceById(pieceId)
		if(!piece)
			return
		src.active_users[ckey]["selected"] = pieceId
		src.pieces[pieceId]["selected"] = ckey

	proc/deselectPiece(ckey)
		// Check if ckey exists
		if (src.active_users[ckey])
			var/pieceId = src.active_users[ckey]["selected"]
			src.active_users[ckey]["selected"] = null
			if (pieceId)
				// Double check that the piece exists
				if (src.pieces[pieceId])
					src.pieces[pieceId]["selected"] = null


	proc/getPieceAt(x, y)

		for (var/id in src.pieces)
			var/list/piece = src.pieces[id]
			if (piece["x"] == x && piece["y"] == y)
				return piece
		return null

	proc/placePalette(ckey, x, y)
		if (x < 0 || x >= src.board_width || y < 0 || y >= src.board_height)
			return

		// Update old pos
		var/newX = x
		var/newY = y

		if(src.lock_pieces_to_tile)
			newX = round(x)
			newY = round(y)

		var/palette = src.active_users[ckey]["palette"]
		if (palette)
			// Remove any piece at the location
			src.removePieceAt(newX, newY)
			src.createPiece(palette, newX, newY)
			src.clearPalette(ckey)

		return

	proc/movePiece(piece, x, y)
		// Move piece
		if (x < 0 || x >= src.board_width || y < 0 || y >= src.board_height)
			return

		piece["prevX"] = piece["x"]
		piece["prevY"] = piece["y"]
		var/newX = x
		var/newY = y

		if(src.lock_pieces_to_tile)
			newX = round(x)
			newY = round(y)

		var/oldX = piece["prevX"]
		var/oldY = piece["prevY"]


		piece["lastSelected"] = piece["selected"]

		// Move the piece to the new tile
		piece["x"] = newX
		piece["y"] = newY

		var/user = src.active_users[piece["selected"]]
		var/moverName = user["name"]

		src.speakMapText(piece, oldX, oldY, newX, newY, MAP_TEXT_MOVE, moverName)
		src.lastMovedPiece = piece
		playsound(src.loc, src.sounds[SOUND_MOVE], 30, 1)

	proc/speakMapText(piece, newX, newY, oldX, oldY, mapTextType, captured=null)
		var/map_text = ""
		if(!piece) return // If the piece doesn't exist, return
		if(!piece["selected"]) return // If the piece isn't selected, return
		var/user = src.active_users[piece["selected"]]
		var/moverName = user["name"]
		var/prevPosString = src.posToNotationString(newX, newY)
		var/newPosString = src.posToNotationString(oldX, oldY)

		switch(mapTextType)
			if(MAP_TEXT_MOVE)
				map_text = "[moverName] moves [prevPosString] to [newPosString]!"
			if(MAP_TEXT_CAPTURE)
				if(captured)
					map_text = "[moverName] moves [prevPosString] to [newPosString] and captures [captured["code"]]!"

		var/map_text_final = make_chat_maptext(src, map_text, "color: #A8E9F0;", alpha = 150, time = 8)
		for (var/mob/O in hearers(src))
			O.show_message(assoc_maptext = map_text_final)

	proc/placeSelectedPiece(ckey, x, y)
		// Check if out of bounds
		if (x < 0 || x >= src.board_width || y < 0 || y >= src.board_height)
			return

		var/newX = x
		var/newY = y

		if(src.lock_pieces_to_tile)
			newX = round(x)
			newY = round(y)

		// Check if the user has a selected piece
		var/piece = src.getPieceById(src.active_users[ckey]["selected"])
		if (!piece)
			// How can you move a piece if you don't have one selected?
			// src.deselectPiece(ckey)
			return

		// Check if the pawn is moving to a tile that is already occupied
		var/occupied = src.getPieceAt(newX, newY)

		if (occupied)
			// Check if the piece is moving to a tile that is occupied by an enemy
			if (piece != occupied)
				// Capture the piece
				src.capturePieceAt(occupied, piece, newX, newY)
		else
			// The space is not occupied, move the piece
			src.movePiece(piece, newX, newY)

		// Deselect the piece
		src.deselectPiece(ckey)

	proc/capturePiece(piece, capturedby)
		//src.drawBoardIcon()
		if(!piece) return
		playsound(src.loc, src.sounds[SOUND_CAPTURE], 30, 1)
		src.removePieceById(piece)
		if(capturedby)
			src.speakMapText(capturedby, capturedby["x"], capturedby["y"], capturedby["prevX"], capturedby["prevY"], MAP_TEXT_CAPTURE, piece)
		src.movePiece(capturedby, capturedby["prevX"], capturedby["prevY"])

	proc/capturePieceAt(piece, capturedby, x, y)
		//src.drawBoardIcon()
		if(!piece) return
		playsound(src.loc, src.sounds[SOUND_CAPTURE], 30, 1)
		src.removePieceAt(x, y)
		if(capturedby)
			src.speakMapText(capturedby, capturedby["x"], capturedby["y"], capturedby["prevX"], capturedby["prevY"], MAP_TEXT_CAPTURE, piece)
		src.movePiece(capturedby, x, y)

	can_access_remotely(mob/user)
		. = can_access_remotely_default(user)

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)

		if(!src.active_users[user.ckey])
			src.active_users[user.ckey] = list(
				"ckey" = user.ckey,
				"name" = user.name,
				"selected" = null,
				"palette" = null,
			)

		if(!ui)
			ui = new(user, src, "Boardgame")
			ui.open()


	ui_static_data(mob/user)
		. = list()
		.["boardInfo"] = list(
			"name" = src.name,
			"game" = src.game,
			"design" = src.design,
			"width" = src.board_width,
			"height" = src.board_height,
			"lock" = src.lock_pieces_to_tile
		)


	ui_data(mob/user)
		. = list()
		.["pieces"] = src.pieces
		.["styling"] = src.styling
		.["users"] = src.active_users
		.["currentUser"] = src.active_users[user.ckey]
		.["lastMovedPiece"] = src.lastMovedPiece

	ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
		. = ..()
		if(. || !IN_RANGE(src, ui.user, 1))
			return
		switch(action)
			if("pieceCreate")
				var/code = params["code"]
				var/x = text2num(params["x"])
				var/y = text2num(params["y"])
				src.createPiece(code, x, y)
				. = TRUE
			if("pieceRemove")
				var/piece = params["piece"]
				src.removePiece(piece)
				. = TRUE
			if("pieceRemoveHeld")
				var/ckey = params["ckey"]
				var/piece = src.active_users[ckey]["selected"]
				src.deselectPiece(ckey)
				src.removePiece(piece)
				. = TRUE
			if("pieceSelect")
				var/ckey = params["ckey"]
				var/piece = params["piece"]
				src.selectPiece(ckey, piece)
				//src.removePiece
				. = TRUE
			if("pieceDeselect")
				var/ckey = params["ckey"]
				src.deselectPiece(ckey)
				. = TRUE
			if("piecePlace")
				// Place the pawn on the board currently selected
				var/ckey = params["ckey"]
				var/x = text2num(params["x"])
				var/y = text2num(params["y"])
				if(src.active_users[ckey]["selected"])
					src.placeSelectedPiece(ckey, x, y)
				else
					src.placePalette(ckey, x, y)
				. = TRUE
			if("applyGNot")
				var/gnot = params["gnot"]
				src.applyGNot(gnot)
				. = TRUE

			// Palette actions
			if("paletteSet")
				var/ckey = params["ckey"]
				var/code = params["code"]
				src.setPalette(ckey, code)
				. = TRUE

			if("paletteClear")
				var/ckey = params["ckey"]
				src.clearPalette(ckey)
				. = TRUE
			if("heldClear")
				var/ckey = params["ckey"]
				if(src.active_users[ckey]["selected"])
					src.deselectPiece(ckey)
				if(src.active_users[ckey]["palette"])
					src.clearPalette(ckey)
				. = TRUE

	ui_close(mob/user)
		src.active_users -= user.ckey
		. = ..()

	ui_status(mob/user, datum/ui_state/state)
		. = ..()
		if(. <= UI_CLOSE || !IN_RANGE(src, user, 10))
			return UI_CLOSE

	examine(mob/user)
		. = ..()
		if(IN_RANGE(src, user, 10))
			return src.ui_interact(user)

	mouse_drop(var/mob/user)
		if(user == usr && !user.restrained() && !user.stat && (user.contents.Find(src) || in_interact_range(src, user)))
			if(!user.put_in_hand(src))
				return ..()

	attack_hand(var/mob/user) // open browser window when board is clicked
		src.ui_interact(user)

	attack_ai(var/mob/user)
		return src.attack_hand(user)

	attackby(obj/item/W, mob/user, params)
		/// Check if the board is hit by a paint can
		if(istype(W, /obj/item/paint_can))
			var/obj/item/paint_can/can = W

			var/tileColour = STYLING_TILECOLOR1
			if(user.l_hand == can)
				tileColour = STYLING_TILECOLOR1
			else if(user.r_hand == can)
				tileColour = STYLING_TILECOLOR2
			else
				boutput(user, "<span class='warning'>You need to hold the paint can in your hand to use it!</span>")
				return


			//Check if the paint can is empty
			if(can.uses <= 0)
				boutput(user, "<span class='warning'>The paint can is empty!</span>")
				return

			//Apply the paint to the src.styling[tileColour]
			src.styling[tileColour] = can.paint_color
			// Reset filter to default, use custom styled board instead
			src.remove_filter("paint_color")
			can.uses--
		return

#undef MAP_TEXT_MOVE
#undef MAP_TEXT_CAPTURE

#undef PATTERN_CHECKERBOARD

#undef SOUND_MOVE
#undef SOUND_CAPTURE
#undef SOUND_NEWGAME

#undef STYLING_TILECOLOR1
#undef STYLING_TILECOLOR2
#undef STYLING_OLDTILECOLOR1
#undef STYLING_OLDTILECOLOR2
#undef STYLING_BORDER
#undef STYLING_ASPECT
#undef STYLING_NOTATIONS
