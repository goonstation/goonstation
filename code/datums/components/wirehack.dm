/**
 * Machinery wire hacking component
 *
 * For performance, tracked in parallel arrays:
 * 	/datum/wireDefinition - shared definition for machines: color, function flag
 * 		Define this as a static variable on the object, so the wires are consistent across the object class
 *
 * 	/datum/component/wireStatus - individual machine status: track wire status & flags
 * 		Define this in New()
 *
 * TODO: pass in color map instead of array to support TGUI
 * TODO: standardize output for TGUI
 * TODO: write reusable UI component
 */


// #define KEEP_WIRE_ORDER /// Debug - Do not randomize wire color or function

/datum/wireDefinition
	var/list/wire_color
	var/list/wire_function

/***
 * functions = list of wire functions - see `obj.dm` defines
 * colors = list of wire colors
 */
/datum/wireDefinition/New(var/list/functions, var/list/colors)
	..()
	if (length(functions) > length(colors))
		CRASH("Tried to create wireDefinition with fewer colors than functions")
	var/count = length(functions)
	for (var/i in 1 to count)
		// color and function randomization
		#ifdef KEEP_WIRE_ORDER
		var/color = colors[i]
		#else
		var/color = pick(colors)
		#endif
		colors -= color

		#ifdef KEEP_WIRE_ORDER
		var/function = functions[i]
		#else
		var/function = pick(functions)
		#endif
		functions -= function

		wire_color += list(color)
		wire_function += list(function)

/datum/wireDefinition/proc/ui_static_wire_data()
	return list()

TYPEINFO(/datum/component/wireStatus)
	initialization_args = list(
		ARG_INFO("definition", DATA_INPUT_REF, "Datum holding our wire defintion"),
	)

/datum/component/wireStatus
	var/list/cut_wires = list()
	var/wire_flags = 0
	var/datum/wireDefinition/wire_definition

/datum/component/wireStatus/Initialize(_definition)
	. = ..()
	src.wire_definition = _definition
	for (var/wire in src.wire_definition.wire_function)
		cut_wires += list(FALSE)
	RegisterSignal(parent, COMSIG_WIRE_HACK_CUT, .proc/cut)
	RegisterSignal(parent, COMSIG_WIRE_HACK_PULSE, .proc/pulse)
	RegisterSignal(parent, COMSIG_WIRE_HACK_BITE, .proc/bite)

/datum/component/wireStatus/proc/pulse(datum/source, wire)
	if (!usr.find_tool_in_hand(TOOL_PULSING) && !isAI(usr))
		boutput(usr, "You need a multitool or similar!")
		return
	if (cut_wires[wire])
		boutput(usr, "You can't pulse a cut wire.")
		return
	return TRUE

/datum/component/wireStatus/proc/cut(datum/source, wire)
	if (!usr.find_tool_in_hand(TOOL_SNIPPING))
		boutput(usr, "You need a snipping tool!")
		return
	if(!cut_wires[wire])
		cut_wires[wire] = TRUE
		wire_flags |= wire_definition.wire_function[wire]
	else // mend
		cut_wires[wire] = FALSE
		wire_flags &= ~wire_definition.wire_function[wire]
	return TRUE

/datum/component/wireStatus/proc/bite(wire)
	if(!cut_wires[wire])
		cut_wires[wire] = TRUE
		wire_flags |= wire_definition.wire_function[wire]
		return TRUE

/datum/component/wireStatus/proc/ui_wire_data()
	return list()

// #undef KEEP_WIRE_ORDER
