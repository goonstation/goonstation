//list("Catering","Engineering","Export","Medbay","Research","Security","QM")

ABSTRACT_TYPE(/obj/machinery/cargo_router/aetherion)

// engine router
/obj/machinery/cargo_router/aetherion/southsec_west
	New()
		destinations = list("Security" = SOUTH)
		default_direction = WEST
		..()

/obj/machinery/cargo_router/aetherion/easteng_north
	New()
		destinations = list("Engineering" = EAST, "Security" = EAST)
		default_direction = NORTH
		..()

/obj/machinery/cargo_router/aetherion/easteng_south
	New()
		destinations = list("Engineering" = EAST)
		default_direction = SOUTH
		..()
// medical router
/obj/machinery/cargo_router/aetherion/southcatering_west
	New()
		destinations = list("Catering" = SOUTH)
		default_direction = WEST
		..()

/obj/machinery/cargo_router/aetherion/westmedbay_north
	New()
		destinations = list("Medbay" = WEST)
		default_direction = NORTH
		..()

/obj/machinery/cargo_router/aetherion/eastmedbay_north
	New()
		destinations = list("Catering" = EAST, "Medbay" = EAST)
		default_direction = NORTH
		..()

// research router
/obj/machinery/cargo_router/aetherion/southresearch_east
	New()
		destinations = list("Catering" = EAST, "Medbay" = EAST)
		default_direction = SOUTH
		..()

/obj/machinery/cargo_router/aetherion/southresearch_west
	New()
		destinations = list("Research" = SOUTH)
		default_direction = WEST
		..()

/obj/machinery/cargo_router/aetherion/mixedresearch_west
	New()
		destinations = list("Research" = NORTH, "Catering" = NORTH, "Medbay" = NORTH)
		default_direction = WEST
		..()

// routing depot
/obj/machinery/cargo_router/aetherion/depot_north
	New()
		destinations = list("Engineering" = WEST, "Security" = WEST)
		default_direction = NORTH
		..()

/obj/machinery/cargo_router/aetherion/depot_east
	New()
		destinations = list("Export" = NORTH)
		default_direction = EAST
		..()

/obj/machinery/cargo_router/aetherion/depot_south
	New()
		destinations = list("Research" = EAST, "Catering" = EAST, "Medbay" = EAST)
		default_direction = SOUTH
		..()

/obj/machinery/cargo_router/aetherion/depot_west
	New()
		destinations = list("QM" = SOUTH)
		default_direction = WEST
		..()
