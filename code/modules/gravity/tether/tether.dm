ABSTRACT_TYPE(/obj/machinery/gravity_tether)
/obj/machinery/gravity_tether
	processing_tier = 5
	name = "gravity tether"
	desc = "A rather delicate piece of machinery that normalizes gravity to Earth-like levels."
	icon = 'icons/obj/large/32x48.dmi'
	icon_state = "area_tether"
	density = TRUE
	anchored = ANCHORED

	layer = EFFECTS_LAYER_BASE // covers people who walk behind it
	status = REQ_PHYSICAL_ACCESS
	object_flags = CAN_REPROGRAM_ACCESS | NO_GHOSTCRITTER
	speech_verb_say = list("bleeps", "bloops", "drones", "beeps", "boops", "emits")
	voice_sound_override = 'sound/misc/talk/bottalk_3.ogg'

	var/obj/item/cell/cell = null //!Internal capacitor
	var/datum/light/light = null

	/// List of references to areas this tether targets
	var/list/area/target_area_refs = list()

	/// State of the internal cell charger
	var/charge_state = TETHER_CHARGE_IDLE
	/// State of the maintenance panel door
	var/door_state = TETHER_DOOR_CLOSED
	/// State of the set of wires behind the cell
	var/wire_state = TETHER_WIRES_INTACT

	/// Wattage charge per G of intensity changed
	var/active_wattage_per_g = 500 WATTS
	/// Wattage charge per machine process
	var/passive_wattage_per_g = 100 WATTS
	/// Last cell charge level, used for tracking charge state
	var/last_charge_level = 0

	/// Whether the cell tamper grate is intact
	var/tamper_intact = TRUE
	/// Cell is replacable
	var/replacable_cell = FALSE

	/// **Do not change directly!** Intensity of the generated gravity, in G.
	///
	///  Use `proc/change_intensity(new_intensity)` to change values.
	var/intensity = 1
	/// Current intensity setting (used when changing intensities)
	var/target_intensity = 1
	/// Maxmimum intensity of this tether (emag changes this) (or badmins)
	var/maximum_intensity = 1.5

	/// Can someone toggle us currently
	var/locked = FALSE

	/// Is this currently doing a gravity change
	var/changing_gravity = FALSE
	/// How quickly are people allowed to change states
	var/cooldown = 15 SECONDS
	/// Delay between attempting to toggle and the effect atually changing
	var/delay = 10 SECONDS // needs to be shorter than cooldown
	/// Is this machine emagged
	var/emagged = FALSE
	/// type-path of the cell to install by default
	var/cell_type_path = /obj/item/cell/charged
	/// timer to track gravity disturbance indicator
	var/gravity_disturbed_until = null

/obj/machinery/gravity_tether/New()
	. = ..()
	START_TRACKING_CAT(TR_CAT_GRAVITY_TETHERS)
	src.cell = new cell_type_path(src)
	src.light = new/datum/light/point
	if (src.cell)
		src.last_charge_level = src.cell.charge
	// TODO: dirty hack :(
	if (istype(src, /obj/machinery/gravity_tether/station))
		src.light.attach(src, 1, 1)
	else
		src.light.attach(src, 0.5, 1)
	src.light.set_brightness(1)

	if (src.req_access)
		src.locked = TRUE
	src.UpdateIcon()
	for (var/area/A in src.target_area_refs)
		A.register_tether(src)

/obj/machinery/gravity_tether/disposing()
	STOP_TRACKING_CAT(TR_CAT_GRAVITY_TETHERS)
	src.intensity = 0
	for (var/area/A in src.target_area_refs)
		A.unregister_tether(src)
	src.target_area_refs.len = 0
	. = ..()

/obj/machinery/gravity_tether/build_deconstruction_buttons(mob/user)
	if (src.intensity > 0)
		return "[src] cannot be deconstructed while it is still providing gravity!"
	if (src.changing_gravity)
		return "[src] cannot be deconstructed while it is processing a gravity change!"
	return ..()

