TYPEINFO(/mob/living/intangible/wraith/poltergeist)
	start_speech_outputs = list(SPEECH_OUTPUT_DEADCHAT_POLTERGEIST)

/mob/living/intangible/wraith/poltergeist
	name = "Poltergeist"
	real_name = "Poltergeist"
	desc = "Jesus Christ, how spooky."
	icon = 'icons/mob/mob.dmi'
	icon_state = "poltergeist"
	deaths = 1					//only 1 life
	hud_path = /datum/hud/wraith/poltergeist
	var/mob/living/intangible/wraith/master = null
	var/obj/spookMarker/marker = null
	forced_haunt_duration = 15 SECONDS
	death_icon_state = "derangedghost"
	weak_tk = TRUE
	var/max_dist_marker = 15
	var/max_dist_master = 12
	var/following_master = 0

	//this might be real shit, but there's not really a lot of poltergeists in a round so w/e
	var/dist_from_master = 0
	var/dist_from_marker = 0
	var/power_well_dist = 0		//the lesser of the two distances from master/marker

	var/atom/movable/overlay/orbit_anchor = null	//empty dummy object that is attached to wraith for poltergeists to orbit around

	make_name()
		var/len = rand(4, 6)
		var/vowel_prob = 0
		var/list/con = list("h","n", "k", "s", "l", "t", "r", "sh", "m", "d")
		var/list/vow = list("o", "a", "i", "u", "ou")
		var/theName = ""
		for (var/i = 1, i <= len, i++)
			if (prob(vowel_prob))
				vowel_prob = 0
				theName += pick(vow)
			else
				vowel_prob += rand(15, 40)
				theName += pick(con)
		var/fc = copytext(theName, 1, 2)
		theName = "[uppertext(fc)][copytext(theName, 2)]"
		if (prob(2))
			theName = pick("Peeves", "Peevs", "Peves", "Casper")
		theName = theName  + "[pick(" the Poltergeist", " the Mischievous", " the Playful", " the Trickster", " the Sneaky", " the Child", " the Kid", " the Ass", " the Inquisitive", " the Exiled")]"
		return theName

	New(var/turf/T, var/mob/living/intangible/wraith/master, var/obj/spookMarker/marker)
		..(T)
		src.master = master
		src.marker = marker

		//poltergeists can't make child poltergeists so lets just null this
		src.poltergeists = null

		//just in cases
		if (isnull(master.poltergeists))
			master.poltergeists = list()

		master.poltergeists += src

		orbit_anchor = new (src)
		orbit_anchor.icon_state = "blank"
		orbit_anchor.icon = 'icons/mob/mob.dmi'
		orbit_anchor.master = src
		orbit_anchor.mouse_opacity = 0

	Life(parent)
		..()
		if (!marker && !master)
			death()
			boutput(src, "Your portal and master have been destroyed, you return to the nether.")

		update_well_dist(master, marker)

		if (loc == master && src.health < src.max_health)
			HealDamage("chest", 5, 0)
			//get more points when following your master
			var/denom = 1
			if (islist(master?.poltergeists))
				denom = master?.poltergeists.len
			src.abilityHolder.points += master.abilityHolder.regenRate/min(2, denom+1)

		else if (dist_from_master > max_dist_marker && dist_from_marker > max_dist_master && health > 50)
			TakeDamage("all", 5, 0)
			// boutput(src, SPAN_ALERT("You are damaged from being too far from a well of power!"))
		//else
			//You're close to a well of power, gain extra spell points

	death()
		if (master)
			master.poltergeists -= src
			boutput(master, SPAN_ALERT("Your poltergeist, [src], has been destroyed!"))
		qdel(marker)
		..()

	disposing()
		qdel(marker)
		master?.poltergeists -= src
		master = null
		qdel(orbit_anchor)
		..()

	addAllBasicAbilities()
		src.addAbility(/datum/targetable/wraithAbility/decay)
		src.addAbility(/datum/targetable/wraithAbility/command)
		src.addAbility(/datum/targetable/wraithAbility/animateObject)
		src.addAbility(/datum/targetable/wraithAbility/haunt)
		src.addAbility(/datum/targetable/wraithAbility/spook)
		src.addAbility(/datum/targetable/wraithAbility/whisper)
		src.addAbility(/datum/targetable/wraithAbility/blood_writing)

		src.addAbility(/datum/targetable/wraithAbility/retreat)

	removeAllAbilities()
		src.removeAbility(/datum/targetable/wraithAbility/decay)
		src.removeAbility(/datum/targetable/wraithAbility/command)
		src.removeAbility(/datum/targetable/wraithAbility/animateObject)
		src.removeAbility(/datum/targetable/wraithAbility/haunt)
		src.removeAbility(/datum/targetable/wraithAbility/spook)
		src.removeAbility(/datum/targetable/wraithAbility/whisper)
		src.removeAbility(/datum/targetable/wraithAbility/blood_writing)

		src.removeAbility(/datum/targetable/wraithAbility/retreat)

	Move(var/turf/NewLoc, direct)
		..()
		update_well_dist(master, marker)

	click(atom/target)
		. = ..()
		if (target == master)
			src.enter_master()

	//returns success/failure
	proc/enter_master()
		if (!isnull(master) && src.loc != master)
			src:following_master = 1
			src.set_loc(master)
			orbit_master_animation()


			if (istype(hud, /datum/hud/wraith/poltergeist))
				var/datum/hud/wraith/poltergeist/p_hud = hud
				p_hud.set_leave_master(1)
			boutput(src, SPAN_ALERT("You start following your master. You can leave by pressing the 'X' Button at the top right and can move around slightly with your movement keys!"))
			return 1
		return 0

	proc/orbit_master_animation()
		//to turn the poltergeist to face the direction they are orbitting
		var/orbit_direction = pick("L", "R")
		var/turn_angle = 90
		if (orbit_direction == "L")
			turn_angle = -90

		//animate the ghost moving in and out
		var/matrix/min = matrix()
		min.Turn(turn_angle)
		min.Translate(0, rand(32, 64))
		var/matrix/max = matrix()
		max.Turn(turn_angle)
		max.Translate(0, rand(96, 128))

		var/t1 = rand(10, 30)
		animate(src, transform = max, time = t1, loop = -1)
		animate(transform = min, time = t1)

		//attach ghost to orbit anchor and spin it
		orbit_anchor.vis_contents += src
		animate_spin(orbit_anchor, orbit_direction, rand(14, 25), -1)

		//attach orbit anchor to the master wraith
		master.vis_contents += orbit_anchor

	//desination, where to deposit you. on master's tile if null
	//returns success/failure
	proc/exit_master(var/turf/destination = null)
		if (src.loc == master)
			src:following_master = 0
			if (!isturf(destination))
				src.set_loc(get_turf(master))
			else
				src.set_loc(destination)

			//stop orbitting animations, remove from vis_contents
			animate(src, transform = null)
			animate(orbit_anchor, transform = null)

			orbit_anchor.vis_contents -= src
			master.vis_contents -= orbit_anchor

			if (istype(hud, /datum/hud/wraith/poltergeist))
				var/datum/hud/wraith/poltergeist/p_hud = hud
				p_hud.set_leave_master(0)
			return 1
		return 0


	//values, TRUE, FALSE. which, if any of these two do we want to update the distances of
	proc/update_well_dist(var/update_master, var/update_marker)
		if (update_master)
			dist_from_master = master ? GET_DIST(src, master) : 0
		if (update_marker)
			dist_from_marker = marker ? GET_DIST(src, marker) : 0

		//lesser of dist from master and marker
		power_well_dist = min(dist_from_master, dist_from_marker)
		//Maybe display, but that could be too fast...
		// hud_path needs to be /datum/hud/wraith/poltergeist here
		if (istype(hud, /datum/hud/wraith/poltergeist))
			var/datum/hud/wraith/poltergeist/p_hud = hud
			p_hud.update_well_dist(power_well_dist)

