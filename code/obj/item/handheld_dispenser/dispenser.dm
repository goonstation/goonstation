/obj/item/handheld_dispenser
	name = "handheld pipe dispenser"
	desc = "A neat tool to quickly lay down pipes onto the floor."
	icon = 'icons/obj/items/hpd.dmi'
	icon_state = "hpd"
	flags = TABLEPASS | CONDUCT
	var/dispenser_being_used = FALSE
	var/dispenser_delay = 5 DECI SECONDS
	var/static/list/atmospipesforcreation = list(
		"Pipe" = /obj/machinery/atmospherics/pipe/simple/overfloor,
		"Manifold" = /obj/machinery/atmospherics/pipe/manifold/overfloor,
		"Quadway manifold" = /obj/machinery/atmospherics/pipe/quadway,
		"Heat exchanging pipe" = /obj/machinery/atmospherics/pipe/simple/heat_exchanging,
		"HE junction" = /obj/machinery/atmospherics/pipe/simple/junction,
	)
	var/static/list/atmosmachinesforcreation = list(
		"Passive vent" = /obj/machinery/atmospherics/unary/vent,
		"Pressure tank" = /obj/machinery/atmospherics/unary/tank,
		"Passive gate" = /obj/machinery/atmospherics/binary/passive_gate,
		"Pressure pump" = /obj/machinery/atmospherics/binary/pump,
		"Volume pump" = /obj/machinery/atmospherics/binary/volume_pump,
		"Manual valve" = /obj/machinery/atmospherics/binary/valve,
		"Digital valve" = /obj/machinery/atmospherics/binary/valve/digital,
		"Outlet Injector" = /obj/machinery/atmospherics/unary/outlet_injector,
		"Vent pump" = /obj/machinery/atmospherics/unary/vent_pump,
		"Vent scrubber" = /obj/machinery/atmospherics/unary/vent_scrubber,
	)

	var/static/list/icon/cache = list()
	var/selection = /obj/fluid_pipe/straight
	var/selectedimage
	var/direction = EAST
	var/destroying = FALSE
	var/resources = 20

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
		"selectedimage" = (src.selectedimage || getBase64Img(selection, src.direction)),
		"selectedcost" = 3, //TODO when datumized
		"resources" = src.resources,
		"destroying" = src.destroying,
	)

/obj/item/handheld_dispenser/ui_static_data(mob/user)
	. = list(
	)
	for (var/itemtype in atmospipesforcreation)
		.["atmospipes"] += list(list(
			"type" = itemtype,
			"image" = getBase64Img(atmospipesforcreation[itemtype]),
			"cost" = 4, //TODO when datumized
			))
	for (var/itemtype in atmosmachinesforcreation)
		.["atmosmachines"] += list(list(
			"type" = itemtype,
			"image" = getBase64Img(atmosmachinesforcreation[itemtype]),
			"cost" = 4,
			))

/obj/item/handheld_dispenser/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if (.)
		return
	switch(action)
		if("select")
			src.selection = atmospipesforcreation[params["type"]] || atmosmachinesforcreation[params["type"]]
			src.selectedimage = getBase64Img(src.selection, direction)
			. = TRUE
		if("changedir")
			src.direction = text2num_safe(params["newdir"])
			//invalidate the cached selected image
			src.selectedimage = null
			. = TRUE
		if("toggle-destroying")
			src.destroying = !src.destroying
			. = TRUE

/obj/item/handheld_dispenser/proc/getBase64Img(atom/object, direction = SOUTH)
	. = src.cache["[object][direction]"]
	if(.)
		return
	. = icon2base64(icon = icon(icon = initial(object.icon), icon_state = initial(object.icon_state), dir = direction))
	src.cache["[object][direction]"] = .
