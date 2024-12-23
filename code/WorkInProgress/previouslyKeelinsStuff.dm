//
// This file contains stuff that was originally made by me and then expanded on or butchered by other people.
// - Keelin
//


/*
/verb/fuck_this_shit()
	set name = "Press this if the server is so badly fucked up that it will never recover or restart"
	set category = "Debug"
	//del(world)
	*/

/proc/is_null_or_space(var/input)
	if (input == " " || input == "" || isnull(input)) return 1
	else return 0

/proc/lolcat_parse(var/datum/text_roamer/R)
	var/new_string = ""
	var/used = 0

	switch(lowertext(R.curr_char))

		if ("d")
			if ( !is_null_or_space(R.prev_char) && lowertext(R.next_char) == "e" && is_null_or_space(R.next_next_char))
				new_string = "ded"
				used = 2

		if ("a")
			if ( is_null_or_space(R.prev_char) && lowertext(R.next_char) == "m" && is_null_or_space(R.next_next_char))
				new_string = "are"
				used = 2
			//else if (!is_null_or_space(R.prev_char) && lowertext(R.next_char) == "d" && lowertext(R.next_next_char) == "e")
			//	new_string = "aid"
			//	used = 3
			else if ( !is_null_or_space(R.prev_char) && lowertext(R.next_char) == "y" && !is_null_or_space(R.next_next_char))
				new_string = "eh"
				used = 2
			else if (!is_null_or_space(R.prev_char) && lowertext(R.next_char) == "u" && !is_null_or_space(R.next_next_char))
				new_string = "oo"
				used = 2
			else if (is_null_or_space(R.prev_char) && lowertext(R.next_char) == "r" && lowertext(R.next_next_char) == "e" && is_null_or_space(R.next_next_next_char))
				new_string = "r"
				used = 3

		if ("h")
			if (lowertext(R.next_char) == "a" && lowertext(R.next_next_char) == "v" && lowertext(R.next_next_next_char) == "e")
				new_string = "has"
				used = 4
			else if (is_null_or_space(R.prev_char) && lowertext(R.next_char) == "e" && is_null_or_space(R.next_next_char))
				new_string = "him"
				used = 2
			else if (is_null_or_space(R.prev_char) && lowertext(R.next_char) == "i" && lowertext(R.next_next_char) == "s" && is_null_or_space(R.next_next_next_char))
				new_string = "him"
				used = 3
			else if (lowertext(R.next_char) == "e" && lowertext(R.next_next_char) == "r" && lowertext(R.next_next_next_char) == "e")
				new_string = "ere"
				used = 4

		if ("m")
			if (is_null_or_space(R.prev_char) && lowertext(R.next_char) == "e" && is_null_or_space(R.next_next_char))
				new_string = "i"
				used = 2

		if ("g")
			if (!is_null_or_space(R.prev_char) && lowertext(R.next_char) == "h" && !is_null_or_space(R.next_next_char))
				new_string = ""
				used = 2

		if ("n")
			if (!is_null_or_space(R.prev_char)&& lowertext(R.next_char) == "d" && lowertext(R.next_next_char) == "s" && is_null_or_space(R.next_next_char))
				new_string = "nz"
				used = 3
			else if (is_null_or_space(R.prev_char)&& lowertext(R.next_char) == "o" && is_null_or_space(R.next_next_char))
				new_string = "noes"
				used = 2

		if ("t")
			if (!is_null_or_space(R.prev_char) && lowertext(R.next_char) == "i" && lowertext(R.next_next_char) == "o" && lowertext(R.next_next_next_char) == "n")
				new_string = "shun"
				used = 4
			else if (lowertext(R.next_char) == "h" && lowertext(R.next_next_char) == "e" && lowertext(R.next_next_next_char) == "y")
				new_string = "dem"
				used = 4
			else if (lowertext(R.next_char) == "h" && lowertext(R.next_next_char) == "e")
				new_string = "teh" //da
				used = 3
			else if (!is_null_or_space(R.prev_char)  && lowertext(R.next_char) == "l" && lowertext(R.next_next_char) == "e" && is_null_or_space(R.next_next_next_char))
				new_string = "tul"
				used = 3
			else if (!is_null_or_space(R.prev_char)  && lowertext(R.next_char) == "e" && is_null_or_space(R.next_next_char))
				new_string = "ted"
				used = 2
			else if (lowertext(R.next_char) == "h")
				new_string = pick("d","f")
				used = 2
			else if (!is_null_or_space(R.prev_char) && is_null_or_space(R.next_char))
				new_string = "te"
				used = 1

		if ("q")
			new_string = "kw"
			used = 1

		if ("o")
			if (!is_null_or_space(R.prev_char) && lowertext(R.next_char) == "u" && is_null_or_space(R.next_next_char))
				new_string = "o"
				used = 2
			if (!is_null_or_space(R.prev_char) && lowertext(R.next_char) == "u" && !is_null_or_space(R.next_next_char))
				new_string = "ow"
				used = 2
			else if (R.in_word() && lowertext(R.next_char) == "o")
				new_string = "u"
				used = 2
			else if (R.in_word())
				new_string = "u"
				used = 1
			else if (R.alone())
				new_string = "u"
				used = 1

		if ("e")
			if (!is_null_or_space(R.prev_char) && lowertext(R.next_char) == "m" && is_null_or_space(R.next_next_char))
				new_string = "am"
				used = 2
			else if (!is_null_or_space(R.prev_char) && lowertext(R.next_char) == "n" && is_null_or_space(R.next_next_char))
				new_string = "un"
				used = 2
			else if (!is_null_or_space(R.prev_char) && lowertext(R.next_char) == "r" && is_null_or_space(R.next_next_char))
				new_string = pick("ah","ur")
				used = 2
			else if (!is_null_or_space(R.prev_char) && lowertext(R.next_char) == "l" && is_null_or_space(R.next_next_char))
				new_string = "ul"
				used = 2
			else if (!is_null_or_space(R.prev_char) && lowertext(R.next_char) == "n" && lowertext(R.next_next_char) == "t" && is_null_or_space(R.next_next_next_char))
				new_string = "unt"
				used = 3
			else if (!is_null_or_space(R.prev_char) && lowertext(R.next_char) == "d" && is_null_or_space(R.next_next_char))
				new_string = "eded"
				used = 2

		if ("k")
			if (lowertext(R.next_char) == "n" && !is_null_or_space(R.next_next_char))
				new_string = "n"
				used = 2

		if ("w")
			if (lowertext(R.next_char) == "h" && lowertext(R.next_next_char) == "y" && is_null_or_space(R.next_next_next_char))
				new_string = "y"
				used = 3

		if ("y")
			if (is_null_or_space(R.prev_char) && lowertext(R.next_char) == "o" && lowertext(R.next_next_char) == "u")
				new_string = "u"
				used = 3
			else if (!is_null_or_space(R.prev_char) && is_null_or_space(R.next_char))
				new_string = "ai" //eh
				used = 1

		if ("i")
			if (is_null_or_space(R.prev_char) && lowertext(R.next_char) == "m" && is_null_or_space(R.next_next_char))
				new_string = "iz"
				used = 2
			else if (is_null_or_space(R.prev_char) && lowertext(R.next_char) == "'" && lowertext(R.next_next_char) == "m" && is_null_or_space(R.next_next_next_char))
				new_string = "iz"
				used = 3
			else if (!is_null_or_space(R.prev_char) && lowertext(R.next_char) == "n" && lowertext(R.next_next_char) == "g" && is_null_or_space(R.next_next_next_char))
				new_string = "in"
				used = 3
			else if (!is_null_or_space(R.prev_char) && lowertext(R.next_char) == "t" && lowertext(R.next_next_char) == "e" && is_null_or_space(R.next_next_next_char))
				new_string = "iet"
				used = 3
			else if (!is_null_or_space(R.prev_char) && lowertext(R.next_char) == "o" && lowertext(R.next_next_char) == "u" && is_null_or_space(R.next_next_next_char))
				new_string = "u"
				used = 3

		if ("s")
			if (!is_null_or_space(R.prev_char) && lowertext(R.next_char) == "s")
				new_string = "z"
				used = 2
			else if (!is_null_or_space(R.prev_char) && lowertext(R.next_char) == "h" && lowertext(R.next_next_char) == "e" && is_null_or_space(R.next_next_next_char))
				new_string = "her"
				used = 3
			else if (!is_null_or_space(R.prev_char) && is_null_or_space(R.next_char))
				new_string = "z"
				used = 1

		if ("w")
			if (!is_null_or_space(R.prev_char) && lowertext(R.next_char) == "h" && !is_null_or_space(R.next_next_char))
				new_string = "w"
				used = 2

		if ("u")
			if (R.in_word())
				new_string = "oo"
				used = 1

	if (new_string == "")
		new_string = R.curr_char
		used = 1

	var/datum/parse_result/P = new/datum/parse_result
	P.string = uppertext(new_string)
	P.chars_used = used
	return P

