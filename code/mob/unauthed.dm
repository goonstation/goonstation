/**
	* Unauthed
	*
	* A mob that is not authenticated. This exists because clients need some type of mob during the connection process,
	* but there are cases where we want to reject the client early, without creating a /mob/new_player.
	*/
/mob/unauthed
	anchored = ANCHORED
	has_typing_indicator = FALSE
	density = FALSE
	stat = STAT_DEAD
	canmove = 0
	anchored = ANCHORED

	New()
		. = ..()
		APPLY_ATOM_PROPERTY(src, PROP_MOB_INVISIBILITY, src, INVIS_ALWAYS)

	Login()
		return
