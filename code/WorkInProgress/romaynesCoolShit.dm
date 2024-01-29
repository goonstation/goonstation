
/obj/item/devbutton
	name = "Romayne's Coding Button"
	desc = "What's it do? Who the fuck knows? Do you want to find out?"
	icon = 'icons/obj/items/bell.dmi'
	icon_state = "bell_kitchen"
	var/obj/item/tank/imcoder/test_tank = new /obj/item/tank/imcoder()
	var/obj/item/tank/imcoder/old/old_tank = new /obj/item/tank/imcoder/old()

/obj/item/devbutton/attack_self(mob/user)
	. = ..()
	playsound(src, 'sound/effects/bell_ring.ogg', 30, FALSE)
	// Code fuckery goes here
	src.explosion_data()

/// Used to get the data for a csv file of explosion ranges since thats cool.
/obj/item/devbutton/proc/explosion_data(var/use_old=FALSE)

	// min_ / max_ : lowest / highest temp of a gas
	// step_ : increment of temperature per iteration
	// oxy: oxygen | tox: plasma
	// temp: temperature, NOT temporary

	var/min_oxy = 100
	var/max_oxy = 300
	var/step_oxy = 1

	var/min_tox = 500
	var/max_tox = 2500
	var/step_tox = 1

	var/step_total = (1 + ceil( (max_oxy - min_oxy) / step_oxy )) * (1 + ceil( (max_tox - min_tox) / step_tox ))
	var/oxy_temp = min_oxy
	var/tox_temp = min_tox

	var/list/bomb_data = new/list(step_total,3)
	var/list_iter = 1
	var/fname = "testing_[min_oxy]_[max_oxy]_[step_oxy]_[min_tox]_[max_tox]_[step_tox].csv"
	var/fpath = "data/[fname]"

	while(oxy_temp <= max_oxy)
		while(tox_temp <= max_tox)
			bomb_data[list_iter] = src.test_bomb(oxy_temp, tox_temp, use_old)
			list_iter += 1
			tox_temp += step_tox
		tox_temp = min_tox
		oxy_temp += step_oxy

	// Writes the output as a CSV
	var/descriptors = list("oxygen", "plasma", "power")
	rustg_file_write("[jointext(descriptors,",")]\n[jointext(bomb_data,"\n")]",fpath)

#define PRESSURE_DELTA 506.625 // half the maximum fill pressure of a tank (5atm)
#define HANDHELD_TANK_VOLUME 70 // Litres in a handheld tank
/// Used to test a bomb safely and get the resultant explosion range
/obj/item/devbutton/proc/test_bomb(var/oxy_temp, var/tox_temp, var/use_old = FALSE)
	var/obj/item/tank/imcoder/use_tank = null
	if (!use_old)
		use_tank = src.test_tank
	else
		use_tank = src.old_tank

	var/range = -1

	var/datum/gas_mixture/air_contents = use_tank.air_contents

	var/mols_oxy = PRESSURE_DELTA * HANDHELD_TANK_VOLUME / (oxy_temp * R_IDEAL_GAS_EQUATION)
	var/mols_tox = PRESSURE_DELTA * HANDHELD_TANK_VOLUME / (tox_temp * R_IDEAL_GAS_EQUATION)

	var/oxy_heat_capacity = mols_oxy * SPECIFIC_HEAT_O2
	var/tox_heat_capacity = mols_tox * SPECIFIC_HEAT_PLASMA

	air_contents.oxygen = mols_oxy
	air_contents.toxins = mols_tox
	air_contents.temperature = (oxy_temp*oxy_heat_capacity + tox_temp*tox_heat_capacity) / (oxy_heat_capacity + tox_heat_capacity)

	var/ticks_limit = 20
	while (range == -1 && ticks_limit > 0)
		range = use_tank.process()
		ticks_limit -= 1

	use_tank.restore_original()

	range = clamp(range,0,12)

	return "[oxy_temp],[tox_temp],[range]"

#undef PRESSURE_DELTA
#undef HANDHELD_TANK_VOLUME
/// Used to create tanks which react and explode at different speeds to test reaction speed shenanagains
/obj/item/devbutton/proc/mult_test(mob/user)

	var/obj/item/tank/imcoder/tank1 = new /obj/item/tank/imcoder()
	var/obj/item/tank/imcoder/tank2 = new /obj/item/tank/imcoder()
	var/obj/item/tank/imcoder/tank3 = new /obj/item/tank/imcoder()

	tank1.creator = user
	tank2.creator = user
	tank3.creator = user

	tank1.air_contents.toxins = 3 MOLES
	tank1.air_contents.oxygen = 24 MOLES
	tank1.air_contents.temperature = 500 KELVIN
	tank1.name = "Mult = 1"

	tank2.air_contents.toxins = 3 MOLES
	tank2.air_contents.oxygen = 24 MOLES
	tank2.air_contents.temperature = 500 KELVIN
	tank2.air_contents.test_mult = 2
	tank2.name = "Mult = 2"

	tank3.air_contents.toxins = 3 MOLES
	tank3.air_contents.oxygen = 24 MOLES
	tank3.air_contents.temperature = 500 KELVIN
	tank3.air_contents.test_mult = 0.5
	tank3.name = "Mult = 0.5"

	tank1.loc = user.loc
	tank2.loc = user.loc
	tank3.loc = user.loc

