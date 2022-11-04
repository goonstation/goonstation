/obj/effects/harmless_smoke
	name = "smoke"
	icon_state = "smoke"
	opacity = 1
	anchored = 0
	mouse_opacity = 0
	var/amount = 6
	//Remove this bit to use the old smoke
	icon = 'icons/effects/96x96.dmi'
	pixel_x = -32
	pixel_y = -32

/*
/obj/effects/harmless_smoke/New()
	..()
	SPAWN(10 SECONDS)
		qdel(src)
	return
*/
/obj/effects/harmless_smoke/proc/kill(var/time)
	SPAWN(time)
		qdel(src)


proc/harmless_smoke_puff(var/turf/location, var/duration = 100)
	if(!istype(location)) return
	var/obj/effects/harmless_smoke/smoke = new /obj/effects/harmless_smoke
	smoke.set_loc(location)
	smoke.kill(100)