/proc/lolcat(var/string)
	var/modded = ""
	var/datum/text_roamer/T = new/datum/text_roamer(string)

	for(var/i = 0, i < length(string), i=i)
		var/datum/parse_result/P = lolcat_parse(T)
		modded += P.string
		i += P.chars_used
		T.curr_char_pos = T.curr_char_pos + P.chars_used
		T.update()

	if (prob(16))
		switch(pick(1,2))
			if (1)
				modded += " SRSLY"
			if (2)
				modded += " LUL"

	return modded

/*/area/forest
	name = "Strange Forest"
	icon_state = "null"
	luminosity = 1
	force_fullbright = 1
	requires_power = 0

/area/forest/entrance
	name = "Strange Forest - Entrance"
	icon_state = "null"
	luminosity = 1
	force_fullbright = 1
	requires_power = 0*/


var/reverse_mode = 0

/proc/reverse_text(var/string)
	var/new_string=""
	for(var/i=length(string)+1, i>0, i--)
		new_string += copytext(string,i,i+1)
	return new_string

/proc/reverse()
	reverse_mode = !reverse_mode
	for(var/atom/A)
		A.name = reverse_text(A.name)
		if (hasvar(A,"real_name")) A:real_name = reverse_text(A:real_name)
		if (hasvar(A,"registered")) A:registered = reverse_text(A:registered)

