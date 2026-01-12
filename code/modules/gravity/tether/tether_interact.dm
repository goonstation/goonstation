/// How much cable coil it takes to repair the tether wiring
#define TETHER_WIRE_REPAIR_CABLE_COST 5
/// How many rods to repair the tether tamper grate
#define TETHER_TAMPER_REPAIR_ROD_COST 5

/obj/machinery/gravity_tether/receive_silicon_hotkey(mob/user)
	if (..() || !src.allowed(user) || !length(src.req_access) || !in_interact_range(src, user))
		return
	if (user.client.check_key(KEY_BOLT))
		. = 1
		if (src.emagged)
			boutput(user, SPAN_NOTICE("Unable to interface with [src]!"))
			return
		src.locked = !src.locked
		src.update_ma_screen()
		src.update_ma_tamper()
		src.UpdateIcon()

/obj/machinery/gravity_tether/attack_ai(mob/user)
	if (isAIeye(user))
		boutput(user, SPAN_ALERT("The gravity tether requires physical access!"))
		return
	. = ..()

/obj/machinery/gravity_tether/attack_hand(mob/user)
	if(..())
		return

	user.lastattacked = get_weakref(src)

	if (src.locked && !src.emagged)
		// Can't call parent for interaction checks and no acess desc for syndicate IDs on purpose.
		if (istype(src, /obj/machinery/gravity_tether/multi_area/listening_post))
			src.say("Syndicate access required.", message_params=list("group"="\ref[src]_acc"))
			return
		src.say("[get_access_desc(src.req_access[1])] access required.", message_params=list("group"="\ref[src]_acc"))
		return
	if (src.processing_state == TETHER_PROCESSING_PENDING)
		src.say("Processing shift, [src.change_begin_time-TIME > 0 ? "[time_to_text(src.change_begin_time-TIME)] remaining" : "change pending"].")
		return
	else if (src.processing_state == TETHER_PROCESSING_COOLDOWN)
		src.say("Recalibrating, [src.cooldown_end_time-TIME > 0 ? "[time_to_text(src.cooldown_end_time-TIME)] remaining" : "refresh pending"].")
		return

	var/new_intensity = tgui_input_number(user, "Running at [src.gforce_intensity]G. Change intensity?", "Gravity Tether", src.gforce_intensity, src.maximum_intensity, round_input=FALSE)
	if (isnull(new_intensity))
		return
	new_intensity = round(new_intensity, 0.01)
	if (src.glitching_out)
		new_intensity += round((prob(50) ? 1 : -1) * randfloat(0.2, 0.4), 0.01)
	if (new_intensity == src.gforce_intensity)
		boutput(user, SPAN_NOTICE("Tether already set to [new_intensity]G!"))
		return

	if (src.emagged)
		var/choice = tgui_alert(user, "Really let \the [src] announce [new_intensity]G?", "Tether Confirmation", list("Yes", "No"))
		if (isnull(choice))
			return
		if (choice == "No")
			src.do_announcement = FALSE
	else // phrased to be easily mistakeable for the emag text
		if (tgui_alert(user, "Really set \the [src] [new_intensity-src.gforce_intensity> 0 ? "upwards" : "downwards" ] to [new_intensity]G?", "Tether Confirmation", list("Yes", "No")) != "Yes")
			return

	if (in_interact_range(src, user))
		src.attempt_gravity_change(new_intensity)

