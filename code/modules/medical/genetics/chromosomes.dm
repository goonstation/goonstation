/datum/dna_chromosome
	var/name = "Stabilizer"
	var/desc = {"Prevents a gene from causing any genetic instability when given to an organism.
	It will do nothing to genes that are already present in an organism."}

	proc/check_apply(datum/bioEffect/BE)
		if(!istype(BE))
			return "Invalid gene."
		if(BE.altered)
			return "This gene has already been altered."
		if(!BE.stability_loss)
			return "This chromosome can only be applied to genes that cause stability loss."
		return null

	proc/apply(datum/bioEffect/BE)
		. = src.check_apply(BE)
		if (.)
			return

		if(BE.holder && !BE.activated_from_pool)
			BE.holder.genetic_stability = max(0, BE.holder.genetic_stability + BE.stability_loss)

		BE.stability_loss = 0
		BE.name = "Stabilized " + BE.name
		BE.altered = 1

/datum/dna_chromosome/anti_mutadone
	name = "Reinforcer"
	desc = "Prevents a gene from being removed by mutadone."

	check_apply(datum/bioEffect/BE)
		if(!istype(BE))
			return "Invalid gene."
		if(BE.altered)
			return "This gene has already been altered."
		if(!BE.curable_by_mutadone)
			return "This gene is already immune to mutadone."
		return null

	apply(datum/bioEffect/BE)
		. = src.check_apply(BE)
		if (.)
			return

		BE.curable_by_mutadone = 0
		BE.name = "Reinforced " + BE.name
		BE.altered = 1

/datum/dna_chromosome/reclaimer
	name = "Weakener"
	desc = "Makes a gene reclaimable and doubles the amount of materials you get from reclaiming it."

	check_apply(datum/bioEffect/BE)
		if(!istype(BE))
			return "Invalid gene."
		if(BE.altered)
			return "This gene has already been altered."
		return null

	apply(datum/bioEffect/BE)
		. = src.check_apply(BE)
		if (.)
			return

		BE.reclaim_fail = 0
		BE.reclaim_mats *= 2
		BE.name = "Weakened " + BE.name
		BE.altered = 1

/datum/dna_chromosome/stealth
	name = "Camouflager"
	desc = "Enables a gene to be added to a subject without them noticing immediately."

	check_apply(datum/bioEffect/BE)
		if(!istype(BE))
			return "Invalid gene."
		if(BE.altered)
			return "This gene has already been altered."
		return null

	apply(datum/bioEffect/BE)
		. = src.check_apply(BE)
		if (.)
			return

		BE.msgGain = ""
		BE.msgLose = ""
		BE.name = "Camouflaged " + BE.name
		BE.altered = 1

// Powers

/datum/dna_chromosome/power_enhancer
	name = "Power Booster"
	desc = "Makes abilities granted by genes more powerful."

	check_apply(datum/bioEffect/BE)
		if(!istype(BE))
			return "Invalid Gene."
		if(BE.altered)
			return "This gene has already been altered."
		return null

	apply(datum/bioEffect/power/BE)
		. = src.check_apply(BE)
		if (.)
			return
		var/oldpower = BE.power
		BE.power = 2
		BE.name = "Empowered " + BE.name
		BE.altered = 1
		BE.onPowerChange(oldpower, BE.power)

/datum/dna_chromosome/cooldown_reducer
	name = "Energy Booster"
	desc = "Allows abilities granted by genes to be used more often."

	check_apply(datum/bioEffect/power/BE)
		if(!istype(BE))
			return "This chromosome can only be applied to power-granting genes."
		if(BE.altered)
			return "This gene has already been altered."
		if(!BE.cooldown)
			return "This chromosome cannot be applied to this power gene."
		return null

	apply(datum/bioEffect/power/BE)
		. = src.check_apply(BE)
		if (.)
			return

		if(BE.cooldown != 0)
			BE.cooldown /= 2
		BE.name = "Energized " + BE.name
		BE.altered = 1

/datum/dna_chromosome/safety
	name = "Synchronizer"
	desc = "Allows dangerous abilities to be used without harm to the user."

	check_apply(datum/bioEffect/power/BE)
		if(!istype(BE))
			return "This chromosome can only be applied to power-granting genes."
		if(BE.altered)
			return "This gene has already been altered."
		if(BE.safety)
			return "This chromosome cannot be applied to this power gene."
		return null

	apply(datum/bioEffect/power/BE)
		. = src.check_apply(BE)
		if (.)
			return

		BE.safety = 1
		BE.name = "Synchronized " + BE.name
		BE.altered = 1
