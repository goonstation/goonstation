/datum/game_mode/flock
	name = "flock"
	config_tag = "flock"

	shuttle_available = 2
	shuttle_available_threshold = 12000 // 20 min, default value, probably change this

	//NOTE: if you need to track something, put it here
	var/list/flockminds = list()

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
		flockmind.special_role = ROLE_FLOCKMIND
		possible_flockminds.Remove(flockmind)

	return 1

/datum/game_mode/flock/post_setup()
	//TODO
	return 1

/datum/game_mode/flock/check_finished()
	//TODO
	. = ..()

/datum/game_mode/flock/declare_completion()
	//TODO
	. = ..()


