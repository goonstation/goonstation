#ifdef ENABLE_ARTEMIS

/////////////////////TANK/////////////////////
/obj/machinery/atmospherics/unary/ion_drive/plasma_tank
		name = "plasma tank"
		desc = "the engines plasma tank"
		icon = 'icons/misc/artemis/artemis_engine.dmi'
		icon_state = "engine_tank"
		density = 1

		var/max_pressure =150 * ONE_ATMOSPHERE
		var/on = FALSE
		var/volume=1000
		var/stars_id = "artemis"

		var/datum/gas_mixture/stored_fuel = null

/obj/machinery/atmospherics/unary/ion_drive/plasma_tank/New()
		src.dir=NORTH
		src.initialize_directions=NORTH
		..()
		src.stored_fuel= new /datum/gas_mixture
		src.stored_fuel.volume = src.volume
		src.stored_fuel.temperature = T20C
		src.stored_fuel.toxins = (src.max_pressure / 2) * src.volume / (T20C * R_IDEAL_GAS_EQUATION)



/// Checks for gas in node1 and there is room left in the tank. If yes process it by storing the plasma and deleting the rest
/obj/machinery/atmospherics/unary/ion_drive/plasma_tank/process()
		..()

		if(!src.on)
				return FALSE

		var/tank_pressure = MIXTURE_PRESSURE(src.stored_fuel)
		if(tank_pressure >= src.max_pressure)
				return TRUE

		var/pressure_delta = src.max_pressure - tank_pressure
		var/transfer_moles

		if(src.air_contents.temperature > 0)
				transfer_moles = pressure_delta*src.stored_fuel.volume/(src.air_contents.temperature * R_IDEAL_GAS_EQUATION)

		if(transfer_moles > 0)
				var/datum/gas_mixture/removed = src.air_contents.remove(transfer_moles)

				if(removed.toxins>0)
						var/datum/gas_mixture/filtered_out = new /datum/gas_mixture

						if(removed.temperature)
								filtered_out.temperature = removed.temperature

						filtered_out.toxins=removed.toxins
						removed.toxins = 0
						src.stored_fuel.merge(filtered_out)
				qdel(removed)
				src.network?.update = TRUE

		return TRUE



/////////////////////DRIVE/////////////////////
/obj/machinery/ion_drive/drive
		name = "Ion Drive"
		desc = "the engine"
		icon = 'icons/misc/artemis/artemis_engine.dmi'
		icon_state = "engine_main"
		density = 1

		var/stars_id = "artemis"
		var/on=FALSE
		var/max_pressure = 10 * ONE_ATMOSPHERE
		var/multiplier= null
		var/penalty=0//expressed as a

		var/obj/item/artemis_engine_component/plasma_exciter/drive_exciter
		var/obj/item/artemis_engine_component/casing/drive_casing
		var/obj/item/artemis_engine_component/coil/drive_coil
		var/datum/gas_mixture/fuel_buffer


/obj/machinery/ion_drive/drive/New()
		..()

		src.fuel_buffer = new /datum/gas_mixture
		src.fuel_buffer.volume = 1000
		src.fuel_buffer.temperature = T20C

		src.drive_exciter = new /obj/item/artemis_engine_component/plasma_exciter
		src.drive_exciter.New("plasmastone")

		src.drive_casing = new /obj/item/artemis_engine_component/casing
		src.drive_casing.New()

		src.drive_coil = new /obj/item/artemis_engine_component/coil
		src.drive_coil.New("copper")

		src.multiplier=src.drive_exciter.conversion_rate//come up with something better
/obj/machinery/ion_drive/drive/proc/usefuel(var/throttle)
		if(src.fuel_buffer.toxins<src.drive_exciter.conversion_rate || src.drive_casing.integrity <= 0)
				return FALSE

		src.fuel_buffer.toxins -= src.drive_exciter.conversion_rate

		src.drive_casing.integrity -= src.drive_casing.degredation_rate
		if(src.drive_casing.integrity < 0)
				src.drive_casing.integrity=0
		src.use_power(1000*src.drive_coil.field_strength)

		if(throttle)
				return src.usefuel(FALSE)
		return TRUE
/////////////////////INTERFACE/////////////////////
/obj/machinery/ion_drive/interface
		name = "Ion Drive Interface"
		desc = "the engine interface"
		icon = 'icons/misc/artemis/artemis_engine.dmi'
		icon_state = "engine_out"
		density = 1

		var/throttle
		var/on = FALSE
		var/target_pressure=ONE_ATMOSPHERE
		var/stars_id = "artemis"

		var/obj/machinery/atmospherics/unary/ion_drive/plasma_tank/artemis_tank = null
		var/obj/machinery/ion_drive/drive/artemis_drive = null
		var/obj/artemis/ship = null
