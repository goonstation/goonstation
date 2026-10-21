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
	var/obj/item/reagent_containers/container = null

/obj/mapping_helper/glassware_spawn/setup()
	. = list()
	if (!isnull(src.container))
		src.container = null
		. += "[CI.format_position(src)] has varedited or overriden `container` value. Do not set this directly."

	// First, check for a cup or beaker on the helper's tile.
	for (var/obj/item/reagent_containers/found_container in src.loc)
		if (src.container)
			. += "[CI.format_position(src)] was placed on a tile with multiple glassware objects."
			break

		src.container = found_container

	for (var/obj/machinery/chem_dispenser/dispenser in src.loc)
		if (src.container)
			dispenser.add_glassware(container)
			return

		// Every type of drink dispenser needs to be here prior to the chem dispenser check or else a drink dispenser may end up with a large beaker.
		var/container_type = null
		if (istype(dispenser, /obj/machinery/chem_dispenser/soda))
			container_type = DEFAULT_DRINK_GLASSWARE
		else if(istype(dispenser, /obj/machinery/chem_dispenser/alcohol))
			container_type = DEFAULT_DRINK_GLASSWARE
		else if(istype(dispenser, /obj/machinery/chem_dispenser/chef))
			container_type = DEFAULT_DRINK_GLASSWARE
		else if(istype(dispenser, /obj/machinery/chem_dispenser))
			container_type = DEFAULT_CHEM_GLASSWARE

		src.container = new container_type(src.loc)
		dispenser.add_glassware(src.container)
		return

	for (var/obj/machinery/espresso_machine/espresso_machine in src.loc)
		if (src.container)
			espresso_machine.add_cup(container)
			return

		src.container = new /obj/item/reagent_containers/food/drinks/espressocup(src.loc)
		espresso_machine.add_cup(src.container)
		return

	. += "[CI.format_position(src)] could not locate a valid dispenser."

#undef DEFAULT_CHEM_GLASSWARE
#undef DEFAULT_DRINK_GLASSWARE
