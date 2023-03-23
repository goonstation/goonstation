/datum/targetable/flockmindAbility/ping
	name = "Ping"
	desc = "Request attention from other elements of the flock."
	icon_state = "ping"
	cooldown = 0.3 SECONDS

/datum/targetable/flockmindAbility/ping/cast(atom/target)
	if(..())
		return TRUE
	if (!isturf(target.loc) && !isturf(target))
		return TRUE
	src.tutorial_check(FLOCK_ACTION_PING, target, TRUE) //you can always ping
	var/mob/living/intangible/flock/F = holder.owner
	F.flock?.ping(target, holder.owner)
