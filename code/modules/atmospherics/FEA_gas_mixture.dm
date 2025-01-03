/*
What are the archived variables for?
	Calculations are done using the archived variables with the results merged into the regular variables.
	This prevents race conditions that arise based on the order of tile processing.
*/

/** The key of atmospherics.
 * 	This datum here is how we represent gas mixtures. Temperature is in Kelvin and volume is in Litres.
 * 	Defines and stores base gases using [APPLY_TO_GASES] and stores trace gases using [datum/gas_mixture/var/list/datum/gas/trace_gases]. */
/datum/gas_mixture
	#define _DEFINE_GAS(GAS, ...) var/GAS = 0;
	APPLY_TO_GASES(_DEFINE_GAS)
	#undef _DEFINE_GAS

#ifdef ATMOS_ARCHIVING
	#define _DEFINE_ARCH_GAS(GAS, ...) var/tmp/GAS;
	APPLY_TO_ARCHIVED_GASES(_DEFINE_ARCH_GAS)
	#undef _DEFINE_ARCH_GAS
#endif
	/// Temperature of gases in Kelvin
	var/temperature = 0 KELVIN
#ifdef ATMOS_ARCHIVING
	var/tmp/ARCHIVED(temperature)
#endif

	/// Volume of container in litres
	var/volume = CELL_VOLUME
	/// Used in air groups, this represents how many tiles are in the air group.
	/// Using this lets us scale all kinds of variables so we can always act like one big tile.
	var/group_multiplier = 1
	/// Bitfield representing gas graphics on our tile.
	var/graphic
	var/tmp/graphic_archived // intentionally NOT using ARCHIVED() because graphic archiving is actually important and shouldn't be turned off
	/// Rough representation of oxygen and plasma used. Actual usage of plasma is currectly divided by 3 for balance.
	var/tmp/fuel_burnt = 0


// Overrides
/datum/gas_mixture/disposing()
	total_gas_mixtures--
	..()

/datum/gas_mixture/New()
	..()
	total_gas_mixtures++

// Mutator procs
// For specific events

/// Removes all gases except if in an underwater map, in which case the gas is set to be hot low pressure air.
/datum/gas_mixture/proc/reset_to_space_gas()
	ZERO_GASES(src)
	if (map_currently_underwater)
		src.oxygen = MOLES_O2STANDARD * 0.5
		src.nitrogen = MOLES_N2STANDARD * 0.5
		src.temperature = OCEAN_TEMP

/// Build bitfield of overlays to use for a gas mixture and determine if graphic should be updated
/datum/gas_mixture/proc/check_tile_graphic()
	//returns TRUE if graphic changed
	graphic = 0

	UPDATE_GAS_MIXTURE_GRAPHIC(graphic, GAS_IMG_PLASMA, toxins)
	UPDATE_GAS_MIXTURE_GRAPHIC(graphic, GAS_IMG_RAD, radgas)
	UPDATE_GAS_MIXTURE_GRAPHIC(graphic, GAS_IMG_N2O, nitrous_oxide)

	. = graphic != graphic_archived
	graphic_archived = graphic

/// Process all reactions, return bitfield if notable reaction occurs.
/datum/gas_mixture/proc/react(atom/dump_location, mult=1)
	. = 0 //(used by pipe_network and hotspots)
	var/reaction_rate
	if(src.temperature > 900 && src.toxins > MINIMUM_REACT_QUANTITY && src.carbon_dioxide > MINIMUM_REACT_QUANTITY)
		if(src.oxygen_agent_b > MINIMUM_REACT_QUANTITY)
			reaction_rate = min(src.carbon_dioxide*0.75, src.toxins*0.25, src.oxygen_agent_b*0.05)
			reaction_rate = reaction_rate * mult

			src.carbon_dioxide -= reaction_rate
			src.oxygen += reaction_rate
			src.oxygen_agent_b -= reaction_rate*0.05

			src.temperature += (reaction_rate*20000)/HEAT_CAPACITY(src)

			if(reaction_rate > MINIMUM_REACT_QUANTITY)
				. |= CATALYST_ACTIVE
			. |= REACTION_ACTIVE

		if(src.farts > MINIMUM_REACT_QUANTITY)
			reaction_rate = min(src.carbon_dioxide*0.75, src.toxins*0.25, src.farts*0.05)
			reaction_rate = reaction_rate * mult

			src.carbon_dioxide -= reaction_rate
			src.toxins += reaction_rate
			src.farts -= reaction_rate*0.05

			src.temperature += (reaction_rate*10000)/HEAT_CAPACITY(src)
			. |= REACTION_ACTIVE

	src.fuel_burnt = 0
	if(src.temperature > FIRE_MINIMUM_TEMPERATURE_TO_EXIST)
		if(src.fire(mult))
			. |= COMBUSTION_ACTIVE

