/datum/targetable/flockmindAbility/splitDrone
	name = "Diffract Drone"
	desc = "Split a drone into flockbits, mindless automata that only convert whatever they find."
	icon_state = "diffract"
	cooldown = 0

/datum/targetable/flockmindAbility/splitDrone/cast(mob/living/critter/flock/drone/target)
	if(..())
		return TRUE
	if(!istype(target))
		return TRUE
	var/mob/living/intangible/flock/flockmind/F = holder.owner
	if(!F.flock || F.flock != target.flock)
		boutput(F, "<span class='notice'>The drone does not respond to your command.</span>")
		return TRUE
	if (isdead(target))
		boutput(F, "<span class='notice'>That drone is dead.</span>")
		return TRUE
	if(F.flock.getComplexDroneCount() == 1)
		boutput(F, "<span class='alert'>That's your last complex drone. Diffracting it would be suicide.</span>")
		return TRUE
	if (!src.tutorial_check(FLOCK_ACTION_DIFFRACT, target))
		return TRUE
	boutput(F, "<span class='notice'>You diffract the drone.</span>")
	logTheThing(LOG_COMBAT, holder.get_controlling_mob(), "casts diffract drone on [constructTarget(target)] at [log_loc(src.holder.owner)].")
	target.split_into_bits()
