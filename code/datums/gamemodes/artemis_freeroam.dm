#ifdef ENABLE_ARTEMIS
/datum/game_mode/artemis_freeroam
	name = "free roam"
	config_tag = "freeroam"

/datum/game_mode/artemis_freeroam/announce()
	boutput(world, "<B>The current game mode is - Free Roam!</B>")
	boutput(world, "<B>Just have fun!</B>")

/datum/game_mode/artemis_freeroam/pre_setup()
	return 1
#endif