/// * Process fire combustion, pretty much just plasma combustion.
/// * Returns: Rough amount of plasma and oxygen used. Inaccurate due to plasma usage lowering.
/datum/gas_mixture/proc/fire(mult=1)

	var/energy_released = 0
	var/old_heat_capacity = HEAT_CAPACITY(src)

	//Handle plasma burning
	if(src.toxins > MINIMUM_REACT_QUANTITY)
		var/plasma_burn_rate = 0
		var/oxygen_burn_rate = 0
		//more energy released at higher temperatures
		var/temperature_scale
		if(src.temperature > PLASMA_UPPER_TEMPERATURE)
			temperature_scale = 1
		else
			temperature_scale = (temperature - PLASMA_MINIMUM_BURN_TEMPERATURE) / (PLASMA_UPPER_TEMPERATURE - PLASMA_MINIMUM_BURN_TEMPERATURE)
#ifdef CHECK_MORE_RUNTIMES
		ASSERT(temperature_scale > 0)
#endif
		oxygen_burn_rate = 1.4 - temperature_scale
		if(src.oxygen > src.toxins * PLASMA_OXYGEN_FULLBURN)
			plasma_burn_rate = (src.toxins * temperature_scale) / 4
		else
			plasma_burn_rate = (temperature_scale * (src.oxygen / PLASMA_OXYGEN_FULLBURN)) / 4
		if(plasma_burn_rate > MINIMUM_REACT_QUANTITY)
			plasma_burn_rate *= mult
			oxygen_burn_rate *= mult

			src.toxins -= plasma_burn_rate / 3 // Plasma usage lowered
			src.oxygen -= plasma_burn_rate * oxygen_burn_rate
			src.carbon_dioxide += plasma_burn_rate / 3

			energy_released += FIRE_PLASMA_ENERGY_RELEASED * (plasma_burn_rate)

			src.fuel_burnt += (plasma_burn_rate) * ( 1 + oxygen_burn_rate)

	if(energy_released)
		var/new_heat_capacity = HEAT_CAPACITY(src)
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			src.temperature = (src.temperature * old_heat_capacity + energy_released) / new_heat_capacity
#ifdef CHECK_MORE_RUNTIMES
	ASSERT(src.fuel_burnt >= 0)
#endif
	return src.fuel_burnt

/// Processes an interaction between a neutron and this gas mixture, altering the component gasses accordingly.
/// Returns the resulting number of neutrons - 0 means that the reaction consumed the input neutron
/datum/gas_mixture/proc/neutron_interact()
	var/neutron_count = 1
	if(neutron_count && src.toxins > 1) //plasma acts crazy, producing fallout and a random bunch of neutrons
		//number of neutrons directly proportional to number of moles
		//for every 100 mol, one extra neutron, with the remainder acting as a prob
		//couple cans of plasma at room temp is about 50 mol in each gas channel with standard setup
		var/plasma_react_count = round((src.toxins - (src.toxins % (NEUTRON_PLASMA_REACT_MOLS_PER_LITRE*src.volume)))/(NEUTRON_PLASMA_REACT_MOLS_PER_LITRE*src.volume)) + prob(src.toxins % (NEUTRON_PLASMA_REACT_MOLS_PER_LITRE*src.volume))
		plasma_react_count = rand(0, plasma_react_count) //make it a little probabilistic
		src.toxins -= 0.5 * plasma_react_count
		src.radgas += 2 * plasma_react_count
		neutron_count += plasma_react_count

	if(neutron_count && src.carbon_dioxide > 1) //CO2 acts like a gaseous control rod
		var/co2_react_count = round((src.carbon_dioxide - (src.carbon_dioxide % (NEUTRON_CO2_REACT_MOLS_PER_LITRE*src.volume)))/(NEUTRON_CO2_REACT_MOLS_PER_LITRE*src.volume)) + prob(src.carbon_dioxide % (NEUTRON_CO2_REACT_MOLS_PER_LITRE*src.volume))
		co2_react_count = rand(0, co2_react_count) //make it a little probabilistic
		src.temperature += 5*min(neutron_count, co2_react_count)
		neutron_count -= min(neutron_count, co2_react_count)

	if(neutron_count && src.radgas > 1)
		//rare chance for radgas to decompose into a random gas when hit by a neutron
		if(prob(src.radgas))
			src.radgas -= 1
			src.temperature += 5
			switch(rand(1,5))
				if(1)
					src.oxygen += 0.5
				if(2)
					src.nitrogen += 0.5
				if(3)
					src.farts += 0.1
				if(4)
					src.nitrous_oxide += 0.1
				if(5)
					src.oxygen_agent_b += 0.1
	return neutron_count

