/**
 * Wire Panel Component
 *
 * Addding this component to an object will add an interactable wire panel.
 *
 * Consumer is responsible for icon updates / functionality changes based on wire control.
 */

TYPEINFO(/datum/component/wirePanel)
	initialization_args = list(
		ARG_INFO("definition", DATA_INPUT_REF, "Datum holding our wire panel defintion"),
	)
/datum/component/wirePanel
	/// Reference to a wire defintion datum, passed in Initialize
	var/datum/wirePanel/panelDefintion/panel_def
	/// panel cover status (default closed)
	var/cover_status = WPANEL_COVER_CLOSED
	/// wire-indexed list of booleans
	var/list/cut_wires = list()
	/// bitmask of which wire controls are active (default all active)
	var/active_wire_controls = ~0

/datum/component/wirePanel/Initialize(_definition)
	if(!istype(parent, /obj))
		return COMPONENT_INCOMPATIBLE
	src.panel_def = _definition
	for(var/datum/wirePanel/indicatorDefintion/indicator in src.panel_def.indicator_lights)
		indicator.cache_color()
	for (var/wire in 1 to length(src.panel_def.wire_definitions))
		src.panel_def.wire_definitions[wire].cache_color()
		src.cut_wires += list(FALSE) // no wires cut by default
	RegisterSignal(parent, COMSIG_ATTACKBY, .proc/attackby)
	RegisterSignal(parent, COMSIG_ATTACKHAND, .proc/attack_hand)

	RegisterSignal(parent, COMSIG_WPANEL_MOB_WIRE_ACT, .proc/mob_wire_act)
	RegisterSignal(parent, COMSIG_WPANEL_ION_STORM, .proc/ion_storm)

	RegisterSignal(parent, COMSIG_WPANEL_SET_CONTROL, .proc/set_control)
	RegisterSignal(parent, COMSIG_WPANEL_SET_COVER, .proc/set_cover)

	RegisterSignal(parent, COMSIG_WPANEL_STATE_CONTROLS, .proc/state_controls)
	RegisterSignal(parent, COMSIG_WPANEL_STATE_COVER, .proc/state_cover)

	RegisterSignal(parent, COMSIG_WPANEL_UI_DATA, .proc/ui_data)
	RegisterSignal(parent, COMSIG_WPANEL_UI_STATIC_DATA, .proc/ui_static_data)
	RegisterSignal(parent, COMSIG_WPANEL_UI_ACT, .proc/ui_act)

/// Handle tool usage on the panel/object
/datum/component/wirePanel/proc/attackby(obj/parent, obj/item/item, mob/user)
	if (isscrewingtool(item))
		switch(src.cover_status)
			if (WPANEL_COVER_CLOSED)
				SEND_SIGNAL(parent, COMSIG_WPANEL_SET_COVER, user, WPANEL_COVER_OPEN)
				boutput(user, "You open [parent]'s maintenance panel.", "wpanel")
				parent.ui_interact(user)
				return TRUE
			if (WPANEL_COVER_OPEN)
				SEND_SIGNAL(parent, COMSIG_WPANEL_SET_COVER, user, WPANEL_COVER_CLOSED)
				boutput(user, "You close [parent]'s maintenance panel.", "wpanel")
				return TRUE
			if (WPANEL_COVER_BROKEN)
				boutput(user, "The maintenance panel on [parent] is broken!", "wpanel")
				return
			if (WPANEL_COVER_LOCKED)
				boutput(user, "The maintenance panel on [parent] is locked!", "wpanel")
				return

	if (src.cover_status == WPANEL_COVER_OPEN && (ispulsingtool(item) || issnippingtool(item)))
		parent.ui_interact(user)
		return TRUE

/// handles when the wire panel is open. Note: does not block other actions.
/datum/component/wirePanel/proc/attack_hand(obj/parent, mob/user)
	if (src.cover_status == WPANEL_COVER_BROKEN)
		return
	if (src.cover_status == WPANEL_COVER_OPEN)
		parent.ui_interact(user)

/**
 * Set one or more wire controls on or off
 *
 * Returns TRUE if the active control state changes.
 *
 * Arguments:
 * * `controls` - the control to change
 * * `new_status` - new status of the control
 * * `mob/user` - user doing the action, if applicable
 */
