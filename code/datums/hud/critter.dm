/// Highly modular HUD for critters.
/datum/hud/critter
	var/list/hands = list()
	var/list/equipment = list()
	var/obj/screen/hud/health
	var/obj/screen/hud/oxygen
	var/obj/screen/hud/fire
	var/obj/screen/hud/intent
	var/obj/screen/hud/mintent
	var/obj/screen/hud/throwing
	var/obj/screen/hud/pulling
	var/obj/screen/hud/resist
	var/obj/screen/hud/

	var/obj/screen/hud
		stamina
		stamina_back
		bodytemp
		toxin
		rad
		bleeding
		resting

	var/mob/living/critter/master
	var/icon/icon_hud = 'icons/mob/hud_human.dmi'
	var/list/statusUiElements = list() //Assoc. List  STATUS EFFECT INSTANCE : UI ELEMENT add_screen(obj/screen/S). Used to hold the ui elements since they shouldnt be on the status effects themselves.

	var/nr = 0
	var/nl = 0
	var/rl = 0
	var/rr = 0
	var/tre = 0

	New(M)
		..()
		master = M

		var/hand_s = -round((master.hands.len - 1) / 2)
		nl = hand_s - 1
		for (var/i = 1, i <= master.hands.len, i++)
			var/curr = hand_s + i - 1
			var/datum/handHolder/HH = master.hands[i]
			var/SL = "CENTER[curr < 0 ? curr : (curr > 0 ? "+[curr]" : null)],SOUTH"
			var/obj/screen/hud/H = create_screen("hand[i]", HH.name, HH.icon, "[HH.icon_state][i == master.active_hand ? 1 : 0]", SL, HUD_LAYER+1)
			HH.screenObj = H
			hands += H
		nr = hand_s + master.hands.len
		health = create_screen("health", "health", src.icon_hud, "health0", "EAST[next_topright()],NORTH", HUD_LAYER+1)

		if (master.use_stamina)
			var/stamloc = "EAST-1, NORTH"
			stamina = create_screen("stamina","Stamina", src.icon_hud, "stamina", stamloc, HUD_LAYER, tooltipTheme = "stamina")
			stamina_back = create_screen("stamina_back","Stamina", src.icon_hud, "stamina_back", stamloc, HUD_LAYER-2)
			if (master.stamina_bar)
				stamina.desc = master.stamina_bar.getDesc(master)

		bodytemp = create_screen("bodytemp","Temperature", src.icon_hud, "temp0", "EAST[next_topright()], NORTH", HUD_LAYER, tooltipTheme = "tempInd tempInd0")
		bodytemp.desc = "The temperature feels fine."

		if (master.get_health_holder("oxy"))
			oxygen = create_screen("oxygen", "Suffocation Warning", src.icon_hud, "oxy0", "EAST[next_topright()], NORTH", HUD_LAYER)

			fire = create_screen("fire","Fire Warning", src.icon_hud, "fire0", "EAST[next_topright()], NORTH", HUD_LAYER)

			toxin = create_screen("toxin","Toxic Warning",src.icon_hud, "toxin0", "EAST[next_topright()], NORTH", HUD_LAYER, tooltipTheme = "statusToxin")
			toxin.desc = "This indicator warns that you are poisoned. You will take toxic damage until the situation is remedied."

			rad = create_screen("rad","Radiation Warning", src.icon_hud, "rad0", "EAST[next_topright()], NORTH", HUD_LAYER, tooltipTheme = "statusRad")
			rad.desc = "This indicator warns that you are irradiated. You will take toxic and burn damage until the situation is remedied."

		if (master.can_bleed)
			bleeding = create_screen("bleeding","Bleed Warning", src.icon_hud, "blood0", "EAST[next_topright()], NORTH", HUD_LAYER, tooltipTheme = "healthDam healthDam0")
			bleeding.desc = "This indicator warns that you are currently bleeding. You will die if the situation is not remedied."

		if (master.can_throw)
			throwing = create_screen("throw", "throw mode", src.icon_hud, "throw0", "CENTER+[nr], SOUTH", HUD_LAYER+1)
			nr++

		intent = create_screen("intent", "action intent", src.icon_hud, "intent-help", "CENTER+[nr],SOUTH", HUD_LAYER+1)
		nr++
		pulling = create_screen("pull", "pulling", 'icons/mob/critter_ui.dmi', "pull0", "CENTER+[nr], SOUTH", HUD_LAYER+1)
		mintent = create_screen("mintent", "movement mode", 'icons/mob/critter_ui.dmi', "move-run", "CENTER+[nr], SOUTH", HUD_LAYER+1)
		nr++
		resist = create_screen("resist", "resist", 'icons/mob/critter_ui.dmi', "resist_critter", "CENTER+[nr], SOUTH", HUD_LAYER+1)
		resting = create_screen("rest", "resting", src.icon_hud, "rest0", "CENTER+[nr], SOUTH+0.5", HUD_LAYER+1)
		nr++


		for (var/i = 1, i <= master.equipment.len, i++)
			var/datum/equipmentHolder/EH = master.equipment[i]
			var/SL = loc_left()
			var/obj/screen/hud/H = create_screen("equipment[i]", EH.name, EH.icon, EH.icon_state, SL, HUD_LAYER+1)
			EH.screenObj = H
			equipment += EH
			if (EH.item)
				add_object(EH.item)

	clear_master()
		master = null
		..()

	proc/loc_left()
		if (nl < -6)
			rl++
			nl = rr < rl ? 0 : -1
		var/e = nl
		nl--
		var/col = "CENTER[e < 0 ? e : (e > 0 ? "+[e]" : null)]"
		var/row = "SOUTH[rl > 0 ? "+[rl]" : null]"
		return "[col],[row]"

	proc/loc_right()
		if (nr > 6)
			rr++
			nr = rl < rr ? 0 : 1
		var/e = nr
		nr++
		var/col = "CENTER[e < 0 ? e : (e > 0 ? "+[e]" : null)]"
		var/row = "SOUTH[rr > 0 ? "+[rr]" : null]"
		return "[col],[row]"

	proc/next_right()
		nr += 1
		return "+[nr - 1]"

	proc/next_left()
		nl -= 1
		return nl + 1

	proc/next_topright()
		tre -= 1
		return tre + 1 == 0 ? "" : tre

	proc/set_suffocating(var/status)
		if (!oxygen)
			return
		oxygen.icon_state = "oxy[status]"

	proc/set_breathing_fire(var/status)
		if (!fire)
			return
		fire.icon_state = "fire[status]"

	proc/update_hands()
		for (var/i = 1, i <= master.hands.len, i++)
			var/datum/handHolder/HH = master.hands[i]
			var/obj/screen/hud/H = HH.screenObj
			if (master.active_hand == i)
				H.icon_state = "[HH.icon_state]1"
			else
				H.icon_state = "[HH.icon_state]0"

	proc/update_throwing()
		if (!master.can_throw || !throwing)
			return
		throwing.icon_state = "throw[master.in_throw_mode]"

	clicked(id, mob/user, list/params)
		if (copytext(id, 1, 5) == "hand")
			var/handid = text2num(copytext(id, 5))
			master.active_hand = handid
			master.hand = handid
			update_hands()
		else if (copytext(id, 1, 10) == "equipment")
			var/eid = text2num(copytext(id, 10))
			master.equip_click(master.equipment[eid])
		else
			switch(id)
				if ("oxygen")
					boutput(master, "<span class='alert'>This indicator warns that you are currently suffocating. You will take oxygen damage until the situation is remedied.</span>")

				if ("intent")
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

				if ("mintent")
					if (master.m_intent == "run")
						master.m_intent = "walk"
					else
						master.m_intent = "run"
					out(master, "You are now [master.m_intent == "walk" ? "walking" : "running"]")
					src.update_mintent()

				if ("pull")
					if (master.pulling)
						unpull_particle(master,pulling)
					master.pulling = null
					src.update_pulling()

				if ("throw")
					var/icon_y = text2num(params["icon-y"])
					if (icon_y > 16 || master.in_throw_mode)
						master.toggle_throw_mode()
					else
						master.drop_item()
				if ("resist")
					master.resist()
				if ("health")
					boutput(master, "<span class='notice'>Your health: [master.health]/[master.max_health]</span>")
				if ("rest")
					if(ON_COOLDOWN(src.master, "toggle_rest", REST_TOGGLE_COOLDOWN)) return
					if(master.ai_active && !master.hasStatus("resting"))
						master.show_text("You feel too restless to do that!", "red")
					else
						master.hasStatus("resting") ? master.delStatus("resting") : master.setStatus("resting", INFINITE_STATUS)
						master.force_laydown_standup()
					src.update_resting()

	proc/update_health()
		if (!isdead(master))
			if (!health) //Runtime fix: Cannot modify null.icon_state
				return
			var/h_ratio = master.health / master.max_health * 100
			switch(h_ratio)
				if(90 to INFINITY)
					health.icon_state = "health0" // green with green marker
				if(75 to 90)
					health.icon_state = "health1" // green
				if(60 to 75)
					health.icon_state = "health2" // yellow
				if(45 to 60)
					health.icon_state = "health3" // orange
				if(20 to 45)
					health.icon_state = "health4" // dark orange
				if(10 to 20)
					health.icon_state = "health5" // red
				else
					health.icon_state = "health6" // crit
		else
			health.icon_state = "health7"         // dead

	proc/update_intent()
		intent.icon_state = "intent-[master.a_intent]"

	proc/update_mintent()
		if (!mintent) return 0
		mintent.icon_state = "move-[master.m_intent]"

	proc/update_pulling()
		if (!pulling) return 0
		pulling.icon_state = "pull[!!master.pulling]"

	proc/update_status_effects()
		for(var/obj/screen/statusEffect/G in src.objects)
			remove_screen(G)

		for(var/datum/statusEffect/S in src.statusUiElements) //Remove stray effects.
			if(!master.statusEffects || !(S in master.statusEffects))
				pool(statusUiElements[S])
				src.statusUiElements.Remove(S)
				qdel(S)

		var/spacing = 0.6
		var/pos_x = spacing - 0.2 - 1

		if(master.statusEffects)
			for(var/datum/statusEffect/S in master.statusEffects) //Add new ones, update old ones.
				if(!S.visible) continue
				if((S in statusUiElements) && statusUiElements[S])
					var/obj/screen/statusEffect/U = statusUiElements[S]
					U.icon = icon_hud
					U.screen_loc = "EAST[pos_x < 0 ? "":"+"][pos_x],NORTH-0.7"
					U.update_value()
					add_screen(U)
					pos_x -= spacing
				else
					if(S.visible)
						var/obj/screen/statusEffect/U = new/obj/screen/statusEffect(master, S)
						U.init(master,S)
						U.icon = icon_hud
						statusUiElements.Add(S)
						statusUiElements[S] = U
						U.screen_loc = "EAST[pos_x < 0 ? "":"+"][pos_x],NORTH-0.7"
						U.update_value()
						add_screen(U)
						pos_x -= spacing
						animate_buff_in(U)
		return
