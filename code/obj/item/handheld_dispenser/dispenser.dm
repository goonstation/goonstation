/obj/item/handheld_dispenser
	name = "handheld pipe dispenser"
	desc = "A neat tool to quickly lay down pipes onto the floor."
	icon = 'icons/obj/items/hpd.dmi'
	icon_state = "hpd"
	flags = TABLEPASS | CONDUCT
	var/dispenser_being_used = FALSE
	var/dispenser_delay = 5 DECI SECONDS
	var/static/list/available_fluid_pipes = list(
		"Pipe" = /obj/fluid_pipe/straight,
		"Pipe with glass view" = /obj/fluid_pipe/straight/see_fluid/overfloor,
		"Elbow Pipe" = /obj/fluid_pipe/elbow/overfloor,
		"T-Junction" = /obj/fluid_pipe/t_junction/overfloor,
		"Four-Way" = /obj/fluid_pipe/quad/overfloor,
		"Fluid Tank" = /obj/fluid_pipe/fluid_tank,
		"Fluid Tank with glass view" = /obj/fluid_pipe/fluid_tank/see_fluid
	)
	var/static/list/available_fluid_machines = list(
		"Powered Drain" = /obj/machinery/fluid_pipe_machinery/unary/drain/inlet_pump,
		"Powered Outlet" = /obj/machinery/fluid_pipe_machinery/unary/outlet_pump,
		"Pump" = /obj/machinery/fluid_pipe_machinery/binary/pump
	)
	var/static/list/icon/cache = list()
	var/selection = /obj/fluid_pipe/straight
	var/selectedimage
	var/direction = EAST
	var/destroying = FALSE

/obj/item/handheld_dispenser/attack_self(mob/user )
	src.ui_interact(user)

/obj/item/handheld_dispenser/afterattack(atom/target, mob/user)
	if (!can_reach(user, target) || !isturf(target))
		return
	if(dispenser_being_used)
		boutput(user, SPAN_ALERT("Wait a bit while its working!"))
		return




/obj/item/handheld_dispenser/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "HandPipeDispenser", name)
		ui.open()

/obj/item/handheld_dispenser/ui_data(mob/user)
	. = list(
		"selectedimage" = (src.selectedimage || getBase64ImgFluid(selection)),
		"mode" = src.destroying
	)

/obj/item/handheld_dispenser/ui_static_data(mob/user)
	. = list(
	)
	for (var/pipetype in available_fluid_pipes)
		.["fluidpipes"] += list(list(
			"type" = pipetype,
			"image" = getBase64ImgFluid(available_fluid_pipes[pipetype])
			))
	for (var/machinetype in available_fluid_machines)
		.["fluidmachines"] += list(list(
			"type" = machinetype,
			"image" = getBase64ImgFluid(available_fluid_machines[machinetype])
			))

/obj/item/handheld_dispenser/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if (.)
		return
	switch(action)
		if("select")
			src.selection = available_fluid_pipes[params["type"]] || available_fluid_machines[params["type"]]
			src.selectedimage = getBase64ImgFluid(src.selection, direction)
			. = TRUE
		if("changedir")
			src.direction = text2num_safe(params["newdir"])

/obj/item/handheld_dispenser/proc/getBase64ImgFluid(atom/fluidobject, direction = EAST)
	. = src.cache["[fluidobject][direction]"]
	if(.)
		return
	. = icon2base64(icon = icon(icon = initial(fluidobject.icon), icon_state = initial(fluidobject.icon_state), dir = direction))
	src.cache["[fluidobject][direction]"] = .
/*
/obj/item/handheld_dispenser/proc/create_object(atom/target, path)
	new /dmm_suite/preloader(target, list("dir" = direction))
	if(ispath(path, /obj/fluid_pipe))
		var/obj/fluid_pipe/pipe = new path(target)
		for(var/obj/fluid_pipe/object in target)
			if(pipe == object)
				continue
			if((pipe.initialize_directions & object.initialize_directions) || object.hogs_tile)
				qdel(pipe)
				boutput(user, SPAN_ALERT("Something is taking up that direction!"))
				break
		pipe.initialize()
	else
		var/obj/machinery/fluid_pipe_machinery/machine = new path(target)
		for(var/obj/machinery/fluid_pipe_machinery/object in target)
			if(machine == object)
				continue
			if((machine.initialize_directions & object.initialize_directions))
				qdel(machine)
				boutput(user, SPAN_ALERT("Something is taking up that direction!"))
				break
		machine.initialize()
*/
