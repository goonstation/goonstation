/////////////////////////////////////////////////////////////////////////////////
// EGG
/////////////////////////////////////////////////////////////////////////////////
/obj/flock_structure/egg
	icon = 'icons/misc/featherzone.dmi'
	icon_state = "egg"
	anchored = FALSE
	density = FALSE
	name = "glowing doodad"
	desc = "Some sort of small machine. It looks like its getting ready for something."
	flock_desc = "Will soon hatch into a Flockdrone."
	flock_id = "Second-Stage Assembler"
	build_time = 6
	health = 30
	uses_health_icon = FALSE
	var/decal_made = FALSE // for splashing stuff on throw

/obj/flock_structure/egg/New()
	..()
	src.flock?.updateEggCost()
	src.info_tag.set_info_tag("Time left: [src.build_time] seconds")

/obj/flock_structure/egg/building_specific_info()
	var/time_remaining = round(src.build_time - getTimeInSecondsSinceTime(src.time_started))
	return "Approximately <span class='bold'>[time_remaining]</span> second[time_remaining == 1 ? "" : "s"] left until hatching."

/obj/flock_structure/egg/process()
	var/elapsed = getTimeInSecondsSinceTime(src.time_started)
	src.info_tag.set_info_tag("Time left: [round(src.build_time - elapsed)] seconds")
	if(elapsed >= build_time)
		src.visible_message("<span class='notice'>[src] breaks open!</span>")
		src.spawn_contents()
		qdel(src)
	else
		var/severity = round(((build_time - elapsed)/build_time) * 5)
		animate_shake(src, severity, severity)

/obj/flock_structure/egg/proc/spawn_contents()
	new /mob/living/critter/flock/drone(get_turf(src), src.flock)

/obj/flock_structure/egg/throw_impact(atom/A, datum/thrown_thing/thr)
	var/turf/T = get_turf(A)
	playsound(src.loc, 'sound/impact_sounds/Crystal_Hit_1.ogg', 100, 1)
	if (T && !decal_made)
		playsound(src.loc, 'sound/impact_sounds/Slimy_Splat_1.ogg', 80, 1)
		make_cleanable( /obj/decal/cleanable/flockdrone_debris/fluid,T)
		decal_made = TRUE
	..()

/obj/flock_structure/egg/disposing()
	. = ..()
	src.flock?.updateEggCost()

/obj/flock_structure/egg/bit
	flock_id = "Secondary Second-Stage Assembler"
	flock_desc = "Will soon hatch into Flockbits."

/obj/flock_structure/egg/bit/spawn_contents()
	for (var/i in 1 to 3)
		new /mob/living/critter/flock/bit(get_turf(src), src.flock)

/obj/flock_structure/egg/tutorial

/obj/flock_structure/egg/tutorial/spawn_contents()
	var/mob/living/critter/flock/drone/drone = new(get_turf(src), src.flock)
	drone.set_tutorial_ai(TRUE)
