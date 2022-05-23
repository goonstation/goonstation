/////////////////////////////////////////////////////////////////
// Defintion for the nuclear reactor engine
/////////////////////////////////////////////////////////////////

/obj/machinery/nuclear_reactor
	name = "Model NTBMK Nuclear Reactor"
	desc = "A nuclear reactor vessel, with slots for fuel rods and other components. Hey wait, didn't one of these explode once?"
	icon = 'icons/misc/nuclearreactor.dmi'
	icon_state = "reactor_empty"
	bound_width = 160
	bound_height = 160
	pixel_x = -64
	pixel_y = -64
	bound_x = -64
	bound_y = -64
	anchored = 1
	density = 1

	var/list/component_grid[6][6]

	New()
		..()

	process()
		. = ..()
		for(var/i=1 to 6)
			for(var/j=1 to 6)
				if(src.component_grid[i][j])
					var/obj/item/reactor_component/comp = src.component_grid[i][j]
					comp.processGas()
					comp.processHeat()
					comp.processNeutrons()


