
/datum/lifeprocess/brain
	var/static/list/head_messages = list("Your head doesn't feel so good!",
										 "You get a pounding headache!",
										 "Your head.... Ow....",
										 "Why does your head hurt so much!",
										 "You should probably get your head checked out!")
	process(datum/gas_mixture/environment)
		..()
		var/mob/living/carbon/human/H = src.owner

		if (!istype(H))
			return

		var/brain_dmg = H.get_brain_damage()
		var/mult = get_multiplier()

		if (brain_dmg >= BRAIN_DAMAGE_MAJOR)
			if (probmult(30))
				H.nauseate(1)

			if (probmult(5))
				H.changeStatus("blinded", rand(10, 25) SECONDS)
		else if (brain_dmg >= BRAIN_DAMAGE_MODERATE)
			if (probmult(15))
				H.nauseate(1)

		if (brain_dmg >= BRAIN_DAMAGE_MODERATE && probmult(5))
			boutput(H, SPAN_ALERT(pick(src.head_messages)))
