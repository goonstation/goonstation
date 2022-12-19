/**
 * Datums for supporting the wirePanel component
 */
/datum/wirePanel

/**
 * Per-wire defintion for breaking/fixing controls. Can be defined via `custom_acts`.
 *
 * Use `WPANEL_CUSTOM_ACT` macro.
 *
 * Arguments:
 * * `control`: The control flag this wire controls
 * * `to_fix`: bitfield of `WIRE_ACT_*` - which actions will fix this control
 * * `to_break`: bitfield of `WIRE_ACT_*` - which actions will break this control
 */
/datum/wirePanel/wireActs
	var/control_flag = 0
	var/fix_act = ~WIRE_ACT_CUT
	var/break_act = ~WIRE_ACT_MEND

/datum/wirePanel/wireActs/New(control=0, to_fix=~WIRE_ACT_CUT, to_break=~WIRE_ACT_MEND)
	. = ..()
	src.control_flag = control
	src.fix_act = to_fix
	src.break_act = to_break

/**
 * Definition for a single indicator. Automatically generated via `/datum/wirePanel/indicatorMap`.
 *
 * Use `WPANEL_INDICATOR` macro.
 *
 * Arguments:
 * * `control`: WIRE_CONTROL_* - control this indicator is for
 * * `color`: string - name of a color from `named_colors.dm`
 * * `active_pattern`: WPANEL_PATTERN_* - pattern this uses when the relatedcontrol is active
 * * `inactive_pattern`:  WPANEL_PATTERN_* -
 */
/datum/wirePanel/indicatorDefintion
	var/control_flags
	var/color_name
	var/color_value
	var/active_pattern
	var/inactive_pattern

/datum/wirePanel/indicatorDefintion/New(control, color, active, inactive)
	. = ..()
	src.control_flags = control
	src.color_name = color
	src.active_pattern = active
	src.inactive_pattern = inactive

/// Fetches the RGB color value from the global `named_colors`
/datum/wirePanel/indicatorDefintion/proc/cache_color()
	if (!src.color_value)
		var/datum/named_color/C = get_color_by_name(src.color_name)
		if (istype(C))
			src.color_value = rgb(C.r, C.g, C.b)

/**
 * Default set of indicators; each control has the same distinct light and pattern between rounds.
 */
/datum/wirePanel/indicatorMap
	var/static/list/datum/wirePanel/indicatorDefintion/indicators = list(
		WPANEL_INDICATOR(WIRE_CONTROL_GROUND, "yellow", "on", "flashing"),
		WPANEL_INDICATOR(WIRE_CONTROL_POWER_A, "blue", "on", "off"),
		WPANEL_INDICATOR(WIRE_CONTROL_POWER_B, "brown", "on", "off"),
		WPANEL_INDICATOR(WIRE_CONTROL_BACKUP_A, "green", "on", "off"),
		WPANEL_INDICATOR(WIRE_CONTROL_BACKUP_B, "orange", "on", "off"),
		WPANEL_INDICATOR(WIRE_CONTROL_SILICON, "cyan", "on", "flashing"),
		WPANEL_INDICATOR(WIRE_CONTROL_ACCESS, "orange", "on", "flashing"),
		WPANEL_INDICATOR(WIRE_CONTROL_SAFETY, "pink", "off", "flashing"),
		WPANEL_INDICATOR(WIRE_CONTROL_RESTRICT, "white", "on", "flashing"),
		WPANEL_INDICATOR(WIRE_CONTROL_ACTIVATE, "red", "off", "on"),
		WPANEL_INDICATOR(WIRE_CONTROL_RECIEVE, "purple", "flashing", "off"),
		WPANEL_INDICATOR(WIRE_CONTROL_TRANSMIT, "lime", "flashing", "off"),
		)

