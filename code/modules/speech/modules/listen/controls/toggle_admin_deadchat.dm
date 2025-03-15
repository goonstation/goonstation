/datum/listen_module/control/client_verb/toggle_admin_deadchat
	id = LISTEN_CONTROL_TOGGLE_ADMIN_DEADCHAT
	proc_path = /client/proc/toggle_admin_deadchat

/datum/listen_module/control/client_verb/toggle_admin_deadchat/initialise()
	var/mob/mob_listener = src.parent_tree.listener_parent
	if (!istype(mob_listener) || !mob_listener.client)
		return

	var/datum/listen_module/input/deadchat/admin/module = src.parent_tree.GetInputByID(LISTEN_INPUT_DEADCHAT_ADMIN)
	if (!module)
		return

	if (mob_listener.client.admin_deadchat)
		module.enable()
	else
		module.disable()


/client/var/admin_deadchat = TRUE
/client/proc/toggle_admin_deadchat()
	set name = "Toggle Your Deadchat"
	set desc = "Toggle whether you can see deadchat or not"
	SET_ADMIN_CAT(ADMIN_CAT_SELF)
	ADMIN_ONLY
	SHOW_VERB_DESC
	NOT_IF_TOGGLES_ARE_OFF

	if (!src.mob || !src.mob.listen_tree)
		return

	var/datum/listen_module/input/deadchat/admin/module = src.mob.listen_tree.GetInputByID(LISTEN_INPUT_DEADCHAT_ADMIN)
	if (!module)
		return

	src.admin_deadchat = !src.admin_deadchat
	if (src.admin_deadchat)
		module.enable()
	else
		module.disable()

	boutput(src, SPAN_NOTICE("[src.admin_deadchat ? "Now" : "No longer"] viewing deadchat."))
