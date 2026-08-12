/*
What are the archived variables for?
	Calculations are done using the archived variables with the results merged into the regular variables.
	This prevents race conditions that arise based on the order of tile processing.
*/

/** The key of atmospherics.
 * 	This datum here is how we represent gas mixtures. Temperature is in Kelvin and volume is in Litres.
 * 	Defines and stores base gases using [APPLY_TO_GASES] and stores trace gases using [datum/gas_mixture/var/list/datum/gas/trace_gases]. */
ABSTRACT_TYPE(/datum/gas_mixture)
/datum/gas_mixture
	/// Bitfield representing gas graphics on our tile.
	var/graphic
	var/tmp/graphic_archived // intentionally NOT using ARCHIVED() because graphic archiving is actually important and shouldn't be turned off
	/// Rough representation of oxygen and plasma used. Actual usage of plasma is currectly divided by 3 for balance.
	var/tmp/fuel_burnt = 0

#define _CREATE_GET_PROCS(GAS, ...) /datum/gas_mixture/proc/##GAS() {}
APPLY_TO_GASES(_CREATE_GET_PROCS)
#undef _CREATE_GET_PROCS

#define _CREATE_SET_PROCS(GAS, ...) /datum/gas_mixture/proc/set_##GAS(value) {}
APPLY_TO_GASES(_CREATE_SET_PROCS)
#undef _CREATE_SET_PROCS

#define _CREATE_CHANGE_PROCS(GAS, ...) /datum/gas_mixture/proc/adjust_##GAS(value) {}
APPLY_TO_GASES(_CREATE_CHANGE_PROCS)
#undef _CREATE_CHANGE_PROCS

/datum/gas_mixture/proc/get_index(index)

/// Returns temperature in Kelvin
/datum/gas_mixture/proc/temperature()

/// Sets the temperature to value
/datum/gas_mixture/proc/set_temperature(value)

/// Changes the temperature by value
/datum/gas_mixture/proc/adjust_temperature(value)

/// Returns the thermal energy
/datum/gas_mixture/proc/thermal_energy()

/// Sets the thermal energy to value
/datum/gas_mixture/proc/set_thermal_energy(value)

/// Changes the thermal energy by value
/datum/gas_mixture/proc/adjust_thermal_energy(value)

/// Returns the volume
/datum/gas_mixture/proc/volume()

/// Sets the volume to value
/datum/gas_mixture/proc/set_volume(value)

/// Returns the total moles
/datum/gas_mixture/proc/moles()

/// Returns the pressure
/datum/gas_mixture/proc/pressure()

/// Partial Pressure
/datum/gas_mixture/proc/partial_pressure(index)
	src.get_index(index) * R_IDEAL_GAS_EQUATION * src.temperature() / src.volume()

/// Returns the heat capacity
/datum/gas_mixture/proc/heat_capacity()

/// Zeros out the gas mixture
/datum/gas_mixture/proc/zero_out()

/// Removes all gases except if in an underwater map, in which case the gas is set to be hot low pressure air.
/datum/gas_mixture/proc/reset_to_space_gas()

/// Build bitfield of overlays to use for a gas mixture and determine if graphic should be updated
/datum/gas_mixture/proc/check_tile_graphic()

/// Process all reactions, return bitfield if notable reaction occurs.
/datum/gas_mixture/proc/react(atom/dump_location, mult=1)

/// * Process fire combustion, pretty much just plasma combustion.
/// * Returns: Rough amount of plasma and oxygen used. Inaccurate due to plasma usage lowering.
/datum/gas_mixture/proc/fire(mult=1)

/// Processes an interaction between a neutron and this gas mixture, altering the component gasses accordingly.
/// Returns the resulting number of neutrons - 0 means that the reaction consumed the input neutron
/datum/gas_mixture/proc/neutron_interact()

/// * Merges all air from giver into self. Deletes giver.
/// * Returns: TRUE on success (no failure cases yet)
/datum/gas_mixture/proc/merge(datum/gas_mixture/giver)

