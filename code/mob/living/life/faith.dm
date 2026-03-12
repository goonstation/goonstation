
/datum/lifeprocess/faith

	process(datum/gas_mixture/environment)
		var/mult = get_multiplier()

		if (isunconscious(owner) || isdead(owner) || isghostcritter(owner) || isintangible(owner) || !isliving(owner) || !owner.client)
			// do nothing
		else if (owner.traitHolder.hasTrait("training_chaplain"))
			// At 0 faith, chaplains will generate as much as a normal person in the chapel
			// At FAITH_STARTING faith, chaplains will produce 1 faith/t
			var/amount = min(FAITH_STARTING / max(1, get_chaplain_faith(owner)), FAITH_GEN_BASE)
			modify_chaplain_faith(owner, amount * mult)
		else if (!istype(get_area(owner), /area/station/chapel))
			// non-chaplains need to be in the chapel
		else if (isvampire(owner) || isvampiricthrall(owner) || iswraith(owner) || owner.bioHolder.HasEffect("revenant"))
			// vampires are unholy and will not produce faith unless they are a chaplain
		else if (owner.traitHolder.hasTrait("atheist"))
			// atheists don't produce faith unless they are a chaplain (the lifeprocess should already be removed, though)
		else
			// They're a non-chaplain in the chapel
			add_faith(FAITH_GEN_BASE * mult)
		..()

/// Add faith to all chaplains on the station
/proc/add_faith(amount)
	for (var/datum/trait/job/chaplain/chap in by_type[/datum/trait/job/chaplain])
		var/to_add = amount
		if (to_add > 0)
			to_add *= chap.faith_mult
		chap.faith += to_add

/proc/get_chaplain_faith(mob/target)
	var/datum/trait/job/chaplain/chap_trait = target.traitHolder?.getTrait("training_chaplain")
	if (chap_trait)
		return chap_trait.faith

/proc/modify_chaplain_faith(mob/target, amount)
	var/datum/trait/job/chaplain/chap_trait = target.traitHolder?.getTrait("training_chaplain")
	if (chap_trait)
		// faith mult (atheist) only applies to gains
		if(amount > 0)
			amount *= chap_trait.faith_mult
		chap_trait.faith += amount
		return chap_trait.faith
