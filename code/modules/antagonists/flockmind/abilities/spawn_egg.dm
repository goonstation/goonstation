/datum/targetable/flockmindAbility/spawnEgg
	name = "Spawn Rift"
	desc = "Spawn an rift where you are, and from there, begin."
	icon_state = "spawn_egg"
	targeted = FALSE
	cooldown = 0

/datum/targetable/flockmindAbility/spawnEgg/cast(atom/target)
	if(..())
		return TRUE

	var/mob/living/intangible/flock/flockmind/F = holder.owner

	var/turf/T = get_turf(F)

	if (!isadmin(F))
		if (istype(T, /turf/space/) || istype(T.loc, /area/station/solar) || istype(T.loc, /area/station/mining/magnet))
			boutput(F, SPAN_ALERT("Space and exposed areas are unsuitable for rift placement!"))
			return TRUE

		if(IS_ARRIVALS(T.loc))
			boutput(F, SPAN_ALERT("Your rift can't be placed inside arrivals!"))
			return TRUE

		if (!istype(T.loc, /area/station/) && !istype(T.loc, /area/tutorial/flock))
			boutput(F, SPAN_ALERT("Your rift needs to be placed on the [station_or_ship()]!"))
			return TRUE

		if (istype(T, /turf/unsimulated/))
			boutput(F, SPAN_ALERT("This kind of tile cannot support rift placement."))
			return TRUE

		if (T.density)
			boutput(F, SPAN_ALERT("Your rift cannot be placed inside a wall!"))
			return TRUE

		if (ismap("DONUT3") && (istype(T.loc, /area/station/medical/asylum) || istype(T.loc, /area/station/crew_quarters/clown)))
			boutput(F, SPAN_ALERT("Your rift needs to be placed on the [station_or_ship()]!"))
			return TRUE

		for (var/atom/O in T.contents)
			if (O.density)
				boutput(F, SPAN_ALERT("That tile is blocked by [O]."))
				return TRUE

	if (!src.tutorial_check(FLOCK_ACTION_RIFT_SPAWN, T))
		return TRUE

	if (F)
		if (tgui_alert(F,"Would you like to spawn a rift?","Spawn Rift?",list("Yes","No"), theme = "flock") != "Yes")
			return TRUE

	logTheThing(LOG_GAMEMODE, holder.get_controlling_mob(), "spawns a rift at [log_loc(src.holder.owner)].")
	message_ghosts("<b>A flockmind</b> has spawned a rift at [log_loc(src.holder.owner, ghostjump=TRUE)].")
	F.spawnEgg()

/datum/targetable/flockmindAbility/spawnEgg/logCast(atom/target)
	return
