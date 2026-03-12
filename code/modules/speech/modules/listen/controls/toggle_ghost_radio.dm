/datum/listen_module/control/client_verb/toggle_ghost_radio
	id = LISTEN_CONTROL_TOGGLE_GHOST_RADIO
	proc_path = /client/proc/toggle_ghost_radio

/datum/listen_module/control/client_verb/toggle_ghost_radio/initialise()
	var/mob/mob_listener = src.parent_tree.listener_parent
	if (!istype(mob_listener) || !mob_listener.client)
		return

	var/datum/listen_module/input/global_radio/ghost/module = src.parent_tree.GetInputByID(LISTEN_INPUT_RADIO_GLOBAL_GHOST)
	if (!module)
		return

	if (mob_listener.client.mute_ghost_radio)
		module.disable()
	else
		module.enable()


/client/var/mute_ghost_radio = FALSE
/client/proc/toggle_ghost_radio()
	set name = "Toggle Ghost Radio"
	set desc = "Toggle whether you can hear radio chatter while dead."
	set category = "Ghost"
	SHOW_VERB_DESC

	if (!src.mob || !src.mob.listen_tree)
		return

	var/datum/listen_module/input/global_radio/ghost/module = src.mob.listen_tree.GetInputByID(LISTEN_INPUT_RADIO_GLOBAL_GHOST)
	if (!module)
		return

	src.mute_ghost_radio = !src.mute_ghost_radio
	if (src.mute_ghost_radio)
		module.disable()
	else
		module.enable()

	boutput(src, SPAN_NOTICE("[src.mute_ghost_radio ? "No longer" : "Now"] hearing radio as a ghost."))