/// * Proportionally removes amount of gas from the gas_mixture.
/// * Returns: gas_mixture with the gases removed.
/datum/gas_mixture/proc/remove(amount)

/// * Proportionally removes amount of gas from the gas_mixture.
/// * Returns: gas_mixture with the gases removed.
/datum/gas_mixture/proc/remove_ratio(ratio)

/// Copies variables from sample
/datum/gas_mixture/proc/copy_from(datum/gas_mixture/sample)

/// * Performs air sharing calculations between two gas_mixtures assuming only 1 boundary length.
/// * Return: Moles of gas exchanged (+ if sharer received)
/datum/gas_mixture/proc/share(datum/gas_mixture/sharer)

/// Conducts heat between gases.
/// Conduction_coefficient is a multiplier that determines how well heat equalises, with 0 meaning no heat and 1 meaning perfect equalisation.
/datum/gas_mixture/proc/temperature_share(datum/gas_mixture/sharer, conduction_coefficient)

/// Checks for, ya know, if the mixture is potentially dangerous.
/datum/gas_mixture/proc/check_if_dangerous()
	if(src.moles() && (src.temperature() > T100C || src.temperature() < T0C || src.toxins() || src.farts() || src.carbon_dioxide() || (src.nitrogen() && !src.oxygen())))
		return TRUE
	else
		return FALSE

/datum/gas_mixture/normal
	VAR_PRIVATE/alist/gases = alist()
	VAR_PRIVATE/temperature = 0
	VAR_PRIVATE/recalculate = TRUE
	VAR_PRIVATE/heat_capacity = 0
	VAR_PRIVATE/moles = 0
	VAR_PRIVATE/volume = CELL_VOLUME

/datum/gas_mixture/normal/proc/refresh_cache()
	var/heat_capacity_sum = 0
	src.moles = values_sum(src.gases)
	src.heat_capacity = values_dot(src.gases, ATMOS::HEAT_CAPACITIES)
	src.recalculate = FALSE

#define _CREATE_GET_PROCS(GAS, INDEX, ...) /datum/gas_mixture/normal/##GAS() { return src.gases[INDEX]; }
APPLY_TO_GASES(_CREATE_GET_PROCS)
#undef _CREATE_GET_PROCS

#define _CREATE_SET_PROCS(GAS, INDEX, ...) /datum/gas_mixture/normal/set_##GAS(value) { src.gases[INDEX] = value; src.recalculate = TRUE; }
APPLY_TO_GASES(_CREATE_SET_PROCS)
#undef _CREATE_SET_PROCS

#define _CREATE_CHANGE_PROCS(GAS, INDEX, ...) /datum/gas_mixture/normal/adjust_##GAS(value) { src.gases[INDEX] += value; src.recalculate = TRUE; }
APPLY_TO_GASES(_CREATE_CHANGE_PROCS)
#undef _CREATE_CHANGE_PROCS

/datum/gas_mixture/normal/get_index(index)
	return src.gases[index]

/datum/gas_mixture/normal/moles()
	if (src.recalculate)
		src.refresh_cache()
	return src.moles

/datum/gas_mixture/normal/heat_capacity()
	if (src.recalculate)
		src.refresh_cache()
	return src.heat_capacity

/datum/gas_mixture/normal/temperature()
	return src.temperature()

/datum/gas_mixture/normal/set_temperature(value)
	src.temperature() = value

/datum/gas_mixture/normal/adjust_temperature(value)
	src.temperature() += value

/datum/gas_mixture/normal/thermal_energy()
	return src.temperature() * src.heat_capacity()

/datum/gas_mixture/normal/set_thermal_energy(value)
	src.temperature() = value / src.heat_capacity()

/datum/gas_mixture/normal/adjust_thermal_energy(value)
	src.temperature() += value / src.heat_capacity()

/datum/gas_mixture/normal/volume()
	return src.volume

