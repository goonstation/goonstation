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
	var/list/eject = list()

/obj/flock_structure/rift/building_specific_info()
	var/time_remaining = round(src.build_time - getTimeInSecondsSinceTime(src.time_started))
	return "Approximately <span class='bold'>[time_remaining]</span> second[time_remaining == 1 ? "" : "s"] left until entry."

/obj/flock_structure/rift/process()
	var/elapsed = getTimeInSecondsSinceTime(src.time_started)
	if(elapsed >= build_time)
		src.visible_message("<span class='text-blue'>Multiple shapes exit out of [src]!</span>")
		for(var/i in 1 to pick(3, 4))
			var/obj/item/flockcache/x = new(src.contents)
			x.resources = rand(40, 50)
			eject += x
		for(var/i in 1 to 4)
			var/obj/flock_structure/egg/e = new(src.contents, src.flock)
			eject += e
		var/obj/flock_structure/egg/bit/bitegg = new(src.contents, src.flock)
		eject += bitegg
		var/list/candidate_turfs = list()
		for(var/turf/simulated/floor/S in orange(src, 4))
			candidate_turfs += S
		for(var/i in 1 to 10)
			for(var/S in candidate_turfs)
				if(istype(S, /turf/simulated/floor/feather))
					candidate_turfs -= S
					continue
				if(prob(25))
					if (src.flock)
						src.flock.claimTurf(flock_convert_turf(S))
					else
						flock_convert_turf(S)
					candidate_turfs -= S
					break
		flockdronegibs(src.loc, null, eject) //ejectables ejected here
		src.flock.flockmind.started = TRUE
		qdel(src)
	else
		var/severity = round(((build_time - elapsed)/build_time) * 5)
		animate_shake(src, severity, severity)
