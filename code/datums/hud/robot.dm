/atom/movable/screen/hud/robotstorage
	MouseEntered(location, control, params)
		// there is no reason for master to ever be something other than /datum/hud/silicon here
		// and yet
		if(istype(src.master, /datum/hud/silicon/robot))
			var/datum/hud/silicon/robot/hud = src.master
			if(usr != hud.silicon) return
		if (src.name)
			src.maptext_x = 34
			src.maptext_width = 128
			src.maptext = "<span class='vm l pixel sh'>[src.name]</span>"
	MouseExited(location, control, params)
		if(istype(src.master, /datum/hud/silicon/robot))
			var/datum/hud/silicon/robot/hud = src.master
			if(usr != hud.silicon) return
		src.maptext = null

/datum/hud/silicon/robot
	var/atom/movable/screen/hud
		mod1
		mod2
		mod3
		charge
		module
		intent
		pulling

		prev
		boxes
		next
		close

		health
		oxy
		temp

		pda
		eyecam

	var/list/screen_tools = list()

	var/list/atom/movable/screen/hud/upgrade_bg = list()
	var/list/atom/movable/screen/hud/upgrade_slots = list()
	var/show_upgrades = 1

	var/items_screen = 1
	var/show_items = 0

	var/last_health = -1
	var/mini_health = 0

	var/list/last_upgrades = list()
	var/list/last_tools = list()
	var/mob/living/silicon/robot/master
	var/icon/icon_hud = 'icons/mob/hud_robot.dmi'

	var/image/storage_bg


	var/list/statusUiElements = list() //Assoc. List  STATUS EFFECT INSTANCE : UI ELEMENT add_screen(atom/movable/screen/S). Used to hold the ui elements since they shouldnt be on the status effects themselves.

	var/atom/movable/screen/hud

	clear_master()
		master = null
		..()

	proc
		toggle_equipment()
			show_items = !show_items
			update_equipment()

		module_added()
			items_screen = 1
			update_equipment()
			update_module()

		module_removed()
			items_screen = 1
			update_equipment()
			update_module()

		update_equipment()
			if (!master.module || !show_items)
				show_items = 0
				for (var/O in screen_tools)
					remove_screen(O)
				remove_screen(boxes)
				remove_screen(close)
				remove_screen(prev)
				remove_screen(next)
				return
			var/list/tools = master.get_tools()
			var x = 1, y = 10, sx = 1, sy = 10
			if (!boxes)
				return
			if (items_screen + 6 > length(tools))
				items_screen = max(length(tools) - 6, 1)
			if (items_screen < 1)
				items_screen = 1
			boxes.screen_loc = "[x], [y] to [x+sx-1], [y-sy+1]"
			if (!close)
				src.close = create_screen("close", "Close", 'icons/mob/screen1.dmi', "x", "1, 1", HUD_LAYER+1)
			if (!prev)
				src.prev = create_screen("prev", "Previous Page", 'icons/mob/screen1.dmi', "up_dis", "1, 10", HUD_LAYER+1)
			if (!next)
				src.next = create_screen("next", "Next Page", 'icons/mob/screen1.dmi', "down", "1, 2", HUD_LAYER+1)
			close.screen_loc = "[x+sx-1], [y-sy+1]"
			next.screen_loc = "[x+sx-1], [y-sy+2]"
			prev.screen_loc = "[x+sx-1], [y]"

			for (var/O in screen_tools)
				remove_screen(O)
			add_screen(boxes)
			add_screen(close)
			add_screen(prev)
			add_screen(next)

			if (items_screen > 1)
				prev.icon_state = "up"
				prev.color = COLOR_MATRIX_IDENTITY
			else
				prev.icon_state = "up_dis"
				prev.color = COLOR_MATRIX_GRAYSCALE

			var/sid = 1
			var/i_max = items_screen + 7
			if (i_max <= length(tools))
				next.icon_state = "down"
				next.color = COLOR_MATRIX_IDENTITY
			else
				next.icon_state = "down_dis"
				next.color = COLOR_MATRIX_GRAYSCALE

			for (var/i = items_screen, i < i_max, i++)
				if (i > length(tools))
					break
				var/obj/item/I = tools[i]
				var/atom/movable/screen/hud/S = screen_tools[sid]

				if (!I) // if the item has been deleted, just show an empty slot.
					S.name = null
					S.icon = 0
					S.icon_state = null
					S.overlays = null
					S.underlays = null
					S.color = COLOR_MATRIX_IDENTITY
					S.alpha = 255
					S.item = null
				else
					S.name = I.name
					S.icon = I.icon
					S.icon_state = I.icon_state
					S.overlays = I.overlays.Copy()
					S.underlays = I.underlays.Copy()
					if (I.loc == master.module)
						S.color = I.color
					else
						S.color = COLOR_MATRIX_GRAYSCALE // If the tool is already equipped, set grayscale
					S.alpha = I.alpha
					S.item = I
					S.underlays += storage_bg

				S.screen_loc = "[x], [y - sid]"
				add_screen(S)
				sid++

		try_equip_at(var/i)
			if (!master)
				update_equipment()
				return
			if (!master.cell || master.cell.charge <= ROBOT_BATTERY_DISTRESS_THRESHOLD)
				boutput(master, SPAN_ALERT("You don't have enough power to equip this!"))
				update_equipment()
				return
			if (!master.module || !show_items)
				update_equipment()
				return
			if (master.hasStatus("lockdown_robot"))
				boutput(master, SPAN_ALERT("Your equipment is locked down!"))
				update_equipment()
				return
			var/content_id = items_screen + i - 1
			var/list/tools = master.get_tools()
			if (content_id > length(tools) || content_id < 1)
				boutput(usr, SPAN_ALERT("An error occurred. Please notify a coder immediately. (Content ID: [content_id].)"))
			var/obj/item/O = tools[content_id]
			if(!O || (O.loc != master.module && O.loc != master))
				return
			if(!master.module_states[1] && istype(master.part_arm_l,/obj/item/parts/robot_parts/arm/))
				master.equip_slot(1, O)
			else if(!master.module_states[2])
				master.equip_slot(2, O)
			else if(!master.module_states[3] && istype(master.part_arm_r,/obj/item/parts/robot_parts/arm/))
				master.equip_slot(3, O)
			else
				master.uneq_active()
				if(!master.module_states[1] && istype(master.part_arm_l,/obj/item/parts/robot_parts/arm/))
					master.equip_slot(1, O)
				else if(!master.module_states[2])
					master.equip_slot(2, O)
				else if(!master.module_states[3] && istype(master.part_arm_r,/obj/item/parts/robot_parts/arm/))
					master.equip_slot(3, O)
			update_equipment()
			update_tools()

	New(M)
		..()
		master = M

		// @TODO i fucking hate the boxes not being clickable so here's a gross hack to fix it
		src.storage_bg = image('icons/mob/screen1.dmi', icon_state = "block")
		src.storage_bg.appearance_flags |= RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM

		src.boxes = create_screen("boxes", "Storage", 'icons/mob/screen1.dmi', "block", "1, 10 to 1, 1")
		remove_screen(boxes)
		src.prev = create_screen("prev", "Previous Page", 'icons/mob/screen1.dmi', "up_dis", "1, 10", HUD_LAYER+1)
		remove_screen(prev)
		src.next = create_screen("next", "Next Page", 'icons/mob/screen1.dmi', "down", "1, 2", HUD_LAYER+1)
		remove_screen(next)
		src.close = create_screen("close", "Close", 'icons/mob/screen1.dmi', "x", "1, 1", HUD_LAYER+1)
		remove_screen(close)
		for (var/i = 1, i <= 7, i++)
			var/S = create_screen("object[i]", "object", null, null, "1, [10 - i]", HUD_LAYER + 1, customType = /atom/movable/screen/hud/robotstorage)
			remove_screen(S)
			screen_tools += S

		create_screen("", "", 'icons/mob/hud_common.dmi', "hotbar_bg", "CENTER-5, SOUTH to CENTER+5, SOUTH", HUD_LAYER)
		create_screen("", "", 'icons/mob/hud_common.dmi', "hotbar_side", "CENTER-5, SOUTH+1 to CENTER+5, SOUTH+1", HUD_LAYER, SOUTH)
		create_screen("", "", 'icons/mob/hud_common.dmi', "hotbar_side", "CENTER-6, SOUTH+1", HUD_LAYER, SOUTHWEST)
		create_screen("", "", 'icons/mob/hud_common.dmi', "hotbar_side", "CENTER-6, SOUTH", HUD_LAYER, EAST)
		create_screen("", "", 'icons/mob/hud_common.dmi', "hotbar_side", "CENTER+6, SOUTH+1", HUD_LAYER, SOUTHEAST)
		create_screen("", "", 'icons/mob/hud_common.dmi', "hotbar_side", "CENTER+6, SOUTH", HUD_LAYER, WEST)

		mod1 = create_screen("mod1", "Module 1", icon_hud, "mod10", "CENTER-5, SOUTH", HUD_LAYER+1)
		mod2 = create_screen("mod2", "Module 2", icon_hud, "mod20", "CENTER-4, SOUTH", HUD_LAYER+1)
		mod3 = create_screen("mod3", "Module 3", icon_hud, "mod30", "CENTER-3, SOUTH", HUD_LAYER+1)

		create_screen("store", "Store", icon_hud, "store", "CENTER-2, SOUTH", HUD_LAYER+1)
		charge = create_screen("charge", "Battery", icon_hud, "charge4", "CENTER-1, SOUTH", HUD_LAYER+1)
		charge.maptext_y = -5
		charge.maptext_width = 48
		charge.maptext_x = -9

		module = create_screen("module", "Module", icon_hud, "module-initial", "CENTER, SOUTH", HUD_LAYER+1)
		create_screen("radio", "Radio", icon_hud, "radio", "CENTER+1, SOUTH", HUD_LAYER+1)
		intent = create_screen("intent", "Intent", icon_hud, "intent-[master.a_intent]", "CENTER+2, SOUTH", HUD_LAYER+1)

		pulling = create_screen("pulling", "Pulling", icon_hud, "pull0", "CENTER+4, SOUTH", HUD_LAYER+1)
		create_screen("upgrades", "Upgrades", icon_hud, "upgrades", "CENTER+5, SOUTH", HUD_LAYER+1)

		health = create_screen("health", "Health", icon_hud, "health0", "EAST, NORTH")
		health.maptext_width = 148
		health.maptext_height = 64
		health.maptext_x = -150
		health.maptext_y = -36

		oxy = create_screen("oxy", "Oxygen", icon_hud, "oxy0", "EAST, NORTH-1")
		temp = create_screen("temp", "Temperature", icon_hud, "temp0", "EAST, NORTH-2")

		if (master.module_active)
			set_active_tool(master.module_states.Find(master.module_active))
		update_tools()
		update_pulling()
		update_health()
		update_module()
		update_upgrades()
		update_equipment()

		pda = create_screen("pda", "Cyborg PDA", 'icons/mob/hud_ai.dmi', "pda", "WEST, NORTH+0.5", HUD_LAYER)
		pda.underlays += "button"

		eyecam = create_screen("eyecam", "Eject to eyecam", 'icons/mob/screen1.dmi', "x", "SOUTH,EAST", HUD_LAYER)
		eyecam.underlays += "block"


	scrolled(id, dx, dy, user, parms, atom/movable/screen/hud/scr)
		if(!master || user != master) return
		switch(id)
			if("object1", "object2", "object3", "object4", "object5", "object6", "object7", "next", "nextbg", "prev", "prevbg", "boxes")
				if(dy < 0) items_screen++
				else items_screen--
				update_equipment()
			else
				if(scr?.item)
					if(dy < 0) items_screen++
					else items_screen--
					update_equipment()

	relay_click(id)
		if (!master)
			return
		switch (id)
			if ("next")
				if (next.icon_state != "down_dis") // this is bad and i will fix it in 2025
					items_screen += 7
					update_equipment()
			if ("prev")
				if (next.icon_state != "up_dis") // this is bad and i will fix it in 2025
					items_screen -= 7
					update_equipment()
			if ("close")
				show_items = 0
				update_equipment()
			if ("object1")
				try_equip_at(1)
				update_equipment()
			if ("object2")
				try_equip_at(2)
				update_equipment()
			if ("object3")
				try_equip_at(3)
				update_equipment()
			if ("object4")
				try_equip_at(4)
				update_equipment()
			if ("object5")
				try_equip_at(5)
				update_equipment()
			if ("object6")
				try_equip_at(6)
				update_equipment()
			if ("object7")
				try_equip_at(7)
				update_equipment()
			if ("mod1")
				master.swap_hand(1)
			if ("mod2")
				master.swap_hand(2)
			if ("mod3")
				master.swap_hand(3)
			if ("store")
				master.uneq_active()
			if ("module")
				master.toggle_module_pack()
			if ("radio")
				master.radio_menu()
			if ("intent")
				if (master.a_intent == INTENT_HELP)
					master.set_a_intent(INTENT_HARM)
				else
					master.set_a_intent(INTENT_HELP)
			if ("pulling")
				if (master.pulling)
					unpull_particle(master,pulling)
					master.remove_pulling()
					src.update_pulling()
				else if(!isturf(master.loc))
					boutput(master, SPAN_NOTICE("You can't pull things while inside \a [master.loc]."))
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
						boutput(master, SPAN_NOTICE("There is nothing to pull."))
					else
						to_pull = tgui_input_list(master, "Which do you want to pull? You can also Ctrl+Click on things to pull them.", "Which thing to pull?", pullable)
					if(!isnull(to_pull) && BOUNDS_DIST(master, to_pull) == 0)
						to_pull.pull(master)
			if ("upgrades")
				set_show_upgrades(!src.show_upgrades)
			if ("upgrade1") // this is horrifying
				if (length(last_upgrades) >= 1)
					master.activate_upgrade(src.last_upgrades[1])
			if ("upgrade2")
				if (length(last_upgrades) >= 2)
					master.activate_upgrade(src.last_upgrades[2])
			if ("upgrade3")
				if (length(last_upgrades) >= 3)
					master.activate_upgrade(src.last_upgrades[3])
			if ("upgrade4")
				if (length(last_upgrades) >= 4)
					master.activate_upgrade(src.last_upgrades[4])
			if ("upgrade5")
				if (length(last_upgrades) >= 5)
					master.activate_upgrade(src.last_upgrades[5])
			if ("upgrade6")
				if (length(last_upgrades) >= 6)
					master.activate_upgrade(src.last_upgrades[6])
			if ("upgrade7")
				if (length(last_upgrades) >= 7)
					master.activate_upgrade(src.last_upgrades[7])
			if ("upgrade8")
				if (length(last_upgrades) >= 8)
					master.activate_upgrade(src.last_upgrades[8])
			if ("upgrade9")
				if (length(last_upgrades) >= 9)
					master.activate_upgrade(src.last_upgrades[9])
			if ("upgrade10")
				if (length(last_upgrades) >= 10)
					master.activate_upgrade(src.last_upgrades[10])
			if ("health")
				mini_health = (mini_health + 1) % 3
				last_health = -1
			if ("pda")
				master.access_internal_pda()
			if ("eyecam")
				master.become_eye()

	proc/update_status_effects()
		for(var/atom/movable/screen/statusEffect/G in src.objects)
			remove_screen(G)

		for(var/datum/statusEffect/S as anything in src.statusUiElements) //Remove stray effects.
			if(!master.statusEffects || !(S in master.statusEffects))
				qdel(statusUiElements[S])
				src.statusUiElements.Remove(S)
				qdel(S)

		var/spacing = 0.6
		var/pos_x = spacing - 0.2 - 1

		if(master.statusEffects)
			for(var/datum/statusEffect/S as anything in master.statusEffects) //Add new ones, update old ones.
				if(!S.visible) continue
				if((S in statusUiElements) && statusUiElements[S])
					var/atom/movable/screen/statusEffect/U = statusUiElements[S]
					U.icon = icon_hud
					U.screen_loc = "EAST[pos_x < 0 ? "":"+"][pos_x],NORTH-2.7"
					U.update_value()
					add_screen(U)
					pos_x -= spacing
				else
					if(S.visible)
						var/atom/movable/screen/statusEffect/U = new /atom/movable/screen/statusEffect
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

	update_health()
		..()
		if (!isdead(master))
			//var/pct = round(100*master.cell.charge/master.cell.maxcharge, 1)
			//charge.maptext = "<span class='vga ol vt c'>[pct]%</span>"
			//charge.maptext_y = 11
			if (mini_health == 2)
				health.maptext = " "
			else if (1 || last_health != master.health)

				var/list/hp = list(
					"[!mini_health ? "H/C " : "HEAD "][maptext_health_percent(master.part_head)]",
					"[!mini_health ? " " : "\nCHST "][maptext_health_percent(master.part_chest)]",
					"[!mini_health ? "\nARM " : "\nLARM "][maptext_health_percent(master.part_arm_l)]",
					"[!mini_health ? " " : "\nRARM "][maptext_health_percent(master.part_arm_r)]",
					"[!mini_health ? "\nLEG " : "\nLLEG "][maptext_health_percent(master.part_leg_l)]",
					"[!mini_health ? " " : "\nRLEG "][maptext_health_percent(master.part_leg_r)]"
					)

				health.maptext = "<span class='ol r vt ps2p'>[jointext(hp, "")]</span>"
				last_health = master.health


			/*
				var/obj/item/parts/robot_parts/head/part_head = null
				var/obj/item/parts/robot_parts/chest/part_chest = null
				var/obj/item/parts/robot_parts/arm/part_arm_r = null
				var/obj/item/parts/robot_parts/arm/part_arm_l = null
				var/obj/item/parts/robot_parts/leg/part_leg_r = null
				var/obj/item/parts/robot_parts/leg/part_leg_l = null
			*/

			switch(master.health)
				if(100 to INFINITY)
					health.icon_state = "health0"
				if(80 to 100)
					health.icon_state = "health1"
				if(60 to 80)
					health.icon_state = "health2"
				if(40 to 60)
					health.icon_state = "health3"
				if(20 to 40)
					health.icon_state = "health4"
				if(0 to 20)
					health.icon_state = "health5"
				else
					health.icon_state = "health6"
		else
			health.icon_state = "health7"

		// I put this here because there's nowhere else for it right now.
		// @TODO robot hud needs a general update() call imo.
		if (src.eyecam)
			eyecam.invisibility = (master.mainframe ? INVIS_NONE : INVIS_ALWAYS)

	proc
		set_active_tool(active) // naming these tools to distinuish it from the module of a borg
			mod1.icon_state = "mod1[active == 1]"
			mod2.icon_state = "mod2[active == 2]"
			mod3.icon_state = "mod3[active == 3]"

		set_show_upgrades(show)
			if (show == show_upgrades)
				return
			show_upgrades = show
			if (show)
				for (var/atom/movable/screen/hud/H in upgrade_bg)
					add_screen(H)
				for (var/atom/movable/screen/hud/H in upgrade_slots)
					add_screen(H)
				for (var/obj/item/roboupgrade/upgrade in last_upgrades)
					add_object(upgrade, HUD_LAYER+2)
			else
				for (var/atom/movable/screen/hud/H in upgrade_bg)
					remove_screen(H)
				for (var/atom/movable/screen/hud/H in upgrade_slots)
					remove_screen(H)
				for (var/obj/item/roboupgrade/upgrade in last_upgrades)
					remove_object(upgrade)

		update_tools()
			for (var/obj/item/I in last_tools)
				remove_object(I)
			var/obj/item/tool1 = master.module_states[1]
			var/obj/item/tool2 = master.module_states[2]
			var/obj/item/tool3 = master.module_states[3]
			if (tool1)
				add_object(tool1, HUD_LAYER+2, "CENTER-5, SOUTH")
			if (tool2)
				add_object(tool2, HUD_LAYER+2, "CENTER-4, SOUTH")
			if (tool3)
				add_object(tool3, HUD_LAYER+2, "CENTER-3, SOUTH")
			last_tools = master.module_states.Copy()

		update_module()
			if (master.module)
				module.icon_state = "module-[master.module.mod_hudicon]"
			else if (master.freemodule)
				module.icon_state = "module-initial"
			else
				module.icon_state = "module-empty"

		update_intent()
			intent.icon_state = "intent-[master.a_intent]"

		update_charge()
			if (master.cell)
				var/pct = round(100*master.cell.charge/master.cell.maxcharge, 1)
				charge.maptext = "<span class='ps2p ol vt c' style='color: [rgb(255 * clamp((100 - pct) / 50, 0, 1), 255 * clamp(pct / 50, 1, 0), 0)];'>[pct]%</span>"

				switch(round(100*master.cell.charge/master.cell.maxcharge))
					if(75 to INFINITY)
						charge.icon_state = "charge4"
					if(50 to 75)
						charge.icon_state = "charge3"
					if(25 to 50)
						charge.icon_state = "charge2"
					if(1 to 25)
						charge.icon_state = "charge1"
					else
						charge.icon_state = "charge0"
			else
				charge.icon_state = "charge-none"
				charge.maptext = "<span class='ps2p ol vt c' style='color: #f00;'>---</span>"

		maptext_health_percent(var/obj/item/parts/robot_parts/part)
			if (!part || !istype(part) || part.qdeled)
				return "<span style='color: #f00;'>[!mini_health ? "---%" : "MISSING"]</span>"

			var/dmg = part.dmg_blunt + part.dmg_burns
			var/pct = 100 - clamp(dmg / part.max_health * 100, 0, 100)
			return "<span style='color: [rgb(255 * clamp((100 - pct) / 50, 0, 1), 255 * clamp(pct / 50, 1, 0), 0)];'>[!mini_health ? "[pad_leading(round(pct), 3)]%" : "[pad_leading(round(part.max_health - dmg), 3)]</span>/<span style='color: #ffffff;'>[pad_leading(round(part.max_health), 3)]"]</span>"


		update_pulling()
			pulling.icon_state = "pull[master.pulling ? 1 : 0]"

		update_environment()
			var/turf/T = get_turf(master)
			if (T)
				var/datum/gas_mixture/environment = T.return_air()
				var/total = TOTAL_MOLES(environment)
				if (total > 0) // prevent a division by zero
					oxy.icon_state = "oxy[environment.oxygen/total*MIXTURE_PRESSURE(environment) < 17]"
				else
					oxy.icon_state = "oxy1"
				switch (environment.temperature)
					if (350 to INFINITY)
						temp.icon_state = "temp1"
					if (280 to 350)
						temp.icon_state = "temp0"
					else
						temp.icon_state = "temp-1"

		update_upgrades()
			var/startx = 5 - master.max_upgrades
			if (master.max_upgrades != upgrade_slots.len)
				for (var/atom/movable/screen/hud/H in upgrade_bg)
					remove_screen(H)
				for (var/atom/movable/screen/hud/H in upgrade_slots)
					remove_screen(H)

				upgrade_bg.len = 0
				upgrade_bg += create_screen("", "", 'icons/mob/hud_common.dmi', "hotbar_bg", "CENTER+[startx]:24, SOUTH+1:4 to CENTER+4:24, SOUTH+1:4", HUD_LAYER)
				upgrade_bg += create_screen("", "", 'icons/mob/hud_common.dmi', "hotbar_side", "CENTER+[startx]:24, SOUTH+2:4 to CENTER+4:24, SOUTH+2:4", HUD_LAYER, SOUTH)
				upgrade_bg += create_screen("", "", 'icons/mob/hud_common.dmi', "hotbar_side", "CENTER+[startx-1]:24, SOUTH+2:4", HUD_LAYER, SOUTHWEST)
				upgrade_bg += create_screen("", "", 'icons/mob/hud_common.dmi', "hotbar_side", "CENTER+[startx-1]:24, SOUTH+1:4", HUD_LAYER, EAST)
				upgrade_bg += create_screen("", "", 'icons/mob/hud_common.dmi', "hotbar_side", "CENTER+5:24, SOUTH+2:4", HUD_LAYER, SOUTHEAST)
				upgrade_bg += create_screen("", "", 'icons/mob/hud_common.dmi', "hotbar_side", "CENTER+5:24, SOUTH+1:4", HUD_LAYER, WEST)

				upgrade_slots.len = 0
				for (var/i = 0; i < master.max_upgrades; i++)
					upgrade_slots += create_screen("upgrade[i+1]", "Upgrade [i+1]", icon_hud, "upgrade0", "CENTER+[startx+i]:24, SOUTH+1:4", HUD_LAYER+1)

				if (!show_upgrades) // this is dumb
					for (var/atom/movable/screen/hud/H in upgrade_bg)
						remove_screen(H)
					for (var/atom/movable/screen/hud/H in upgrade_slots)
						remove_screen(H)

			for (var/obj/item/roboupgrade/upgrade in last_upgrades)
				remove_object(upgrade)
			var/i = 0
			for (var/obj/item/roboupgrade/upgrade in master.upgrades)
				if (i >= upgrade_slots.len)
					break

				var/atom/movable/screen/hud/slot = upgrade_slots[i+1]
				slot.icon_state = "upgrade[upgrade.activated]"
				if (show_upgrades)
					add_object(upgrade, HUD_LAYER+2, "CENTER+[startx+i]:24, SOUTH+1:4")
					i++
			last_upgrades = master.upgrades.Copy()

	proc/handle_event(var/event, var/sender)
		if (event == "icon_updated") // this is only ever emitted by atoms
			var/atom/senderAtom = sender
			if (senderAtom.loc != master.module) // An equipped tool has changed its icon; refresh module display
				update_equipment()

/mob/living/silicon/robot
	updateStatusUi()
		if(src.hud && istype(src.hud, /datum/hud/silicon/robot))
			var/datum/hud/silicon/robot/H = src.hud
			H.update_status_effects()
		return