/datum/component/wirePanel/proc/set_control(obj/parent, mob/user, controls, new_status)
	if (HAS_FLAG(src.active_wire_controls, controls) == new_status)
		return // we already are this status
	TOGGLE_FLAG(src.active_wire_controls, controls)
	return TRUE

/**
 * Chamges the panel cover status
 *
 * Returns the new wire cover status.
 *
 * Arguments:
 * `status` - new `WIRE_COVER_*` status
 * `mob/user` - user who did the action, if applicable
 */
/datum/component/wirePanel/proc/set_cover(obj/parent, mob/user, status)
	src.cover_status = status
	return src.cover_status

/**
 * Check to see if the user can modify our wires.
 *
 * Return TRUE if we can interact with the wires.
 */
/datum/component/wirePanel/proc/can_mod_wires(obj/parent, mob/user, tool_flag)
	if (src.cover_status == WPANEL_COVER_BROKEN)
		boutput(user, "The wire panel looks [pick ("broken", "smashed", "totalled", "messed up")], repair it first!", "wpanel")
		return

	if (isAI(user) || (issilicon(user) && BOUNDS_DIST(user, parent)))
		if (!HAS_FLAG(src.active_wire_controls, WIRE_CONTROL_SILICON))
			boutput(user, "Remote silicon control has been disabled!", "wpanel")
			return
		return TRUE

	if (src.cover_status == WPANEL_COVER_OPEN)
		if (BOUNDS_DIST(user, parent))
			boutput(user, "You're too far away to reach the wire panel on [parent]!", "wpanel")
			return
		if (!user.find_tool_in_hand(tool_flag))
			switch(tool_flag)
				if (TOOL_SNIPPING)
					boutput(user, "You need a snipping tool to cut or mend wires!", "wpanelSnip")
					return
				if (TOOL_PULSING)
					boutput(user, "You need a multitool or similar to pulse wires!", "wpanelPulse")
					return
			return
		return TRUE

	if (src.cover_status == WPANEL_COVER_CLOSED || src.cover_status == WPANEL_COVER_LOCKED)
		if (!issilicon(user))
			boutput(user, "The cover panel is [src.cover_status == WPANEL_COVER_CLOSED ? "closed": "locked"]")
			return
		if (HAS_FLAG(src.active_wire_controls, WIRE_CONTROL_SILICON))
			return TRUE
		boutput(user, "Remote silicon control has been disabled!", "wpanel")

/// Mob following through and doing the action to the wire.
/datum/component/wirePanel/proc/act_wire(obj/parent, mob/user, wire, wire_act_flag)
	switch(wire_act_flag)
		if (WIRE_ACT_CUT)
			src.cut_wires[wire] = TRUE
			boutput(user, "You cut the <b>[src.panel_def.wire_definitions[wire].wire_color_name]</b> wire!")
		if (WIRE_ACT_MEND)
			src.cut_wires[wire] = FALSE
			boutput(user, "You mend the <b>[src.panel_def.wire_definitions[wire].wire_color_name]</b> wire!")
		if (WIRE_ACT_PULSE)
			boutput(user, "You pulse the <b>[src.panel_def.wire_definitions[wire].wire_color_name]</b> wire!")

	// of the active controls, which of those does this wire change
	var/can_break = HAS_ANY_FLAGS(src.active_wire_controls, src.panel_def.wire_definitions[wire].control_flags)
	// of the inactive controls, which of those does this wire change
	var/can_fix = HAS_ANY_FLAGS(~src.active_wire_controls, src.panel_def.wire_definitions[wire].control_flags)

	// can we break/fix with this tool?
	if (can_break && HAS_ANY_FLAGS(src.panel_def.wire_definitions[wire].actions_to_break, wire_act_flag))
		. = SEND_SIGNAL(parent, COMSIG_WPANEL_SET_CONTROL, user, can_break, FALSE)
	if (can_fix && HAS_ANY_FLAGS(src.panel_def.wire_definitions[wire].actions_to_fix, wire_act_flag))
		. = SEND_SIGNAL(parent, COMSIG_WPANEL_SET_CONTROL, user, can_fix, TRUE)
	tgui_process.update_uis(parent)

/**
 * Mob attempting an action on a wire.
 *
 * Returns TRUE if
 *
 * Arguments:
 * * `mob/user`: mob - Who is doing the action
 * * `wire`: number - Index of the wire to act on
 * * `action`: `WIRE_ACT_*` - The action to take
 */
