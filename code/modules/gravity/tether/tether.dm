TYPEINFO(/obj/machinery/gravity_tether)
	start_speech_modifiers = list(SPEECH_MODIFIER_MACHINERY)
	start_speech_outputs = list(SPEECH_OUTPUT_SPOKEN_SUBTLE)

ABSTRACT_TYPE(/obj/machinery/gravity_tether)
/obj/machinery/gravity_tether
	name = "gravity tether"
	desc = "A rather delicate piece of machinery that normalizes gravity to Earth-like levels."
	icon = 'icons/obj/machines/tether_32x48.dmi'
	icon_state = "base"
	density = TRUE
	anchored = ANCHORED_ALWAYS
	layer = EFFECTS_LAYER_BASE - 1 // covers people who walk behind it but not over other effects
	status = REQ_PHYSICAL_ACCESS
	object_flags = CAN_REPROGRAM_ACCESS | NO_GHOSTCRITTER

	speech_verb_say = "drones"
	voice_sound_override = 'sound/misc/talk/bottalk_3.ogg'

	HELP_MESSAGE_OVERRIDE(null)

	var/obj/item/cell/cell = null //!Internal capacitor
	var/cell_type_path = /obj/item/cell/charged //! type-path of the cell to install by default
	var/datum/light/light = null // star light, star bright, first star i see tonight
	var/list/area/target_area_refs = list() //! List of references to areas this tether targets

	var/active_wattage_per_g = 500 WATTS //! Wattage charge per G of intensity changed
	var/passive_wattage_per_g = 100 WATTS //! Wattage charge per machine process

	var/locked = FALSE //! Is the tether ID-locked?
	var/emagged = FALSE //! Is this machine emagged
	var/do_announcement = TRUE //! Announce gravity changes? Used when emagging
	var/tamper_intact = TRUE //! Whether the cell tamper grate is intact
	/// **Do not change directly!** Intensity of the generated gravity, in G.
	///
	///  Use `proc/change_intensity(new_intensity)` to change values.
	var/gforce_intensity = 0
	var/target_intensity = 1 //! Current intensity setting (used when changing intensities)
	var/maximum_intensity = TETHER_INTENSITY_MAX_DEFAULT //! Maxmimum intensity of this tether (emag changes this)

	var/last_charge_amount = 0 //! Last cell charge level, used for tracking charging/draining battery status
	var/charging_state = TETHER_CHARGE_IDLE //! State of the internal cell charger
	var/charge_pct_state = TETHER_BATTERY_CHARGE_FULL //! State of the last power threshold, used for battery level indicator
	var/door_state = TETHER_DOOR_CLOSED //! State of the maintenance panel door
	var/processing_state = TETHER_PROCESSING_STABLE //! Is this tether currently doing a gravity change
	var/wire_state = TETHER_WIRES_INTACT //! State of the set of wires behind the cell
	var/glitching_out = FALSE //! Whether we're Freaking Out and/or Causing Problems

	var/change_begin_time = null //! When to start the gravity change
	var/cooldown_end_time = null //! When to end post-change cooldown
	var/disturbed_end_time = null //! timer to track gravity disturbance indicator

	// large image composition, MAs cut out overlay re-rendering
	var/mutable_appearance/MA
	var/mutable_appearance/ma_graviton
	var/mutable_appearance/ma_door
	var/mutable_appearance/ma_cell
	var/mutable_appearance/ma_cell_charge
	var/mutable_appearance/ma_wires
	var/mutable_appearance/ma_tamper
	var/mutable_appearance/ma_bat
	var/mutable_appearance/ma_bat_charge
	var/mutable_appearance/ma_status
	var/mutable_appearance/ma_graph
	var/mutable_appearance/ma_screen
	var/mutable_appearance/ma_intensity
	var/mutable_appearance/ma_dials

