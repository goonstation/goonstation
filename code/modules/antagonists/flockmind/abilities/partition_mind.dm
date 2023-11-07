/datum/targetable/flockmindAbility/partitionMind
	name = "Partition Mind"
	icon_state = "partition_mind"
	cooldown = 60 SECONDS
	targeted = FALSE
	///Are we still waiting for ghosts to respond
	var/waiting = FALSE

/datum/targetable/flockmindAbility/partitionMind/New()
	src.desc = "Create a Flocktrace. Requires [FLOCKTRACE_COMPUTE_COST] total compute per trace."
	..()

/datum/targetable/flockmindAbility/partitionMind/cast(atom/target)
	if(waiting || ..())
		return TRUE

	var/mob/living/intangible/flock/flockmind/F = holder.owner

	if(length(F.flock.traces) >= F.flock.max_trace_count)
		if (length(F.flock.traces) < round(FLOCK_RELAY_COMPUTE_COST / FLOCKTRACE_COMPUTE_COST))
			boutput(holder.get_controlling_mob(), SPAN_ALERT("You need more compute!"))
		else
			boutput(holder.get_controlling_mob(), SPAN_ALERT("You cannot make any more Flocktraces!"))
		return TRUE

	if (!src.tutorial_check(FLOCK_ACTION_PARTITION))
		return TRUE

	waiting = TRUE
	SPAWN(0)
		F.partition()
		waiting = FALSE
