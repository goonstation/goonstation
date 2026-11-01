/datum/game_mode/mixed/spooky
	name = "Spooky"
	config_tag = "spooky"
	latejoin_antag_compatible = 1
#ifdef RP_MODE
	latejoin_antag_roles = list(ROLE_CHANGELING = 1, ROLE_VAMPIRE = 1)
#else
	latejoin_antag_roles = list(ROLE_CHANGELING = 1, ROLE_VAMPIRE = 1, ROLE_WEREWOLF = 1, ROLE_HUNTER = 1)
#endif
	antag_token_support = TRUE
	has_werewolves = TRUE
#ifdef RP_MODE
	traitor_types = list(ROLE_CHANGELING = 1, ROLE_VAMPIRE = 1)
#else
	traitor_types = list(ROLE_CHANGELING = 1, ROLE_VAMPIRE = 1, ROLE_WEREWOLF = 1)
#endif
	major_threats = list(ROLE_WRAITH = 1)
	var/minimum_players = 15

/datum/game_mode/mixed/spooky/announce()
	boutput(world, "<B>The current game mode is - Spooky!</B>")
	boutput(world, "<B>Watch out for ghosts!</B>")

/datum/game_mode/mixed/spooky/pre_setup()
#ifndef ME_AND_MY_40_ALT_ACCOUNTS
	var/num_players = src.roundstart_player_count()
	if (num_players < minimum_players)
		message_admins("<b>ERROR: Minimum player count of [minimum_players] required for Spooky game mode, aborting spook round pre-setup.</b>")
		logTheThing(LOG_GAMEMODE, src, "Failed to start Spooky mode. [num_players] players were ready but a minimum of [minimum_players] players is required. ")
		return 0
#endif
	global.debug_mixed_forced_wraith = 1
	. = ..()
