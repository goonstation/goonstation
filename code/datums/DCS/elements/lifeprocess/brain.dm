/datum/element/lifeprocess/brain
	target_type = /mob/living/carbon/human
	var/static/list/messages = list(
		"Your head doesn't feel so good!",
		"You get a pounding headache!",
		"Your head.... Ow....",
		"Why does your head hurt so much!",
		"You should probably get your head checked out!",
	)

/datum/element/lifeprocess/brain/process(mob/living/carbon/human/target, mult, datum/gas_mixture/environment)
	if (isdead(target))
		return

	switch (target.get_brain_damage())
		// Moderate brain damage.
		if (BRAIN_DAMAGE_MODERATE to BRAIN_DAMAGE_MAJOR)
			if (probmult(15))
				target.nauseate(1)

			if (probmult(5))
				boutput(target, SPAN_ALERT(pick(src.messages)))

		// Major brain damage.
		if (BRAIN_DAMAGE_MAJOR to INFINITY)
			if (probmult(30))
				target.nauseate(1)

			if (probmult(5))
				target.changeStatus("blinded", rand(10, 25) SECONDS)

			if (probmult(5))
				boutput(target, SPAN_ALERT(pick(src.messages)))
