/datum/game_mode/mixed/spooky
	name = "Spooky"
	config_tag = "spooky"
	latejoin_antag_compatible = 1
	latejoin_antag_roles = list(ROLE_CHANGELING = 1, ROLE_VAMPIRE = 1, ROLE_WEREWOLF = 1, ROLE_HUNTER = 1)
	antag_token_support = TRUE
	has_werewolves = TRUE
	traitor_types = list(ROLE_CHANGELING = 1, ROLE_VAMPIRE = 1, ROLE_WEREWOLF = 1)
	major_threats = list(ROLE_WRAITH)

/datum/game_mode/mixed/mixed_rp/announce()
	boutput(world, "<B>The current game mode is - Mixed Spooky!</B>")
	boutput(world, "<B>Watch out for ghosts!</B>")

/datum/game_mode/mixed/pre_setup()
	global.debug_mixed_forced_wraith = 1
