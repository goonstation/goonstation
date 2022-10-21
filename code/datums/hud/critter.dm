/// Highly modular HUD for critters.
/datum/hud/critter
	/// list of holders of hand hud elements
	var/list/hands = list()
	/// list of equipment hud elements
	var/list/equipment = list()
	/// health hud element
	var/atom/movable/screen/hud/health = null
	/// oxygen hud element
	var/atom/movable/screen/hud/oxygen = null
	/// fire hud element
	var/atom/movable/screen/hud/fire = null
	/// attack intent hud element
	var/atom/movable/screen/hud/intent = null
	/// movement intent hud element
	var/atom/movable/screen/hud/mintent = null
	/// throwing hud element
	var/atom/movable/screen/hud/throwing = null
	/// pulling hud element
	var/atom/movable/screen/hud/pulling = null
	/// resist hud element
	var/atom/movable/screen/hud/resist = null
	/// stamina hud element
	var/atom/movable/screen/hud/stamina = null
	/// backdrop of stamina hud element
	var/atom/movable/screen/hud/stamina_back = null
	/// temperature hud element
	var/atom/movable/screen/hud/bodytemp = null
	/// toxic gas hud element
	var/atom/movable/screen/hud/toxin = null
	/// radiation hud element
	var/atom/movable/screen/hud/rad = null
	/// bleeding hud element
	var/atom/movable/screen/hud/bleeding = null
	/// resting hud element
	var/atom/movable/screen/hud/resting = null

	/// hud owner mob
	var/mob/living/critter/master = null

	/// hud icons to use
	var/icon/hud_icon = 'icons/mob/hud_human.dmi'

	/// Assoc. List  STATUS EFFECT INSTANCE : UI ELEMENT add_screen(atom/movable/screen/S). Used to hold the ui elements since they shouldnt be on the status effects themselves.
	var/list/statusUiElements = list()

	/// offset for a screen location to the right
	var/right_offset = 0
	/// offset for a screen location to the left
	var/left_offset = 0
	/// offset for a screen location in the top right (generally where health and status icons go)
	var/top_right_offset = 0

	/// status effect left offset
	var/wraparound_offset_left = 0
	/// status effect right offset
	var/wraparound_offset_right = 0

/datum/hud/critter/New(M)
	..()
	src.master = M

	// element load order determines position in the hud
	src.create_hand_element()
	src.create_health_element()
	src.create_stamina_element()
	src.create_temperature_element()

	// these elements rely on being able to breathe
	if (src.master.get_health_holder("oxy"))
		src.create_oxygen_element()
		src.create_fire_element()
		src.create_toxin_element()

	src.create_radiation_element()

	if (src.master.can_bleed)
		src.create_bleeding_element()

	if (src.master.can_throw)
		src.create_throwing_element()

	src.create_intent_element()
	src.create_pulling_element()
	src.create_mintent_element()
	src.create_rest_element()
	src.create_resist_element()
	src.create_equipment_element()


/// clears owner mob
/datum/hud/critter/clear_master()
	src.master = null
	..()

/// gets the leftmost screen loc
/datum/hud/critter/proc/loc_left()
	if (src.left_offset < -9) // wraps vertically if the magnitude of left offset is greater than 6
		src.wraparound_offset_left++

	var/next_left_offset = src.next_left()
	var/x_offset = 0
	var/y_offset = 0

	if (next_left_offset < 0)
		x_offset = next_left_offset + src.wraparound_offset_left
	else if (next_left_offset > 0)
		x_offset = "+[next_left_offset + src.wraparound_offset_left]"
	else
		x_offset = ""

	if (src.wraparound_offset_left > 0)
		y_offset = "+[src.wraparound_offset_left]"
	else
		y_offset = ""

	return "CENTER[x_offset], SOUTH[y_offset]"

/// gets the rightmost screen loc
/datum/hud/critter/proc/loc_right()
	if (src.right_offset > 9) // wraps vertically if the magnitude of right offset is greater than 6
		src.wraparound_offset_right++

	var/next_right_offset = src.next_right()
	var/x_offset = 0
	var/y_offset = 0

	if (next_right_offset < 0)
		x_offset = next_right_offset - src.wraparound_offset_right
	else if (next_right_offset > 0)
		x_offset = "+[next_right_offset - src.wraparound_offset_right]"
	else
		x_offset = ""

	if (src.wraparound_offset_right > 0)
		y_offset = "+[src.wraparound_offset_right]"
	else
		y_offset = ""

	return "CENTER[x_offset], SOUTH[y_offset]"

