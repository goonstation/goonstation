/datum/lifeprocess/hivebot_statusupdate
	process()
		hivebot_owner.hud.update_charge()
		hivebot_owner.health = hivebot_owner.max_health - (hivebot_owner.fireloss + hivebot_owner.bruteloss)
		return ..()
