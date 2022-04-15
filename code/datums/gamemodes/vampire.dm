/datum/game_mode/mixed/vampire //todo : 'horror' mode
	name = "vampire"
	config_tag = "vampire"
	latejoin_antag_compatible = 1
	latejoin_antag_roles = list(ROLE_VAMPIRE)
	traitor_types = list(ROLE_VAMPIRE)


	has_wizards = 0
	has_werewolves = 0
	has_blobs = 0

	num_enemies_divisor = 20

/datum/game_mode/mixed/vampire/announce()
	boutput(world, "<B>The current game mode is - Vampire!</B>")
	boutput(world, "<B>Don't be scared!</B>")