/obj/machinery/gravity_tether/attackby(obj/item/I, mob/user)
	user.lastattacked = get_weakref(src)
	var/is_handy = FALSE
	if (ishuman(user))
		var/mob/living/carbon/human/H = user
		is_handy = H.traitHolder.hasTrait("carpenter") || H.traitHolder.hasTrait("training_engineer")
	if (ispryingtool(I))
		src.add_fingerprint(user)
		switch (src.door_state)
			if (TETHER_DOOR_MISSING)
				boutput(user, SPAN_NOTICE("There's no door on [src]!"))
			if (TETHER_DOOR_OPEN)
				if (src.locked)
					user.visible_message(
						SPAN_NOTICE("[user] [pick("loudly", "quickly")] close the door on [src]!"),
						SPAN_NOTICE("You [pick("loudly", "quickly")] close the door on [src]!"),
						SPAN_NOTICE("A hollow metal clang rings out!")
					)
					playsound(src.loc, 'sound/misc/safe_close.ogg', 60)
				else
					user.visible_message(
						SPAN_REGULAR("The door on [src] is closed by [user]."),
						SPAN_REGULAR("You close the door on [src]."),
						SPAN_REGULAR("You hear a solid metal thunk.")
					)
					playsound(src.loc, 'sound/misc/locker_close.ogg', 30)
				src.door_state = TETHER_DOOR_CLOSED
				src.update_ma_door()
				src.UpdateIcon()
			if (TETHER_DOOR_CLOSED)
				if (src.locked)
					var/duration = 2 SECONDS / (is_handy ? 2 : 1)
					playsound(src, 'sound/machines/airlock_pry.ogg', 35, TRUE)
					SETUP_GENERIC_ACTIONBAR_WIDE(user, src, duration, /obj/machinery/gravity_tether/proc/door_force_open, list(I, user), \
					I.icon, I.icon_state, null, INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_ATTACKED | INTERRUPT_STUNNED | INTERRUPT_ACTION)
				else
					user.visible_message(
						SPAN_NOTICE("The door on [src] is opened by [user]."),
						SPAN_NOTICE("You open the door on [src]."),
						SPAN_ALERT("You hear the creak of a metal door.")
					)
					playsound(src.loc, 'sound/misc/locker_open.ogg', 30)
					src.door_state = TETHER_DOOR_OPEN
					src.update_ma_door()
					src.UpdateIcon()
			if (TETHER_DOOR_WELDED)
				boutput (user, SPAN_NOTICE("The door on [src] is welded shut!"))
		return

	if (isweldingtool(I))
		switch (src.door_state)
			if (TETHER_DOOR_OPEN)
				boutput(user, SPAN_NOTICE("The door on [src] must be closed before welding it shut."))
				return
			if (TETHER_DOOR_MISSING)
				boutput(user, SPAN_NOTICE("There's no door on [src] to weld!"))
				return

		if(I:try_weld(user, 1, burn_eyes = 1))
			var/positions = src.get_welding_positions()
			actions.start(new /datum/action/bar/private/welding(user, src, 2 SECONDS, /obj/machinery/gravity_tether/proc/weld_action, \
							list(user), "[user] finishes using [his_or_her(user)] [I.name] on [src].", positions[1], positions[2]),user)
		return

	if (src.door_state == TETHER_DOOR_OPEN || src.door_state == TETHER_DOOR_MISSING)

		// tamper repair grate
		if (istype(I, /obj/item/rods) && src.locked && !src.tamper_intact)
			if (I.amount < TETHER_TAMPER_REPAIR_ROD_COST)
				boutput(user, SPAN_NOTICE("You need [TETHER_TAMPER_REPAIR_ROD_COST] rods to restore the tamper-grate on [src]."))
				return
			var/duration = 5 SECONDS / (is_handy ? 2 : 1)
			user.visible_message(
				SPAN_NOTICE("[user] begins repairing [src]'s tamper-resist security grate."),
				SPAN_NOTICE("You begin repairing the tamper-resist security grate on [src]."),
			)
			SETUP_GENERIC_ACTIONBAR_WIDE(user, src, duration, /obj/machinery/gravity_tether/proc/tamper_repair, list(I, user), \
			I.icon, I.icon_state, null, INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_ATTACKED | INTERRUPT_STUNNED | INTERRUPT_ACTION)
			return

		// destroy tamper grate
		if ((issawingtool(I)) && src.locked && src.tamper_intact)
			var/duration = 20 SECONDS / (is_handy ? 2 : 1)
			playsound(src.loc, 'sound/items/mining_drill.ogg', 50, 1, extrarange=1)
			user.visible_message(
				SPAN_COMBAT("[user] begins cutting into [src]'s tamper-resist security grate!"),
				SPAN_COMBAT("You begin cutting into [src]'s tamper-resist security grate!"),
				SPAN_COMBAT("You hear the awful sound of metal grinding on metal."),
			)
			SETUP_GENERIC_ACTIONBAR_WIDE(user, src, duration, /obj/machinery/gravity_tether/proc/tamper_destroy, list(I, user), \
			I.icon, I.icon_state, null, INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_ATTACKED | INTERRUPT_STUNNED | INTERRUPT_ACTION)
			return

		// battery and wiring
		if (!(src.locked && src.tamper_intact))
			if (src.cell)
				// take cell
				if (iswrenchingtool(I))
					var/duration = 5 SECONDS / (is_handy ? 2 : 1)
					playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
					user.visible_message(
						SPAN_ALERT("[user] begins removing the interal cell from [src]!"),
						SPAN_ALERT("You begin removing the interal battery from [src]!"),
						SPAN_ALERT("You hear the loosening of heavy-duty bolts.")
					)
					SETUP_GENERIC_ACTIONBAR_WIDE(user, src, duration, /obj/machinery/gravity_tether/proc/cell_remove, list(I, user), \
					I.icon, I.icon_state, null, INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_ATTACKED | INTERRUPT_STUNNED | INTERRUPT_ACTION)
					return
			else
				// give cell
				if (istype(I, /obj/item/cell))
					var/duration = 5 SECONDS / (is_handy ? 2 : 1)
					user.visible_message(
						SPAN_NOTICE("[user] begins installing [I] into [src]."),
						SPAN_NOTICE("You begin installing [I] into [src]."),
					)
					SETUP_GENERIC_ACTIONBAR_WIDE(user, src, duration, /obj/machinery/gravity_tether/proc/cell_install, list(I, user), \
					I.icon, I.icon_state, null, INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_ATTACKED | INTERRUPT_STUNNED | INTERRUPT_ACTION)
					return

				// cut out wires
				if(src.wire_state != TETHER_WIRES_CUT && (iscuttingtool(I) || issnippingtool(I)))
					var/shockdmg = user.shock(src, src.gforce_intensity * (src.processing_state ? src.active_wattage_per_g : src.passive_wattage_per_g), user.hand == LEFT_HAND ? "l_arm": "r_arm")
					if (prob(min(shockdmg, 100)))
						return
					var/duration = 8 SECONDS / (is_handy ? 2 : 1)
					user.visible_message(
						SPAN_ALERT("[user] begins cutting some important wires out of [src]."),
						SPAN_ALERT("You begin cutting some important wires out of [src]."),
					)
					playsound(src.loc, 'sound/items/Scissor.ogg', 60, TRUE)
					SETUP_GENERIC_ACTIONBAR_WIDE(user, src, duration, /obj/machinery/gravity_tether/proc/wire_snip, list(I, user), \
					I.icon, I.icon_state, null, INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_ATTACKED | INTERRUPT_STUNNED | INTERRUPT_ACTION)
					return

				// repair wires
				if (src.wire_state == TETHER_WIRES_CUT && istype(I, /obj/item/cable_coil))
					if (I.amount < TETHER_WIRE_REPAIR_CABLE_COST)
						boutput(user, SPAN_NOTICE("You need [TETHER_WIRE_REPAIR_CABLE_COST] lengths of cable to fix the wiring on [src]."))
						return
					var/duration = 10 SECONDS / (is_handy ? 2 : 1)
					user.visible_message(
						SPAN_NOTICE("[user] begins repairing the wiring in [src]."),
						SPAN_NOTICE("You begin repairing the wiring in [src]."),
					)
					playsound(src.loc, 'sound/items/penclick.ogg', 60, TRUE)
					SETUP_GENERIC_ACTIONBAR_WIDE(user, src, duration, /obj/machinery/gravity_tether/proc/wire_repair, list(I, user), \
					I.icon, I.icon_state, null, INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_ATTACKED | INTERRUPT_STUNNED | INTERRUPT_ACTION)
					return

		// repair door
		if (src.door_state == TETHER_DOOR_MISSING)
			if (istype(I, /obj/item/sheet))
				if (I.change_stack_amount(-1))
					user.visible_message(
						SPAN_REGULAR("[user] repairs the door on [src]"),
						SPAN_REGULAR("You repair the door on [src]."),
						SPAN_REGULAR("The click of metal sheet attaching to something rings out.")
					)
					playsound(src.loc, 'sound/items/crowbar.ogg', 60, TRUE)
					src.door_state = TETHER_DOOR_OPEN
					src.update_ma_door()

	if (src.has_no_power())
		return ..()

	var/obj/item/card/id/id_card = get_id_card(I)
	if (istype(id_card) && length(src.req_access))
		if (src.allowed(user))
			src.locked = !src.locked
			src.update_ma_tamper()
			src.update_ma_screen()
			src.UpdateIcon()
		else
			src.say("[get_access_desc(src.req_access[1])] access required to [src.locked ? "un" : ""]lock.", message_params=list("group"="\ref[src]_acc"))
		return
	. = ..()


