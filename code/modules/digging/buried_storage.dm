/*
 * Copyright (C) 2025 Mr. Moriarty
 * Copyright (C) 2025 Firedhat
 *
 * Originally contributed to the 35 Below Project
 * Made available under the terms of the CC BY-NC-SA 3.0
 * Full terms available in the "LICENSE" file or at:
 * http://creativecommons.org/licenses/by-nc-sa/3.0/us/
 */


/// How many times do people have to dig from inside to get out
#define BURIED_DIG_OUT_THESHOLD 20
/// How many digs should cause cracks to form at the surface?
#define BURIED_CRACKS_FORM_THRESHOLD 15
/// Probability of converting a relaymove into a dig out
#define BURIED_DIG_OUT_CHANCE 30

/atom/movable/buried_storage
	icon = null
	icon_state = null
	plane = PLANE_NOSHADOW_BELOW
	density = 0
	mouse_opacity = 0
	pass_unstable = FALSE

	var/turf/parent_turf
	var/has_buried_mob = FALSE
	var/number_of_objects = 0
	var/dig_outs = 0
	var/last_relaymove_time
	var/obj/overlay/tile_effect/cracks/my_cracks

	New(newLoc)
		. = ..()
		src.parent_turf = newLoc

	disposing()
		qdel(src.my_cracks)
		src.my_cracks = null
		src.parent_turf = null
		. = ..()

	Exited(Obj, newloc)
		. = ..()
		if (isliving(Obj))
			UnregisterSignal(Obj, COMSIG_MOB_FLIP)

	relaymove(mob/user, direction, delay, running)
		if (is_incapacitated(user))
			return
		if (src.hasStatus("teleporting"))
			return
		if (world.time < (src.last_relaymove_time + DEFAULT_INTERNAL_RELAYMOVE_DELAY))
			return
		src.last_relaymove_time = world.time
		src.dig_out_from_inside(user)

	proc/mob_flip_inside(mob/user)
		src.dig_out_from_inside(user)

	proc/move_turf_contents_to_storage()
		for (var/atom/movable/AM as anything in parent_turf)
			if (!istype(AM, /obj) && !istype(AM, /mob))
				continue
			if(AM == src || AM.invisibility || AM.anchored)
				continue
			continue_if_overlay_or_effect(AM)

			if (istype(AM, /mob))
				if (isliving(AM))
					var/mob/living/M = AM
					if (!isdead(M))
						boutput(M, SPAN_COMBAT("You're buried alive! <b>HOLY SHIT</b>!"))
					RegisterSignal(M, COMSIG_MOB_FLIP, PROC_REF(mob_flip_inside))

				if (src.has_buried_mob)
					continue

				src.has_buried_mob = TRUE

			else
				if (src.number_of_objects >= 3)
					if (src.has_buried_mob)
						return

					continue

				else
					src.number_of_objects += 1

			AM.set_loc(src)

	proc/move_storage_contents_to_turf(turf/target_turf=null)
		if (isnull(target_turf))
			target_turf = src.parent_turf
		for (var/atom/movable/AM as anything in src)
			AM.set_loc(target_turf)

		src.has_buried_mob = FALSE
		src.number_of_objects = 0

	proc/dig_out_from_inside(mob/user)
		if (prob(BURIED_DIG_OUT_CHANCE))
			boutput(user, SPAN_ALERT("You make some progress through the ground above..."))
			src.dig_outs += 1
			src.parent_turf.visible_message(SPAN_NOTICE("Something stirs beneath the ground..."))
			playsound(
				src.parent_turf,
				pick('sound/effects/shovel1.ogg', 'sound/effects/shovel2.ogg', 'sound/effects/shovel3.ogg'),
				vol=(70 * (src.dig_outs/BURIED_DIG_OUT_THESHOLD))
			)
			if (src.dig_outs >= BURIED_DIG_OUT_THESHOLD)
				src.parent_turf.dig_trench()
				src.move_storage_contents_to_turf()
				return

			if (src.dig_outs > BURIED_CRACKS_FORM_THRESHOLD && isnull(src.my_cracks))
				src.my_cracks = new(src.parent_turf)

#undef BURIED_DIG_OUT_THESHOLD
#undef BURIED_CRACKS_FORM_THRESHOLD
#undef BURIED_DIG_OUT_CHANCE
