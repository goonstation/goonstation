/obj/machinery/gravity_tether/proc/take_significant_damage(probability)
	if (!prob(probability))
		return
	animate_shake(src)
	if (src.door_state == TETHER_DOOR_WELDED || src.door_state == TETHER_DOOR_CLOSED)
		src.visible_message(SPAN_ALERT("The door on \the [src] is flung right off its hinges!"))
		playsound(src.loc, 'sound/impact_sounds/Metal_Hit_Light_1.ogg', 50, TRUE)
		src.door_state = TETHER_DOOR_MISSING
		src.update_ma_door()
		var/obj/item/sheet/steel/sheet = new(get_turf(src))
		var/turf/T = get_edge_target_turf(src, SOUTH)
		sheet.throw_at(T,rand(0,5),rand(1,3))
	else if (src.locked && src.tamper_intact == TRUE)
		src.visible_message(SPAN_ALERT("The tamper-resist grate on \the [src] is destroyed!"))
		playsound(src.loc, 'sound/impact_sounds/Metal_Hit_Light_1.ogg', 50, TRUE, extrarange=2)
		src.tamper_intact = FALSE
		src.update_ma_tamper()
	else if (src.cell)
		src.visible_message(SPAN_ALERT("The power cell inside \the [src] flies out!"))
		playsound(src, 'sound/effects/snaptape.ogg', 50, TRUE)
		src.cell.set_loc(get_turf(src))
		var/turf/T = get_edge_target_turf(src, SOUTH)
		src.cell.throw_at(T,rand(0,5),rand(1,3))
		src.cell = null
		src.update_ma_cell()
		src.update_ma_bat()
	else if (src.wire_state == TETHER_WIRES_INTACT || src.wire_state == TETHER_WIRES_BURNED)
		playsound(src, 'sound/effects/sparks4.ogg', 50, TRUE)
		var/datum/effects/system/spark_spread/S = new /datum/effects/system/spark_spread
		S.set_up(2, FALSE, src)
		S.start()
		src.wire_state = TETHER_WIRES_CUT
		src.update_ma_wires()
	else if (!src.is_broken())
		src.set_broken()
	else
		if (!ON_COOLDOWN(src, "damage_fault", 10 SECONDS))
			playsound(src, 'sound/effects/torpedolaunch.ogg', 30, TRUE)
			src.random_fault(probability)
	src.UpdateIcon()

/obj/machinery/gravity_tether/blob_act(power)
	if (prob(25 * power/20))
		if (src.status & BROKEN)
			qdel(src)
		else
			src.set_broken()
		return
	if (prob(power * 2))
		src.take_significant_damage(src.calculate_fault_chance(power))

// slowly breaks down
/obj/machinery/gravity_tether/bullet_act(obj/projectile/P)
	. = ..()
	if (P.power < 10)
		return .
	if (HAS_ANY_FLAGS(P.proj_data.damage_type, D_KINETIC | D_PIERCING | D_SLASHING))
		if (prob(src.calculate_fault_chance(P.power * P.proj_data.ks_ratio/2)))
			src.take_significant_damage(P.power * P.proj_data.ks_ratio/2)

	if (HAS_ANY_FLAGS(P.proj_data.damage_type, D_ENERGY | D_RADIOACTIVE) && !src.has_no_power())
		if (prob(src.calculate_fault_chance(P.power * (1-P.proj_data.ks_ratio) / 8)))
			if (src.wire_state == TETHER_WIRES_INTACT)
				playsound(src, 'sound/effects/sparks4.ogg', 50)
				var/datum/effects/system/spark_spread/S = new /datum/effects/system/spark_spread
				S.set_up(2, FALSE, src)
				S.start()
				src.wire_state = TETHER_WIRES_BURNED
				src.update_ma_wires()
				src.UpdateIcon()
			if (!ON_COOLDOWN(src, "damage_fault", 10 SECONDS))
				src.random_fault()

// a little bit resilient
/obj/machinery/gravity_tether/ex_act(severity, last_touched, power, datum/explosion/explosion)
	switch (severity)
		if(1)
			if (src.is_broken())
				if (prob(40))
					qdel(src)
					return
				else
					src.take_significant_damage(100)
			else
				if (prob(80))
					src.set_broken()
				else
					src.take_significant_damage(max(min(100, power), 80))
		if(2)
			if (src.is_broken())
				src.take_significant_damage(max(min(100, power), 60))
			else
				src.take_significant_damage(max(min(100, power), 40))
		if(3)
			src.take_significant_damage(max(min(100, power), 20))

/obj/machinery/gravity_tether/overload_act()
	. = ..()
	if (!ON_COOLDOWN(src, "overload_cooldown", 1 MINUTE))
		if (prob(src.calculate_fault_chance(6)))
			src.visible_message(SPAN_ALERT("The pylon on [src] violently shorts!"), SPAN_ALERT("You hear a sharp spark!"))
			switch (src.wire_state)
				if(TETHER_WIRES_INTACT)
					src.wire_state = TETHER_WIRES_BURNED
					src.update_ma_wires()
				if(TETHER_WIRES_CUT)
					if (src.cell)
						logTheThing(LOG_STATION, src, "shorts out via overload, causing a cell failure at [log_loc(src)].")
						src.cell_rig_effect()
			src.random_fault(src.calculate_fault_chance(6))
		else
			src.visible_message(SPAN_ALERT("The pylon on [src] briefly shorts."), SPAN_ALERT("You hear a spark."))
			src.random_fault()
		src.UpdateIcon()
		return TRUE
	return FALSE

/// emag effects:
/// * disables access requirements
/// * makes gravity change announcement optional
/// * burns out wires (greater chance to trigger random faults)
/obj/machinery/gravity_tether/emag_act(mob/user, obj/item/card/emag/E)
	. = ..()
	if(src.emagged)
		boutput(user, SPAN_NOTICE("The g-force limiter on [src] is already disabled."))
		return
	logTheThing(LOG_STATION, src, "was emagged by [user] at [log_loc(src)].")
	boutput(user, SPAN_ALERT("You slide [E] across [src]'s ID reader, breaking the g-force limiter."))
	src.locked = FALSE
	src.emagged = TRUE
	if (src.wire_state == TETHER_WIRES_INTACT)
		src.wire_state = TETHER_WIRES_BURNED
		src.update_ma_wires()
	src.UpdateIcon()

/obj/machinery/gravity_tether/demag(mob/user)
	. = ..()
	src.emagged = FALSE
