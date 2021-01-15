/datum/lifeprocess/robot_oil
	//moved from robot.dm proc/process_oil to this life process
	process(var/datum/gas_mixture/environment)
		if(robot_owner)
			var/mult = get_multiplier()
			robot_owner.oil -= 1*mult
			if (robot_owner.oil <= 0)
				robot_owner.oil = 0
				robot_owner.remove_stun_resist_mod("robot_oil", 25)
				REMOVE_MOVEMENT_MODIFIER(robot_owner, /datum/movement_modifier/robot_oil, "oil")
	..()