/// gives an offset for the next right screen element, and then increases the magnitude of the next offset
/datum/hud/critter/proc/next_right()
	. = "+[src.right_offset]"
	src.right_offset++

/// gives an offset for the next left screen element, and then increases the magnitude of the next offset
/datum/hud/critter/proc/next_left()
	. = src.left_offset
	src.left_offset--

/// gives an offset for the next top-right screen element, and then increases the magnitude of the next offset
/datum/hud/critter/proc/next_topright()
	if (!src.top_right_offset)
		. = ""
	else
		. = src.top_right_offset
	src.top_right_offset--

/// returns the right offset correctly formatted for a screen loc
/datum/hud/critter/proc/get_right()
	return "+[src.right_offset]"

/// returns the left offset correctly formatted for a screen loc
/datum/hud/critter/proc/get_left()
	return "-[src.left_offset]"

/// sets the suffocation icon on the hud to show suffocation status
/datum/hud/critter/proc/set_suffocating(var/status)
	if (!src.oxygen)
		return
	src.oxygen.icon_state = "oxy[status]"

/// sets the breathing fire icon on the hud to show breathing fire status
/datum/hud/critter/proc/set_breathing_fire(var/status)
	if (!src.fire)
		return
	src.fire.icon_state = "fire[status]"

/// updates the hand icon(s) to reflect which hand is active
/datum/hud/critter/proc/update_hands()
	for (var/i = 1, i <= src.master.hands.len, i++)
		var/datum/handHolder/handHolder = src.master.hands[i]
		var/atom/movable/screen/hud/hand_element = handHolder.screenObj
		if (src.master.active_hand == i)
			hand_element.icon_state = "[handHolder.icon_state]1"
		else
			hand_element.icon_state = "[handHolder.icon_state]0"

/// updates the throwing icon to show whether or not throwing is active
/datum/hud/critter/proc/update_throwing()
	if (!src.master.can_throw || !src.throwing)
		return
	src.throwing.icon_state = "throw[src.master.in_throw_mode]"

/// recieves clicks from the screen hud objects
/datum/hud/critter/relay_click(id, mob/user, list/params)
	if (copytext(id, 1, 5) == "hand")
		var/handid = text2num(copytext(id, 5))
		src.master.active_hand = handid
		src.master.hand = handid
		src.update_hands()

	else if (copytext(id, 1, 10) == "equipment")
		var/equipment_id = text2num(copytext(id, 10))
		src.master.equip_click(src.master.equipment[equipment_id])
	else
		switch(id)
			if ("oxygen")
				boutput(src.master, "<span class='alert'>This indicator warns that you are currently suffocating.\
				You will take oxygen damage until the situation is remedied.</span>")

			if ("intent")
				var/icon_x = text2num(params["icon-x"])
				var/icon_y = text2num(params["icon-y"])
				if (icon_x > 16)
					if (icon_y > 16)
						src.master.set_a_intent(INTENT_DISARM)
					else
						src.master.set_a_intent(INTENT_HARM)
				else
					if (icon_y > 16)
						src.master.set_a_intent(INTENT_HELP)
					else
						src.master.set_a_intent(INTENT_GRAB)
				src.update_intent()

			if ("mintent")
				if (src.master.m_intent == "run")
					src.master.m_intent = "walk"
				else
					src.master.m_intent = "run"
				out(src.master, "You are now [src.master.m_intent == "walk" ? "walking" : "running"]")
				src.update_mintent()

			if ("pull")
				if (master.pulling)
					unpull_particle(master,pulling)
					master.remove_pulling()
					src.update_pulling()
				else if(!isturf(master.loc))
					boutput(master, "<span class='notice'>You can't pull things while inside \a [master.loc].</span>")
				else
					var/list/atom/movable/pullable = list()
					for(var/atom/movable/AM in range(1, get_turf(master)))
						if(AM.anchored || !AM.mouse_opacity || AM.invisibility > master.see_invisible || AM == master)
							continue
						pullable += AM
					var/atom/movable/to_pull = null
					if(length(pullable) == 1)
						to_pull = pullable[1]
					else if(length(pullable) < 1)
						boutput(master, "<span class='notice'>There is nothing to pull.</span>")
					else
						to_pull = tgui_input_list(master, "Which do you want to pull? You can also Ctrl+Click on things to pull them.", "Which thing to pull?", pullable)
					if(!isnull(to_pull) && BOUNDS_DIST(master, to_pull) == 0)
						to_pull.pull(master)

			if ("throw")
				var/icon_y = text2num(params["icon-y"])
				if (icon_y > 16 || src.master.in_throw_mode)
					src.master.toggle_throw_mode()
				else
					src.master.drop_item()
			if ("resist")
				src.master.resist()

			if ("health")
				boutput(src.master, "<span class='notice'>Your health: [src.master.health]/[src.master.max_health]</span>")

			if ("rest")
				if(ON_COOLDOWN(src.master, "toggle_rest", REST_TOGGLE_COOLDOWN))
					return
				if(src.master.ai_active && !src.master.hasStatus("resting"))
					src.master.show_text("You feel too restless to do that!", "red")
				else if (src.master.hasStatus("resting"))
					src.master.delStatus("resting")
					src.master.force_laydown_standup()
				else
					src.master.setStatus("resting", INFINITE_STATUS)
					src.master.force_laydown_standup()
				src.update_resting()

