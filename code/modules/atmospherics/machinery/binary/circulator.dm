#define LEFT 1
#define RIGHT 2

/obj/machinery/atmospherics/binary/circulator
	name = "circulator/heat exchanger"
	desc = "A gas circulator pump and heat exchanger."
	icon = 'icons/obj/atmospherics/pipes.dmi'
	icon_state = "circ1-off"
	anchored = ANCHORED
	density = TRUE

	var/side = LEFT
	var/last_pressure_delta = 0

/obj/machinery/atmospherics/binary/circulator/proc/return_transfer_air()
	var/output_starting_pressure = MIXTURE_PRESSURE(air2)
	var/input_starting_pressure = MIXTURE_PRESSURE(air1)

	//Calculate necessary moles to transfer using PV = nRT
	ASSERT(air1.temperature >= 0)
	if(TOTAL_MOLES(air1))
		var/pressure_delta = (input_starting_pressure - output_starting_pressure)/2

		var/transfer_moles = pressure_delta*air2.volume/(air1.temperature * R_IDEAL_GAS_EQUATION)

		last_pressure_delta = pressure_delta

		//Actually transfer the gas
		var/datum/gas_mixture/removed = air1.remove(transfer_moles)

		network1?.update = TRUE
		network2?.update = TRUE

		return removed

	else
		last_pressure_delta = 0

/obj/machinery/atmospherics/binary/circulator/process()
	..()
	UpdateIcon()

/obj/machinery/atmospherics/binary/circulator/update_icon()
	if(status & (BROKEN|NOPOWER))
		icon_state = "circ[side]-p"
	else if(last_pressure_delta > 0)
		if(last_pressure_delta > ONE_ATMOSPHERE * 10000)
			icon_state = "circ[side]-fast"
		else if(last_pressure_delta > ONE_ATMOSPHERE)
			icon_state = "circ[side]-run"
		else
			icon_state = "circ[side]-slow"
	else
		icon_state = "circ[side]-off"

#undef LEFT
#undef RIGHT
