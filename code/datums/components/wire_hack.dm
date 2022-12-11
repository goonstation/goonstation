/**
 * Wire hacking component
 *
 * State of each wire is tracked in parallel lists across two objects.
 *
 * Checks tool_flags and returns relevant player feedback
 *
 * Parents are responsible for what they do with that state
 *
 *
 * TODO: state - keep track of panel open state?
 * TODO: state - manage hint light data?
 * TODO: state -mapping support for preset cut wires (azones?)
 * TODO: ui - pass in color map instead of list to support TGUI
 * TODO: ui - standardize output for TGUI
 * TODO: ui - write TGUI data component ala ReagentStatus
 * TODO: implementation - cut down on defines by allowing duplicate entries in effects list?
 */

/// Debug - Do not randomize wire color or function
#define KEEP_WIRE_ORDER FALSE

/**
 * Definiton of a wire panel.
 *
 * Automatically randomizes effects and colors when created.
 *
 * You can add more colors than effects to add variety in color choices round-by-round.
 *
 */
/datum/wireDefinition
	/// indexed list of wire effects
	var/list/wire_effect
	/// indexed list of wire colors
	var/list/wire_color
	/// flags that require a successful mend (i.e. APC shorting)
	var/require_mend
	/// flags that require a successful pulse (i.e. Airlock door bolts)
	var/require_pulse

/***
 * Enables all atoms of a type have the same wire color-to-function mapping.
 *
 * Best used as a static variable per path.
 *
 * Arguments:
 * * list/effects list of wire effects - see `obj.dm` defines
 * * list/colors list of wire colors
 * * mend_required `wire_effect` flags that require mending to remove
 * * pulse_rquired `wire_effect` flags that require pulsing to remove
 */
/datum/wireDefinition/New(list/effects, list/colors, mend_required=0, pulse_required=0)
	. = ..()
	if (length(effects) > length(colors))
		CRASH("Tried to create wireDefinition with fewer colors than effects")
	require_mend = mend_required
	require_pulse = pulse_required
	var/count = length(effects)
	for (var/i in 1 to count)
		// color and effect randomization
		#if KEEP_WIRE_ORDER
		var/color = colors[i]
		#else
		var/color = pick(colors)
		#endif
		colors -= color

		#if KEEP_WIRE_ORDER
		var/effect = effects[i]
		#else
		var/effect = pick(effects)
		#endif
		effects -= effect

		wire_color += list(color)
		wire_effect += list(effect)

TYPEINFO(/datum/component/wireStatus)
	initialization_args = list(
		ARG_INFO("definition", DATA_INPUT_REF, "Datum holding our wire defintion"),
	)
/datum/component/wireStatus
	/// list of booleans to track which wires are cut
	var/list/cut_wires = list()
	/// which wire flags are set
	var/wire_effect_flags
	/// Reference to a wire defintion datum, set in Initialize
	var/datum/wireDefinition/wire_definition

/datum/component/wireStatus/Initialize(_definition)
	. = ..()
	wire_definition = _definition
	for (var/wire in wire_definition.wire_effect)
		cut_wires += list(FALSE)
	RegisterSignal(parent, COMSIG_WIRE_HACK_CUT, .proc/cut)
	RegisterSignal(parent, COMSIG_WIRE_HACK_MEND, .proc/mend)
	RegisterSignal(parent, COMSIG_WIRE_HACK_MOB_SNIP, .proc/mob_snip)
	RegisterSignal(parent, COMSIG_WIRE_HACK_MOB_PULSE, .proc/mob_pulse)
	RegisterSignal(parent, COMSIG_WIRE_HACK_FLAGS, .proc/flags)

/**
 * Cut a wire.
 *
 * Changes bool state in cut_wires. Returns TRUE if the state was changed.
 *
 * Arguments:
 * * wire index of the wire to affect.
 */
/datum/component/wireStatus/proc/cut(datum/source, wire)
	if(!cut_wires[wire])
		cut_wires[wire] = TRUE
		ADD_FLAG(wire_effect_flags, wire_definition.wire_effect[wire])
		return TRUE

/**
 * Mend a wire.
 *
 * Changes state in cut_wires.  Returns TRUE if the state was changed.
 *
 * Arguments:
 * * wire index of the wire to affect.
 *
 * Returns TRUE if the state was changed.
 */
/datum/component/wireStatus/proc/mend(datum/source, wire)
	if (cut_wires[wire])
		cut_wires[wire] = FALSE
		if (!HAS_FLAG(wire_definition.require_pulse, wire_definition.wire_effect[wire]))
			REMOVE_FLAG(wire_effect_flags, wire_definition.wire_effect[wire])
		return TRUE

/**
 * Mob attempting to snip a given wire.
 *
 * Returns TRUE if state was changed.
 *
 * Arguments:
 * * wire index of the wire to affect.
 * * mob/user who is using the tool
 */
/datum/component/wireStatus/proc/mob_snip(datum/source, wire, mob/user)
	if (!user.find_tool_in_hand(TOOL_SNIPPING))
		boutput(user, "You need a snipping tool!")
		return
	if(!cut_wires[wire])
		return src.cut(source, wire)
	return src.mend(source, wire)

/**
 * Mob attempting to pulse a given wire.
 *
 * Returns TRUE on successful pulse.
 *
 * Arguments:
 * * wire index of the wire to affect.
 * * mob/user who is using the tool
*/
/datum/component/wireStatus/proc/mob_pulse(datum/source, wire, mob/user)
	if (!user.find_tool_in_hand(TOOL_PULSING) && !isAI(user))
		boutput(user, "You need a multitool or similar!")
		return
	if (cut_wires[wire])
		boutput(user, "You can't pulse a cut wire.")
		return
	if (!HAS_FLAG(wire_effect_flags, wire_definition.wire_effect[wire]))
		ADD_FLAG(wire_effect_flags, wire_definition.wire_effect[wire])
		return TRUE
	if (!HAS_FLAG(wire_definition.require_mend, wire_definition.wire_effect[wire]))
		REMOVE_FLAG(wire_effect_flags, wire_definition.wire_effect[wire])
	return TRUE

/**
 * Returns a list of all active flags
 */
/datum/component/wireStatus/proc/flags()
	return wire_effect_flags

#undef KEEP_WIRE_ORDER
