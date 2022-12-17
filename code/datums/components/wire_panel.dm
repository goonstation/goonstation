/**
 * Wire Panel Component
 *
 * Addding this component to an object will add an interactable wire panel.
 *
 * Has signals for state changes for con
 *
 * Consumer is responsible for icon updates and functionality changes based on wire control.
 */

/*
 TODOs:
 * state - map-preset cut wires/control state
 * ui - write TGUI data component ala ReagentStatus
*/

// ----- datums ----- //

/**
 * Indicator Lights
 *
 * A default list of control wires to indicator light color, active pattern, and inactive pattern
 *
 */
/datum/wirePanel

/datum/wirePanel/wireActs
	var/control_flag = 0
	var/fix_act = ~WIRE_ACT_CUT
	var/break_act = ~WIRE_ACT_MEND

/datum/wirePanel/wireActs/New(control=0, to_fix=~WIRE_ACT_CUT, to_break=~WIRE_ACT_MEND)
	. = ..()
	src.control_flag = control
	src.fix_act = to_fix
	src.break_act = to_break

/datum/wirePanel/indicatorDefintion
	var/control_flag
	var/color_name
	var/color_value
	var/active_pattern
	var/inactive_pattern

/datum/wirePanel/indicatorDefintion/New(control, color, active, inactive)
	src.control_flag = control
	src.color_name = color
	src.active_pattern = active
	src.inactive_pattern = inactive
	. = ..()

/datum/wirePanel/indicatorDefintion/proc/cache_color()
	if (!src.color_value)
		var/datum/named_color/C = get_color_by_name(src.color_name)
		if (istype(C))
			src.color_value = rgb(C.r, C.g, C.b)

/datum/wirePanel/indicatorMap
	var/static/list/datum/wirePanel/indicatorDefintion/indicators = list(
		WPANEL_INDICATOR(WIRE_GROUND_TODO, "white", "on", "flashing"),
		WPANEL_INDICATOR(WIRE_POWER_1_TODO, "blue", "on", "off"),
		WPANEL_INDICATOR(WIRE_POWER_2_TODO, "brown", "on", "off"),
		WPANEL_INDICATOR(WIRE_BACKUP_1_TODO, "green", "on", "off"),
		WPANEL_INDICATOR(WIRE_BACKUP_2_TODO, "orange", "on", "off"),
		WPANEL_INDICATOR(WIRE_SILICON_TODO, "cyan", "on", "flashing"),
		WPANEL_INDICATOR(WIRE_ACCESS_TODO, "orange", "on", "flashing"),
		WPANEL_INDICATOR(WIRE_SAFETY_TODO, "pink", "off", "flashing"),
		WPANEL_INDICATOR(WIRE_RESTRICT_TODO, "yellow", "on", "flashing"),
		WPANEL_INDICATOR(WIRE_ACTIVATE_TODO, "red", "off", "on"),
		WPANEL_INDICATOR(WIRE_RECIEVE_TODO, "purple", "flashing", "off"),
		WPANEL_INDICATOR(WIRE_TRANSMIT_TODO, "lime", "flashing", "off"),
		)

// /datum/wirePanel/indicatorMap/New()
// 	. = ..()
// 	src.indicators =
/datum/wirePanel/wireDefintion
	var/control_flags
	var/wire_color_name
	var/wire_color_value
	var/actions_to_fix
	var/actions_to_break

/**
 * Defintion of an individual wire.
 */
/datum/wirePanel/wireDefintion/New(controls=0, wire_color="iris", to_fix=~WIRE_ACT_CUT, to_break=~WIRE_ACT_MEND)
	. = ..()
	src.control_flags = controls
	src.wire_color_name = wire_color
	src.actions_to_fix = to_fix
	src.actions_to_break = to_break

/datum/wirePanel/wireDefintion/proc/cache_color()
	if (!src.wire_color_value)
		var/datum/named_color/C = get_color_by_name(src.wire_color_name)
		if (istype(C))
			src.wire_color_value = rgb(C.r, C.g, C.b)

/**
 * Panel defintion
 */
/datum/wirePanel/panelDefintion
	/// Ordered list of `wirePanel/wireDefintion`. Defintions for each wire
	var/list/datum/wirePanel/wireDefintion/wire_definitions = list()
	/// Ordered List of `wirePanel/indicatorDefintion. All available indicator lights for this defintion
	var/list/datum/wirePanel/indicatorDefintion/indicator_lights = list()