/// updates health hud element
/datum/hud/critter/proc/update_health()
	if (!isdead(src.master))
		if (!src.health) //Runtime fix: Cannot modify null.icon_state
			return
		var/h_ratio = (src.master.health / src.master.max_health) * 100
		switch(h_ratio)
			if(90 to INFINITY)
				src.health.icon_state = "health0" // green with green marker
			if(75 to 90)
				src.health.icon_state = "health1" // green
			if(60 to 75)
				src.health.icon_state = "health2" // yellow
			if(45 to 60)
				src.health.icon_state = "health3" // orange
			if(20 to 45)
				src.health.icon_state = "health4" // dark orange
			if(10 to 20)
				src.health.icon_state = "health5" // red
			else
				src.health.icon_state = "health6" // crit
	else
		src.health.icon_state = "health7"         // dead

/// updates intent hud element
/datum/hud/critter/proc/update_intent()
	src.intent.icon_state = "intent-[src.master.a_intent]"

/// updates movement intent hud element
/datum/hud/critter/proc/update_mintent()
	if (!src.mintent)
		return 0
	src.mintent.icon_state = "move-[src.master.m_intent]"

/// updates pull hud element
/datum/hud/critter/proc/update_pulling()
	if (!src.pulling)
		return 0
	src.pulling.icon_state = "pull[!!src.master.pulling]"

/// updates all status effect hud elements
/datum/hud/critter/proc/update_status_effects()
	for(var/atom/movable/screen/statusEffect/G in src.objects)
		src.remove_screen(G)

	for(var/datum/statusEffect/S as anything in src.statusUiElements) //Remove stray effects.
		if(!src.master.statusEffects || !(S in src.master.statusEffects))
			qdel(src.statusUiElements[S])
			src.statusUiElements.Remove(S)
			qdel(S)

	var/spacing = 0.6
	var/pos_x = spacing - 0.2 - 1

	if(master.statusEffects)
		for(var/datum/statusEffect/S as anything in master.statusEffects) //Add new ones, update old ones.
			if(!S.visible) continue
			if((S in statusUiElements) && src.statusUiElements[S])
				var/atom/movable/screen/statusEffect/U = src.statusUiElements[S]
				U.icon = src.hud_icon
				U.screen_loc = "EAST[pos_x < 0 ? "":"+"][pos_x],NORTH-0.7"
				U.update_value()
				src.add_screen(U)
				pos_x -= spacing
			else
				if(S.visible)
					var/atom/movable/screen/statusEffect/U = new/atom/movable/screen/statusEffect(src.master, S)
					U.init(src.master,S)
					U.icon = src.hud_icon
					src.statusUiElements.Add(S)
					src.statusUiElements[S] = U
					U.screen_loc = "EAST[pos_x < 0 ? "":"+"][pos_x],NORTH-0.7"
					U.update_value()
					src.add_screen(U)
					pos_x -= spacing
					global.animate_buff_in(U)
	return

//HUMAN COPOY PASTE
/// updates stamina sprinting icon state
/datum/hud/critter/proc/set_sprint(var/on)
	if(src.stamina)
		src.stamina.icon_state = on ? "stamina_sprint" : "stamina"