/datum/gas_mixture/normal/pressure()
	src.moles() * R_IDEAL_GAS_EQUATION * src.temperature() / src.volume()

/datum/gas_mixture/normal/zero_out()
	src.gases.Cut()

/// Removes all gases except if in an underwater map, in which case the gas is set to be hot low pressure air.
/datum/gas_mixture/normal/reset_to_space_gas()
	src.zero_out()
	if (map_currently_underwater)
		src.gases[GAS_OXYGEN] = MOLES_O2STANDARD * 0.5
		src.gases[GAS_NITROGEN] = MOLES_N2STANDARD * 0.5
		src.temperature() = OCEAN_TEMP
	src.recalculate = TRUE

/// Build bitfield of overlays to use for a gas mixture and determine if graphic should be updated
/datum/gas_mixture/normal/check_tile_graphic()
	//returns TRUE if graphic changed
	graphic = 0

	UPDATE_GAS_MIXTURE_GRAPHIC(graphic, GAS_IMG_PLASMA, src.gases[GAS_TOXINS])
	UPDATE_GAS_MIXTURE_GRAPHIC(graphic, GAS_IMG_RAD, src.gases[GAS_RADGAS])
	UPDATE_GAS_MIXTURE_GRAPHIC(graphic, GAS_IMG_N2O, src.gases[GAS_NITROUS_OXIDE])

	. = graphic != graphic_archived
	graphic_archived = graphic

/// Process all reactions, return bitfield if notable reaction occurs.
/datum/gas_mixture/normal/react(atom/dump_location, mult=1)
	. = 0 //(used by pipe_network and hotspots)
	var/reaction_rate
	if(src.temperature() > 900 && src.gases[GAS_TOXINS] > MINIMUM_REACT_QUANTITY && src.gases[GAS_CARBON_DIOXIDE] > MINIMUM_REACT_QUANTITY)
		if(src.gases[GAS_AGENT_B] > MINIMUM_REACT_QUANTITY)
			reaction_rate = min(src.gases[GAS_CARBON_DIOXIDE]*0.75, src.gases[GAS_TOXINS]*0.25, src.gases[GAS_AGENT_B]*0.05)
			reaction_rate = QUANTIZE(reaction_rate) * mult

			src.gases[GAS_CARBON_DIOXIDE] -= reaction_rate
			src.gases[GAS_OXYGEN] += reaction_rate
			src.gases[GAS_AGENT_B] -= reaction_rate*0.05

			src.adjust_thermal_energy(reaction_rate*20000)
			src.recalculate = TRUE

			if(reaction_rate > MINIMUM_REACT_QUANTITY)
				. |= CATALYST_ACTIVE
			. |= REACTION_ACTIVE

		if(src.gases[GAS_FARTS] > MINIMUM_REACT_QUANTITY)
			reaction_rate = min(src.gases[GAS_CARBON_DIOXIDE]*0.75, src.gases[GAS_TOXINS]*0.25, src.gases[GAS_FARTS]*0.05)
			reaction_rate = QUANTIZE(reaction_rate) * mult

			src.gases[GAS_CARBON_DIOXIDE] -= reaction_rate
			src.gases[GAS_TOXINS] += reaction_rate
			src.gases[GAS_FARTS] -= reaction_rate*0.05

			src.adjust_thermal_energy(reaction_rate*10000)
			src.recalculate = TRUE
			. |= REACTION_ACTIVE

	src.fuel_burnt = 0
	if(src.temperature() > FIRE_MINIMUM_TEMPERATURE_TO_EXIST)
		if(src.fire(mult))
			. |= COMBUSTION_ACTIVE

