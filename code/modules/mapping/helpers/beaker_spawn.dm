/obj/mapping_helper/glassware_spawn
	name = "glassware spawn"
	desc = "Helper for putting glassware in a dispenser at round start (also works for espresso machines)."
	icon_state = "glassware_spawn"

	/// The type of glassware this helper will spawn and attempt to put in the dispenser it's on.
	var/glassware_type

	setup()
		for(var/obj/machinery/chem_dispenser/dispenser in src.loc)
			if(istype(dispenser, /obj/machinery/chem_dispenser/soda))
				glassware_type = /obj/item/reagent_containers/food/drinks/drinkingglass/pitcher
			else if(istype(dispenser, /obj/machinery/chem_dispenser/alcohol))
				glassware_type = /obj/item/reagent_containers/food/drinks/drinkingglass/pitcher
			else if(istype(dispenser, /obj/machinery/chem_dispenser))
				glassware_type = /obj/item/reagent_containers/glass/beaker/large

			var/obj/item/reagent_containers/container = new glassware_type(src.loc)
			dispenser.add_beaker_no_user(container)
			return

		for(var/obj/machinery/espresso_machine/espressoer in src.loc)
			var/obj/item/reagent_containers/container = new /obj/item/reagent_containers/food/drinks/espressocup(src.loc)
			espressoer.add_cup_no_user(container)
			return

		CRASH("A glassware helper couldn't properly spawn glassware. \
		Perhaps there wasn't a valid dispenser on its turf?")