// use tool on tether callback procs

/obj/machinery/gravity_tether/proc/door_force_open(obj/item/I, mob/user)
	if (src.door_state == TETHER_DOOR_OPEN)
		return
	user.visible_message(
		SPAN_ALERT("[user] [pick("brutishly", "crudely", "forcefully")] pries open the door on [src]!"),
		SPAN_ALERT("You [pick("brutishly", "crudely", "forcefully")] open the door on [src]!"),
		SPAN_ALERT("A loud metal thud rings out!")
	)
	playsound(src.loc, 'sound/misc/safe_open.ogg', 70)
	src.door_state = TETHER_DOOR_OPEN
	src.update_ma_door()
	src.UpdateIcon()

/obj/machinery/gravity_tether/proc/tamper_destroy(obj/item/I, mob/user)
	if (!src.tamper_intact)
		return

	user.visible_message(
		SPAN_ALERT("The tamper-resist grate inside [src] is brutally sliced through by [user]."),
		SPAN_ALERT("You destroy the tamper-resist grate inside [src]."),
		SPAN_ALERT("You hear the sound of tough metal being cut through.")
	)
	logTheThing(LOG_STATION, user, "destroyed the tamper-resist grate on [src].")
	playsound(src.loc, 'sound/impact_sounds/Metal_Hit_Light_1.ogg', 50, 1, extrarange=2)
	src.tamper_intact = FALSE
	src.update_ma_tamper()
	src.UpdateIcon()
	return

