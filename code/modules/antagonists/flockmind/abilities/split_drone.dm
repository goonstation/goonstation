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
		boutput(F, SPAN_NOTICE("The drone does not respond to your command."))
		return TRUE
	if (isdead(target))
		boutput(F, SPAN_NOTICE("That drone is dead."))
		return TRUE
	if(F.flock.getComplexDroneCount() == 1)
		boutput(F, SPAN_ALERT("That's your last complex drone. Diffracting it would be suicide."))
		return TRUE
	if (!src.tutorial_check(FLOCK_ACTION_DIFFRACT, target))
		return TRUE
	boutput(F, SPAN_NOTICE("You diffract the drone."))
	logTheThing(LOG_COMBAT, holder.get_controlling_mob(), "casts diffract drone on [constructTarget(target)] at [log_loc(src.holder.owner)].")
	target.split_into_bits()

/datum/targetable/flockmindAbility/splitDrone/logCast(atom/target)
	return
