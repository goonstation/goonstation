/obj/machinery/atmospherics/unary/tank
	icon = 'icons/obj/atmospherics/tanks/grey_pipe_tank.dmi'
	icon_state = "tank-map"
	name = "Pressure Tank"
	desc = "A large vessel containing pressurized gas."
	density = TRUE
	var/volume = 1620 //in liters, 0.9 meters by 0.9 meters by 2 meters

/obj/machinery/atmospherics/unary/tank/New()
	..()
	src.AddComponent(/datum/component/obj_projectile_damage)
	src.air_contents.volume = src.volume
	src.air_contents.temperature = T20C

/obj/machinery/atmospherics/unary/tank/update_icon()
	SET_PIPE_UNDERLAY(src.node, src.dir, "long", issimplepipe(src.node) ?  src.node.color : null, FALSE)


/obj/machinery/atmospherics/unary/tank/attackby(obj/item/I, mob/user) //let's just make these breakable for now
	if (I.force)
		src.visible_message(SPAN_ALERT("[user] hits \the [src] with \a [I]!"))
		user.lastattacked = get_weakref(src)
		attack_particle(user,src)
		hit_twitch(src)
		playsound(src.loc, 'sound/impact_sounds/Metal_Hit_Light_1.ogg', 50, 1)
		logTheThing(LOG_STATION, user, "attacks [src] [log_atmos(src)] with [I] at [log_loc(src)].")
		src.changeHealth(-I.force)
	..()

/obj/machinery/atmospherics/unary/tank/onDestroy()
	var/atom/location = src.loc
	location.assume_air(air_contents)
	air_contents = null
	src.gib(location)
	..()

/obj/machinery/atmospherics/unary/tank/carbon_dioxide
	icon = 'icons/obj/atmospherics/tanks/black_pipe_tank.dmi'
	name = "Pressure Tank (Carbon Dioxide)"

/obj/machinery/atmospherics/unary/tank/carbon_dioxide/New()
	..()
	src.air_contents.carbon_dioxide = (50*ONE_ATMOSPHERE)*(src.air_contents.volume)/(R_IDEAL_GAS_EQUATION*src.air_contents.temperature)

/obj/machinery/atmospherics/unary/tank/toxins
	icon = 'icons/obj/atmospherics/tanks/orange_pipe_tank.dmi'
	name = "Pressure Tank (Plasma)"

/obj/machinery/atmospherics/unary/tank/toxins/New()
	..()
	src.air_contents.toxins = (50*ONE_ATMOSPHERE)*(src.air_contents.volume)/(R_IDEAL_GAS_EQUATION*src.air_contents.temperature)

/obj/machinery/atmospherics/unary/tank/oxygen_agent_b
	icon = 'icons/obj/atmospherics/tanks/red_orange_pipe_tank.dmi'
	name = "Pressure Tank (Oxygen + Plasma)"

/obj/machinery/atmospherics/unary/tank/oxygen_agent_b/New()
	..()
	src.air_contents.temperature = T0C
	src.air_contents.oxygen_agent_b = (50*ONE_ATMOSPHERE)*(src.air_contents.volume)/(R_IDEAL_GAS_EQUATION*src.air_contents.temperature)

/obj/machinery/atmospherics/unary/tank/oxygen
	icon = 'icons/obj/atmospherics/tanks/blue_pipe_tank.dmi'
	name = "Pressure Tank (Oxygen)"

/obj/machinery/atmospherics/unary/tank/oxygen/New()
	..()
	src.air_contents.oxygen = (50*ONE_ATMOSPHERE)*(src.air_contents.volume)/(R_IDEAL_GAS_EQUATION*src.air_contents.temperature)

/obj/machinery/atmospherics/unary/tank/nitrogen
	icon = 'icons/obj/atmospherics/tanks/red_pipe_tank.dmi'
	name = "Pressure Tank (Nitrogen)"

/obj/machinery/atmospherics/unary/tank/nitrogen/New()
	..()
	src.air_contents.nitrogen = (50*ONE_ATMOSPHERE)*(src.air_contents.volume)/(R_IDEAL_GAS_EQUATION*src.air_contents.temperature)

/obj/machinery/atmospherics/unary/tank/sleeping_agent
	icon = 'icons/obj/atmospherics/tanks/red_white_pipe_tank.dmi'
	name = "Pressure Tank (N2O)"

/obj/machinery/atmospherics/unary/tank/sleeping_agent/New()
	..()
	src.air_contents.nitrous_oxide = (50*ONE_ATMOSPHERE)*(src.air_contents.volume)/(R_IDEAL_GAS_EQUATION*src.air_contents.temperature)

/obj/machinery/atmospherics/unary/tank/air
	icon = 'icons/obj/atmospherics/tanks/white_pipe_tank.dmi'
	name = "Pressure Tank (Air)"

/obj/machinery/atmospherics/unary/tank/air/New()
	..()
	src.air_contents.oxygen = (50*ONE_ATMOSPHERE*O2STANDARD)*(src.air_contents.volume)/(R_IDEAL_GAS_EQUATION*src.air_contents.temperature)
	src.air_contents.nitrogen = (50*ONE_ATMOSPHERE*N2STANDARD)*(src.air_contents.volume)/(R_IDEAL_GAS_EQUATION*src.air_contents.temperature)

// Experiment for improving the usefulness of air hookups. They have twice the capacity of portable
// canisters and contain 4 times the volume of their default air mixture (Convair880).
/obj/machinery/atmospherics/unary/tank/air_repressurization
	icon = 'icons/obj/atmospherics/tanks/white_red_pipe_tank.dmi'
	name = "High-Pressure Tank (Air)"
	desc = "Large vessel containing a pressurized air mixture for emergency purposes."
	volume = 2000

/obj/machinery/atmospherics/unary/tank/air_repressurization/New()
	..()
	src.air_contents.oxygen = (180*ONE_ATMOSPHERE*O2STANDARD)*(src.air_contents.volume)/(R_IDEAL_GAS_EQUATION*src.air_contents.temperature)
	src.air_contents.nitrogen = (180*ONE_ATMOSPHERE*N2STANDARD)*(src.air_contents.volume)/(R_IDEAL_GAS_EQUATION*src.air_contents.temperature)


/obj/machinery/atmospherics/unary/tank/radgas
	icon = 'icons/obj/atmospherics/tanks/green_pipe_tank.dmi'
	name = "Pressure Tank (Nuclear Exhaust)"

/obj/machinery/atmospherics/unary/tank/radgas/New()
	..()
	src.air_contents.radgas = (50*ONE_ATMOSPHERE)*(src.air_contents.volume)/(R_IDEAL_GAS_EQUATION*src.air_contents.temperature)