/proc/circlerange(center=usr,radius=3)

	var/turf/centerturf = get_turf(center)
	var/list/turfs = new/list()
	var/rsq = radius * (radius+0.5)

	for(var/atom/T in range(radius, centerturf))
		var/dx = T.x - centerturf.x
		var/dy = T.y - centerturf.y
		if (dx*dx + dy*dy <= rsq)
			turfs += T

	//turfs += centerturf
	return turfs

/proc/circleview(center=usr,radius=3)

	var/turf/centerturf = get_turf(center)
	var/list/turfs = new/list()
	var/rsq = radius * (radius+0.5)

	for(var/atom/T in view(radius, centerturf))
		var/dx = T.x - centerturf.x
		var/dy = T.y - centerturf.y
		if (dx*dx + dy*dy <= rsq)
			turfs += T

	//turfs += centerturf
	return turfs

/obj/item/relic
	icon = 'icons/misc/hstation.dmi'
	icon_state = "relic"
	name = "strange relic"
	desc = "It feels cold..."
	var/using = 0
	var/beingUsed = 0

	pickup(mob/living/M)
		SPAWN(1 MINUTE)
			processing_items.Add(src)

	disposing()
		processing_items.Remove(src)
		. = ..()

	process()
		if (prob(1) && prob(50) && ismob(src.loc))
			var/mob/M = src.loc
			boutput(M, SPAN_ALERT("You feel uneasy ..."))

		if (prob(25))
			for(var/obj/machinery/light/L in range(6, get_turf(src)))
				if (prob(25))
					L.broken()

		if (prob(1) && prob(50) && !using)
			new/obj/critter/spirit( get_turf(src) )

		if (prob(3) && prob(50))
			var/obj/o = new/obj/item/spook( get_turf(src) )
			SPAWN(1 MINUTE)
				qdel(o)

		if (prob(25))
			for(var/obj/storage/L in range(6, get_turf(src)))
				if (prob(45))
					L.toggle()

		if (prob(25))
			for(var/obj/stool/chair/L in range(6, get_turf(src)))
				if (prob(15))
					L.rotate()



	attack_self(var/mob/user)
		if (user != loc)
			return
		if (using)
			boutput(user, SPAN_ALERT("The relic is humming loudly."))
			return
		else
			if (!beingUsed) //I guess you could use this thing in-hand a lot and gain its powers repeatedly!
				beingUsed = 1
				switch( input(user,"What now?","???", null) in null|list("Let the relic's power flow through you", "Bend the relic's power to your will", "Use the relic's power to heal your wounds" ,"Attempt to absorb the relic's power", "Leave it alone"))

					if (null, "Leave it alone")
						boutput(user, "You leave the relic alone.")

					if ("Let the relic's power flow through you")
						using = 1
						var/turf/T = get_turf(src)
						if (isrestrictedz(T.z))
							user.gib()
						else
							user.shock(src, rand(5000, 250000), "chest", 1, 1)
						/*harmless_smoke_puff(get_turf(src))
						playsound(user, 'sound/effects/ghost2.ogg', 60, FALSE)
						user.flash(60)
						var/mob/oldmob = user
						var/mob/dead/observer/O = new/mob/dead/observer()
						O.set_loc(get_turf(src))
						oldmob.sleeping = 1
						oldmob.weakened = 600
						var/datum/mind/M = user.mind
						if (M) //Why would this happen? Why wouldn't it happen?
							M.transfer_to(O)
							SPAWN(1 MINUTE)
								if (M && oldmob)
									var/mob/newmob = M.current
									M.transfer_to(oldmob)
									qdel(newmob)
									oldmob.paralysis += 3
									oldmob.sleeping = 0
									oldmob.delStatus("knockdown")

								using = 0*/
					if ("Bend the relic's power to your will")
						using = 1
						boutput(user, SPAN_ALERT("You can feel the power of the relic coursing through you..."))
						user.bioHolder.AddEffect("telekinesis_drag")
						SPAWN(2 MINUTES)
							using = 0
							user.bioHolder.RemoveEffect("telekinesis_drag")
					if ("Use the relic's power to heal your wounds")
						var/obj/shield/s = new/obj/shield( get_turf(src) )
						s.name = "energy"
						SPAWN(1.3 SECONDS) qdel(s)
						user.changeStatus("stunned", 1 SECOND)
						user.take_toxin_damage(-INFINITY)
						user:HealDamage("All", 1000, 1000)
						if (prob(75))
							boutput(user, SPAN_ALERT("The relic crumbles into nothingness..."))
							qdel(src)
						SPAWN(1 MINUTE) using = 0
					if ("Attempt to absorb the relic's power")
						if (prob(1))
							user.bioHolder.AddEffect("telekinesis_drag", 0, 0, 1) //because really
							user.bioHolder.AddEffect("thermal_resist", 0, 0, 1) //if they're lucky enough to get this
							user.bioHolder.AddEffect("xray", 2, 0, 1) //they're lucky enough to keep it
							user.bioHolder.AddEffect("hulk", 0, 0, 1) //probably
							boutput(user, SPAN_ALERT("The relic crumbles into nothingness..."))
							src.invisibility = INVIS_ALWAYS
							var/obj/effects/explosion/E = new/obj/effects/explosion( get_turf(src) )
							E.fingerprintslast = src.fingerprintslast
							sleep(0.5 SECONDS)
							E = new/obj/effects/explosion( get_turf(src) )
							E.fingerprintslast = src.fingerprintslast
							sleep(0.5 SECONDS)
							E = new/obj/effects/explosion( get_turf(src) )
							E.fingerprintslast = src.fingerprintslast
							qdel(src)
						else
							switch(pick(175;1,30;2,25;3,85;4))
								if (1)
									boutput(user, SPAN_ALERT("The relic's power overwhelms you!"))
									user:changeStatus("knockdown", 10 SECONDS)
									user:TakeDamage("chest", 0, 33)
								if (2)
									boutput(user, SPAN_ALERT("The relic explodes in a bright flash, blinding you!"))
									user.flash(60)
									user.bioHolder.AddEffect("blind")
									qdel(src)
								if (3)
									boutput(user, SPAN_ALERT("The relic explodes violently!"))
									var/obj/effects/explosion/E = new/obj/effects/explosion( get_turf(src) )
									E.fingerprintslast = src.fingerprintslast
									logTheThing(LOG_COMBAT, user, "was gibbed by [src] ([src.type]) at [log_loc(user)].")
									user:gib()
									qdel(src)
								if (4)
									boutput(user, SPAN_ALERT("The relic's power completely overwhelms you!!"))
									using = 1
									harmless_smoke_puff( get_turf(src) )
									playsound(user, 'sound/effects/ghost2.ogg', 60, FALSE)
									logTheThing(LOG_COMBAT, user, "was killed by [src] ([src.type]) at [log_loc(user)].")
									user.flash(60)
									var/mob/oldmob = user
									oldmob.ghostize()
									oldmob.death()
									using = 0
				beingUsed = 0


/obj/effect_sparker
	icon = 'icons/misc/mark.dmi'
	icon_state = "x4"
	invisibility = INVIS_ALWAYS
	anchored = ANCHORED
	density = 0

	New()
		src.sparks()
		return ..()

	proc/sparks()
		var/area/A = get_area(src)
		if (A.active)
			elecflash(src)
		SPAWN(rand(10,300))
			src.sparks()



//Same as the thing below just for density and without support for atoms.
/proc/can_line(var/atom/source, var/atom/target, var/length=5)
	var/turf/current = get_turf(source)
	var/turf/target_turf = get_turf(target)
	var/steps = 0

	while(current != target_turf)
		if (steps > length) return 0
		if (!current) return 0
		if (current.density) return 0
		current = get_step_towards(current, target_turf)
		steps++

	return 1

/proc/can_line_airborne(var/atom/source, var/atom/target, var/length=5)
	var/turf/current = get_turf(source)
	var/turf/target_turf = get_turf(target)
	var/steps = 0

	while(current != target_turf)
		if (steps > length) return 0
		if (!current) return 0
		if (current.density) return 0 //If we can avoid the more expensive Cross check, let's
		if (!current.Cross(source)) return 0

		current = get_step_towards(current, target_turf)
		steps++

	return 1


