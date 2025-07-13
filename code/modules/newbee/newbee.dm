#define NEWBEE_ROUNDS 30
#define NEWBEE_ROUNDS_RP 30

/// indicates if this is a player who is new to goonstation
/datum/player/var/is_newbee = FALSE

/client/New()
	. = ..()
	check_newbee()

/// marks a player as a newbee if they are below the newbee rounds threshold. Grants them various new player indicators.
/client/proc/check_newbee()
	set waitfor = FALSE
	if (player.is_newbee)
		return //already marked as newbee
	var/list/round_stats = src.player.get_round_stats(TRUE)
	if (!round_stats)
		logTheThing(LOG_DEBUG, src, "check_newbee() failed, unable to fetch round stats.")
		return
	#ifdef RP_MODE
	if ((round_stats["participated_rp"] + (0.2 * round_stats["participated"])) <= NEWBEE_ROUNDS_RP)
	#else
	if ((round_stats["participated"] + (0.2 * round_stats["participated_rp"])) <= NEWBEE_ROUNDS)
	#endif
		//welcome new bee!
		player.is_newbee = TRUE

#undef NEWBEE_ROUNDS
#undef NEWBEE_ROUNDS_RP