/obj/machinery/gravity_tether/New()
	. = ..()
	START_TRACKING_CAT(TR_CAT_GRAVITY_TETHERS)
	src.RegisterSignal(GLOBAL_SIGNAL, COMSIG_GRAVITY_EVENT, /obj/machinery/gravity_tether/proc/on_gravity_event)
	src.AddComponent(/datum/component/bullet_holes, 20, 10)
	src.cell = new cell_type_path(src)
	src.cell.update_icon()
	src.light = new/datum/light/point
	if (src.cell)
		src.last_charge_amount = src.cell.charge

	if (src.has_access_requirements())
		src.locked = TRUE

	src.light.set_height(1.5)
	src.light.set_brightness(0.8)

	src.MA = mutable_appearance(src.icon, src.icon_state)
	src.ma_graviton = mutable_appearance(src.icon, "graviton-idle")
	src.ma_door = mutable_appearance(src.icon, "door-closed")
	src.ma_cell = mutable_appearance ('icons/obj/power.dmi', "apc-hpcell")
	src.ma_cell.pixel_y = -4
	src.ma_cell.dir = SOUTH
	src.ma_cell_charge = mutable_appearance('icons/obj/power.dmi', "cell02")
	src.ma_cell_charge.pixel_y = 1
	src.ma_cell_charge.pixel_x = 1
	src.ma_cell_charge.dir = SOUTH
	src.ma_wires = mutable_appearance(src.icon, "wires-intact")
	src.ma_tamper = mutable_appearance(src.icon, "tamper-secure")
	src.ma_bat = mutable_appearance(src.icon, "battery-full")
	src.ma_bat_charge = mutable_appearance(src.icon, "power-charging")
	src.ma_status = mutable_appearance(src.icon, "status-working")
	src.ma_graph = mutable_appearance(src.icon, "graph-good")
	src.ma_screen = mutable_appearance(src.icon, "screen-locked")
	src.ma_intensity = mutable_appearance(src.icon, "level-2")
	src.ma_dials = mutable_appearance(src.icon, "dials-regular")
	src.update_ma_tamper()
	src.update_ma_cell()
	src.update_ma_screen()
	src.update_ma_status()
	src.UpdateIcon()

/obj/machinery/gravity_tether/initialize()
	. = ..()
	src.setup_areas()
	src.UpdateIcon()

/obj/machinery/gravity_tether/disposing()
	STOP_TRACKING_CAT(TR_CAT_GRAVITY_TETHERS)
	src.change_intensity(0)
	src.target_area_refs.len = 0
	src.UnregisterSignal(src, COMSIG_GRAVITY_EVENT)
	. = ..()

/obj/machinery/gravity_tether/build_deconstruction_buttons(mob/user)
	if (src.gforce_intensity > 0)
		return "[src] cannot be deconstructed while it is still providing gravity!"
	if (src.processing_state == TETHER_PROCESSING_PENDING)
		return "[src] cannot be deconstructed while it is processing a gravity change!"
	return ..()

/obj/machinery/gravity_tether/was_built_from_frame(mob/user, newly_built)
	. = ..()
	if (newly_built)
		src.target_intensity = 0
		src.setup_areas()
	src.UpdateIcon()

/obj/machinery/gravity_tether/get_desc(dist, mob/user)
	. = ..()
	if (src.has_no_power())
		. += " It doesn't seem powered on."
		return

	. += " It is operating at [src.gforce_intensity]G"
	if (src.processing_state == TETHER_PROCESSING_PENDING)
		. += ", and is processing a change to [src.target_intensity]G."
	else if (src.processing_state == TETHER_PROCESSING_COOLDOWN)
		.+= ", and is cooling down from a recent change."
	else if (src.glitching_out)
		. += ", and doesn't seem to be working right."
	else
		. += "."

