// -----------------------------------------------------------------------------
// RIFT
// -----------------------------------------------------------------------------
/obj/flock_structure/rift
	icon = 'icons/misc/featherzone.dmi'
	icon_state = "rift"
	density = FALSE
	name = "glowing portal thingymabob"
	desc = "That doesn't look human."
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
		if (src.flock.flockmind.tutorial) //simplify down to a single drone during tutorial
			flockdronegibs(src.loc, null, list(new /obj/flock_structure/egg/tutorial(src.contents, src.flock)))
			src.flock.flockmind.started = TRUE
			src.flock.flockmind.tutorial.PerformAction(FLOCK_ACTION_RIFT_COMPLETE)
			qdel(src)
		else
			src.open()
	else
		var/severity = round(((build_time - elapsed)/build_time) * 5)
		animate_shake(src, severity, severity)

/obj/flock_structure/rift/proc/open()
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
	var/sentinels_made = 0
	for(var/turf/simulated/floor/floor as anything in candidate_turfs)
		if (src.flock)
			src.flock.claimTurf(flock_convert_turf(floor))
		else
			flock_convert_turf(floor)
	for (var/turf/simulated/floor/feather/flocktile as anything in candidate_turfs)
		if (!flock_is_blocked_turf(flocktile))
			new /obj/flock_structure/sentinel(flocktile, src.flock)
			sentinels_made++
			if (sentinels_made >= sentinel_count)
				break

	flockdronegibs(src.loc, null, eject) //ejectables ejected here
	src.flock.flockmind.started = TRUE
	qdel(src)

/obj/flock_structure/rift/disposing()
	if (!src.flock?.flockmind?.started)
		src.flock?.flockmind?.death()
	..()