/***
 * Definition of a wire panel
 *
 * Randomizes on creation. Best used as a static variable per path you want to share wire color-to-function mapping
 *
 * Arguments:
 * * `controls` req. indexed list - what each control wire can do
 * * `color_pool` req. unordered list - color pool to pull from for wire color. must be equal to or larger than `controls` length
 * * `custom_acts` opt. unordered list - what will fix/activate each wire control
 * * `indicators` opt. bitfield of `WIRE_*` - which indicators are tracked. defaults to all controls in `wire_control`. set to -1 for no indicators.
 * * `light_map` opt. /datum/indicatorLights - ustom defintion of indicator lights. default `datum/indicatorLights`
 * * `keep_color_order` opt. boolean - keeps the orders of wire control to color (i.e. for debugging)
 */
/datum/wirePanel/panelDefintion/New(
	list/controls,
	list/color_pool,
	list/custom_acts,
	indicators,
	datum/wirePanel/indicatorMap/light_map,
	keep_color_order=FALSE,
	)
	. = ..()
	var/count = length(controls)
	if (count > length(color_pool))
		CRASH("Tried to create wirePanelDefinition with longer length `controls` than `color_pool`")
	if (istype(light_map))
		if (!istype(light_map, /datum/wirePanel/indicatorMap))
			CRASH("Tried to create wirePanelDefinition with `light_map` not of type `/datum/wirePanel/indicatorMap`")
	else
		light_map = /datum/wirePanel/indicatorMap

	var/indicator_bitfield = 0

	for (var/i in 1 to count)
		var/shared_pick = 1
		var/color_pick = rand(1, length(color_pool))
		if (keep_color_order)
			color_pick = shared_pick

		var/datum/wirePanel/wireDefintion/wire_definition = new /datum/wirePanel/wireDefintion(
			controls = controls[shared_pick],
			wire_color = color_pool[color_pick]
		)
		for (var/datum/wirePanel/wireActs/act in custom_acts)
			if (act.control_flag == controls[shared_pick])
				wire_definition.actions_to_fix = act.fix_act
				wire_definition.actions_to_break = act.break_act

		src.wire_definitions += wire_definition

		indicator_bitfield |= controls[shared_pick]

		controls -= controls[shared_pick]
		color_pool -= color_pool[color_pick]

	if (indicators == -1) // no indicators
		return
	if (indicators >= 1) // custom indicators
		indicator_bitfield = indicators

	for (var/datum/wirePanel/indicatorDefintion/indicator in light_map.indicators)
		if (HAS_FLAG(indicator_bitfield, indicator.control_flag))
			src.indicator_lights += list(indicator)

// ----- component ----- //

TYPEINFO(/datum/component/wirePanel)
	initialization_args = list(
		ARG_INFO("definition", DATA_INPUT_REF, "Datum holding our wire panel defintion"),
	)
/datum/component/wirePanel
	/// p0anel cover status
	var/cover_status = PANEL_COVER_CLOSED
	/// wire-indexed list of booleans
	var/list/cut_wires = list()
	/// Reference to a wire defintion datum, set in Initialize
	var/datum/wirePanel/panelDefintion/panel_def
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

	RegisterSignal(parent, COMSIG_WPANEL_SET_CONTROL, .proc/set_control)
	RegisterSignal(parent, COMSIG_WPANEL_SET_CONTROL_BY_INDEX, .proc/set_control_by_index)
	RegisterSignal(parent, COMSIG_WPANEL_SET_COVER, .proc/set_cover)

	RegisterSignal(parent, COMSIG_WPANEL_MOB_SNIP, .proc/mob_snip)
	RegisterSignal(parent, COMSIG_WPANEL_MOB_PULSE, .proc/mob_pulse)

	RegisterSignal(parent, COMSIG_WPANEL_STATE_CUTS, .proc/state_cuts)
	RegisterSignal(parent, COMSIG_WPANEL_STATE_CONTROLS, .proc/state_controls)
	RegisterSignal(parent, COMSIG_WPANEL_STATE_COVER, .proc/state_cover)

	RegisterSignal(parent, COMSIG_WPANEL_UPDATE_UI, .proc/update_ui)
	RegisterSignal(parent, COMSIG_WPANEL_UI_DATA, .proc/ui_data)
	RegisterSignal(parent, COMSIG_WPANEL_UI_STATIC_DATA, .proc/ui_static_data)
	RegisterSignal(parent, COMSIG_WPANEL_UI_ACT, .proc/ui_act)

