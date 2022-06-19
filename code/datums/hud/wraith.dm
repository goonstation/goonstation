/datum/hud/wraith
	var/mob/wraith/master
	var/atom/movable/screen/intent
	var/atom/movable/screen/health

	New(M)
		..()
		master = M
		health = create_screen("health","Health", 'icons/mob/wraith_ui.dmi', "health-7", "EAST, NORTH", HUD_LAYER, tooltipTheme = "healthDam healthDam0")
		health.desc = "You feel powerful."
		// var/atom/movable/screen/S = create_screen("release", "release", 'icons/mob/screen1.dmi', "x", "NORTH,EAST", HUD_LAYER)
		// S.underlays += "block"
		// intent = create_screen("intent", "action intent", 'icons/mob/hud_human.dmi', "intent-help", "SOUTH,EAST-2", HUD_LAYER)

	clear_master()
		master = null
		..()

	relay_click(id, mob/user, list/params)
		if (id == "release")
			if (master)
				master.death(FALSE)
		else if (id == "intent") // copy n pasted but fuck it for now
			var/icon_x = text2num(params["icon-x"])
			var/icon_y = text2num(params["icon-y"])
			if (icon_x > 16)
				if (icon_y > 16)
					master.set_a_intent(INTENT_DISARM)
				else
					master.set_a_intent(INTENT_HARM)
			else
				if (icon_y > 16)
					master.set_a_intent(INTENT_HELP)
				else
					master.set_a_intent(INTENT_GRAB)
			src.update_intent()

	proc/update_intent()
		intent.icon_state = "intent-[master.a_intent]"

	proc/update_health()
		var/health_num = round((max(master.health,0)/master.max_health)*7)
		health.icon_state = "health-[health_num]"				//there's 8 icons, that's where 0-7 comes from
		switch(health_num)
			if (0)
				health.desc = "You feel nothing."
			if (1)
				health.desc = "You feel like a shadow."
			if (2)
				health.desc = "You feel pale."
			if (3)
				health.desc = "You feel thin."
			if (4)
				health.desc = "You feel neutral."
			if (5)
				health.desc = "You feel capable."
			if (6)
				health.desc = "You feel strong."
			if (7)
				health.desc = "You feel powerful."
