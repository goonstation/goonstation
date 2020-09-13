//
// rift thingymabob
//
/obj/flock_structure/rift
	icon = 'icons/misc/featherzone.dmi'
	icon_state = "rift"
	anchored = 0
	density = 0
	name = "glowing portal thingymabob"
	desc = "Oh god is that a fucking light grenade?!"
	flock_id = "Entry Rift"
	build_time = 10
	health = 200 // stronk little thing
	var/decal_made = 0 // for splashing stuff on throw
	var/list/eject = list()
	var/mainflock = null // for when a flockmind is spawning the little shits(read:drones) get assigned to it

/obj/flock_structure/rift/New(var/atom/location, var/datum/flock/F=null)
	..()
	if(src.flock)
		src.flock.registerUnit(src)

/obj/flock_structure/rift/building_specific_info()
	var/time_remaining = round(src.build_time - getTimeInSecondsSinceTime(src.time_started))
	return "Approximately <span class='bold'>[time_remaining]</span> second[time_remaining == 1 ? "" : "s"] left until entry."

/obj/flock_structure/rift/process()
	var/elapsed = getTimeInSecondsSinceTime(src.time_started)
	if(elapsed >= build_time)
		src.visible_message("<span class='text-blue'>Multiple shapes exit out of [src]!</span>")
		var/j = pick(4, 5)
		for(var/i=1, i<j, i++) //here im using the flockdronegibs proc to handle throwing things out randomly. in these for loops im just creating the objects (resource caches and flockdrone eggs) and adding them to the list (eject) which will get thrown about
			var/obj/item/flockcache/x = new(src.contents)
			x.resources = rand(40, 50)
			eject += x
		for(var/i=1, i<5, i++)
			var/obj/flock_structure/egg/e = new(src.contents, src.flock)
			eject += e
			e.flock = mainflock
		var/list/candidate_turfs = list()
		for(var/turf/simulated/floor/S in orange(src, 4))
			candidate_turfs += S
		for(var/i=1, i<11, i++)
			for(var/S in candidate_turfs)
				if(istype(S, /turf/simulated/floor/feather))
					candidate_turfs -= S
					continue
				if(prob(25))
					flock_convert_turf(S)
					candidate_turfs -= S
					break
		flockdronegibs(src.loc, null, eject)//here they are actually ejected
		if(src.flock)
			src.flock.removeDrone(src)
		qdel(src)
	else
		var/severity = round(((build_time - elapsed)/build_time) * 5)
		animate_shake(src, severity, severity)
