/obj/item/device/pager
	name = "centcom pager"
	icon_state = "pager"
	var/icon_state_received = "pager_receive"
	flags = TABLEPASS | CONDUCT
	c_flags = ONBELT
	force = 5
	w_class = W_CLASS_SMALL
	desc = "A pager designed for direct communication with Nanotrasen Central Command"
	var/list/message_history = list()
	var/theme = "ntos"
	var/max_length = 400

	New()
		. = ..()
		START_TRACKING

	disposing()
		STOP_TRACKING
		. = ..()

	attack_self(var/mob/user)
		if(!ishuman(user))
			boutput(user, "You don't know how to read!")
			return
		src.ui_interact(user)

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if(!ui)
			ui = new(user, src, "Pager", src.name)
			ui.open()

	ui_data(mob/user)
		. = list(
			"theme" = src.theme,
			"message_history" = src.message_history,
			"max_length" = src.max_length
		)

	ui_act(action, params)
		. = ..()
		if (.)
			return
		switch(action)
			if ("send")
				src.send_message(usr, params["value"])
				. = TRUE

proc/send_message(var/user, var/message)
	message_admins("[user ? user : "Someone"] sent a direct message to Central Command: \"[message]\"")
	//var/ircmsg[] = new()
	//ircmsg["msg"] = "[user ? user : "Unknown"] sent a direct message to Central Command: \"[message]\""
	//ircbot.export_async("admin", ircmsg)

proc/receive_message(var/message)
	if(!istext(message))
		return
	src.icon_state = src.icon_state_received
	SPAWN(30 SECONDS)
		src.icon_state = initial(src.icon_state)
	src.message_history += message

/client/proc/cmd_admin_reply_to_pager()
	SET_ADMIN_CAT(ADMIN_CAT_FUN)
	set name = "Reply to pager"
	ADMIN_ONLY
	SHOW_VERB_DESC

	var/list/pagers = list()
	for_by_tcl(pager, /obj/item/device/pager)
		var/in_loc = ""
		if(!isturf(pager.loc))
			in_loc = " [in_or_on] [pager.loc]"
		pagers["[pager][in_loc] in [get_area(A)]]"] = pager
	if(!length(pagers))
		boutput(usr, "No pagers found.")
		return

	var/selected_pager = tgui_input_list(user, "Pick a pager to reply to", "[src]", pagers)
	if(!selected_pager)
		return
	var/input = input(usr, "Enter the text for the reply. Anything. Serious.", "What?", "") as null|text
	if(!input)
		return

	if (tgui_alert(src, "Target: \"[selected_pager]\" \nReply: \"[input]\"", "Confirmation", "Send", "Cancel" == "Send"))
		selected_pager.receive_message(input)
		logTheThing(LOG_ADMIN, src, "replies to pager [selected_pager] with \"[input]\"")
		logTheThing(LOG_DIARY, src, "replies to pager [selected_pager] with \"[input]\"", "admin")
		message_admins("[key_name(src)] replies to pager [selected_pager] with \"[input]\"")
