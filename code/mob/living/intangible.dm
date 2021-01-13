/mob/living/intangible
	icon = 'icons/mob/mob.dmi'
	icon_state = "ghost"
	layer = NOLIGHT_EFFECTS_LAYER_BASE
	density = 0
	canmove = 1
	blinded = 0
	anchored = 1
	event_handler_flags = USE_CANPASS | IMMUNE_MANTA_PUSH

	New()
		. = ..()
		src.invisibility = 10
		src.sight |= SEE_TURFS | SEE_MOBS | SEE_OBJS | SEE_SELF
		src.see_invisible = 15
		src.see_in_dark = SEE_DARK_FULL

	can_strip()
		return 0
	can_use_hands()
		return 0
	is_active()
		return 0
	say_understands(var/other)
		return 1
	CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
		return 1

	meteorhit()
		return

	// No log entries for unaffected mobs (Convair880).
	ex_act(severity)
		return

	Move(NewLoc, direct)
		if(!canmove) return

		if (NewLoc && isrestrictedz(src.z) && !restricted_z_allowed(src, NewLoc) && !(src.client && src.client.holder))
			var/OS = pick_landmark(LANDMARK_OBSERVER, locate(1, 1, 1))
			if (OS)
				src.set_loc(OS)
			else
				src.z = 1
			return

		if(!isturf(src.loc))
			src.set_loc(get_turf(src))
		if(NewLoc)
			src.set_loc(NewLoc)
			return
		if((direct & NORTH) && src.y < world.maxy)
			src.y++
		if((direct & SOUTH) && src.y > 1)
			src.y--
		if((direct & EAST) && src.x < world.maxx)
			src.x++
		if((direct & WEST) && src.x > 1)
			src.x--

/mob/living/intangible/change_eye_blurry(var/amount, var/cap = 0)
	if (amount < 0)
		return ..()
	else
		return 1

/mob/living/intangible/take_eye_damage(var/amount, var/tempblind = 0)
	if (amount < 0)
		return ..()
	else
		return 1

/mob/living/intangible/take_ear_damage(var/amount, var/tempdeaf = 0)
	if (amount < 0)
		return ..()
	else
		return 1
