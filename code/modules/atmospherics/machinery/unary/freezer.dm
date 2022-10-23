/obj/machinery/atmospherics/unary/cold_sink/freezer
	name = "freezer"
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "freezer_0"
	density = 1
	anchored = 1
	weldable = FALSE
	current_heat_capacity = 1000
	var/pipe_direction = 1

	north
		dir = NORTH
	east
		dir = EAST
	south
		dir = SOUTH
	west
		dir = WEST

	// Medbay and kitchen freezers start at correct temperature to avoid pointless busywork.
	cryo
		name = "freezer (cryo cell)"
		current_temperature = 73.15

		north
			dir = NORTH
		east
			dir = EAST
		south
			dir = SOUTH
		west
			dir = WEST

	kitchen
		name = "freezer (kitchen)"
		current_temperature = 150
		on = 1

		north
			dir = NORTH
		east
			dir = EAST
		south
			dir = SOUTH
		west
			dir = WEST

	New()
		..()
		pipe_direction = src.dir
		initialize_directions = pipe_direction

	initialize()
		if(node) return

		var/node_connect = pipe_direction

		for(var/obj/machinery/atmospherics/target in get_step(src,node_connect))
			if(target.initialize_directions & get_dir(target,src))
				node = target
				break

		UpdateIcon()


	update_icon()

		if(src.node)
			if(src.on)
				icon_state = "freezer_1"
			else
				icon_state = "freezer"
		else
			icon_state = "freezer_0"
		return

	process()
		..()
		if(prob(5) && src.on)
			playsound(src.loc, ambience_atmospherics, 30, 1)

	ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
		. = ..()
		if(.)
			return
		switch(action)
			if("active_toggle")
				src.on = !src.on
				UpdateIcon()
				. = TRUE
			if("set_target_temperature")
				src.current_temperature = clamp(params["value"], 73.15, 293.15)
				. = TRUE

	ui_data(mob/user)
		. = ..()
		.["active"] = src.on
		.["target_temperature"] = src.current_temperature
		.["air_temperature"] = air_contents.temperature
		.["air_pressure"] = MIXTURE_PRESSURE(air_contents)

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if (!ui)
			ui = new(user, src, "Freezer")
			ui.set_autoupdate(TRUE)
			ui.open()

