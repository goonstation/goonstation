/datum/aiHolder/human


/datum/aiTask/timed/targeted/human/get_targets()
	var/list/targets = list()
	if(holder.owner)
		for(var/mob/living/M in view(target_range, holder.owner))
			if(isalive(M))
				targets += M
	return targets

