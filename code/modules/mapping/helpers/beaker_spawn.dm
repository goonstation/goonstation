/// The default glassware type glassware helpers use for chem dispensers.
#define DEFAULT_CHEM_GLASSWARE /obj/item/reagent_containers/food/drinks/drinkingglass/pitcher
/// The default glassware type glassware helpers use for alcohol dispensers.
#define DEFAULT_ALCOHOL_GLASSWARE /obj/item/reagent_containers/food/drinks/drinkingglass/pitcher
/// The default glassware type glassware helpers use for soda dispensers.
#define DEFAULT_SODA_GLASSWARE /obj/item/reagent_containers/glass/beaker/large

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
				dispenser.add_beaker_no_user(container)
				return

			if(istype(dispenser, /obj/machinery/chem_dispenser/soda))
				container = DEFAULT_CHEM_GLASSWARE
			else if(istype(dispenser, /obj/machinery/chem_dispenser/alcohol))
				container = DEFAULT_ALCOHOL_GLASSWARE
			else if(istype(dispenser, /obj/machinery/chem_dispenser))
				container = DEFAULT_SODA_GLASSWARE

			container = new container(src.loc)
			dispenser.add_beaker_no_user(container)
			return

		for(var/obj/machinery/espresso_machine/espressoer in src.loc)
			if(container)
				espressoer.add_cup_no_user(container)
				return

			container = new /obj/item/reagent_containers/food/drinks/espressocup(src.loc)
			espressoer.add_cup_no_user(container)
			return

		CRASH("A glassware helper couldn't properly spawn glassware. \
		Perhaps there wasn't a valid dispenser on its turf?")

#undef DEFAULT_CHEM_GLASSWARE
#undef DEFAULT_ALCOHOL_GLASSWARE
#undef DEFAULT_SODA_GLASSWARE
