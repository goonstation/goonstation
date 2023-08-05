#if ENABLE_ARTEMIS
/obj/machinery/shuttle/engine/propulsion/ion_drive
		name = "Ion Drive"
		desc = "the engine"
		icon = 'icons/misc/artemis/artemis_engine.dmi'
		icon_state = "engine_main"

/obj/machinery/atmospherics/binary/ion_drive/plas_tank
		name = "plasma tank"
		desc = "the engines plasma tank"
		icon = 'icons/misc/artemis/artemis_engine.dmi'
		icon_state = "engine_tank"
		var/on=FALSE
		var/datum/gas_mixture/stored_fuel = null
		var/max_pressure =150 * ONE_ATMOSPHERE
/obj/machinery/atmospherics/binary/ion_drive/plas_tank/New()
		..()
		src.stored_fuel= new /datum/gas_mixture

		src.stored_fuel.volume = 0
		src.stored_fuel.temperature = T20C
///filters plasma from input, outputs rejected gas, removes fuel
/obj/machinery/atmospherics/binary/ion_drive/plas_tank/process()
		..()
		var/tank_pressure=MIXTURE_PRESSURE(src.stored_fuel)
		if(tank_pressure>=src.max_pressure)
				return TRUE
		var/pressure_delta = tank_pressure - src.max_pressure
		var/transfer_moles
		if(src.air1.temperature > 0)
				transfer_moles = pressure_delta*src.stored_fuel.volume/(src.air1.temperature * R_IDEAL_GAS_EQUATION)
		if(transfer_moles > 0)
				var/datum/gas_mixture/removed = src.air1.remove(transfer_moles)
				if(src.air1.toxins>0)
						var/datum/gas_mixture/filtered_out = new /datum/gas_mixture
						if(removed.temperature)
								filtered_out.temperature = removed.temperature
						filtered_out.toxins=removed.toxins
						removed.toxins = 0;
						src.stored_fuel.merge(filtered_out)
				src.air2.merge(removed)
		src.network1?.update = TRUE
		src.network2?.update = TRUE
/*
*get_fuel: get a volume of fuel as moles, delete those from tank
*
*input: desired volume
*output: moles to be used
*/
/obj/machinery/atmospherics/binary/ion_drive/plas_tank/get_fuel(volume_wanted)
		//cases to return null on
		if((!src.on)||(src.stored_fuel.volume<=0)||(src.stored_fuel.temperature<=0))
				return null
		if(src.stored_fuel.volume-volume_wanted<0)
				volume_wanted+=src.stored_fuel.volume-volume_wanted
		var/tank_pressure=MIXTURE_PRESSURE(src.stored_fuel)
		var/transfer_moles
		if(src.stored_fuel.temperature > 0)
				transfer_moles = tank_pressure*volume_wanted/(src.stored_fuel.temperature * R_IDEAL_GAS_EQUATION)
		if(transfer_moles>0)
				src.stored_fuel.toxins-=transfer_moles;
				return transfer_moles


#endif
