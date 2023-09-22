/obj/machinery/atmospherics/unary/heat_reservoir
	//currently the same code as cold_sink but anticipating process() changes
	name = "Heat Reservoir"
	desc = "Heats gas when connected to pipe network"
	icon = 'icons/obj/atmospherics/heat_reservoir.dmi'
	icon_state = "intact_off"
	density = TRUE

	var/on = FALSE
	var/current_temperature = T20C
	var/current_heat_capacity = 50000 //totally random

/obj/machinery/atmospherics/unary/heat_reservoir/update_icon()
	if(src.node)
		icon_state = "intact_[src.on?("on"):("off")]"
	else
		icon_state = "exposed"

		on = FALSE

/obj/machinery/atmospherics/unary/heat_reservoir/process()
	..()
	if(!src.on)
		return FALSE
	var/air_heat_capacity = HEAT_CAPACITY(src.air_contents)
	var/combined_heat_capacity = current_heat_capacity + air_heat_capacity
	var/old_temperature = src.air_contents.temperature

	if(combined_heat_capacity > 0)
		var/combined_energy = current_temperature*current_heat_capacity + air_heat_capacity*src.air_contents.temperature
		src.air_contents.temperature = combined_energy/combined_heat_capacity

	//todo: have current temperature affected. require power to bring up current temperature again

	if(abs(old_temperature - src.air_contents.temperature) > 1 KELVIN)
		src.network.update = TRUE
	return TRUE
