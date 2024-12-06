/obj/item/handheld_dispenser
	name = "handheld pipe dispenser"
	desc = "A neat tool to quickly lay down pipes onto the floor."
	icon = 'icons/obj/items/hpd.dmi'
	icon_state = "hpd"
	flags = TABLEPASS | CONDUCT
	var/dispenser_being_used = FALSE
	var/dispenser_delay = 5 DECI SECONDS
	var/static/list/atmospipesforcreation = null
	var/static/list/atmosmachinesforcreation = null
	var/static/list/icon/cache = list()
	var/datum/pipe_recipe/selection = null
	var/selectedimage
	var/direction = EAST
	var/destroying = FALSE
	var/resources = 20

/obj/item/handheld_dispenser/New()
	. = ..()
	if (!src.atmospipesforcreation)
		src.atmospipesforcreation = list()
		for (var/datum/pipe_recipe/pipe/recipe as anything in concrete_typesof(/datum/pipe_recipe/pipe))
			src.atmospipesforcreation[initial(recipe.name)] = new recipe

	if (!src.atmosmachinesforcreation)
		src.atmosmachinesforcreation = list()
		for (var/datum/pipe_recipe/machine/recipe as anything in concrete_typesof(/datum/pipe_recipe/machine))
			src.atmosmachinesforcreation[initial(recipe.name)] = new recipe

	src.selection = src.atmospipesforcreation["Pipe"]

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
		"selectedimage" = (src.selectedimage || getBase64Img(selection.path, src.direction)),
		"selectedcost" = src.selection.cost,
		"resources" = src.resources,
		"destroying" = src.destroying,
	)

/obj/item/handheld_dispenser/ui_static_data(mob/user)
	. = list(
	)
	for (var/name in atmospipesforcreation)
		var/datum/pipe_recipe/pipe/recipe = src.atmospipesforcreation[name]
		.["atmospipes"] += list(list(
			"name" = name,
			"image" = getBase64Img(recipe.path),
			"cost" = recipe.cost,
			))
	for (var/name in src.atmosmachinesforcreation)
		var/datum/pipe_recipe/machine/recipe = src.atmosmachinesforcreation[name]
		.["atmosmachines"] += list(list(
			"name" = name,
			"image" = getBase64Img(recipe.path),
			"cost" = recipe.cost,
			))

/obj/item/handheld_dispenser/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if (.)
		return
	switch(action)
		if("select")
			src.selection = atmospipesforcreation[params["name"]] || atmosmachinesforcreation[params["name"]]
			src.selectedimage = getBase64Img(src.selection.path, direction)
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

/datum/pipe_recipe
	var/path
	var/cost = 2
	var/name = "CALL 1800 CODER"

ABSTRACT_TYPE(/datum/pipe_recipe/pipe)
/datum/pipe_recipe/pipe
	simple
		name = "Pipe"
		path = /obj/machinery/atmospherics/pipe/simple/overfloor
		cost = 1
	manifold
		name = "Manifold"
		path = /obj/machinery/atmospherics/pipe/manifold/overfloor
	quad_manifold
		name = "Quadway manifold"
		path = /obj/machinery/atmospherics/pipe/quadway
		cost = 4 //quad
	heat_pipe
		name = "Heat exchanging pipe"
		path = /obj/machinery/atmospherics/pipe/simple/heat_exchanging
		cost = 3
	heat_junction
		name = "HE junction"
		path = /obj/machinery/atmospherics/pipe/simple/junction

ABSTRACT_TYPE(/datum/pipe_recipe/machine)
/datum/pipe_recipe/machine
	cost = 4
	vent
		name = "Passive vent"
		path = /obj/machinery/atmospherics/unary/vent
	tank
		cost = 8
		name = "Pressure tank"
		path = /obj/machinery/atmospherics/unary/tank
	gate
		name = "Passive gate"
		path = /obj/machinery/atmospherics/binary/passive_gate
	pressure_pump
		name = "Pressure pump"
		path = /obj/machinery/atmospherics/binary/pump
	volume_pump
		name = "Volume pump"
		path = /obj/machinery/atmospherics/binary/volume_pump
	valve
		name = "Manual valve"
		path = /obj/machinery/atmospherics/binary/valve
	digital_valve
		name = "Digital valve"
		path = /obj/machinery/atmospherics/binary/valve/digital
	outlet_injector
		name = "Outlet Injector"
		path = /obj/machinery/atmospherics/unary/outlet_injector
	vent_pump
		name = "Vent pump"
		path = /obj/machinery/atmospherics/unary/vent_pump
	vent_scrubber
		name = "Vent scrubber"
		path = /obj/machinery/atmospherics/unary/vent_scrubber