/**
 * Handles panel opening and showing the UI a wire hacking tool is used
 */
/datum/component/wirePanel/proc/attackby(obj/parent, obj/item/item, mob/user)
	if (isscrewingtool(item))
		switch(src.cover_status)
			if (PANEL_COVER_CLOSED)
				SEND_SIGNAL(parent, COMSIG_WPANEL_SET_COVER, PANEL_COVER_OPEN, user)
				SEND_SIGNAL(parent, COMSIG_WPANEL_UPDATE_UI, user)
				boutput(user, "You open the maintenance panel.")
				return TRUE
			if (PANEL_COVER_OPEN)
				SEND_SIGNAL(parent, COMSIG_WPANEL_SET_COVER, PANEL_COVER_CLOSED, user)
				SEND_SIGNAL(parent, COMSIG_WPANEL_UPDATE_UI)
				boutput(user, "You close the maintenance panel.")
				return TRUE
			if (PANEL_COVER_BROKEN)
				boutput(user, "The maintenance panel is broken!")
				return
			if (PANEL_COVER_LOCKED)
				boutput(user, "The maintenance panel is locked!")
				return

	if (src.cover_status == PANEL_COVER_OPEN && (ispulsingtool(item) || issnippingtool(item)))
		SEND_SIGNAL(parent, COMSIG_WPANEL_UPDATE_UI, user)
		return TRUE

/datum/component/wirePanel/proc/attack_hand(obj/parent, mob/user)
	if (src.cover_status == PANEL_COVER_BROKEN)
		return
	if (src.cover_status == PANEL_COVER_OPEN)
		SEND_SIGNAL(parent, COMSIG_WPANEL_UPDATE_UI, user)
	if (parent.can_access_remotely(user))
		SEND_SIGNAL(parent, COMSIG_WPANEL_UPDATE_UI, user)

/**
 * Set a control
 *
 * Returns TRUE if the active control state changes.
 *
 * Arguments:
 * * control the control to change
 * * new_status new status of the control
 */
/datum/component/wirePanel/proc/set_control(obj/parent, control, new_status, mob/user)
	if (HAS_FLAG(src.active_wire_controls, control) == new_status)
		return // we already are this status
	TOGGLE_FLAG(src.active_wire_controls, control)
	return TRUE

/**
 * Set a control based on the wire
 *
 * Returns TRUE if the active control state changes.
 *
 * Arguments:
 * * wire index of the wire to control
 * * new_status new status of the control
 */
/datum/component/wirePanel/proc/set_control_by_index(obj/parent, wire, new_status, mob/user)
	return SEND_SIGNAL(parent, COMSIG_WPANEL_SET_CONTROL, src.panel_def.wire_definitions[wire].control_flags, new_status, user)

/**
 * Chamges a panel cover's status
 *
 * Returns the updated state
 *
 * Arguments:
 * status new `WIRE_COVER_*` status to apply
 * mob/user who altered the cover
 */
/datum/component/wirePanel/proc/set_cover(obj/parent, status, mob/user)
	src.cover_status = status
	return src.cover_status

/**
 * Deprecated. Stub for CHUI conusmers. Force a UI update for the user
 *
 * No return value
 *
 * Arguments:
 * * mob/user (optional) user to add to updates
 */
/datum/component/wirePanel/proc/update_ui(obj/parent, mob/user)
	return

/**
 * Return TRUE if we can interact with the wires
 */
/datum/component/wirePanel/proc/can_mod_wires(obj/parent, mob/user, tool_flag)
	if (src.cover_status == PANEL_COVER_OPEN)
		if (isAI(user) || (issilicon(user) && BOUNDS_DIST(user, parent)))
			if (!HAS_FLAG(src.active_wire_controls, WIRE_SILICON_TODO))
				boutput(user, "Silicon control wire has been disabled!")
				return
		else
			if (BOUNDS_DIST(user, parent))
				boutput(user, "You're too far away to reach the wire panel on [parent]!")
				return
			if (!user.find_tool_in_hand(tool_flag))
				switch(tool_flag)
					if (TOOL_SNIPPING)
						boutput(user, "You need a snipping tool to cut or mend wires!")
						return
					if (TOOL_PULSING)
						boutput(user, "You need a multitool or similar!")
						return
				return
		return TRUE
	else if (src.cover_status == PANEL_COVER_CLOSED || src.cover_status == PANEL_COVER_LOCKED)
		if(!parent.can_access_remotely(user))
			boutput(user, "The panel is [src.cover_status == PANEL_COVER_CLOSED ? "closed": "locked"]!")
			return
		if (!HAS_FLAG(src.active_wire_controls, WIRE_SILICON_TODO))
			boutput(user, "Silicon control wire has been disabled!")
			return
		return TRUE
	else if (src.cover_status == PANEL_COVER_BROKEN)
		boutput(user, "The wire panel looks [pick ("broken", "smashed", "totalled", "messed up")], repair it first!")