//HUMAN COPOY PASTE
	proc/set_sprint(var/on)
		if(stamina)
			stamina.icon_state = on ? "stamina_sprint" : "stamina"

	proc/update_blood_indicator()
		if (!bleeding || isdead(master))
			bleeding.icon_state = "blood0"
			bleeding.tooltipTheme = "healthDam healthDam0"
			return

		var/state = 0
		var/theme = 0
		switch (master.bleeding)
			if (-INFINITY to 0)
				state = 0 // blank
				theme = 0
			if (1 to 2)
				state = 1
				theme = 3
			if (3 to 4)
				state = 2
				theme = 4
			if (5 to INFINITY)
				state = 3
				theme = 6
/*			if (-INFINITY to 0)
				state = 0 // blank
				theme = 0
			if (1 to 3)
				state = 1
				theme = 3
			if (4 to 6)
				state = 2
				theme = 4
			if (7 to INFINITY)
				state = 3
				theme = 6
*/
		bleeding.icon_state = "blood[state]"
		bleeding.tooltipTheme = "healthDam healthDam[theme]"

	proc/update_temp_indicator()
		if (!bodytemp)
			return
		if(master.getStatusDuration("burning") && !master.is_heat_resistant())
			bodytemp.icon_state = "tempF" // on fire
			bodytemp.tooltipTheme = "tempInd tempIndF"
			bodytemp.desc = "OH FUCK FIRE FIRE FIRE OH GOD FIRE AAAAAAA"
			return

		var/dev = master.get_temp_deviation()
		var/state
		switch(dev)
			if(4)
				state = 4 // burning up
				bodytemp.desc = "It's scorching hot!"
			if(3)
				state = 3 // far too hot
				bodytemp.desc = "It's too hot."
			if(2)
				state = 2 // too hot
				bodytemp.desc = "It's a bit warm, but nothing to worry about."
			if(1)
				state = 1 // warm but safe
				bodytemp.desc = "It feels a little warm."
			if(-1)
				state = -1 // cool but safe
				bodytemp.desc = "It feels a little cool."
			if(-2)
				state = -2 // too cold
				bodytemp.desc = "It's a little cold, but nothing to worry about."
			if(-3)
				state = -3 // far too cold
				bodytemp.desc = "It's too cold."
			if(-4)
				state = -4 // freezing
				bodytemp.desc = "It's absolutely freezing!"
			else
				state = 0 // 310 is optimal body temp
				bodytemp.desc = "The temperature feels fine."

		bodytemp.icon_state = "temp[state]"
		bodytemp.tooltipTheme = "tempInd tempInd[state]"

	proc/update_tox_indicator(var/status)
		if (!toxin)
			return
		toxin.icon_state = "tox[status]"

	proc/update_rad_indicator(var/status)
		if (!rad) // not rad :'(
			return
		rad.icon_state = "rad[status]"

	proc/update_resting()
		if (!resting) return 0
		resting.icon_state = "rest[master.hasStatus("resting") ? 1 : 0]"


/mob/living/critter/updateStatusUi()
	if(src.hud && istype(src.hud, /datum/hud/critter))
		var/datum/hud/critter/H = src.hud
		H.update_status_effects()
	return
