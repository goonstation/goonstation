/datum/component/player_piano_auto_linker
	var/list/pianos

TYPEINFO(/datum/component/player_piano_auto_linker)
	initialization_args = list(
		ARG_INFO("start_piano", DATA_INPUT_REF, "The first piano to store", null),
		ARG_INFO("user", DATA_INPUT_REF, "The user who's using this", null)
	)

/datum/component/player_piano_auto_linker/Initialize(atom/start_piano, atom/user)
	. = ..()
	if (!ispulsingtool(parent) || start_piano == null || user == null || !istype(start_piano, /obj/player_piano) || !istype(user, /mob))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_ITEM_ATTACKBY_PRE, PROC_REF(store_piano))
	RegisterSignal(parent, COMSIG_ITEM_ATTACK_SELF, PROC_REF(finish_storing_pianos))
	src.pianos = list()
	src.start_storing_pianos(start_piano, user)

/datum/component/player_piano_auto_linker/proc/can_store_piano(obj/player_piano/piano, mob/user)
	if (piano.is_busy)
		boutput(user, SPAN_ALERT("Can't link a busy piano!"))
		return FALSE
	if (!piano.panel_exposed)
		boutput(user, SPAN_ALERT("Can't link without an exposed panel!"))
		return FALSE
	if (length(piano.linked_pianos))
		boutput(user, SPAN_ALERT("Can't link an already linked piano!"))
		return FALSE
	if (piano in src.pianos)
		boutput(user, SPAN_ALERT("That piano is already stored!"))
		return FALSE
	if (piano.is_stored)
		boutput(user, SPAN_ALERT("Another device has already stored that piano!"))
		return FALSE
	return TRUE

/datum/component/player_piano_auto_linker/proc/link_pianos()
	var/list/linking_pianos = src.pianos.Copy()
	while (length(linking_pianos))
		var/obj/player_piano/link_from = linking_pianos[1]
		linking_pianos.Cut(1,2)
		if (link_from == null)
			break
		for (var/obj/player_piano/link_to as anything in linking_pianos)
			if (link_to == null)
				break
			link_from.add_piano(link_to)
			link_to.add_piano(link_from)
			sleep(0.1 SECOND)

/datum/component/player_piano_auto_linker/proc/start_storing_pianos(obj/player_piano/piano, mob/user)
	boutput(user, SPAN_NOTICE("Now [parent] is storing pianos to link. Use it in hand to link them."))
	piano.is_stored = TRUE
	src.pianos.Add(piano)
	boutput(user, SPAN_NOTICE("Stored piano."))
	return

/datum/component/player_piano_auto_linker/proc/store_piano(obj/item/pulser, atom/A, mob/user)
	if (!istype(A, /obj/player_piano))
		return FALSE
	var/obj/player_piano/piano = A
	if (!src.can_store_piano(piano, user))
		return TRUE
	piano.is_stored = TRUE
	src.pianos.Add(piano)
	boutput(user, SPAN_NOTICE("Stored piano."))
	return TRUE

/datum/component/player_piano_auto_linker/proc/finish_storing_pianos(obj/item/pulser, mob/user)
	if (length(src.pianos) < 2)
		boutput(user, SPAN_ALERT("You must have at least two pianos to link!"))
		src.RemoveComponent()
		return TRUE
	boutput(user, SPAN_NOTICE("Linking pianos..."))
	src.link_pianos()
	boutput(user, SPAN_NOTICE("Finished linking."))
	src.RemoveComponent()
	return TRUE

/datum/component/player_piano_auto_linker/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ITEM_ATTACKBY_PRE)
	UnregisterSignal(parent, COMSIG_ITEM_ATTACK_SELF)
	for (var/obj/player_piano/piano as anything in src.pianos)
		if (piano != null)
			piano.is_stored = FALSE
	. = ..()