/// For mapping purposes
/obj/machinery/portable_atmospherics/canister/custom
	var/weight_oxygen = 0
	var/weight_oxygen_b = 0
	var/weight_co2 = 0
	var/weight_plasma = 0
	var/weight_fart = 0
	var/weight_n2 = 0
	var/weight_n20 = 0
	var/weight_fallout = 0
	var/gas_temperature = 273 KELVIN

#define MOLES_TO_FILL_PCT(pct) (src.maximum_pressure*filled * (pct))*air_contents.volume/(R_IDEAL_GAS_EQUATION*air_contents.temperature)

/obj/machinery/portable_atmospherics/canister/custom/New()
	..()
	if (!src.isempty)
		src.air_contents.allowed_to_react = src.do_reacts
		src.air_contents.temperature = src.gas_temperature
		var/sum_weight = src.weight_oxygen + src.weight_oxygen_b + src.weight_co2 + src.weight_plasma + src.weight_fart + src.weight_n2 + src.weight_n20 + src.weight_fallout
		src.air_contents.oxygen = MOLES_TO_FILL_PCT(src.weight_oxygen/sum_weight)
		src.air_contents.oxygen_agent_b = MOLES_TO_FILL_PCT(src.weight_oxygen_b/sum_weight)
		src.air_contents.carbon_dioxide = MOLES_TO_FILL_PCT(src.weight_co2/sum_weight)
		src.air_contents.toxins = MOLES_TO_FILL_PCT(src.weight_plasma/sum_weight)
		src.air_contents.farts = MOLES_TO_FILL_PCT(src.weight_fart/sum_weight)
		src.air_contents.nitrogen = MOLES_TO_FILL_PCT(src.weight_n2/sum_weight)
		src.air_contents.nitrous_oxide = MOLES_TO_FILL_PCT(src.weight_n20/sum_weight)
		src.air_contents.radgas = MOLES_TO_FILL_PCT(src.weight_fallout/sum_weight)
	src.UpdateIcon()
	return 1

#undef MOLES_TO_FILL_PCT

/obj/item/tank_copier
	name = "Machine Copier"
	icon = 'icons/misc/mechanicsExpansion.dmi'
	icon_state = "comp_pressure"
	var/base_desc = "A machine made to copy specific objects. This one is currently not set to copy anything."
	anchored = 1
	var/copy_offset_x = 0
	var/copy_offset_y = 0

	var/obj/machinery/portable_atmospherics/to_copy = null

	New()
		. = ..()
		src.do_copy()
		if (!to_copy)
			desc = base_desc + " Its copy programme is set to copy the first machine at (X:[src.x + src.copy_offset_x], Y:[src.y + src.copy_offset_y]). Fascinating."

	proc/do_copy()
		if (!to_copy)
			var/turf/T = locate(src.x + src.copy_offset_x, src.y + src.copy_offset_y,src.z)
			for (var/obj/machinery/portable_atmospherics/P in T)
				src.to_copy = P
				break
			if (!src.to_copy)
				return
			desc = base_desc + " Its copy programme is set to copy [src.to_copy.name]. Fascinating."
		if (checkTurfPassable(locate(src.x, src.y, src.z)))
			var/obj/machinery/portable_atmospherics/new_thing = semi_deep_copy(src.to_copy)
			new_thing.set_loc(src.loc)

	Crossed()
		. = ..()
		src.do_copy()

	Uncrossed()
		. = ..()
		src.do_copy()

