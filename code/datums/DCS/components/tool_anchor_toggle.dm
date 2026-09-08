TYPEINFO(/datum/component/tool_anchor_toggle)
	initialization_args = list(
		ARG_INFO("tools", DATA_INPUT_BITFIELD, "The tool type(s) needed to (un)anchor the atom. Takes tool bitflags, like TOOL_WELDING", TOOL_SCREWING),
		ARG_INFO("action_time", DATA_INPUT_NUM, "How much time (un)anchoring the atom should take, if any at all.", 0),
		ARG_INFO("cooldown_time", DATA_INPUT_NUM, "How much time must elapse between (un)anchorings, to prevent spam if desired.", 0),
	)

/// Allows atom/movables to be (un)anchored using the specified tool(s), with optional actionbar and cooldown
/datum/component/tool_anchor_toggle
	/// What tool flags will (un)anchor our parent? (Default: Screwdriver)
	var/tool_types = null
	var/sound2play = 'sound/items/Screwdriver.ogg'
	var/anchor_prefix = "screws"
	var/unanchor_prefix = "unscrews"
	var/actionbar_time = 0
	var/cooldown = 0
	var/atom/movable/parent_atom = null
	var/datum/action/bar/icon/callback/actionbar

/datum/component/tool_anchor_toggle/Initialize(tools = TOOL_SCREWING, action_time = 0, cooldown_time = 0)
	if(!ismovable(src.parent))
		return COMPONENT_INCOMPATIBLE
	. = ..()
	src.tool_types = tools
	src.actionbar_time = action_time
	src.cooldown = cooldown_time
	src.parent_atom = parent
	RegisterSignal(parent, COMSIG_ATTACKBY, PROC_REF(attackby))

/datum/component/tool_anchor_toggle/UnregisterFromParent()
	. = ..()
	src.UnregisterSignal(parent, COMSIG_ATTACKBY)

/datum/component/tool_anchor_toggle/proc/attackby(datum/source, obj/item/W, mob/user)
	if(!istool(W, src.tool_types))
		return
	. = 1 // we want to stop atom/attackby() to avoid this tool doing anything but toggling anchor
	if(src.cooldown && ON_COOLDOWN(src.parent_atom, "toggle_anchor", src.cooldown))
		return
	if(!isturf(src.parent_atom.loc))
		boutput(user, SPAN_ALERT("[src.parent] needs to be on the ground to do that!"))
		return
	if(src.parent_atom.anchored == MAGIC_GLUE_ANCHORED)
		boutput(user, SPAN_ALERT("[src.parent] is glued in place, you can't just secure or free it with [src.parent]!"))
		return
	if(src.parent_atom.anchored >= ANCHORED_ALWAYS)
		return
	if(!src.cache_effects(W, user))
		logTheThing(LOG_DEBUG, src, "Invalid tool type ([W]) used on [src.parent]. [src] does not support this tool yet.")
		// adding new tools is easy, just go to cache_effects() and add your prefix/suffix/sound to the if/else sequence
		return
	if(isweldingtool(W))
		if(!W:try_weld(user))
			return
	else //try_weld() already does sound
		playsound(src.parent_atom.loc, src.sound2play, 50, 1)
	if(src.actionbar_time)
		src.actionbar = SETUP_GENERIC_ACTIONBAR(user, src.parent_atom, src.actionbar_time, PROC_REF(toggle_anchor), list(W, user), \
			W.icon, W.icon_state, null, INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_ATTACKED | INTERRUPT_STUNNED | INTERRUPT_ACTION)
		src.actionbar.call_proc_on = src
	else
		src.toggle_anchor(W, user)

/datum/component/tool_anchor_toggle/proc/cache_effects(obj/item/W, mob/user)
	. = FALSE
	if(istool(W, TOOL_SCREWING))
		src.sound2play = 'sound/items/Screwdriver.ogg'
		src.anchor_prefix = "screws"
		src.unanchor_prefix = "unscrews"
		. = TRUE
	else if(istool(W, TOOL_WRENCHING))
		src.sound2play = 'sound/items/Ratchet.ogg'
		src.anchor_prefix = "wrenches"
		src.unanchor_prefix = "unwrenches"
		. = TRUE
	else if(istool(W, TOOL_WELDING))
		src.sound2play = null // welders make their own sound from try_weld()
		src.anchor_prefix = "welds"
		src.unanchor_prefix = "cuts"
		. = TRUE

/datum/component/tool_anchor_toggle/proc/toggle_anchor(obj/item/W, mob/user)
	if(src.parent_atom.anchored == ANCHORED)
		user?.visible_message(SPAN_NOTICE("<b>[user.name]</b> [src.unanchor_prefix] [src.parent] free."))
		src.parent_atom.anchored = UNANCHORED
	else
		user?.visible_message(SPAN_NOTICE("<b>[user.name]</b> [src.anchor_prefix] [src.parent] into place."))
		src.parent_atom.anchored = ANCHORED
