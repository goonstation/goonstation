/datum/random_event/major/antag/salvagers
	name = "Salvagers"
	required_elapsed_round_time = 12.8 MINUTES
	wont_occur_past_this_time = 35 MINUTES
	customization_available = 1
	announce_to_admins = 0 // Doing it manually.
	weight = 20

	var/antag_count = 0
	var/lock = 0
	var/admin_override = 0
	var/ghost_confirmation_delay = 2 MINUTES // time to acknowledge or deny respawn offer.
	var/minimum_count = 3

	is_event_available(var/ignore_time_lock = 0)
		if( emergency_shuttle.online )
			return 0

		if(ticker?.mode)
			if(istype(ticker.mode, /datum/game_mode/blob))
				return 0

			if(istype(ticker.mode, /datum/game_mode/revolution))
				return 0

			if (istype(ticker.mode, /datum/game_mode/nuclear))
				return 0

			if (istype(ticker.mode, /datum/game_mode/salvager))
				weight = initial(weight)+100

			if (istype(ticker.mode, /datum/game_mode/flock))
				wont_occur_past_this_time = 25 MINUTES

		if(length(eligible_dead_player_list(allow_dead_antags = TRUE)) < minimum_count)
			return 0

		return ..()

	admin_call(var/source)
		if (..())
			return

		if (src.lock)
			message_admins("Setup of previous [src] event hasn't finished yet, aborting.")
			return

		src.antag_count = input(usr, "How many Salvagers to spawn? ([length(eligible_dead_player_list(allow_dead_antags = TRUE))] players eligible)", src.name, 0) as num|null
		if (isnull(src.antag_count))
			return
		else if (src.antag_count < 1)
			return
		else
			src.antag_count = round(src.antag_count)

		src.admin_override = 1
		src.event_effect(source)
		return

	event_effect(var/source)
		if(src.lock)
			return
		if (src.admin_override != 1)
			if (!source && (!ticker.mode || ticker.mode.latejoin_antag_compatible == 0 || late_traitors == 0))
				message_admins("Salvagers are disabled in this game mode, aborting.")
				return

			if (emergency_shuttle.online)
				return
		message_admins(SPAN_INTERNAL("Setting up [src] event. Source: [source ? "[source]" : "random"]"))
		logTheThing(LOG_ADMIN, null, "Setting up [src] event. Source: [source ? "[source]" : "random"]")
		SPAWN(0)
			src.lock = TRUE
			do_event(source)

	proc/do_event(var/source)
		if (!src || !istype(src, /datum/random_event/major/antag/salvagers))
			return

		// 1: alert | 2: alert (chatbox) | 3: alert acknowledged (chatbox) | 4: no longer eligible (chatbox) | 5: waited too long (chatbox)
		var/list/text_messages = list()
		text_messages.Add("Would you like to respawn as a salvager? Your name will be added to the list of eligible candidates and may be selected at random by the game.")
		text_messages.Add("You are eligible to be respawned as a salvager. You have [src.ghost_confirmation_delay / 10] seconds to respond to the offer.")
		text_messages.Add("You have been added to the list of eligible candidates. The game will pick a player soon. Good luck!")

		// The proc takes care of all the necessary work (job-banned etc checks, confirmation delay).
		message_admins("Sending offer to eligible ghosts. They have [src.ghost_confirmation_delay / 10] seconds to respond.")
		var/list/datum/mind/candidates = dead_player_list(1, src.ghost_confirmation_delay, text_messages, allow_dead_antags = 1)

		if (!islist(candidates) || !length(candidates))
			message_admins("Couldn't set up Salvager; no ghosts responded. Source: [source ? "[source]" : "random"]")
			logTheThing(LOG_ADMIN, null, "Couldn't set up Salvager; no ghosts responded. Source: [source ? "[source]" : "random"]")
			src.post_event()
			return

		if(!admin_override && (length(candidates) < src.minimum_count) )
			message_admins("Couldn't set up Salvager; insufficient ghosts responded (had [length(candidates)], needed [src.minimum_count]). Source: [source ? "[source]" : "random"]")
			logTheThing(LOG_ADMIN, null, "Couldn't set up Salvager; insufficient ghosts responded (had [length(candidates)], needed [src.minimum_count]). Source: [source ? "[source]" : "random"]")
			src.post_event()
			return

		if(!antag_count)
			antag_count = rand(src.minimum_count, min(length(candidates), 5))

		for(var/antag_idx in 1 to src.antag_count)
			// Check against player preferences.
			var/attempts = 0
			var/datum/mind/lucky_dude = null

			while (attempts < 4 && length(candidates) && !(lucky_dude && istype(lucky_dude) && lucky_dude.current))
				lucky_dude = candidates[1]
				attempts++

			if (!(lucky_dude && istype(lucky_dude) && lucky_dude.current))
				message_admins("Couldn't set up Salvager; candidate selection failed (had [length(candidates)] candidate(s)). Source: [source ? "[source]" : "random"]")
				logTheThing(LOG_ADMIN, null, "Couldn't set up Salvager; candidate selection failed (had [length(candidates)] candidate(s)). Source: [source ? "[source]" : "random"]")
				src.post_event()
				return

			candidates -= lucky_dude
			log_respawn_event(lucky_dude, "Salvager", source)
			// Respawn and assign role.
			var/mob/M3
			if (!M3)
				M3 = lucky_dude.current
			else
				if (src.lock != 1) // Respawn might be in progress still.
					src.post_event()
				return

			// Shouldn't happen, will happen.
			if (lucky_dude.special_role)
				if (lucky_dude in ticker.mode.traitors)
					ticker.mode.traitors.Remove(lucky_dude)
				if (lucky_dude in ticker.mode.Agimmicks)
					ticker.mode.Agimmicks.Remove(lucky_dude)
				if (!lucky_dude.former_antagonist_roles.Find(lucky_dude.special_role))
					lucky_dude.former_antagonist_roles.Add(lucky_dude.special_role)
				if (!(lucky_dude in ticker.mode.former_antagonists))
					ticker.mode.former_antagonists.Add(lucky_dude)

			var/failed = FALSE
			var/mob/living/L = M3.humanize(equip_rank=FALSE)

			if (istype(L))
				L.mind?.wipe_antagonists()
				L.mind?.add_antagonist(ROLE_SALVAGER, do_equip = TRUE, do_relocate = TRUE, source = ANTAGONIST_SOURCE_RANDOM_EVENT)
			else
				failed = TRUE

			if (failed)
				message_admins("Couldn't set up Salvager Spawn; respawn failed. Source: [source ? "[source]" : "random"]")
				logTheThing(LOG_ADMIN, null, "Couldn't set up Salvager Spawn; respawn failed. Source: [source ? "[source]" : "random"]")
				antag_idx--
				return

			lucky_dude.assigned_role = "MODE"
			lucky_dude.special_role = ROLE_SALVAGER
			lucky_dude.random_event_special_role = 1
			if (!(lucky_dude in ticker.mode.Agimmicks))
				ticker.mode.Agimmicks.Add(lucky_dude)

			if (lucky_dude.current)
				lucky_dude.current.show_text("<h3>You have been respawned as a Salvager.</h3>", "blue")
			message_admins("[key_name(lucky_dude)] respawned as a random event Salvager. Source: [source ? "[source]" : "random"]")
		src.post_event()

	proc/post_event()
		if (!src || !istype(src, /datum/random_event/major/antag/salvagers))
			return

		src.lock = initial(src.lock)
		src.antag_count = initial(src.antag_count)
		src.admin_override = initial(src.admin_override)
		src.ghost_confirmation_delay = initial(src.ghost_confirmation_delay)
		src.minimum_count = initial(src.minimum_count)

		return
