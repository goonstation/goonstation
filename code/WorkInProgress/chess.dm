/****************************************************************************************************************************************************************************************
________  ___  ___  _______   ________   ________  _____ ______   ________  ________  _________  _______   ________      ________   ________    _____  ________                      	*
|\   ____\|\  \|\  \|\  ___ \ |\   ____\ |\   ____\|\   _ \  _   \|\   __  \|\   ____\|\___   ___\\  ___ \ |\   __  \    |\   ____\ |\   ____\  / __  \|\_____  \                     	*
\ \  \___|\ \  \\\  \ \   __/|\ \  \___|_\ \  \___|\ \  \\\__\ \  \ \  \|\  \ \  \___|\|___ \  \_\ \   __/|\ \  \|\  \   \ \  \___|_\ \  \___|_|\/_|\  \|____|\ /_                    	*
 \ \  \    \ \   __  \ \  \_|/_\ \_____  \\ \_____  \ \  \\|__| \  \ \   __  \ \_____  \   \ \  \ \ \  \_|/_\ \   _  _\   \ \_____  \\ \_____  \|/ \ \  \    \|\  \                   	*
  \ \  \____\ \  \ \  \ \  \_|\ \|____|\  \\|____|\  \ \  \    \ \  \ \  \ \  \|____|\  \   \ \  \ \ \  \_|\ \ \  \\  \| __\|____|\  \\|____|\  \   \ \  \  __\_\  \                  	*
   \ \_______\ \__\ \__\ \_______\____\_\  \ ____\_\  \ \__\    \ \__\ \__\ \__\____\_\  \   \ \__\ \ \_______\ \__\\ _\|\__\____\_\  \ ____\_\  \   \ \__\|\_______\                 	*
    \|_______|\|__|\|__|\|_______|\_________\\_________\|__|     \|__|\|__|\|__|\_________\   \|__|  \|_______|\|__|\|__\|__|\_________\\_________\   \|__|\|_______|                 	*
                                 \|_________\|_________|                       \|_________|                                 \|_________\|_________|                                   	*
																																														*
 ________  ________  ________  ___    ___ ________  ___  ________  ___  ___  _________     _______  ________  ________  ________      ___       __   ________  ________  ________     	*
|\   ____\|\   __  \|\   __  \|\  \  /  /|\   __  \|\  \|\   ____\|\  \|\  \|\___   ___\  /  ___  \|\   __  \|\   __  \|\   ____\    |\  \     |\  \|\   __  \|\   __  \|\   ____\    	*
\ \  \___|\ \  \|\  \ \  \|\  \ \  \/  / | \  \|\  \ \  \ \  \___|\ \  \\\  \|___ \  \_| /__/|_/  /\ \  \|\  \ \  \|\  \ \  \___|    \ \  \    \ \  \ \  \|\  \ \  \|\  \ \  \___|    	*
 \ \  \    \ \  \\\  \ \   ____\ \    / / \ \   _  _\ \  \ \  \  __\ \   __  \   \ \  \  |__|//  / /\ \  \\\  \ \  \\\  \ \  \____    \ \  \  __\ \  \ \   __  \ \   _  _\ \  \       	*
  \ \  \____\ \  \\\  \ \  \___|\/  /  /   \ \  \\  \\ \  \ \  \|\  \ \  \ \  \   \ \  \ ___ /  /_/__\ \  \\\  \ \  \\\  \ \  ___  \ __\ \  \|\__\_\  \ \  \ \  \ \  \\  \\ \  \____  	*
   \ \_______\ \_______\ \__\ __/  / /      \ \__\\ _\\ \__\ \_______\ \__\ \__\   \ \__\\__\\________\ \_______\ \_______\ \_______\\__\ \____________\ \__\ \__\ \__\\ _\\ \_______\	*
    \|_______|\|_______|\|__||\___/ /        \|__|\|__|\|__|\|_______|\|__|\|__|    \|__\|__|\|_______|\|_______|\|_______|\|_______\|__|\|____________|\|__|\|__|\|__|\|__|\|_______|	*
                             \|___|/                                                                                                                                                  	*
****************************************************************************************************************************************************************************************/


var/list/chessboard = list()
var/chess_enpassant = 0
var/chess_in_progress = 0