/obj/machinery/gravity_tether/was_deconstructed_to_frame(mob/user)
	src.change_intensity(0)
	logTheThing(LOG_STATION, user, "<b>deconstructed</b> gravity tether [constructName(src)]")
	. = ..()

/obj/machinery/gravity_tether/was_built_from_frame(mob/user, newly_built)
	. = ..()
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WELDER | DECON_WIRECUTTERS | DECON_MULTITOOL | DECON_WRENCH

/obj/machinery/gravity_tether/update_icon()
	src.ClearAllOverlays(TRUE)

	if (src.has_no_power())
		src.light.disable()
		return

	var/color_r = 0
	var/color_g = 0
	var/color_b = 0

	// gravity ball
	if (src.is_broken())
		src.UpdateOverlays(SafeGetOverlayImage("graviton", 'icons/obj/large/32x48.dmi', "area_tether-broken"), "graviton")
		color_r += 150
		color_b += 50
	else if (src.intensity == 0)
		src.UpdateOverlays(SafeGetOverlayImage("graviton", 'icons/obj/large/32x48.dmi', "area_tether-disabled"), "graviton")
		color_r += 100
		color_b += 50
		color_g += 50
	else
		src.UpdateOverlays(SafeGetOverlayImage("graviton", 'icons/obj/large/32x48.dmi', "area_tether-enabled"), "graviton")
		color_r += 50
		color_b += 50
		color_g += 100

	// computer screen
	if (src.locked)
		src.AddOverlays(SafeGetOverlayImage("screen", 'icons/obj/large/32x48.dmi',"area_tether-locked"), "screen")
		color_r += 10
		color_g += 10
	else
		src.AddOverlays(SafeGetOverlayImage("screen", 'icons/obj/large/32x48.dmi',"area_tether-unlocked"), "screen")
		color_g += 20

	src.light.set_color(color_r/255, color_g/255, color_b/255)
	src.light.enable()

/obj/machinery/gravity_tether/process(mult)
	. = ..()

	src.handle_power_cycle()

	if (src.has_no_power())
		src.changing_gravity = FALSE
		return

	if (prob(3))
		SPAWN(1 DECI SECOND)
			playsound(src.loc, pick(
				"sound/ambience/station/Underwater/sub_ambi2.ogg",
				"sound/ambience/station/Underwater/sub_ambi3.ogg",
				"sound/ambience/station/Underwater/sub_ambi4.ogg",
				"sound/ambience/station/Underwater/sub_ambi6.ogg",
				"sound/ambience/station/Underwater/sub_ambi8.ogg",
			), 50, 1)

	if (src.is_broken())
		var/malf_chance = src.calculate_malfunction()
		if (prob(malf_chance) && !ON_COOLDOWN(src, "passive_malfunction", 50 SECONDS + rand(1, 20) SECONDS))
			// fault intensity chance increases as fault chance goes up
			src.random_fault(malf_chance)

	var/do_update_icon = FALSE

	if (src.gravity_disturbed_until && TIME > src.gravity_disturbed_until)
		src.gravity_disturbed_until = null
		do_update_icon = TRUE

	if (src.changing_gravity)
		// TODO: integrate gravity change over time (too perf heavy rn)
		// change `src.changing_gravity` into a gravity step value, and have it stop when it hits the target G
		var/cooldown_timer = GET_COOLDOWN(src, TETHER_COOLDOWN_ID)
		if (cooldown_timer <= 0)
			playsound(src.loc, 'sound/machines/shieldgen_shutoff.ogg', 50, 1)
			src.changing_gravity = FALSE
			src.change_intensity(src.target_intensity)
			do_update_icon = TRUE
		else
			// TODO: Better looping sound?
			playsound(src.loc, 'sound/machines/found.ogg', 80, 0)

	if (do_update_icon)
		src.UpdateIcon()

/obj/machinery/gravity_tether/powered()
	if (istype(src.loc, /obj/item/electronics/frame)) //if in a frame, we are never powered
		return FALSE
	if (src.cell?.charge > (src.passive_wattage_per_g * src.intensity))
		return TRUE
	. = ..()

