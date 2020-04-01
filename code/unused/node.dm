/obj/machinery/atmos/node
	name = "Pipe Node"
	desc = "attaches to a pipe and interacts with the air"
	icon = 'icons/obj/atmospherics/pipes.dmi'
	icon_state = "pipe"
	opacity = 0
	density = 0
	layer = PIPE_LAYER//Change this to wires+-1

	m_amt = 50	// metal
	g_amt = 10	// glass
	w_amt = 80	// waster amounts


//What dir\s the pipe can connect with
	var/obj/machinery/atmos/up = null
	var/obj/machinery/atmos/down = null
	var/obj/machinery/atmos/left = null
	var/obj/machinery/atmos/right = null

