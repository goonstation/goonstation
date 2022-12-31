/datum/game_mode/mixed/mixed_rp
	name = "mixed (mild)"
	config_tag = "mixed_rp"
	latejoin_antag_compatible = 1
	 //went with a trivial solution of adding more identical items to the list
	 //Input needed here

	antag_token_support = TRUE
	latejoin_antag_roles = list(ROLE_TRAITOR = 2, ROLE_CHANGELING = 1, ROLE_VAMPIRE = 1,  ROLE_WRESTLER = 1, ROLE_ARCFIEND = 1)
	traitor_types = list(ROLE_TRAITOR = 1, ROLE_CHANGELING = 1, ROLE_VAMPIRE = 1, ROLE_SPY_THIEF = 1, ROLE_ARCFIEND = 1, ROLE_TRAITOR = 1)

	has_wizards = 0
	has_werewolves = 0
	major_threats = list(ROLE_WRAITH = 1)

	num_enemies_divisor = 12


/datum/game_mode/mixed/mixed_rp/announce()
	boutput(world, "<B>The current game mode is - Mixed Mild!</B>")
	boutput(world, "<B>Something could happen! Be on your guard!</B>")
