/datum/listen_module/control/client_verb/toggle_ghost_global_hearing
	id = LISTEN_CONTROL_TOGGLE_GLOBAL_HEARING_GHOST
	proc_path = /client/proc/toggle_ghost_global_hearing

/datum/listen_module/control/client_verb/toggle_ghost_global_hearing/initialise()
	var/mob/mob_listener = src.parent_tree.listener_parent
	if (!istype(mob_listener) || !mob_listener.client)
		return

	var/datum/listen_module/input/ears = src.parent_tree.GetInputByID(LISTEN_INPUT_EARS_GHOST)
	var/datum/listen_module/input/global_hearing = src.parent_tree.GetInputByID(LISTEN_INPUT_GLOBAL_HEARING_GHOST)
	var/datum/listen_module/input/global_hearing_counterpart = src.parent_tree.GetInputByID(LISTEN_INPUT_GLOBAL_HEARING_LOCAL_COUNTERPART_GHOST)
	if (!ears || !global_hearing || !global_hearing_counterpart)
		return

	if (mob_listener.client.preferences.local_deadchat)
		ears.enable()
		global_hearing.disable()
		global_hearing_counterpart.disable()
	else
		ears.disable()
		global_hearing.enable()
		global_hearing_counterpart.enable()


/client/proc/toggle_ghost_global_hearing()
	set name = "Toggle Ghost Global Hearing"
	set desc = "Toggle whether you can hear all chat while dead or just local chat."
	set category = "Ghost"
	SHOW_VERB_DESC

	if (!src.mob || !src.mob.listen_tree)
		return

	var/datum/listen_module/input/ears = src.mob.listen_tree.GetInputByID(LISTEN_INPUT_EARS_GHOST)
	var/datum/listen_module/input/global_hearing = src.mob.listen_tree.GetInputByID(LISTEN_INPUT_GLOBAL_HEARING_GHOST)
	var/datum/listen_module/input/global_hearing_counterpart = src.mob.listen_tree.GetInputByID(LISTEN_INPUT_GLOBAL_HEARING_LOCAL_COUNTERPART_GHOST)
	if (!ears || !global_hearing || !global_hearing_counterpart)
		return

	src.preferences.local_deadchat = !src.preferences.local_deadchat
	if (src.preferences.local_deadchat)
		ears.enable()
		global_hearing.disable()
		global_hearing_counterpart.disable()
	else
		ears.disable()
		global_hearing.enable()
		global_hearing_counterpart.enable()

	boutput(src, SPAN_NOTICE("[src.preferences.local_deadchat ? "Now" : "No longer"] hearing local chat only."))
