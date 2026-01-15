/obj/machinery/gravity_tether/set_broken()
	. = ..()
	if (.)
		return .
	if (src.wire_state == TETHER_WIRES_INTACT)
		src.wire_state = TETHER_WIRES_BURNED
		src.update_ma_wires()
	src.random_fault(src.calculate_fault_chance(50))
	src.glitching_out = TRUE

	src.UpdateParticles(new/particles/rack_smoke, "broken_smoke")
	if (istype(src,  /obj/machinery/gravity_tether/station))
		src.UpdateParticles(new/particles/station_tether_spark, "broken_spark")
	else
		src.UpdateParticles(new/particles/rack_spark, "broken_spark")

	src.update_ma_graviton()
	src.update_ma_screen()
	src.update_ma_dials()
	src.update_ma_status()
	src.UpdateIcon()

/obj/machinery/gravity_tether/was_deconstructed_to_frame(mob/user)
	if (src.gforce_intensity)
		boutput(user, SPAN_ALERT("[src] cannot be deconstructed while it is still providing gravity!"))
	logTheThing(LOG_STATION, user, "<b>deconstructed</b> gravity tether [constructName(src)]")
	. = ..()

/obj/machinery/gravity_tether/was_built_from_frame(mob/user, newly_built)
	. = ..()
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WELDER | DECON_WIRECUTTERS | DECON_MULTITOOL | DECON_WRENCH

/obj/machinery/gravity_tether/process(mult)
	. = ..()
	if (!istype(src.loc, /turf/simulated))
		if (src.processing_state == TETHER_PROCESSING_PENDING)
			src.finish_gravity_change()
		if (src.gforce_intensity != 0)
			src.say("Contact with stable ground lost.")
			src.change_intensity(0)
		return

	src.handle_power_cycle()

	if (src.has_no_power())
		if (src.processing_state == TETHER_PROCESSING_PENDING)
			src.finish_gravity_change()
		return

	if (src.glitching_out)
		var/malf_chance = src.calculate_fault_chance()
		if (prob(malf_chance) && !ON_COOLDOWN(src, "passive_malfunction", rand(50, 70) SECONDS))
			// fault severity chance increases as fault chance goes up
			src.random_fault(malf_chance)

	if (src.disturbed_end_time && TIME > src.disturbed_end_time)
		src.disturbed_end_time = null
		src.update_ma_graph()
		src.UpdateIcon()

	if (src.processing_state == TETHER_PROCESSING_PENDING)
		if (TIME > src.change_begin_time)
			src.change_intensity(src.target_intensity)
			src.finish_gravity_change()
			playsound(src.loc, 'sound/machines/sweep.ogg', 40, pitch=(0.5 + (src.gforce_intensity/2)))
		else
			playsound(src.loc, 'sound/machines/found.ogg', 60, 0)
	else if (src.processing_state == TETHER_PROCESSING_COOLDOWN)
		if (TIME > src.cooldown_end_time)
			src.cooldown_end_time = null
			src.processing_state = TETHER_PROCESSING_STABLE

			src.update_ma_status()
			src.update_ma_screen()
			src.update_ma_dials()

			src.UpdateIcon()
	else if (prob(src.gforce_intensity))
		playsound(src.loc, pick(global.ambience_gravity), 50, 1, pitch=(0.5 + (src.gforce_intensity/2)))

/// The gravity tether prioritizes its own internal capacitor
/obj/machinery/gravity_tether/use_power(amount, chan)
	// convert powernet wattage to cell usage
	var/battery_usage = CELLRATE * amount

	// use the internal battery first
	if (src.cell && src.cell.charge < battery_usage)
		src.use_cell_wrapper(src.cell.charge)
		amount -= src.cell.charge / CELLRATE
		var/area/A = get_area(src)
		if (A.powered(EQUIP))
			..(amount)
		else
			src.power_change()
	else
		src.use_cell_wrapper(battery_usage)


/obj/machinery/gravity_tether/power_change()
	if(src.has_no_power())
		status |= NOPOWER
	else
		status &= ~NOPOWER
	src.UpdateIcon()

/obj/machinery/gravity_tether/has_no_power()
	if (istype(src.loc, /obj/item/electronics/frame)) //if in a frame, we are never powered
		return TRUE
	if (src.cell?.charge > (src.passive_wattage_per_g * src.gforce_intensity))
		return FALSE
	. = ..()