/// updates bleeding hud element
/datum/hud/critter/proc/update_blood_indicator()
	if (!src.bleeding) return //doesn't have a hud element to update
	if (isdead(src.master))
		src.bleeding.icon_state = "blood0"
		src.bleeding.tooltipTheme = "healthDam healthDam0"
		return

	var/state = 0
	var/theme = 0
	switch (src.master.bleeding)
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

	src.bleeding.icon_state = "blood[state]"
	src.bleeding.tooltipTheme = "healthDam healthDam[theme]"

/// updates temperature hud element
/datum/hud/critter/proc/update_temp_indicator()
	if (!src.bodytemp)
		return
	if(src.master.getStatusDuration("burning") && !src.master.is_heat_resistant())
		src.bodytemp.icon_state = "tempF" // on fire
		src.bodytemp.tooltipTheme = "tempInd tempIndF"
		src.bodytemp.desc = "OH FUCK FIRE FIRE FIRE OH GOD FIRE AAAAAAA"
		return

	var/dev = src.master.get_temp_deviation()
	var/state = 0
	switch(dev)
		if(4)
			state = 4 // burning up
			src.bodytemp.desc = "It's scorching hot!"
		if(3)
			state = 3 // far too hot
			src.bodytemp.desc = "It's too hot."
		if(2)
			state = 2 // too hot
			src.bodytemp.desc = "It's a bit warm, but nothing to worry about."
		if(1)
			state = 1 // warm but safe
			src.bodytemp.desc = "It feels a little warm."
		if(-1)
			state = -1 // cool but safe
			src.bodytemp.desc = "It feels a little cool."
		if(-2)
			state = -2 // too cold
			src.bodytemp.desc = "It's a little cold, but nothing to worry about."
		if(-3)
			state = -3 // far too cold
			src.bodytemp.desc = "It's too cold."
		if(-4)
			state = -4 // freezing
			src.bodytemp.desc = "It's absolutely freezing!"
		else
			state = 0 // 310 is optimal body temp
			src.bodytemp.desc = "The temperature feels fine."

	src.bodytemp.icon_state = "temp[state]"
	src.bodytemp.tooltipTheme = "tempInd tempInd[state]"

/// updates toxic gas hud element
/datum/hud/critter/proc/update_tox_indicator(var/status)
	if (!src.toxin)
		return
	src.toxin.icon_state = "tox[status]"

/// updates radiation hud element
/datum/hud/critter/proc/update_rad_indicator(var/status)
	if (!src.rad) // not rad :'(
		return
	src.rad.icon_state = "rad[status]"

/// updates resting status
/datum/hud/critter/proc/update_resting()
	if (!src.resting)
		return 0
	src.resting.icon_state = "rest[src.master.hasStatus("resting") ? 1 : 0]"

/// updates status effects on the owner's hud
/mob/living/critter/updateStatusUi()
	if(src.hud && istype(src.hud, /datum/hud/critter))
		var/datum/hud/critter/H = src.hud
		H.update_status_effects()
	return

/datum/hud/critter/proc/create_hand_element()
	var/initial_hand_offset = -round((src.master.hands.len - 1) / 2) // calculates an offset based on even//odd number of hands
	src.left_offset = initial_hand_offset - 1
	for (var/i = 1, i <= src.master.hands.len, i++)
		var/curr = initial_hand_offset + i - 1
		var/datum/handHolder/handHolder = src.master.hands[i]
		var/center_offset = 0
		if (curr < 0)
			center_offset = curr
		else if (curr > 0)
			center_offset = "+[curr]"
		else
			center_offset = ""

		var/new_screen_loc = "CENTER[center_offset], SOUTH"
		var/atom/movable/screen/hud/hand_element = src.create_screen("hand[i]", handHolder.name, handHolder.icon,\
		"[handHolder.icon_state][i == src.master.active_hand ? 1 : 0]", new_screen_loc, HUD_LAYER)
		handHolder.screenObj = hand_element
		src.hands.Add(handHolder)
	src.right_offset = initial_hand_offset + length(src.master.hands)

/datum/hud/critter/proc/create_health_element()
	src.health = src.create_screen("health", "health", src.hud_icon, "health0",\
	"EAST[src.next_topright()],NORTH", HUD_LAYER)