/// Handle power billing and cell charging
///
/// uses area power until 40%, then internal cell, then area power
/obj/machinery/gravity_tether/proc/handle_power_cycle()
	var/passive_wattage_needed = src.passive_wattage_per_g * src.intensity
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
		var/area/A = get_area(src)
		if (A.powered(EQUIP))
			var/obj/machinery/power/apc/area_apc = A?.area_apc
			if (istype(area_apc) && area_apc.cell?.charge)
				var/available_area_watts = area_apc.cell?.charge / CELLRATE
				if (passive_wattage_needed && available_area_watts > passive_wattage_needed)
					area_apc.use_power(passive_wattage_needed, EQUIP)
					available_area_watts -= passive_wattage_needed
					passive_wattage_needed = 0
				// only try recharging if we sustain passive operation and we can keep the lights on
				if (!passive_wattage_needed && recharge_wattage_needed && available_area_watts > recharge_wattage_needed && area_apc.cell?.percent() > 40 )
					if(src.give_cell_wrapper(recharge_wattage_needed * CELLRATE))
						area_apc.use_power(recharge_wattage_needed, EQUIP)
						recharge_wattage_needed = 0

	if (passive_wattage_needed)
		src.power_change()

	// TODO: This could probably use recharge_wattage_needed instead ? may have to store another var
	if (src.cell)
		if (src.charge_state != TETHER_CHARGE_IDLE && (src.cell.charge == src.last_charge_level))
			src.charge_state = TETHER_CHARGE_IDLE
			src.UpdateIcon()
		else if (src.charge_state != TETHER_CHARGE_CHARGING && (src.cell.charge > src.last_charge_level))
			src.charge_state = TETHER_CHARGE_CHARGING
			src.UpdateIcon()
		else if (src.charge_state != TETHER_CHARGE_DRAINING && (src.cell.charge < src.last_charge_level))
			src.charge_state = TETHER_CHARGE_DRAINING
			src.UpdateIcon()

		// TODO: check against battery level thresholds instead of updating everytime the cell charge changes
		if (src.last_charge_level != src.cell.charge)
			src.last_charge_level = src.cell.charge
			src.UpdateIcon()

/obj/machinery/gravity_tether/power_change()
	. = ..()
	if (!src.powered())
		if (src.changing_gravity)
			src.changing_gravity = FALSE
		src.change_intensity(0)
		src.UpdateIcon()

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

/obj/machinery/gravity_tether/receive_silicon_hotkey(var/mob/user)
	if (..())
		return
	if (!src.allowed(user))
		return
	if (user.client.check_key(KEY_BOLT))
		. = 1
		src.say("Interface [!src.locked ? "locked" : "unlocked"].")
		if (!src.emagged)
			src.locked = !src.locked
			if (!src.locked)
				logTheThing(LOG_STATION, user, "unlocked gravity tether at at [log_loc(src)].")
			src.UpdateIcon()
		return

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
	src.set_broken()

	if (src.cell.rigger)
		message_admins("[key_name(src.cell.rigger)]'s rigged cell damaged [src] at [log_loc(src)].")
		logTheThing(LOG_COMBAT, src.cell.rigger, "'s rigged cell damaged [src] at [log_loc(src)].")

	src.visible_message(SPAN_ALERT("<b>[src]'s internal capacitor compartment explodes!</b>"), SPAN_ALERT("You hear a loud bang. That doesn't sound good."))

	var/epicenter = get_turf(src)
	playsound(epicenter, "explosion", 90, 1)

	SPAWN(0)
		qdel(src.cell)
		src.cell = null
		src.UpdateIcon()