/**
 * Any action on a wire; maybe good for packets?
 */
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


	if (HAS_FLAG(src.panel_def.wire_definitions[wire].actions_to_break, wire_act_flag))
		return SEND_SIGNAL(parent, COMSIG_WPANEL_SET_CONTROL_BY_INDEX, wire, FALSE, user)
	if (HAS_FLAG(src.panel_def.wire_definitions[wire].actions_to_fix, wire_act_flag))
		return SEND_SIGNAL(parent, COMSIG_WPANEL_SET_CONTROL_BY_INDEX, wire, TRUE, user)

/**
 * Mob attempting to snip a given wire.
 *
 * Returns TRUE if the wire control activation changed
 *
 * Arguments:
 * * mob/user who is using the tool
 * * wire index of the wire to affect.
 */
/datum/component/wirePanel/proc/mob_snip(obj/parent, mob/user, wire)
	if (!src.can_mod_wires(parent, user, TOOL_SNIPPING))
		return
	if (src.cut_wires[wire])
		return src.act_wire(parent, user, wire, WIRE_ACT_MEND)
	else
		return src.act_wire(parent, user, wire, WIRE_ACT_CUT)

/**
 * Mob attempting to pulse a given wire.
 *
 * Returns TRUE if active control wires were changed.
 *
 * Arguments:
 * * mob/user who is using the tool
 * * index of the wire to affect.
*/
/datum/component/wirePanel/proc/mob_pulse(obj/parent, mob/user, wire)
	if (!src.can_mod_wires(parent, user, TOOL_PULSING))
		return
	if (src.cut_wires[wire])
		boutput(user, "You can't pulse a cut wire.")
		return
	return src.act_wire(parent, user, wire, WIRE_ACT_PULSE)

/datum/component/wirePanel/proc/state_cuts(obj/parent, list/cuts)
	cuts.Add(src.cut_wires)

/datum/component/wirePanel/proc/state_controls(obj/parent)
	return src.active_wire_controls

/datum/component/wirePanel/proc/state_cover(obj/parent)
	return src.cover_status

/datum/component/wirePanel/ui_static_data(obj/parent, list/data)
	src.panel_def.ui_static_data(parent, data)

/datum/wirePanel/panelDefintion/ui_static_data(obj/parent, list/data)
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
			"active" = indicator.active_pattern,
			"inactive" = indicator.inactive_pattern,
		))
	output["indicators"] = indicators

	data["wirePanelStatic"] = output

/datum/component/wirePanel/ui_data(obj/parent, list/data)
	var/list/output = list()

	var/wires = list()
	for (var/i in 1 to length(src.cut_wires))
		wires += list(list(
			"cut" = src.cut_wires[i]
		))
	output["wires"] = wires

	var/indicators = list()
	for (var/datum/wirePanel/indicatorDefintion/indicator in src.panel_def.indicator_lights)
		indicators += list(list(
			"status" = HAS_FLAG(src.active_wire_controls, indicator["control_flag"])
		))
	output["indicators"] = indicators

	output["cover_status"] = src.cover_status
	output["active_wire_controls"] = src.active_wire_controls

	data["wirePanel"] = output

/datum/component/wirePanel/ui_act(obj/parent, action, list/params, datum/tgui/ui)
	switch(action)
		if("snipwire")
			if(params["wire"])
				var/ret = SEND_SIGNAL(parent, COMSIG_WPANEL_MOB_SNIP, ui.user, params["wire"])
				tgui_process.try_update_ui(ui.user, src, ui)
				return ret
		if("pulsewire")
			if(params["wire"])
				var/ret = SEND_SIGNAL(parent, COMSIG_WPANEL_MOB_SNIP, ui.user, params["wire"])
				tgui_process.try_update_ui(ui.user, src, ui)
				return ret
