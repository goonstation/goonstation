
/datum/lifeprocess/bodytemp
	//proc/handle_environment(datum/gas_mixture/environment) //TODO : REALTIME BODY TEMP CHANGES (Mbc is too lazy to look at this mess right now)
	process(var/datum/gas_mixture/environment)
		if (!environment)
			return ..()
		var/environment_heat_capacity = HEAT_CAPACITY(environment)
		var/loc_temp = T0C
		var/mult = get_multiplier()
		if (istype(owner.loc, /turf/space))
			var/turf/space/S = owner.loc
			environment_heat_capacity = S.heat_capacity
			loc_temp = S.temperature
		else if (istype(owner.loc, /obj/machinery/vehicle))
			var/obj/machinery/vehicle/ship = owner.loc
			if (ship.life_support)
				if (ship.life_support.active)
					loc_temp = ship.life_support.tempreg
				else
					loc_temp = environment.temperature
		// why am i repeating this shit?
		else if (istype(owner.loc, /obj/vehicle))
			var/obj/vehicle/V = owner.loc
			if (V.sealed_cabin)
				loc_temp = T20C // hardcoded honkytonk nonsense
			else
				loc_temp = environment.temperature
		else if (istype(owner.loc, /obj/machinery/atmospherics/unary/cryo_cell))
			var/obj/machinery/atmospherics/unary/cryo_cell/C = owner.loc
			loc_temp = C.air_contents.temperature
		else if (istype(owner.loc,/obj/icecube))
			var/obj/icecube/ice = owner.loc
			if (!ice.does_cooling)
				return
			loc_temp = ice.cooltemp// ice go brrrrrrrrr
			if (owner.bodytemperature > ice.melttemp)
				ice.takeDamage(1 * mult)
			else if (environment.temperature > ice.melttemp)
				ice.takeDamage(0.5 * mult)
		else
			loc_temp = environment.temperature

		var/thermal_protection
		if (!isdead(owner))
			owner.bodytemperature = owner.adjustBodyTemp(owner.bodytemperature, owner.base_body_temp, 1 ,owner.thermoregulation_mult)
		if (loc_temp < owner.base_body_temp) // a cold place -> add in cold protection
			if (owner.is_cold_resistant())
				return ..()
			thermal_protection = owner.get_cold_protection()
		else // a hot place -> add in heat protection
			if (owner.is_heat_resistant())
				return ..()
			thermal_protection = owner.get_heat_protection()
		var/thermal_divisor = (100 - thermal_protection) * 0.01
		owner.bodytemperature = owner.adjustBodyTemp(owner.bodytemperature,loc_temp, thermal_divisor, owner.innate_temp_resistance)

		if (istype(owner.loc, /obj/machinery/atmospherics/unary/cryo_cell))
			return ..()

		//shivering status chance
		if (isalive(owner) && ((owner.bodytemperature + owner.temp_tolerance) < owner.base_body_temp) && !owner.is_cold_resistant())
			var/diff = owner.base_body_temp - (owner.bodytemperature + owner.temp_tolerance)
			var/scaling_factor = max((owner.base_body_temp - T0C)*6,1)
			var/chance = round((diff/scaling_factor)*100)
			chance = clamp(chance,0,100)
			if(probmult(chance))
				owner.changeStatus("shivering", lerp(chance/100, 1, 0.25) * 6 SECONDS)
		else
			owner.delStatus("shivering")

		// lets give them a fair bit of leeway so they don't just start dying
		//as that may be realistic but it's no fun
		if ((owner.bodytemperature > owner.base_body_temp + (owner.temp_tolerance * 1.7) && environment.temperature > owner.base_body_temp + (owner.temp_tolerance * 1.7)) || (owner.bodytemperature < owner.base_body_temp - (owner.temp_tolerance * 1.7) && environment.temperature < owner.base_body_temp - (owner.temp_tolerance * 1.7)))

			//Yep this means that the damage is no longer per limb. Restore this to per limb eventually. See above.
			owner.handle_temperature_damage(LEGS, environment.temperature, environment_heat_capacity*thermal_divisor, mult)
			owner.handle_temperature_damage(TORSO,environment.temperature, environment_heat_capacity*thermal_divisor, mult)
			owner.handle_temperature_damage(HEAD, environment.temperature, environment_heat_capacity*thermal_divisor, mult)
			owner.handle_temperature_damage(ARMS, environment.temperature, environment_heat_capacity*thermal_divisor, mult)

			for (var/atom/A in owner.contents)
				A.material_trigger_on_temp(environment.temperature)

			for (var/atom/equipped_stuff in owner.equipped())
				equipped_stuff.material_trigger_on_temp(environment.temperature)

		// decoupled this from environmental temp - this should be more for hypothermia/heatstroke stuff
		//if (src.bodytemperature > src.base_body_temp || src.bodytemperature < src.base_body_temp)

		//Account for massive pressure differences
		//TODO: DEFERRED
		..()


/mob/living/proc/handle_temperature_damage(body_part, exposed_temperature, exposed_intensity, mult)
	if (exposed_temperature > src.base_body_temp && src.is_heat_resistant())
		return
	if (exposed_temperature < src.base_body_temp && (src.is_cold_resistant() || src.space_damage_immune))
		return
	var/discomfort = min(abs(exposed_temperature - bodytemperature)*(exposed_intensity)/2000000, 1)

	if (discomfort * mult < 0.1) //stop corpses eternally twitching
		return

	switch(body_part)
		if (HEAD)
			TakeDamage("head", 0, 2.5*discomfort*mult, 0, DAMAGE_BURN)
		if (TORSO)
			TakeDamage("chest", 0, 2.5*discomfort*mult, 0, DAMAGE_BURN)
		if (LEGS)
			TakeDamage("l_leg", 0, 0.6*discomfort*mult, 0, DAMAGE_BURN)
			TakeDamage("r_leg", 0, 0.6*discomfort*mult, 0, DAMAGE_BURN)
		if (ARMS)
			TakeDamage("l_arm", 0, 0.4*discomfort*mult, 0, DAMAGE_BURN)
			TakeDamage("r_arm", 0, 0.4*discomfort*mult, 0, DAMAGE_BURN)
