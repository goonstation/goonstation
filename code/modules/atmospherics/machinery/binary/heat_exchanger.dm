/obj/machinery/atmospherics/binary/heat_exchanger
	name = "Heat Exchanger"
	desc = "Exchanges heat between two input gases without mixing them."
	icon = 'icons/obj/atmospherics/heat_exchanger.dmi'
	icon_state = "exchanger"

/obj/machinery/atmospherics/binary/heat_exchanger/update_icon()
	SET_PIPE_UNDERLAY(src.node1, turn(src.dir, 180), "long", issimplepipe(src.node1) ?  src.node1.color : null, FALSE)
	SET_PIPE_UNDERLAY(src.node2, src.dir, "long", issimplepipe(src.node2) ?  src.node2.color : null, FALSE)

/obj/machinery/atmospherics/binary/heat_exchanger/process()
	..()
	if(!(src.node1 && src.node2))
		return FALSE

	src.air1.temperature_share(src.air2, WINDOW_HEAT_TRANSFER_COEFFICIENT)

	src.network1?.update = TRUE
	src.network2?.update = TRUE

	return TRUE
