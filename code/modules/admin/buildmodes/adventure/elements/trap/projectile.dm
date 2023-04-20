/datum/puzzlewizard/trap/projectiletrap
	name = "AB CREATE: Projectile trap"
	var/turf/target = null
	var/proj_type = 5
	var/invisibility = INVIS_ADVENTURE

	var/selection

	initialize()
		..()
		selection = new /obj/adventurepuzzle/marker
		if ((input("Is this trap invisible?", "Invisibility", "yes") in list("yes", "no")) == "no")
			invisibility = INVIS_NONE
		proj_type = input("Projectile type?", "Projectile type", null) in childrentypesof(/datum/projectile)
		boutput(usr, "<span class='notice'>Right click to set trap target. Right click active target to clear target. Left click to place trap. Ctrl+click anywhere to finish.</span>")
		boutput(usr, "<span class='notice'>Special note: If no target is set, the projectile will launch at a random mob in view.</span>")

	disposing()
		if (target)
			target.overlays -= selection
		if (selection)
			qdel(selection)
		..()

	build_click(var/mob/user, var/datum/buildmode_holder/holder, var/list/pa, var/atom/object)
		if ("left" in pa)
			var/turf/T = get_turf(object)
			if ("ctrl" in pa)
				finished = 1
				target.overlays -= selection
				target = null
				return
			if (T)
				var/obj/adventurepuzzle/triggerable/targetable/projectiletrap/P = new /obj/adventurepuzzle/triggerable/targetable/projectiletrap(T)
				if (target)
					var/obj/adventurepuzzle/invisible/I = locate() in target
					if (!I)
						I = new /obj/adventurepuzzle/invisible(target)
					P.target = I
				P.proj_type = proj_type
				P.trap_delay = trap_delay
				P.invisibility = invisibility
				P.set_dir(holder.dir)
		else if ("right" in pa)
			if (isturf(object))
				if (target == object)
					target.overlays -= selection
					target = null
				else
					if (target)
						target.overlays -= selection
					target = object
					target.overlays += selection

/obj/adventurepuzzle/triggerable/targetable/projectiletrap
	name = "projectile trap"
	invisibility = INVIS_ADVENTURE
	icon = 'icons/obj/randompuzzles.dmi'
	icon_state = "projectiletrap"
	density = 0
	opacity = 0
	anchored = ANCHORED
	target = null
	var/proj_type = /datum/projectile/bullet
	var/datum/projectile/current_projectile
	var/trap_delay = 100
	var/next_trap = 0

	var/is_on = 1

	var/static/list/triggeracts = list("Activate" = "act", "Disable" = "off", "Destroy" = "del", "Do nothing" = "nop", "Enable" = "on")

	trigger_actions()
		return triggeracts

	trigger(var/act)
		switch (act)
			if ("del")
				is_on = 0
				qdel(src)
			if ("act")
				if (is_on && next_trap <= world.time)
					if (!current_projectile)
						current_projectile = new proj_type()
					var/turf/T
					if (target)
						T = target
					else
						var/mob/M = locate(/mob/living) in view(6)
						if (M)
							T = get_turf(M)

					shoot_projectile_ST(src, current_projectile, T)
					next_trap = world.time + trap_delay
			if ("off")
				is_on = 0
				return
			if ("on")
				is_on = 1
				return

	serialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		..()
		F["[path].is_on"] << is_on
		F["[path].proj_type"] << proj_type
		F["[path].trap_delay"] << trap_delay
		if (target)
			F["[path].has_target"] << 1
			F["[path].target"] << "ser:\ref[target]"
		else
			F["[path].has_target"] << 0

	deserialize_postprocess()
		..()
		if (target)
			target = locate(target)

	deserialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		. = ..()
		F["[path].is_on"] >> is_on
		F["[path].proj_type"] >> proj_type
		F["[path].trap_delay"] >> trap_delay
		var/has_target
		F["[path].has_target"] >> has_target
		if (has_target)
			F["[path].target"] >> target
			. |= DESERIALIZE_NEED_POSTPROCESS

	reset()
		next_trap = 0
