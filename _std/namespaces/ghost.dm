/// Namespace for ghost related constants and procs.
CREATE_NAMESPACE(GHOST)


/// Returns a list of all ghost-observable atoms.
ADD_TO_NAMESPACE(GHOST)(proc/get_observables())
	RETURN_TYPE(/list/atom)
	. = list()

	for (var/atom/A as anything in global.by_cat[TR_CAT_GHOST_OBSERVABLES])
		if (GHOST.can_observe(A))
			. += A

/// Returns TRUE is the specified atom can be observed by a ghost.
ADD_TO_NAMESPACE(GHOST)(proc/can_observe(atom/A))
	if (QDELETED(A) || isnull(A.loc))
		return FALSE

	if (!A.HasElement(/datum/element/ghost_observable))
		return FALSE

	if (ismob(A))
		var/mob/M = A

		// Admins aren't observable unless they're in player mode.
		if (M.client?.holder && !M.client.player_mode)
			return FALSE

		// Any secret mobs that someone is controlling.
		if (M.unobservable)
			return FALSE

		// Disallow azone NPCs outside of station, debris, and mining z-levels.
		var/is_npc = (M.client == null) && (M.ghost == null)
		if (is_npc && isrestrictedz(M.z))
			return FALSE

	return TRUE


//------------ Messages ------------//
/// Ghost message procs.
CREATE_NAMESPACE(GHOST, MESSAGE)

/// The announcer say source that `GHOST.MESSAGE.send()` should use.
ADD_TO_NAMESPACE(GHOST, MESSAGE)(var/atom/movable/abstract_say_source/deadchat/announcer = new())

/**
 *	Used to send a message to all ghosts (excluding wraiths) when something interesting has happened.
 *
 *	Any message sent to this should just be a funny comment on something logged elsewhere, so they probably don't need to
 *	be logged here again (e.g. death alerts).
 */
ADD_TO_NAMESPACE(GHOST, MESSAGE)(proc/send(message))
	var/list/mob/living/intangible/wraith/wraiths = list()
	for (var/datum/antagonist/antagonist_datum as anything in global.get_all_antagonists(ROLE_WRAITH))
		wraiths[antagonist_datum.owner.current] = TRUE

	src.announcer.say(message, flags = SAYFLAG_IGNORE_HTML, message_params = list("atom_listeners_to_be_excluded" = wraiths))

/// Formats the name of a mob as `<b>Name</b>`, with a link to observe that mob.
ADD_TO_NAMESPACE(GHOST, MESSAGE)(proc/format_atom(atom/A, display_text, plaintext = FALSE))
	if (!istype(A))
		return

	display_text ||= "<b>[A.name]</b>"
	if (plaintext || !GHOST.can_observe(A))
		return display_text

	return "<a href='byond://?src=\ref[GHOST.MESSAGE.TOPIC];action=observe_atom;target=\ref[A]' title='Observe'>[display_text]</a>"

/// Formats the position of an atom as `(x, y, z) in Location`, with a link to teleport to those coordinates.
ADD_TO_NAMESPACE(GHOST, MESSAGE)(proc/format_loc(atom/A, plaintext = FALSE))
	if (!istype(A))
		return

	var/turf/T = get_turf(A)
	if (!T)
		return "(?, ?, ?) in Unknown"

	if (isrestrictedz(T.z))
		plaintext = TRUE

	var/coordinates = null
	if (plaintext)
		coordinates = "[T.x], [T.y], [T.z]"
	else
		coordinates = "<a href='byond://?src=\ref[GHOST.MESSAGE.TOPIC];action=jump_coords;target=\ref[T]' title='Jump to Coords'>[T.x], [T.y], [T.z]</a>"

	return "([coordinates]) in [T.loc]"


//------------ Message Topic ------------//
/// Ghost Topic handing for messages.
CREATE_NAMESPACE(GHOST, MESSAGE, TOPIC)

ADD_TO_NAMESPACE(GHOST, MESSAGE, TOPIC)(Topic(href, href_list))
	if (!isdead(usr))
		return

	var/mob/dead/user = usr

	switch (href_list["action"])
		if ("jump_coords")
			var/turf/target = locate(href_list["target"])
			if (!istype(target))
				return

			src.jump_coords(user, target)

		if ("observe_atom")
			var/atom/target = locate(href_list["target"])
			if (!istype(target) || QDELETED(target))
				return

			src.observe_atom(user, target)

ADD_TO_NAMESPACE(GHOST, MESSAGE, TOPIC)(proc/to_ghost(mob/M))
	PRIVATE_PROC(TRUE)
	RETURN_TYPE(/mob/dead/observer)

	if (istype(M, /mob/dead/observer))
		return M

	if (istype_exact(M, /mob/dead/target_observer))
		var/mob/dead/target_observer/observer = M
		return observer.to_ghost()

ADD_TO_NAMESPACE(GHOST, MESSAGE, TOPIC)(proc/observe_atom(mob/dead/user, atom/target))
	PRIVATE_PROC(TRUE)

	if (!GHOST.can_observe(target))
		return

	src.to_ghost(user)?.insert_observer(target)

ADD_TO_NAMESPACE(GHOST, MESSAGE, TOPIC)(proc/jump_coords(mob/dead/user, turf/target))
	PRIVATE_PROC(TRUE)

	if (!global.can_ghost_be_here(user, target))
		return

	src.to_ghost(user)?.set_loc(target)
