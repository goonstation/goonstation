/datum/game_mode/intrusion
	name = "Intrusion"
	config_tag = "intrusion"
	shuttle_available = SHUTTLE_AVAILABLE_DELAY
	shuttle_available_threshold = 30 MINUTES

	//latejoin_antag_compatible = TRUE
	//latejoin_only_if_all_antags_dead = TRUE
	//do_antag_random_spawns = TRUE
	do_random_events = TRUE
	escape_possible = TRUE

	antag_token_support = FALSE

/datum/game_mode/intrusion/announce()
	boutput(world, "<b>The current game mode is - <font color='purple'>Intrusion</font>!</b>")
	boutput(world, "<b>An otherworldly entity has become aware of this reality and wants to integrate itself!</b>")
	boutput(world, "<b>You must stop its invasion force and banish it back to its own plane of existence.</b>")
