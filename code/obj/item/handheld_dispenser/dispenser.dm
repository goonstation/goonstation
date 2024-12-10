/obj/item/places_pipes
	name = "handheld pipe dispenser"
	desc = "A neat tool to quickly lay down pipes onto the floor."
	icon = 'icons/obj/items/hpd.dmi'
	icon_state = "hpd"
	flags = TABLEPASS | CONDUCT
	var/dispenser_being_used = FALSE
	var/dispenser_delay = 1 DECI SECONDS
	var/static/list/atmospipesforcreation = null
	var/static/list/atmosmachinesforcreation = null
	var/static/list/icon/cache = list()
	var/datum/pipe_recipe/selection = null
	var/selectedimage
	var/direction = EAST
	var/destroying = FALSE
	var/resources = 50

/obj/item/places_pipes/New()
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

/obj/item/places_pipes/attack_self(mob/user )
	src.ui_interact(user)

/obj/item/places_pipes/afterattack(atom/target, mob/user)
	if (!can_reach(user, target))
		return
	if(destroying)
		if(istype(target, /obj/machinery/atmospherics))
			qdel(target)

	else
		var/directs = selection.get_directions(direction)
		for(var/obj/machinery/atmospherics/device in get_turf(target))
			if(device.initialize_directions & directs)
				boutput(user, SPAN_ALERT("NOOOOOO"))
				return
		new /dmm_suite/preloader(get_turf(target), list("dir" = direction))
		var/obj/machinery/atmospherics/device = new selection.path(get_turf(target))
		device.initialize(TRUE)
/obj/item/places_pipes/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "HandPipeDispenser", name)
		ui.open()

/obj/item/places_pipes/ui_data(mob/user)
	. = list(
		"selectedimage" = (src.selectedimage || getBase64Img(selection, src.direction)),
		"selectedcost" = src.selection.cost,
		"resources" = src.resources,
		"destroying" = src.destroying,
	)

/obj/item/places_pipes/ui_static_data(mob/user)
	. = list(
	)
	for (var/name in atmospipesforcreation)
		var/datum/pipe_recipe/pipe/recipe = src.atmospipesforcreation[name]
		.["atmospipes"] += list(list(
			"name" = name,
			"image" = getBase64Img(recipe),
			"cost" = recipe.cost,
			))
	for (var/name in src.atmosmachinesforcreation)
		var/datum/pipe_recipe/machine/recipe = src.atmosmachinesforcreation[name]
		.["atmosmachines"] += list(list(
			"name" = name,
			"image" = getBase64Img(recipe),
			"cost" = recipe.cost,
			))

/obj/item/places_pipes/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if (.)
		return
	switch(action)
		if("select")
			src.selection = atmospipesforcreation[params["name"]] || atmosmachinesforcreation[params["name"]]
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

/obj/item/places_pipes/proc/getBase64Img(datum/pipe_recipe/recipe, direction = SOUTH)
	. = src.cache["[recipe.name][direction]"]
	if(.)
		return
	. = icon2base64(icon = icon(icon = recipe.icon, icon_state = recipe.icon_state, dir = direction))
	src.cache["[recipe.name][direction]"] = .

/obj/item/places_pipes/proc/do_pipe_action()

/datum/pipe_recipe
	var/icon = 'icons/obj/atmospherics/hhd_recipe_images.dmi'
	var/icon_state
	var/path
	var/cost = 2
	var/name = "CALL 1800 CODER"

	proc/get_directions(dir)
		return 0

