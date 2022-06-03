/////////////////////////////////////////////////////////////////
// Defintion for the control consoles of the nuclear reactor engine
// turbine first, then reactor
/////////////////////////////////////////////////////////////////

/obj/machinery/power/nuclear/turbine_control
	name = "Turbine Control Computer"
	desc = "A computer for configuring and monitoring the turbine of a nuclear reactor."
	icon = 'icons/obj/computer.dmi'
	icon_state = "engine"
	density = TRUE
	anchored = TRUE
	var/obj/machinery/atmospherics/binary/reactor_turbine/turbine_handle = null
	var/list/history
	var/const/history_max = 50

	New()
		..()
		src.history = list()

	process()
		. = ..()
		use_power(250)

		if(!turbine_handle)
			var/datum/powernet/powernet = src.get_direct_powernet()
			if(!powernet) return
			for(var/obj/machinery/power/terminal/N in powernet.nodes)
				if(istype(N.master,/obj/machinery/atmospherics/binary/reactor_turbine))
					src.turbine_handle = N.master
					return

		if (status & (NOPOWER|BROKEN))
			return

		if (length(src.history) > src.history_max)
			src.history.Cut(1, 2) //drop the oldest entry
		history += list(
					list(
						turbine_handle.RPM,
						turbine_handle.stator_load,
						turbine_handle.lastgen
						)
					)


	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if (!ui)
			ui = new(user, src, "TurbineControl", src.name)
			ui.open()

	ui_static_data(mob/user)
		. = list(
		)

	ui_data(mob/user)
		. = list(
			"rpm" = turbine_handle.RPM,
			"load" = turbine_handle.stator_load,
			"power" = turbine_handle.lastgen,
			"volume" = turbine_handle.flow_rate,
			"history" = src.history,
		)

	ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
		. = ..()
		if(.)
			return

		switch(action)
			if("loadChange")
				var/x = params["newVal"]
				src.turbine_handle.stator_load = x
			if("volChange")
				var/x = params["newVal"]
				src.turbine_handle.flow_rate = x
/////////////////////////////////////////////////////////////////////////////////////////////////////////


/obj/machinery/power/nuclear/reactor_control
	name = "Reactor Control Computer"
	desc = "A computer for configuring and monitoring the a nuclear reactor."
	icon = 'icons/obj/computer.dmi'
	icon_state = "reactor_stats"
	density = TRUE
	anchored = TRUE
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
		var/control_rod_level = 0
		var/control_rod_count = 0
		var/comps[length(reactor_handle.component_grid)][length(src.reactor_handle.component_grid[1])]
		for(var/x=1 to length(src.reactor_handle.component_grid))
			for(var/y=1 to length(src.reactor_handle.component_grid[1]))
				if(src.reactor_handle.component_grid[x][y])
					var/obj/item/reactor_component/comp = src.reactor_handle.component_grid[x][y]
					if(istype(comp,/obj/item/reactor_component/control_rod))
						var/obj/item/reactor_component/control_rod/CR = comp
						control_rod_count++
						control_rod_level+=CR.configured_insertion_level
					comps[x][y]=list(
							"x" = x,
							"y" = y,
							"name" = comp.name,
							"img" = comp.ui_image,
							"temp" = comp.temperature
						)

		. = list(
			"components" = comps,
			"reactorTemp" = src.reactor_handle.temperature,
			"reactorRads" = src.reactor_handle.radiationLevel,
			"controlRodLevel" = (control_rod_level/max(1,control_rod_count))*100
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
