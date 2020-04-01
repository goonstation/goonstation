/datum/random_event/major/spatial_tear
	name = "Spatial Tear"
	centcom_headline = "Spatial Anomaly"
	centcom_message = "A severe spatial anomaly has been detected near the station. Personnel are advised to avoid any unusual phenomenae."
	required_elapsed_round_time = 10 MINUTES

	event_effect(var/source)
		..()
		var/barrier_duration = rand(1 MINUTE, 5 MINUTES)
		var/pickx = rand(40,175)
		var/picky = rand(75,140)
		var/btype = rand(1,2)
		var/count = btype == 1 ? world.maxy : world.maxx // could just set it to our current mapsize (300) but this should help in case that changes again in the future or we go with non-square maps for some reason??  :v
		if (btype == 1)
			// Vertical
			while (count > 0)
				var/obj/forcefield/event/B = new /obj/forcefield/event(locate(pickx,count,1),barrier_duration)
				B.icon_state = "spat-v"
				count -= 1
		else
			// Horizontal
			while (count > 0)
				var/obj/forcefield/event/B = new /obj/forcefield/event(locate(count,picky,1),barrier_duration)
				B.icon_state = "spat-h"
				count -= 1

/obj/forcefield/event
	name = "Spatial Tear"
	desc = "A breach in the spatial fabric. Extremely difficult to pass."
	icon = 'icons/effects/effects.dmi'
	icon_state = "spat-h"
	anchored = 1.0
	opacity = 1
	density = 1
	layer = NOLIGHT_EFFECTS_LAYER_BASE

	New(var/loc,var/duration)
		..()
		SPAWN_DBG(duration)
			qdel(src)
