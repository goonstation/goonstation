//destinations = list("Catering","Engineering Storage","Market","Medbay","Mining","QM","Research","Robotics","Tool Storage")
//below loaders are ordered clockwise from bottom left
//most loaders should go on top of a conveyor; loaders that are underneath a flap, currently at the market and tool storage endpoints, are the exception

/obj/machinery/cargo_router/oshan
	plane = PLANE_DEFAULT //gets the loaders to layer on top of the belts, instead of underneath

/obj/machinery/cargo_router/oshan/mining
	trigger_when_no_match = 0
	New()
		destinations = list("Mining" = SOUTH)
		default_direction = NORTH
		..()

/obj/machinery/cargo_router/oshan/qm
	trigger_when_no_match = 0
	New()
		destinations = list("QM" = EAST)
		default_direction = NORTH
		..()

/obj/machinery/cargo_router/oshan/catering
	trigger_when_no_match = 0
	New()
		destinations = list("Catering" = EAST)
		default_direction = NORTH
		..()

/obj/machinery/cargo_router/oshan/toolstorage
	trigger_when_no_match = 0
	New()
		destinations = list("Tool Storage" = NORTH)
		default_direction = EAST
		..()

/obj/machinery/cargo_router/oshan/toolstorage_flap
	New()
		destinations = list("Tool Storage" = NORTH)
		default_direction = SOUTH
		..()

/obj/machinery/cargo_router/oshan/robotics
	trigger_when_no_match = 0
	New()
		destinations = list("Robotics" = SOUTH)
		default_direction = EAST
		..()

/obj/machinery/cargo_router/oshan/medbay
	trigger_when_no_match = 0
	New()
		destinations = list("Medbay" = SOUTH)
		default_direction = EAST
		..()

/obj/machinery/cargo_router/oshan/research
	trigger_when_no_match = 0
	New()
		destinations = list("Research" = WEST)
		default_direction = SOUTH
		..()

/obj/machinery/cargo_router/oshan/eng_storage
	trigger_when_no_match = 0
	New()
		destinations = list("Engineering Storage" = WEST)
		default_direction = SOUTH
		..()

/obj/machinery/cargo_router/oshan/market
	trigger_when_no_match = 0
	New()
		destinations = list("Market" = SOUTH)
		default_direction = WEST
		..()

/obj/machinery/cargo_router/oshan/market_flap
	New()
		destinations = list("Market" = SOUTH)
		default_direction = NORTH
		..()
