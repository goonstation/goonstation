/obj/mapping_helper/glassware
	name = "glassware spawn"
	desc = "Helper for putting glassware in dispensers at round start (also works for espresso machines)."
	icon_state = "glassware_spawn"

	/// The type of glassware this component will spawn and attempt to put in the dispenser it's on.
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
			dispenser.beaker = container
			container.set_loc(dispenser)
			APPLY_ATOM_PROPERTY(container, PROP_ITEM_IN_CHEM_DISPENSER, dispenser)
			dispenser.UpdateIcon()
			return

		for(var/obj/machinery/espresso_machine/espressoer in src.loc)
			var/obj/item/reagent_containers/container = new /obj/item/reagent_containers/food/drinks/espressocup(src.loc)
			espressoer.cupsinside += 1
			container.set_loc(espressoer)
			espressoer.update()
			return
