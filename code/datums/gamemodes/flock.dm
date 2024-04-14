/datum/game_mode/flock
	name = "Flock (Beta)"
	config_tag = "flock"
	regular = FALSE

	shuttle_available = SHUTTLE_AVAILABLE_DELAY
	shuttle_available_threshold = 20 MINUTES // default value, probably change this
	var/const/waittime_l = 600 //lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 1800 //upper bound on time before intercept arrives (in tenths of seconds)

	//NOTE: if you need to track something, put it here
	var/list/datum/mind/flockminds = list()

/datum/game_mode/flock/announce()
	boutput(world, "<B>The current game mode is - Flock!</B>")
	boutput(world, "<B>flavor text goes here</B>")

/datum/game_mode/flock/pre_setup()
	var/list/possible_flockminds = list()

	// TODO: Use this for scaling players
//	var/num_players = 0 //commented since seemingly unused?
//	for (var/mob/new_player/player in mobs)
//		if(player.client && player.ready) num_players++

	// TODO: Handle token players

	possible_flockminds = get_possible_enemies(ROLE_FLOCKMIND, 1)
	var/list/chosen_flockminds = antagWeighter.choose(pool = possible_flockminds, role = ROLE_FLOCKMIND, amount = 1, recordChosen = 1)
	flockminds |= chosen_flockminds
	for (var/datum/mind/flockmind in flockminds)
		flockmind.assigned_role = "MODE"
		src.traitors += flockmind
		possible_flockminds.Remove(flockmind)

	return TRUE

/datum/game_mode/flock/post_setup()
	for (var/datum/mind/flockmind in flockminds)
		flockmind.add_antagonist(ROLE_FLOCKMIND, source = ANTAGONIST_SOURCE_ROUND_START)
	SPAWN(rand(waittime_l, waittime_h))
		send_intercept()
	. = ..()

/datum/game_mode/flock/victory_msg()
	return "<span style='font-size:20px'><b>[victory_headline()]</b><br>[victory_body()]</span>"

/datum/game_mode/flock/victory_headline()
	if (flock_signal_unleashed)
		return "Flock victory!"
	else
		var/living_flockmind = FALSE
		for (var/datum/mind/flockmind as anything in src.flockminds)
			if (isalive(flockmind.current))
				living_flockmind = TRUE
				break
		if (living_flockmind)
			return "Crew victory!"
		else
			return "Total crew victory!"

/datum/game_mode/flock/victory_body()
	if (flock_signal_unleashed)
		return "The Flock managed to construct a relay and transmit The Signal. One step closer to its mysterious goals."
	else
		var/living_flockmind = FALSE
		for (var/datum/mind/flockmind as anything in src.flockminds)
			if (isalive(flockmind.current))
				living_flockmind = TRUE
				break
		if (living_flockmind)
			return "The crew succeeded in preventing the Flock from transmitting into the void."
		else
			return "The Flock was wiped out, their consciousness ceasing to exist as their last drone was destroyed."

/datum/game_mode/flock/declare_completion()
	boutput(world, victory_msg())
	. = ..()