/**
 * Definition of a single wire. Automatically generated via `/datum/wirePanel/panelDefintion/New()`.
 *
 * Arguments:
 * * `controls`: bitfield of `WIRE_CONTROL_*`. - Which control wire flags does this control
 * * `wire_color`: string - *Named* colour to apply to this wire.
 * * `to_fix`?: bitfield of `WIRE_ACT_*` - Which actions on this wire will fix the related controls
 * * `to_break`?: bitfield of `WIRE_ACT_*` - Which actions on this wire will break the related controls
 */
/datum/wirePanel/wireDefintion
	var/control_flags
	var/wire_color_name
	var/wire_color_value
	var/actions_to_fix
	var/actions_to_break

/datum/wirePanel/wireDefintion/New(controls=0, wire_color="iris", to_fix=~WIRE_ACT_CUT, to_break=~WIRE_ACT_MEND)
	. = ..()
	src.control_flags = controls
	src.wire_color_name = wire_color
	src.actions_to_fix = to_fix
	src.actions_to_break = to_break

/// Fetches the RGB color value from the global `named_colors`
/datum/wirePanel/wireDefintion/proc/cache_color()
	if (!src.wire_color_value)
		var/datum/named_color/C = get_color_by_name(src.wire_color_name)
		if (istype(C))
			src.wire_color_value = rgb(C.r, C.g, C.b)

/***
 * Definition of a wire panel
 *
 * Randomly links wire color to controls. Use as a static variable to share wire color-to-function mapping.
 *
 * Arguments:
 * * `controls`: indexed list of `WIRE_CONTROL_*` flags - Each wire can handle one or more wire controls
 * * `color_pool`: unordered list of global `named_colors` colors - pool to pull from for wire color. must be equal to or larger than `controls` length.
 * * `custom_acts`?: unordered list of `/datum/wirePanel/wireActs` - what will fix/activate each wire control
 * * `indicators`?: bitfield of `WIRE_CONTROL_*` - which indicators are tracked. defaults to all controls in `wire_control`. set to -1 for no indicators.
 * * `light_map`?: `/datum/indicatorLights` - Custom defintion of indicator lights. defaults to directly referencing `/datum/indicatorLights/indicatorMap`
 * * `keep_order`?: boolean - keeps the order of wire controls and colors (e.g. for debugging)
 */
/datum/wirePanel/panelDefintion
	/// Ordered list of `wirePanel/wireDefintion`. Defintions for each wire
	var/list/datum/wirePanel/wireDefintion/wire_definitions = list()
	/// Ordered List of `wirePanel/indicatorDefintion. All available indicator lights for this defintion
	var/list/datum/wirePanel/indicatorDefintion/indicator_lights = list()

/datum/wirePanel/panelDefintion/New(
	list/controls,
	list/color_pool,
	list/custom_acts,
	indicators,
	datum/wirePanel/indicatorMap/light_map,
	keep_order=FALSE,
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
		var/control_pick = rand(1, length(controls))
		var/color_pick = rand(1, length(color_pool))
		if (keep_order)
			control_pick = 1
			color_pick = 1

		var/datum/wirePanel/wireDefintion/wire_definition = new /datum/wirePanel/wireDefintion(
			controls = controls[control_pick],
			wire_color = color_pool[color_pick]
		)

		// handle what controls need to be fixed specifically fixed, i.e. only pulses can fix a control
		for (var/datum/wirePanel/wireActs/act in custom_acts)
			if (act.control_flag == controls[control_pick])
				wire_definition.actions_to_fix = act.fix_act
				wire_definition.actions_to_break = act.break_act

		src.wire_definitions += wire_definition

		indicator_bitfield |= controls[control_pick]

		controls -= controls[control_pick]
		color_pool -= color_pool[color_pick]

	if (indicators == -1) // don't track indicators
		return
	if (indicators >= 1) // only track specific indicators
		indicator_bitfield = indicators

	for (var/datum/wirePanel/indicatorDefintion/indicator in light_map.indicators)
		if (HAS_ALL_FLAGS(indicator_bitfield, indicator.control_flags))
			src.indicator_lights += list(indicator)
