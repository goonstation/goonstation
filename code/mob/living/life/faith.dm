
/datum/lifeprocess/faith

	process(var/datum/gas_mixture/environment)
		var/mult = get_multiplier()

		if (isunconscious(owner) || isdead(owner) || isghostcritter(owner) || isintangible(owner) || !isliving(owner) || !owner.client)
			// do nothing
		else if (owner.traitHolder.hasTrait("training_chaplain"))
			modify_chaplain_faith(owner, min(FAITH_STARTING / max(1, get_chaplain_faith(owner)), 5) * mult) // helps chaplains get back to normal
		else if (!istype(get_area(owner), /area/station/chapel))
			// others need to be in the chapel
		else if (isvampire(owner) || isvampiricthrall(owner) || iswraith(owner) || owner.bioHolder.HasEffect("revenant"))
			// vampires are unholy and will not produce faith unless they are a chaplain
		else if (owner.traitHolder.hasTrait("atheist"))
		else
			add_faith(FAITH_GEN_BASE * mult)
		..()

/proc/add_faith(amount)
	for (var/datum/trait/job/chaplain/chap in by_type[/datum/trait/job/chaplain])
		chap.faith += ((amount > 0) ? (amount * chap.faith_mult) : amount)

/proc/get_chaplain_trait(mob/target)
	return target.traitHolder?.getTrait("training_chaplain")

/proc/get_chaplain_faith(mob/target)
	var/datum/trait/job/chaplain/chap_trait = get_chaplain_trait(target)
	if (chap_trait)
		return chap_trait.faith

/proc/modify_chaplain_faith(mob/target, amount)
	var/datum/trait/job/chaplain/chap_trait = get_chaplain_trait(target)
	if (chap_trait)
		if(amount > 0)
			amount *= chap_trait.faith_mult
		chap_trait.faith += amount
		return chap_trait.faith
