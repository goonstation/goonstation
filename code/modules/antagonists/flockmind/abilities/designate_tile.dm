/datum/targetable/flockmindAbility/designateTile
	name = "Designate Priority Tile"
	desc = "Add or remove a tile to the urgent tiles the flock should claim."
	icon_state = "designate_tile"
	cooldown = 0
	sticky = TRUE

/datum/targetable/flockmindAbility/designateTile/cast(atom/target)
	if(..())
		return TRUE
	var/mob/living/intangible/flock/F = holder.owner
	var/turf/T = get_turf(target)
	if(!(istype(T, /turf/simulated) || istype(T, /turf/space)) || !flockTurfAllowed(T))
		boutput(holder.get_controlling_mob(), "<span class='alert'>The flock can't convert this.</span>")
		return TRUE
	if(isfeathertile(T))
		boutput(holder.get_controlling_mob(), "<span class='alert'>This tile has already been converted.</span>")
		return TRUE
	if (!(T in F.flock.priority_tiles))
		for (var/name in F.flock.busy_tiles)
			if (T == F.flock.busy_tiles[name])
				boutput(holder.get_controlling_mob(), "<span class='alert'>This tile is already scheduled for conversion!</span>")
				return TRUE
	if (!src.tutorial_check(FLOCK_ACTION_MARK_TILE, T))
		return TRUE
	F.flock?.togglePriorityTurf(T)