/obj/machinery/gravity_tether/proc/tamper_repair(obj/item/I, mob/user)
	if (src.tamper_intact)
		return
	if (user.equipped() != I)
		return
	var/obj/item/rods/rods = I
	if (!istype(rods))
		return
	if (!rods.change_stack_amount(-TETHER_TAMPER_REPAIR_ROD_COST))
		return
	user.visible_message(
		SPAN_NOTICE("The tamper-resist grate inside [src] has been reassembled by [user]."),
		SPAN_NOTICE("You reassemble the tamper-resist grate inside [src]."),
	)
	playsound(src.loc, 'sound/impact_sounds/Metal_Hit_Light_1.ogg', 30, 1)
	src.tamper_intact = TRUE
	src.update_ma_tamper()
	src.UpdateIcon()

/obj/machinery/gravity_tether/proc/wire_snip(obj/item/I, mob/user)
	if (src.wire_state == TETHER_WIRES_CUT)
		return

	user.visible_message(
		SPAN_ALERT("The wires inside [src] are snipped out by [user]."),
		SPAN_ALERT("You snip out the wires inside [src]."),
	)
	logTheThing(LOG_STATION, user, "removed the [src.wire_state == TETHER_WIRES_BURNED ? "burned" : "intact"] wires on [src].")
	src.wire_state = TETHER_WIRES_CUT
	src.update_ma_wires()
	src.UpdateIcon()

