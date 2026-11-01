/datum/element/lifeprocess/robot
	target_type = /mob/living/silicon/robot

/datum/element/lifeprocess/robot/process(mob/living/silicon/robot/target, mult, datum/gas_mixture/environment)
	if (!target.part_chest || !target.part_head)
		target.death()
		return

	if (target.stuttering)
		target.stuttering = max(target.stuttering - (0.33 * mult), 0)

	if (target.druggy)
		target.druggy = max(target.druggy - mult, 0)

	if (target.weapon_lock)
		target.uneq_slot(1)
		target.uneq_slot(2)
		target.uneq_slot(3)

		target.weaponlock_time -= mult
		if (target.weaponlock_time <= 0)
			boutput(target, SPAN_ALERT("<b>Weapon Lock Timed Out!</b>"))
			target.weapon_lock = 0
			target.weaponlock_time = 120