turf/unsimulated/floor/chess

	var/obj/item/chesspiece/enpassant = null

	New()
		..()
		chessboard += src

	Del()
		chessboard -= src
		..()

obj/chessbutton
	name = "Chess Reset Button"
	desc = "A button that clears the chessboard, then re-sets the pieces. Don't press it while you're playing"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "doorctrl0"
	var/confirm = 0

	attack_hand(mob/user)
		if(chess_in_progress && !confirm)
			boutput(user, "<span class='alert'>You are about to erase the board. Press again to confirm.</span>")
			confirm = 1
		else
			logTheThing(LOG_ADMIN, user, "has reset the chessboard. Hope nobody was playing chess.")
			logTheThing(LOG_DIARY, user, "has reset the chessboard. Hope nobody was playing chess.", "admin")

			for(var/turf/unsimulated/floor/chess/T in chessboard)
				T.enpassant = null // almost forgot this, gotte get that sweet GC
				for(var/obj/item/O in T)
					qdel(O)
				for(var/obj/landmark/chess/L in T)
					L.lets_fuckin_start_this_party()
				sleep(0.1 SECONDS)

			chess_in_progress = 1
			confirm = 0


obj/landmark/chess
	add_to_landmarks = FALSE
	deleted_on_start = FALSE

	proc/lets_fuckin_start_this_party()
		switch(src.name)
			if("pawn")
				new /obj/item/chesspiece/pawn(src.loc)
			if("king")
				new /obj/item/chesspiece/king(src.loc)
			if("queen")
				new /obj/item/chesspiece/queen(src.loc)
			if("rook")
				new /obj/item/chesspiece/rook(src.loc)
			if("bishop")
				new /obj/item/chesspiece/bishop(src.loc)
			if("knight")
				new /obj/item/chesspiece/knight(src.loc)
			if("b_pawn")
				new /obj/item/chesspiece/pawn/black(src.loc)
			if("b_king")
				new /obj/item/chesspiece/king/black(src.loc)
			if("b_queen")
				new /obj/item/chesspiece/queen/black(src.loc)
			if("b_rook")
				new /obj/item/chesspiece/rook/black(src.loc)
			if("b_bishop")
				new /obj/item/chesspiece/bishop/black(src.loc)
			if("b_knight")
				new /obj/item/chesspiece/knight/black(src.loc)

obj/item/chesspiece

	name = "chess piece"
	desc = "a generic chess piece parent that you really shouldnt be seeing"
	icon = 'icons/misc/chess.dmi'
	icon_state = "pawn_black"
	anchored = 1

	var/chess_color = 0
	var/isking = 0

	New()
		..()
		name = "[chess_color ? "black" : "white" ] [name]"

	mouse_drop(obj/over_object as obj, src_location, over_location, mob/user as mob)
		..()
		var/turf/Tb = get_turf(over_location)
		var/turf/Ta = get_turf(src_location)

		if(!Tb || !Ta)
			return
		else
			if(istype(Tb,/turf/unsimulated/floor/chess) && validmove(Ta,Tb))
				chessmove(Tb,user)
			else
				src.visible_message("<span class='alert'>Invalid move dorkus.</span>") // seems USER here is not actually the mob, but the click proc itself, so im regressing to a visible message for now

	proc/gib()
		//do some gib stuff here
		qdel(src)


	proc/validmove(turf/start_pos, turf/end_pos)
		return 1

	proc/chessmove(turf/T, mob/user)
		for(var/obj/item/chesspiece/C in T)
			if(C.isking && (chess_color != C.chess_color))
				src.visible_message("<span class='success'>[src] has captured the enemy Captain. The [chess_color ? "black" : "white" ] commander has defeated the [C.chess_color ? "black" : "white" ] crew.</span>")
				C.gib()
				chess_in_progress = 0
			else if(chess_color == C.chess_color)
				src.visible_message("<span class='alert'>You really ought to fight the enemy pieces, [chess_color ? "black" : "white" ] commander.</span>")
				return
			else
				src.visible_message("<span class='notice'>[src] has captured [C].</span>")
				C.gib()
		src.visible_message("<span class='notice'>The [chess_color ? "black" : "white" ] commander has moved [src].</span>")
		src.set_loc(T)
		if(chess_enpassant)
			for(var/turf/unsimulated/floor/chess/CB in chessboard)
				CB.enpassant = null
				chess_enpassant = 0



