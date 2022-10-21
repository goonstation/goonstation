/datum/game_mode/mixed/arcfiend
	name = "arcfiend"
	config_tag = "arcfiend"
	antag_token_support = TRUE
	latejoin_antag_compatible = 1
	latejoin_antag_roles = list(ROLE_ARCFIEND)
	traitor_types = list(ROLE_ARCFIEND = 1)


	has_wizards = 0
	has_werewolves = 0
	major_threats = list(ROLE_WRAITH)

	num_enemies_divisor = 20

/datum/game_mode/mixed/arcfiend/announce()
	boutput(world, "<B>The current game mode is - Arcfiend!</B>")
	boutput(world, "<B>Energy draining monsters are hiding aboard the ship!</B>")
