var/datum/event_controller/random_events

/datum/event_controller
	var/list/events = list()
	var/major_events_begin = 18000 // 30m
	var/time_between_events_lower = 6600  // 11m
	var/time_between_events_upper = 12000 // 20m
	var/events_enabled = 1
	var/announce_events = 1
	var/event_cycle_count = 0

	var/list/minor_events = list()
	var/minor_events_begin = 6000 // 10m
	var/time_between_minor_events_lower = 4000 // roughly 8m
	var/time_between_minor_events_upper = 8000 // roughly 14m
	var/minor_events_enabled = 1
	var/minor_event_cycle_count = 0

	var/list/antag_spawn_events = list()
	var/alive_antags_threshold = 0.06
	var/list/player_spawn_events = list()
	var/dead_players_threshold = 0.3
	var/spawn_events_begin = 23 MINUTES
	var/time_between_spawn_events = 8 MINUTES

	var/major_event_timer = 0
	var/minor_event_timer = 0

	var/next_major_event = 0
	var/next_minor_event = 0
	var/next_spawn_event = 0

	var/time_lock = 1
	var/list/special_events = list()
	var/minimum_population = 15 // Minimum amount of players connected for event to occur

	New()
		..()
		for (var/X in childrentypesof(/datum/random_event/major))
			var/datum/random_event/RE = new X
			events += RE

		for (var/X in childrentypesof(/datum/random_event/major/antag))
			var/datum/random_event/RE = new X
			antag_spawn_events += RE

		for (var/X in childrentypesof(/datum/random_event/major/player_spawn))
			var/datum/random_event/RE = new X
			player_spawn_events += RE

		for (var/X in childrentypesof(/datum/random_event/minor))
			var/datum/random_event/RE = new X
			minor_events += RE

		for (var/X in childrentypesof(/datum/random_event/special))
			var/datum/random_event/RE = new X
			special_events += RE

	proc/process()
		// prevent random events near round end
		if (emergency_shuttle.location > SHUTTLE_LOC_STATION || current_state == GAME_STATE_FINISHED)
			return

		if (TIME >= major_events_begin)
			if (TIME >= next_major_event)
				event_cycle()

		if (TIME >= spawn_events_begin)
			if (TIME >= next_spawn_event)
				spawn_event()

		if (TIME >= minor_events_begin)
			if (TIME >= next_minor_event)
				minor_event_cycle()

	proc/event_cycle()
		event_cycle_count++
		if (events_enabled && (total_clients() >= minimum_population))
			do_random_event(events)
		else
			message_admins("<span class='internal'>A random event would have happened now, but they are disabled!</span>")

		major_event_timer = rand(time_between_events_lower,time_between_events_upper)
		next_major_event = TIME + major_event_timer
		message_admins("<span class='internal'>Next event will occur at [round(next_major_event / 600)] minutes into the round.</span>")

	proc/minor_event_cycle()
		minor_event_cycle_count++
		if (minor_events_enabled)
			do_random_event(minor_events)

		minor_event_timer = rand(time_between_minor_events_lower,time_between_minor_events_upper)
		next_minor_event = TIME + minor_event_timer

	proc/spawn_event(var/type = "player")
		var/do_event = 1
		if (!events_enabled)
			message_admins("<span class='internal'>A spawn event would have happened now, but they are disabled!</span>")
			do_event = 0
		if (total_clients() < minimum_population)
			message_admins("<span class='internal'>A spawn event would have happened now, but there is not enough players!</span>")
			do_event = 0

		if (do_event)
			var/aap = get_alive_antags_percentage()
			var/dcp = get_dead_crew_percentage()
			if (aap < alive_antags_threshold && (ticker?.mode?.do_antag_random_spawns))
				do_random_event(list(pick(antag_spawn_events)), source = "spawn_antag")
				message_admins("<span class='internal'>Antag spawn event success!<br>[100 * aap]% of the alive crew were antags.</span>")
			else if (dcp > dead_players_threshold)
				do_random_event(player_spawn_events, source = "spawn_player")
				message_admins("<span class='internal'>Player spawn event success!<br>[100 * dcp]% of the entire crew were dead.</span>")
			else
				message_admins("<span class='internal'>A spawn event would have happened now, but it was not needed based on alive players + antagonists headcount or game mode!<br>[100 * aap]% of the alive crew were antags and [100 * dcp]% of the entire crew were dead.</span>")

		next_spawn_event = TIME + time_between_spawn_events

	proc/do_random_event(var/list/event_bank, var/source = null)
		if (!event_bank || event_bank.len < 1)
			logTheThing("debug", null, null, "<b>Random Events:</b> do_random_event proc was passed a bad event bank")
			return
		var/list/eligible = list()
		var/list/weights = list()
		for (var/datum/random_event/RE in event_bank)
			if (RE.is_event_available( ignore_time_lock = (source=="spawn_antag") ))
				eligible += RE
				weights += RE.weight
		if (eligible.len > 0)
			var/datum/random_event/this = weightedprob(eligible, weights)
			this.event_effect(source)
		else
			logTheThing("debug", null, null, "<b>Random Events:</b> do_random_event couldn't find any eligible events")

	proc/force_event(var/string,var/reason)
		if (!string)
			return
		if (!reason)
			reason = "coded instance (undefined)"

		var/list/allevents = events | minor_events | special_events
		for (var/datum/random_event/RE in allevents)
			if (RE.name == string)
				RE.event_effect(string,reason)
				break

	///////////////////
	// CONFIGURATION //
	///////////////////

	proc/event_config()
		var/dat = "<html><body><title>Random Events Controller</title>"
		dat += "<b><u>Random Event Controls</u></b><HR>"

		if (current_state <= GAME_STATE_PREGAME)
			dat += "<b>Random Events begin at: <a href='byond://?src=\ref[src];EventBegin=1'>[round(major_events_begin / 600)] minutes</a><br>"
			dat += "<b>Minor Events begin at: <a href='byond://?src=\ref[src];MEventBegin=1'>[round(minor_events_begin / 600)] minutes</a><br>"
			dat += "<b>Spawn Events begin at: <a href='byond://?src=\ref[src];MEventBegin=1'>[round(spawn_events_begin / 600)] minutes</a><br>"
		else
			dat += "Next major random event at [round(next_major_event / 600)] minutes into the round.<br>"
			dat += "Next minor event at [round(next_minor_event / 600)] minutes into the round.<br>"
			dat += "Next spawn event at [round(next_spawn_event / 600)] minutes into the round.<br>"

		dat += "<b><a href='byond://?src=\ref[src];EnableEvents=1'>Random Events Enabled:</a></b> [events_enabled ? "Yes" : "No"]<br>"
		dat += "<b><a href='byond://?src=\ref[src];EnableMEvents=1'>Minor Events Enabled:</a></b> [minor_events_enabled ? "Yes" : "No"]<br>"
		dat += "<b><a href='byond://?src=\ref[src];AnnounceEvents=1'>Announce Events to Station:</a></b> [announce_events ? "Yes" : "No"]<br>"
		dat += "<b><a href='byond://?src=\ref[src];TimeLocks=1'>Time Locking:</a></b> [time_lock ? "Yes" : "No"]<br>"
		dat += "<b>Minimum Population for Events: <a href='byond://?src=\ref[src];MinPop=1'>[minimum_population] players</a><br>"
		dat += "<b>Time Between Events:</b> <a href='byond://?src=\ref[src];TimeLower=1'>[round(time_between_events_lower / 600)]m</a> /"
		dat += " <a href='byond://?src=\ref[src];TimeUpper=1'>[round(time_between_events_upper / 600)]m</a><br>"
		dat += "<b>Time Between Minor Events:</b> <a href='byond://?src=\ref[src];MTimeLower=1'>[round(time_between_minor_events_lower / 600)]m</a> /"
		dat += " <a href='byond://?src=\ref[src];MTimeUpper=1'>[round(time_between_minor_events_upper / 600)]m</a>"
		dat += "<HR>"

		dat += "<b><u>Normal Random Events</u></b><BR>"
		for(var/datum/random_event/RE in events)
			dat += "<a href='byond://?src=\ref[src];TriggerEvent=\ref[RE]'><b>[RE.name]</b></a>"
			dat += " <small><a href='byond://?src=\ref[src];DisableEvent=\ref[RE]'>([RE.disabled ? "Disabled" : "Enabled"])</a>"
			if (RE.is_event_available())
				dat += " (Active)"
			dat += "<br></small>"
		dat += "<BR>"

		dat += "<b><u>Minor Random Events</u></b><BR>"
		for(var/datum/random_event/RE in minor_events)
			dat += "<a href='byond://?src=\ref[src];TriggerMEvent=\ref[RE]'><b>[RE.name]</b></a>"
			dat += " <small><a href='byond://?src=\ref[src];DisableMEvent=\ref[RE]'>([RE.disabled ? "Disabled" : "Enabled"])</a>"
			if (RE.is_event_available())
				dat += " (Active)"
			dat += "<br></small>"
		dat += "<BR>"

		dat += "<b><u>Gimmick Events</u></b><BR>"
		for(var/datum/random_event/RE in special_events)
			dat += "<a href='byond://?src=\ref[src];TriggerSEvent=\ref[RE]'><b>[RE.name]</b></a><br>"

		dat += "<HR>"
		dat += "</body></html>"
		usr.Browse(dat,"window=reconfig;size=450x450")

	Topic(href, href_list[])
		//So we have not had any validation on the admin random events panel since its inception. Argh. /Spy
		if(usr?.client && !usr.client.holder) {boutput(usr, "Only administrators may use this command."); return}

		if(href_list["TriggerEvent"])
			var/datum/random_event/RE = locate(href_list["TriggerEvent"]) in events
			if (!istype(RE,/datum/random_event/))
				return
			var/choice = alert("Trigger a [RE.name] event?","Random Events","Yes","No")
			if (choice == "Yes")
				if (RE.customization_available)
					var/choice2 = alert("Random or custom variables?","[RE.name]","Random","Custom")
					if (choice2 == "Custom")
						RE.admin_call(key_name(usr, 1))
					else
						RE.event_effect("Triggered by [key_name(usr)]")
				else
					RE.event_effect("Triggered by [key_name(usr)]")

		else if(href_list["TriggerMEvent"])
			var/datum/random_event/RE = locate(href_list["TriggerMEvent"]) in minor_events
			if (!istype(RE,/datum/random_event/))
				return
			var/choice = alert("Trigger a [RE.name] event?","Random Events","Yes","No")
			if (choice == "Yes")
				if (RE.customization_available)
					var/choice2 = alert("Random or custom variables?","[RE.name]","Random","Custom")
					if (choice2 == "Custom")
						RE.admin_call(key_name(usr, 1))
					else
						RE.event_effect("Triggered by [key_name(usr)]")
				else
					RE.event_effect("Triggered by [key_name(usr)]")

		else if(href_list["TriggerSEvent"])
			var/datum/random_event/RE = locate(href_list["TriggerSEvent"]) in special_events
			if (!istype(RE,/datum/random_event/))
				return
			var/choice = alert("Trigger a [RE.name] event?","Random Events","Yes","No")
			if (choice == "Yes")
				if (RE.customization_available)
					var/choice2 = alert("Random or custom variables?","[RE.name]","Random","Custom")
					if (choice2 == "Custom")
						RE.admin_call(key_name(usr, 1))
					else
						RE.event_effect("Triggered by [key_name(usr)]")
				else
					RE.event_effect("Triggered by [key_name(usr)]")

		else if(href_list["DisableEvent"])
			var/datum/random_event/RE = locate(href_list["DisableEvent"]) in events
			if (!istype(RE,/datum/random_event/))
				return
			RE.disabled = !RE.disabled
			message_admins("Admin [key_name(usr)] switched [RE.name] event [RE.disabled ? "Off" : "On"]")
			logTheThing("admin", usr, null, "switched [RE.name] event [RE.disabled ? "Off" : "On"]")
			logTheThing("diary", usr, null, "switched [RE.name] event [RE.disabled ? "Off" : "On"]", "admin")

		else if(href_list["DisableMEvent"])
			var/datum/random_event/RE = locate(href_list["DisableMEvent"]) in minor_events
			if (!istype(RE,/datum/random_event/))
				return
			RE.disabled = !RE.disabled
			message_admins("Admin [key_name(usr)] switched [RE.name] event [RE.disabled ? "Off" : "On"]")
			logTheThing("admin", usr, null, "switched [RE.name] event [RE.disabled ? "Off" : "On"]")
			logTheThing("diary", usr, null, "switched [RE.name] event [RE.disabled ? "Off" : "On"]", "admin")

		else if(href_list["MinPop"])
			var/new_min = input("How many players need to be connected before events will occur?","Random Events",minimum_population) as num
			if (new_min == minimum_population) return

			if (new_min < 1)
				boutput(usr, "<span class='alert'>Well that doesn't even make sense.</span>")
				return
			else
				minimum_population = new_min

			message_admins("Admin [key_name(usr)] set the minimum population for events to [minimum_population]")
			logTheThing("admin", usr, null, "set the minimum population for events to [minimum_population]")
			logTheThing("diary", usr, null, "set the minimum population for events to [minimum_population]", "admin")

		else if(href_list["EventBegin"])
			var/time = input("How many minutes into the round until events begin?","Random Events") as num
			major_events_begin = time * 600

			message_admins("Admin [key_name(usr)] set random events to begin at [time] minutes")
			logTheThing("admin", usr, null, "set random events to begin at [time] minutes")
			logTheThing("diary", usr, null, "set random events to begin at [time] minutes", "admin")

		else if(href_list["MEventBegin"])
			var/time = input("How many minutes into the round until minor events begin?","Random Events") as num
			minor_events_begin = time * 600

			message_admins("Admin [key_name(usr)] set minor events to begin at [time] minutes")
			logTheThing("admin", usr, null, "set minor events to begin at [time] minutes")
			logTheThing("diary", usr, null, "set minor events to begin at [time] minutes", "admin")

		else if(href_list["EnableEvents"])
			events_enabled = !events_enabled
			message_admins("Admin [key_name(usr)] [events_enabled ? "enabled" : "disabled"] random events")
			logTheThing("admin", usr, null, "[events_enabled ? "enabled" : "disabled"] random events")
			logTheThing("diary", usr, null, "[events_enabled ? "enabled" : "disabled"] random events", "admin")

		else if(href_list["EnableMEvents"])
			minor_events_enabled = !minor_events_enabled
			message_admins("Admin [key_name(usr)] [minor_events_enabled ? "enabled" : "disabled"] minor events")
			logTheThing("admin", usr, null, "[minor_events_enabled ? "enabled" : "disabled"] minor events")
			logTheThing("diary", usr, null, "[minor_events_enabled ? "enabled" : "disabled"] minor events", "admin")

		else if(href_list["AnnounceEvents"])
			announce_events = !announce_events
			message_admins("Admin [key_name(usr)] [announce_events ? "enabled" : "disabled"] random event announcements")
			logTheThing("admin", usr, null, "[announce_events ? "enabled" : "disabled"] random event announcements")
			logTheThing("diary", usr, null, "[announce_events ? "enabled" : "disabled"] random event announcements", "admin")

		else if(href_list["TimeLocks"])
			time_lock = !time_lock
			message_admins("Admin [key_name(usr)] [time_lock ? "enabled" : "disabled"] random event time locks")
			logTheThing("admin", usr, null, "[time_lock ? "enabled" : "disabled"] random event time locks")
			logTheThing("diary", usr, null, "[time_lock ? "enabled" : "disabled"] random event time locks", "admin")

		else if(href_list["TimeLower"])
			var/time = input("Set the lower bound to how many minutes?","Random Events") as num
			if (time < 1)
				boutput(usr, "<span class='alert'>The fuck is that supposed to mean???? Knock it off!</span>")
				return

			time *= 600
			if (time > time_between_events_upper)
				boutput(usr, "<span class='alert'>You cannot set the lower bound higher than the upper bound.</span>")
			else
				time_between_events_lower = time
				message_admins("Admin [key_name(usr)] set event lower interval bound to [time_between_events_lower / 600] minutes")
				logTheThing("admin", usr, null, "set event lower interval bound to [time_between_events_lower / 600] minutes")
				logTheThing("diary", usr, null, "set event lower interval bound to [time_between_events_lower / 600] minutes", "admin")

		else if(href_list["TimeUpper"])
			var/time = input("Set the upper bound to how many minutes?","Random Events") as num
			if (time > 100)
				boutput(usr, "<span class='alert'>That's a bit much.</span>")
				return

			time *= 600
			if (time < time_between_events_lower)
				boutput(usr, "<span class='alert'>You cannot set the upper bound lower than the lower bound.</span>")
			else
				time_between_events_upper = time
			message_admins("Admin [key_name(usr)] set event upper interval bound to [time_between_events_upper / 600] minutes")
			logTheThing("admin", usr, null, "set event upper interval bound to [time_between_events_upper / 600] minutes")
			logTheThing("diary", usr, null, "set event upper interval bound to [time_between_events_upper / 600] minutes", "admin")

		else if(href_list["MTimeLower"])
			var/time = input("Set the lower bound to how many minutes?","Random Events") as num
			if (time < 1)
				boutput(usr, "<span class='alert'>The fuck is that supposed to mean???? Knock it off!</span>")
				return

			time *= 600
			if (time > time_between_minor_events_upper)
				boutput(usr, "<span class='alert'>You cannot set the lower bound higher than the upper bound.</span>")
			else
				time_between_minor_events_lower = time
			message_admins("Admin [key_name(usr)] set minor event lower interval bound to [time_between_minor_events_lower / 600] minutes")
			logTheThing("admin", usr, null, "set minor event lower interval bound to [time_between_minor_events_lower / 600] minutes")
			logTheThing("diary", usr, null, "set minor event lower interval bound to [time_between_minor_events_lower / 600] minutes", "admin")

		else if(href_list["MTimeUpper"])
			var/time = input("Set the upper bound to how many minutes?","Random Events") as num
			if (time > 100)
				boutput(usr, "<span class='alert'>That's a bit much.</span>")
				return

			time *= 600
			if (time < time_between_events_lower)
				boutput(usr, "<span class='alert'>You cannot set the upper bound lower than the lower bound.</span>")
			else
				time_between_minor_events_upper = time
			message_admins("Admin [key_name(usr)] set minor event upper interval bound to [time_between_minor_events_upper / 600] minutes")
			logTheThing("admin", usr, null, "set minor event upper interval bound to [time_between_minor_events_upper / 600] minutes")
			logTheThing("diary", usr, null, "set minor event upper interval bound to [time_between_minor_events_upper / 600] minutes", "admin")

		src.event_config()
