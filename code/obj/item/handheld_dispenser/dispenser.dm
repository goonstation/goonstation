TYPEINFO(/obj/item/places_pipes)
	mats = list("metal_superdense" = 12,
				"crystal_dense" = 6,
				"conductive_high" = 6,
				"energy_high" = 6)
/obj/item/places_pipes
	name = "handheld pipe dispenser"
	desc = "A neat tool to quickly lay down pipes onto the floor."
	icon = 'icons/obj/items/hpd.dmi'
	icon_state = "hpd-place"
	flags = TABLEPASS | CONDUCT
	inventory_counter_enabled = 1
	var/department_postfix = null //used for alternate colour HPDs
	var/dispenser_being_used = FALSE
	var/dispenser_delay = 5 DECI SECONDS
	var/static/list/atmospipesforcreation = null
	var/static/list/atmosmachinesforcreation = null
	var/static/list/fluidpipesforcreation = null
	var/static/list/fluidmachinesforcreation = null
	var/static/list/icon/cache = list()
	var/static/list/exemptedtypes = typecacheof(list(/obj/machinery/atmospherics/binary/circulatorTemp,
		/obj/machinery/nuclear_reactor,
		/obj/machinery/reactor_turbine,
		/obj/machinery/atmospherics/unary/cryo_cell))
	var/const/silicon_cost_multiplier = 200
	var/datum/pipe_recipe/selection = /datum/pipe_recipe/atmos/pipe/simple
	var/selectedimage
	var/direction = EAST
	var/destroying = FALSE
	var/resources = 50
	var/max_resources = 50

/obj/item/places_pipes/New()
	. = ..()
	if (!src.atmospipesforcreation)
		src.atmospipesforcreation = list()
		for (var/datum/pipe_recipe/recipe as anything in concrete_typesof(/datum/pipe_recipe/atmos/pipe))
			src.atmospipesforcreation[initial(recipe.name)] = new recipe

	if (!src.atmosmachinesforcreation)
		src.atmosmachinesforcreation = list()
		for (var/datum/pipe_recipe/recipe as anything in concrete_typesof(/datum/pipe_recipe/atmos/machine))
			src.atmosmachinesforcreation[initial(recipe.name)] = new recipe

	if (!src.fluidpipesforcreation)
		src.fluidpipesforcreation = list()
		for (var/datum/pipe_recipe/recipe as anything in concrete_typesof(/datum/pipe_recipe/fluid/pipe))
			src.fluidpipesforcreation[initial(recipe.name)] = new recipe

	if (!src.fluidmachinesforcreation)
		src.fluidmachinesforcreation = list()
		for (var/datum/pipe_recipe/recipe as anything in concrete_typesof(/datum/pipe_recipe/fluid/machine))
			src.fluidmachinesforcreation[initial(recipe.name)] = new recipe
	src.selection = src.atmospipesforcreation["Pipe"]
	src.UpdateIcon()

/obj/item/places_pipes/update_icon(...)
	if (src.destroying)
		src.icon_state = "hpd-destroy" + department_postfix
	else
		src.icon_state = "hpd-place" + department_postfix

	var/fullness = round(src.resources/src.max_resources * 100, 25)
	if (fullness <= 0)
		src.UpdateOverlays(null, "ammo")
	else
		src.UpdateOverlays(image(src.icon, "ammo-[fullness]"), "ammo")

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
	if(issilicon(user))
		return
	if (!ammo.matter)
		return
	if (src.resources == src.max_resources)
		boutput(user, "\The [src] can't hold any more matter.")
		return
	if (src.resources + ammo.matter > src.max_resources)
		ammo.matter -= (src.max_resources - src.resources)
		boutput(user, "The cartridge now contains [ammo.matter] units of matter.")
		src.resources = src.max_resources
		ammo.tooltip_rebuild = TRUE
	else
		src.resources += ammo.matter
		ammo.matter = 0
		qdel(ammo)
	src.tooltip_rebuild = TRUE
	if (!issilicon(user))
		src.inventory_counter.update_number(src.resources)
	src.UpdateIcon()
	playsound(src, 'sound/machines/click.ogg', 50, TRUE)
	boutput(user, "\The [src] now holds [src.resources] matter-units.")

