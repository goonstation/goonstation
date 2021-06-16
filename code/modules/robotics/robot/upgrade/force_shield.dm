/obj/item/roboupgrade/physshield
	name = "cyborg force shield upgrade"
	desc = "A force field generator that protects a cyborg from physical harm."
	icon_state = "up-Pshield"
	drainrate = 250
	borg_overlay = "up-pshield"
	var/overheat_level = 0
	var/max_overheat = 5

	//TODO: Convert this to a status on the cyborg with a switch(overheat_level) on icon state so they can see when they're overheating
	// It'd work a lot better but fuuuuuuuuuuuuuuck I wanna be done looking at cyborg code, jesus

	proc/overheat()
		SPAWN_DBG(COMBAT_CLICK_DELAY * 2)
			overheat_level--
			overheat_level = max(0,overheat_level)
		overheat_level++
		return min(max_overheat,overheat_level)
