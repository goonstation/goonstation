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
	ROLE_NUKEOP_COMMANDER = "be_syndicate_commander",
	ROLE_VAMPIRE = "be_vampire",
	ROLE_GANG_LEADER = "be_gangleader",
	ROLE_GANG_MEMBER = "be_gangmember",
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


var/list/antagonist_datum_types_by_id = null
/**
  * Return the typepath of an antagonist datum for the given role define.
  *
  * Arguments:
  * * role - role to return a typepath for.
  */
/proc/get_antagonist_datum_type(role)
	RETURN_TYPE(/datum/antagonist)

	if (isnull(global.antagonist_datum_types_by_id))
		global.antagonist_datum_types_by_id = list()
		for (var/datum/antagonist/T as anything in concrete_typesof(/datum/antagonist))
			global.antagonist_datum_types_by_id[T::id] = T

	return global.antagonist_datum_types_by_id[role]


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
