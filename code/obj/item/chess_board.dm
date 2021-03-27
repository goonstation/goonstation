/obj/item/chessboard
	name = "chess board"
	desc = "It's a board for playing chess! Or checkers... Or anything that uses an 8x8 checkered board..."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "chess-board"

/obj/item/chessbox
	name = "chessmen box"
	desc = "if you see this, everything has gone disastrously wrong, please send a bug report."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "piece-box-b"
	var/affinity // 1 or 2 (black or white), for setting the piece colour dispensed by a box
	// a list of the pieces the box spawns
	var/kings = 1
	var/queens = 2 // 1 extra for piece promotion :)
	var/bishops = 2
	var/knights = 2
	var/rooks = 2
	var/pawns = 2
	var/draughtsmen = 12 // oh right, this game exists :sheltersweat:

	attack_self(mob/user as mob)
		if(src.icon_state == "piece-box-b" || src.icon_state == "piece-box-w") // if icon_state is either one of the two closed box icon_states
			if(src.icon_state == "piece-box-b")
				src.icon_state = "piece-boxe-b"
			else
				src.icon_state = "piece-boxe-w"
		else if(src.icon_state == "piece-boxe-b" || src.icon_state == "piece-boxe-w") // if icon_state is either one of the open box icons_states
			if(src.icon_state == "piece-boxe-b")
				src.icon_state = "piece-box-b"
			else
				src.icon_state = "piece-box-w"

/obj/item/chessbox/b
	name = "black chess box"
	desc = "An ornate wooden box containing black pieces for chess and checkers."
	icon_state = "piece-box-b"
	affinity = 1

/obj/item/chessbox/w
	name = "white chess box"
	desc = "An ornate wooden box containing white pieces for chess and checkers."
	icon_state = "piece-box-w"
	affinity = 2

/obj/item/chessman
	name = "unidentified chessman"
	desc = "OH GOD GET IT AWAY FROM ME FILE A BUG REPORT AAAAA!"
	icon = 'icons/obj/items/items.dmi'
	w_class = 1

	// black's pieces
	black
		king
			name = "black king"
			desc = "Checkmate!"
			icon_state = "king-b"
		queen
			name = "black queen"
			desc = "Queen OP, pls nerf."
			icon_state = "queen-b"
		bishop
			name = "black bishop"
			desc = "hallelujah!"
			icon_state = "bishop-b"
		knight
			name = "black knight"
			desc = "Neigh, bitch."
			icon_state = "knight-b"
		rook
			name = "black rook"
			desc = "I'm the king of the castle!"
			icon_state = "rook-b"
		pawn
			name = "black pawn"
			desc = "Sacre bleu! Envahisseur!"
			icon_state = "pawn-b"
		checker
			name = "black checker piece"
			desc = "A yummy-looking wooden disk."
			icon_state = "checker-b"

	// white's pieces
	white
		king
			name = "white king"
			desc = "Checkmate!"
			icon_state = "king-w"
		queen
			name = "white queen"
			desc = "Queen OP, pls nerf."
			icon_state = "queen-w"
		bishop
			name = "white bishop"
			desc = "hallelujah!"
			icon_state = "bishop-w"
		knight
			name = "white knight"
			desc = "Neigh, bitch."
			icon_state = "knight-w"
		rook
			name = "white rook"
			desc = "I'm the king of the castle!"
			icon_state = "rook-w"
		pawn
			name = "white pawn"
			desc = "Sacre bleu! Envahisseur!"
			icon_state = "pawn-w"
		checker
			name = "white checker piece"
			desc = "A yummy-looking wooden disk."
			icon_state = "checker-w"
