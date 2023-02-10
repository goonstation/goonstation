//
// This file contains stuff that was originally made by me and then expanded on or butchered by other people.
// - Keelin
//

//proc/can_see(var/atom/source, var/atom/target, var/length=5)

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

/proc/ff_cansee(var/atom/A, var/atom/B)
	var/AT = get_turf(A)
	var/BT = get_turf(B)
	if (AT == BT)
		return 1
	var/list/line = getline(A,B)
	for (var/turf/T in line)
		if (!T.gas_cross(T))
			return 0
		var/obj/blob/BL = locate() in T
		if (istype(BL, /obj/blob/wall) || istype(BL, /obj/blob/firewall) || istype(BL, /obj/blob/reflective))
			return 0
	return 1

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
			boutput(M, "<span class='alert'>You feel uneasy ...</span>")

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
			boutput(user, "<span class='alert'>The relic is humming loudly.</span>")
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
						playsound(user, 'sound/effects/ghost2.ogg', 60, 0)
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
									oldmob.delStatus("weakened")

								using = 0*/
					if ("Bend the relic's power to your will")
						using = 1
						boutput(user, "<span class='alert'>You can feel the power of the relic coursing through you...</span>")
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
							boutput(user, "<span class='alert'>The relic crumbles into nothingness...</span>")
							qdel(src)
						SPAWN(1 MINUTE) using = 0
					if ("Attempt to absorb the relic's power")
						if (prob(1))
							user.bioHolder.AddEffect("telekinesis_drag", 0, 0, 1) //because really
							user.bioHolder.AddEffect("thermal_resist", 0, 0, 1) //if they're lucky enough to get this
							user.bioHolder.AddEffect("xray", 2, 0, 1) //they're lucky enough to keep it
							user.bioHolder.AddEffect("hulk", 0, 0, 1) //probably
							boutput(user, "<span class='alert'>The relic crumbles into nothingness...</span>")
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
									boutput(user, "<span class='alert'>The relic's power overwhelms you!</span>")
									user:changeStatus("weakened", 10 SECONDS)
									user:TakeDamage("chest", 0, 33)
								if (2)
									boutput(user, "<span class='alert'>The relic explodes in a bright flash, blinding you!</span>")
									user.flash(60)
									user.bioHolder.AddEffect("blind")
									qdel(src)
								if (3)
									boutput(user, "<span class='alert'>The relic explodes violently!</span>")
									var/obj/effects/explosion/E = new/obj/effects/explosion( get_turf(src) )
									E.fingerprintslast = src.fingerprintslast
									logTheThing(LOG_COMBAT, user, "was gibbed by [src] ([src.type]) at [log_loc(user)].")
									user:gib()
									qdel(src)
								if (4)
									boutput(user, "<span class='alert'>The relic's power completely overwhelms you!!</span>")
									using = 1
									harmless_smoke_puff( get_turf(src) )
									playsound(user, 'sound/effects/ghost2.ogg', 60, 0)
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
	anchored = 1
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

///Config datum for LSD fake sounds
/datum/hallucinated_sound
	///The sound file to play
	var/path
	///Max number of times to play it
	var/max_count
	///Min number of times to play it
	var/min_count
	///Delay between each play
	var/delay
	///Pitch to play it at
	var/pitch

	New(path, min_count = 1, max_count = 1, delay = 0, pitch = 1)
		..()
		src.path = path
		src.min_count = min_count
		src.max_count = max_count
		src.delay = delay
		src.pitch = pitch

	///Play the sound to a mob from a location
	proc/play(var/mob/mob, var/atom/location)
		SPAWN(0)
			for (var/i = 1 to rand(src.min_count, src.max_count))
				mob.playsound_local(location, src.path, 100, 1, pitch = src.pitch)
				sleep(src.delay)