/obj/machinery/gravity_tether/attack_hand(mob/user)
	if(..())
		return
	if (src.locked && !src.emagged)
		src.say("Controls locked.")
		return

	var/cooldown_timer = GET_COOLDOWN(src, TETHER_COOLDOWN_ID)
	if (src.changing_gravity)
		src.say("Processing existing gravity shift. [TO_SECONDS(cooldown_timer)] seconds remaining.")
		return

	var/new_intensity = tgui_input_number(user, "[src] is currently set to [src.intensity]G. Change intensity?", "Tether Intensity", src.intensity, src.maximum_intensity, round_input=FALSE)
	new_intensity = round(new_intensity, 0.01)

	if (isnull(new_intensity))
		return
	if (new_intensity == src.intensity)
		src.say("Current configuration is already [new_intensity]G!")
		return

	if (!src.emagged)
		if (tgui_alert(user, "Really set [src] to [new_intensity]G?", "Tether Confirmation", list("Yes", "No")) != "Yes")
			return

	if (in_interact_range(src, user))
		src.attempt_gravity_change(new_intensity)
	src.UpdateIcon()

/obj/machinery/gravity_tether/attackby(obj/item/I, mob/user)
	user.lastattacked = get_weakref(src)
	if (src.replacable_cell)
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
					src.UpdateIcon()
				if (TETHER_DOOR_CLOSED)
					if (src.locked)
						var/duration = 2 SECONDS
						if (ishuman(user))
							var/mob/living/carbon/human/H = user
							if (H.traitHolder.hasTrait("carpenter") || H.traitHolder.hasTrait("training_engineer"))
								duration = duration / 2
						playsound(src, 'sound/machines/airlock_pry.ogg', 35, TRUE)
						SETUP_GENERIC_ACTIONBAR(user, src, duration, /obj/machinery/gravity_tether/proc/door_force_open, list(I, user), \
						I.icon, I.icon_state, null, INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_ATTACKED | INTERRUPT_STUNNED | INTERRUPT_ACTION)
					else
						user.visible_message(
							SPAN_NOTICE("The door on [src] is opened by [user]."),
							SPAN_NOTICE("You open the door on [src]."),
							SPAN_ALERT("You hear the creak of a metal door.")
						)
						playsound(src.loc, 'sound/misc/locker_open.ogg', 30)
						src.door_state = TETHER_DOOR_OPEN
						src.UpdateIcon()
				if (TETHER_DOOR_WELDED)
					boutput (user, SPAN_NOTICE("The door on [src] is welded shut!"))
			return

		if (isweldingtool(I))
			switch(src.door_state)
				if (TETHER_DOOR_OPEN)
					boutput(user, SPAN_NOTICE("The door on [src] must be closed before welding it shut."))
					return
				if (TETHER_DOOR_MISSING)
					boutput(user, SPAN_NOTICE("There's no door on [src] to weld!"))
					return

			var/positions = src.get_welding_positions()
			actions.start(new /datum/action/bar/private/welding(user, src, 2 SECONDS, /obj/machinery/gravity_tether/proc/weld_action, \
							list(user), "[user] finishes using [his_or_her(user)] [I.name] on [src].", positions[1], positions[2]),user)
			return

		if (src.door_state == TETHER_DOOR_OPEN || src.door_state == TETHER_DOOR_MISSING)

			// tamper repair grate
			if (istype(I, /obj/item/rods) && src.locked && !src.tamper_intact)
				var/duration = 5 SECONDS
				if (ishuman(user))
					var/mob/living/carbon/human/H = user
					if (H.traitHolder.hasTrait("carpenter") || H.traitHolder.hasTrait("training_engineer"))
						duration = duration / 2
				user.visible_message(
					SPAN_NOTICE("[user] begins repairing [src]'s tamper-resist security grate."),
					SPAN_NOTICE("You begin repairing the tamper-resist security grate on [src]."),
				)
				SETUP_GENERIC_ACTIONBAR(user, src, duration, /obj/machinery/gravity_tether/proc/tamper_repair, list(I, user), \
				I.icon, I.icon_state, null, INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_ATTACKED | INTERRUPT_STUNNED | INTERRUPT_ACTION)
				return

			// destroy tamper grate
			if ((issawingtool(I)) && src.locked && src.tamper_intact)
				var/duration = 20 SECONDS
				if (ishuman(user))
					var/mob/living/carbon/human/H = user
					if (H.traitHolder.hasTrait("carpenter") || H.traitHolder.hasTrait("training_engineer"))
						duration = duration / 2
				playsound(src.loc, 'sound/items/mining_drill.ogg', 50, 1, extrarange=1)
				user.visible_message(
					SPAN_COMBAT("[user] begins cutting into [src]'s tamper-resist security grate!"),
					SPAN_COMBAT("You begin cutting into [src]'s tamper-resist security grate!"),
					SPAN_COMBAT("You hear the awful sound of metal grinding on metal."),
				)
				SETUP_GENERIC_ACTIONBAR(user, src, duration, /obj/machinery/gravity_tether/proc/tamper_destroy, list(I, user), \
				I.icon, I.icon_state, null, INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_ATTACKED | INTERRUPT_STUNNED | INTERRUPT_ACTION)
				return

			// battery and wiring
			if (!(src.locked && src.tamper_intact))
				if (src.cell)
					// take cell
					if (iswrenchingtool(I))
						var/duration = 5 SECONDS
						if (ishuman(user))
							var/mob/living/carbon/human/H = user
							if (H.traitHolder.hasTrait("carpenter") || H.traitHolder.hasTrait("training_engineer"))
								duration = duration / 2
						playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
						user.visible_message(
							SPAN_ALERT("[user] begins removing the interal cell from [src]!"),
							SPAN_ALERT("You begin removing the interal battery from [src]!"),
							SPAN_ALERT("You hear the loosening of heavy-duty bolts.")
						)
						SETUP_GENERIC_ACTIONBAR(user, src, duration, /obj/machinery/gravity_tether/proc/cell_remove, list(I, user), \
						I.icon, I.icon_state, null, INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_ATTACKED | INTERRUPT_STUNNED | INTERRUPT_ACTION)
						return
				else
					// give cell
					if (istype(I, /obj/item/cell))
						var/duration = 5 SECONDS
						if (ishuman(user))
							var/mob/living/carbon/human/H = user
							if (H.traitHolder.hasTrait("carpenter") || H.traitHolder.hasTrait("training_engineer"))
								duration = duration / 2
						user.visible_message(
							SPAN_NOTICE("[user] begins installing [I] into [src]."),
							SPAN_NOTICE("You begin installing [I] into [src]."),
						)
						SETUP_GENERIC_ACTIONBAR(user, src, duration, /obj/machinery/gravity_tether/proc/cell_install, list(I, user), \
						I.icon, I.icon_state, null, INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_ATTACKED | INTERRUPT_STUNNED | INTERRUPT_ACTION)
						return

					// cut out wires
					if(src.wire_state != TETHER_WIRES_CUT && (iscuttingtool(I) || issnippingtool(I)))
						var/shockdmg = user.shock(src, src.power_usage, user.hand == LEFT_HAND ? "l_arm": "r_arm")
						if (prob(min(shockdmg, 100)))
							return
						var/duration = 8 SECONDS
						if (ishuman(user))
							var/mob/living/carbon/human/H = user
							if (H.traitHolder.hasTrait("carpenter") || H.traitHolder.hasTrait("training_engineer"))
								duration = duration / 2
						user.visible_message(
							SPAN_ALERT("[user] begins cutting the wires out of [src]."),
							SPAN_ALERT("You begin cutting the wires out of [src]."),
						)
						playsound(src.loc, 'sound/items/Scissor.ogg', 60, TRUE)
						SETUP_GENERIC_ACTIONBAR(user, src, duration, /obj/machinery/gravity_tether/proc/wire_snip, list(I, user), \
						I.icon, I.icon_state, null, INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_ATTACKED | INTERRUPT_STUNNED | INTERRUPT_ACTION)
						return

					// repair wires
					if (src.wire_state == TETHER_WIRES_CUT && istype(I, /obj/item/cable_coil))
						if (I.amount < TETHER_WIRE_REPAIR_CABLE_COST)
							boutput(user, SPAN_NOTICE("You need [TETHER_WIRE_REPAIR_CABLE_COST] lengths of cable to fix the wiring on [src]."))
							return
						var/duration = 10 SECONDS
						if (ishuman(user))
							var/mob/living/carbon/human/H = user
							if (H.traitHolder.hasTrait("carpenter") || H.traitHolder.hasTrait("training_engineer"))
								duration = duration / 2
						user.visible_message(
							SPAN_NOTICE("[user] begins repairing the wiring in [src]."),
							SPAN_NOTICE("You begin repairing the wiring in [src]."),
						)
						playsound(src.loc, 'sound/items/penclick.ogg', 60, TRUE)
						SETUP_GENERIC_ACTIONBAR(user, src, duration, /obj/machinery/gravity_tether/proc/wire_repair, list(I, user), \
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

	if (src.has_no_power())
		return ..()

	var/obj/item/card/id/id_card = get_id_card(I)
	if (istype(id_card) && length(src.req_access))
		if (src.allowed(user))
			src.say("Interface [!src.locked ? "locked" : "unlocked"].")
			if (!src.emagged)
				src.locked = !src.locked
				if (!src.locked)
					logTheThing(LOG_STATION, user, "unlocked gravity tether at at [log_loc(src)].")
		else
			src.say("Access denied.")
		src.UpdateIcon()
	. = ..()

// use tool on tether helper procs

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
	src.UpdateIcon()
	return

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
	if (src.is_broken())
		src.status &= ~BROKEN
	src.UpdateIcon()

/obj/machinery/gravity_tether/proc/cell_remove(obj/item/I, mob/user)
	if (!user || !I || (user.equipped() != I))
		return

	playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 0)
	src.cell.UpdateIcon()
	user.put_in_hand_or_drop(src.cell)
	src.charge_state = TETHER_CHARGE_IDLE
	src.cell = null
	user.visible_message(
		SPAN_NOTICE("[user] removes \the [src.cell] from \the [src]."),
		SPAN_NOTICE("You remove \the [src.cell] from \the [src].")
	)
	src.UpdateIcon()

