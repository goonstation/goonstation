/datum/element/lifeprocess/faith/process(mob/living/target, mult, datum/gas_mixture/environment)
	if (!target.client || !isliving(target) || !isalive(target) || isghostcritter(target) || isintangible(target))
		return

	// At 0 faith, Chaplains will generate as much as a normal person in the Chapel.
	// At FAITH_STARTING, faith generated will decrease linearly.
	var/datum/trait/job/chaplain/chaplain_training = target.traitHolder?.getTrait("training_chaplain")
	if (chaplain_training)
		var/amount = min(FAITH_STARTING / max(chaplain_training.faith, 1), FAITH_GEN_BASE) * mult
		if (amount > 0)
			chaplain_training.faith += amount * chaplain_training.faith_mult
		else
			chaplain_training.faith += amount

		return

	// Non-Chaplains need to be in the Chapel.
	if (!istype(get_area(target), /area/station/chapel))
		return

	// Unholy creatures don't produce faith unless they are a Chaplain.
	if (isvampire(target) || isvampiricthrall(target) || iswraith(target) || target.bioHolder?.HasEffect("revenant"))
		return

	// Atheists don't believe in such things as faith. Unless they're a Chaplain.
	if (target.traitHolder?.hasTrait("atheist"))
		return

	var/amount = FAITH_GEN_BASE * mult
	for_by_tcl(chaplain, /datum/trait/job/chaplain)
		if (amount > 0)
			chaplain.faith += amount * chaplain.faith_mult
		else
			chaplain.faith += amount
