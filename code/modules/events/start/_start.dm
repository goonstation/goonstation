ABSTRACT_TYPE(/datum/random_event/start)
/datum/random_event/start
	wont_occur_past_this_time = 1

	proc/is_crew_affected(var/mob/living/player)
		. = TRUE

	proc/apply_to_player(var/mob/living/player)
		return

	proc/get_affected_crew()
		. = list()
		for(var/mob/living/M in mobs)
			if (isnpc(M))
				continue
			if(is_crew_affected(M))
				. += M

ABSTRACT_TYPE(/datum/random_event/start/until_playing)
/datum/random_event/start/until_playing
	customization_available = TRUE
	var/queued = FALSE
	var/notify_player = FALSE
	var/query_player = FALSE // TODO allow player to opt out via prompt...
	var/include_antags = FALSE
	var/player_chance = 100
	var/include_latejoin = FALSE

	admin_call(var/source)
		. = ..()
		if(!.)
			include_latejoin = alert("Apply to late join players?", "Late Join", "Yes", "No") == "Yes"
		if(!.)
			if(current_state >= GAME_STATE_PLAYING)
				if( alert("Force Event?", "Round already Started!", "Yes", "No") == "Yes")
					queued = TRUE
				else if(include_latejoin)
					message_admins(SPAN_INTERNAL("[src.name] will only apply to latejoin players!"))
				else
					boutput(usr,SPAN_INTERNAL("Round Start Event: [src.name] aborted! Round in progress."))
					. = TRUE
		if(!.)
			include_antags = alert("Apply to antagonists?", "Antags", "Yes", "No") == "Yes"
			player_chance = tgui_input_number(usr, "Probability per crewmember.", "[name]", 100, 100, 1)

	is_crew_affected(var/mob/living/player)
		if(player.mind)
			if((!player.mind.is_antagonist() || include_antags) && prob(player_chance))
				. = TRUE

	proc/notify_player(var/mob/living/player)
		if(notify_player)
			SPAWN(0)
				if(isnum(notify_player))
					notify_player = "Aspects of this round may different from what you might normally expect."
				alert(player, "You have been selected for narrative enhancement!  [notify_player]", "Special Round!!!")
		//else if(query_player)
			//"You have been selected for narrative enhancement!  Aspects of this round may different from what you might normally expect."
		. = TRUE

	apply_to_player(var/mob/living/player)
		. = notify_player(player)

	event_effect(var/source)
		if(current_state < GAME_STATE_PLAYING)
			random_events.delayed_start[src] = source
			queued = TRUE
			message_admins(SPAN_INTERNAL("Round Start Event: [src.name] queued!"))
		else if(queued)
			..()
			return TRUE
		else
			message_admins(SPAN_INTERNAL("Round Start Event: [src.name] skipped!  It was not queued in time."))

	cleanup()
		. = ..()
		queued = FALSE