/// Callback run when a cell is installed
/obj/machinery/gravity_tether/proc/cell_install(obj/item/I, mob/user)
	if (istype(I, /obj/item/cell) && user.equipped() == I)
		playsound(src.loc, 'sound/machines/click.ogg', 50, 0)
		user.u_equip(I)
		I.set_loc(src)
		src.cell = I
		user.visible_message(
			SPAN_NOTICE("[user] installs \the [I] into \the [src]."),
			SPAN_NOTICE("You install \the [I] into \the [src]."),
		)
		src.UpdateIcon()

/// emag effects:
/// * disables access requirements
/// * disables gravity change confirmation dialog
/// * disables gravity change announcement
/// * increases maximum intensity
/// * burns out wires (greater chance to trigger random faults)
/obj/machinery/gravity_tether/emag_act(mob/user, obj/item/card/emag/E)
	. = ..()
	if(src.emagged)
		boutput(user, "The g-force limiter on [src] is already glitching out...")
		return
	logTheThing(LOG_STATION, src, "was emagged by [user] at [log_loc(src)].")
	boutput(user, "You slide [E] across [src]'s ID reader, breaking the g-force limiter.")
	src.locked = FALSE
	if (src.wire_state == TETHER_WIRES_INTACT)
		src.wire_state = TETHER_WIRES_BURNED
	src.emagged = TRUE
	src.maximum_intensity = 4 // wireless 4G
	src.UpdateIcon()