/datum/hud/critter/proc/create_stamina_element()
	if (src.master.use_stamina)
		var/stamloc = "EAST[src.next_topright()], NORTH"
		src.stamina = src.create_screen("stamina","Stamina", src.hud_icon, "stamina",\
		stamloc, HUD_LAYER, tooltipTheme = "stamina")
		src.stamina_back = src.create_screen("stamina_back","Stamina", src.hud_icon, "stamina_back",\
		stamloc, HUD_LAYER_UNDER_1)
		if (src.master.stamina_bar)
			src.stamina.desc = src.master.stamina_bar.getDesc(src.master)

/datum/hud/critter/proc/create_temperature_element()
	src.bodytemp = src.create_screen("bodytemp","Temperature", src.hud_icon, "temp0",\
	"EAST[src.next_topright()], NORTH", HUD_LAYER, tooltipTheme = "tempInd tempInd0")
	src.bodytemp.desc = "The temperature feels fine."

/datum/hud/critter/proc/create_oxygen_element()
	src.oxygen = src.create_screen("oxygen", "Suffocation Warning", src.hud_icon, "oxy0",\
	"EAST[src.next_topright()], NORTH", HUD_LAYER)

/datum/hud/critter/proc/create_fire_element()
	src.fire = src.create_screen("fire","Fire Warning", src.hud_icon, "fire0",\
	"EAST[src.next_topright()], NORTH", HUD_LAYER)

/datum/hud/critter/proc/create_toxin_element()
	src.toxin = src.create_screen("toxin","Toxic Warning",src.hud_icon, "toxin0",\
	"EAST[src.next_topright()], NORTH", HUD_LAYER, tooltipTheme = "statusToxin")
	src.toxin.desc = "This indicator warns that you are poisoned. You will take toxic damage until the situation is remedied."

/datum/hud/critter/proc/create_radiation_element()
	src.rad = src.create_screen("rad","Radiation Warning", src.hud_icon, "rad0",\
	"EAST[src.next_topright()], NORTH", HUD_LAYER, tooltipTheme = "statusRad")
	src.rad.desc = "This indicator warns that you are irradiated. You will take toxic and burn damage until the situation is remedied."

/datum/hud/critter/proc/create_bleeding_element()
	src.bleeding = src.create_screen("bleeding","Bleed Warning", src.hud_icon, "blood0",\
	"EAST[src.next_topright()], NORTH", HUD_LAYER, tooltipTheme = "healthDam healthDam0")
	src.bleeding.desc = "This indicator warns that you are currently bleeding. You will die if the situation is not remedied."

/datum/hud/critter/proc/create_throwing_element()
	src.throwing = src.create_screen("throw", "throw mode", src.hud_icon, "throw0",\
	"CENTER[src.next_right()], SOUTH", HUD_LAYER_1)

/datum/hud/critter/proc/create_intent_element()
	src.intent = src.create_screen("intent", "action intent", src.hud_icon, "intent-help",\
	"CENTER[src.next_right()],SOUTH", HUD_LAYER_1)

/datum/hud/critter/proc/create_pulling_element()
	src.pulling = src.create_screen("pull", "pulling", 'icons/mob/critter_ui.dmi', "pull0",\
	"CENTER[src.get_right()], SOUTH", HUD_LAYER_1)

/datum/hud/critter/proc/create_mintent_element()
	src.mintent = src.create_screen("mintent", "movement mode", 'icons/mob/critter_ui.dmi', "move-run",\
	"CENTER[src.next_right()], SOUTH", HUD_LAYER_1)

/datum/hud/critter/proc/create_rest_element()
	src.resting = src.create_screen("rest", "resting", 'icons/mob/critter_ui.dmi', "rest0",\
		"CENTER[src.get_right()], SOUTH", HUD_LAYER_1)

/datum/hud/critter/proc/create_resist_element()
	src.resist = src.create_screen("resist", "resist", 'icons/mob/critter_ui.dmi', "resist_critter",\
	"CENTER[src.next_right()], SOUTH", HUD_LAYER_1)

/datum/hud/critter/proc/create_equipment_element()
	for (var/i = 1, i <= src.master.equipment.len, i++)
		var/datum/equipmentHolder/equipmentHolder = src.master.equipment[i]
		var/screen_loc = src.loc_left()
		var/atom/movable/screen/hud/equipment_hud = src.create_screen("equipment[i]", equipmentHolder.name, equipmentHolder.icon,\
		equipmentHolder.icon_state, screen_loc, HUD_LAYER_1)
		equipmentHolder.screenObj = equipment_hud
		src.equipment += equipmentHolder
		if (equipmentHolder.item)
			src.add_object(equipmentHolder.item)
