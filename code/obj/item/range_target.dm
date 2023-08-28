// Shooting range targets for use on the syndicate shuttle.area

/obj/range_target
	name = "shooting range target"
	desc = "A target to fire at in a shooting range."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "bopbag"
	density = 1
	anchored = ANCHORED

	New()
		..()
		src.AddComponent(/datum/component/bullet_holes, 100, 0)

	bullet_act(obj/projectile/P)
		. = ..()
		if(!ON_COOLDOWN(src, "target_range_hit", 0.5 SECONDS))
			flick("[icon_state]2", src)

	ex_act(severity)
		return
