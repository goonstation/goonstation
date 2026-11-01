/obj/machinery/atmospherics/unary/node
	name = "Node"
	desc = "Allows not-atmospheric machinery to connect to atmospheric machinery. You should not see this!"
	invisibility = INVIS_ALWAYS
	anchored = ANCHORED_ALWAYS
	event_handler_flags = IMMUNE_SINGULARITY

	ex_act()
		return

	meteorhit(obj/meteor)
		return