/obj/machinery/gravity_tether/demag(mob/user)
	. = ..()
	src.emagged = FALSE
	src.maximum_intensity = initial(src.maximum_intensity)

/obj/machinery/gravity_tether/ex_act(severity)
	switch(severity)
		if(1)
			if(prob(50))
				src.set_broken()
			else
				src.random_fault()
			return
		if(2)
			if (prob(10))
				src.set_broken()
			else if (prob(50))
				src.random_fault()
		if(3)
			src.random_fault()

/obj/machinery/gravity_tether/blob_act(power)
	if (prob(25 * power/20))
		if (src.is_broken())
			qdel(src)
		else
			src.set_broken()
		return
	if (prob(power * 2))
		if (!src.is_disabled())
			src.random_fault(src.calculate_malfunction())

/obj/machinery/gravity_tether/bullet_act(obj/projectile/P)
	if (HAS_ANY_FLAGS(P.proj_data.damage_type, D_KINETIC | D_PIERCING | D_SLASHING))
		if (prob(src.calculate_malfunction(P.power * P.proj_data.ks_ratio / 4)))
			if (src.replacable_cell)
				if (src.door_state == TETHER_DOOR_WELDED || src.door_state == TETHER_DOOR_CLOSED)
					src.visible_message(SPAN_ALERT("The door on \the [src] is blown right off its hinges!"))
					playsound(src.loc, 'sound/impact_sounds/Metal_Hit_Light_1.ogg', 50, 1)
					src.door_state = TETHER_DOOR_MISSING
				else if (src.locked && src.tamper_intact == TRUE)
					logTheThing(LOG_STATION, P, "destroyed the tamper-resist grate on [src].")
					playsound(src.loc, 'sound/impact_sounds/Metal_Hit_Light_1.ogg', 50, 1, extrarange=2)
					src.tamper_intact = FALSE
				else if (src.cell)
					src.visible_message("The power cell inside \the [src] flies out!")
					src.cell.set_loc(get_turf(src))
					var/turf/T = get_edge_target_turf(src, SOUTH)
					src.cell.throw_at(T,rand(0,5),rand(1,3))
					src.cell = null
				else if (src.wire_state == TETHER_WIRES_INTACT || src.wire_state == TETHER_WIRES_BURNED)
					playsound(src, 'sound/effects/sparks4.ogg', 50)
					var/datum/effects/system/spark_spread/S = new /datum/effects/system/spark_spread
					S.set_up(2, FALSE, src)
					S.start()
					src.wire_state = TETHER_WIRES_CUT
				src.UpdateIcon()
			if (!ON_COOLDOWN(src, "bullet_fault", 4 SECONDS))
				if (P.power > 50)
					src.random_fault(src.calculate_malfunction(15))
				else
					src.random_fault()

	if (HAS_ANY_FLAGS(P.proj_data.damage_type, D_ENERGY | D_RADIOACTIVE) && !src.has_no_power())
		if (prob(src.calculate_malfunction(P.power * (1-P.proj_data.ks_ratio) / 8)))
			if (src.replacable_cell && src.wire_state == TETHER_WIRES_INTACT)
				playsound(src, 'sound/effects/sparks4.ogg', 50)
				var/datum/effects/system/spark_spread/S = new /datum/effects/system/spark_spread
				S.set_up(2, FALSE, src)
				S.start()
				src.wire_state = TETHER_WIRES_BURNED
				src.UpdateIcon()
			if (!ON_COOLDOWN(src, "bullet_fault", 4 SECONDS))
				src.random_fault()

