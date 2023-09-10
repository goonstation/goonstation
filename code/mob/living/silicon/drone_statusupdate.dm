/datum/lifeprocess/robot_statusupdate
	process(var/datum/gas_mixture/environment)

		var/mult = get_multiplier()

		if (owner.stuttering)
			owner.stuttering = max(owner.stuttering - 0.33*mult, 0) // for some reason this makes borg stammer go away way faster than human stammer without the 0.33* despite being otherwise identical

		if (owner.druggy)
			owner.druggy = max(owner.druggy-mult, 0)