/// * Process fire combustion, pretty much just plasma combustion.
/// * Returns: Rough amount of plasma and oxygen used. Inaccurate due to plasma usage lowering.
/datum/gas_mixture/normal/fire(mult=1)

	var/energy_released = 0
	var/old_heat_capacity = HEAT_CAPACITY(src)

	//Handle plasma burning
	if(src.gases[GAS_TOXINS] > MINIMUM_REACT_QUANTITY)
		var/plasma_burn_rate = 0
		var/oxygen_burn_rate = 0
		//more energy released at higher temperatures
		var/temperature_scale
		if(src.temperature() > PLASMA_UPPER_TEMPERATURE)
			temperature_scale = 1
		else
			temperature_scale = (temperature - PLASMA_MINIMUM_BURN_TEMPERATURE) / (PLASMA_UPPER_TEMPERATURE - PLASMA_MINIMUM_BURN_TEMPERATURE)
#ifdef CHECK_MORE_RUNTIMES
		ASSERT(temperature_scale > 0)
#endif
		oxygen_burn_rate = 1.4 - temperature_scale
		if(src.gases[GAS_OXYGEN] > src.gases[GAS_TOXINS] * PLASMA_OXYGEN_FULLBURN)
			plasma_burn_rate = (src.gases[GAS_TOXINS] * temperature_scale) / 4
		else
			plasma_burn_rate = (temperature_scale * (src.gases[GAS_OXYGEN] / PLASMA_OXYGEN_FULLBURN)) / 4
		if(plasma_burn_rate > MINIMUM_REACT_QUANTITY)
			plasma_burn_rate *= mult
			oxygen_burn_rate *= mult

			src.gases[GAS_TOXINS] -= QUANTIZE(plasma_burn_rate / 3) // Plasma usage lowered
			src.gases[GAS_OXYGEN] -= QUANTIZE(plasma_burn_rate * oxygen_burn_rate)
			src.gases[GAS_CARBON_DIOXIDE] += QUANTIZE(plasma_burn_rate / 3)

			energy_released += FIRE_PLASMA_ENERGY_RELEASED * (plasma_burn_rate)

			src.fuel_burnt += (plasma_burn_rate) * ( 1 + oxygen_burn_rate)
			src.recalculate = TRUE

	if(energy_released)
		var/new_heat_capacity = HEAT_CAPACITY(src)
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			src.adjust_thermal_energy(energy_released)
#ifdef CHECK_MORE_RUNTIMES
	ASSERT(src.fuel_burnt >= 0)
#endif
	return src.fuel_burnt

/// Processes an interaction between a neutron and this gas mixture, altering the component gasses accordingly.
/// Returns the resulting number of neutrons - 0 means that the reaction consumed the input neutron
/datum/gas_mixture/normal/neutron_interact()
	var/neutron_count = 1
	if(neutron_count && src.gases[GAS_TOXINS] > 1) //plasma acts crazy, producing fallout and a random bunch of neutrons
		//number of neutrons directly proportional to number of moles
		//for every 100 mol, one extra neutron, with the remainder acting as a prob
		//couple cans of plasma at room temp is about 50 mol in each gas channel with standard setup
		var/plasma_react_count = round((src.gases[GAS_TOXINS] - (src.gases[GAS_TOXINS] % (NEUTRON_PLASMA_REACT_MOLS_PER_LITRE*src.volume)))/(NEUTRON_PLASMA_REACT_MOLS_PER_LITRE*src.volume)) + prob(src.gases[GAS_TOXINS] % (NEUTRON_PLASMA_REACT_MOLS_PER_LITRE*src.volume))
		plasma_react_count = rand(0, plasma_react_count) //make it a little probabilistic
		src.gases[GAS_TOXINS] -= 0.5 * plasma_react_count
		src.gases[GAS_RADGAS] += 2 * plasma_react_count
		neutron_count += plasma_react_count

	if(neutron_count && src.gases[GAS_CARBON_DIOXIDE] > 1) //CO2 acts like a gaseous control rod
		var/co2_react_count = round((src.gases[GAS_CARBON_DIOXIDE] - (src.gases[GAS_CARBON_DIOXIDE] % (NEUTRON_CO2_REACT_MOLS_PER_LITRE*src.volume)))/(NEUTRON_CO2_REACT_MOLS_PER_LITRE*src.volume)) + prob(src.gases[GAS_CARBON_DIOXIDE] % (NEUTRON_CO2_REACT_MOLS_PER_LITRE*src.volume))
		co2_react_count = rand(0, co2_react_count) //make it a little probabilistic
		src.temperature() += 5*min(neutron_count, co2_react_count)
		neutron_count -= min(neutron_count, co2_react_count)

	if(neutron_count && src.gases[GAS_RADGAS] > 1)
		//rare chance for radgas to decompose into a random gas when hit by a neutron
		if(prob(src.gases[GAS_RADGAS]))
			src.gases[GAS_RADGAS] -= 1
			src.temperature() += 5
			switch(rand(1,5))
				if(1)
					src.gases[GAS_OXYGEN] += 0.5
				if(2)
					src.gases[GAS_NITROGEN] += 0.5
				if(3)
					src.gases[GAS_FARTS] += 0.1
				if(4)
					src.gases[GAS_NITROUS_OXIDE] += 0.1
				if(5)
					src.gases[GAS_AGENT_B] += 0.1
	src.recalculate = TRUE
	return neutron_count

