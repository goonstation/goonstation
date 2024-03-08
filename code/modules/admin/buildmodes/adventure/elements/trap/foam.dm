/datum/puzzlewizard/trap/foamtrap
	name = "AB CREATE: Foam trap"
	var/reagent
	var/foam_size

	initialize()
		..()
		foam_size = input("How many units of fluorosurfactant and water to mix?", "Foam size", 25) as num
		reagent = input("What reagent to foam? (reagent id)", "Reagent", "lube")
		boutput(usr, SPAN_NOTICE("Left click to place trap. Ctrl+click anywhere to finish."))

	build_click(var/mob/user, var/datum/buildmode_holder/holder, var/list/pa, var/atom/object)
		if ("left" in pa)
			var/turf/T = get_turf(object)
			if ("ctrl" in pa)
				finished = 1
				return
			if (T)
				var/obj/adventurepuzzle/triggerable/foamtrap/L = new /obj/adventurepuzzle/triggerable/foamtrap(T)
				L.reagent = reagent
				L.trap_delay = trap_delay
				L.foam_size = foam_size

/obj/adventurepuzzle/triggerable/foamtrap
	name = "foam trap"
	invisibility = INVIS_ADVENTURE
	icon = 'icons/obj/items/chemistry_glassware.dmi'
	icon_state = "large_beaker"
	density = 0
	opacity = 0
	anchored = ANCHORED
	var/reagent
	var/trap_delay = 100
	var/next_trap = 0
	var/foam_size = 20

	var/is_on = 1

	var/static/list/triggeracts = list("Activate" = "act", "Disable" = "off", "Destroy" = "del", "Do nothing" = "nop", "Enable" = "on")

	New()
		src.create_reagents(5000)
		..()

	trigger_actions()
		return triggeracts

	trigger(var/act)
		switch (act)
			if ("del")
				is_on = 0
				qdel(src)
			if ("act")
				if (is_on && next_trap <= world.time)
					var/datum/reagents/R = src.reagents
					R.add_reagent(reagent, 20)
					R.add_reagent("fluorosurfactant", foam_size)
					R.add_reagent("water", foam_size)
					R.handle_reactions()
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
		F["[path].reagent"] << reagent
		F["[path].trap_delay"] << trap_delay
		F["[path].foam_size"] << foam_size

	deserialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		. = ..()
		F["[path].is_on"] >> is_on
		F["[path].reagent"] >> reagent
		F["[path].trap_delay"] >> trap_delay
		var/FS
		F["[path].foam_size"] >> FS
		if (FS)
			foam_size = FS // backwards compatibility