/obj/item/places_pipes/afterattack(atom/target, mob/user)
	if (!can_reach(user, target))
		return
	if(destroying)
		if(src.exemptedtypes[target.type]) //hilarium
			actions.start(new /datum/action/bar/hpd_exemption_failure(target, user, src), user)
			return
		if(istype(target, /obj/machinery/atmospherics) || istype(target, /obj/fluid_pipe) || istype(target, /obj/machinery/fluid_machinery))
			SETUP_GENERIC_ACTIONBAR(target, src, src.dispenser_delay, PROC_REF(destroy_item), list(user, target),\
			 null, null, null, INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ATTACKED)

	else
		if(!issimulatedturf(target) && !istype(target, /turf/space))
			return
		var/directs = selection.get_directions(direction)
		if(istype(src.selection, /datum/pipe_recipe/atmos))
			for(var/obj/machinery/atmospherics/device in target)
				if((device.initialize_directions & directs))
					boutput(user, SPAN_ALERT("Something is occupying that direction!"))
					return
				if(selection.exclusionary && device.exclusionary)
					boutput(user, SPAN_ALERT("Something is occupying that space!"))
					return
		else
			var/obj/fluid_pipe/fluidthingy
			for(var/obj/device in target)
				if(!istype(device, /obj/fluid_pipe) && !istype(device, /obj/machinery/fluid_machinery))
					continue
				fluidthingy = device
				if((fluidthingy.initialize_directions & directs))
					boutput(user, SPAN_ALERT("Something is occupying that direction!"))
					return
				if(selection.exclusionary && fluidthingy.exclusionary)
					boutput(user, SPAN_ALERT("Something is occupying that space!"))
					return
		if (issilicon(user))
			var/mob/living/silicon/S = user
			if (!(S.cell && (S.cell.charge >= selection.cost * silicon_cost_multiplier)))
				boutput(user, SPAN_ALERT("Not enough charge to make a [selection.name]!"))
				return
		else if(src.resources < selection.cost)
			boutput(user, SPAN_ALERT("Not enough resources to make a [selection.name]!"))
			return
		var/icon/rotated_icon = icon(selection.icon, selection.icon_state, src.direction)
		var/datum/action/bar/icon/callback/actionbar = new (\
			target, src, src.dispenser_delay, PROC_REF(create_item), list(target, user, selection, direction),\
			rotated_icon, null, null, INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ATTACKED
		)
		actions.start(actionbar, user)

/obj/item/places_pipes/proc/create_item(turf/target, mob/user, datum/pipe_recipe/recipe, direction)
	var/mob/living/silicon/S
	if(!(user && can_reach(user, target)))
		boutput(user, SPAN_ALERT("Can't reach there!"))
		return
	if (issilicon(user))
		S = user
		if (!(S.cell && (S.cell.charge >= recipe.cost * silicon_cost_multiplier)))
			boutput(user, SPAN_ALERT("Not enough charge to make a [recipe.name]!"))
			return
	else if(src.resources < recipe.cost)
		boutput(user, SPAN_ALERT("Not enough resources to make a [recipe.name]!"))
		return
	var/directs = recipe.get_directions(direction)
	if(istype(src.selection, /datum/pipe_recipe/atmos))
		for(var/obj/machinery/atmospherics/device in target)
			if((device.initialize_directions & directs))
				boutput(user, SPAN_ALERT("Something is occupying that direction!"))
				return
			if(selection.exclusionary && device.exclusionary)
				boutput(user, SPAN_ALERT("Something is occupying that space!"))
				return
	else
		var/obj/fluid_pipe/fluidthingy
		for(var/obj/device in target)
			if(!istype(device, /obj/fluid_pipe) && !istype(device, /obj/machinery/fluid_machinery))
				continue
			fluidthingy = device
			if((fluidthingy.initialize_directions & directs))
				boutput(user, SPAN_ALERT("Something is occupying that direction!"))
				return
			if(selection.exclusionary && fluidthingy.exclusionary)
				boutput(user, SPAN_ALERT("Something is occupying that space!"))
				return
	if (S?.cell)
		S.cell.use(recipe.cost * silicon_cost_multiplier)
	else
		src.resources -= recipe.cost
	if (!issilicon(user))
		src.inventory_counter.update_number(src.resources)
	src.tooltip_rebuild = TRUE
	logTheThing(LOG_STATION, user, "places a [recipe.name] at [log_loc(target)] with dir: [target.dir] with an HPD")
	new /dmm_suite/preloader(target, list("dir" = (recipe.bent ? turn(direction, 45) : direction)))
	var/obj/device = new recipe.path(target)
	device.initialize(TRUE)
	user.visible_message(SPAN_NOTICE("[user] places [device]."))
	src.UpdateIcon()
	playsound(src, 'sound/machines/click.ogg', 50, TRUE)

