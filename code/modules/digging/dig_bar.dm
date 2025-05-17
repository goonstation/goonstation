/*
 * Copyright (C) 2025 Mr. Moriarty
 * Copyright (C) 2025 DisturbHerb
 * Copyright (C) 2025 Bartimeus
 * Copyright (C) 2010,2016,2020-2025 Goonstation Contributors
 *
 * Contributed to the 35 Below Project, derived at least 10.9%
 * from code in Goonstation available through the terms of the
 * CreativeCommons BY-NC-SA 3.0 United States License ONLY.
 * Full terms available in the "LICENSE" file or at:
 * http://creativecommons.org/licenses/by-nc-sa/3.0/us/
 */

/datum/action/bar/dig_trench
	duration = 5 SECONDS
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ATTACKED | INTERRUPT_ACTION | INTERRUPT_ACT
	id = "dig_trench"
	resumable = TRUE
	var/turf/turf

	New(turf)
		. = ..()
		src.turf = turf

	onUpdate()
		..()
		if (BOUNDS_DIST(src.owner, src.turf) > 0 || !src.turf)
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		if (BOUNDS_DIST(src.owner, src.turf) > 0 || !src.turf)
			interrupt(INTERRUPT_ALWAYS)
			return

		if (istype(src.turf, /turf/simulated/floor/auto/trench) && (get_turf(src.owner) == src.turf))
			interrupt(INTERRUPT_ALWAYS)
			boutput(src.owner, SPAN_ALERT("You can't bury yourself!"))
			return

		src.owner.visible_message(SPAN_NOTICE("[src.owner] starts [src.digging_or_burying()] [src.turf]!"), group = "trench-dig")
		src.play_digging_sound()

	onEnd()
		..()
		if (BOUNDS_DIST(src.owner, src.turf) > 0 || !src.turf)
			interrupt(INTERRUPT_ALWAYS)
			return

		if (istype(src.turf, /turf/simulated/floor/auto/trench))
			for(var/atom/movable/AM as anything in src.turf)
				if (isitem(AM))
					var/obj/item/O = AM
					if ((O.object_flags & NO_GHOSTCRITTER)) // approximating "important items"
						logTheThing(LOG_STATION, src.owner, "buried notable item [O] at [log_loc(src.turf)].")
				else if (ismob(AM))
					logTheThing(LOG_COMBAT, src.owner, "buried mob [constructTarget(AM, "combat")] at [log_loc(src.turf)].")

		src.owner.visible_message(SPAN_NOTICE("[src.owner] finishes [src.digging_or_burying()] [src.turf]!"))
		src.turf.dig_trench()
		for (var/obj/tombstone/grave in orange(src.turf, 1))
			if (istype(grave) && !grave.robbed)
				grave.robbed = 1
				//idea: grave robber medal.
				if (grave.special)
					new grave.special (src.turf)
				else
					switch (rand(1, 5))
						if (1)
							new /obj/item/skull {desc = "A skull.  That was robbed.  From a grave.";} ( src.turf )
						if (2)
							new /obj/item/sheet/wood {name = "rotted coffin wood"; desc = "Just your normal, everyday rotten wood.  That was robbed.  From a grave.";} ( src.turf )
						if (3)
							new /obj/item/clothing/under/suit/pinstripe {name = "old pinstripe suit"; desc  = "A pinstripe suit.  That was stolen.  Off of a buried corpse.";} ( src.turf )
						else
							; // default
				break

	proc/digging_or_burying()
		if (istype(src.turf, /turf/simulated/floor/auto/trench))
			return "burying"

		return "digging up"

	proc/play_digging_sound()
		if (src.state == ACTIONSTATE_RUNNING)
			var/sound = pick('sound/effects/shovel1.ogg', 'sound/effects/shovel2.ogg', 'sound/effects/shovel3.ogg')
			playsound(src.turf, sound, 50, 1, 0.3)

			SPAWN((rand(11, 14) / 10) SECONDS)
				src.play_digging_sound()



/datum/action/bar/climb_trench
	duration = 1 SECOND
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	id = "climb_trench"
	resumable = TRUE
	var/mob/owner_mob
	var/turf/trench
	var/list/collision_whitelist = null

	New(owner, trench)
		..()
		collision_whitelist = typesof(/obj/railing, /obj/decal/stage_edge, /obj/sec_tape)
		owner = owner
		src.owner_mob = owner
		src.trench = trench

	onUpdate()
		..()
		if (BOUNDS_DIST(src.owner_mob, src.trench) > 0)
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		if (BOUNDS_DIST(src.owner_mob, src.trench) > 0 || !src.trench || !src.owner_mob)
			interrupt(INTERRUPT_ALWAYS)
			return

		if (check_for_obstruction())
			boutput(src.owner_mob, SPAN_ALERT("Something is obstructing [src.trench]!"))
			interrupt(INTERRUPT_ALWAYS)
			return

		src.owner_mob.visible_message(SPAN_NOTICE("[src.owner_mob] begins to climb [src.into_or_out_of()] the hole."))

	onEnd()
		..()
		sendOwner()

	proc/into_or_out_of()
		if (istype(src.trench, /turf/simulated/floor/auto/trench))
			return "into"

		return "out of"

	proc/check_for_obstruction()
		var/obj/obstacle = null
		var/direction = get_dir(get_turf(owner), src.trench)

		if (src.trench.density)
			obstacle = src.trench.name
		else
			// Is the trench blocked?
			obstacle = check_turf_obstacles(src.trench)

			// If the trench is not blocked, is the owner moving in an ordinal direction? If so, consider corners.
			if (!obstacle && (direction in ordinal))
				var/turf/T1 = get_step(get_turf(owner), turn(direction, 45))
				obstacle = check_turf_obstacles(T1)

				if (obstacle) // T1 was blocked, but was T2 also blocked?
					var/turf/T2 = get_step(get_turf(owner), turn(direction, -45))
					obstacle = check_turf_obstacles(T2)


		if(obstacle)
			return TRUE

		return FALSE

	proc/check_turf_obstacles(turf/T)
		for (var/obj/O in T.contents)
			if (!O.density)
				continue
			if (O.type in collision_whitelist)
				continue
			return O

	proc/sendOwner()
		src.owner_mob.set_loc(src.trench)
		src.owner_mob.visible_message(SPAN_NOTICE("[src.owner_mob] climbs [src.into_or_out_of()] the trench."))
