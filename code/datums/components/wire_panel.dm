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
	/// by-order list of booleans
	var/list/cut_wires = list()
	/// bitmask of which wire controls are hacked
	var/hacked_controls = 0

/datum/component/wirePanel/Initialize(datum/wirePanel/panelDefintion/_definition)
	..()
	if(!istype(parent, /obj))
		return COMPONENT_INCOMPATIBLE
	src.panel_def = _definition
	src.panel_def.deserialize()

	for (var/datum/wirePanel/wireDefintion/wire in src.panel_def.by_order)
		wire.cache_color()
		src.cut_wires += list(FALSE)
	RegisterSignal(parent, COMSIG_ATTACKBY, PROC_REF(attackby))
	RegisterSignal(parent, COMSIG_ATTACKHAND, PROC_REF(attack_hand))

	RegisterSignal(parent, COMSIG_WPANEL_MOB_WIRE_ACT, PROC_REF(mob_wire_act))

	RegisterSignal(parent, COMSIG_WPANEL_SET_CONTROLS, PROC_REF(set_controls))
	RegisterSignal(parent, COMSIG_WPANEL_SET_COVER, PROC_REF(set_cover))

	RegisterSignal(parent, COMSIG_WPANEL_HACKED_CONTROLS, PROC_REF(state_controls))
	RegisterSignal(parent, COMSIG_WPANEL_STATE_COVER, PROC_REF(state_cover))

	RegisterSignal(parent, COMSIG_ATOM_UI_DATA, PROC_REF(ui_data))
	RegisterSignal(parent, COMSIG_ATOM_UI_STATIC_DATA, PROC_REF(ui_static_data))
	RegisterSignal(parent, COMSIG_ATOM_UI_ACT, PROC_REF(ui_act))

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
				return TRUE

	if (src.cover_status == WPANEL_COVER_OPEN && (ispulsingtool(item) || issnippingtool(item)))
		parent.ui_interact(user)
		return TRUE

/// handles when the wire panel is open. Does not block other actions.
/datum/component/wirePanel/proc/attack_hand(obj/parent, mob/user)
	if (src.cover_status == WPANEL_COVER_OPEN)
		parent.ui_interact(user)

/**
 * Set one or more wire controls on or off
 *
 * Arguments:
 * * `mob/user` - user doing the action
 * * `controls` - the controls to change
 * * `is_hacked` - new hacked state of the controls
 */
/datum/component/wirePanel/proc/set_controls(obj/parent, mob/user, controls, is_hacked)
	if (is_hacked)
		src.hacked_controls = ADD_FLAG(src.hacked_controls, controls)
	else
		src.hacked_controls = REMOVE_FLAG(src.hacked_controls, controls)
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
		if (HAS_FLAG(src.hacked_controls, WIRE_CONTROL_SILICON))
			boutput(user, "Remote silicon control has been disabled!", "wpanel")
			return
		return TRUE

	if (src.cover_status == WPANEL_COVER_OPEN)
		if (BOUNDS_DIST(user, parent)) // [ ] Large object offset
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
		if (HAS_FLAG(src.hacked_controls, WIRE_CONTROL_SILICON))
			boutput(user, "Remote silicon control has been disabled!", "wpanel")
			return
		return TRUE

/// Mob following through and doing the action to the wire.
/datum/component/wirePanel/proc/act_wire(obj/parent, mob/user, wire_index, wire_act_flag)
	var/datum/wirePanel/wireDefintion/wire = src.panel_def.by_order[wire_index]
	if(!istype(wire))
		return
	switch(wire_act_flag)
		if (WIRE_ACT_CUT)
			src.cut_wires[wire_index] = TRUE
			boutput(user, "You cut the <b>[wire.color_name]</b> wire!")
		if (WIRE_ACT_MEND)
			src.cut_wires[wire_index] = FALSE
			boutput(user, "You mend the <b>[wire.color_name]</b> wire!")
		if (WIRE_ACT_PULSE)
			boutput(user, "You pulse the <b>[wire.color_name]</b> wire!")

	// only fix what's hacked
	var/can_fix = src.hacked_controls & wire.control_flags
	// only hack what's not fixed
	var/can_hack = wire.control_flags ^ can_fix

	if(HAS_FLAG(wire.hack, wire_act_flag))
		. = SEND_SIGNAL(parent, COMSIG_WPANEL_SET_CONTROLS, user, can_hack, TRUE)
	if(HAS_FLAG(wire.fix, wire_act_flag))
		. = SEND_SIGNAL(parent, COMSIG_WPANEL_SET_CONTROLS, user, can_fix, FALSE)

	tgui_process.update_uis(parent)

/**
 * Mob attempting an action on a wire.
 *
 * Returns TRUE if the wire state changed
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

/// Returns the currently active wire control flags
/datum/component/wirePanel/proc/state_controls(obj/parent)
	return src.hacked_controls

/// Return the status of the wire panel's cover
/datum/component/wirePanel/proc/state_cover(obj/parent)
	return src.cover_status

/// TGUI Data helper
/datum/component/wirePanel/ui_static_data(obj/parent, mob/user, list/data)
	var/list/output = list()
	var/list/wire_data = list()
	for (var/datum/wirePanel/wireDefintion/wire in src.panel_def.by_order)
		var/list/this_wire = list()
		this_wire["color_name"] = wire.color_name
		this_wire["color_value"] = wire.color_value
		wire_data += list(this_wire)
	output["wires"] = wire_data

	output["control_lights"] = src.panel_def.control_lights

	data["wire_panel"] = output

/// TGUI Data helper
/datum/component/wirePanel/ui_data(obj/parent, mob/user, list/data)
	var/list/output = list()

	var/list/wire_data = list()
	for (var/wire in 1 to length(src.cut_wires))
		var/list/this_wire = list()
		var/datum/wirePanel/wireDefintion/wire_def = src.panel_def.by_order[wire]
		this_wire["color_name"] = wire_def.color_name
		this_wire["color_value"] = wire_def.color_value
		this_wire["is_cut"] = src.cut_wires[wire]
		wire_data += list(this_wire)

	output["wires"] = wire_data
	output["control_lights"] = src.panel_def.control_lights

	output["cover_status"] = src.cover_status
	output["hacked_controls"] = src.hacked_controls
	output["is_silicon_user"] = isAI(user) || issilicon(user)
	output["is_accessing_remotely"] = isAI(user) || (issilicon(user) && BOUNDS_DIST(user, parent))

	data["wire_panel"] = output

/// TGUI Helper. Handles wire actions, and if there is a change, requests a UI update.
/datum/component/wirePanel/ui_act(obj/parent, action, list/params, datum/tgui/ui)
	switch(action)
		if("actwire")
			if(("wire_index" in params) && ("action" in params))
				. = SEND_SIGNAL(parent, COMSIG_WPANEL_MOB_WIRE_ACT, ui.user, params["wire_index"], params["action"])