/obj/item/places_pipes/proc/destroy_item(mob/user, obj/machinery/atmospherics/target)
	var/mob/living/silicon/S
	user.visible_message(SPAN_NOTICE("[user] destroys [target]."))
	logTheThing(LOG_STATION, user, "destroys a [target] at [log_loc(target)] with dir: [target.dir] with an HPD")
	if(istype(target, /obj/machinery/atmospherics/binary/valve))
		var/obj/machinery/atmospherics/binary/valve/O = target
		if(O.high_risk)
			message_admins("[key_name(user)] has destroyed the high-risk valve: [target] at [log_loc(src)]")
	if (S?.cell)
		S.cell.give(src.silicon_cost_multiplier)
	else
		resources += (src.resources + 1 <= src.max_resources) ? 1 : 0
	if (!issilicon(user))
		src.inventory_counter.update_number(src.resources)
	src.tooltip_rebuild = TRUE
	if (istype(target, /obj/machinery/atmospherics))
		qdel(target)
	else
		target.onDestroy()
	src.UpdateIcon()
	playsound(src, 'sound/machines/click.ogg', 50, TRUE)

/obj/item/places_pipes/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "HandPipeDispenser", name)
		ui.open()

/obj/item/places_pipes/proc/getBase64Img(datum/pipe_recipe/recipe, direction = SOUTH)
	. = src.cache["[recipe.name][direction]"]
	if(.)
		return
	. = icon2base64(icon = icon(icon = recipe.icon, icon_state = recipe.icon_state, dir = direction))
	src.cache["[recipe.name][direction]"] = .

/obj/item/places_pipes/ui_data(mob/user)
	var/mob/living/silicon/S
	if (issilicon(user))
		S = user
	. = list(
		"selectedimage" = (src.selectedimage || getBase64Img(selection, src.direction)),
		"selectedcost" = S ? (src.selection.cost * silicon_cost_multiplier) : src.selection.cost,
		"resources" = S ? (S.cell ? S.cell.charge : 0) : src.resources,
		"destroying" = src.destroying,
		"selecteddesc" = src.selection.desc,
	)

/obj/item/places_pipes/ui_static_data(mob/user)
	. = list(
	)
	var/siliconmodifier = issilicon(user) ? silicon_cost_multiplier : 1
	for (var/name in atmospipesforcreation)
		var/datum/pipe_recipe/recipe = src.atmospipesforcreation[name]
		.["atmospipes"] += list(list(
			"name" = name,
			"image" = getBase64Img(recipe),
			"cost" = recipe.cost * siliconmodifier,
			))
	for (var/name in src.atmosmachinesforcreation)
		var/datum/pipe_recipe/recipe = src.atmosmachinesforcreation[name]
		.["atmosmachines"] += list(list(
			"name" = name,
			"image" = getBase64Img(recipe),
			"cost" = recipe.cost * siliconmodifier,
			))
	for (var/name in src.fluidpipesforcreation)
		var/datum/pipe_recipe/recipe = src.fluidpipesforcreation[name]
		.["fluidpipes"] += list(list(
			"name" = name,
			"image" = getBase64Img(recipe),
			"cost" = recipe.cost * siliconmodifier,
			))
	for (var/name in src.fluidmachinesforcreation)
		var/datum/pipe_recipe/recipe = src.fluidmachinesforcreation[name]
		.["fluidmachines"] += list(list(
			"name" = name,
			"image" = getBase64Img(recipe),
			"cost" = recipe.cost * siliconmodifier,
			))
	.["issilicon"] = issilicon(user)

