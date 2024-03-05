/obj/machinery/atmospherics/unary/cold_sink
	name = "Cold Sink"
	desc = "Cools gas when connected to pipe network"
	icon = 'icons/obj/atmospherics/cold_sink.dmi'
	icon_state = "intact_off"
	density = TRUE

	var/on = FALSE
	/// What temperature are we changing the gas to.
	var/current_temperature = T20C
	/// How well do we change a mixture's temperature, essentially.
	var/current_heat_capacity = 50000 //totally random

/obj/machinery/atmospherics/unary/cold_sink/update_icon()
	if(node)
		icon_state = "intact_[src.on?("on"):("off")]"
	else
		icon_state = "exposed"
		src.on = FALSE

/obj/machinery/atmospherics/unary/cold_sink/process()
	..()
	if(!src.on)
		return FALSE

	var/air_heat_capacity = HEAT_CAPACITY(src.air_contents)
	var/combined_heat_capacity = current_heat_capacity + air_heat_capacity
	var/old_temperature = src.air_contents.temperature

	if(combined_heat_capacity > 0)
		var/combined_energy = current_temperature*current_heat_capacity + air_heat_capacity*air_contents.temperature
		air_contents.temperature = combined_energy/combined_heat_capacity
		src.use_power(round(abs(old_temperature-air_contents.temperature)), ENVIRON) // watt per degree kelvin changed

	if(abs(old_temperature-air_contents.temperature) > 1 KELVIN && src.network)
		src.network.update = TRUE
	return TRUE