#ifdef ATMOS_ARCHIVING
/// Update archived versions of variables.
/datum/gas_mixture/proc/archive()
	#define _ARCHIVE_GAS(GAS, ...) ARCHIVED(GAS) = GAS;
	APPLY_TO_GASES(_ARCHIVE_GAS)
	#undef _ARCHIVE_GAS
	src.ARCHIVED(temperature) = src.temperature
	src.graphic_archived = src.graphic
#endif

/** Similar to [/datum/gas_mixture/proc/merge] but first checks to see if the amount of air assumed is small enough
	that group processing is still accurate for source (aborts if not).
 *  Returns: TRUE on successful merge, FALSE if the check failed. */
/datum/gas_mixture/proc/check_then_merge(datum/gas_mixture/giver)
	if(!giver)
		return FALSE
	#define _ABOVE_SUSPEND_THRESHOLD(GAS, ...) ((giver.GAS > MINIMUM_AIR_TO_SUSPEND) && (giver.GAS >= GAS*MINIMUM_AIR_RATIO_TO_SUSPEND)) ||
	if(APPLY_TO_GASES(_ABOVE_SUSPEND_THRESHOLD) FALSE) // the FALSE is there so the last || in the macro isnt left hanging
		return FALSE
	#undef _ABOVE_SUSPEND_THRESHOLD
	if(abs(giver.temperature - src.temperature) > MINIMUM_TEMPERATURE_DELTA_TO_SUSPEND)
		return FALSE

	return merge(giver)

/// * Merges all air from giver into self. Deletes giver.
/// * Returns: TRUE on success (no failure cases yet)
/datum/gas_mixture/proc/merge(datum/gas_mixture/giver)
	if(!giver)
		return FALSE

	if(abs(temperature-giver.temperature)>MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER)
		var/self_heat_capacity = HEAT_CAPACITY(src)*src.group_multiplier
		var/giver_heat_capacity = HEAT_CAPACITY(giver)*giver.group_multiplier
		var/combined_heat_capacity = giver_heat_capacity + self_heat_capacity
		if(combined_heat_capacity)
			src.temperature = (giver.temperature*giver_heat_capacity + src.temperature*self_heat_capacity)/combined_heat_capacity

	if((src.group_multiplier > 1) || (giver.group_multiplier > 1))
		#define _MERGE_GAS_GM(GAS, ...) GAS += giver.GAS*giver.group_multiplier/src.group_multiplier;
		APPLY_TO_GASES(_MERGE_GAS_GM)
		#undef _MERGE_GAS_GM
	else
		#define _MERGE_GAS(GAS, ...) GAS += giver.GAS;
		APPLY_TO_GASES(_MERGE_GAS)
		#undef _MERGE_GAS

	giver.dispose() // skip the qdel overhead
	return TRUE

/// * Proportionally removes amount of gas from the gas_mixture.
/// * Returns: gas_mixture with the gases removed.
/datum/gas_mixture/proc/remove(amount)
	var/sum = TOTAL_MOLES(src)
	amount = min(amount,sum) //Can not take more air than tile has!
	if(amount <= 0)
		return

	var/datum/gas_mixture/removed = new /datum/gas_mixture

	#define _REMOVE_GAS(GAS, ...) \
		removed.GAS = min((src.GAS/sum)*amount, src.GAS); \
		src.GAS -= removed.GAS/src.group_multiplier;
	APPLY_TO_GASES(_REMOVE_GAS)
	#undef _REMOVE_GAS

	removed.temperature = src.temperature

	return removed

/// * Proportionally removes amount of gas from the gas_mixture.
/// * Returns: gas_mixture with the gases removed.
/datum/gas_mixture/proc/remove_ratio(ratio)
	if(ratio <= 0)
		return

	ratio = min(ratio, 1)

	var/datum/gas_mixture/removed = new /datum/gas_mixture

	#define _REMOVE_GAS_RATIO(GAS, ...) \
		removed.GAS = min(src.GAS*ratio, src.GAS); \
		src.GAS -= removed.GAS/src.group_multiplier;
	APPLY_TO_GASES(_REMOVE_GAS_RATIO)
	#undef _REMOVE_GAS_RATIO

	removed.temperature = src.temperature

	return removed