/obj/machinery/gravity_tether/overload_act()
	. = ..()

	if (!ON_COOLDOWN(src, "overload_cooldown", 1 MINUTE))
		if (prob(src.calculate_malfunction(6)))
			src.visible_message(SPAN_ALERT("The pylon on [src] violently shorts!"), SPAN_ALERT("You hear a sharp spark!"))
			if (src.replacable_cell)
				switch (src.wire_state)
					if(TETHER_WIRES_INTACT)
						src.wire_state = TETHER_WIRES_BURNED
					if(TETHER_WIRES_CUT)
						if (src.cell)
							logTheThing(LOG_STATION, src, "shorts out via overload, causing a cell failure at [log_loc(src)].")
							src.cell_rig_effect()
			src.random_fault(src.calculate_malfunction())
		else
			src.visible_message(SPAN_ALERT("The pylon on [src] briefly shorts."), SPAN_ALERT("You hear a spark."))
			src.random_fault()

		src.UpdateIcon()
		return TRUE
	return FALSE

/obj/machinery/gravity_tether/set_broken()
	if (src.replacable_cell && src.wire_state == TETHER_WIRES_INTACT)
		src.wire_state = TETHER_WIRES_BURNED
	src.random_fault(src.calculate_malfunction(50))
	. = ..()