/obj/machinery/gravity_tether/get_help_message(dist, mob/user)
	. = ..()
	if (src.locked)
		if (isAI(user) || isrobot(user))
			var/datum/keymap/keymap = user.client.keymap
			. += "Unlock using <b>[keymap ? keymap.action_to_keybind(KEY_BOLT) : "SHIFT"]</b>+<b>Click</b>."
		else
			. += "Unlock with an appropriate <b>ID Card</b>."
		if (istrainedsyndie(x))
			. += "<br>Break the access lock with an <b>Electromagnetic Card</b>."
	else if (src.has_access_requirements())
		if (isAI(user) || isrobot(user))
			var/datum/keymap/keymap = user.client.keymap
			. += "Lock using <b>[keymap ? keymap.action_to_keybind(KEY_BOLT) : "SHIFT"]</b>+<b>Click</b>."
		else
			. += "Lock with an appropriate <b>ID Card</b>."
		if (istrainedsyndie(x))
			. += "<br>Break the access lock with an <b>Electromagnetic Card</b>."
	else
		. += "Has no access lock."
	if (user.traitHolder?.hasTrait("training_engineer"))
		if (!src.has_access_requirements())
			. += "<br>Add an access lock with an <b>Access Lite</b>."
		else
			. += "<br>The access lock can be modified with an <b>Access Pro</b>."
	if (isarcfiend(user))
		. += "<br>Can overload with <b>Discharge</b>."

	switch (src.door_state)
		if (TETHER_DOOR_WELDED)
			. += "<br>Unseal the door with a <b>welding</b> tool."
		if (TETHER_DOOR_CLOSED)
			. += "<br>Seal the door with a <b>welding</b> tool."
			. += "<br>Open the door with a <b>prying</b> tool."
		if (TETHER_DOOR_OPEN, TETHER_DOOR_MISSING)
			if (src.door_state == TETHER_DOOR_OPEN)
				. += "<br>Close the door with a <b>prying</b> tool."
			else if (src.door_state == TETHER_DOOR_MISSING)
				. += "<br>Replace the door with <b>sheet metal</b>."
			var/show_cell = TRUE
			if (src.locked)
				if (src.tamper_intact)
					show_cell = FALSE
					. += "<br>Destroy the grate with a <b>sawing</b> tool. "
				else
					. += "<br>Repair the grate with a <b>metal rod</b>."
			if (show_cell)
				if (src.cell)
					. += "<br>Remove the cell with a <b>wrenching</b> tool."
				else
					. += "<br>Replace the internal <b>power cell</b>."
					switch (src.wire_state)
						if (TETHER_WIRES_INTACT, TETHER_WIRES_BURNED)
							. += "<br>Cut out the wiring with a <b>snipping</b> tool."
						if (TETHER_WIRES_CUT)
							. += "<br>Repair the wiring with <b>cables</b>."

/// Set up the machine's targeted areas
/obj/machinery/gravity_tether/proc/setup_areas()
	src.change_intensity(src.target_intensity)

/// Run through some checks before starting gravity change
/obj/machinery/gravity_tether/proc/attempt_gravity_change(new_intensity)
	if (src.has_no_power() || src.processing_state)
		return
	if (!isfloor(src.loc))
		src.visible_message(SPAN_ALERT("\The [src] can't activate if it isn't on solid ground!"))
		return
	if (!issimulatedturf(src.loc))
		src.visible_message(SPAN_ALERT("\The [src] can't activate here!"))
		return

	new_intensity = round(new_intensity, 0.01)
	var/cost = abs(src.gforce_intensity - new_intensity) * src.active_wattage_per_g

	var/charge_avail = 0 // in cell units
	if (src.cell)
		charge_avail += src.cell.charge
	var/area/A = get_area(src)
	if (A.powered(EQUIP))
		var/obj/machinery/power/apc/area_apc = A.area_apc
		if (istype(area_apc) && area_apc.cell)
			charge_avail += area_apc.cell.charge

	if (cost <= (charge_avail / CELLRATE))
		if(src.calculate_fault_chance(0))
			src.random_fault()

		src.use_power(cost, EQUIP)
		src.begin_gravity_change(new_intensity)
	else
		src.say("Not enough power to complete change.")
		playsound(src, 'sound/machines/weaponoverload.ogg', 40, TRUE)

/// Actually start the gravity shift wind-up
/obj/machinery/gravity_tether/proc/begin_gravity_change(new_intensity)
	playsound(src.loc, 'sound/effects/mantamoving.ogg', 50, 1)
	src.processing_state = TETHER_PROCESSING_PENDING
	src.change_begin_time = TIME + TETHER_BEGIN_DELAY
	src.target_intensity = new_intensity

	src.update_ma_bat()
	src.update_ma_status()
	src.update_ma_screen()
	src.update_ma_dials()
	src.UpdateIcon()

/// Called when the tether reaches its target intensity
/obj/machinery/gravity_tether/proc/finish_gravity_change()
	if (src.gforce_intensity > 0)
		playsound(src.loc, 'sound/machines/shieldgen_startup.ogg', 50, 1)
	else
		playsound(src.loc, 'sound/machines/shieldgen_shutoff.ogg', 50, 1)
	src.change_begin_time = null
	src.processing_state = TETHER_PROCESSING_COOLDOWN
	src.cooldown_end_time = TIME + TETHER_CHANGE_COOLDOWN

	src.shake_affected()

	src.update_ma_bat()
	src.update_ma_status()
	src.update_ma_screen()
	src.update_ma_dials()
	src.UpdateIcon()

