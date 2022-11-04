/datum/hud/ghost_observer
	var/mob/dead/observer/master
	var/atom/movable/screen/respawn_timer/respawn_timer
	var/atom/movable/screen/join_other/join_other

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

	proc/get_join_other()
		RETURN_TYPE(/atom/movable/screen/join_other)
		if(src.master.client?.holder && !src.master.client?.player_mode)
			return
		var/datum/game_server/buddy = global.game_servers.get_buddy()
		if(isnull(buddy))
			return null
		if(!buddy.ghost_notif_target)
			return null
		if(isnull(src.join_other))
			src.join_other = new(null, buddy.id, buddy.name)
			src.add_object(src.join_other)
		return src.join_other

	proc/update_ability_hotbar()
		if (!master.client)
			return

		for(var/obj/ability_button/B in master.client.screen)
			master.client.screen -= B

		for(var/atom/movable/screen/ability/B in master.client.screen)
			master.client.screen -= B

		if (master.abilityHolder) //abilities come first. no overlap from the upcoming buttons!
			master.abilityHolder.updateButtons()
