/datum/listen_module/control/client_verb/toggle_hearing_all_looc
	id = LISTEN_CONTROL_TOGGLE_HEARING_ALL_LOOC
	proc_path = /client/proc/toggle_hearing_all_looc

/datum/listen_module/control/client_verb/toggle_hearing_all_looc/New(datum/listen_module_tree/parent)
	. = ..()

	src.parent_tree.AddListenInput(LISTEN_INPUT_LOOC_ADMIN_LOCAL)
	src.parent_tree.AddListenInput(LISTEN_INPUT_LOOC_ADMIN_GLOBAL)

/datum/listen_module/control/client_verb/toggle_hearing_all_looc/disposing()
	src.parent_tree.RemoveListenInput(LISTEN_INPUT_LOOC_ADMIN_LOCAL)
	src.parent_tree.RemoveListenInput(LISTEN_INPUT_LOOC_ADMIN_GLOBAL)

	. = ..()

/datum/listen_module/control/client_verb/toggle_hearing_all_looc/initialise()
	var/mob/mob_listener = src.parent_tree.listener_parent
	if (!istype(mob_listener) || !mob_listener.client)
		return

	var/datum/listen_module/input/local_looc = src.parent_tree.GetInputByID(LISTEN_INPUT_LOOC_ADMIN_LOCAL)
	var/datum/listen_module/input/global_looc = src.parent_tree.GetInputByID(LISTEN_INPUT_LOOC_ADMIN_GLOBAL)
	if (!local_looc || !global_looc)
		return

	if (mob_listener.client.only_local_looc)
		local_looc.enable()
		global_looc.disable()
	else
		local_looc.disable()
		global_looc.enable()


/client/var/only_local_looc = FALSE
/client/proc/toggle_hearing_all_looc()
	set name = "Toggle Hearing All LOOC"
	set desc = "Toggles the ability to hear all LOOC messages regardless of where you are."
	SET_ADMIN_CAT(ADMIN_CAT_SELF)
	ADMIN_ONLY
	SHOW_VERB_DESC

	if (!src.mob || !src.mob.listen_tree)
		return

	var/datum/listen_module/input/local_looc = src.mob.listen_tree.GetInputByID(LISTEN_INPUT_LOOC_ADMIN_LOCAL)
	var/datum/listen_module/input/global_looc = src.mob.listen_tree.GetInputByID(LISTEN_INPUT_LOOC_ADMIN_GLOBAL)
	if (!local_looc || !global_looc)
		return

	src.only_local_looc = !src.only_local_looc
	if (src.only_local_looc)
		local_looc.enable()
		global_looc.disable()
	else
		local_looc.disable()
		global_looc.enable()

	boutput(src, SPAN_NOTICE("Toggled seeing all LOOC messages [src.only_local_looc ?"off":"on"]!"))
