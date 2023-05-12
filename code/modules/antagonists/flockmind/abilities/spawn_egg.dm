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
			boutput(F, "<span class='alert'>Space and exposed areas are unsuitable for rift placement!</span>")
			return TRUE

		if(IS_ARRIVALS(T.loc))
			boutput(F, "<spawn class='alert'>Your rift can't be placed inside arrivals!</span>")
			return TRUE

		if (!istype(T.loc, /area/station/) && !istype(T.loc, /area/tutorial/flock))
			boutput(F, "<spawn class='alert'>Your rift needs to be placed on the [station_or_ship()]!</span>")
			return TRUE

		if (istype(T, /turf/unsimulated/))
			boutput(F, "<span class='alert'>This kind of tile cannot support rift placement.</span>")
			return TRUE

		if (T.density)
			boutput(F, "<span class='alert'>Your rift cannot be placed inside a wall!</span>")
			return TRUE

		for (var/atom/O in T.contents)
			if (O.density)
				boutput(F, "<span class='alert'>That tile is blocked by [O].</span>")
				return TRUE

	if (!src.tutorial_check(FLOCK_ACTION_RIFT_SPAWN, T))
		return TRUE

	if (F)
		if (tgui_alert(F,"Would you like to spawn a rift?","Spawn Rift?",list("Yes","No")) != "Yes")
			return TRUE

	logTheThing(LOG_GAMEMODE, holder.get_controlling_mob(), "spawns a rift at [log_loc(src.holder.owner)].")
	F.spawnEgg()
