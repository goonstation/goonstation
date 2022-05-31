/////////////////////////////////////////////////////////////////
// Defintion for the control consoles of the nuclear reactor engine
// turbine first, then reactor
/////////////////////////////////////////////////////////////////

/obj/machinery/power/nuclear/turbine_control
	name = "Turbine Control Computer"
	desc = "A computer for configuring and monitoring the turbine of a nuclear reactor."
	icon = 'icons/obj/computer.dmi'
	icon_state = "engine"
	var/obj/machinery/atmospherics/binary/reactor_turbine/turbine_handle = null

	process()
		. = ..()
		if(!turbine_handle)
			var/datum/powernet/powernet = src.get_direct_powernet()
			if(!powernet) return
			for(var/obj/machinery/power/terminal/N in powernet.nodes)
				if(istype(N.master,/obj/machinery/atmospherics/binary/reactor_turbine))
					src.turbine_handle = N.master


/////////////////////////////////////////////////////////////////////////////////////////////////////////


/obj/machinery/power/nuclear/reactor_control
	name = "Reactor Control Computer"
	desc = "A computer for configuring and monitoring the a nuclear reactor."
	icon = 'icons/obj/computer.dmi'
	icon_state = "reactor_stats"
	var/obj/machinery/atmospherics/binary/nuclear_reactor/reactor_handle = null

	process()
		. = ..()
		if(!reactor_handle)
			var/datum/powernet/powernet = src.get_direct_powernet()
			if(!powernet) return
			for(var/obj/machinery/power/terminal/netlink/N in powernet.nodes)
				if(istype(N.master,/obj/machinery/atmospherics/binary/nuclear_reactor))
					src.reactor_handle = N.master

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if(!ui)
			ui = new(user, src, "NuclearReactor")
			ui.open()

	ui_static_data(mob/user)
		. = list(
			"gridW" = length(src.reactor_handle.component_grid),
			"gridH" = length(src.reactor_handle.component_grid[1]),
			"emptySlotIcon" = icon2base64(icon('icons/misc/reactorcomponents.dmi',"empty"))
		)

	ui_data()
		var/comps[length(reactor_handle.component_grid)][length(src.reactor_handle.component_grid[1])]
		for(var/x=1 to length(src.reactor_handle.component_grid))
			for(var/y=1 to length(src.reactor_handle.component_grid[1]))
				if(src.reactor_handle.component_grid[x][y])
					var/obj/item/reactor_component/comp = src.reactor_handle.component_grid[x][y]
					comps[x][y]=list(
							"x" = x,
							"y" = y,
							"name" = comp.name,
							"img" = comp.ui_image,
							"temp" = comp.temperature
						)

		. = list(
			"components" = comps,
		)

	ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
		. = ..()
		if(.)
			return

		switch(action)
			if("slot")
				var/x = params["x"]
				var/y = params["y"]
				if(istype(src.reactor_handle.component_grid[x][y],/obj/item/reactor_component/control_rod))
					var/obj/item/reactor_component/control_rod/CR = src.reactor_handle.component_grid[x][y]
					CR.configured_insertion_level = !CR.configured_insertion_level //TODO better