/obj/item/places_pipes/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if (.)
		return
	switch(action)
		if("select")
			src.selection = atmospipesforcreation[params["name"]] || atmosmachinesforcreation[params["name"]] || \
				fluidpipesforcreation[params["name"]] || fluidmachinesforcreation[params["name"]]
			src.selectedimage = getBase64Img(src.selection, direction)
			src.tooltip_rebuild = TRUE
			. = TRUE
		if("changedir")
			src.direction = text2num_safe(params["newdir"])
			//invalidate the cached selected image
			src.selectedimage = null
			. = TRUE
		if("toggle-destroying")
			src.destroying = !src.destroying
			src.UpdateIcon()
			. = TRUE

/obj/item/places_pipes/adminshenanigans
	name = "extremely powerful handheld pipe dispenser"
	resources = INFINITY
	max_resources = INFINITY
	dispenser_delay = 1 DECI SECOND

/datum/pipe_recipe
	var/icon = 'icons/obj/atmospherics/hhd_recipe_images.dmi'
	var/icon_state
	var/path
	var/cost = 2
	var/name = "CALL 1800 CODER"
	var/bent = FALSE // not a big fan, but its a shrimple solution to bent pipes
	/// Does not share space with another exclusionary object.
	var/exclusionary = FALSE
	var/desc = "This is a pipe which does like things idk."

	proc/get_directions(dir)
		return 0

ABSTRACT_TYPE(/datum/pipe_recipe/atmos/pipe)
/datum/pipe_recipe/atmos/pipe
	simple
		name = "Pipe"
		path = /obj/machinery/atmospherics/pipe/simple/overfloor
		cost = 1
		icon_state = "pipe"
		desc = "A simple uninsulated pipe. Conducts heat to and from its surroundings."

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
			desc = "A simple insulated pipe. Does not conduct heat to and from its surroundings."

	bent
		name = "Bent pipe"
		path = /obj/machinery/atmospherics/pipe/simple/overfloor
		cost = 1
		icon_state = "pipebent"
		bent = TRUE
		desc = "A simple uninsulated pipe. Conducts heat to and from its surroundings."

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
			desc = "A simple insulated pipe. Does not conduct heat to and from its surroundings."

	manifold
		name = "Manifold"
		path = /obj/machinery/atmospherics/pipe/manifold/overfloor
		icon_state = "manifold"
		desc = "A three way manifold."

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
		desc = "A four way manifold."

		get_directions(dir)
			return NORTH|SOUTH|EAST|WEST

	heat_pipe
		name = "Heat exchanging pipe"
		path = /obj/machinery/atmospherics/pipe/simple/heat_exchanging
		cost = 3
		icon_state = "heatpipe"
		desc = "A heat exchanging pipe. Conducts heat very well to and from its surroundings."

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
		desc = "A heat exchanging pipe. Conducts heat very well to and from its surroundings."

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
		desc = "For connecting heat exchanging pipes to regular ones."

		get_directions(dir)
			switch(dir)
				if(NORTH, SOUTH)
					return NORTH|SOUTH
				if(EAST, WEST)
					return EAST|WEST

ABSTRACT_TYPE(/datum/pipe_recipe/atmos/machine)
/datum/pipe_recipe/atmos/machine
	cost = 4