ABSTRACT_TYPE(/datum/pipe_recipe/pipe)
/datum/pipe_recipe/pipe
	simple
		name = "Pipe"
		path = /obj/machinery/atmospherics/pipe/simple/overfloor
		cost = 1
		icon_state = "pipe"

		get_directions(dir)
			switch(dir)
				if(NORTH, SOUTH)
					return NORTH|SOUTH
				if(EAST, WEST)
					return EAST|WEST
	bent
		name = "Bent pipe"
		path = /obj/machinery/atmospherics/pipe/simple/overfloor
		cost = 1
		icon_state = "pipebent"

		get_directions(dir)
			switch(dir)
				if(NORTH)
					return NORTH|WEST
				if(SOUTH)
					return SOUTH|EAST
				if(EAST)
					return NORTH|EAST
				if(WEST)
					return SOUTH|WEST

	manifold
		name = "Manifold"
		path = /obj/machinery/atmospherics/pipe/manifold/overfloor
		icon_state = "manifold"

		get_directions(dir)
			switch(dir)
				if(NORTH)
					return EAST|WEST|SOUTH
				if(SOUTH)
					return EAST|WEST|NORTH
				if(EAST)
					return NORTH|SOUTH|WEST
				if(WEST)
					return NORTH|SOUTH|EAST

	quad_manifold
		name = "Quadway manifold"
		path = /obj/machinery/atmospherics/pipe/quadway
		cost = 4 //quad
		icon_state = "4way"

		get_directions(dir)
			return NORTH|SOUTH|EAST|WEST

	heat_pipe
		name = "Heat exchanging pipe"
		path = /obj/machinery/atmospherics/pipe/simple/heat_exchanging
		cost = 3
		icon_state = "heatpipe"

		get_directions(dir)
			switch(dir)
				if(NORTH, SOUTH)
					return NORTH|SOUTH
				if(EAST, WEST)
					return EAST|WEST

	bent_heat_pipe
		name = "Bent Heat exchanging pipe"
		path = /obj/machinery/atmospherics/pipe/simple/heat_exchanging
		cost = 3
		icon_state = "heatpipebent"

		get_directions(dir)
			switch(dir)
				if(NORTH)
					return NORTH|WEST
				if(SOUTH)
					return SOUTH|EAST
				if(EAST)
					return NORTH|EAST
				if(WEST)
					return SOUTH|WEST

	heat_junction
		name = "HE junction"
		path = /obj/machinery/atmospherics/pipe/simple/junction
		icon_state = "junction"

		get_directions(dir)
			switch(dir)
				if(NORTH, SOUTH)
					return NORTH|SOUTH
				if(EAST, WEST)
					return EAST|WEST

ABSTRACT_TYPE(/datum/pipe_recipe/machine)
/datum/pipe_recipe/machine
	cost = 4

ABSTRACT_TYPE(/datum/pipe_recipe/machine/unary)
/datum/pipe_recipe/machine/unary
	get_directions(dir)
		return dir
	vent
		name = "Passive vent"
		path = /obj/machinery/atmospherics/unary/vent
		icon_state = "vent"
	tank
		cost = 8
		name = "Pressure tank"
		path = /obj/machinery/atmospherics/unary/tank
		icon_state = "tank"

	outlet_injector
		name = "Outlet Injector"
		path = /obj/machinery/atmospherics/unary/outlet_injector/overfloor
		icon_state = "injector"
	vent_pump
		name = "Vent pump"
		path = /obj/machinery/atmospherics/unary/vent_pump/overfloor/inactive
		icon_state = "ventpump"
	vent_scrubber
		name = "Vent scrubber"
		path = /obj/machinery/atmospherics/unary/vent_scrubber/overfloor/inactive
		icon_state = "ventscrubber"
ABSTRACT_TYPE(/datum/pipe_recipe/machine/binary)
/datum/pipe_recipe/machine/binary
	get_directions(dir)
		switch(dir)
			if(NORTH, SOUTH)
				return NORTH|SOUTH
			if(EAST, WEST)
				return EAST|WEST
	gate
		name = "Passive gate"
		path = /obj/machinery/atmospherics/binary/passive_gate
		icon_state = "passivegate"
	pressure_pump
		name = "Pressure pump"
		path = /obj/machinery/atmospherics/binary/pump
		icon_state = "pump"
	volume_pump
		name = "Volume pump"
		path = /obj/machinery/atmospherics/binary/volume_pump
		icon_state = "volumepump"
	valve
		name = "Manual valve"
		path = /obj/machinery/atmospherics/binary/valve
		icon_state = "valve"
	digital_valve
		name = "Digital valve"
		path = /obj/machinery/atmospherics/binary/valve/digital
		icon_state = "digitalvalve"
