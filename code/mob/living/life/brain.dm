
/datum/lifeprocess/brain
	var/static/list/head_messages = list("Your head doesn't feel so good!",
										 "You get a pounding headache!",
										 "Your head.... Ow....",
										 "Why does your head hurt so much!",
										 "You should probably get your head checked out!")
	process(datum/gas_mixture/environment)
		..()

		if (!istype(src.human_owner) || isdead(src.human_owner))
			return

		var/brain_dmg = src.human_owner.get_brain_damage()
		var/mult = get_multiplier()

		if (brain_dmg >= BRAIN_DAMAGE_MAJOR)
			if (probmult(30))
				src.human_owner.nauseate(1)

			if (probmult(5))
				src.human_owner.changeStatus("blinded", rand(10, 25) SECONDS)
		else if (brain_dmg >= BRAIN_DAMAGE_MODERATE)
			if (probmult(15))
				src.human_owner.nauseate(1)

		if (brain_dmg >= BRAIN_DAMAGE_MODERATE && probmult(5))
			boutput(src.human_owner, SPAN_ALERT(pick(src.head_messages)))
