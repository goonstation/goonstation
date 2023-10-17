/datum/wirePanel

/datum/wirePanel/wireDefintion
	var/color_name
	var/color_value
	var/control_flags
	var/hack
	var/fix

/datum/wirePanel/wireDefintion/New(wire_color="red", controls=WIRE_CONTROL_INERT, to_hack=WIRE_ACT_CUT_PULSE, to_fix=WIRE_ACT_CUT_PULSE)
	. = ..()
	src.color_name = wire_color
	src.control_flags = controls
	src.hack = to_hack
	src.fix = to_fix

/// Fetches the RGB color value from the global `named_colors`
/datum/wirePanel/wireDefintion/proc/cache_color()
	if (!src.color_value)
		var/datum/named_color/C = get_color_by_name(src.color_name)
		if (istype(C))
			src.color_value = rgb(C.r, C.g, C.b)

ABSTRACT_TYPE(/datum/wirePanel/panelDefintion)
/datum/wirePanel/panelDefintion
	/// list of wire defintions, set once per panel definiton
	var/list/wire_definition = list()
	/// Randomize the order of wires
	var/randomize_wire_order = TRUE
	/// Randomize the color of wires
	// var/randomize_wire_colors = FALSE // [ ] implement
	/// Show status of these controls in the UI (default: All)
	var/controls_to_show = ~0
	/// Stored order of the list
	var/list/datum/wirePanel/wireDefintion/by_order = list()

/datum/wirePanel/panelDefintion/proc/deserialize()
	if (length(src.by_order))
		return

	if (!length(src.wire_definition))
		logTheThing(LOG_DEBUG, src, "Tried to generate wire panel with no wires.")

	if (src.randomize_wire_order)
		shuffle_list(src.wire_definition)

	for (var/i in 1 to length(src.wire_definition))
		src.by_order += new /datum/wirePanel/wireDefintion(wire_definition[i][1], wire_definition[i][2], wire_definition[i][3], wire_definition[i][4])

