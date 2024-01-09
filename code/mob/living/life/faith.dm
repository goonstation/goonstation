
/datum/lifeprocess/faith

	process(var/datum/gas_mixture/environment)
		var/mult = get_multiplier()

		if (isunconscious(owner) || isdead(owner) || !owner.mind || isghostcritter(owner))
			// do nothing
		else if (owner.traitHolder.hasTrait("training_chaplain"))
			add_faith(FAITH_GEN_CHAPLAIN * mult) // chaplains produce a bit of faith just for being alive
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
		chap.faith += amount

/proc/get_chaplain_trait(mob/target)
	var/datum/traitHolder/TH = target.traitHolder
	for(var/id in TH.traits)
		var/datum/trait/T = TH.traits[id]
		if (istype(T, /datum/trait/job/chaplain))
			var/datum/trait/job/chaplain/chap = T
			return chap

/proc/get_chaplain_faith(mob/target)
	var/datum/trait/job/chaplain/chap_trait = get_chaplain_trait(target)
	if (chap_trait)
		return chap_trait.faith

/proc/modify_chaplain_faith(mob/target, amount)
	var/datum/trait/job/chaplain/chap_trait = get_chaplain_trait(target)
	if (chap_trait)
		chap_trait.faith += amount
		return chap_trait.faith


