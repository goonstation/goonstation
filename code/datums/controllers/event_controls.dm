var/datum/event_controller/random_events

/datum/event_controller
	var/events_enabled = TRUE
	var/announce_events = TRUE

	var/list/major_events = list()
	var/major_events_begin = 30 MINUTES // 30m
	var/time_between_major_events_lower = 11 MINUTES  // 11m
	var/time_between_major_events_upper = 20 MINUTES // 20m
	var/major_events_enabled = TRUE
	var/major_event_cycle_count = 0

	var/list/minor_events = list()
	var/minor_events_begin = 10 MINUTES // 10m
	var/time_between_minor_events_lower = 400 SECONDS // roughly 8m
	var/time_between_minor_events_upper = 800 SECONDS // roughly 14m
	var/minor_events_enabled = TRUE
	var/minor_event_cycle_count = 0

	var/list/antag_spawn_events = list()
#ifdef RP_MODE
	var/alive_antags_threshold = 0.04
#else
	var/alive_antags_threshold = 0.1
#endif
	var/list/player_spawn_events = list()
	var/dead_players_threshold = 0.3
	var/spawn_events_begin = 23 MINUTES
	var/time_between_spawn_events_lower = 8 MINUTES
	var/time_between_spawn_events_upper = 12 MINUTES

	var/major_event_timer = 0
	var/minor_event_timer = 0

	var/next_major_event = 0
	var/next_minor_event = 0
	var/next_spawn_event = 0

	var/time_lock = 1
	var/list/special_events = list()
	var/minimum_population = 15 // Minimum amount of players connected for event to occur

	var/datum/storyteller/active_storyteller

	var/list/queued_events

	var/start_events_enabled = FALSE
	var/list/start_events = list()
	var/list/datum/random_event/delayed_start = list()

	New()
		..()

		for (var/X in concrete_typesof(/datum/random_event/major))
			var/datum/random_event/RE = new X
			major_events += RE

		for (var/X in concrete_typesof(/datum/random_event/major/antag)+concrete_typesof(/datum/random_event/major/player_spawn/antag))
			var/datum/random_event/RE = new X
			antag_spawn_events += RE

		for (var/X in concrete_typesof(/datum/random_event/major/player_spawn)-concrete_typesof(/datum/random_event/major/player_spawn/antag))
			var/datum/random_event/RE = new X
			player_spawn_events += RE

		for (var/X in concrete_typesof(/datum/random_event/minor))
			var/datum/random_event/RE = new X
			minor_events += RE

		for (var/X in concrete_typesof(/datum/random_event/special))
			var/datum/random_event/RE = new X
			special_events += RE

		for (var/X in concrete_typesof(/datum/random_event/start))
			var/datum/random_event/RE = new X
			start_events += RE

		queued_events = list("major"=list(),"minor"=list(),"special_events"=list(),"spawn"=list(),"start_events"=list())

		src.active_storyteller = new/datum/storyteller/basic()
		src.active_storyteller.set_active(src)

	proc/process()
		if( !events_enabled )
			return

		// prevent random events near round end
		if (emergency_shuttle.location > SHUTTLE_LOC_STATION || current_state == GAME_STATE_FINISHED)
			return

		if (ticker.round_elapsed_ticks == 0)
			roundstart_events()

		active_storyteller.process()

	proc/do_random_event(var/list/event_bank, var/source = null)
		if (!event_bank || length(event_bank) < 1)
			logTheThing(LOG_DEBUG, null, "<b>Random Events:</b> do_random_event proc was passed a bad event bank")
			return
		if (!ticker?.mode?.do_random_events)
			logTheThing(LOG_DEBUG, null, "<b>Random Events:</b> Random events are turned off on this game mode.")
			return
		var/list/eligible = list()
		var/list/weights = list()
		for (var/datum/random_event/RE in event_bank)
			if (RE.is_event_available( ignore_time_lock = (source=="spawn_antag") ))
				eligible += RE
				weights += RE.weight
		if (length(eligible) > 0)
			var/datum/random_event/this = weightedprob(eligible, weights)
			this.event_effect(source)
		else
			logTheThing(LOG_DEBUG, null, "<b>Random Events:</b> do_random_event couldn't find any eligible events")

	proc/roundstart_events()
		for(var/datum/random_event/RE in delayed_start)
			var/source = delayed_start[RE]
			SPAWN(0) RE.event_effect(source)

	proc/force_event(var/string,var/reason)
		if (!string)
			return
		if (!reason)
			reason = "coded instance (undefined)"

		var/list/allevents = major_events | minor_events | special_events
		for (var/datum/random_event/RE in allevents)
			if (RE.name == string)
				RE.event_effect(reason)
				break

