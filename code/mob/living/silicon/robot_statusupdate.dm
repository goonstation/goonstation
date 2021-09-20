/datum/lifeprocess/robot_statusupdate
	process(var/datum/gas_mixture/environment)
		if(!robot_owner.part_chest)
			// this doesn't even make any sense unless you're rayman or some shit
			robot_owner.death()

		else if (!robot_owner.part_head)
			robot_owner.death()