/** Similar to [/datum/gas_mixture/proc/remove] but first checks to see if the amount of air removed is small enough
	that group processing is still accurate for source (aborts if not).
 *  Returns: gas_mixture with the gases removed if group processing was preserved, else [SELF_CHECK_FAIL]. */
/datum/gas_mixture/proc/check_then_remove(amount)
	//Since it is all proportional, the check may be done on the gas as a whole
	var/sum = TOTAL_MOLES(src)
	amount = min(amount,sum) //Can not take more air than tile has!

	if((amount > MINIMUM_AIR_RATIO_TO_SUSPEND) && (amount > sum*MINIMUM_AIR_RATIO_TO_SUSPEND))
		return SELF_CHECK_FAIL

	return remove(amount)

/// Copies variables from sample
/datum/gas_mixture/proc/copy_from(datum/gas_mixture/sample)
	if (!sample)
		return FALSE

	#define _COPY_GAS(GAS, ...) GAS = sample.GAS;
	APPLY_TO_GASES(_COPY_GAS)
	#undef _COPY_GAS

	src.temperature = sample.temperature

	return TRUE

/// Subtracts right_side from air_mixture. Used to help turfs mingle
/datum/gas_mixture/proc/subtract(datum/gas_mixture/right_side)
	#define _SUBTRACT_GAS(GAS, ...) GAS -= right_side.GAS;
	APPLY_TO_GASES(_SUBTRACT_GAS)
	#undef _SUBTRACT_GAS

/// * Checks if us and the sharer have a low enough delta and our combination's delta is small enough that group processing can be preserved.
/// * Returns: [SELF_CHECK_FAIL] if the self-check failed, [SHARER_CHECK_FAIL] if sharer-check failed, [GROUP_CHECK_PASS] if both checks pass.
/datum/gas_mixture/proc/check_gas_mixture(datum/gas_mixture/sharer)
	if (!sharer)
		return SELF_CHECK_FAIL
	#define _DELTA_GAS(GAS, ...) var/delta_##GAS = (GAS - sharer.GAS)/5;
	APPLY_TO_ARCHIVED_GASES(_DELTA_GAS)
	#undef _DELTA_GAS

	var/delta_temperature = (ARCHIVED(temperature) - sharer.ARCHIVED(temperature))

	#define _ABOVE_SUSPEND_THRESHOLD(GAS, ...) ((abs(delta_##GAS) > MINIMUM_AIR_TO_SUSPEND) && (abs(delta_##GAS) >= GAS*MINIMUM_AIR_RATIO_TO_SUSPEND)) ||
	if(APPLY_TO_ARCHIVED_GASES(_ABOVE_SUSPEND_THRESHOLD) FALSE) // the FALSE is there so the last || in the macro isnt left hanging
		return SELF_CHECK_FAIL
	#undef _ABOVE_SUSPEND_THRESHOLD

	if(abs(delta_temperature) > MINIMUM_TEMPERATURE_DELTA_TO_SUSPEND)
		return SELF_CHECK_FAIL

	#define _ABOVE_SUSPEND_THRESHOLD(GAS, ...) ((abs(delta_##GAS) > MINIMUM_AIR_TO_SUSPEND) && (abs(delta_##GAS) >= sharer.GAS*MINIMUM_AIR_RATIO_TO_SUSPEND)) ||
	if(APPLY_TO_ARCHIVED_GASES(_ABOVE_SUSPEND_THRESHOLD) FALSE) // the FALSE is there so the last || in the macro isnt left hanging
		return SHARER_CHECK_FAIL
	#undef _ABOVE_SUSPEND_THRESHOLD

	return GROUP_CHECK_PASS

/// * Checks if the turf is valid for air group processing.
/// * Returns: FALSE if self-check failed or TRUE if check passes
/datum/gas_mixture/proc/check_turf(turf/model)
	#define _DELTA_GAS(GAS, ...) var/delta_##GAS = (ARCHIVED(GAS) - model.GAS)/5;
	APPLY_TO_GASES(_DELTA_GAS)
	#undef _DELTA_GAS

	var/delta_temperature = (ARCHIVED(temperature) - model.temperature)

	#define _ABOVE_SUSPEND_THRESHOLD(GAS, ...) ((abs(delta_##GAS) > MINIMUM_AIR_TO_SUSPEND) && (abs(delta_##GAS) >= ARCHIVED(GAS)*MINIMUM_AIR_RATIO_TO_SUSPEND)) ||
	if(APPLY_TO_GASES(_ABOVE_SUSPEND_THRESHOLD) FALSE) // the FALSE is there so the last || in the macro isnt left hanging
		return FALSE
	#undef _ABOVE_SUSPEND_THRESHOLD
	if(abs(delta_temperature) > MINIMUM_TEMPERATURE_DELTA_TO_SUSPEND)
		return FALSE

	return TRUE

