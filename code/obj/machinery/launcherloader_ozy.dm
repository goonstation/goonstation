//list("Catering","Ejection","Engineering","Hydroponics","Medbay","Mining","QM","Research","Vessel Dock")
//Ejection is a hidden output to be added to specifically the research barcode computer

/obj/machinery/computer/barcode/ozy
	destinations = list("Catering","Engineering","Hydroponics","Medbay","Mining","QM","Research","Vessel Dock")

/obj/machinery/computer/barcode/qm/ozy
	destinations = list("Catering","Engineering","Hydroponics","Medbay","Mining","QM","Research","Vessel Dock")

/obj/machinery/cargo_router/ozy/research_nw
	New()
		destinations = list("Ejection" = WEST, "Research" = EAST, "Vessel Dock" = EAST)
		default_direction = NORTH
		..()

/obj/machinery/cargo_router/ozy/research_se
	New()
		destinations = list("Research" = EAST, "Vessel Dock" = SOUTH)
		default_direction = WEST
		..()

/obj/machinery/cargo_router/ozy/medical
	New()
		destinations = list("Ejection" = NORTH, "Medbay" = SOUTH, "Research" = NORTH, "Vessel Dock" = NORTH)
		default_direction = EAST
		..()

/obj/machinery/cargo_router/ozy/grandcentral_north
	New()
		destinations = list("Engineering" = NORTH, "Hydroponics" = WEST)
		default_direction = EAST
		..()

/obj/machinery/cargo_router/ozy/grandcentral_mid
	New()
		destinations = list("Catering" = EAST)
		default_direction = SOUTH
		..()

/obj/machinery/cargo_router/ozy/grandcentral_south
	New()
		destinations = list("Catering" = WEST, "Ejection" = EAST, "Engineering" = EAST, "Hydroponics" = WEST, "Medbay" = EAST, "Research" = EAST, "Vessel Dock" = EAST)
		default_direction = SOUTH
		..()

/obj/machinery/cargo_router/ozy/qm_west
	New()
		destinations = list("Catering" = NORTH, "Ejection" = NORTH, "Engineering" = NORTH, "Hydroponics" = NORTH, "Medbay" = NORTH, "Mining" = NORTH, "Research" = NORTH, "Vessel Dock" = NORTH)
		default_direction = SOUTH
		..()

/obj/machinery/cargo_router/ozy/qm_mid
	New()
		destinations = list("Catering" = NORTH, "Ejection" = NORTH, "Engineering" = NORTH, "Hydroponics" = NORTH, "Medbay" = NORTH, "Research" = NORTH, "Vessel Dock" = NORTH)
		default_direction = EAST
		..()

/obj/machinery/cargo_router/ozy/qm_east
	New()
		destinations = list("Mining" = SOUTH)
		default_direction = WEST
		..()
