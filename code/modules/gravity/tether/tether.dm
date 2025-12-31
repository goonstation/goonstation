/// Time between the player confirming the change and the change starting
#define TETHER_BEGIN_DELAY (30 SECONDS)
/// Time after the change is complete before another change can be entered
#define TETHER_CHANGE_COOLDOWN (30 SECONDS)

ABSTRACT_TYPE(/obj/machinery/gravity_tether)
/obj/machinery/gravity_tether
	name = "gravity tether"
	desc = "A rather delicate piece of machinery that normalizes gravity to Earth-like levels."
	icon = 'icons/obj/machines/tether_32x48.dmi'
	icon_state = "base"
	density = TRUE
	anchored = ANCHORED_ALWAYS
	layer = EFFECTS_LAYER_BASE // covers people who walk behind it
	status = REQ_PHYSICAL_ACCESS
	object_flags = CAN_REPROGRAM_ACCESS | NO_GHOSTCRITTER

	speech_verb_say = list("bleeps", "bloops", "drones", "beeps", "boops", "emits")
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
	src.cell = new cell_type_path(src)
	src.light = new/datum/light/point
	if (src.cell)
		src.last_charge_amount = src.cell.charge

	if (src.req_access)
		src.locked = TRUE

	src.light.set_height(1.5)
	src.light.set_brightness(0.8)

	src.MA = mutable_appearance(src.icon, src.icon_state)
	src.ma_graviton = mutable_appearance(src.icon, "graviton-idle")
	src.ma_door = mutable_appearance(src.icon, "door-closed")
	src.ma_cell = mutable_appearance ('icons/obj/power.dmi', "apc-hpcell")
	src.ma_cell.pixel_x = 10
	src.ma_cell.pixel_y = 5
	src.ma_cell_charge = mutable_appearance('icons/obj/power.dmi', "cell02")
	src.ma_cell_charge.pixel_x = 1
	src.ma_cell_charge.pixel_y = 1
	src.ma_wires = mutable_appearance(src.icon, "wires-intact")
	src.ma_tamper = mutable_appearance(src.icon, "tamper-secure")
	src.ma_bat = mutable_appearance(src.icon, "battery-full")
	src.ma_bat_charge = mutable_appearance(src.icon, "power-charging")
	src.ma_status = mutable_appearance(src.icon, "status-working")
	src.ma_graph = mutable_appearance(src.icon, "graph-good")
	src.ma_screen = mutable_appearance(src.icon, "screen-locked")
	src.ma_intensity = mutable_appearance(src.icon, "level-2")
	src.ma_dials = mutable_appearance(src.icon, "dials-regular")

/obj/machinery/gravity_tether/initialize()
	. = ..()
	src.change_intensity(src.target_intensity)
	src.UpdateIcon()

/obj/machinery/gravity_tether/disposing()
	STOP_TRACKING_CAT(TR_CAT_GRAVITY_TETHERS)
	src.change_intensity(0)
	src.target_area_refs.len = 0
	. = ..()

/obj/machinery/gravity_tether/build_deconstruction_buttons(mob/user)
	if (src.gforce_intensity > 0)
		return "[src] cannot be deconstructed while it is still providing gravity!"
	if (src.processing_state == TETHER_PROCESSING_PENDING)
		return "[src] cannot be deconstructed while it is processing a gravity change!"
	return ..()

/obj/machinery/gravity_tether/get_desc(dist, mob/user)
	. = ..()
	if (src.has_no_power())
		. += " It doesn't seem powered on."
	else
		if (src.processing_state == TETHER_PROCESSING_PENDING)
			. += " It is changing intensity."
		else if (src.processing_state == TETHER_PROCESSING_COOLDOWN)
			.+= " It is cooling down from a change."
		else if (src.status & BROKEN)
			. += " It doesn't seem to be working right."
		else if (src.gforce_intensity == 0)
			. += " It is online, but not active."
		else
			. += " It is operating at [src.gforce_intensity]G."

/obj/machinery/gravity_tether/get_help_message(dist, mob/user)
	. = ..()
	if (src.locked)
		if (isAI(user) || isrobot(user))
			var/datum/keymap/keymap = user.client.keymap
			. += "Unlock using <b>[keymap ? keymap.action_to_keybind(KEY_BOLT) : "SHIFT"]</b>+<b>Click</b>."
		else
			. += "Unlock with an appropriate <b>ID Card</b>."
		if (istrainedsyndie(x) || isspythief(x))
			. += "<br>Break the access lock with an <b>Electromagnetic Card</b>."
	else if (length(src.req_access))
		if (isAI(user) || isrobot(user))
			var/datum/keymap/keymap = user.client.keymap
			. += "Lock using <b>[keymap ? keymap.action_to_keybind(KEY_BOLT) : "SHIFT"]</b>+<b>Click</b>."
		else
			. += "Lock with an appropriate <b>ID Card</b>."
	else
		. += "Has no access lock."
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

/// Run through some checks before starting gravity change
/obj/machinery/gravity_tether/proc/attempt_gravity_change(new_intensity)
	if (src.has_no_power() || src.processing_state)
		return
	if (!isfloor(src.loc))
		src.visible_message(SPAN_ALERT("\The [src] can't activate if it isn't on solid ground!"))
		return
	if (!istype(src.loc, /turf/simulated))
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
		playsound(src, 'sound/machines/pod_alarm.ogg', 40, TRUE)


/// Actually start the gravity shift wind-up
/obj/machinery/gravity_tether/proc/begin_gravity_change(new_intensity)
	playsound(src.loc, 'sound/machines/shieldgen_startup.ogg', 50, 1)
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
		return
	src.gforce_intensity = round(new_gforce, 0.01)

	src.update_ma_status()
	src.update_ma_graviton()
	src.update_ma_dials()
	src.update_ma_graph()
	src.update_ma_intensity()
	src.UpdateIcon()

	SPAWN (0)
		for (var/area/A in src.target_area_refs)
			A.gforce_tether += gforce_diff
			var/total_gforce = max(A.gforce_minimum, global.zlevels[A.z].gforce + A.gforce_tether)
			for (var/turf/T in A)
				T.gforce_current = round(max(0, total_gforce + T.gforce_inherent), 0.01)
			LAGCHECK(LAG_LOW)

#undef TETHER_BEGIN_DELAY
#undef TETHER_CHANGE_COOLDOWN
