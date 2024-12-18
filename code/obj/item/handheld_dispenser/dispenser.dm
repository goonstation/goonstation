/obj/item/places_pipes
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
	var/datum/pipe_recipe/selection = /datum/pipe_recipe/pipe/simple
	var/selectedimage
	var/direction = EAST
	var/destroying = FALSE
	var/resources = 50
	var/max_resources = 50

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

/obj/item/places_pipes/get_desc()
	. += "<br>It holds [src.resources] units. It is currently set to make a [selection.name]."

/obj/item/places_pipes/attackby(obj/item/W, mob/user)
	if (istype(W, /obj/item/rcd_ammo))
		src.load_ammo(user, W)
		return
	. = ..()

/obj/item/places_pipes/proc/load_ammo(mob/user, obj/item/rcd_ammo/ammo)
	if (!ammo.matter)
		return
	if (src.resources == src.max_resources)
		boutput(user, "\The [src] can't hold any more matter.")
		return
	if (src.resources + ammo.matter > src.max_resources)
		ammo.matter -= (src.max_resources - src.resources)
		boutput(user, "The cartridge now contains [ammo.matter] units of matter.")
		src.resources = src.max_resources
		ammo.tooltip_rebuild = 1
	else
		src.resources += ammo.matter
		ammo.matter = 0
		qdel(ammo)
	src.tooltip_rebuild = 1
	playsound(src, 'sound/machines/click.ogg', 50, TRUE)
	boutput(user, "\The [src] now holds [src.resources] matter-units.")

/obj/item/places_pipes/afterattack(atom/target, mob/user)
	if (!can_reach(user, target))
		return
	if(destroying)
		if(istype(target, /obj/machinery/atmospherics)) //hilarium
			SETUP_GENERIC_ACTIONBAR(target, src, src.dispenser_delay, PROC_REF(destroy_item), list(user, target),\
			 null, null, null, INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ATTACKED)

	else
		if(!isturf(target))
			return
		var/directs = selection.get_directions(direction)
		for(var/obj/machinery/atmospherics/device in target)
			if(device.initialize_directions & directs)
				boutput(user, SPAN_ALERT("Something is occupying that direction!"))
				return
		if(src.resources < selection.cost)
			boutput(user, SPAN_ALERT("Not enough resources to make a [selection.name]!"))
			return
		var/icon/rotated_icon = icon(selection.icon, selection.icon_state, src.direction)
		var/datum/action/bar/icon/callback/actionbar = new (\
			target, src, src.dispenser_delay, PROC_REF(create_item), list(target, user, selection, direction),\
			rotated_icon, null, null, INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ATTACKED
		)
		actions.start(actionbar, user)

/obj/item/places_pipes/proc/create_item(turf/target, mob/user, datum/pipe_recipe/recipe, direction)
	if(!(user && can_reach(user, target)))
		boutput(user, SPAN_ALERT("Can't reach there!"))
		return
	if(src.resources < selection.cost)
		boutput(user, SPAN_ALERT("Not enough resources to make a [recipe.name]!"))
		return
	var/directs = recipe.get_directions(direction)
	for(var/obj/machinery/atmospherics/device in target)
		if(device.initialize_directions & directs)
			boutput(user, SPAN_ALERT("Something is occupying that direction!"))
			return
	src.resources -= recipe.cost
	src.tooltip_rebuild = 1
	user.visible_message(SPAN_NOTICE("[user] places a [recipe.name]."))
	logTheThing(LOG_STATION, user, "places a [recipe.name] at [log_loc(target)] with an HPD")
	new /dmm_suite/preloader(target, list("dir" = (recipe.bent ? turn(direction, 45) : direction)))
	var/obj/machinery/atmospherics/device = new recipe.path(target)
	device.initialize(TRUE)
	playsound(src, 'sound/machines/click.ogg', 50, TRUE)

/obj/item/places_pipes/proc/destroy_item(mob/user, obj/machinery/atmospherics/target)
	if(!src.resources)
		boutput(user, SPAN_ALERT("Not enough resources to destroy that!"))
		return
	boutput(user, SPAN_NOTICE("The [src] destroys the [target]!"))
	logTheThing(LOG_STATION, user, "destroys a [target] at [log_loc(target)] with an HPD")
	resources -= 1
	src.tooltip_rebuild = 1
	qdel(target)
	playsound(src, 'sound/machines/click.ogg', 50, TRUE)

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
			src.tooltip_rebuild = 1
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
	var/bent = FALSE // not a big fan, but its a shrimple solution to bent pipes

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

		insulated
			name = "Insulated pipe"
			path = /obj/machinery/atmospherics/pipe/simple/insulated
			cost = 2
			icon_state = "insulatedpipe"

	bent
		name = "Bent pipe"
		path = /obj/machinery/atmospherics/pipe/simple/overfloor
		cost = 1
		icon_state = "pipebent"
		bent = TRUE

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

		insulated
			name = "Bent insulated pipe"
			path = /obj/machinery/atmospherics/pipe/simple/insulated
			cost = 2
			icon_state = "insulatedpipebent"

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
		path = /obj/machinery/atmospherics/pipe/quadway/overfloor
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
		bent = TRUE

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
	connector
		name = "Portable Connector"
		path = /obj/machinery/atmospherics/unary/portables_connector
		icon_state = "connector"
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
