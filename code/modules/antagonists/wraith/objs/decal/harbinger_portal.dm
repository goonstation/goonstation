/////////////////////////////
// Cosmetic portal effect
/////////////////////////////
/obj/decal/harbinger_portal
	name = "harbinger portal"
	anchored = 1
	icon = 'icons/effects/wraitheffects.dmi'
	icon_state = "harbinger_portal"
	layer = EFFECTS_LAYER_BASE
	density = 0

/obj/decal/guard_attack_marker
	name = ""
	anchored = 1
	icon = 'icons/effects/wraitheffects.dmi'
	icon_state = "attack_marker"
	layer = EFFECTS_LAYER_BASE
	density = 0

	New(var/atom/location, var/duration = 1.5 SECONDS)
		src.set_loc(location)
		SPAWN(duration)
			qdel(src)
		..()
