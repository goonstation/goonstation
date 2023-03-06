/datum/targetable/wraithAbility/blood_writing
	name = "Blood Writing"
	desc = "Write a spooky character on the ground."
	icon_state = "bloodwriting"
	targeted = 1
	target_anything = 1
	pointCost = 2
	cooldown = 1 SECONDS
	min_req_dist = 10
	var/in_use = 0

	// cast(turf/target, params)
	cast(atom/target, params)
		if (..())
			return 1

		var/turf/T = get_turf(target)
		if (isturf(T))
			write_on_turf(T, holder.owner, params)


	proc/write_on_turf(var/turf/T as turf, var/mob/user as mob, params)
		if (!T || !user || src.in_use)
			return
		src.in_use = 1
		var/list/c_default = list("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
		"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "Exclamation Point", "Question Mark", "Period", "Comma", "Colon", "Semicolon", "Ampersand", "Left Parenthesis", "Right Parenthesis",
		"Left Bracket", "Right Bracket", "Percent", "Plus", "Minus", "Times", "Divided", "Equals", "Less Than", "Greater Than")
		var/list/c_symbol = list("Dollar", "Euro", "Arrow North", "Arrow East", "Arrow South", "Arrow West",
		"Square", "Circle", "Triangle", "Heart", "Star", "Smile", "Frown", "Neutral Face", "Bee", "Pentagram","Skull")

		var/t = input(user, "What do you want to write?", null, null) as null|anything in (c_default + c_symbol)

		if (!t)
			src.in_use = 0
			return 1
		var/obj/decal/cleanable/writing/spooky/G = make_cleanable(/obj/decal/cleanable/writing/spooky,T)
		G.artist = user.key

		logTheThing(LOG_STATION, user, "writes on [T] with [src] [log_loc(T)]: [t]")
		G.icon_state = t
		G.words = t
		if (islist(params) && params["icon-y"] && params["icon-x"])
			// playsound(src.loc, 'sound/impact_sounds/Slimy_Splat_1.ogg', 50, 0)

			G.pixel_x = text2num(params["icon-x"]) - 16
			G.pixel_y = text2num(params["icon-y"]) - 16
		else
			G.pixel_x = rand(-4,4)
			G.pixel_y = rand(-4,4)
		src.in_use = 0
