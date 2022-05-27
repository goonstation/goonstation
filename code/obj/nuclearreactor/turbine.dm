/////////////////////////////////////////////////////////////////
// Defintion for the turbine used by the nuclear reactor
// This is where the power comes from
/////////////////////////////////////////////////////////////////

/obj/machinery/atmospherics/binary/reactor_turbine
	name = "Gas Turbine"
	desc = "A large turbine used for generating power using hot gas."
	icon = 'icons/obj/large/96x160.dmi'
	icon_state = "turbine_main" //TODO make rotated states of this
	anchored = 1
	density = 1
	bound_width = 96
	bound_height = 160
	pixel_x = -32
	pixel_y = -32
	bound_x = -32
	bound_y = -32
	var/obj/machinery/power/terminal/terminal = null
	var/net_id = null
	dir = WEST

	New()
		. = ..()
		terminal = new /obj/machinery/power/terminal/netlink(src.loc)
		src.net_id = generate_net_id(src)
		terminal.set_dir(turn(src.dir,-90))
		terminal.master = src

	//override the atmos/binary connection code, because it doesn't like big icons
	initialize()
		if(node1 && node2) return

		var/node2_connect = dir
		var/node1_connect = turn(dir, 180)

		for(var/obj/machinery/atmospherics/target in get_step(src,node1_connect))
			if(target.initialize_directions & src.dir)
				if(target != src)
					node1 = target
					break

		for(var/obj/machinery/atmospherics/target in get_step(src,node2_connect))
			if(target.initialize_directions & src.dir)
				if(target != src)
					node2 = target
					break

		UpdateIcon()

	process()
		. = ..()
