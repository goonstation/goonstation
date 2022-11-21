// -----------------------------------------------------------------------------
// RIFT
// -----------------------------------------------------------------------------
/obj/flock_structure/rift
	icon = 'icons/misc/featherzone.dmi'
	icon_state = "rift"
	density = FALSE
	name = "glowing portal thingymabob"
	desc = "Oh god is that a fucking light grenade?!"
	flock_desc = "The rift through which your Flock will enter this world."
	flock_id = "Entry Rift"
	build_time = 10
	health = 200
	uses_health_icon = FALSE
	var/list/eject = list()

/obj/flock_structure/rift/New()
	..()
	src.info_tag.set_info_tag("Entry time: [src.build_time] seconds")

/obj/flock_structure/rift/building_specific_info()
	var/time_remaining = round(src.build_time - getTimeInSecondsSinceTime(src.time_started))
	return "Approximately <span class='bold'>[time_remaining]</span> second[time_remaining == 1 ? "" : "s"] left until entry."

/obj/flock_structure/rift/process()
	var/elapsed = getTimeInSecondsSinceTime(src.time_started)
	src.info_tag.set_info_tag("Entry time: [round(src.build_time - elapsed)] seconds")
	if(elapsed >= build_time)
		src.visible_message("<span class='text-blue'>Multiple shapes exit out of [src]!</span>")
		for(var/i in 1 to 4 + src.flock?.player_mod)
			var/obj/item/flockcache/x = new(src.contents)
			x.resources = 40
			eject += x
		for(var/i in 1 to 4 + src.flock?.player_mod)
			var/obj/flock_structure/egg/e = new(src.contents, src.flock)
			eject += e
		var/obj/flock_structure/egg/bit/bitegg = new(src.contents, src.flock)
		eject += bitegg
		var/list/candidate_turfs = list()
		for(var/turf/simulated/floor/S in range(src, 2)) // 5x5
			if (istype(S, /turf/simulated/floor/feather))
				continue
			candidate_turfs += S
		shuffle_list(candidate_turfs)
		if (length(candidate_turfs) > 13)
			candidate_turfs = candidate_turfs.Copy(1, 14)

		var/sentinel_count = 2
		for(var/turf/simulated/floor/floor as anything in candidate_turfs)
			if (src.flock)
				src.flock.claimTurf(flock_convert_turf(floor))
			else
				flock_convert_turf(floor)
		for (var/i in 1 to min(sentinel_count, length(candidate_turfs)))
			var/turf/simulated/floor/feather/floor = candidate_turfs[i]
			if (!flock_is_blocked_turf(floor))
				new /obj/flock_structure/sentinel(floor, src.flock)

		flockdronegibs(src.loc, null, eject) //ejectables ejected here
		src.flock.flockmind.started = TRUE
		qdel(src)
	else
		var/severity = round(((build_time - elapsed)/build_time) * 5)
		animate_shake(src, severity, severity)

/obj/flock_structure/rift/disposing()
	if (!src.flock?.flockmind?.started)
		src.flock?.flockmind?.death()
	..()
