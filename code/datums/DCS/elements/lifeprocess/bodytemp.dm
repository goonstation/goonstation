/datum/element/lifeprocess/bodytemp/process(mob/living/target, mult, datum/gas_mixture/environment)
	if (!environment)
		return

	var/loc_temp = src.get_loc_temp(target, environment, mult)

	// Alive mobs slowly return to their base body temperature.
	if (!isdead(target))
		target.bodytemperature = target.adjustBodyTemp(target.bodytemperature, target.base_body_temp, 1, target.thermoregulation_mult)

	// Calculate thermal protection. Return early if the target has any resistances to the current temperature differential.
	var/thermal_protection = 0
	if (loc_temp < target.base_body_temp)
		if (target.is_cold_resistant())
			return

		thermal_protection = target.get_cold_protection()

	else
		if (target.is_heat_resistant())
			return

		thermal_protection = target.get_heat_protection()

	// Move the target's body temperature towards the loc temperature.
	var/thermal_divisor = (100 - thermal_protection) * 0.01
	target.bodytemperature = target.adjustBodyTemp(target.bodytemperature, loc_temp, thermal_divisor, target.innate_temp_resistance)

	if (istype(target.loc, /obj/machinery/atmospherics/unary/cryo_cell))
		return

	// Shivering status chance.
	var/diff = target.base_body_temp - (target.bodytemperature + target.temp_tolerance)
	if (isalive(target) && (diff > 0) && !target.is_cold_resistant())
		var/scaling_factor = max((target.base_body_temp - T0C) * 6, 1)
		var/chance = clamp(round((diff / scaling_factor) * 100), 1, 100)
		if (probmult(chance))
			target.changeStatus("shivering", lerp(chance / 100, 1, 0.25) * 6 SECONDS)
	else
		target.delStatus("shivering")

	// Handle heat damage when the target is outside of their tolerance.
	// Mobs are given a fair bit of leeway so they don't just start dying, as that's no fun.
	var/tolerance = target.temp_tolerance * 1.7
	var/upper_tolerance = target.base_body_temp + tolerance
	var/lower_tolerance = target.base_body_temp - tolerance
	var/env_temperature = environment.temperature
	if ( \
		((target.bodytemperature > upper_tolerance) && (env_temperature > upper_tolerance)) || \
		((target.bodytemperature < lower_tolerance) && (env_temperature < lower_tolerance)) \
	)
		var/is_resistant = (target.base_body_temp > env_temperature) \
			? (target.is_cold_resistant() || HAS_ATOM_PROPERTY(target, PROP_MOB_SPACE_DAMAGE_IMMUNE)) \
			: (target.is_heat_resistant())

		if (!is_resistant)
			var/heat_capacity = astype(target.loc, /turf/space)?.heat_capacity || HEAT_CAPACITY(environment)
			var/discomfort = min(abs(env_temperature - target.bodytemperature) * heat_capacity * thermal_divisor / 2000000, 1) * mult
			if (discomfort >= 0.1) // Stop corpses eternally twitching.
				target.TakeDamage("head",	0, discomfort * 2.5, 0, DAMAGE_BURN)
				target.TakeDamage("chest",	0, discomfort * 2.5, 0, DAMAGE_BURN)
				target.TakeDamage("l_leg",	0, discomfort * 0.6, 0, DAMAGE_BURN)
				target.TakeDamage("r_leg",	0, discomfort * 0.6, 0, DAMAGE_BURN)
				target.TakeDamage("l_arm",	0, discomfort * 0.4, 0, DAMAGE_BURN)
				target.TakeDamage("r_arm",	0, discomfort * 0.4, 0, DAMAGE_BURN)

		for (var/atom/A in target.contents)
			A.material_trigger_on_temp(env_temperature)

		for (var/atom/A as anything in target.equipped())
			A.material_trigger_on_temp(env_temperature)

/// Returns the temperature of the target's loc.
/datum/element/lifeprocess/bodytemp/proc/get_loc_temp(mob/living/target, datum/gas_mixture/environment, mult)
	var/atom/A = target.loc
	if (istype(A, /turf/space))
		var/turf/space/T = A
		return T.temperature

	else if (istype(A, /obj/machinery/vehicle))
		var/obj/machinery/vehicle/ship = A
		var/obj/item/shipcomponent/life_support/life_support_part = ship.get_part(POD_PART_LIFE_SUPPORT)
		if (life_support_part?.active)
			return life_support_part.tempreg

	else if (istype(A, /obj/vehicle))
		var/obj/vehicle/vehicle = A
		if (vehicle.sealed_cabin)
			return T20C

	else if (istype(A, /obj/machinery/atmospherics/unary/cryo_cell))
		var/obj/machinery/atmospherics/unary/cryo_cell/cryo_cell = A
		return cryo_cell.air_contents.temperature

	else if (istype(A, /obj/icecube))
		var/obj/icecube/ice = A
		if (ice.does_cooling)
			if (target.bodytemperature > ice.melttemp)
				ice.takeDamage(1 * mult)
			else if (environment.temperature > ice.melttemp)
				ice.takeDamage(0.5 * mult)

			return ice.cooltemp

	return environment.temperature
