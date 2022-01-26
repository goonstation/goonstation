/datum/puzzlewizard/trap/smoketrap
	name = "AB CREATE: Smoke trap"
	var/reagent

	initialize()
		..()
		reagent = input("What reagent to smoke? (reagent id)", "Reagent", "lube")
		boutput(usr, "<span class='notice'>Left click to place trap. Ctrl+click anywhere to finish.</span>")

	build_click(var/mob/user, var/datum/buildmode_holder/holder, var/list/pa, var/atom/object)
		if ("left" in pa)
			var/turf/T = get_turf(object)
			if ("ctrl" in pa)
				finished = 1
				return
			if (T)
				var/obj/adventurepuzzle/triggerable/smoketrap/L = new /obj/adventurepuzzle/triggerable/smoketrap(T)
				L.reagent = reagent
				L.trap_delay = trap_delay

/obj/adventurepuzzle/triggerable/smoketrap
	name = "smoke trap"
	invisibility = INVIS_ADVENTURE
	icon = 'icons/obj/chemical.dmi'
	icon_state = "beakerlarge"
	density = 0
	opacity = 0
	anchored = 1
	var/reagent
	var/trap_delay = 100
	var/next_trap = 0

	var/is_on = 1

	var/static/list/triggeracts = list("Activate" = "act", "Disable" = "off", "Destroy" = "del", "Do nothing" = "nop", "Enable" = "on")

	New()
		src.create_reagents(80)
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
					R.add_reagent("potassium", 20)
					R.add_reagent("phosphorus", 20)
					R.add_reagent("sugar", 20)
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


	deserialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		. = ..()
		F["[path].is_on"] >> is_on
		F["[path].reagent"] >> reagent
		F["[path].trap_delay"] >> trap_delay