/// Handle power billing and internal cell charging
///
/// Uses area power until 40%, then internal cell, then area power
/obj/machinery/gravity_tether/proc/handle_power_cycle()
	var/area/A = get_area(src)
	var/passive_wattage_needed = src.passive_wattage_per_g * src.gforce_intensity
	var/recharge_wattage_needed = 0

	if (src.cell)
		// calculate how much to charge up based on the standard cell charge rate, in watts
		recharge_wattage_needed = min(
			(src.cell.maxcharge - src.cell.charge),
			(src.cell.maxcharge * CHARGELEVEL * PROCESSING_TIER_MULTI(src) / 4)
		) / CELLRATE

	if (passive_wattage_needed)
		if (src.cell)
			var/available_cell_watts = src.cell.charge / CELLRATE
			if (passive_wattage_needed && available_cell_watts > passive_wattage_needed)
				if(src.use_cell_wrapper(passive_wattage_needed * CELLRATE))
					passive_wattage_needed = 0

	if (passive_wattage_needed || recharge_wattage_needed)
		if (A.powered(EQUIP))
			var/obj/machinery/power/apc/area_apc = A?.area_apc
			if (istype(area_apc) && area_apc.cell?.charge)
				var/available_area_watts = area_apc.cell?.charge / CELLRATE
				if (passive_wattage_needed && available_area_watts > passive_wattage_needed)
					area_apc.use_power(passive_wattage_needed, EQUIP)
					available_area_watts -= passive_wattage_needed
					passive_wattage_needed = 0
				if (!passive_wattage_needed && recharge_wattage_needed && available_area_watts > recharge_wattage_needed && area_apc.cell?.percent() > 40 )
					if(src.give_cell_wrapper(recharge_wattage_needed * CELLRATE))
						area_apc.use_power(recharge_wattage_needed, EQUIP)
						recharge_wattage_needed = 0

	if (passive_wattage_needed) // no power, keel over
		src.power_change()

	if (src.cell)
		var/new_charging_state = TETHER_CHARGE_IDLE
		var/new_charge_pct_state = null
		switch (src.cell.percent())
			if (TETHER_BATTERY_CHARGE_FULL to INFINITY)
				new_charge_pct_state = TETHER_BATTERY_CHARGE_FULL
			if (-INFINITY to 0)
				new_charge_pct_state = 0
			if (-INFINITY to TETHER_BATTERY_CHARGE_MEDIUM)
				new_charge_pct_state = TETHER_BATTERY_CHARGE_LOW
			if (TETHER_BATTERY_CHARGE_MEDIUM to TETHER_BATTERY_CHARGE_HIGH)
				new_charge_pct_state = TETHER_BATTERY_CHARGE_MEDIUM
			if (TETHER_BATTERY_CHARGE_HIGH to TETHER_BATTERY_CHARGE_FULL)
				new_charge_pct_state = TETHER_BATTERY_CHARGE_HIGH

		if (src.cell.charge == src.last_charge_amount)
			new_charging_state = TETHER_CHARGE_IDLE
		if (src.cell.charge > src.last_charge_amount)
			new_charging_state = TETHER_CHARGE_CHARGING
			src.last_charge_amount = src.cell.charge
		else if (src.cell.charge < src.last_charge_amount)
			new_charging_state = TETHER_CHARGE_DRAINING
			src.last_charge_amount = src.cell.charge

		if (src.charge_pct_state != new_charge_pct_state || src.charging_state != new_charging_state)
			src.charge_pct_state = new_charge_pct_state
			src.charging_state = new_charging_state
			src.update_ma_bat()
			src.update_ma_cell()

/// Wrapper for using the internal cell, needed to interrupt the default rigged effect
/obj/machinery/gravity_tether/proc/use_cell_wrapper(amount)
	if (!src.cell)
		return FALSE

	if (amount == 0)
		return TRUE

	if(src.cell.rigged)
		src.cell_rig_effect()
		return FALSE

	src.cell.use(amount)
	if (global.zamus_dumb_power_popups)
		new /obj/maptext_junk/power(get_turf(src), change = -amount, channel = 0)

	return TRUE

/// Wrapper for giving to the internal cell, needed to interrupt the default rigged effect
/obj/machinery/gravity_tether/proc/give_cell_wrapper(amount)
	if (!src.cell)
		return FALSE

	if (amount == 0)
		return TRUE

	if (src.cell.rigged)
		src.cell_rig_effect()
		return FALSE

	src.cell.give(amount)
	return TRUE

/// What happens to the tether when when the cell is rigged
/obj/machinery/gravity_tether/proc/cell_rig_effect()
	src.cell.rigged = FALSE
	src.door_state = TETHER_DOOR_MISSING
	src.wire_state = TETHER_WIRES_BURNED
	src.update_ma_door()
	src.update_ma_wires()
	src.set_broken()

	if (src.cell.rigger)
		message_admins("[key_name(src.cell.rigger)]'s rigged cell damaged [src] at [log_loc(src)].")
		logTheThing(LOG_COMBAT, src.cell.rigger, "'s rigged cell damaged [src] at [log_loc(src)].")

	src.visible_message(SPAN_ALERT("<b>[src]'s internal capacitor compartment explodes!</b>"), SPAN_ALERT("You hear a loud bang. That doesn't sound good."))

	var/epicenter = get_turf(src)
	playsound(epicenter, "explosion", 90, 1)

	var/turf/T = get_turf(src)
	for (var/mob/M in view(min(5, 2*src.gforce_intensity), T))
		if (M.invisibility >= INVIS_AI_EYE) continue
		arcFlash(src, M, src.cell.charge)

	SPAWN(0)
		qdel(src.cell)
		src.cell = null
		src.update_ma_cell()
		src.update_ma_bat()
		src.UpdateIcon()
