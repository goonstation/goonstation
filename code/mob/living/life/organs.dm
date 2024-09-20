
/datum/lifeprocess/organs
	process(var/datum/gas_mixture/environment)
		if(!isdead(owner))
			owner.handle_organs(get_multiplier())
		..()


/mob/living/proc/handle_organs(var/mult = 1)//for things that arent humans, and dont override to use actual organs - they might use digestion ok
	src.organHolder?.stomach?.handle_digestion(mult)

/mob/living/carbon/human/handle_organs(var/mult = 1)
	if (src.ignore_organs)
		return

	if (!src.organHolder)
		src.organHolder = new(src)
		sleep(1 SECOND)

	var/datum/organHolder/oH = src.organHolder
	if (!oH.head && !isskeleton(src) && !src.nodamage) // skeletons can survive without their head
		src.death()

	// time to find out why this wasn't added - cirr
	oH.handle_organs(mult)


	if (!oH.skull && oH.head && !isskeleton(src) && !src.nodamage) // skeletons can also survive without their skull because reasons
		src.death()
		src.visible_message(SPAN_ALERT("<b>[src]</b>'s head collapses into a useless pile of skin mush with no skull to keep it in its proper shape!"),\
		SPAN_ALERT("Your head collapses into a useless pile of skin mush with no skull to keep it in its proper shape!"))

	//Wire note: Fix for Cannot read null.loc
	else if (oH.skull?.loc != src)
		oH.skull = null

	if (!oH.brain)
		if (!src.nodamage)
			src.death()
	else if (oH.brain.loc != src)
		oH.brain = null

	if (!oH.heart)
		if (!ischangeling(src) && !src.nodamage)
			if (src.get_oxygen_deprivation())
				src.take_brain_damage(3 * mult)
			else if (prob(10))
				src.take_brain_damage(1 * mult)

			src.changeStatus("knockdown", 5 * mult SECONDS)
			src.losebreath += 20 * mult
			src.take_oxygen_deprivation(20 * mult)
	else
		if (oH.heart.loc != src)
			oH.heart = null
		else if (oH.heart.robotic && oH.heart.emagged && !oH.heart.broken)
			src.changeStatus("drowsy", -20 SECONDS)
			if (src.sleeping) src.sleeping = 0
		else if (oH.heart.robotic && !oH.heart.broken)
			src.changeStatus("drowsy", -10 SECONDS)
			if (src.sleeping) src.sleeping = 0
		else if (oH.heart.broken)
			if (src.get_oxygen_deprivation())
				src.take_brain_damage(3 * mult)
			else if (prob(10))
				src.take_brain_damage(1 * mult)

			changeStatus("knockdown", 2 * mult SECONDS)
			src.losebreath += 20 * mult
			src.take_oxygen_deprivation(20 * mult)
		else if (src.organHolder.heart.get_damage() > 100)
			src.contract_disease(/datum/ailment/malady/flatline,null,null,1)

	// lungs are skipped until they can be removed/whatever