/// * Performs air sharing calculations between two gas_mixtures assuming only 1 boundary length.
/// * Return: Moles of gas exchanged (+ if sharer received)
/datum/gas_mixture/proc/share(datum/gas_mixture/sharer)
	if(!sharer)
		return
	#define _DELTA_GAS(GAS, ...) var/delta_##GAS = (src.ARCHIVED(GAS) - sharer.ARCHIVED(GAS))/5;
	APPLY_TO_GASES(_DELTA_GAS)
	#undef _DELTA_GAS

	var/delta_temperature = (src.ARCHIVED(temperature) - sharer.ARCHIVED(temperature))

	var/moved_moles = 0 MOLES
	#define _SHARE_GAS(GAS, ...) \
		if(delta_##GAS) { \
			src.GAS -= delta_##GAS / src.group_multiplier; \
			sharer.GAS += delta_##GAS / sharer.group_multiplier; \
			moved_moles += delta_##GAS; }
	APPLY_TO_GASES(_SHARE_GAS)
	#undef _SHARE_GAS

	if(abs(delta_temperature) > MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER)
		var/heat_capacity_self_to_sharer = 0
		var/heat_capacity_sharer_to_self = 0
		#define _SHARE_GAS_HEAT(GAS, SPECIFIC_HEAT, ...) \
			if(delta_##GAS > 0) { heat_capacity_self_to_sharer += SPECIFIC_HEAT * delta_##GAS } \
			else if(delta_##GAS < 0) { heat_capacity_sharer_to_self -= SPECIFIC_HEAT * delta_##GAS }
		APPLY_TO_GASES(_SHARE_GAS_HEAT)
		#undef _SHARE_GAS_HEAT
		var/old_self_heat_capacity = HEAT_CAPACITY(src)*src.group_multiplier
		var/old_sharer_heat_capacity = HEAT_CAPACITY(sharer)*sharer.group_multiplier

		var/new_self_heat_capacity = old_self_heat_capacity + heat_capacity_sharer_to_self - heat_capacity_self_to_sharer
		var/new_sharer_heat_capacity = old_sharer_heat_capacity + heat_capacity_self_to_sharer - heat_capacity_sharer_to_self

		if(new_self_heat_capacity > MINIMUM_HEAT_CAPACITY)
			src.temperature = (old_self_heat_capacity*src.temperature - heat_capacity_self_to_sharer*ARCHIVED(temperature) + heat_capacity_sharer_to_self*sharer.ARCHIVED(temperature))/new_self_heat_capacity

		if(new_sharer_heat_capacity > MINIMUM_HEAT_CAPACITY)
			sharer.temperature = (old_sharer_heat_capacity*sharer.temperature-heat_capacity_sharer_to_self*sharer.ARCHIVED(temperature) + heat_capacity_self_to_sharer*ARCHIVED(temperature))/new_sharer_heat_capacity

			if(abs(old_sharer_heat_capacity) > MINIMUM_HEAT_CAPACITY && abs(new_sharer_heat_capacity/old_sharer_heat_capacity - 1) < 0.1) // <10% change in sharer heat capacity
				src.temperature_share(sharer, OPEN_HEAT_TRANSFER_COEFFICIENT)

	// Check that either threshold was met for pressure_difference calculations
	if((abs(delta_temperature) > MINIMUM_TEMPERATURE_TO_MOVE) || abs(moved_moles) > MINIMUM_MOLES_DELTA_TO_MOVE)
		var/delta_pressure = ARCHIVED(temperature)*(TOTAL_MOLES(src) + moved_moles) - sharer.ARCHIVED(temperature)*(TOTAL_MOLES(sharer) - moved_moles)
		return (delta_pressure*R_IDEAL_GAS_EQUATION/volume)
	else
		return 0 MOLES

/// * Similar to [/datum/gas_mixture/proc/share], except the model is not modified.
/// * Return: Moles of gas exchanged.
/datum/gas_mixture/proc/mimic(turf/model, border_multiplier = 1)
	if (!model)
		return FALSE

	#define _DELTA_GAS(GAS, ...) var/delta_##GAS = ((src.ARCHIVED(GAS) - model.GAS)/5)*border_multiplier/src.group_multiplier;
	APPLY_TO_GASES(_DELTA_GAS)
	#undef _DELTA_GAS

	var/delta_temperature = (src.ARCHIVED(temperature) - model.temperature)

	var/moved_moles = 0 MOLES

	#define _MIMIC_GAS(GAS, ...) \
		src.GAS = src.GAS - delta_##GAS; \
		moved_moles += delta_##GAS;
	APPLY_TO_GASES(_MIMIC_GAS)
	#undef _MIMIC_GAS

	if(abs(delta_temperature) > MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER)
		var/heat_transferred = 0
		var/old_self_heat_capacity = 0
		var/heat_capacity_transferred = 0

		if(abs(delta_temperature) > MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER)
			#define _MIMIC_GAS_HEAT(GAS, SPECIFIC_HEAT, ...) \
				if(delta_##GAS) { \
					var/GAS##_heat_capacity = SPECIFIC_HEAT * delta_##GAS; \
					heat_transferred -= GAS##_heat_capacity * model.temperature; \
					heat_capacity_transferred -= GAS##_heat_capacity; \
				}
			APPLY_TO_GASES(_MIMIC_GAS_HEAT)
			#undef _MIMIC_GAS_HEAT

		old_self_heat_capacity = HEAT_CAPACITY(src)*src.group_multiplier
		var/new_self_heat_capacity = old_self_heat_capacity - heat_capacity_transferred
		if(new_self_heat_capacity > MINIMUM_HEAT_CAPACITY)
			src.temperature = (old_self_heat_capacity*src.temperature - heat_capacity_transferred*border_multiplier*src.ARCHIVED(temperature))/new_self_heat_capacity

		src.temperature_mimic(model, model.thermal_conductivity, border_multiplier)

	if((delta_temperature > MINIMUM_TEMPERATURE_TO_MOVE))
		var/delta_pressure = src.ARCHIVED(temperature)*(TOTAL_MOLES(src) + moved_moles) - model.temperature*TOTAL_MOLES(model)
		return (delta_pressure*R_IDEAL_GAS_EQUATION/volume)
	else
		return 0 MOLES

/** Checks if our combined temperatures have a low enough delta that group processing is preserved.
 * Returns: [SELF_CHECK_FAIL] if the self-check failed, [SHARER_CHECK_FAIL] if sharer-check failed, [GROUP_CHECK_PASS] if both checks pass. */
/datum/gas_mixture/proc/check_both_then_temperature_share(datum/gas_mixture/sharer, conduction_coefficient)
	var/delta_temperature = (src.ARCHIVED(temperature) - sharer.ARCHIVED(temperature))

	var/self_heat_capacity = HEAT_CAPACITY_ARCHIVED(src)
	var/sharer_heat_capacity = HEAT_CAPACITY_ARCHIVED(sharer)

	var/self_temperature_delta = 0
	var/sharer_temperature_delta = 0

	if((sharer_heat_capacity > MINIMUM_HEAT_CAPACITY) && (self_heat_capacity > MINIMUM_HEAT_CAPACITY))
		var/heat = conduction_coefficient*delta_temperature* \
			(self_heat_capacity*sharer_heat_capacity/(self_heat_capacity+sharer_heat_capacity))

		self_temperature_delta = -heat/(self_heat_capacity*src.group_multiplier)
		sharer_temperature_delta = heat/(sharer_heat_capacity*sharer.group_multiplier)
	else
		return GROUP_CHECK_PASS

	if((abs(self_temperature_delta) > MINIMUM_TEMPERATURE_DELTA_TO_SUSPEND) \
		&& (abs(self_temperature_delta) > MINIMUM_TEMPERATURE_RATIO_TO_SUSPEND*src.ARCHIVED(temperature)))
		return SELF_CHECK_FAIL

	if((abs(sharer_temperature_delta) > MINIMUM_TEMPERATURE_DELTA_TO_SUSPEND) \
		&& (abs(sharer_temperature_delta) > MINIMUM_TEMPERATURE_RATIO_TO_SUSPEND*sharer.ARCHIVED(temperature)))
		return SHARER_CHECK_FAIL

	src.temperature += self_temperature_delta
	sharer.temperature += sharer_temperature_delta

	return GROUP_CHECK_PASS
	//Logic integrated from: temperature_share(sharer, conduction_coefficient) for efficiency

/// Similar to [/datum/gas_mixture/proc/check_both_then_temperature_share] except that we solely check ourselves.
/// Returns: FALSE if the self-check failed and TRUE if self-check passed.
/datum/gas_mixture/proc/check_me_then_temperature_share(datum/gas_mixture/sharer, conduction_coefficient)
	var/delta_temperature = (src.ARCHIVED(temperature) - sharer.ARCHIVED(temperature))

	var/self_heat_capacity = HEAT_CAPACITY_ARCHIVED(src)
	var/sharer_heat_capacity = HEAT_CAPACITY_ARCHIVED(sharer)

	var/self_temperature_delta = 0
	var/sharer_temperature_delta = 0

	if((sharer_heat_capacity > MINIMUM_HEAT_CAPACITY) && (self_heat_capacity > MINIMUM_HEAT_CAPACITY))
		var/heat = conduction_coefficient*delta_temperature* \
			(self_heat_capacity*sharer_heat_capacity/(self_heat_capacity+sharer_heat_capacity))

		self_temperature_delta = -heat/(self_heat_capacity*src.group_multiplier)
		sharer_temperature_delta = heat/(sharer_heat_capacity*sharer.group_multiplier)
	else
		return TRUE

	if((abs(self_temperature_delta) > MINIMUM_TEMPERATURE_DELTA_TO_SUSPEND) \
		&& (abs(self_temperature_delta) > MINIMUM_TEMPERATURE_RATIO_TO_SUSPEND*src.ARCHIVED(temperature)))
		return FALSE

	src.temperature += self_temperature_delta
	sharer.temperature += sharer_temperature_delta

	return TRUE
	//Logic integrated from: temperature_share(sharer, conduction_coefficient) for efficiency

/// * Checks if the difference is small enough so we can continue group processing,
/// * Return: TRUE if valid for group processing, FALSE if delta is too large for group processing.
/datum/gas_mixture/proc/check_me_then_temperature_turf_share(turf/simulated/sharer, conduction_coefficient)
	var/delta_temperature = (src.ARCHIVED(temperature) - sharer.temperature)

	var/self_temperature_delta = 0
	var/sharer_temperature_delta = 0

	if(abs(delta_temperature) > MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER)
		var/self_heat_capacity = HEAT_CAPACITY_ARCHIVED(src)

		if((sharer.heat_capacity > MINIMUM_HEAT_CAPACITY) && (self_heat_capacity > MINIMUM_HEAT_CAPACITY))
			var/heat = conduction_coefficient*delta_temperature* \
				(self_heat_capacity*sharer.heat_capacity/(self_heat_capacity+sharer.heat_capacity))

			self_temperature_delta = -heat/(self_heat_capacity*src.group_multiplier)
			sharer_temperature_delta = heat/sharer.heat_capacity
	else
		return TRUE

	if((abs(self_temperature_delta) > MINIMUM_TEMPERATURE_DELTA_TO_SUSPEND) \
		&& (abs(self_temperature_delta) > MINIMUM_TEMPERATURE_RATIO_TO_SUSPEND*src.ARCHIVED(temperature)))
		return FALSE

	src.temperature += self_temperature_delta
	sharer.temperature += sharer_temperature_delta

	return TRUE
	//Logic integrated from: temperature_turf_share(sharer, conduction_coefficient) for efficiency

/// Similar to [/datum/gas_mixture/proc/check_me_then_temperature_share] except the model is not modified.
/datum/gas_mixture/proc/check_me_then_temperature_mimic(turf/model, conduction_coefficient)
	var/delta_temperature = (src.ARCHIVED(temperature) - model.temperature)
	var/self_temperature_delta = 0

	if(abs(delta_temperature) > MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER)
		var/self_heat_capacity = HEAT_CAPACITY_ARCHIVED(src)

		if((model.heat_capacity > MINIMUM_HEAT_CAPACITY) && (self_heat_capacity > MINIMUM_HEAT_CAPACITY))
			var/heat = conduction_coefficient*delta_temperature* \
				(self_heat_capacity*model.heat_capacity/(self_heat_capacity+model.heat_capacity))

			self_temperature_delta = -heat/(self_heat_capacity*src.group_multiplier)

	if((abs(self_temperature_delta) > MINIMUM_TEMPERATURE_DELTA_TO_SUSPEND) \
		&& (abs(self_temperature_delta) > MINIMUM_TEMPERATURE_RATIO_TO_SUSPEND*src.ARCHIVED(temperature)))
		return FALSE

	src.temperature += self_temperature_delta

	return TRUE
	//Logic integrated from: temperature_mimic(model, conduction_coefficient) for efficiency

/// Conducts heat between gases.
/// Conduction_coefficient is a multiplier that determines how well heat equalises, with 0 meaning no heat and 1 meaning perfect equalisation.
/datum/gas_mixture/proc/temperature_share(datum/gas_mixture/sharer, conduction_coefficient)
	var/delta_temperature = (src.ARCHIVED(temperature) - sharer.ARCHIVED(temperature))
	if(abs(delta_temperature) > MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER)
		var/self_heat_capacity = HEAT_CAPACITY_ARCHIVED(src)
		var/sharer_heat_capacity = HEAT_CAPACITY_ARCHIVED(sharer)

		if((sharer_heat_capacity > MINIMUM_HEAT_CAPACITY) && (self_heat_capacity > MINIMUM_HEAT_CAPACITY))
			var/heat = conduction_coefficient*delta_temperature* \
				(self_heat_capacity*sharer_heat_capacity/(self_heat_capacity+sharer_heat_capacity))

			src.temperature -= heat/(self_heat_capacity*src.group_multiplier)
			sharer.temperature += heat/(sharer_heat_capacity*sharer.group_multiplier)

/// Similar to [/datum/gas_mixture/proc/temperature_share] except the model is not modified.
/datum/gas_mixture/proc/temperature_mimic(turf/model, conduction_coefficient, border_multiplier)
	var/delta_temperature = (src.temperature - model.temperature)
	if(abs(delta_temperature) > MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER)
		var/self_heat_capacity = HEAT_CAPACITY(src)

		if((model.heat_capacity > MINIMUM_HEAT_CAPACITY) && (self_heat_capacity > MINIMUM_HEAT_CAPACITY))
			var/heat = conduction_coefficient*delta_temperature* \
				(self_heat_capacity*model.heat_capacity/(self_heat_capacity+model.heat_capacity))

			if(border_multiplier)
				src.temperature -= heat*border_multiplier/(self_heat_capacity*src.group_multiplier)
			else
				src.temperature -= heat/(self_heat_capacity*src.group_multiplier)

/// Shares heat between turfs, with conduction_coefficient as heat transfer efficiency factor.
/datum/gas_mixture/proc/temperature_turf_share(turf/simulated/sharer, conduction_coefficient)
	var/delta_temperature = (src.ARCHIVED(temperature) - sharer.temperature)
	if(abs(delta_temperature) > MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER)
		var/self_heat_capacity = HEAT_CAPACITY(src)

		if((sharer.heat_capacity > MINIMUM_HEAT_CAPACITY) && (self_heat_capacity > MINIMUM_HEAT_CAPACITY))
			var/heat = conduction_coefficient*delta_temperature* \
				(self_heat_capacity* sharer.heat_capacity /(self_heat_capacity+sharer.heat_capacity))

			src.temperature -= heat/(self_heat_capacity*src.group_multiplier)
			sharer.temperature += heat/sharer.heat_capacity

/// * Compares sample to src to see if within acceptable ranges that group processing may be enabled
/// * Returns: TRUE if within range, FALSE if outside range.
/datum/gas_mixture/proc/compare(datum/gas_mixture/sample)
	if (!sample)
		return FALSE
	#define _COMPARE_GAS(GAS, ...) \
		if((abs(GAS-sample.GAS) > MINIMUM_AIR_TO_SUSPEND) && \
			((GAS < (1-MINIMUM_AIR_RATIO_TO_SUSPEND)*sample.GAS) || (GAS > (1+MINIMUM_AIR_RATIO_TO_SUSPEND)*sample.GAS))) \
			{ return FALSE; }
	APPLY_TO_GASES(_COMPARE_GAS)
	#undef _COMPARE_GAS

	if((TOTAL_MOLES(src)) > MINIMUM_AIR_TO_SUSPEND)
		if((abs(temperature-sample.temperature) > MINIMUM_TEMPERATURE_DELTA_TO_SUSPEND) && \
			((temperature < (1-MINIMUM_TEMPERATURE_RATIO_TO_SUSPEND)*sample.temperature) || (temperature > (1+MINIMUM_TEMPERATURE_RATIO_TO_SUSPEND)*sample.temperature)))
			return FALSE

	return TRUE

/// Checks for, ya know, if the mixture is potentially dangerous.
/datum/gas_mixture/proc/check_if_dangerous()
	if(TOTAL_MOLES(src) && (temperature > T100C || src.temperature < T0C || toxins || farts || carbon_dioxide || (nitrogen && !oxygen)))
		return TRUE
	else
		return FALSE
