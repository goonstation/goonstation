/obj/item/boardgame
	name = "game board"
	desc = "A generic game board?"
	icon = 'icons/obj/items/gameboard.dmi'
	icon_state = "chessboard"
	flags = TGUI_INTERACTIVE
	w_class = W_CLASS_NORMAL
	two_handed = TRUE
	stamina_damage = 30
	stamina_cost = 20

	var/list/sounds = list(
		"move" = 'sound/impact_sounds/Wood_Tap.ogg',
		"capture" = 'sound/effects/capture.ogg',
		"newgame" = 'sound/effects/sine_boop.ogg',
	)

	var/game = "chess"
	var/pattern = "checkerboard"

	var/board_width = 8
	var/board_height = 8

	// Customizable board
	var/icon/cb = null
	var/use_cb = FALSE // Whether to use the custom board icon or not
	var/cb_xoffset = 2 // Offset everything by this much
	var/cb_yoffset = 2 // Offset everything by this much
	var/cb_tsize = 3 // 3x3 pixels per tile
	var/cb_pad = 4 // 4 pixels of padding around the board
	var/cb_clr_out = rgb(86, 63,43) // Outline color
	var/cb_clr_bot = rgb(69,42,31) // Bottom color
	var/cb_mrg_bot = 1 // Bottom margin in pixels

	var/lock_pieces_to_tile = TRUE // If true, pieces will be locked to the center of the tile they're on, otherwise they'll be free to move around

	/// Apply custom styling, matches both in dm and tgui releated code
	var/list/styling = list(
		"tileColour1" = rgb(240, 217, 181),
		"tileColour2" = rgb(181, 136, 99),
		"border" = rgb(131, 100, 74),
		"aspectRatio" = 1, // 1 to 1 ratio, used for auto resizing, FALSE to disable
		"useNotations" = TRUE, // Whether to use chess-like notation or not
	)

	// Game state data
	var/list/active_users = list()
	var/list/pieces = list()

	proc/posToNotationString(x, y)
		// Convert a position to a chess notation string
		// eg. 1, 1 -> A1

		// Create a split list of the alphabet
		var/list/letters = splittext("ABCDEFGHIJKLMNOPQRSTUVWXYZ", "")
		return "[letters[x+1]][board_height - y]"



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

		playsound(src.loc, src.sounds["newgame"], 30, 1)

	proc/uniquePieceId()
		// create a unique random id for a piece when adding it to the board
		var/id = ""
		while ((id == "") || (id in src.pieces))
			id = "[rand(1000, 99999)]"
		return id

	proc/createPiece(var/code, var/x, var/y)
		var/id = src.uniquePieceId()
		src.pieces[id] = list(
			"code" = code,
			"x" = x,
			"y" = y,
			"prevX" = x,
			"prevY" = y,
			"selected" = null, // Piece on the board selected
			"lastSelected" = null, // Last piece selected by the user
			"palette" = null, // Code of the palette
		)
		playsound(src.loc, src.sounds["move"], 30, 1)

	// Apply a palette to the user
	proc/setPalette(var/ckey, var/code)
		src.active_users[ckey]["palette"] = code

	proc/clearPalette(var/ckey)
		src.active_users[ckey]["palette"] = null

	proc/getActivePalette(var/ckey)
		return src.active_users[ckey]["palette"]

	proc/getPawnById(var/id)
		return src.pieces[id]

	proc/removePiece(var/piece)
		if(piece)
			src.pieces -= piece


	proc/removePieceById(var/id)
		src.removePiece(src.getPawnById(id))

	proc/removePieceAt(var/x, var/y)
		for (var/piece in src.pieces)
			if (src.pieces[piece]["x"] == x && src.pieces[piece]["y"] == y)
				src.removePiece(piece)

	proc/selectPawn(ckey, pId)
		src.active_users[ckey]["selected"] = pId
		if (!pId)
			return
		// Check if ["selected"] is null
		if (src.active_users[ckey]["selected"])
			pieces[pId]["selected"] = src.active_users[ckey]



	proc/deselectPawn(ckey)
		// Check if ckey exists
		if (ckey in src.active_users)
			// Check if the user has a selected piece
			if (src.active_users[ckey]["selected"])
				// Deselect the piece
				pieces[src.active_users[ckey]["selected"]]["selected"] = null
				src.active_users[ckey]["selected"] = null

	proc/getPawnAt(x, y)
		for (var/id in src.pieces)
			var/list/pawn = src.pieces[id]
			if (pawn["x"] == x && pawn["y"] == y)
				return pawn
		return null

	proc/placePalette(ckey, x, y)
		if (x < 0 || x >= src.board_width || y < 0 || y >= src.board_height)
			return

		// Update old pos
		var/_x = x
		var/_y = y

		if(src.lock_pieces_to_tile)
			_x = round(x)
			_y = round(y)

		var/palette = src.active_users[ckey]["palette"]
		if (palette)
			// Remove any piece at the location
			src.removePieceAt(_x, _y)

			src.createPiece(palette, _x, _y)
			src.clearPalette(ckey)

		return

	proc/placePawn(ckey, x, y)
		// Check if out of bounds
		if (x < 0 || x >= src.board_width || y < 0 || y >= src.board_height)
			return

		var/_x = x
		var/_y = y

		if(src.lock_pieces_to_tile)
			_x = round(x)
			_y = round(y)

		var/pawn = src.getPawnById(src.active_users[ckey]["selected"])
		if (!pawn)
			src.deselectPawn(ckey)
			return

		var/new_x = pawn["x"]
		var/new_y = pawn["y"]

		// Check if the pawn is moving to a new tile
		if (new_x == _x && new_y == _y)
			src.deselectPawn(ckey)
			return

		var/map_text = ""
		var/moverName = pawn["selected"]["name"]
		var/prevPosString = src.posToNotationString(new_x, new_y)
		var/newPosString = src.posToNotationString(_x, _y)

		// Update old pos
		pawn["prevX"] = new_x
		pawn["prevY"] = new_y
		pawn["lastSelected"] = pawn["selected"]

		// Check if the pawn is moving to a tile that is already occupied

		var/occupied = src.getPawnAt(_x, _y)

		if (occupied)
			// Check if the pawn is moving to a tile that is occupied by an enemy
			if (pawn != occupied)
				map_text = "[moverName] moves [prevPosString] to [newPosString] and captures [occupied["code"]]!"
				playsound(src.loc, src.sounds["capture"], 30, 1)
				src.removePieceAt(_x, _y)
			else
				// If the piece is moving to a tile that is occupied by itself
				return
		else
			map_text = "[moverName] moves [prevPosString] to [newPosString]!"


		// var/map_text_final = make_chat_maptext(src, map_text, "color: #A8E9F0;", alpha = 150, time = 8)
		// for (var/mob/O in hearers(src))
		// 	O.show_message(assoc_maptext = map_text_final)

		playsound(src.loc, src.sounds["move"], 30, 1)

		// Move the pawn to the new tile
		pawn["x"] = _x
		pawn["y"] = _y

		// Draw the piece and tile



		// Deselect the pawn
		src.deselectPawn(ckey)

	proc/capturePawn(var/pawn)
		//src.drawBoardIcon()
		playsound(src.loc, src.sounds["capture"], 30, 1)
		src.removePiece(pawn["id"])

	proc/drawTile(x, y, updateIcon = FALSE)
		if(!src.use_cb) return

		var/usecolor = src.styling["tileColour1"]
		if ((x + y) % 2 == 0)
			usecolor = src.styling["tileColour2"]

		var/x1 = x * src.cb_tsize -1
		var/y1 = y * src.cb_tsize
		var/x2 = x1 + src.cb_tsize - 1
		var/y2 = y1 + src.cb_tsize - 1

		src.cb.DrawBox(usecolor, x1,y1,x2,y2)

		if(updateIcon)
			src.icon = src.cb

	proc/drawPiece(code, _x, _y, px = 0, py = 0, updateIcon = FALSE)
		if(!src.use_cb) return
		var/x = _x + 1
		// Reverse y
		var/y = _y + 1

		if (px > 0 && py > 0)
			// Clear the previous tile
			src.drawTile(px, py, FALSE)

		// Alter height depending on piece type
		var/pawn_height = 1
		switch(code)
			// Pawn (Chess), Man and King (Draughts),
			if("p", "P", "d", "D", "m", "M")
				pawn_height = 0
			// King (Chess)
			if("k", "K")
				pawn_height = 2

		var/piece_color = rgb(0, 0, 0)
		if (code == uppertext(code))
			piece_color = rgb(226, 226, 226)

		// Box size, use pawn_height to make the piece taller or shorter
		var/x1 = (x) * src.cb_tsize
		var/y1 = (board_height - y + 1) * src.cb_tsize

		src.cb.DrawBox(piece_color, x1,y1 + 1,x1,y1 + 1 + pawn_height)

		if(updateIcon)
			src.icon = src.cb

	proc/swapCustomAndDefault()
		if(src.icon == src.cb)
			src.swapToDefaultBoardStyle()
		else
			src.swapToCustomBoardStyle()

	proc/swapToCustomBoardStyle()
		src.icon = src.cb
		src.initCustomBoardIcon()

	proc/swapToDefaultBoardStyle()
		src.icon = 'icons/obj/items/gameboard.dmi'
		src.icon_state = "chessboard"

	proc/initCustomBoardIcon()

		var/width = (src.board_width * src.cb_tsize) + src.cb_pad - 2
		var/height = (src.board_height * src.cb_tsize) + src.cb_pad - 1

		src.bound_width = width
		src.bound_height = height
		src.cb = icon(src.icon, icon_state = "base")
		src.cb.Crop(1, 1, width, height)

		// Draw the background for the board
		src.cb.DrawBox(src.cb_clr_out, 1, 1 + src.cb_mrg_bot, width, height)
		src.cb.DrawBox(src.cb_clr_bot, 1, 1, width, src.cb_mrg_bot)

		// Draw the board
		var/quarter_pad = src.cb_pad / 4 // Like a quarter pounder, but with padding
		for(var/x in 1 to board_width)
			for(var/y in 1 to board_height)
				src.drawTile(x, y)

		for(var/id in src.pieces)
			var/piece = src.pieces[id]
			var/code = piece["code"]
			var/x = piece["x"]
			var/y = piece["y"]
			src.drawPiece(code, x, y)

		/*
		for(var/x in 1 to board_width)
			for(var/y in 1 to board_height)
				var/tile_color = color1rgb
				var/tile_x1 = (x) * tile_size
				var/tile_y1 = (board_height - y + 1) * tile_size
				var/tile_x2 = tile_x1 + tile_size
				var/tile_y2 = tile_y1 + tile_size
				if ((x + y) % 2 == 0)
					tile_color = color2rgb
				src.custom_board.DrawBox(tile_color, tile_x1, tile_y1, tile_x2-1, tile_y2-1)


		for(var/id in src.pieces)
			var/piece = src.pieces[id]
			var/letter = piece["code"]
			var/x = piece["x"] + 1
			var/y = piece["y"] + 1

			// DrawBox uses x1, y1, x2, y2, each tile should be 2x2

			var/tile_x1 = (x) * tile_size
			var/tile_y1 = (board_height - y + 1) * tile_size

			var/pawn_height = 1
			if(letter == "p" || letter == "P")
				pawn_height = 0
			if(letter == "k" || letter == "K")
				pawn_height = 2
			if (letter != "")
				if (letter == uppertext(letter))
					src.custom_board.DrawBox(rgb(255, 255, 255), tile_x1 + 1, tile_y1 + 1, tile_x1 + 1, tile_y1 + 1 + pawn_height)
				else
					src.custom_board.DrawBox(rgb(0, 0, 0), tile_x1 + 1, tile_y1 + 1, tile_x1 + 1, tile_y1 + 1 + pawn_height)*/
		src.icon = src.cb


	can_access_remotely(mob/user)
		. = can_access_remotely_default(user)

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if(!ui)
			ui = new(user, src, "Boardgame")
			ui.open()

			if(!src.active_users[user.ckey])
				src.active_users[user.ckey] = list(
					"ckey" = user.ckey,
					"name" = user.name,
					"selected" = null
				)

	ui_static_data(mob/user)
		. = list()
		.["boardInfo"] = list(
			"name" = src.name,
			"game" = src.game,
			"pattern" = src.pattern,
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

	ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
		. = ..()
		if(. || !IN_RANGE(src, ui.user, 1))
			return
		switch(action)
			if("pawnCreate")
				var/fenCode = params["fenCode"]
				var/x = text2num(params["x"])
				var/y = text2num(params["y"])
				src.createPiece(fenCode, x, y)
				. = TRUE
			if("pawnRemove")
				var/id = params["id"]
				src.removePiece(id)
				. = TRUE
			if("pawnRemoveHeld")
				var/ckey = params["ckey"]
				var/id = src.active_users[ckey]["selected"]
				src.deselectPawn(ckey)
				src.removePiece(id)
				. = TRUE
			if("pawnSelect")
				var/ckey = params["ckey"]
				var/pId = params["pId"]
				src.selectPawn(ckey, pId)
				//src.removePiece
				. = TRUE
			if("pawnDeselect")
				var/ckey = params["ckey"]
				src.deselectPawn(ckey)
				. = TRUE
			if("pawnPlace")
				// Place the pawn on the board currently selected
				var/ckey = params["ckey"]
				var/x = text2num(params["x"])
				var/y = text2num(params["y"])
				if(src.active_users[ckey]["selected"])
					src.placePawn(ckey, x, y)
				else
					src.placePalette(ckey, x, y)
				. = TRUE
			/*if("applyFen")
				var/fen = params["fen"]
				src.applyFen(fen)
				. = TRUE*/
			if("applyGNot")
				var/gnot = params["gnot"]
				src.applyGNot(gnot)
				if(src.use_cb)
					src.initCustomBoardIcon()
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

	ui_close(mob/user)
		src.active_users -= user
		. = ..()

	ui_status(mob/user, datum/ui_state/state)
		. = ..()
		if(. <= UI_CLOSE || !IN_RANGE(src, user, 10))
			return UI_CLOSE

	examine(mob/user)
		. = ..()
		if(IN_RANGE(src, user, 10))
			return src.attack_hand(user)

	mouse_drop(var/mob/user)
		if((istype(user,/mob/living/carbon/human))&&(!user.stat)&&!(src in user.contents)&&!src.anchored)
			user.put_in_hand_or_drop(src)
		return ..()

	attack_hand(var/mob/user) // open browser window when board is clicked
		src.ui_interact(user)

	attack_ai(var/mob/user)
		return src.attack_hand(user)

	attackby(obj/item/W, mob/user, params)
		if(istype(W, /obj/item/paint_can))
			var/obj/item/paint_can/can = W

			//Check which hand the paint can is in, style tileColour1 or tileColour2
			// based on that

			var/tileColour = "tileColour1"
			if(user.l_hand == can)
				tileColour = "tileColour1"
			else if(user.r_hand == can)
				tileColour = "tileColour2"
			else
				boutput(user, "<span class='warning'>You need to hold the paint can in your hand to use it!</span>")
				return

			//Check if the paint can is empty
			if(can.uses <= 0)
				boutput(user, "<span class='warning'>The paint can is empty!</span>")
				return

			//Apply the paint to the src.styling[tileColour]
			src.styling[tileColour] = can.paint_color
			can.uses--

		return



	chess
		name = "chess board"
		desc = "It's a board for playing chess and checkers!"
		New()
			..()

	New()
		..()
		// Store old styling if there is any reason to reset the board
		styling["oldTileColour1"] = styling["tileColour1"]
		styling["oldTileColour2"] = styling["tileColour2"]

		if(src.use_cb)
			src.initCustomBoardIcon()