/// * Merges all air from giver into self.
/// * Returns: TRUE on success (no failure cases yet)
/datum/gas_mixture/normal/merge(datum/gas_mixture/giver)
	if(!giver)
		return FALSE

	if(abs(temperature-giver.temperature())>MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER)
		var/self_heat_capacity = src.heat_capacity()
		var/giver_heat_capacity = giver.heat_capacity()
		var/combined_heat_capacity = giver_heat_capacity + self_heat_capacity
		if(combined_heat_capacity)
			src.temperature() = (giver.temperature()*giver_heat_capacity + src.temperature()*self_heat_capacity)/combined_heat_capacity

	#define _MERGE_GAS(GAS, INDEX, ...) src.gases[INDEX] += giver.GAS();
	APPLY_TO_GASES(_MERGE_GAS)
	#undef _MERGE_GAS
	src.recalculate = TRUE
	return TRUE

/// * Proportionally removes amount of gas from the gas_mixture.
/// * Returns: gas_mixture with the gases removed.
/datum/gas_mixture/normal/remove(amount)
	var/sum = src.moles()
	amount = min(amount,sum) //Can not take more air than tile has!
	if(amount <= 0)
		return

	var/datum/gas_mixture/normal/removed = new /datum/gas_mixture/normal

	#define _REMOVE_GAS(_, INDEX, ...) \
		removed.gases[INDEX] = min(QUANTIZE((src.gases[INDEX]/sum)*amount), src.gases[INDEX]); \
		src.gases[INDEX] -= removed.gases[INDEX];
	APPLY_TO_GASES(_REMOVE_GAS)
	#undef _REMOVE_GAS

	removed.temperature() = src.temperature()
	src.recalculate = TRUE

	return removed

/// * Proportionally removes amount of gas from the gas_mixture.
/// * Returns: gas_mixture with the gases removed.
/datum/gas_mixture/normal/remove_ratio(ratio)
	if(ratio <= 0)
		return

	ratio = min(ratio, 1)

	var/datum/gas_mixture/normal/removed = new /datum/gas_mixture/normal

	#define _REMOVE_GAS_RATIO(_, INDEX, ...) \
		removed.gases[INDEX] = min(QUANTIZE(src.gases[INDEX]*ratio), src.gases[INDEX]); \
		src.gases[INDEX] -= removed.gases[INDEX];
	APPLY_TO_GASES(_REMOVE_GAS_RATIO)
	#undef _REMOVE_GAS_RATIO

	removed.temperature() = src.temperature()
	src.recalculate = TRUE

	return removed

/// Copies variables from sample
/datum/gas_mixture/normal/copy_from(datum/gas_mixture/sample)
	if (!sample)
		return FALSE

	#define _COPY_GAS(GAS, INDEX, ...) src.gases[INDEX] = sample.GAS();
	APPLY_TO_GASES(_COPY_GAS)
	#undef _COPY_GAS

	src.temperature = sample.temperature()
	src.recalculate = TRUE

	return TRUE

