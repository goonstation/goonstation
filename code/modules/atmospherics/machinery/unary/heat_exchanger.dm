/obj/machinery/atmospherics/unary/heat_exchanger
	name = "Heat Exchanger"
	desc = "Exchanges heat between two input gases. Setup for fast heat transfer"
	icon = 'icons/obj/atmospherics/heat_exchanger.dmi'
	icon_state = "intact"
	density = TRUE

	var/obj/machinery/atmospherics/unary/heat_exchanger/partner = null
	var/update_cycle

/obj/machinery/atmospherics/unary/heat_exchanger/update_icon()
	if(node)
		icon_state = "intact"
	else
		icon_state = "exposed"

/obj/machinery/atmospherics/unary/heat_exchanger/initialize()
	if(!src.partner)
		var/partner_connect = turn(dir,180)

		for(var/obj/machinery/atmospherics/unary/heat_exchanger/target in get_step(src,partner_connect))
			if(target.dir & get_dir(src,target))
				partner = target
				partner.partner = src
				break

	..()

/obj/machinery/atmospherics/unary/heat_exchanger/process()
	..()
	if(!src.partner)
		return FALSE

	if(!air_master || air_master.current_cycle <= src.update_cycle)
		return FALSE

	src.update_cycle = air_master.current_cycle
	src.partner.update_cycle = air_master.current_cycle

	var/air_heat_capacity = HEAT_CAPACITY(src.air_contents)
	var/other_air_heat_capacity = HEAT_CAPACITY(src.partner.air_contents)
	var/combined_heat_capacity = other_air_heat_capacity + air_heat_capacity

	var/old_temperature = src.air_contents.temperature
	var/other_old_temperature = src.partner.air_contents.temperature

	if(combined_heat_capacity > 0)
		var/combined_energy = src.partner.air_contents.temperature*other_air_heat_capacity + air_heat_capacity*src.air_contents.temperature

		var/new_temperature = combined_energy/combined_heat_capacity
		src.air_contents.temperature = new_temperature
		src.partner.air_contents.temperature = new_temperature

	if(src.network)
		if(abs(old_temperature - src.air_contents.temperature) > 1 KELVIN)
			network.update = TRUE

	if(src.partner.network)
		if(abs(other_old_temperature - src.partner.air_contents.temperature) > 1 KELVIN)
			partner.network.update = TRUE

	return TRUE

/obj/machinery/atmospherics/unary/heat_exchanger/disposing()
	src.partner?.partner = null
	src.partner = null

	..()
