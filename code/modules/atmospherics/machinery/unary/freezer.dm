/obj/machinery/atmospherics/unary/cold_sink/freezer
	name = "freezer"
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "freezer_0-map"
	density = TRUE
	anchored = ANCHORED
	current_heat_capacity = 1000

	var/min_temp_possible = 73.15 KELVIN
	var/max_temp_possible = T20C

/obj/machinery/atmospherics/unary/cold_sink/freezer/New()
	..()
	src.AddComponent(/datum/component/obj_projectile_damage)

/obj/machinery/atmospherics/unary/cold_sink/freezer/update_icon()
	icon_state = src.on ? "freezer_1" : "freezer_0"
	SET_PIPE_UNDERLAY(src.node, src.dir, "long", issimplepipe(src.node) ?  src.node.color : null, FALSE)

/obj/machinery/atmospherics/unary/cold_sink/freezer/process()
	..()
	if(prob(5) && src.on)
		playsound(src.loc, pick(ambience_atmospherics), 30, 1)

/obj/machinery/atmospherics/unary/cold_sink/freezer/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("active_toggle")
			src.on = !src.on
			UpdateIcon()
			. = TRUE
		if("set_target_temperature")
			src.current_temperature = clamp(params["value"], src.min_temp_possible, src.max_temp_possible)
			. = TRUE

/obj/machinery/atmospherics/unary/cold_sink/freezer/ui_data(mob/user)
	. = ..()
	.["active"] = src.on
	.["target_temperature"] = src.current_temperature
	.["air_temperature"] = src.air_contents.temperature
	.["air_pressure"] = MIXTURE_PRESSURE(src.air_contents)

/obj/machinery/atmospherics/unary/cold_sink/freezer/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "Freezer")
		ui.set_autoupdate(TRUE)
		ui.open()

/obj/machinery/atmospherics/unary/cold_sink/freezer/attackby(obj/item/I, mob/user) //let's just make these breakable for now
	if (I.force)
		src.visible_message(SPAN_ALERT("[user] hits \the [src] with \a [I]!"))
		user.lastattacked = get_weakref(src)
		attack_particle(user, src)
		hit_twitch(src)
		playsound(src.loc, 'sound/impact_sounds/Metal_Hit_Light_1.ogg', 50, TRUE)
		logTheThing(LOG_STATION, user, "attacks [src] [log_atmos(src)] with [I] at [log_loc(src)].")
		src.changeHealth(-I.force)
	..()

/obj/machinery/atmospherics/unary/cold_sink/freezer/onDestroy()
	var/atom/location = src.loc
	location.assume_air(air_contents)
	air_contents = null
	src.gib(location)
	..()

// Medbay and kitchen freezers start at correct temperature to avoid pointless busywork.
/obj/machinery/atmospherics/unary/cold_sink/freezer/cryo
	name = "freezer (cryo cell)"
	current_temperature = 73.15 KELVIN

/obj/machinery/atmospherics/unary/cold_sink/freezer/kitchen
	name = "freezer (kitchen)"
	current_temperature = 150 KELVIN
	on = TRUE
	icon_state = "freezer_1-map"

/obj/machinery/atmospherics/unary/cold_sink/freezer/emergency
	name = "emergency cooler"
	current_temperature = 73.15 KELVIN
	desc = "Emergency cooling for the reactor. Only for use in meltdown scenarios."
