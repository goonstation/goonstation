/datum/lifeprocess/robot_statusupdate
	process(var/datum/gas_mixture/environment)

		var/mult = get_multiplier()

		if(!robot_owner.part_chest)
			// this doesn't even make any sense unless you're rayman or some shit
			robot_owner.death()

		else if (!robot_owner.part_head)
			robot_owner.death()

		if (owner.stuttering)
			owner.stuttering = max(owner.stuttering - 0.33*mult, 0) // for some reason this makes borg stammer go away way faster than human stammer without the 0.33* despite being otherwise identical
