/datum/game_mode/mixed/arcfiend
	name = "arcfiend"
	config_tag = "arcfiend"
	latejoin_antag_compatible = 1
	latejoin_antag_roles = list(ROLE_ARCFIEND)
	traitor_types = list(ROLE_ARCFIEND, ROLE_VAMPIRE)


	has_wizards = 0
	has_werewolves = 0
	has_blobs = 0

	num_enemies_divisor = 20

/datum/game_mode/mixed/vampire/announce()
	boutput(world, "<B>The current game mode is - Arcfiend!</B>")
	boutput(world, "<B>Energy draining monsters are hiding aboard the ship!</B>")