/* specific pieces go here, the major differences are just their validmove() procs. Some might override chessmove() too

_1____0_
_B____W_

so for real uhhhh some of these things are still being attrocious, not announcing their captures and shit. I dont know why

*/

obj/item/chesspiece/pawn
	name = "chess assistant"
	desc = "A pawn- peon. pon? pone. A chess greyshirt."
	var/movdir = 0
	var/opened = 0
	var/promoteX = 0
	var/turf/unsimulated/floor/chess/EP = null

	black
		chess_color = 1

	New()
		..()
		icon_state = (chess_color ? "pawn_black" : "pawn_white")
		movdir = chess_color ? 1 : -1
		promoteX = src.x + 6*movdir

	validmove(turf/start_pos, turf/end_pos)
		if(!opened && (start_pos.y==end_pos.y)) // do we allow you to move two spots? yes. yes we do. I love you.
			if((end_pos.x - start_pos.x) == 2*movdir)
				for(var/obj/item/chesspiece/C in locate(start_pos.x+movdir,src.y,src.z)) // intermediate blocking
					return 0
				EP = locate(start_pos.x+movdir,src.y,src.z)
				return 1
		if(start_pos.y != end_pos.y)
			if((abs(start_pos.y - end_pos.y) == 1) && (end_pos.x - start_pos.x) == movdir )
				for(var/obj/item/chesspiece/C in end_pos)
					return 1
				var/turf/unsimulated/floor/chess/Tep = end_pos
				if(Tep.enpassant)
					qdel(Tep.enpassant)
					src.visible_message("<span class='notice'>[src] has made a capture en passant.</span>")
					return 1
			return 0
		else if((end_pos.x - start_pos.x) != movdir)
			return 0
		else
			for(var/obj/item/chesspiece/C in end_pos)
				return 0
			return 1


	chessmove()
		opened = 1
		..()
		if(src.x == promoteX) // promote after youre done movin
			if (src.chess_color)
				new /obj/item/chesspiece/queen/black(src.loc)
			else
				new /obj/item/chesspiece/queen(src.loc)
			src.visible_message("<span class='notice'>[src] has been promoted.</span>")
			qdel(src)
		if (EP)
			EP.enpassant = src
			chess_enpassant = 1
			EP = null

obj/item/chesspiece/king
	name = "king"
	desc = "A vital target, fittingly useless in combat."
	isking = 1
	var/opened = 0
	var/castling = 0

	black
		chess_color = 1

	New()
		..()
		icon_state = (chess_color ? "king_black" : "king_white")

	validmove(turf/start_pos, turf/end_pos)
		if(GET_DIST(start_pos,end_pos) == 1)
			return 1
		else if (!opened)
			for(var/obj/item/chesspiece/rook/C in end_pos)
				if ((C.chess_color == chess_color) && (!C.opened))
					var/start = min(start_pos.y,end_pos.y)
					var/end = max(start_pos.y,end_pos.y)
					var/i
					for(i=start+1, i < end, i++)
						for(var/obj/item/chesspiece/Cfuck in locate(start_pos.x,i,src.z))
							return 0
						src.visible_message("<span class='notice'>[src] has castled with [C].</span>")
						if(start_pos.y>end_pos.y)
							C.set_loc(locate(src.x,(src.y - 1),src.z))
							src.set_loc(locate(src.x,(src.y - 2),src.z))
						else
							C.set_loc(locate(src.x,(src.y + 1),src.z))
							src.set_loc(locate(src.x,(src.y + 2),src.z))
						castling = 1 // this is a dirty way to do this but
						return 1
		return 0

	chessmove()
		opened = 1
		if(!castling)
			..()
		else // i guess it should work?
			castling = 0 // in theory
			if(chess_enpassant)
				for(var/turf/unsimulated/floor/chess/CB in chessboard)
					CB.enpassant = null
					chess_enpassant = 0