/obj/fake_attacker
	icon = null
	icon_state = null
	var/fake_icon = 'icons/misc/critter.dmi'
	var/fake_icon_state = ""
	name = ""
	desc = ""
	density = 0
	anchored = 1
	opacity = 0
	var/mob/living/carbon/human/my_target = null
	var/weapon_name = null
	///Does this hallucination constantly whack you
	var/should_attack = TRUE
	event_handler_flags = USE_FLUID_ENTER

	proc/get_name()
		return src.fake_icon_state

	pig
		fake_icon = 'icons/effects/hallucinations.dmi'
		fake_icon_state = "pig"
		get_name()
			return pick("pig", "DAT FUKKEN PIG")
	spider
		fake_icon_state = "big_spide"
		get_name()
			return pick("giant black widow", "aw look a spider", "OH FUCK A SPIDER")
	slime
		fake_icon = 'icons/effects/hallucinations.dmi'
		fake_icon_state = "slime"
		get_name()
			return pick("red slime", "some gooey thing", "ANGRY CRIMSON POO")
	shambler
		fake_icon = 'icons/effects/hallucinations.dmi'
		fake_icon_state = "shambler"
		get_name()
			return pick("shambler", "strange creature", "OH GOD WHAT THE FUCK IS THAT THING?")
	legworm
		fake_icon_state = "legworm"
	handspider
		fake_icon_state = "handspider"

	eyespider
		fake_icon_state = "eyespider"
	buttcrab
		fake_icon_state = "buttcrab"
		should_attack = FALSE
	bat
		fake_icon_state = "bat"
		get_name()
			return pick("bat", "batty", "the roundest possible bat", "the giant bat that makes all of the rules")
	snake
		fake_icon_state = "rattlesnake"
		get_name()
			return pick("snek", "WHY DID IT HAVE TO BE SNAKES?!", "rattlesnake", "OH SHIT A SNAKE")

	scorpion
		fake_icon_state = "spacescorpion"
		get_name()
			return "space scorpion"

	aberration
		fake_icon_state = "aberration"
		should_attack = FALSE
		get_name()
			return "transposed particle field"

	capybara
		fake_icon_state = "capybara"
		should_attack = FALSE

	frog
		fake_icon_state = "frog"
		should_attack = FALSE

	disposing()
		my_target = null
		. = ..()

/obj/fake_attacker/attackby()
	step_away(src,my_target,2)
	for(var/mob/M in oviewers(world.view,my_target))
		boutput(M, "<span class='alert'><B>[my_target] flails around wildly.</B></span>")
	my_target.show_message("<span class='alert'><B>[src] has been attacked by [my_target] </B></span>", 1) //Lazy.
	return

/obj/fake_attacker/Crossed(atom/movable/M)
	..()
	if (M == my_target)
		step_away(src,my_target,2)
		if (prob(30))
			for(var/mob/O in oviewers(world.view , my_target))
				boutput(O, "<span class='alert'><B>[my_target] stumbles around.</B></span>")


/obj/fake_attacker/New(location, target)
	..()
	SPAWN(30 SECONDS)	qdel(src)
	src.name = src.get_name()
	src.my_target = target
	if (src.fake_icon && src.fake_icon_state)
		var/image/image = image(icon = src.fake_icon, loc = src, icon_state = src.fake_icon_state)
		image.override = TRUE
		target << image
	step_away(src,my_target,2)
	process()

/obj/fake_attacker/proc/process()
	if (!my_target)
		qdel(src)
		return
	if (BOUNDS_DIST(src, my_target) > 0)
		step_towards(src,my_target)
	else
		if (src.should_attack && prob(70) && !ON_COOLDOWN(src, "fake_attack_cooldown", 1 SECOND))
			if (weapon_name)
				if (narrator_mode)
					my_target.playsound_local(my_target.loc, 'sound/vox/weapon.ogg', 40, 0)
				else
					my_target.playsound_local(my_target.loc, "sound/impact_sounds/Generic_Hit_[rand(1, 3)].ogg", 40, 1)
				my_target.show_message("<span class='alert'><B>[my_target] has been attacked with [weapon_name] by [src.name] </B></span>", 1)
				if (prob(20)) my_target.change_eye_blurry(3)
				if (prob(33))
					if (!locate(/obj/overlay) in my_target.loc)
						fake_blood(my_target)
			else
				if (narrator_mode)
					my_target.playsound_local(my_target.loc, 'sound/vox/hit.ogg', 40, 0)
				else
					my_target.playsound_local(my_target.loc, pick(sounds_punch), 40, 1)
				my_target.show_message("<span class='alert'><B>[src.name] has punched [my_target]!</B></span>", 1)
				if (prob(33))
					if (!locate(/obj/overlay) in my_target.loc)
						fake_blood(my_target)
			attack_twitch(src)

	if (src.should_attack && prob(10)) step_away(src,my_target,2)
	SPAWN(0.3 SECONDS) .()

/proc/fake_blood(var/mob/target)
	var/obj/overlay/O = new/obj/overlay(target.loc)
	O.name = "blood"
	var/image/I = image('icons/effects/blood.dmi',O,"floor[rand(1,7)]",O.dir,1)
	target << I
	SPAWN(30 SECONDS)
		qdel(O)
	return

/proc/fake_attack(var/mob/target)
	var/list/possible_clones = new/list()
	var/mob/living/carbon/human/clone = null
	var/clone_weapon = null

	for(var/mob/living/carbon/human/H in mobs)
		if (H.stat || H.lying || H.dir == NORTH) continue
		possible_clones += H

	if (!possible_clones.len) return
	clone = pick(possible_clones)

	if (clone.l_hand)
		clone_weapon = clone.l_hand.name
	else if (clone.r_hand)
		clone_weapon = clone.r_hand.name

	var/obj/fake_attacker/F = new/obj/fake_attacker(target.loc, target)

	F.name = clone.name
	//F.my_target = target
	F.weapon_name = clone_weapon

	var/image/O = image(clone,F)
	target << O

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