/// * Performs air sharing calculations between two gas_mixtures assuming only 1 boundary length.
/// * Return: Moles of gas exchanged (+ if sharer received)
/datum/gas_mixture/normal/share(datum/gas_mixture/sharer)
	if(!sharer)
		return
	#define _DELTA_GAS(GAS, INDEX, ...) var/delta_##GAS = QUANTIZE(src.gases[INDEX] - sharer.GAS())/5;
	APPLY_TO_GASES(_DELTA_GAS)
	#undef _DELTA_GAS

	var/delta_temperature = (src.temperature() - sharer.temperature())

	var/moved_moles = 0 MOLES
	#define _SHARE_GAS(GAS, INDEX, ...) \
		if(delta_##GAS) { \
			src.gases[INDEX] -= delta_##GAS; \
			sharer.adjust_##GAS(delta_##GAS); \
			moved_moles += delta_##GAS; }
	APPLY_TO_GASES(_SHARE_GAS)
	#undef _SHARE_GAS
	src.recalculate = TRUE

	if(abs(delta_temperature) > MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER)
		var/heat_capacity_self_to_sharer = 0
		var/heat_capacity_sharer_to_self = 0
		#define _SHARE_GAS_HEAT(GAS, INDEX, ...) \
			if(delta_##GAS > 0) { heat_capacity_self_to_sharer += ATMOS::HEAT_CAPACITIES[INDEX] * delta_##GAS } \
			else if(delta_##GAS < 0) { heat_capacity_sharer_to_self -= ATMOS::HEAT_CAPACITIES[INDEX] * delta_##GAS }
		APPLY_TO_GASES(_SHARE_GAS_HEAT)
		#undef _SHARE_GAS_HEAT
		var/old_self_heat_capacity = src.heat_capacity()
		var/old_sharer_heat_capacity = sharer.heat_capacity()

		var/new_self_heat_capacity = old_self_heat_capacity + heat_capacity_sharer_to_self - heat_capacity_self_to_sharer
		var/new_sharer_heat_capacity = old_sharer_heat_capacity + heat_capacity_self_to_sharer - heat_capacity_sharer_to_self

		if(new_self_heat_capacity > MINIMUM_HEAT_CAPACITY)
			src.temperature() = (old_self_heat_capacity*src.temperature() - heat_capacity_self_to_sharer*src.temperature() + heat_capacity_sharer_to_self*sharer.temperature())/new_self_heat_capacity

		if(new_sharer_heat_capacity > MINIMUM_HEAT_CAPACITY)
			sharer.set_temperature((old_sharer_heat_capacity*sharer.temperature()-heat_capacity_sharer_to_self*sharer.temperature() + heat_capacity_self_to_sharer*src.temperature())/new_sharer_heat_capacity)

			if(abs(old_sharer_heat_capacity) > MINIMUM_HEAT_CAPACITY && abs(new_sharer_heat_capacity/old_sharer_heat_capacity - 1) < 0.1) // <10% change in sharer heat capacity
				src.temperature_share(sharer, OPEN_HEAT_TRANSFER_COEFFICIENT)

	// Check that either threshold was met for pressure_difference calculations
	if((abs(delta_temperature) > MINIMUM_TEMPERATURE_TO_MOVE) || abs(moved_moles) > MINIMUM_MOLES_DELTA_TO_MOVE)
		var/delta_pressure = src.temperature()*(src.moles() + moved_moles) - sharer.temperature()*(sharer.moles() - moved_moles)
		return (delta_pressure*R_IDEAL_GAS_EQUATION/volume)
	else
		return 0 MOLES

/// Conducts heat between gases.
/// Conduction_coefficient is a multiplier that determines how well heat equalises, with 0 meaning no heat and 1 meaning perfect equalisation.
/datum/gas_mixture/normal/temperature_share(datum/gas_mixture/sharer, conduction_coefficient)
	var/delta_temperature = (src.temperature() - sharer.temperature())
	if(abs(delta_temperature) > MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER)
		var/self_heat_capacity = src.heat_capacity()
		var/sharer_heat_capacity = sharer.heat_capacity()

		if((sharer_heat_capacity > MINIMUM_HEAT_CAPACITY) && (self_heat_capacity > MINIMUM_HEAT_CAPACITY))
			var/heat = conduction_coefficient*delta_temperature* \
				(self_heat_capacity*sharer_heat_capacity/(self_heat_capacity+sharer_heat_capacity))

			src.adjust_thermal_energy(-heat)
			sharer.adjust_thermal_energy(heat)


/datum/gas_mixture/turf_tied
	VAR_PRIVATE/turf/our_turf = null
	VAR_PRIVATE/read_only = FALSE

#define _CREATE_GET_PROCS(GAS, INDEX, ...) /datum/gas_mixture/turf_tied/##GAS() { return goonmos_get_gas(src.our_turf, INDEX); }
APPLY_TO_GASES(_CREATE_GET_PROCS)
#undef _CREATE_GET_PROCS

#define _CREATE_SET_PROCS(GAS, INDEX, ...) /datum/gas_mixture/turf_tied/set_##GAS(value) { if (!src.read_only) { goonmos_set_gas(src.our_turf, INDEX, value); } }
APPLY_TO_GASES(_CREATE_SET_PROCS)
#undef _CREATE_SET_PROCS

#define _CREATE_CHANGE_PROCS(GAS, INDEX, ...) /datum/gas_mixture/turf_tied/adjust_##GAS(value) { if (!src.read_only) { goonmos_adjust_gas(src.our_turf, INDEX, value); } }
APPLY_TO_GASES(_CREATE_CHANGE_PROCS)
#undef _CREATE_CHANGE_PROCS

/// Returns temperature in Kelvin
/datum/gas_mixture/turf_tied/temperature()
	goonmos_get_temperature(src.our_turf)

/// Sets the temperature to value
/datum/gas_mixture/turf_tied/set_temperature(value)
	goonmos_set_temperature(src.our_turf, value)

/// Changes the temperature by value
/datum/gas_mixture/turf_tied/adjust_temperature(value)
	goonmos_adjust_temperature(src.our_turf, value)

/// Returns the thermal energy
/datum/gas_mixture/turf_tied/thermal_energy()


/// Sets the thermal energy to value
/datum/gas_mixture/turf_tied/set_thermal_energy(value)

/// Changes the thermal energy by value
/datum/gas_mixture/turf_tied/adjust_thermal_energy(value)

/// Returns the volume
/datum/gas_mixture/turf_tied/volume()
	return CELL_VOLUME

/// No-op
/datum/gas_mixture/turf_tied/set_volume(value)

/// Returns the total moles
/datum/gas_mixture/turf_tied/moles()
	return goonmos_get_total_moles(src.our_turf)

/// Returns the pressure
/datum/gas_mixture/turf_tied/pressure()
	return goonmos_get_pressure(src.our_turf)

/// Returns the heat capacity
/datum/gas_mixture/turf_tied/heat_capacity()
	return 

/// Zeros out the gas mixture
/datum/gas_mixture/turf_tied/zero_out()

/// Removes all gases except if in an underwater map, in which case the gas is set to be hot low pressure air.
/datum/gas_mixture/turf_tied/reset_to_space_gas()

/// Conducts heat between gases.
/// Conduction_coefficient is a multiplier that determines how well heat equalises, with 0 meaning no heat and 1 meaning perfect equalisation.
/datum/gas_mixture/turf_tied/temperature_share(datum/gas_mixture/sharer, conduction_coefficient)
	var/heat = goonmos_mimic_temperature_exchange(src.our_turf, sharer.temperature(), sharer.heat_capacity(), conduction_coefficient)
	src.adjust_thermal_energy(-heat)
	sharer.adjust_thermal_energy(heat)

