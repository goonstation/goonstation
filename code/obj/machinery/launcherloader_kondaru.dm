//list("Catering","Disposal","Engineering","Export","Medbay","Mining","Pod Bay","Research","Security","QM")

/obj/machinery/cargo_router/kd_med_left
	INIT()
		destinations = list("Disposal" = WEST,"Pod Bay" = NORTH)
		default_direction = EAST
		..()

/obj/machinery/cargo_router/kd_med_lmid
	INIT()
		destinations = list("Disposal" = WEST,"Pod Bay" = WEST)
		default_direction = EAST
		..()

/obj/machinery/cargo_router/kd_med_rmid
	INIT()
		destinations = list("Medbay" = EAST,"Disposal" = WEST,"Pod Bay" = WEST)
		default_direction = SOUTH
		..()

/obj/machinery/cargo_router/kd_med_right
	INIT()
		destinations = list("Medbay" = EAST)
		default_direction = WEST
		..()

/obj/machinery/cargo_router/kd_sci_left
	INIT()
		destinations = list("Disposal" = NORTH,"Pod Bay" = NORTH,"Medbay" = NORTH,"Ejection" = WEST) // research gets a bonus destination
		default_direction = SOUTH
		..()

/obj/machinery/cargo_router/kd_sci_eject
	INIT()
		destinations = list("Catering" = EAST,"Disposal" = EAST,"Pod Bay" = EAST,"Medbay" = EAST,"Research" = EAST,"Export" = EAST,"Security" = EAST,"Mining" = EAST,"Engineering" = EAST,"QM" = EAST)
		default_direction = WEST
		..()

/obj/machinery/cargo_router/kd_sci_right
	INIT()
		destinations = list("Research" = EAST)
		default_direction = WEST
		..()

/obj/machinery/cargo_router/kd_shunt_center
	INIT()
		destinations = list("Export" = EAST)
		default_direction = WEST
		..()

/obj/machinery/cargo_router/kd_shunt_nw
	INIT()
		destinations = list("Disposal" = WEST,"Pod Bay" = WEST,"Medbay" = WEST,"Research" = WEST)
		default_direction = NORTH
		..()


/obj/machinery/cargo_router/kd_sec_exoflap
	INIT()
		destinations = list("Security" = EAST,"Disposal" = SOUTH,"Pod Bay" = SOUTH,"Medbay" = SOUTH,"Research" = SOUTH)
		default_direction = WEST
		..()

/obj/machinery/cargo_router/kd_sec_flap
	INIT()
		destinations = list("Security" = EAST)
		default_direction = WEST
		..()

/obj/machinery/cargo_router/kd_qm_exoflap
	INIT()
		destinations = list("Catering" = NORTH,"Disposal" = EAST,"Pod Bay" = EAST,"Medbay" = EAST,"Research" = EAST,"Security" = EAST,"Mining" = NORTH,"Engineering" = NORTH)
		default_direction = WEST
		..()

/obj/machinery/cargo_router/kd_qm_flap
	INIT()
		destinations = list("Catering" = EAST,"Disposal" = EAST,"Pod Bay" = EAST,"Medbay" = EAST,"Research" = EAST,"Security" = EAST,"Mining" = EAST,"Engineering" = EAST)
		default_direction = WEST
		..()

/obj/machinery/cargo_router/kd_qm_inner
	INIT()
		destinations = list("Catering" = EAST,"Disposal" = EAST,"Pod Bay" = EAST,"Medbay" = EAST,"Research" = EAST,"Export" = SOUTH,"Security" = EAST,"Mining" = EAST,"Engineering" = EAST)
		default_direction = WEST
		..()

/obj/machinery/cargo_router/kd_mining
	INIT()
		destinations = list("Mining" = WEST)
		default_direction = EAST
		..()

/obj/machinery/cargo_router/kd_mining_exoflap
	INIT()
		destinations = list("Mining" = WEST)
		default_direction = NORTH
		..()

/obj/machinery/cargo_router/kd_cater_exoflap
	INIT()
		destinations = list("Catering" = EAST)
		default_direction = SOUTH
		..()

/obj/machinery/cargo_router/kd_cater_flap
	INIT()
		destinations = list("Catering" = EAST)
		default_direction = WEST
		..()

/obj/machinery/cargo_router/kd_depot_south
	INIT()
		destinations = list("Catering" = WEST,"Engineering" = WEST,"Mining" = WEST)
		default_direction = SOUTH
		..()

/obj/machinery/cargo_router/kd_depot_north
	INIT()
		destinations = list("Engineering" = NORTH,"Catering" = EAST)
		default_direction = SOUTH
		..()
