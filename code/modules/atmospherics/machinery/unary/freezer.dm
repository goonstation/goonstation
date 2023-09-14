/obj/machinery/atmospherics/unary/cold_sink/freezer
	name = "freezer"
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "freezer_0"
	density = TRUE
	anchored = ANCHORED
	current_heat_capacity = 1000

	var/min_temp_possible = 73.15 KELVIN
	var/max_temp_possible = T20C

/obj/machinery/atmospherics/unary/cold_sink/freezer/update_icon()
	if(src.node)
		if(src.on)
			icon_state = "freezer_1"
		else
			icon_state = "freezer_0"
	else
		icon_state = "freezer"

/obj/machinery/atmospherics/unary/cold_sink/freezer/process()
	..()
	if(prob(5) && src.on)
		playsound(src.loc, ambience_atmospherics, 30, 1)

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


// Medbay and kitchen freezers start at correct temperature to avoid pointless busywork.
/obj/machinery/atmospherics/unary/cold_sink/freezer/cryo
	name = "freezer (cryo cell)"
	current_temperature = 73.15 KELVIN

/obj/machinery/atmospherics/unary/cold_sink/freezer/kitchen
	name = "freezer (kitchen)"
	current_temperature = 150 KELVIN
	on = TRUE

/obj/machinery/atmospherics/unary/cold_sink/freezer/emergency
	name = "emergency cooler"
	current_temperature = 73.15 KELVIN
	desc = "Emergency cooling for the reactor. Only for use in meltdown scenarios."
