/datum/hud/ghost_observer
	var/mob/dead/observer/master

	New(I)
		master = I
		..()
		update_ability_hotbar()

	clear_master()
		master = null
		..()

	proc/update_ability_hotbar()
		if (!master.client)
			return

		for(var/obj/ability_button/B in master.client.screen)
			master.client.screen -= B

		if (master.abilityHolder) //abilities come first. no overlap from the upcoming buttons!
			master.abilityHolder.updateButtons()
