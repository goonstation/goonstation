/datum/lifeprocess/robot_locks
	process(var/datum/gas_mixture/environment)
		if(robot_owner?.weapon_lock)
			robot_owner.uneq_slot(1)
			robot_owner.uneq_slot(2)
			robot_owner.uneq_slot(3)
			robot_owner.weaponlock_time -= get_multiplier()
			if(robot_owner.weaponlock_time <= 0)
				if(robot_owner.client) boutput(robot_owner, "<span class='alert'><B>Weapon Lock Timed Out!</B></span>")
				robot_owner.weapon_lock = 0
				robot_owner.weaponlock_time = 120
		..()
