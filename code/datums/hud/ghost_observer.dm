/datum/hud/ghost_observer
	var/mob/dead/observer/master
	var/atom/movable/screen/respawn_timer/respawn_timer

	New(I)
		master = I
		..()
		update_ability_hotbar()

	clear_master()
		master = null
		..()

	proc/get_respawn_timer()
		RETURN_TYPE(/atom/movable/screen/respawn_timer)
		if(isnull(src.respawn_timer))
			src.respawn_timer = new
			src.add_object(src.respawn_timer)
		return src.respawn_timer

	proc/update_ability_hotbar()
		if (!master.client)
			return

		for(var/obj/ability_button/B in master.client.screen)
			master.client.screen -= B

		if (master.abilityHolder) //abilities come first. no overlap from the upcoming buttons!
			master.abilityHolder.updateButtons()
