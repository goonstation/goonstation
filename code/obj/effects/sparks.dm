/////////////////////////////////////////////
//SPARK SYSTEM (like steam system)
// The attach(atom/atom) proc is optional, and can be called to attach the effect
// to something, like the RCD, so then you can just call start() and the sparks
// will always spawn at the items location.
/////////////////////////////////////////////

/obj/effects/sparks
	name = "sparks"
	icon_state = "sparks"
	var/amount = 6
	anchored = 1
	mouse_opacity = 0

/obj/effects/sparks/New()
	..()
	SPAWN(0.5 SECONDS)
		playsound(src.loc, "sparks", 100, 1)
		var/turf/T = src.loc
		if (istype(T, /turf))
			T.hotspot_expose(1000,100,usr)

/obj/effects/sparks/disposing()
	var/turf/T = get_turf(src)
	if (istype(T, /turf))
		T.hotspot_expose(1000,100,usr)
	..()

/obj/effects/sparks/Move()
	. = ..()
	var/turf/T = src.loc
	if (istype(T, /turf))
		T.hotspot_expose(1000,100,usr)
	return

/obj/effects/rendersparks
	name = "sparks"
	anchored = 1
	icon = 'icons/effects/64x64.dmi'
	icon_state = ""
	pixel_x = -16
	pixel_y = -32
	layer = EFFECTS_LAYER_1
	New()
		icon_state = "sparks[rand(1,5)]"
		..()
		playsound(src.loc, "sparks", 100, 1)
		for(var/turf/X in view(1, src.loc))
			if (istype(X, /turf))
				X.hotspot_expose(1000,100,usr)
		SPAWN(2 SECONDS) qdel(src)

/obj/effects/sparks/end
	icon_state = "sparks_attack"
	pixel_y = 32