/// Directly changes the tether intensity and updates all relevant areas
/obj/machinery/gravity_tether/proc/change_intensity(new_gforce)
	if (new_gforce < 0.01) // floating point imprecision
		new_gforce = 0
	var/gforce_diff = new_gforce - src.gforce_intensity
	if (gforce_diff == 0)
		return TRUE
	src.gforce_intensity = round(new_gforce, 0.01)

	for (var/area/A in src.target_area_refs)
		A.change_gforce_tether(gforce_diff)
	src.after_change_intensity()

/obj/machinery/gravity_tether/proc/after_change_intensity()
	src.update_ma_status()
	src.update_ma_graviton()
	src.update_ma_dials()
	src.update_ma_graph()
	src.update_ma_intensity()
	src.UpdateIcon()

/// Spawns a gravitational anomaly in a turf it controls, based on the state of the machine and given starting probability
///
/// Will automatically target a random area/turf this tether controls
/obj/machinery/gravity_tether/proc/random_fault(major_prob=0)
	if (src.has_no_power())
		return
	if (!length(src.target_area_refs))
		return
	var/area/target_area = pick(src.target_area_refs)
	if (!istype(target_area))
		return

	var/list/turfs = get_area_turfs(target_area, TRUE)
	if (!length(turfs))
		turfs = get_area_turfs(target_area, FALSE)
		if (!length(turfs))
			return

	if (prob(major_prob))
		if (prob(5))
			new /obj/anomaly/gravitational/extreme(pick(turfs))
			return
		if (prob(1))
			src.randomize_gravity()
			return
		new /obj/anomaly/gravitational/major(pick(turfs))
		return
	if (prob(20))
		src.gravity_drift()
		return
	new /obj/anomaly/gravitational/minor(pick(turfs))

/// Generate oods of a fault occuring based on tether state
/obj/machinery/gravity_tether/proc/calculate_fault_chance(start_value=0)
	. = start_value
	if (src.gforce_intensity != 1) // non-standard intensities may introduce problems. scales with intensity
		. += src.gforce_intensity * 2
	switch (src.wire_state) // keep your machine taken care of
		if(TETHER_WIRES_INTACT)
			. += 0
		if(TETHER_WIRES_BURNED)
			. += 15
		if(TETHER_WIRES_CUT)
			. += 30
	. = round(clamp(., 0, 100))

/// quietly and unilaterally drift the machine up or down by 0.1G
/obj/machinery/gravity_tether/proc/gravity_drift()
	src.processing_state = TETHER_PROCESSING_COOLDOWN
	src.cooldown_end_time = TIME + TETHER_CHANGE_COOLDOWN
	src.change_intensity(src.gforce_intensity + (prob(50) ? 0.1 : -0.1))

/// Randomizes gravity. Respects tether cooldown cycle
/obj/machinery/gravity_tether/proc/randomize_gravity()
	var/chosen_gforce = randfloat(0, src.maximum_intensity)
	if (chosen_gforce == src.gforce_intensity)
		return
	src.attempt_gravity_change(chosen_gforce)

/// Handles gravity event signals. event type is `GRAVITY_EVENT_*`. Value is only used with GRAVITY_EVENT_CHANGE.
/// event_type - `GRAVITY_EVENT_*`
/// z_level - z-level for this event. -1 means all z-levels
/// value - only used for changing tether gravity
/obj/machinery/gravity_tether/proc/on_gravity_event(_, event_type, z_level, value=null)
	if (z_level != -1 && z_level != src.z)
		return
	if (src.has_no_power())
		return
	switch (event_type)
		if (GRAVITY_EVENT_DISRUPT)
			if (src.glitching_out)
				return
			src.disturbed_end_time = TIME + TETHER_DISTURBANCE_TIMER
			src.update_ma_graph()
			src.UpdateIcon()
			// additional events extend the timer, but sfx are on cooldown in case of spam
			if (!ON_COOLDOWN(src, "gravity_disturbance_sfx", TETHER_DISTURBANCE_TIMER))
				playsound(src, 'sound/effects/ship_alert_major.ogg', 50, 1)
				src.say("Severe gravity disturbance detected.")
		if (GRAVITY_EVENT_CHANGE)
			if (!isnum(value) || value < 0)
				return
			if (src.glitching_out)
				return
			src.disturbed_end_time = TIME + TETHER_DISTURBANCE_TIMER
			src.update_ma_graph()
			src.UpdateIcon()
			src.say("Auto-compensating for local gforce change.")
			playsound(src, 'sound/effects/manta_alarm.ogg', 50, 1)
			src.attempt_gravity_change(value)

/// Shake the camera of those affected by the change
/obj/machinery/gravity_tether/proc/shake_affected()