/datum/event_controller/ui_state(mob/user)
	return tgui_admin_state

/datum/event_controller/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "EventController")
		ui.open()

/datum/event_controller/ui_static_data(mob/user)
	. = list()
	.["storyTellerList"] = list()
	var/datum/storyteller/S
	for(var/storyteller_type in concrete_typesof(/datum/storyteller))
		S = storyteller_type
		.["storyTellerList"] +=list(list(
			"name" = initial(S.name),
			"description" = initial(S.description),
			"path" = S
		))

/datum/event_controller/ui_data()
	. = list()
	var/datum/random_event/RE
	.["eventsEnabled"] = src.events_enabled
	.["announce"] = src.announce_events
	.["timeLock"] = src.time_lock
	.["minPopulation"] = src.minimum_population
	.["aliveAntagonistThreshold"] = src.alive_antags_threshold
	.["deadPlayersThreshold"] = src.dead_players_threshold
	.["eventData"] = list()

	var/list/majorEventData = list()
	for(RE in src.major_events)
		majorEventData += list(list(
			"byondRef" = ref(RE),
			"name" = RE.name,
			"description" = "Foo",//RE.description,
			"customizable" = RE.customization_available,
			"alwaysCustom" = RE.always_custom,
			"available" = RE.is_event_available(),
			"enabled" =  !RE.disabled,
		))
	.["eventData"] += list(list(
		"name" = "major",
		"enabled" = src.major_events_enabled,
		"startTime" = src.major_events_begin,
		"delayLow" = src.time_between_major_events_lower,
		"delayHigh" = src.time_between_major_events_upper,
		"nextEvent" = src.next_major_event,
		"eventList" = majorEventData
	))

	var/list/minorEventData = list()
	for(RE in src.minor_events)
		minorEventData += list(list(
			"byondRef" = ref(RE),
			"name" = RE.name,
			"description" = "Foo",//RE.description,
			"customizable" = RE.customization_available,
			"alwaysCustom" = RE.always_custom,
			"available" = RE.is_event_available(),
			"enabled" =  !RE.disabled
		))
	.["eventData"] += list(list(
		"name" = "minor",
		"enabled" = src.minor_events_enabled,
		"startTime" = src.minor_events_begin,
		"delayLow" = src.time_between_minor_events_lower,
		"delayHigh" = src.time_between_minor_events_upper,
		"nextEvent" = src.next_minor_event,
		"eventList" = minorEventData
	))

	var/list/specialEventData = list()
	for(RE in src.special_events)
		specialEventData += list(list(
			"byondRef" = ref(RE),
			"name" = RE.name,
			"description" = "Foo",//RE.description,
			"customizable" = RE.customization_available,
			"alwaysCustom" = RE.always_custom,
			"available" = RE.is_event_available(),
			"enabled" =  !RE.disabled
		))
	.["eventData"] += list(list(
		"name" = "special",
		"eventList" = specialEventData
	))


	var/list/roundstartEventData = list()
	for(RE in src.start_events)
		roundstartEventData += list(list(
			"byondRef" = ref(RE),
			"name" = RE.name,
			"description" = "Foo",//RE.description,
			"customizable" = RE.customization_available,
			"alwaysCustom" = RE.always_custom,
			"available" = RE.is_event_available(),
			"enabled" =  !RE.disabled
		))
	.["eventData"] += list(list(
		"name" = "round start",
		"eventList" = roundstartEventData
	))

	.["eventData"] += list(list(
		"name" = "spawn",
		"enabled" = TRUE,
		"startTime" = src.spawn_events_begin,
		"delayLow" = src.time_between_spawn_events_lower,
		"delayHigh" = src.time_between_spawn_events_upper,
		"nextEvent" = src.next_spawn_event,
	))

	.["queuedEvents"] = list()
	for(var/category in src.queued_events)
		for(var/queue_id in src.queued_events[category])
			RE = src.queued_events[category][queue_id][1]
			var/event_time = random_events.queued_events[category][queue_id][2]
			.["queuedEvents"] += list(list(
				"queueID" = queue_id,
				 category = category,
				 name = RE.name,
				 time = event_time
			))

	.["roundStart"] = list()
	for(RE in src.delayed_start)
		.["roundStart"] += list(list(
			"byondRef" = ref(RE),
			"name" = RE.name
		))

	.["storyTeller"] = list("name" = src.active_storyteller.name,
			"description" = src.active_storyteller.description,
			"path" = src.active_storyteller.type)

