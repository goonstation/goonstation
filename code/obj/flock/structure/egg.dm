/////////////////////////////////////////////////////////////////////////////////
// EGG
/////////////////////////////////////////////////////////////////////////////////
/obj/flock_structure/egg
	icon = 'icons/misc/featherzone.dmi'
	icon_state = "egg"
	anchored = 0
	density = 0
	name = "glowing doodad"
	desc = "Oh god is that a fucking light grenade?!"
	flock_id = "Second-Stage Assembler"
	build_time = 6
	health = 30 // fragile little thing
	var/decal_made = 0 // for splashing stuff on throw

/obj/flock_structure/egg/New(var/atom/location, var/datum/flock/F=null)
	..()
	if(src.flock)
		src.flock.registerUnit(src)

/obj/flock_structure/egg/building_specific_info()
	var/time_remaining = round(src.build_time - getTimeInSecondsSinceTime(src.time_started))
	return "Approximately <span class='bold'>[time_remaining]</span> second[time_remaining == 1 ? "" : "s"] left until hatching."

/obj/flock_structure/egg/process()
	var/elapsed = getTimeInSecondsSinceTime(src.time_started)
	if(elapsed >= build_time)
		src.visible_message("<span class='notice'>[src] breaks open!</span>")
		new /mob/living/critter/flock/drone(get_turf(src), src.flock)
		src.set_loc(null)
		SPAWN_DBG(1 SECOND)
			if(src.flock)
				src.flock.removeDrone(src)
			qdel(src)
	else
		var/severity = round(((build_time - elapsed)/build_time) * 5)
		animate_shake(src, severity, severity)

/obj/flock_structure/egg/throw_impact(var/atom/A)
	var/turf/T = get_turf(A)
	playsound(src.loc, "sound/impact_sounds/Crystal_Hit_1.ogg", 100, 1)
	if (T && !decal_made)
		playsound(src.loc, "sound/impact_sounds/Slimy_Splat_1.ogg", 80, 1)
		make_cleanable( /obj/decal/cleanable/flockdrone_debris/fluid,T)
		decal_made = 1
	..()
