/datum/game_mode/mixed/mixed_rp
	name = "Intrigue"
	config_tag = "mixed_rp"
	latejoin_antag_compatible = 1
	 //went with a trivial solution of adding more identical items to the list
	 //Input needed here

	antag_token_support = TRUE
	latejoin_antag_roles = list(ROLE_TRAITOR = 2, ROLE_CHANGELING = 1, ROLE_VAMPIRE = 1,  ROLE_WRESTLER = 1, ROLE_ARCFIEND = 1, ROLE_WIZARD = 0.5)
	// wizards are special cased in the parent to have a 10% chance to spawn for some fucking reason. It's not even a var it's just 10% always
	traitor_types = list(ROLE_TRAITOR = 1, ROLE_CHANGELING = 1, ROLE_VAMPIRE = 1, ROLE_SPY_THIEF = 0.5, ROLE_ARCFIEND = 1, ROLE_TRAITOR = 1, ROLE_SALVAGER = 0.5)

	major_threats = list(ROLE_WRAITH = 1)

	num_enemies_divisor = 12


/datum/game_mode/mixed/mixed_rp/announce()
	boutput(world, "<B>The current game mode is - Intrigue!</B>")
	boutput(world, "<B>Something could happen! Be on your guard!</B>")
