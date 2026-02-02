/// The default glassware type glassware helpers use for chem dispensers.
#define DEFAULT_CHEM_GLASSWARE /obj/item/reagent_containers/glass/beaker/large
/// The default glassware type glassware helpers use for drink (soda, alcohol, chef, etc.) dispensers.
#define DEFAULT_DRINK_GLASSWARE /obj/item/reagent_containers/food/drinks/drinkingglass/pitcher

/// Glassware spawning helper:
/// Allows glassware to be put directly into a dispenser at round start.
/obj/mapping_helper/glassware_spawn
	name = "glassware spawn"
	desc = "Helper for putting glassware in a dispenser at round start (also works for espresso machines)."
	icon_state = "glassware_spawn"

	/// The container object found or spawned by the helper. DO NOT SET THIS DIRECTLY.
	/// If you want specific glassware in a dispenser then simply map that glassware on
	/// the same tile as the helper.
	var/obj/item/reagent_containers/container

	setup()
		// First, check for a cup or beaker on the helper's tile.
		for(var/obj/item/reagent_containers/found_container in src.loc)
#ifdef CHECK_MORE_RUNTIMES // Multiple containers won't cause a `CRASH()` without `CHECK_MORE_RUNTIMES` defined.
			if(!container)
				container = found_container
				continue
			else
				CRASH("A glassware helper was placed on a tile with multiple glassware objects.")
#endif
			container = found_container
			break

		for(var/obj/machinery/chem_dispenser/dispenser in src.loc)
			if(container)
				dispenser.add_beaker(container)
				return

			// Every type of drink dispenser needs to be here prior to the chem dispenser check
			// or else a drink dispenser may end up with a large beaker.
			if(istype(dispenser, /obj/machinery/chem_dispenser/soda))
				container = DEFAULT_DRINK_GLASSWARE
			else if(istype(dispenser, /obj/machinery/chem_dispenser/alcohol))
				container = DEFAULT_DRINK_GLASSWARE
			else if(istype(dispenser, /obj/machinery/chem_dispenser/chef))
				container = DEFAULT_DRINK_GLASSWARE
			else if(istype(dispenser, /obj/machinery/chem_dispenser))
				container = DEFAULT_CHEM_GLASSWARE

			container = new container(src.loc)
			dispenser.add_beaker(container)
			return

		for(var/obj/machinery/espresso_machine/espressoer in src.loc)
			if(container)
				espressoer.add_cup(container)
				return

			container = new /obj/item/reagent_containers/food/drinks/espressocup(src.loc)
			espressoer.add_cup(container)
			return

		CRASH("A glassware helper couldn't properly spawn glassware. \
		Perhaps there wasn't a valid dispenser on its turf?")

#undef DEFAULT_CHEM_GLASSWARE
#undef DEFAULT_DRINK_GLASSWARE
