ABSTRACT_TYPE(/datum/storyteller)
/datum/storyteller
	var/name
	var/description

	var/weight
	var/gamemodes

	var/major_event_start = 30 MINUTES
	var/major_time_range = list(11 MINUTES, 20 MINUTES)

	var/minor_event_start = 10 MINUTES
	var/minor_time_range = list(400 SECONDS, 800 SECONDS)

	var/spawn_event_start = 23 MINUTES
	var/spawn_time_range = list(8 MINUTES, 12 MINUTES)
	var/dead_players_threshold = 0.3
#ifdef RP_MODE
	var/alive_antags_threshold = 0.04
#else
	var/alive_antags_threshold = 0.1
#endif
	var/minimum_population = 15

	proc/set_active(datum/event_controller/random_events)

		random_events.major_events_begin = src.major_event_start
		random_events.time_between_major_events_lower = src.major_time_range[1]
		random_events.time_between_major_events_upper = src.major_time_range[2]

		random_events.minor_events_begin = src.minor_event_start
		random_events.time_between_minor_events_lower = src.minor_time_range[1]
		random_events.time_between_minor_events_upper = src.minor_time_range[2]

		random_events.spawn_events_begin = src.spawn_event_start
		random_events.time_between_spawn_events_lower = src.spawn_time_range[1]
		random_events.time_between_spawn_events_upper = src.spawn_time_range[2]
		random_events.dead_players_threshold = src.dead_players_threshold
		random_events.alive_antags_threshold = src.alive_antags_threshold

		random_events.minimum_population = src.minimum_population

	proc/process()
		check_scheduled()

		if (ticker.round_elapsed_ticks >= major_event_start)
			if (ticker.round_elapsed_ticks >= random_events.next_major_event)
				major_event_cycle()

		if (ticker.round_elapsed_ticks >= spawn_event_start)
			if (ticker.round_elapsed_ticks >= random_events.next_spawn_event)
				spawn_event()

		if (ticker.round_elapsed_ticks >= minor_event_start)
			if (ticker.round_elapsed_ticks >= random_events.next_minor_event)
				minor_event_cycle()

	proc/check_scheduled()
		for(var/queue in random_events.queued_events)
			for(var/queued_id in random_events.queued_events[queue])
				var/datum/random_event/RE = random_events.queued_events[queue][queued_id][1]
				var/event_time = random_events.queued_events[queue][queued_id][2]
				if(istype(RE) && event_time && ticker.round_elapsed_ticks >= event_time)
					random_events.queued_events[queue] -= queued_id
					RE.event_effect("Triggered by Queued Event")

	proc/major_event_cycle()
		random_events.major_event_cycle_count++
		if (total_clients() <= minimum_population)
			message_admins(SPAN_INTERNAL("A random event would have happened now, but there aren't enough players!"))
		else if (!random_events.major_events_enabled)
			message_admins(SPAN_INTERNAL("A random event would have happened now, but they are disabled!"))
		else
			random_events.do_random_event(random_events.major_events)

		random_events.major_event_timer = rand(random_events.time_between_major_events_lower, random_events.time_between_major_events_upper)
		random_events.next_major_event = ticker.round_elapsed_ticks + random_events.major_event_timer
		message_admins(SPAN_INTERNAL("Next event will occur at [round(random_events.next_major_event / 600)] minutes into the round."))

	proc/minor_event_cycle()
		random_events.minor_event_cycle_count++
		if (random_events.minor_events_enabled)
			random_events.do_random_event(random_events.minor_events)

		random_events.minor_event_timer = rand(random_events.time_between_minor_events_lower, random_events.time_between_minor_events_upper)
		random_events.next_minor_event = ticker.round_elapsed_ticks + random_events.minor_event_timer

	proc/spawn_event(var/type = "player")
		var/do_event = 1
		if (!random_events.events_enabled)
			message_admins(SPAN_INTERNAL("A spawn event would have happened now, but they are disabled!"))
			do_event = 0
		if (total_clients() < minimum_population)
			message_admins(SPAN_INTERNAL("A spawn event would have happened now, but there is not enough players!"))
			do_event = 0

		if (do_event && ticker?.mode?.do_random_events)
			var/aap = get_alive_antags_percentage()
			var/dcp = get_dead_crew_percentage()
			if (aap < random_events.alive_antags_threshold && (ticker?.mode?.do_antag_random_spawns))
				random_events.do_random_event(random_events.antag_spawn_events, source = "spawn_antag")
				message_admins(SPAN_INTERNAL("Antag spawn event success!<br>[round(100 * aap, 0.1)]% of the alive crew were antags."))
			else if (dcp > random_events.dead_players_threshold)
				random_events.do_random_event(random_events.player_spawn_events, source = "spawn_player")
				message_admins(SPAN_INTERNAL("Player spawn event success!<br>[round(100 * dcp, 0.1)]% of the entire crew were dead."))
			else
				message_admins("<span class='internal'>A spawn event would have happened now, but it was not needed based on alive players + antagonists headcount or game mode!<br> \
								[round(100 * aap, 0.1)]% of the alive crew were antags and [round(100 * dcp, 0.1)]% of the entire crew were dead.</span>")

		random_events.next_spawn_event = ticker.round_elapsed_ticks + rand(random_events.time_between_spawn_events_lower, random_events.time_between_spawn_events_upper)


/datum/storyteller/basic
	name = "Standard"
	description = "Legacy. The way it used to be"


/datum/storyteller/debug
	name = "Rubber Ducky"
	description = "Duck Eat Grubs! Now Less Bugs! Yay!"

	major_event_start = 3 MINUTES
	major_time_range = list(5 MINUTES, 10 MINUTES)

	minor_event_start = 3 MINUTES
	minor_time_range = list(3 MINUTES, 6 MINUTES)

	spawn_event_start = 10 MINUTES
	spawn_time_range = list(4 MINUTES, 6 MINUTES)

	minimum_population = 0


/datum/storyteller/player_threats
	name = "Many Antags"
	description = "Maintain a high antag population"

	spawn_event_start = 5 MINUTES
	spawn_time_range = list(5 MINUTES, 8 MINUTES)

	major_event_start = 15 MINUTES
	major_time_range = list(15 MINUTES, 25 MINUTES)

	minor_event_start = 8 MINUTES
	minor_time_range = list(6 MINUTES, 12 MINUTES)

	alive_antags_threshold = 0.17

/datum/storyteller/player_driven
	name = "Voir"
	description = "Pushes out events if death or other actions occur."

	var/last_deaths
	var/last_violence
	var/last_playerdeaths

	process()
		if(game_stats.GetStat("violence") > last_violence + 50)
			last_violence = game_stats.GetStat("violence")
			if(prob(30))
				random_events.next_minor_event += rand(1 MINUTE, 2 MINUTES)

		if(game_stats.GetStat("deaths") > last_deaths + 2)
			last_deaths = game_stats.GetStat("deaths")
			random_events.next_minor_event += rand(1 MINUTE, 2 MINUTES)
			if(prob(30))
				random_events.next_major_event += rand(1 MINUTE, 2 MINUTES)

		if(game_stats.GetStat("playerdeaths") > last_playerdeaths)
			last_playerdeaths = game_stats.GetStat("playerdeaths")
			random_events.next_minor_event += rand(1 MINUTE, 2 MINUTES)
			if(prob(30))
				random_events.next_major_event += rand(1 MINUTE, 2 MINUTES)

		..()
