/turf/simulated/floor/engine/attack_hand(var/mob/user)
	if ((!( user.canmove ) || user.restrained() || !( user.pulling )))
		return
	if (user.pulling.anchored)
		return
	if ((user.pulling.loc != user.loc && BOUNDS_DIST(user, user.pulling) > 0))
		return
	if (ismob(user.pulling))
		var/mob/M = user.pulling
		var/mob/t = M.pulling
		M.remove_pulling()
		step(user.pulling, get_dir(user.pulling.loc, src))
		M.set_pulling(t)
	else
		step(user.pulling, get_dir(user.pulling.loc, src))
	return

/turf/simulated/floor/engine/blob_act(var/power)
	if (prob(15))
		ReplaceWithSpace()
		qdel(src)
		return
	return
