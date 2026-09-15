/datum/component/phone_ui
	var/datum/controller_parent = null
	/// The name of the last phone we tried to dial
	var/last_called = "None"
	/// If we're in the middle of dialing
	var/dialing = FALSE

TYPEINFO(/datum/component/phone_ui)
	initialization_args = list(
		ARG_INFO("_controller_parent", DATA_INPUT_REF, "the datum containing the phone controller we care about, if it's different from our parent", null)
	)

/datum/component/phone_ui/Initialize(_controller_parent)
	. = ..()
	if(_controller_parent)
		src.controller_parent = _controller_parent
	else
		src.controller_parent = parent
	src.RegisterSignal(src.controller_parent, COMSIG_PHONE_UI_INTERACT, PROC_REF(signal_ui_interact))
	src.RegisterSignal(src.controller_parent, COMSIG_PHONE_UI_CLOSE, PROC_REF(phone_ui_close))
	src.RegisterSignal(src.controller_parent, COMSIG_PHONE_INBOUND_CONNECTION_CHECK, PROC_REF(inbound_connection_check))

/datum/component/phone_ui/UnregisterFromParent()
	src.UnregisterSignals(src.controller_parent, list(
		COMSIG_PHONE_UI_INTERACT,
		COMSIG_PHONE_UI_CLOSE,
		COMSIG_PHONE_INBOUND_CONNECTION_CHECK
	))
	. = ..()

/datum/component/phone_ui/proc/signal_ui_interact(datum/source, mob/user)
	src.ui_interact(user)

/datum/component/phone_ui/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "Phone")
		ui.open()

/datum/component/phone_ui/ui_data(mob/user)
	var/list/our_directory = list()
	SEND_SIGNAL(controller_parent, COMSIG_PHONE_GET_PHONEBOOK, our_directory)
	var/list/list/list/phonebook = list()
	for(var/P in our_directory)
		var/match_found = FALSE
		var/category = PHONE.directory[P][PHONE_CATEGORY]
		if (length(phonebook))
			for (var/i in 1 to length(phonebook))
				if (phonebook[i]["category"] == category)
					match_found = TRUE
					phonebook[i]["phones"] += list(list(
						"id" = P
					))
					break
		if (!match_found)
			phonebook += list(list(
				"category" = category,
				"phones" = list(list(
					"id" = P
				))
			))

	// The UI expects null for inCall if we're not connected
	var/incall = null
	if(SEND_SIGNAL(src.controller_parent, COMSIG_PHONE_CHECK_CONNECTED))
		incall = TRUE
	. = list(
		"dialing" = src.dialing,
		"inCall" = incall,
		"lastCalled" = src.last_called,
		"name" = PHONE.get_var(src.controller_parent, PHONE_NAME)
	)

	.["phonebook"] = phonebook

/datum/component/phone_ui/ui_act(action, params)
	. = ..()
	if (.)
		return
	switch (action)
		if ("call")
			if (src.dialing == TRUE || SEND_SIGNAL(src.controller_parent, COMSIG_PHONE_CHECK_CONNECTED))
				return
			. = TRUE
			var/id = params["target"]
			// good to double-check since uis don't immediately update
			if(!PHONE.directory[id][PHONE_UNLISTED])
				src.start_call(id)
				return
			boutput(usr, SPAN_ALERT("Unable to connect!"))

/datum/component/phone_ui/proc/start_call(target_id)
	if(SEND_SIGNAL(src.controller_parent, COMSIG_PHONE_OUTBOUND_CONNECTION_CHECK)) return

	src.dialing = TRUE
	tgui_process?.update_uis(src)

	SEND_SIGNAL(src.controller_parent, COMSIG_PHONE_INBOUND_SOUND, 'sound/machines/phones/dial.ogg')

	// in the slight chance we start dialing after the target phone blew up but before our UI updated
	try
		src.last_called = PHONE.directory[target_id][PHONE_UNLISTED] ? "Undisclosed" : "[target_id]"
	catch
		SEND_SIGNAL(src.controller_parent, COMSIG_PHONE_INBOUND_SOUND, 'sound/machines/phones/phone_busy.ogg')
		return

	SPAWN(4 SECONDS)
		SEND_SIGNAL(controller_parent, COMSIG_PHONE_OUTBOUND_CONNECTION, target_id)
		src.dialing = FALSE

/datum/component/phone_ui/proc/inbound_connection_check()
	if(src.dialing)
		return PHONE_FAILED

/datum/component/phone_ui/proc/phone_ui_close()
	tgui_process.close_uis(src)