/datum/event_controller/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if(.)
		return
	var/datum/random_event/RE
	switch(action)
		if("trigger_event")
			RE = locate(params["ref"])
			if(istype(RE) && params["name"] == RE.name)
				if(!RE.announce_to_admins)
					message_admins(SPAN_INTERNAL("Beginning [RE.name] event (Source: [key_name(usr)])."))
					logTheThing(LOG_ADMIN, null, "Random event [RE.name] was triggered. Source: [key_name(usr)]")

				if (RE.customization_available)
					if (RE.always_custom || alert("Random or custom variables?","[RE.name]","Random","Custom") == "Custom")
						RE.admin_call(key_name(usr, 1))
					else
						RE.event_effect("Triggered by [key_name(usr)]")
				else
					RE.event_effect("Triggered by [key_name(usr)]")

			if(istype(RE, /datum/random_event/start/until_playing))
				. = TRUE

		if("toggle_event")
			RE = locate(params["ref"])
			if(istype(RE) && params["name"] == RE.name)
				RE.disabled = !RE.disabled
				message_admins("Admin [key_name(usr)] switched [RE.name] event [RE.disabled ? "Off" : "On"]")
				logTheThing(LOG_ADMIN, usr, "switched [RE.name] event [RE.disabled ? "Off" : "On"]")
				logTheThing(LOG_DIARY, usr, "switched [RE.name] event [RE.disabled ? "Off" : "On"]", "admin")
				. = TRUE

		if("schedule_event")
			RE = locate(params["ref"])
			var/queue_string
			if( RE in major_events )
				queue_string = "major"
			else if(RE in minor_events )
				queue_string = "minor"
			else if(RE in special_events )
				queue_string = "special_events"
			else if(RE in start_events )
				queue_string = "start_events"

			if(istype(RE) && params["name"] == RE.name)
				var/schedule_time = tgui_input_number(usr,
										"When should '[RE.name]' be called? (Shift time in minutes)",
										"Schedule Event",
										((ticker.round_elapsed_ticks + (0.5 MINUTES)) / (1 MINUTES)),
										INFINITY,
										ticker.round_elapsed_ticks / (1 MINUTES),
										round_input = FALSE)
				if((schedule_time MINUTES) <= ticker.round_elapsed_ticks)
					boutput(usr, SPAN_ALERT("Well that doesn't even make sense. That already happened!"))
					return

				src.queued_events[queue_string]["[RE.name]_[schedule_time]_[usr]"] += list(RE,(schedule_time MINUTES))
				. = TRUE

		if("set_category_value")
			. = TRUE
			switch(params["category"])
				if("spawn")
					switch(params["name"])
						if("startTime")
							src.spawn_events_begin = params["new_data"]
						if("delayLow")
							src.time_between_spawn_events_lower = params["new_data"]
						if("delayHigh")
							src.time_between_spawn_events_upper = params["new_data"]
						if("nextEvent")
							src.next_spawn_event = params["new_data"]
						else
							. = FALSE

				if("major")
					. = TRUE
					switch(params["name"])
						if("toggle_category")
							src.major_events_enabled = !src.major_events_enabled
						if("startTime")
							src.major_events_begin = params["new_data"]
						if("delayLow")
							src.time_between_major_events_lower = params["new_data"]
						if("delayHigh")
							src.time_between_major_events_upper = params["new_data"]
						if("nextEvent")
							src.next_major_event = params["new_data"]
						else
							. = FALSE

				if("minor")
					. = TRUE
					switch(params["name"])
						if("toggle_category")
							src.minor_events_enabled = !src.minor_events_enabled
						if("startTime")
							src.minor_events_begin = params["new_data"]
						if("delayLow")
							src.time_between_minor_events_lower = params["new_data"]
						if("delayHigh")
							src.time_between_minor_events_upper = params["new_data"]
						if("nextEvent")
							src.next_minor_event = params["new_data"]
						else
							. = FALSE
				else
					. = FALSE

		if("storyteller")
			var/datum/storyteller/new_teller = tgui_input_list(usr,"Choose Storyteller", "Storyteller", concrete_typesof(/datum/storyteller))
			if(new_teller)
				active_storyteller = new new_teller()
				active_storyteller.set_active(src)
				message_admins("Admin [key_name(usr)] set the storyteller to: [active_storyteller]")
				logTheThing(LOG_ADMIN, usr, "set the storyteller to: [active_storyteller]")
				logTheThing(LOG_DIARY, usr, "set the storyteller to: [active_storyteller]", "admin")

				. = TRUE

		if("set_value")
			. = TRUE
			switch(params["name"])
				if("eventsEnabled")
					src.events_enabled = params["new_data"]
					message_admins("Admin [key_name(usr)] [events_enabled ? "enabled" : "disabled"] random events")
					logTheThing(LOG_ADMIN, usr, "[events_enabled ? "enabled" : "disabled"] random events")
					logTheThing(LOG_DIARY, usr, "[events_enabled ? "enabled" : "disabled"] random events", "admin")

				if("announce")
					src.announce_events = params["new_data"]
					message_admins("Admin [key_name(usr)] [announce_events ? "enabled" : "disabled"] random event announcements")
					logTheThing(LOG_ADMIN, usr, "[announce_events ? "enabled" : "disabled"] random event announcements")
					logTheThing(LOG_DIARY, usr, "[announce_events ? "enabled" : "disabled"] random event announcements", "admin")

				if("timeLock")
					src.time_lock = params["new_data"]
					message_admins("Admin [key_name(usr)] [time_lock ? "enabled" : "disabled"] random event time locks")
					logTheThing(LOG_ADMIN, usr, "[time_lock ? "enabled" : "disabled"] random event time locks")
					logTheThing(LOG_DIARY, usr, "[time_lock ? "enabled" : "disabled"] random event time locks", "admin")

				if("minPopulation")
					src.minimum_population = params["new_data"]
					message_admins("Admin [key_name(usr)] set the minimum population for events to [minimum_population]")
					logTheThing(LOG_ADMIN, usr, "set the minimum population for events to [minimum_population]")
					logTheThing(LOG_DIARY, usr, "set the minimum population for events to [minimum_population]", "admin")

				if("aliveAntagonistThreshold")
					src.alive_antags_threshold = params["new_data"]
					message_admins("Admin [key_name(usr)] set alive antag threshold to [alive_antags_threshold]")
					logTheThing(LOG_ADMIN, usr, "set alive antag threshold to [alive_antags_threshold]")
					logTheThing(LOG_DIARY, usr, "set alive antag threshold to [alive_antags_threshold]", "admin")
				if("deadPlayersThreshold")
					src.dead_players_threshold = params["new_data"]
					message_admins("Admin [key_name(usr)] set dead player threshold to [dead_players_threshold]")
					logTheThing(LOG_ADMIN, usr, "set dead player threshold to [dead_players_threshold]")
					logTheThing(LOG_DIARY, usr, "set dead player threshold to [dead_players_threshold]", "admin")

				else
					. = FALSE

		if("remove_roundstart_event")
			RE = locate(params["ref"])
			if(RE in src.delayed_start)
				src.delayed_start -= RE
				. = TRUE

		if("unschedule_event")
			var/category = params["category"]
			var/queued_id = params["id"]
			if(category in random_events.queued_events)
				random_events.queued_events[category] -= queued_id
				. = TRUE
		else
			tgui_process.close_uis(src)
			. = TRUE

/client/proc/cmd_event_controller()
	SET_ADMIN_CAT(ADMIN_CAT_FUN)
	set name = "Event Controller"
	set desc = "Event Controller"
	ADMIN_ONLY
	SHOW_VERB_DESC

	if(holder)
		random_events.ui_interact(src.mob)
