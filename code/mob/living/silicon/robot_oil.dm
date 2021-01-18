/datum/lifeprocess/robot_oil
	process(var/datum/gas_mixture/environment)
		if(robot_owner)
			if(robot_owner.oil > 0)
				robot_owner.oil -= get_multiplier()
				if (robot_owner.oil <= 0)
					robot_owner.oil = 0
					robot_owner.remove_stun_resist_mod("robot_oil", 25)
					REMOVE_MOVEMENT_MODIFIER(robot_owner, /datum/movement_modifier/robot_oil, "oil")
		..()