//switch to poltergeist after testing
/mob/living/intangible/wraith/poltergeist/set_loc(atom/new_loc, new_pixel_x = 0, new_pixel_y = 0)
	. = ..(new_loc)

	//wraith shit
	if (iswraith(src.loc))	//&& src.loc == src.master
		var/mob/living/intangible/wraith/W = src.loc
		src.override_movement_controller = W.movement_controller
		//Remove this shit after testing --kyle
		src.following_master = 1
	else
		override_movement_controller = null
		src.following_master = 0

/////////////////abilities////////////////////////

//Only for poltergeist
/datum/targetable/wraithAbility/retreat
	name = "Retreat"
	icon_state = "spook"
	desc = "Retreat to the safety of your Master or your Anchor."
	targeted = 1
	target_anything = 1
	pointCost = 100
	cooldown = 1 MINUTES
	min_req_dist = INFINITY

	cast(atom/target)
		if (..())
			return 1

		if (ispoltergeist(holder.owner))
			var/mob/living/intangible/wraith/poltergeist/P = holder.owner
			if (P.density)
				boutput(P, SPAN_ALERT("You cannot retreat while corporeal!"))
				return 1

			var/I = tgui_input_list(holder.owner, "Where to retreat", "Where to retreat", list("Master", "Anchor"))
			if (!I)
				return TRUE
			switch (I)
				if ("Master")
					if (!isnull(P.master))
						P.enter_master()
					else
						boutput(P, "Your master has been banished from this plane of existence! You cannot follow them yet!")
						return 1

				if ("Anchor")
					if (!isnull(P.marker))
						P.set_loc(get_turf(P.marker))
						boutput(P, "You retreat to your anchor...")
					else
						boutput(P, "Your anchor has been destroyed! You have no tether there anymore!")
						return 1

		else
			boutput(holder.owner, "Kiiiiinda need to be a poltergeist to use this ability. Something is fucked if you see this...")
