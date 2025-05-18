/datum/listen_module/control/client_verb/toggle_admin_global_hearing
	id = LISTEN_CONTROL_TOGGLE_GLOBAL_HEARING_ADMIN
	proc_path = /client/proc/toggle_admin_global_hearing

/datum/listen_module/control/client_verb/toggle_admin_global_hearing/initialise()
	var/mob/mob_listener = src.parent_tree.listener_parent
	if (!istype(mob_listener) || !mob_listener.client)
		return

	var/datum/listen_module/input/global_hearing = src.parent_tree.GetInputByID(LISTEN_INPUT_GLOBAL_HEARING)
	var/datum/listen_module/input/global_hearing_counterpart = src.parent_tree.GetInputByID(LISTEN_INPUT_GLOBAL_HEARING_LOCAL_COUNTERPART)
	if (!global_hearing || !global_hearing_counterpart)
		return

	if (mob_listener.client.admin_global_hearing)
		global_hearing.enable()
		global_hearing_counterpart.enable()
	else
		global_hearing.disable()
		global_hearing_counterpart.disable()


/client/var/admin_global_hearing = FALSE
/client/proc/toggle_admin_global_hearing()
	set name = "Toggle Hearing All"
	set desc = "Toggles the ability to hear all messages regardless of where you are, like a ghost."
	SET_ADMIN_CAT(ADMIN_CAT_SELF)
	ADMIN_ONLY
	SHOW_VERB_DESC

	if (!src.mob || !src.mob.listen_tree)
		return

	var/datum/listen_module/input/global_hearing = src.mob.listen_tree.GetInputByID(LISTEN_INPUT_GLOBAL_HEARING)
	var/datum/listen_module/input/global_hearing_counterpart = src.mob.listen_tree.GetInputByID(LISTEN_INPUT_GLOBAL_HEARING_LOCAL_COUNTERPART)
	if (!global_hearing || !global_hearing_counterpart)
		return

	src.admin_global_hearing = !src.admin_global_hearing
	if (src.admin_global_hearing)
		global_hearing.enable()
		global_hearing_counterpart.enable()
	else
		global_hearing.disable()
		global_hearing_counterpart.disable()

	boutput(src, SPAN_NOTICE("Toggled seeing all messages [src.admin_global_hearing ? "on" : "off"]!"))