ABSTRACT_TYPE(/datum/pipe_recipe/atmos/machine/unary)
/datum/pipe_recipe/atmos/machine/unary
	exclusionary = TRUE
	get_directions(dir)
		return dir
	vent
		name = "Passive vent"
		path = /obj/machinery/atmospherics/unary/vent
		icon_state = "vent"
		desc = "Passively vents connected gases to the surrounding air."
	tank
		cost = 8
		name = "Pressure tank"
		path = /obj/machinery/atmospherics/unary/tank
		icon_state = "tank"
		desc = "A 1620 litre pressurized storage tank."
	freezer
		cost = 10
		name = "Freezer"
		path = /obj/machinery/atmospherics/unary/cold_sink/freezer
		icon_state = "freezer"
		desc = "A freezing unit that cools connected gases to a set temperature."
	connector
		name = "Portable Connector"
		path = /obj/machinery/atmospherics/unary/portables_connector
		icon_state = "connector"
		desc = "For connecting canisters, scrubbers, pumps and other portable machinery."
	outlet_injector
		name = "Outlet Injector"
		path = /obj/machinery/atmospherics/unary/outlet_injector/overfloor
		icon_state = "injector"
		desc = "A packet controlled injector that injects a set volume of gas into the surrounding air."
	vent_pump
		name = "Vent pump"
		path = /obj/machinery/atmospherics/unary/vent_pump/overfloor/inactive
		icon_state = "ventpump"
		desc = "A packet controlled pump that pumps gas in or out of a pipe up to and/or down to a set external or internal pressure."
	vent_scrubber
		name = "Vent scrubber"
		path = /obj/machinery/atmospherics/unary/vent_scrubber/overfloor/inactive
		icon_state = "ventscrubber"
		desc = "A packet controlled static scrubber that can filter specific gases out of the surrounding air."

ABSTRACT_TYPE(/datum/pipe_recipe/atmos/machine/binary)
/datum/pipe_recipe/atmos/machine/binary
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
		desc = "A one-way passive air valve. Tries to achieve a target pressure at output (like a normal pump), but without any actual pumping power. Use a multitool to configure."
	pressure_pump
		name = "Pressure pump"
		path = /obj/machinery/atmospherics/binary/pump
		icon_state = "pump"
		desc = "An inline pump that tries to achieve a target pressure on the output side. Can be configured with a wrench."
	volume_pump
		name = "Volume pump"
		path = /obj/machinery/atmospherics/binary/volume_pump
		icon_state = "volumepump"
		desc = "An inline pump that moves a set volume of gas over time, regardless of pressure."
	valve
		name = "Manual valve"
		path = /obj/machinery/atmospherics/binary/valve
		icon_state = "valve"
		desc = "A simple manual valve."
	digital_valve
		name = "Digital valve"
		path = /obj/machinery/atmospherics/binary/valve/digital
		icon_state = "digitalvalve"
		desc = "A digital valve that can be controlled by silicons or by hitting it with a wrench."
	pipepipehe
		name = "Pipe heat exchanger"
		path = /obj/machinery/atmospherics/binary/heat_exchanger
		icon_state = "heatexchanger"
		desc = "Not to be confused with the Heat exchanging pipe, this exchanges heat between pipes without mixing."

ABSTRACT_TYPE(/datum/pipe_recipe/atmos/machine/trinary)
/datum/pipe_recipe/atmos/machine/trinary
	get_directions(dir)
		switch(dir)
			if(NORTH)
				return NORTH|EAST|SOUTH
			if(EAST)
				return EAST|SOUTH|WEST
			if(SOUTH)
				return SOUTH|WEST|NORTH
			if(WEST)
				return WEST|NORTH|EAST

	filter
		name = "Gas Filter"
		icon_state = "gasfilter"
		path = /obj/machinery/atmospherics/trinary/filter
		desc = "A scrubber that filters out a chosen gas to the side."

ABSTRACT_TYPE(/datum/pipe_recipe/fluid/pipe)
/datum/pipe_recipe/fluid/pipe
	simple
		name = "Fluid pipe"
		path = /obj/fluid_pipe/straight/overfloor
		cost = 1
		icon_state = "fluidpipe"
		desc = "A mere fluid pipe."

		get_directions(dir)
			switch(dir)
				if(NORTH, SOUTH)
					return NORTH|SOUTH
				if(EAST, WEST)
					return EAST|WEST
		glass
			name = "See-through fluid pipe"
			path = /obj/fluid_pipe/straight/see_fluid/overfloor
			icon_state = "fluidpipeglass"
			cost = 2
			desc = "A mere fluid pipe. Now with glass!"

	bent
		name = "Bent fluid pipe"
		path = /obj/fluid_pipe/elbow/overfloor
		cost = 1
		icon_state = "bentfluidpipe"
		desc = "A mere fluid pipe."

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
	junction
		name = "Junction fluid pipe"
		path = /obj/fluid_pipe/t_junction/overfloor
		icon_state = "fluidjunction"
		desc = "A three way fluid pipe."

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

	quadway
		name = "Quadway fluid pipe"
		path = /obj/fluid_pipe/quad/overfloor
		cost = 3
		icon_state = "fluidquad"
		desc = "A four way fluid pipe"

		get_directions(dir)
			return NORTH|SOUTH|EAST|WEST

	tank
		name = "Fluid tank"
		path = /obj/fluid_pipe/fluid_tank
		cost = 10
		icon = 'icons/obj/fluidpipes/fluid_tank.dmi'
		icon_state = "tank"
		desc = "A very large tank capable of holding 10000 units"

		get_directions(dir)
			return dir

		glass
			name = "See-through fluid tank"
			path = /obj/fluid_pipe/fluid_tank/see_fluid
			cost = 11
			desc = "A very large tank capable of holding 10000 units. This one has a glass view!"
			icon_state = "tank-view"



