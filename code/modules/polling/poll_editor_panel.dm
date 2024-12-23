/datum/poll_editor_panel
	var/last_error = null

/datum/poll_editor_panel/New(mob/user)
	..()
	// TODO: pass in current poll to edit it

/datum/poll_editor_panel/ui_state(mob/user)
	return tgui_admin_state.can_use_topic(src, user)

/datum/poll_editor_panel/ui_status(mob/user)
	return tgui_admin_state.can_use_topic(src, user)

/datum/poll_editor_panel/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "PollEditorPanel")
		ui.open()

/datum/poll_editor_panel/ui_static_data(mob/user)
	. = list(
		"serverOptions" = list("Local", "Global", "RP Only")
	)

/datum/poll_editor_panel/ui_data(mob/user)
	. = list(
		"lastError" = src.last_error
	)

/datum/poll_editor_panel/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if (.)
		return

	switch (action)
		if ("save")
			USR_ADMIN_ONLY

			var/list/poll

			try
				var/expires_at = src.to_timestamp(params["expiryType"], params["expiryValue"])
				var/servers = src.to_server_list(params["servers"])
				var/datum/apiRoute/polls/add/addPoll = new
				addPoll.buildBody(
					ui.user.ckey,
					params["title"],
					params["multipleChoice"],
					expires_at,
					params["options"],
					servers
				)
				var/datum/apiModel/Tracked/PollResource/pollResource = apiHandler.queryAPI(addPoll)
				poll = pollResource.ToList()
			catch (var/exception/e)
				var/datum/apiModel/Error/error = e.name
				logTheThing(LOG_DEBUG, null, "Failed to add a poll: [error.message]")
				src.last_error = error.message
				return TRUE

			// Add this poll to our cached data
			poll_manager.poll_data.Insert(1, list(poll))

			if (params["alertPlayers"])
				for (var/client/C in clients)
					boutput(C, SPAN_NOTICE("A new poll is now available. <a href='byond://winset?command=Player-Polls'>Click here to vote!</a>"))
				playsound_global(world, 'sound/misc/prayerchime.ogg', 100, channel = VOLUME_CHANNEL_MENTORPM)

			ui.close()
			. = TRUE

/datum/poll_editor_panel/proc/to_timestamp(type, value)
	switch (type)
		if ("never")
			return null
		if ("minutes")
			return toIso8601(addTime(subtractTime(world.realtime, hours = world.timezone), minutes = text2num(value)))
		if ("hours")
			return toIso8601(addTime(subtractTime(world.realtime, hours = world.timezone), hours = text2num(value)))
		if ("days")
			return toIso8601(addTime(subtractTime(world.realtime, hours = world.timezone), days = text2num(value)))
		if ("timestamp")
			if (validateIso8601(value))
				return value
	throw EXCEPTION("Problem processing expiry time.")

/datum/poll_editor_panel/proc/to_server_list(servers)
	switch(servers)
		if ("Local")
			return list(config.server_id)
		if ("Global")
			return list(poll_manager.global_server_id)
		if ("RP Only")
			return list(poll_manager.rp_only_server_id)
	throw EXCEPTION("Problem processing server list.")