/datum/component/wirePanel/proc/mob_wire_act(obj/parent, mob/user, wire, action)
	var/tool = null

	if (action == WIRE_ACT_NONE) return

	// TGUI doesn't track what item was used on a UI, so we intuit
	if (action == WIRE_ACT_CUT || action == WIRE_ACT_MEND)
		tool = TOOL_SNIPPING
	if (action == WIRE_ACT_PULSE)
		tool = TOOL_PULSING

	if (!tool) return
	if (!src.can_mod_wires(parent, user, tool))	return

	. = src.act_wire(parent, user, wire, action)

// /// Appends to a list the state of which wires are cut by index.
// /datum/component/wirePanel/proc/state_cuts(obj/parent, list/cuts)
// 	cuts.Add(src.cut_wires)

/// Returns the currently active wire control flags
/datum/component/wirePanel/proc/state_controls(obj/parent)
	return src.active_wire_controls

/// Return the status of the wire panel's cover
/datum/component/wirePanel/proc/state_cover(obj/parent)
	return src.cover_status

/// Handle ion storm events by turning off a whole wire's controls
/datum/component/wirePanel/proc/ion_storm(obj/parent)
	var/wires = list()
	for(var/datum/wirePanel/wireDefintion/wire in panel_def.wire_definitions)
		wires += list(wire.control_flags)
	var/target_wire_controls = pick(wires)
	SEND_SIGNAL(parent, COMSIG_WPANEL_SET_CONTROL, null, target_wire_controls, FALSE)
	logTheThing(LOG_STATION, null, "Ion storm interfered with [parent.name] at [log_loc(parent)]")

/// Passthrough to the shared panelDefintion function
/datum/component/wirePanel/ui_static_data(obj/parent, mob/user, list/data)
	src.panel_def.ui_static_data(parent, user, data)

/// TGUI UI static data helper. Put here for ease of reference.
/datum/wirePanel/panelDefintion/ui_static_data(obj/parent, mob/user, list/data)
	var/list/output = list()
	var/wires = list()
	for (var/datum/wirePanel/wireDefintion/wire in src.wire_definitions)
		wires += list(list(
			"name" = wire.wire_color_name,
			"value" = wire.wire_color_value,
		))
	output["wires"] = wires

	var/indicators = list()
	for (var/datum/wirePanel/indicatorDefintion/indicator in src.indicator_lights)
		indicators += list(list(
			"name" = indicator.color_name,
			"value" = indicator.color_value,
			"control" = indicator.control_flags,
		))
	output["indicators"] = indicators
	if (!data)
		data = list()

	data["wirePanelStatic"] = output

/// TGUI Data helper
/datum/component/wirePanel/ui_data(obj/parent, mob/user, list/data)
	var/list/output = list()

	var/wires = list()
	for (var/i in 1 to length(src.cut_wires))
		wires += list(list(
			"cut" = src.cut_wires[i]
		))
	output["wires"] = wires

	var/indicators = list()
	for (var/datum/wirePanel/indicatorDefintion/indicator in src.panel_def.indicator_lights)
		var/status = (HAS_FLAG(src.active_wire_controls, indicator.control_flags) > 0)
		var/pattern = status ? indicator.active_pattern : indicator.inactive_pattern
		if (istype(parent, /obj/machinery))
			var/obj/machinery/machine = parent
			if (HAS_FLAG(machine.status, NOPOWER))
				pattern = "off"
		indicators += list(list(
			"status" = status,
			"pattern" = pattern,
		))
	output["indicators"] = indicators

	output["cover_status"] = src.cover_status
	output["active_wire_controls"] = src.active_wire_controls

	output["is_silicon_user"] = isAI(user) || issilicon(user)
	output["is_accessing_remotely"] = isAI(user) || (issilicon(user) && BOUNDS_DIST(user, parent))

	data["wirePanelDynamic"] = output

/// TGUI Helper. Handles wire actions, and if there is a change, requests a UI update.
/datum/component/wirePanel/ui_act(obj/parent, action, list/params, datum/tgui/ui)
	switch(action)
		if("actwire")
			if(params["wire"] && params["action"])
				. = SEND_SIGNAL(parent, COMSIG_WPANEL_MOB_WIRE_ACT, ui.user, params["wire"], params["action"])
