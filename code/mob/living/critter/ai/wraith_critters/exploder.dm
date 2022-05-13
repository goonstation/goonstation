/datum/aiHolder/wraith_critters/exploder

/datum/aiHolder/wraith_critters/exploder/New()
	..()
	default_task = get_instance(/datum/aiTask/prioritizer/exploder, list(src))

/datum/aiTask/prioritizer/exploder
	name = "base thinking (should never see this)"

/datum/aiTask/prioritizer/exploder/New()
	..()
	logTheThing("debug", src, null, "initialize")
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/rushdown, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/timed/wander, list(holder, src))

/datum/aiTask/prioritizer/exploder/on_reset()
	..()
	logTheThing("debug", src, null, "resetted")
	walk(holder.owner, 0)

/datum/aiTask/sequence/goalbased/rushdown
	name = "rushdown"
	weight = 1
	max_dist = 9

/datum/aiTask/sequence/goalbased/rushdown/New(parentHolder, transTask) //????
	..(parentHolder, transTask)
	logTheThing("debug", src, null, "Adding task")
	add_task(holder.get_instance(/datum/aiTask/succeedable/rushdown, list(holder)))

/datum/aiTask/sequence/goalbased/rushdown/precondition()
	logTheThing("debug", src, null, "Preconditions")
	. = TRUE // no precondition required that isn't already checked for targets

/datum/aiTask/sequence/goalbased/rushdown/get_targets()
	logTheThing("debug", src, null, "Get targets")
	. = list()
	for(var/mob/living/carbon/human/T in view(max_dist, holder.owner))
		if(isliving(T) && !is_incapacitated(T))
			. += T
	. = get_path_to(holder.owner, ., max_dist*2, 1)

/datum/aiTask/succeedable/rushdown
	name = "rushdown subtask"

/datum/aiTask/succeedable/rushdown/failed()
	logTheThing("debug", src, null, "Failure check")
	var/mob/living/carbon/human/human_target = holder.target
	if(!human_target || BOUNDS_DIST(holder.owner, human_target) > 0 || fails >= max_fails)
		logTheThing("debug", src, null, "Failure")
		. = TRUE

/datum/aiTask/succeedable/rushdown/succeeded()
	logTheThing("debug", src, null, "SuccessCheck")
	var/mob/living/carbon/human/human_target = holder.target
	var/mob/living/critter/exploder/F = holder.owner
	if(BOUNDS_DIST(holder.owner, human_target) < 1)
		logTheThing("debug", src, null, "Success")
		holder.owner.visible_message(holder.owner.health)
		if (F.health > 60)
			F.set_a_intent(INTENT_HARM)
			F.set_dir(get_dir(holder.owner, holder.target))
			F.hand_attack(human_target)
		else
			F.emote("scream")
			sleep(2 SECONDS)
			return F.gib()
	else
		logTheThing("debug", src, null, "NO success")
		return FALSE

/datum/aiTask/succeedable/rushdown/on_reset()

	..()
	logTheThing("debug", src, null, "rushdown reset")