/area/supply/test_point
	name = "atmos testing point"
	requires_power = 0
	/// Maximum reactions to test on an atmos-containing object
	var/max_test_reacts = 1000
	var/output_x = 0
	var/output_y = 0

	Entered(var/atom/movable/AM)
		..()
		if(isobj(AM) && hasvar(AM, "air_contents"))
			var/obj/O = AM

			if (istype(O,/obj/item/tank))
				src.test_atmos_thing(O)
			else if (istype(O,/obj/machinery/portable_atmospherics/canister))
				src.test_atmos_thing(O)

			if(O)
				qdel(O)

	proc/get_data(var/obj/item/tank/T = null, var/obj/machinery/portable_atmospherics/canister/C = null)
		// PV = NRT
		// Pressure, Delta Pressure, Volume, Mols of gas (total, each), Temperature
		var/datum/gas_mixture/M
		var/delta_P = "N/A"
		if (T)
			M = T.air_contents
			delta_P = MIXTURE_PRESSURE(M) - T.previous_pressure
		else if (C)
			M = C.air_contents
			delta_P = MIXTURE_PRESSURE(M) - C.previous_pressure

		var/total_moles = M.oxygen + \
						  M.oxygen_agent_b + \
						  M.carbon_dioxide + \
						  M.toxins + \
						  M.farts + \
						  M.nitrogen + \
						  M.nitrous_oxide + \
						  M.radgas
		return "Current Pressure: [MIXTURE_PRESSURE(M)]kPa</br>\
				Delta Pressure: [delta_P]kPa</br>\
				Volume: [M.volume]</br>\
				Temperature: [M.temperature]</br>\
				Total Moles of gas: [total_moles] moles</br>\
				Oxygen: [M.oxygen] moles</br>\
				Agent B: [M.oxygen_agent_b] moles</br>\
				CO2: [M.carbon_dioxide] moles</br>\
				Plasma: [M.toxins] moles</br>\
				Farts: [M.farts] moles</br>\
				N2: [M.nitrogen] moles</br>\
				N2O: [M.nitrous_oxide] moles</br>\
				Fallout: [M.radgas] moles</br></br>"

	proc/test_atmos_thing(var/obj/item/tank/T=null, var/obj/machinery/portable_atmospherics/canister/C=null)
		if(!T && !C)
			return
		if (T)
			T.do_reacts = TRUE
			T.air_contents.allowed_to_react = TRUE
		if (C)
			C.do_reacts = TRUE
			C.air_contents.allowed_to_react = TRUE

		/// How many reacts we did so far
		var/test_reacts = 0
		/// String data of test log
		var/test_log = ""
		while (test_reacts < src.max_test_reacts)
			test_log += "Reaction #[test_reacts]</br>"
			if(T && T.air_contents)
				test_log += src.get_data(T)
				T.process()
			else if (C && C.air_contents && !C.rupturing)
				test_log += src.get_data(C)
				C.process()
			else
				break
			test_reacts += 1
		var/obj/item/paper/data_log = new /obj/item/paper()
		data_log.set_loc(locate(src.output_x, src.output_y, src.z))
		data_log.info = test_log
		data_log.update_icon()

/obj/item/tank/imcoder
	name = "gas tank"
	icon_state = "empty"
	var/mob/creator = null
	var/diagnostic_maptext
	var/test_mult = 1

/// Restore the original state of the tank. Pretty much all vars just get set to 0 so its easier than qdel and re-init
/obj/item/tank/imcoder/proc/restore_original()
	src.integrity = 3
	src.air_contents.carbon_dioxide = 0
	src.air_contents.farts = 0
	src.air_contents.toxins = 0
	src.air_contents.oxygen_agent_b = 0
	src.air_contents.oxygen = 0
	src.air_contents.group_multiplier = 1
	src.air_contents.nitrogen = 0
	src.air_contents.nitrous_oxide = 0
	src.air_contents.temperature = 0 KELVIN
	src.air_contents.radgas = 0
	src.air_contents.fuel_burnt = 0

/obj/item/tank/imcoder/process()
	//Allow for reactions
	if (!src.do_reacts)
		return
	if (air_contents)
		src.previous_pressure = MIXTURE_PRESSURE(air_contents)
		air_contents.react()
	return src.check_status()

/obj/item/tank/imcoder/check_status()
	// Handle exploding, leaking, and rupturing of the tank
	// Copied from tank proc, edited to return range values or 0 for duds
	if(!air_contents)
		return 0

	var/pressure = MIXTURE_PRESSURE(air_contents)
	if(pressure > TANK_FRAGMENT_PRESSURE)
		var/react_compensation = ((TANK_FRAGMENT_PRESSURE - src.previous_pressure) / (pressure - src.previous_pressure))
		air_contents.react()
		air_contents.react()
		air_contents.react()
		air_contents.react(mult=react_compensation)
		var/range = (MIXTURE_PRESSURE(air_contents) - TANK_FRAGMENT_PRESSURE) / TANK_FRAGMENT_SCALE
		return range

	else if(pressure > TANK_RUPTURE_PRESSURE)
		if(integrity <= 0)
			return 0
		else
			integrity--

	else if(pressure > TANK_LEAK_PRESSURE)
		if(integrity <= 0)
			air_contents.remove_ratio(0.25)
		else
			integrity--

	else if(integrity < 3)
		integrity++

	return -1

////////////////////////////////////////////////////////////

/obj/item/tank/imcoder/old
	name = "gas tank"

/obj/item/tank/imcoder/old/check_status()
	// Handle exploding, leaking, and rupturing of the tank
	// Copied from tank proc, edited to return range values or 0 for duds
	if(!air_contents)
		return 0

	var/pressure = MIXTURE_PRESSURE(air_contents)
	if(pressure > TANK_FRAGMENT_PRESSURE)
		air_contents.react()
		air_contents.react()
		air_contents.react()
		var/range = (MIXTURE_PRESSURE(air_contents) - TANK_FRAGMENT_PRESSURE) / TANK_FRAGMENT_SCALE
		return range

	else if(pressure > TANK_RUPTURE_PRESSURE)
		if(integrity <= 0)
			return 0
		else
			integrity--

	else if(pressure > TANK_LEAK_PRESSURE)
		if(integrity <= 0)
			air_contents.remove_ratio(0.25)
		else
			integrity--

	else if(integrity < 3)
		integrity++

	return -1
