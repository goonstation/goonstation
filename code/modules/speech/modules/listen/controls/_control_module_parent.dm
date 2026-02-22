ABSTRACT_TYPE(/datum/listen_module/control)
/**
 *	Listen control module datums permit the manipulation of other listen modules to be linked to a module that may be added to a
 *	listen module tree.
 */
/datum/listen_module/control
	id = "control_base"

/// Set up the initial state of the module or modules that this control module manages.
/datum/listen_module/control/proc/initialise()
	return


ABSTRACT_TYPE(/datum/listen_module/control/client_verb)
/**
 *	Client verb listen control module datums permit other listen modules to be manipulated through the use of a verb added to a
 *	client. The module handles updating client verb lists as they log in and out of the parent tree's listener parent.
 */
/datum/listen_module/control/client_verb
	id = "client_verb_base"
	/// The path of the proc that this module should add to the client's verb list.
	var/proc_path

/datum/listen_module/control/client_verb/New(datum/listen_module_tree/parent)
	. = ..()

	src.update_listener_parent(null, null, src.parent_tree.listener_parent)
	src.RegisterSignal(src.parent_tree, COMSIG_LISTENER_PARENT_UPDATED, PROC_REF(update_listener_parent))

/datum/listen_module/control/client_verb/disposing()
	src.update_listener_parent(null, src.parent_tree.listener_parent, null)
	src.UnregisterSignal(src.parent_tree, COMSIG_LISTENER_PARENT_UPDATED)

	. = ..()

/// Updates the signals registered to the parent tree's listener parent.
/datum/listen_module/control/client_verb/proc/update_listener_parent(tree, mob/old_parent, mob/new_parent)
	if (istype(old_parent))
		if (old_parent.client)
			src.client_logout(old_parent, old_parent.client)

		src.UnregisterSignal(old_parent, COMSIG_MOB_LOGOUT)
		src.UnregisterSignal(old_parent, COMSIG_MOB_LOGIN)

	if (istype(new_parent))
		if (new_parent.client)
			src.client_login(new_parent)

		src.RegisterSignal(new_parent, COMSIG_MOB_LOGOUT, PROC_REF(client_logout))
		src.RegisterSignal(new_parent, COMSIG_MOB_LOGIN, PROC_REF(client_login))

/// Updates a client's verbs when they log out of the parent tree's listener parent.
/datum/listen_module/control/client_verb/proc/client_logout(mob/parent, client/client_override)
	var/client/C = client_override || parent.last_client
	C?.verbs -= src.proc_path

/// Updates a client's verbs when they log into the parent tree's listener parent.
/datum/listen_module/control/client_verb/proc/client_login(mob/parent)
	parent.client.verbs += src.proc_path
	SPAWN(1)
		if (QDELETED(src))
			return

		src.initialise()
