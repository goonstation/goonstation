/datum/element/lifeprocess/hivebot
	target_type = /mob/living/silicon/hivebot

/datum/element/lifeprocess/hivebot/process(mob/living/silicon/hivebot/target, datum/gas_mixture/environment)
	target.hud.update_charge()
	target.health = target.max_health - (target.fireloss + target.bruteloss)

	if (target?.mainframe)
		if ((target.z == target.mainframe?.z) || (inunrestrictedz(target) && inonstationz(target.mainframe)))
			target.delStatus("low_signal")
		else
			target.setStatus("low_signal", INFINITE_STATUS)
