/datum/lifeprocess/robot_statusupdate
	process(var/datum/gas_mixture/environment)
		if (isdead(robot_owner)) //Ideally, this will never be needed. Still, better safe than sorry.
			robot_owner.collapse_to_pieces()
			return
		if(!robot_owner.part_chest)
			// this doesn't even make any sense unless you're rayman or some shit
			robot_owner.collapse_to_pieces()

		else if (!robot_owner.part_head)
			robot_owner.collapse_to_pieces()