/// setup the ion drive interface, look for the ship, the tank to the east and the drive to the west
/obj/machinery/ion_drive/interface/New()
		..()
		SPAWN(1 SECONDS)
				for(var/obj/artemis/S in world)
						if(S.stars_id == src.stars_id)
								src.ship = S
								src.ship.engines.drive = src
								break
				var/turf/T = get_step(src,WEST)
				src.artemis_tank = locate(/obj/machinery/atmospherics/unary/ion_drive/plasma_tank) in T
				T = get_step(src,EAST)

				src.artemis_drive = locate(/obj/machinery/ion_drive/drive) in T

				if(!src.artemis_tank||!src.artemis_tank||!src.ship)
						src.status |= BROKEN
				#if ENABLE_ENGINE
				else
						src.ship.accel *= src.artemis_drive.multiplier
				#endif
				var/area/A = get_area(src)
				for(var/obj/machinery/shuttle/engine/propulsion/P in A)
						src.ship.engines.add_engine(P)
/obj/machinery/ion_drive/interface/process()
		. = ..()
		if(!src.on)
				return FALSE
		src.transfer_fuel(src.artemis_tank.stored_fuel,src.artemis_drive.fuel_buffer)


/obj/machinery/ion_drive/interface/proc/process_move()
		if(!src.on)
				return FALSE
		if(!src.artemis_drive.usefuel(src.ship.full_throttle))
				src.on=FALSE;



/obj/machinery/ion_drive/interface/ui_interact(mob/user, datum/tgui/ui)

		ui = tgui_process.try_update_ui(user, src, ui)

		if(!ui)
				ui = new(user, src, "ArtemisEngine")
				ui.open()

/obj/machinery/ion_drive/interface/ui_data(mob/user)
		. = list(
			"fuel_tank" = MIXTURE_PRESSURE(src.artemis_tank.stored_fuel),
			"fuel_buffer" = MIXTURE_PRESSURE(src.artemis_drive.fuel_buffer),
			"target_fuel"=src.target_pressure,
			"engine_on"=src.on,
			"tank_on"=src.artemis_tank.on,
			"exciter_stat" = src.artemis_drive.drive_exciter.conversion_rate,
			"casing_integrity" = src.artemis_drive.drive_casing.integrity,
			"casing_full_integrity" = src.artemis_drive.drive_casing.full_integrity,
			"casing_rate" = src.artemis_drive.drive_casing.degredation_rate,
			"coil_strength" = src.artemis_drive.drive_coil.field_strength,
		)
/obj/machinery/ion_drive/interface/ui_static_data(mob/user)
	. = list(
			"min_pressure" = 0,
			"max_target" = 5 * ONE_ATMOSPHERE,
			"max_tank_pressure" = src.artemis_tank.max_pressure,
			"max_buffer_pressure" = src.artemis_drive.max_pressure,
		)
/obj/machinery/ion_drive/interface/ui_act(action, params)
		. = ..()
		if (.)
				return
		switch(action)

				if("toggle-power")
						if(src.artemis_drive.fuel_buffer.temperature>0)
								src.on = !src.on
								src.artemis_drive.on = !src.artemis_drive.on
								. = TRUE
						else
								. = FALSE

				if("toggle-tank")
						src.artemis_tank.on = !src.artemis_tank.on
						. = TRUE

				if("adjust-flowrate")
						var/new_target_pressure = params["target_fuel"]
						if(isnum(new_target_pressure))
								src.target_pressure = clamp(new_target_pressure, 0, 10*ONE_ATMOSPHERE)
								. =TRUE

/// Transfer fuel from fuel tank to the drives fuel buffer
/obj/machinery/ion_drive/interface/proc/transfer_fuel(datum/gas_mixture/source,datum/gas_mixture/destination)


		var/destination_pressure = MIXTURE_PRESSURE(destination)
		if(destination_pressure>=src.target_pressure)
				return TRUE

		var/pressure_delta = src.target_pressure-destination_pressure
		var/transfer_moles

		if(src.artemis_tank.stored_fuel.temperature>0)
				transfer_moles = pressure_delta * destination.volume / (source.temperature * R_IDEAL_GAS_EQUATION)
		if(transfer_moles>0)
				var/datum/gas_mixture/removed = source.remove(transfer_moles)
				destination.merge(removed)

		return TRUE

/obj/machinery/ion_drive/interface/proc/getMultiplier()
		return src.artemis_drive.multiplier
#endif
