/obj/brain_slug/acidic_goo_ball
	name = "sticky goo"
	//todo make an icon
	icon = 'icons/obj/objects.dmi'
	icon_state = "rat_den"
	desc = "A pile of sticky goo, restraining movement."
	anchored = 0
	density = 0
	var/acidic_range = 1
	var/mob/linked_mob = null
	var/next_spawn_check = 10 SECONDS
	var/acidify_duration = 20 SECONDS

	throw_impact(atom/A, datum/thrown_thing/thr)
		..()
		for (var/turf/T in range(acidic_range, src))
			if (!istype(T, /turf/space) && !istype(T, /turf/unsimulated))
				acidify_turf(T, acidify_duration)
		qdel(src)

	proc/acidify_turf(turf/T, var/burn_duration = 25 SECONDS)
		//Todo add an overlay on turfs to make it bubbly and sizzly
		T.acidic = TRUE
		SPAWN(burn_duration)
			T.acidic = FALSE