obj/item/chesspiece/rook
	name = "rook"
	desc = "Somewhat rigid, linear, but totally ready to start fires"
	var/opened = 0

	black
		chess_color = 1

	New()
		..()
		icon_state = (chess_color ? "rook_black" : "rook_white")

	validmove(turf/start_pos, turf/end_pos)
		var/start = 0
		var/end = 0
		if(start_pos.x == end_pos.x)
			start = min(start_pos.y,end_pos.y)
			end = max(start_pos.y,end_pos.y)
			var/i
			for(i=start+1, i < end, i++)
				for(var/obj/item/chesspiece/C in locate(start_pos.x,i,src.z))
					return 0
			return 1
		else if(start_pos.y == end_pos.y)
			start = min(start_pos.x,end_pos.x)
			end = max(start_pos.x,end_pos.x)
			var/i
			for(i=start+1, i < end, i++)
				for(var/obj/item/chesspiece/C in locate(i,start_pos.y,src.z))
					return 0
			return 1
		else return 0

	chessmove()
		opened = 1
		..()

obj/item/chesspiece/queen
	name = "queen"
	desc = "Subordinate in name only."

	black
		chess_color = 1

	New()
		..()
		icon_state = (chess_color ? "queen_black" : "queen_white")

	validmove(turf/start_pos, turf/end_pos) // we need 4 cases here. two orthogonal, two diagonal.
		var/minx = min(start_pos.x,end_pos.x)
		var/miny = min(start_pos.y,end_pos.y)
		var/maxx = max(start_pos.x,end_pos.x)
		var/maxy = max(start_pos.y,end_pos.y)

		if(start_pos.x == end_pos.x) // vertical movement
			var/i
			for(i=miny+1, i < maxy, i++)
				for(var/obj/item/chesspiece/C in locate(start_pos.x,i,src.z))
					return 0
			return 1

		else if(start_pos.y == end_pos.y) // horizontal movement
			var/i
			for(i=minx+1, i < maxx, i++)
				for(var/obj/item/chesspiece/C in locate(i,start_pos.y,src.z))
					return 0
			return 1

		else if((start_pos.x - end_pos.x) == (start_pos.y - end_pos.y)) // coaxial diagonal
			var/i
			for(i=1, i < (start_pos.x - end_pos.x), i++)
				for(var/obj/item/chesspiece/C in locate(minx+i,miny+i,src.z))
					return 0
			return 1

		else if((start_pos.x - end_pos.x) == -(start_pos.y - end_pos.y)) // the other one
			var/i
			for(i=1, i < (start_pos.x - end_pos.x), i++)
				for(var/obj/item/chesspiece/C in locate(maxx-i,miny+i,src.z))
					return 0
			return 1
		else return 0 // none of the 4 directions? too bad okay. Im annotating code that doesnt need notes just because I gotta look busy at work.

obj/item/chesspiece/bishop
	name = "bishop"
	desc = "Boneless queen"

	black
		chess_color = 1

	New()
		..()
		icon_state = (chess_color ? "bishop_black" : "bishop_white")


	validmove(turf/start_pos, turf/end_pos) // we need only 2 cases here. im copypasting from queen.
		var/minx = min(start_pos.x,end_pos.x)
		var/miny = min(start_pos.y,end_pos.y)
		var/maxx = max(start_pos.x,end_pos.x)

		if((start_pos.x - end_pos.x) == (start_pos.y - end_pos.y)) // coaxial diagonal
			var/i
			for(i=1, i < (start_pos.x - end_pos.x), i++)
				for(var/obj/item/chesspiece/C in locate(minx+i,miny+i,src.z))
					return 0
			return 1

		else if((start_pos.x - end_pos.x) == -(start_pos.y - end_pos.y)) // the other one
			var/i
			for(i=1, i < (start_pos.x - end_pos.x), i++)
				for(var/obj/item/chesspiece/C in locate(maxx-i,miny+i,src.z))
					return 0
			return 1
		else return 0 // pee pee poo poo


obj/item/chesspiece/knight
	name = "knight"
	desc = "Does anyone actually know why they move like that?"

	black
		chess_color = 1

	New()
		..()
		icon_state = (chess_color ? "knight_black" : "knight_white")
		if(prob(1))
			name = "hoarse"

	validmove(turf/start_pos, turf/end_pos) // this is weird
		var/dispx = abs(start_pos.x - end_pos.x)
		var/dispy = abs(start_pos.y - end_pos.y)
		if(((dispx == 2) && (dispy == 1)) || ((dispx == 1) && (dispy == 2)))
			return 1
		else return 0





