/datum/lifeprocess/robot_oil
	process(var/datum/gas_mixture/environment)
		if(robot_owner)
			if(robot_owner.oil > 0)
				robot_owner.oil -= get_multiplier()
				if (robot_owner.oil <= 0)
					robot_owner.oil = 0
					REMOVE_ATOM_PROPERTY(robot_owner, PROP_MOB_STUN_RESIST, "robot_oil")
					REMOVE_ATOM_PROPERTY(robot_owner, PROP_MOB_STUN_RESIST_MAX, "robot_oil")
					REMOVE_MOVEMENT_MODIFIER(robot_owner, /datum/movement_modifier/robot_oil, "oil")
		..()