/// Generate oods of a malfunction from 0-100 based on tether state
/obj/machinery/gravity_tether/proc/calculate_malfunction(start_value=0)
	. = start_value
	if (src.intensity != 1) // non-standard intensities may introduce problems. scales with intensity
		. += src.intensity * 2
	switch (src.wire_state) // keep your machine taken care of
		if(TETHER_WIRES_INTACT)
			. += 0
		if(TETHER_WIRES_BURNED)
			. += 15
		if(TETHER_WIRES_CUT)
			. += 30
	. = clamp(., 0, 100)

/// Actually start the gravity shift wind-up
/obj/machinery/gravity_tether/proc/begin_gravity_change(new_intensity)
	playsound(src.loc, 'sound/machines/shieldgen_startup.ogg', 50, 1)
	src.changing_gravity = TRUE
	src.target_intensity = new_intensity
	src.say("Recalculating gravity matrix for [src.target_intensity]G.")

/// Run through some checks before starting gravity change
/obj/machinery/gravity_tether/proc/attempt_gravity_change(new_intensity)
	if (!src.powered())
		return
	var/cooldown = GET_COOLDOWN(src, TETHER_COOLDOWN_ID)
	if (cooldown > 0)
		return

	var/cost = abs(src.intensity - new_intensity) * src.active_wattage_per_g

	var/charge_avail = 0 // in cell units
	if (src.cell)
		charge_avail += src.cell.charge
	var/area/A = get_area(src)
	if (A.powered(EQUIP))
		var/obj/machinery/power/apc/area_apc = A.area_apc
		if (istype(area_apc) && area_apc.cell)
			charge_avail += area_apc.cell.charge

	if (cost <= (charge_avail / CELLRATE))
		if(src.calculate_malfunction(0))
			src.random_fault()

		src.use_power(cost, EQUIP)
		OVERRIDE_COOLDOWN(src, TETHER_COOLDOWN_ID, src.cooldown)
		src.begin_gravity_change(new_intensity)
	else
		src.say("Not enough available power to process gravity shift.")
		playsound(src, 'sound/machines/pc_process.ogg', 50, TRUE)

/// Beginning and end coordinates for welding spark line
/obj/machinery/gravity_tether/proc/get_welding_positions()
	var/start
	var/stop

	start = list(2,1)
	stop = list(18,1)

	if(src.door_state == TETHER_DOOR_WELDED)
		. = list(stop,start)
	else
		. = list(start,stop)

/// Callback for the welding action
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

	src.UpdateIcon()

/// Directly changes the tether intensity and updates all relevant areas
/obj/machinery/gravity_tether/proc/change_intensity(new_intensity)
	new_intensity = round(new_intensity, 0.01)
	if (src.intensity == new_intensity)
		return TRUE
	src.intensity = new_intensity
	for (var/area/A in src.target_area_refs)
		A.recalc_tether_gforce()
	src.UpdateIcon()

/// Picks a random major or minor fault from all faults, based on the given probability.
///
/// Will automatically target a random area this tether controls unless given an area refere
/obj/machinery/gravity_tether/proc/random_fault(major_prob=0, area/target_area=null)
	if (!istype(target_area))
		target_area = pick(src.target_area_refs)
	if (!istype(target_area))
		return

	var/fault_type
	if (prob(major_prob))
		fault_type = pick(concrete_typesof(/datum/tether_fault/major))
	else
		fault_type = pick(concrete_typesof(/datum/tether_fault/minor))

	var/datum/tether_fault/fault = new fault_type
	fault?.effect(target_area, src)
