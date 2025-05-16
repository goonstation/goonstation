/// Components for common machine item tasks (setting output turf, filtering attackby, etc.)

#define cant_do_shit(nerd) (!isliving(nerd) || isintangible(nerd) || !can_act(nerd))

/// Provides ability to output items directly into item transfer-supporting things.
/datum/component/transfer_output
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	var/atom/output_target

/datum/component/transfer_output/Initialize()
	. = ..()
	if (!isatom(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/transfer_output/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_MOUSEDROP, PROC_REF(handle_drop))
	RegisterSignal(parent, COMSIG_TRANSFER_OUTGOING, PROC_REF(handle_outgoing))

/datum/component/transfer_output/proc/handle_outgoing(comsig_target, obj/item/outgoing)
	if(!output_target)
		return FALSE

	if(!in_interact_range(parent, output_target))
		src.output_target = null
		return FALSE

	if(isturf(output_target))
		outgoing.set_loc(output_target)
		return TRUE

	return SEND_SIGNAL(output_target, COMSIG_TRANSFER_INCOMING, outgoing)

/datum/component/transfer_output/proc/handle_drop(comsig_target, mob/dropper, atom/over_object)
	if(cant_do_shit(dropper))
		return

	if(over_object == parent)
		boutput(dropper, SPAN_NOTICE("You reset the output location of [parent]!"))
		src.output_target = null
		return

	if(!in_interact_range(parent, dropper))
		return

	if(!in_interact_range(over_object, parent))
		boutput(dropper, SPAN_ALERT("[over_object] is too far away!"))
		return

	if (isturf(over_object) || SEND_SIGNAL(over_object, COMSIG_TRANSFER_CAN_LINK, parent))
		boutput(dropper, SPAN_NOTICE("You set [parent] to output to [over_object]."))
		output_target = over_object
		return TRUE
	else
		boutput(dropper, SPAN_ALERT("\The [over_object] cannot be used as an output for [parent]."))


/// Provides many common item input features.
/datum/component/transfer_input
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	/// Optional proc on parent, for transfer side-effects.
	var/transfer_proc
	/// Optional list of permitted object paths.
	var/list/filter
	/// Optional proc, for filtering movables based on state.
	var/filter_proc
	/// Optional proc, for preventing things from linking.
	var/filter_link_proc

#define DEFAULT_TRANSFER_FILTER list(/obj/item/)

/datum/component/transfer_input/Initialize(list/filter=null, transfer_proc=null, filter_proc=null, filter_link_proc=null)
	. = ..()
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	src.filter = filter || DEFAULT_TRANSFER_FILTER
	src.transfer_proc = transfer_proc
	src.filter_proc = filter_proc
	src.filter_link_proc = filter_link_proc

#undef DEFAULT_TRANSFER_FILTER

/datum/component/transfer_input/RegisterWithParent()
	RegisterSignal(parent, COMSIG_TRANSFER_INCOMING, PROC_REF(handle_incoming))
	RegisterSignal(parent, COMSIG_TRANSFER_CAN_LINK, PROC_REF(handle_incoming_link))
	RegisterSignal(parent, COMSIG_ATTACKBY, PROC_REF(handle_attackby))

/datum/component/transfer_input/proc/handle_incoming_link(comsig_target, obj/other)
	return !filter_link_proc || call(parent, filter_link_proc)(other)

/datum/component/transfer_input/proc/is_permitted(atom/movable/AM)
	var/matches_filter = isnull(filter)
	for(var/type in filter)
		if (istype(AM, type))
			matches_filter = TRUE
			break

	if(isitem(AM))
		var/obj/item/I = AM
		if (I.cant_drop)
			return FALSE

	return matches_filter && (!filter_proc || call(parent, filter_proc)(AM))


/datum/component/transfer_input/proc/handle_incoming(comsig_target, atom/movable/incoming)
	if(is_permitted(incoming))
		incoming.set_loc(parent)
		if (transfer_proc)
			call(parent, transfer_proc)(incoming)
		return TRUE
	return FALSE

#define CONTAINER_CHOICE_PLACE "Place container inside"
#define CONTAINER_CHOICE_DUMP  "Dump its contents inside"

/datum/component/transfer_input/proc/handle_attackby(comsig_target, atom/movable/incoming, mob/attacker)
	if(cant_do_shit(attacker))
		return

	if (isgrab(incoming))
		var/obj/item/grab/G = incoming
		if (G.affecting)
			incoming = G.affecting
	else if (istype(incoming, /obj/item/magtractor))
		var/obj/item/magtractor/M = incoming
		if (M.holding)
			incoming = M.holding

	if (incoming.storage || istype(incoming, /obj/item/satchel) || istype(incoming, /obj/item/ore_scoop))
		var/action
		if(is_permitted(incoming))
			if(length(incoming.contents))
				action = tgui_input_list(attacker, "What do you want to do with [incoming]?", "[parent]", list(CONTAINER_CHOICE_PLACE, CONTAINER_CHOICE_DUMP))
			else
				action = CONTAINER_CHOICE_PLACE
		else
			action = CONTAINER_CHOICE_DUMP

		if (!action)
			return

		if (!in_interact_range(parent, attacker))
			boutput(attacker, SPAN_ALERT("You need to be closer to [parent] to do that."))
			return

		if (action == CONTAINER_CHOICE_DUMP)
			if (!length(incoming.contents)) // in case it changed between asking and them responding
				boutput(attacker, SPAN_ALERT("There is nothing in [incoming]!"))
				return
			if (istype(incoming, /obj/item/ore_scoop))
				var/obj/item/ore_scoop/scoop = incoming
				incoming = scoop.satchel
			var/transfers = 0
			for(var/obj/item/I in (incoming.storage?.get_contents() || incoming))
				SEND_SIGNAL(parent, COMSIG_TRANSFER_INCOMING, I)
				transfers++
			incoming.UpdateIcon()
			if (istype(incoming, /obj/item/satchel))
				var/obj/item/satchel/changed_satchel = incoming
				changed_satchel.tooltip_rebuild = 1
			if (transfers)
				attacker.visible_message(SPAN_NOTICE("[attacker] dumps [transfers] items out of [incoming] into [parent]."))
			else
				boutput(attacker, SPAN_ALERT("[parent] didn't find anything it wants in [incoming]!"))
			return TRUE

	if (SEND_SIGNAL(parent, COMSIG_TRANSFER_INCOMING, incoming))
		attacker.visible_message(SPAN_NOTICE("[attacker] places [incoming] into [parent]"))
		if(isitem(incoming))
			var/obj/item/I = incoming
			attacker.u_equip(incoming)
			I.dropped(attacker)
		return TRUE

#undef CONTAINER_CHOICE_DUMP
#undef CONTAINER_CHOICE_PLACE


// transfer_input with quick-loading abilities

/datum/component/transfer_input/quickloading/RegisterWithParent()
	..()
	RegisterSignal(parent, COMSIG_ATOM_MOUSEDROP_T, PROC_REF(handle_drop_t))

/datum/component/transfer_input/quickloading/proc/handle_drop_t(comsig_target, atom/dropped, mob/user)
	if(cant_do_shit(user))
		return

	if(!in_interact_range(parent, user))
		return

	if(!in_interact_range(dropped, parent))
		boutput(user, SPAN_ALERT("[dropped] is too far away!"))
		return

	if (istype(dropped, /obj/storage/crate) || istype(dropped, /obj/storage/cart/))
		var/obj/storage/S = dropped
		if (S.welded || S.locked)
			boutput(user, SPAN_ALERT("You have to be able to open [dropped] to quick-load from it!"))
			return

		for(var/obj/item/AM in S.contents)
			SEND_SIGNAL(parent, COMSIG_TRANSFER_INCOMING, AM)
		user.visible_message(SPAN_NOTICE("[user] quick-loads [S] into [parent]"))
	else if (isitem(dropped))
		var/obj/item/I = dropped
		if(SEND_SIGNAL(parent, COMSIG_TRANSFER_INCOMING, I))
			actions.start(new /datum/action/bar/quickload(parent, I.type), user)


/datum/action/bar/quickload
	duration = 0.1 SECONDS
	/// The target of transfers during quickloading
	var/atom/target
	/// The type of the item we are stuffing into the target.
	var/load_type

	New(atom/target, load_type)
		..()
		src.target = target
		src.load_type = load_type

	onStart()
		. = ..()
		loopStart()
		owner.visible_message(SPAN_NOTICE("[owner] begins quickly stuffing things into [target]!"))

	onUpdate()
		. = ..()
		if(BOUNDS_DIST(owner, target) > 0)
			src.interrupt(INTERRUPT_ALWAYS)

	loopStart()
		. = ..()
		if(BOUNDS_DIST(owner, target) > 0)
			src.interrupt(INTERRUPT_ALWAYS)

	onEnd()
		. = ..()
		if (!load_type)
			return
		if(BOUNDS_DIST(owner, target) > 0)
			src.interrupt(INTERRUPT_ALWAYS)
			return
		for(var/obj/item/M in view(1, owner))
			if (!M || M.loc == owner)
				continue
			if (M.type != load_type)
				continue
			if(SEND_SIGNAL(target, COMSIG_TRANSFER_INCOMING, M))
				playsound(target, 'sound/items/Deconstruct.ogg', 40, TRUE)
				onRestart()
				return

#undef cant_do_shit
