/obj/machinery/atmospherics/trinary/filter
	name = "Gas filter"
	icon = 'icons/obj/atmospherics/filter.dmi'
	icon_state = "intact_off"
	density = TRUE
	layer = PIPE_MACHINE_LAYER
	plane = PLANE_NOSHADOW_BELOW

	var/on = FALSE
	/// What output pressure we aiming for?
	var/target_pressure = ONE_ATMOSPHERE
	/// ID of the gas you wish to filter
	var/filter_type = "toxins"

/obj/machinery/atmospherics/trinary/filter/update_icon()
	if(src.node1&&src.node2&&src.node3)
		src.icon_state = "intact_[src.on?("on"):("off")]"
	else
		src.icon_state = "exposed_off"

		src.on = FALSE

/obj/machinery/atmospherics/trinary/filter/process()
	..()
	if(!src.on)
		return FALSE

	var/output_starting_pressure = MIXTURE_PRESSURE(src.air3)

	if(output_starting_pressure >= src.target_pressure)
		//No need to mix if target is already full!
		return TRUE

	//Calculate necessary moles to transfer using PV=nRT

	var/pressure_delta = src.target_pressure - output_starting_pressure
	var/transfer_moles

	if(src.air1.temperature > 0)
		transfer_moles = pressure_delta*src.air3.volume/(src.air1.temperature * R_IDEAL_GAS_EQUATION)

	//Actually transfer the gas
	if(transfer_moles > 0)
		var/datum/gas_mixture/removed = src.air1.remove(transfer_moles)

		var/datum/gas_mixture/filtered_out = new /datum/gas_mixture
		if(removed.temperature)
			filtered_out.temperature = removed.temperature

		switch(filter_type)
			#define _CREATE_FILTER_TYPES(GAS, ...) if(#GAS) {filtered_out.GAS = removed.GAS ; removed.GAS = 0; }
			APPLY_TO_GASES(_CREATE_FILTER_TYPES)
			#undef _CREATE_FILTER_TYPES

		src.air2.merge(filtered_out)
		src.air3.merge(removed)

	src.network1?.update = TRUE
	src.network2?.update = TRUE
	src.network3?.update = TRUE

	return TRUE