ABSTRACT_TYPE(/datum/pipe_recipe/fluid/machine)
/datum/pipe_recipe/fluid/machine
	cost = 4

ABSTRACT_TYPE(/datum/pipe_recipe/fluid/machine/unary)
/datum/pipe_recipe/fluid/machine/unary
	exclusionary = TRUE
	get_directions(dir)
		return dir

	fluidinlet
		name = "Inlet drain"
		path = /obj/machinery/fluid_machinery/unary/drain/inlet_pump/overfloor
		icon_state = "fluidinlet"
		desc = "Drains between 10-15 units of fluid actively."

	handpump
		name = "Hand pump"
		path = /obj/machinery/fluid_machinery/unary/hand_pump
		icon_state = "handpump"
		desc = "Pumps out up to 100 units of fluid manually."

	nullifier
		name = "Nullifier"
		path = /obj/machinery/fluid_machinery/unary/nullifier
		icon_state = "nullifier"
		desc = "Removes up to 50 units per cycle."
	port
		name = "Port"
		path = /obj/machinery/fluid_machinery/unary/input
		icon_state = "port"
		desc = "Allows pouring in fluids into the network directly and connecting glass plumbing. Can pull 100 units from a screwed barrel per cycle."
	dispenser
		name = "Dispenser"
		path = /obj/machinery/fluid_machinery/unary/dispenser
		icon_state = "dispenser"
		desc = "Capable of printing patches, vials, and pills."
	dripper
		name = "Dripper"
		path = /obj/machinery/fluid_machinery/unary/dripper
		icon_state = "dripper"
		desc = "Passively drips up to 30 units onto the floor, or into connected containers."

ABSTRACT_TYPE(/datum/pipe_recipe/fluid/machine/binary)
/datum/pipe_recipe/fluid/machine/binary
	get_directions(dir)
		switch(dir)
			if(NORTH, SOUTH)
				return NORTH|SOUTH
			if(EAST, WEST)
				return EAST|WEST

	fluidpump
		name = "Fluid pump"
		path = /obj/machinery/fluid_machinery/binary/pump
		icon_state = "fluidpump"
		desc = "Pumps from one network to another at up to 200 units per pump."
	fluidvalve
		name = "Fluid valve"
		path = /obj/machinery/fluid_machinery/binary/valve
		icon_state = "fluidvalve"
		desc = "Connects two networks together when the valve is open."

ABSTRACT_TYPE(/datum/pipe_recipe/fluid/machine/trinary)
/datum/pipe_recipe/fluid/machine/trinary
	get_directions(dir)
		switch(dir)
			if(NORTH)
				return NORTH|EAST|SOUTH
			if(EAST)
				return EAST|SOUTH|WEST
			if(SOUTH)
				return SOUTH|WEST|NORTH
			if(WEST)
				return WEST|NORTH|EAST
	filter
		name = "Fluid Filter"
		path = /obj/machinery/fluid_machinery/trinary/filter
		icon_state = "fluidfilter"
		desc = "Separates fluid to the side. Requires a beaker with a minimum of 1 unit of the desired chem to filter. The largest volume is chosen."

/obj/item/places_pipes/research
	icon_state = "hpd-place-r"
	department_postfix = "-r"

/obj/item/places_pipes/civilian
	icon_state = "hpd-place-c"
	department_postfix = "-c"
