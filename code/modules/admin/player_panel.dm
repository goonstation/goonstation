/// Admin Player Panel
/datum/player_panel

/datum/player_panel/ui_state(mob/user)
	return tgui_admin_state.can_use_topic(src, user)

/datum/player_panel/ui_status(mob/user)
	return tgui_admin_state.can_use_topic(src, user)

/datum/player_panel/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "PlayerPanel")
		ui.open()

/datum/player_panel/ui_data(mob/user)
	var/list/players = list()
	for (var/mob/M in mobs)
		if (M.ckey)
			var/area/A = get_area(M)
			players[M.ckey] = list(
				"mobRef" = "\ref[M]",
				"ckey" = M.ckey,
				"name" = M.name ? M.name : "N/A",
				"realName" = M.real_name ? M.real_name : "N/A",
				"assignedRole" = M.mind?.assigned_role ? M.mind.assigned_role : "N/A",
				"specialRole" = M.mind?.special_role ? M.mind.special_role : "N/A",
				"playerType" = M.type,
				"computerId" = M.computer_id ? M.computer_id : "N/A",
				"ip" = M.lastKnownIP ? M.lastKnownIP : "N/A",
				"joined" = M.client?.joined_date ? M.client.joined_date : "N/A",
				"playerLocation" = A?.name ? A.name : "N/A",
				"ping" = M.client?.chatOutput?.last_ping || -1,
			)
	. = list(
		"players" = players
	)

/datum/player_panel/ui_act(action, params)
	. = ..()
	if (.)
		return

	switch(action)
		if("open-player-options")
			if(!usr.client) return
			var/mobRef = params["mobRef"]
			var/mob/M = locate(mobRef)
			if(ismob(M) && M.ckey == params["ckey"])
				usr.client.holder.playeropt(M)
			else //mob ref was no good
				for(M in mobs)
					if(M.ckey == params["ckey"])
						usr.client.holder.playeropt(M)
						break

		if("private-message-player")
			if(!usr.client) return
			var/mobRef = params["mobRef"]
			var/mob/M = locate(mobRef)
			if(ismob(M) && M.ckey == params["ckey"])
				do_admin_pm(M.ckey, usr)
			else
				for(M in mobs)
					if(M.ckey == params["ckey"])
						do_admin_pm(M.ckey, usr)
						break

		if("jump-to-player-loc")
			if(!usr.client) return
			var/mobRef = params["mobRef"]
			var/mob/M = locate(mobRef)
			if(ismob(M) && M.ckey == params["ckey"])
				usr.client.jumptomob(M)
			else
				for(M in mobs)
					if(M.ckey == params["ckey"])
						usr.client.jumptomob(M)
						break