/obj/machinery/gravity_tether/proc/wire_repair(obj/item/I, mob/user)
	if (src.wire_state == TETHER_WIRES_INTACT)
		return
	if (!user || !I || (user.equipped() != I))
		return
	var/obj/item/cable_coil/cable = I
	if (!istype(cable))
		return
	if (!cable.change_stack_amount(-TETHER_WIRE_REPAIR_CABLE_COST))
		return

	user.visible_message(
		SPAN_NOTICE("The wires inside [src] are repaired out by [user]."),
		SPAN_NOTICE("You repair the wires inside [src]."),
	)

	src.wire_state = TETHER_WIRES_INTACT
	src.status &= ~BROKEN
	src.glitching_out = FALSE
	src.power_change()

	src.update_ma_wires()
	src.update_ma_graviton()
	src.update_ma_screen()
	src.update_ma_dials()
	src.UpdateIcon()

	src.ClearAllParticles()

/obj/machinery/gravity_tether/proc/cell_remove(obj/item/I, mob/user)
	if (!user || !I || (user.equipped() != I))
		return
	playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 0)
	src.cell.UpdateIcon()
	user.put_in_hand_or_drop(src.cell)
	src.charging_state = TETHER_CHARGE_IDLE
	src.cell = null
	user.visible_message(
		SPAN_NOTICE("[user] removes \the [src.cell] from \the [src]."),
		SPAN_NOTICE("You remove \the [src.cell] from \the [src].")
	)
	src.update_ma_cell()
	src.update_ma_bat()
	src.UpdateIcon()

/obj/machinery/gravity_tether/proc/cell_install(obj/item/I, mob/user)
	if (!user || !istype(I, /obj/item/cell) || (user.equipped() != I))
		return
	playsound(src.loc, 'sound/machines/click.ogg', 50, 0)
	user.u_equip(I)
	I.set_loc(src)
	src.cell = I
	user.visible_message(
		SPAN_NOTICE("[user] installs \the [I] into \the [src]."),
		SPAN_NOTICE("You install \the [I] into \the [src]."),
	)
	src.update_ma_cell()
	src.update_ma_bat()
	src.UpdateIcon()

/obj/machinery/gravity_tether/proc/weld_action(mob/user)
	switch (src.door_state)
		if (TETHER_DOOR_WELDED)
			src.door_state = TETHER_DOOR_CLOSED

			user.visible_message(
				SPAN_NOTICE("[user] unwelds the door on [src]."),
				SPAN_NOTICE("You unweld the door on [src]."),
			)
		if (TETHER_DOOR_CLOSED)
			logTheThing(LOG_STATION, src, "[user] welded the [src] door closed at [log_loc(src)]")
			src.door_state = TETHER_DOOR_WELDED

			user.visible_message(
				SPAN_ALERT("[user] welds the door on [src] shut!"),
				SPAN_ALERT("You weld the door on [src] shut!")
			)
		if (TETHER_DOOR_OPEN)
			boutput(user, SPAN_ALERT("Some jerk opened the door on [src] while you were welding it!"))
		if (TETHER_DOOR_MISSING)
			boutput(user, SPAN_ALERT("The door on [src] is simply no longer there. What the hell?!"))
	src.update_ma_door()
	src.UpdateIcon()

/obj/machinery/gravity_tether/proc/get_welding_positions()
	var/start
	var/stop

	start = list(2,1)
	stop = list(18,1)

	if(src.door_state == TETHER_DOOR_WELDED)
		. = list(stop,start)
	else
		. = list(start,stop)

#undef TETHER_WIRE_REPAIR_CABLE_COST
#undef TETHER_TAMPER_REPAIR_ROD_COST
