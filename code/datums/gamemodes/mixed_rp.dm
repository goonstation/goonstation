/datum/game_mode/mixed/mixed_rp
	name = "mixed (mild)"
	config_tag = "mixed_rp"
	latejoin_antag_compatible = 1
	latejoin_antag_roles = list("traitor", "changeling", "vampire", "wrestler")
	traitor_types = list("traitor","changeling","vampire", "spy_thief")


	has_wizards = 0
	has_werewolves = 0
	has_blobs = 0


/datum/game_mode/mixed/mixed_rp/announce()
	boutput(world, "<B>The current game mode is - Mixed Mild!</B>")
	boutput(world, "<B>Something could happen! Be on your guard!</B>")
