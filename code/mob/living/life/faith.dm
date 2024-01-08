#define FAITH_GEN_CHAPLAIN 1
#define FAITH_GEN_BASE 5

/datum/lifeprocess/faith

	process(var/datum/gas_mixture/environment)
		var/mult = get_multiplier()

		if (isunconscious(owner) || isdead(owner) || !owner.mind || isghostcritter(owner))
			// do nothing
		else if (owner.traitHolder.hasTrait("training_chaplain"))
			add_faith(FAITH_GEN_CHAPLAIN * mult) // chaplains produce a bit of faith just for being alive
		else if (!istype(get_area(owner), /area/station/chapel))
			// others need to be in the chapel
		else if (isvampire(owner) || isvampiricthrall(owner))
			// vampires are unholy and will not produce faith unless they are a chaplain
		else if (owner.traitHolder.hasTrait("atheist"))
		else
			add_faith(FAITH_GEN_BASE * mult)
		..()

/proc/add_faith(amount)
	for (var/datum/mind/M in ticker.minds)
		if (!M.current && !M.current.traitHolder.hasTrait("training_chaplain"))
			continue

		var/datum/trait/job/chaplain/chap = get_chaplain_trait(M.current)
		if (chap)
			chap.faith += amount

/proc/get_chaplain_trait(mob/target)
	var/datum/traitHolder/TH = target.traitHolder
	for(var/id in TH.traits)
		var/datum/trait/T = TH.traits[id]
		if (istype(T, /datum/trait/job/chaplain))
			var/datum/trait/job/chaplain/chap = T
			return chap



