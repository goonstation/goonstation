/client/proc/gearspawn_traitor()
	set category = "Commands"
	set name = "Call Syndicate"
	set desc="Teleports useful items to your location."

	if (usr.stat || !isliving(usr) || isintangible(usr))
		usr.show_text("You can't use this command right now.", "red")
		return

	var/uplink_path = get_uplink_type(usr, /obj/item/uplink/syndicate)
	var/obj/item/uplink/syndicate/U = new uplink_path(usr.loc)
	if (!usr.put_in_hand(U))
		U.set_loc(get_turf(usr))
		usr.show_text("<h3>Uplink spawned. You can find it on the floor at your current location.</h3>", "blue")
	else
		usr.show_text("<h3>Uplink spawned. You can find it in your active hand.</h3>", "blue")

	if (usr.mind && istype(usr.mind))
		U.lock_code_autogenerate = 1
		U.setup(usr.mind)
		usr.show_text("<h3>The password to your uplink is '[U.lock_code]'.</h3>", "blue")
		usr.mind.store_memory("<B>Uplink password:</B> [U.lock_code].")

	usr.verbs -= /client/proc/gearspawn_traitor

	return

/proc/alive_player_count()
	. = 0
	for(var/client/C)
		var/mob/M = C.mob
		if(!M || istype(M, /mob/new_player))
			continue
		if (!isdead(M) && isliving(M))
			.++

/// returns a decimal representing the percentage of alive crew that are also antags
/proc/get_alive_antags_percentage()
	var/alive = alive_player_count()
	var/alive_antags = ticker.mode.traitors.len + length(ticker.mode.Agimmicks)

	for (var/datum/mind/antag in ticker.mode.traitors)
		var/mob/M = antag.current
		if (!M) continue
		if (!M.client || isdead(M))
			alive_antags--
	for (var/datum/mind/antag in ticker.mode.Agimmicks)
		var/mob/M = antag.current
		if (!M) continue
		if (!M.client || isdead(M))
			alive_antags--

	if (!alive)
		return 0
	else
		return (alive_antags / alive)

/// returns a decimal representing the percentage of dead crew (non-observers) to all crew
/proc/get_dead_crew_percentage()
	var/all = 0
	var/dead = 0
	var/observer = 0

	for(var/client/C)
		var/mob/M = C.mob
		if(!M || isnewplayer(M)) continue
		if (isdead(M) && !isliving(M))
			dead++
			if (M.mind?.get_player()?.joined_observer)
				observer++
		all++

	if (!all)
		return 0
	else
		return ((dead - observer) / all)

/// Associative list of role defines and their respective client preferences.
var/list/roles_to_prefs = list(
	ROLE_TRAITOR = "be_traitor",
	ROLE_SPY_THIEF = "be_spy",
	ROLE_NUKEOP = "be_syndicate",
	ROLE_VAMPIRE = "be_vampire",
	ROLE_GANG_LEADER = "be_gangleader",
	ROLE_WIZARD = "be_wizard",
	ROLE_CHANGELING = "be_changeling",
	ROLE_WEREWOLF = "be_werewolf",
	ROLE_BLOB = "be_blob",
	ROLE_WRAITH = "be_wraith",
	ROLE_HEAD_REVOLUTIONARY = "be_revhead",
	ROLE_CONSPIRATOR = "be_conspirator",
	ROLE_ARCFIEND = "be_arcfiend",
	ROLE_FLOCKMIND = "be_flock",
	ROLE_SALVAGER = "be_salvager",
	ROLE_MISC = "be_misc"
	)

/**
  * Return the name of a preference variable for the given role define.
  *
  * Arguments:
  * * role - role to return a client preference for.
  */
/proc/get_preference_for_role(var/role)
	return roles_to_prefs[role]


/**
  * Returns a path of a (presumably) valid uplink dependent on the user's mind.
  *
  * Arguments:
  * * target - the mob that will own the uplink.
  *	* uplink - the path of the uplink type that you wish to spawn
  */
/proc/get_uplink_type(mob/target, obj/item/uplink/uplink)
	var/added_text
	switch(target?.mind?.special_role)
		if(ROLE_TRAITOR)
			added_text = "traitor"
		if(ROLE_SPY_THIEF) //Uses its own proc to create it, but leaving this here in case a refactor of it comes by
			added_text = "spy_thief"
		if("spy")
			added_text = "spy"
		if(ROLE_HEAD_REVOLUTIONARY)
			added_text = "rev"
		if(ROLE_NUKEOP, ROLE_NUKEOP_COMMANDER)
			added_text = "nukeop"
		if(ROLE_OMNITRAITOR)
			added_text = "omni"
	return text2path("[uplink]/[added_text]")
