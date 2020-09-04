/datum/hud/object
	var/mob/living/object/master
	var/obj/screen/intent

	New(M)
		..()
		master = M
		var/obj/screen/S = create_screen("release", "release", 'icons/mob/screen1.dmi', "x", "NORTH,EAST", HUD_LAYER)
		S.underlays += "block"
		intent = create_screen("intent", "action intent", 'icons/mob/hud_human.dmi', "intent-help", "SOUTH,EAST-2", HUD_LAYER)

	clear_master()
		master = null
		..()

	clicked(id, mob/user, list/params)
		if (id == "release")
			if (master)
				master.death(0)
		else if (id == "intent") // copy n pasted but fuck it for now
			var/icon_x = text2num(params["icon-x"])
			var/icon_y = text2num(params["icon-y"])
			if (icon_x > 16)
				if (icon_y > 16)
					master.a_intent = INTENT_DISARM
				else
					master.a_intent = INTENT_HARM
			else
				if (icon_y > 16)
					master.a_intent = INTENT_HELP
				else
					master.a_intent = INTENT_GRAB
			src.update_intent()

	proc/update_intent()
		intent.icon_state = "intent-[master.a_intent]"
