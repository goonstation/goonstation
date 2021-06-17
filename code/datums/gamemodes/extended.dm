/datum/game_mode/extended
	name = "extended"
	config_tag = "extended"
	do_antag_random_spawns = 0
	latejoin_antag_compatible = 0

/datum/game_mode/extended/pre_setup()
	. = ..()
	for(var/datum/mind/mind in antag_token_list())
		mind.current?.client?.using_antag_token = FALSE

/datum/game_mode/extended/announce()
	boutput(world, "<B>The current game mode is - Extended!</B>")
	boutput(world, "<B>Just have fun!</B>")
