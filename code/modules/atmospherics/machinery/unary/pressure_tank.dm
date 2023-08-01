//TODO: Repath to /unary
/obj/machinery/atmospherics/pipe/tank
	icon = 'icons/obj/atmospherics/tanks/grey_pipe_tank.dmi'
	icon_state = "intact"
	name = "Pressure Tank"
	desc = "A large vessel containing pressurized gas."
	volume = 1620 //in liters, 0.9 meters by 0.9 meters by 2 meters
	plane = PLANE_DEFAULT
	density = TRUE
	var/obj/machinery/atmospherics/node1

/obj/machinery/atmospherics/pipe/tank/New()
	..()
	initialize_directions = dir

/obj/machinery/atmospherics/pipe/tank/process()
	..()
	if(!node1)
		parent.mingle_with_turf(loc, 200)

/obj/machinery/atmospherics/pipe/tank/disposing()
	node1?.disconnect(src)
	parent = null
	..()

/obj/machinery/atmospherics/pipe/tank/pipeline_expansion()
	return list(node1)

/obj/machinery/atmospherics/pipe/tank/update_icon()
	if(node1)
		icon_state = "intact"

		dir = get_dir(src, node1)

	else
		icon_state = "exposed"

/obj/machinery/atmospherics/pipe/tank/initialize()
	var/connect_direction = dir

	for(var/obj/machinery/atmospherics/target in get_step(src,connect_direction))
		if(target.initialize_directions & get_dir(target,src))
			node1 = target
			break

	UpdateIcon()

/obj/machinery/atmospherics/pipe/tank/disconnect(obj/machinery/atmospherics/reference)
	if(reference == node1)
		if(istype(node1, /obj/machinery/atmospherics/pipe))
			if (parent)
				parent.dispose()
			parent = null
		node1 = null

	UpdateIcon()


/obj/machinery/atmospherics/pipe/tank/carbon_dioxide
	name = "Pressure Tank (Carbon Dioxide)"

/obj/machinery/atmospherics/pipe/tank/carbon_dioxide/New()
	..()
	air_temporary = new /datum/gas_mixture
	air_temporary.volume = volume
	air_temporary.temperature = T20C

	air_temporary.carbon_dioxide = (50*ONE_ATMOSPHERE)*(air_temporary.volume)/(R_IDEAL_GAS_EQUATION*air_temporary.temperature)

/obj/machinery/atmospherics/pipe/tank/toxins
	icon = 'icons/obj/atmospherics/tanks/orange_pipe_tank.dmi'
	name = "Pressure Tank (Plasma)"

/obj/machinery/atmospherics/pipe/tank/toxins/New()
	..()
	air_temporary = new /datum/gas_mixture
	air_temporary.volume = volume
	air_temporary.temperature = T20C

	air_temporary.toxins = (50*ONE_ATMOSPHERE)*(air_temporary.volume)/(R_IDEAL_GAS_EQUATION*air_temporary.temperature)

/obj/machinery/atmospherics/pipe/tank/oxygen_agent_b
	icon = 'icons/obj/atmospherics/tanks/red_orange_pipe_tank.dmi'
	name = "Pressure Tank (Oxygen + Plasma)"

/obj/machinery/atmospherics/pipe/tank/oxygen_agent_b/New()
	..()
	air_temporary = new /datum/gas_mixture
	air_temporary.volume = volume
	air_temporary.temperature = T0C

	air_temporary.oxygen_agent_b = (50*ONE_ATMOSPHERE)*(air_temporary.volume)/(R_IDEAL_GAS_EQUATION*air_temporary.temperature)

/obj/machinery/atmospherics/pipe/tank/oxygen
	icon = 'icons/obj/atmospherics/tanks/blue_pipe_tank.dmi'
	name = "Pressure Tank (Oxygen)"

/obj/machinery/atmospherics/pipe/tank/oxygen/New()
	..()
	air_temporary = new /datum/gas_mixture
	air_temporary.volume = volume
	air_temporary.temperature = T20C

	air_temporary.oxygen = (50*ONE_ATMOSPHERE)*(air_temporary.volume)/(R_IDEAL_GAS_EQUATION*air_temporary.temperature)

/obj/machinery/atmospherics/pipe/tank/nitrogen
	icon = 'icons/obj/atmospherics/tanks/red_pipe_tank.dmi'
	name = "Pressure Tank (Nitrogen)"

/obj/machinery/atmospherics/pipe/tank/nitrogen/New()
	..()
	air_temporary = new /datum/gas_mixture
	air_temporary.volume = volume
	air_temporary.temperature = T20C

	air_temporary.nitrogen = (50*ONE_ATMOSPHERE)*(air_temporary.volume)/(R_IDEAL_GAS_EQUATION*air_temporary.temperature)

/obj/machinery/atmospherics/pipe/tank/sleeping_agent
	icon = 'icons/obj/atmospherics/tanks/red_white_pipe_tank.dmi'
	name = "Pressure Tank (N2O)"

/obj/machinery/atmospherics/pipe/tank/sleeping_agent/New()
	..()
	air_temporary = new /datum/gas_mixture
	air_temporary.volume = volume
	air_temporary.temperature = T20C

	air_temporary.nitrous_oxide = (50*ONE_ATMOSPHERE)*(air_temporary.volume)/(R_IDEAL_GAS_EQUATION*air_temporary.temperature)

/obj/machinery/atmospherics/pipe/tank/air
	icon = 'icons/obj/atmospherics/tanks/white_pipe_tank.dmi'
	name = "Pressure Tank (Air)"

/obj/machinery/atmospherics/pipe/tank/air/New()
	..()
	air_temporary = new /datum/gas_mixture
	air_temporary.volume = volume
	air_temporary.temperature = T20C

	air_temporary.oxygen = (50*ONE_ATMOSPHERE*O2STANDARD)*(air_temporary.volume)/(R_IDEAL_GAS_EQUATION*air_temporary.temperature)
	air_temporary.nitrogen = (50*ONE_ATMOSPHERE*N2STANDARD)*(air_temporary.volume)/(R_IDEAL_GAS_EQUATION*air_temporary.temperature)

// Experiment for improving the usefulness of air hookups. They have twice the capacity of portable
// canisters and contain 4 times the volume of their default air mixture (Convair880).
/obj/machinery/atmospherics/pipe/tank/air_repressurization
	icon = 'icons/obj/atmospherics/tanks/whitered_pipe_tank.dmi'
	name = "High-Pressure Tank (Air)"
	desc = "Large vessel containing a pressurized air mixture for emergency purposes."
	volume = 2000

/obj/machinery/atmospherics/pipe/tank/air_repressurization/New()
	..()
	air_temporary = new /datum/gas_mixture
	air_temporary.volume = volume
	air_temporary.temperature = T20C

	air_temporary.oxygen = (180*ONE_ATMOSPHERE*O2STANDARD)*(air_temporary.volume)/(R_IDEAL_GAS_EQUATION*air_temporary.temperature)
	air_temporary.nitrogen = (180*ONE_ATMOSPHERE*N2STANDARD)*(air_temporary.volume)/(R_IDEAL_GAS_EQUATION*air_temporary.temperature)

