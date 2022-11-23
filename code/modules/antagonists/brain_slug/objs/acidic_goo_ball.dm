/obj/brain_slug/acidic_goo_ball
	name = "sticky goo"
	icon = 'icons/mob/brainslug.dmi'
	icon_state = "acid_ball"
	desc = "A pile of sticky goo, restraining movement."
	anchored = 0
	density = 0
	var/acidic_range = 1
	var/acidify_duration = 25 SECONDS

	throw_impact(atom/A, datum/thrown_thing/thr)
		..()
		for (var/turf/T in range(acidic_range, src))
			if (!istype(T, /turf/space) && !istype(T, /turf/unsimulated) && !istype(T, /turf/simulated/shuttle))
				T.acidify_turf(acidify_duration)
		qdel(src)
