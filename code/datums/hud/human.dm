

/datum/hud/human
	var/atom/movable/screen/hud
		invtoggle
		belt
		storage1
		storage2
		back
		lhand
		rhand
		twohandl
		twohandr
		throwing
		intent
		mintent
		resist
		pulling
		resting
		sprinting
		swaphands
		equip
		tg_butts

		health
		health_brute
		health_burn
		health_tox
		health_oxy
		bleeding
		stamina
		stamina_back
		bodytemp
		oxygen
		fire
		toxin
		rad
		ability_toggle
		stats
		legend
		sel
	var/list/atom/movable/screen/hud/inventory_bg = list()
	var/list/obj/item/inventory_items = list()
	var/show_inventory = 1
	var/show_genetics_abilities = TRUE
	var/icon/icon_hud = 'icons/mob/hud_human_new.dmi'

	var/list/statusUiElements = list() //Assoc. List  STATUS EFFECT INSTANCE : UI ELEMENT add_screen(atom/movable/screen/S). Used to hold the ui elements since they shouldnt be on the status effects themselves.

	var/mob/living/carbon/human/master

	var/layout_style = "goon"

	var/mutable_appearance/default_sel_appearance

	var/static/list/layouts = \
							list("goon" = list( \
										"invtoggle" = ui_invtoggle,\
										"belt" = ui_belt,\
										"storage1" = ui_storage1,\
										"storage2" = ui_storage2,\
										"back" = ui_back,\
										"lhand" = ui_lhand,\
										"rhand" = ui_rhand,\
										"twohand" = ui_twohand,\
										"twohandl" = ui_lhand,\
										"twohandr" = ui_rhand,\
										"throwing" = ui_throwing,\
										"intent" = ui_intent,\
										"mintent" = ui_mintent,\
										"resist" = ui_resist,\
										"pull" = ui_pulling,\
										"rest" = ui_rest,\
										"sprint" = 0,\
										"shoes" = ui_shoes,\
										"gloves" = ui_gloves,\
										"id" = ui_id,\
										"under" = ui_clothing,\
										"suit" = ui_suit,\
										"glasses" = ui_glasses,\
										"ears" = ui_ears,\
										"mask" = ui_mask,\
										"head" = ui_head,\
										"abiltoggle" = ui_abiltoggle,\
										"stats" = ui_stats,\
										"legend" = ui_legend,\
										"ability_icon" = "ability-",\
										"swaphands" = 0,\
										"equip" = 0,\
										"tg_butts" = 0,\
										"ignore_inventory_hide" = 0,\
										"show_bg" = 1,\
										), \
							"tg" = list( \
										"invtoggle" = tg_ui_invtoggle,\
										"belt" = tg_ui_belt,\
										"storage1" = tg_ui_storage1,\
										"storage2" = tg_ui_storage2,\
										"back" = tg_ui_back,\
										"lhand" = tg_ui_lhand,\
										"rhand" = tg_ui_rhand,\
										"twohand" = tg_ui_twohand,\
										"twohandl" = tg_ui_lhand,\
										"twohandr" = tg_ui_rhand,\
										"throwing" = tg_ui_throwing,\
										"intent" = tg_ui_intent,\
										"mintent" = tg_ui_mintent,\
										"resist" = tg_ui_resist,\
										"pull" = tg_ui_pulling,\
										"rest" = tg_ui_rest,\
										"sprint" = tg_ui_sprint,\
										"shoes" = tg_ui_shoes,\
										"gloves" = tg_ui_gloves,\
										"id" = tg_ui_id,\
										"under" = tg_ui_clothing,\
										"suit" = tg_ui_suit,\
										"glasses" = tg_ui_glasses,\
										"ears" = tg_ui_ears,\
										"mask" = tg_ui_mask,\
										"head" = tg_ui_head,\
										"abiltoggle" = tg_ui_abiltoggle,\
										"stats" = tg_ui_stats,\
										"legend" = tg_ui_legend,\
										"ability_icon" = "tg_ability-",\
										"swaphands" = tg_ui_swaphands,\
										"equip" = tg_ui_equip,\
										"tg_butts" = tg_ui_extra_buttons,\
										"ignore_inventory_hide" = list("id"),\
										"show_bg" = 0,\
										))



	proc/update_status_effects()
		for(var/datum/statusEffect/S as anything in src.statusUiElements) //Remove stray effects.
			remove_screen(statusUiElements[S])
			if(!master || !master.statusEffects || !(S in master.statusEffects))
				qdel(statusUiElements[S])
				src.statusUiElements.Remove(S)
				qdel(S)

		var/spacing = 0.6
		var/pos_x = spacing - 0.2

		if(master?.statusEffects)
			for(var/datum/statusEffect/S as anything in master.statusEffects) //Add new ones, update old ones.
				if(!S.visible) continue
				if((S in statusUiElements) && statusUiElements[S])
					var/atom/movable/screen/statusEffect/U = statusUiElements[S]
					U.icon = icon_hud
					U.screen_loc = "EAST[pos_x < 0 ? "":"+"][pos_x],NORTH-0.7"
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

	clear_master()
		master = null
		..()

	New(M)
		..()
		if(isnull(M))
			CRASH("human HUD created with no master")
		master = M

		SPAWN(0)
			if(master?.disposed)
				qdel(src)
				return
			if(src.disposed)
				return
			var/icon/hud_style = hud_style_selection[get_hud_style(master)]
			if (isicon(hud_style))
				src.icon_hud = hud_style

			if (master?.client?.tg_layout)
				layout_style = "tg"

			if (layouts[layout_style]["show_bg"])
				create_screen("", "", 'icons/mob/hud_common.dmi', "hotbar_bg", "CENTER-5, SOUTH to CENTER+6, SOUTH", HUD_LAYER)
				create_screen("", "", 'icons/mob/hud_common.dmi', "hotbar_side", "CENTER-5, SOUTH+1 to CENTER+6, SOUTH+1", HUD_LAYER, SOUTH)
				create_screen("", "", 'icons/mob/hud_common.dmi', "hotbar_side", "CENTER-6, SOUTH+1", HUD_LAYER, SOUTHWEST)
				create_screen("", "", 'icons/mob/hud_common.dmi', "hotbar_side", "CENTER-6, SOUTH", HUD_LAYER, EAST)
				create_screen("", "", 'icons/mob/hud_common.dmi', "hotbar_side", "CENTER+7, SOUTH+1", HUD_LAYER, SOUTHEAST)
				create_screen("", "", 'icons/mob/hud_common.dmi', "hotbar_side", "CENTER+7, SOUTH", HUD_LAYER, WEST)

			invtoggle = create_screen("invtoggle", "toggle inventory", src.icon_hud, "invtoggle", layouts[layout_style]["invtoggle"], HUD_LAYER+1)
			belt = create_screen("belt", "belt", src.icon_hud, "belt", layouts[layout_style]["belt"], HUD_LAYER+1)
			storage1 = create_screen("storage1", "pocket", src.icon_hud, "pocket", layouts[layout_style]["storage1"], HUD_LAYER+1)
			storage2 = create_screen("storage2", "pocket", src.icon_hud, "pocket", layouts[layout_style]["storage2"], HUD_LAYER+1)
			back = create_screen("back", "back", src.icon_hud, "back", layouts[layout_style]["back"], HUD_LAYER+1)
			lhand = create_screen("lhand", "left hand", src.icon_hud, "handl0", layouts[layout_style]["lhand"], HUD_LAYER+1)
			rhand = create_screen("rhand", "right hand", src.icon_hud, "handr0", layouts[layout_style]["rhand"], HUD_LAYER+1)
			twohandl = create_screen("twohandl", "both hands", src.icon_hud, "twohandl", layouts[layout_style]["twohandl"], HUD_LAYER+1)
			twohandr = create_screen("twohandr", "both hands", src.icon_hud, "twohandr", layouts[layout_style]["twohandr"], HUD_LAYER+1)
			throwing = create_screen("throw", "throw mode", src.icon_hud, "throw0", layouts[layout_style]["throwing"], HUD_LAYER+1)
			intent = create_screen("intent", "action intent", src.icon_hud, "intent-help", layouts[layout_style]["intent"], HUD_LAYER+1)
			mintent = create_screen("mintent", "movement mode", src.icon_hud, "move-run", layouts[layout_style]["mintent"], HUD_LAYER+1)
			resist = create_screen("resist", "resist", src.icon_hud, "resist", layouts[layout_style]["resist"], HUD_LAYER+1)
			pulling = create_screen("pull", "pulling", src.icon_hud, "pull0", layouts[layout_style]["pull"], HUD_LAYER+1)
			resting = create_screen("rest", "resting", src.icon_hud, "rest0", layouts[layout_style]["rest"], HUD_LAYER+1)

			if (layouts[layout_style]["sprint"])
				sprinting = create_screen("sprint", "sprinting", src.icon_hud, "sprint0", layouts[layout_style]["sprint"], HUD_LAYER+1)
			if (layouts[layout_style]["swaphands"])
				swaphands = create_screen("swaphands", "swap hands", src.icon_hud, "swap", layouts[layout_style]["swaphands"], HUD_LAYER+1)
			if (layouts[layout_style]["equip"])
				equip = create_screen("equip", "equip item", src.icon_hud, "equip", layouts[layout_style]["equip"], HUD_LAYER+1)
			if (layouts[layout_style]["tg_butts"])
				equip = create_screen("tg_butts", "extra buttons", src.icon_hud, "tg_butts", layouts[layout_style]["tg_butts"], HUD_LAYER+1)

			inventory_bg += create_screen("shoes", "shoes", src.icon_hud, "shoes", layouts[layout_style]["shoes"], HUD_LAYER+1)
			inventory_bg += create_screen("gloves", "gloves", src.icon_hud, "gloves", layouts[layout_style]["gloves"], HUD_LAYER+1)
			inventory_bg += create_screen("id", "ID", src.icon_hud, "id", layouts[layout_style]["id"], HUD_LAYER+1)
			inventory_bg += create_screen("under", "clothing", src.icon_hud, "center", layouts[layout_style]["under"], HUD_LAYER+1)
			inventory_bg += create_screen("suit", "suit", src.icon_hud, "armor", layouts[layout_style]["suit"], HUD_LAYER+1)
			inventory_bg += create_screen("glasses", "glasses", src.icon_hud, "glasses", layouts[layout_style]["glasses"], HUD_LAYER+1)
			inventory_bg += create_screen("ears", "ears", src.icon_hud, "ears", layouts[layout_style]["ears"], HUD_LAYER+1)
			inventory_bg += create_screen("mask", "mask", src.icon_hud, "mask", layouts[layout_style]["mask"], HUD_LAYER+1)
			inventory_bg += create_screen("head", "head", src.icon_hud, "hair", layouts[layout_style]["head"], HUD_LAYER+1)

			if (layouts[layout_style]["ignore_inventory_hide"])
				for (var/id in layouts[layout_style]["ignore_inventory_hide"])
					for (var/atom/movable/screen/hud/H in inventory_bg)
						if (id == H.id)
							inventory_bg -= H
							break

			health = create_screen("health","Health", src.icon_hud, "health0", "EAST, NORTH", HUD_LAYER, tooltipTheme = "healthDam healthDam0")
			health.desc = "You feel fine."

			health_brute = create_screen("mbrute","Brute Damage", src.icon_hud, "blank", "EAST, NORTH", HUD_LAYER, tooltipTheme = "healthDam healthDam0")
			health_burn = create_screen("mburn","Burn Damage", src.icon_hud, "blank", "EAST, NORTH", HUD_LAYER, tooltipTheme = "healthDam healthDam0")
			health_tox = create_screen("mtox","Toxin Damage", src.icon_hud, "blank", "EAST, NORTH", HUD_LAYER, tooltipTheme = "healthDam healthDam0")
			health_oxy = create_screen("moxy","Oxygen Damage", src.icon_hud, "blank", "EAST, NORTH", HUD_LAYER, tooltipTheme = "healthDam healthDam0")

			bleeding = create_screen("bleeding","Bleed Warning", src.icon_hud, "blood0", "EAST-3, NORTH", HUD_LAYER, tooltipTheme = "healthDam healthDam0")
			bleeding.desc = "This indicator warns that you are currently bleeding. You will die if the situation is not remedied."

			stamina = create_screen("stamina","Stamina", src.icon_hud, "stamina", "EAST-1, NORTH", HUD_LAYER, tooltipTheme = "stamina")
			stamina_back = create_screen("stamina_back","Stamina", src.icon_hud, "stamina_back", "EAST-1, NORTH", HUD_LAYER-2)
			if (master?.stamina_bar)
				stamina.desc = master.stamina_bar.getDesc(master)

			bodytemp = create_screen("bodytemp","Temperature", src.icon_hud, "temp0", "EAST-2, NORTH", HUD_LAYER, tooltipTheme = "tempInd tempInd0")
			bodytemp.desc = "The temperature feels fine."

			oxygen = create_screen("oxygen","Suffocation Warning", src.icon_hud, "oxy0", "EAST-4, NORTH", HUD_LAYER, tooltipTheme = "statusOxy")
			oxygen.desc = "This indicator warns that you are currently suffocating. You will take oxygen damage until the situation is remedied."

			fire = create_screen("fire","Fire Warning", src.icon_hud, "fire0", "EAST-5, NORTH", HUD_LAYER, tooltipTheme = "statusFire")
			fire.desc = "This indicator warns that you are either on fire, or too hot. You will take burn damage until the situation is remedied."

			toxin = create_screen("toxin","Toxic Warning",src.icon_hud, "toxin0", "EAST-6, NORTH", HUD_LAYER, tooltipTheme = "statusToxin")
			toxin.desc = "This indicator warns that you are poisoned. You will take toxic damage until the situation is remedied."

			rad = create_screen("rad","Radiation Warning", src.icon_hud, "rad0", "EAST-7, NORTH", HUD_LAYER, tooltipTheme = "statusRad")
			rad.desc = "This indicator warns that you are irradiated. You will take toxic and burn damage until the situation is remedied."

			ability_toggle = create_screen("ability", "Toggle Ability Hotbar", src.icon_hud, "[layouts[layout_style]["ability_icon"]]1", layouts[layout_style]["abiltoggle"], HUD_LAYER)
			stats = create_screen("stats", "Character stats", src.icon_hud, "stats", layouts[layout_style]["stats"], HUD_LAYER,
				tooltipTheme = master?.client?.preferences?.hud_style == "New" ? "newhud" : "item")
			stats.desc = "..."

			legend = create_screen("legend", "Inline Icon Legend", src.icon_hud, "legend", layouts[layout_style]["legend"], HUD_LAYER,
				tooltipTheme = master?.client?.preferences?.hud_style == "New" ? "newhud" : "item")
			legend.desc = "When blocking:"+\
			"<br><img style=\"display:inline;margin:0\" width=\"12\" height=\"12\" /><img style=\"display:inline;margin:0\" src=\"[resource("images/tooltips/cutprot.png")]\" width=\"12\" height=\"12\" /> Increased armor vs cutting attacks"+\
			"<br><img style=\"display:inline;margin:0\" width=\"12\" height=\"12\" /><img style=\"display:inline;margin:0\" src=\"[resource("images/tooltips/stabprot.png")]\" width=\"12\" height=\"12\" /> Increased armor vs stabbing attacks"+\
			"<br><img style=\"display:inline;margin:0\" width=\"12\" height=\"12\" /><img style=\"display:inline;margin:0\" src=\"[resource("images/tooltips/burnprot.png")]\" width=\"12\" height=\"12\" /> Increased armor vs burning attacks"+\
			"<br><img style=\"display:inline;margin:0\" width=\"12\" height=\"12\" /><img style=\"display:inline;margin:0\" src=\"[resource("images/tooltips/bluntprot.png")]\" width=\"12\" height=\"12\" /> Increased armor vs blunt attacks"+\
			"<br><img style=\"display:inline;margin:0\" width=\"12\" height=\"12\" /><img style=\"display:inline;margin:0\" src=\"[resource("images/tooltips/protdisorient.png")]\" width=\"12\" height=\"12\" /> Body Insulation (Disorient Resist): 20%"

			sel = create_screen("sel", "sel", src.icon_hud, "sel", null, HUD_LAYER+1.2)
			sel.mouse_opacity = 0
			default_sel_appearance = new(sel)

			set_visible(twohandl, 0)
			set_visible(twohandr, 0)

			update_hands()
			update_throwing()
			update_intent()
			update_mintent()
			update_pulling()
			update_resting()
			update_sprinting()
			update_indicators()
			update_ability_hotbar()

			master?.update_equipment_screen_loc()

	relay_click(id, mob/user, list/params)
		switch (id)
			if ("invtoggle")
				var/obj/item/I = master.equipped()
				if (I)
					// this doesnt unequip the original item because that'd cause all the items to drop if you swapped your jumpsuit, I expect this to cause problems though
					// ^-- You don't say.
					// you can write multiline macros with \, please god don't write 400 character macros on one line
					#define autoequip_slot(slot, var_name)\
						if (master.can_equip(I, master.slot) && !istype(I.loc, /obj/item/parts) && !(master.var_name && master.var_name.cant_self_remove))\
						{\
							master.u_equip(I);\
							var/obj/item/C = master.var_name;\
							if (C)\
							{\
								/*master.u_equip(C);*/\
								C.unequipped(master);\
								src.remove_item(C);\
								master.var_name = null;\
								if(!master.put_in_hand(C))\
								{\
									master.drop_from_slot(C, get_turf(C))\
								}\
							}\
							master.force_equip(I, master.slot);\
							return\
						}
					autoequip_slot(slot_shoes, shoes)
					autoequip_slot(slot_gloves, gloves)
					autoequip_slot(slot_wear_id, wear_id)
					autoequip_slot(slot_w_uniform, w_uniform)
					autoequip_slot(slot_wear_suit, wear_suit)
					autoequip_slot(slot_glasses, glasses)
					autoequip_slot(slot_ears, ears)
					autoequip_slot(slot_wear_mask, wear_mask)
					autoequip_slot(slot_head, head)
					autoequip_slot(slot_back, back)

					if (!istype(master.belt,/obj/item/storage) || istype(I,/obj/item/storage)) // belt BEFORE trying storages, and only swap if its not a storage swap
						autoequip_slot(slot_belt, belt)
						if (master.equipped() != I)
							return

					for (var/datum/hud/storage/S in user.huds) //ez storage stowing
						S.master.Attackby(I, user, params)
						if (master.equipped() != I)
							return

					//ONLY do these if theyre actually empty, we dont want to pocket swap.
					if (!master.l_store)
						autoequip_slot(slot_l_store, l_store)
					if (!master.r_store)
						autoequip_slot(slot_r_store, r_store)
					#undef autoequip_slot

					return

				show_inventory = !show_inventory
				if (show_inventory)
					for (var/atom/movable/screen/hud/S in inventory_bg)
						src.add_screen(S)
					for (var/obj/O in inventory_items)
						src.add_object(O, HUD_LAYER+2)
					if (layout_style == "tg")
						src.add_screen(legend)
				else
					for (var/atom/movable/screen/hud/S in inventory_bg)
						src.remove_screen(S)
					for (var/obj/O in inventory_items)
						src.remove_object(O)
					if (layout_style == "tg")
						src.remove_screen(legend)

			if ("lhand")
				master.swap_hand(1)

			if ("rhand")
				master.swap_hand(0)

			if ("swaphands")
				master.swap_hand(!master.hand)

			if ("equip")
				var/obj/item/I = master.equipped()
				if (I)
					#define autoequip_slot(slot, var_name) if (master.can_equip(I, master.slot) && !(master.var_name && master.var_name.cant_self_remove)) { master.u_equip(I); var/obj/item/C = master.var_name; if (C) { /*master.u_equip(C);*/ C.unequipped(master); master.var_name = null; if(!master.put_in_hand(C)){master.drop_from_slot(C, get_turf(C))} } master.force_equip(I, master.slot); return }
					autoequip_slot(slot_shoes, shoes)
					autoequip_slot(slot_gloves, gloves)
					autoequip_slot(slot_wear_id, wear_id)
					autoequip_slot(slot_w_uniform, w_uniform)
					autoequip_slot(slot_wear_suit, wear_suit)
					autoequip_slot(slot_glasses, glasses)
					autoequip_slot(slot_ears, ears)
					autoequip_slot(slot_wear_mask, wear_mask)
					autoequip_slot(slot_head, head)
					autoequip_slot(slot_back, back)

					if (!istype(master.belt,/obj/item/storage) || istype(I,/obj/item/storage)) // belt BEFORE trying storages, and only swap if its not a storage swap
						autoequip_slot(slot_belt, belt)
						if (master.equipped() != I)
							return

					for (var/datum/hud/storage/S in user.huds) //ez storage stowing
						S.master.Attackby(I, user, params)
						if (master.equipped() != I)
							return

					//ONLY do these if theyre actually empty, we dont want to pocket swap.
					if (!master.l_store)
						autoequip_slot(slot_l_store, l_store)
					if (!master.r_store)
						autoequip_slot(slot_r_store, r_store)
					#undef autoequip_slot
					return

			if ("throw")
				var/icon_y = text2num(params["icon-y"])
				if (icon_y > 16 || master.in_throw_mode)
					master.toggle_throw_mode()
				else
					master.drop_item(null, TRUE)

			if ("resist")
				master.resist()

			if ("intent")
				var/icon_x = text2num(params["icon-x"])
				var/icon_y = text2num(params["icon-y"])
				if (icon_x > 16)
					if (icon_y > 16)
						master.set_a_intent(INTENT_DISARM)
						master.check_for_intent_trigger()
					else
						master.set_a_intent(INTENT_HARM)
						master.check_for_intent_trigger()
				else
					if (icon_y > 16)
						master.set_a_intent(INTENT_HELP)
						master.check_for_intent_trigger()
					else
						master.set_a_intent(INTENT_GRAB)
						master.check_for_intent_trigger()
				src.update_intent()

			if ("mintent")
				if (master.m_intent == "run")
					master.m_intent = "walk"
				else
					master.m_intent = "run"
				out(master, "You are now [master.m_intent == "walk" ? "walking" : "running"].")
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

			if ("rest")
				if(ON_COOLDOWN(src.master, "toggle_rest", REST_TOGGLE_COOLDOWN)) return
				if(master.ai_active && !master.hasStatus("resting"))
					master.show_text("You feel too restless to do that!", "red")
				else
					master.hasStatus("resting") ? master.delStatus("resting") : master.setStatus("resting", INFINITE_STATUS)
					master.force_laydown_standup()
				src.update_resting()

			if ("sprint")
				//lol
				if (master.client && master.client.tg_controls)
					master.show_text("Hold SPACE to sprint.", "red")
				else
					master.show_text("Hold SHIFT to sprint.", "red")
				//src.update_sprinting()

			if ("ability")
				if(show_genetics_abilities)
					show_genetics_abilities = FALSE
					boutput(master, "No longer showing genetic abilities.")
				else
					show_genetics_abilities = TRUE
					boutput(master, "Now showing genetic abilities.")

				ability_toggle.icon_state = "[layouts[layout_style]["ability_icon"]][show_genetics_abilities]"
				update_ability_hotbar()

			if ("health")
				if (isdead(master))
					out(master, "Seems like you've died. Bummer.")
					return
				var/health_state = ((master.health - master.fakeloss) / master.max_health) * 100
				var/class
				switch(health_state)
					if(100 to INFINITY)
						class = ""
					if(80 to 100)
						class = ""
					if(60 to 80)
						class = "alert"
					if(40 to 60)
						class = "alert"
					if(20 to 40)
						class = "alert bold"
					if(0 to 20)
						class = "alert bold"
					else
						class = "alert bold italic"

				out(master, "<span class='[class]'>[health.desc]</span>")

			if ("bodytemp")
				if(master.getStatusDuration("burning") && !master.is_heat_resistant())
					boutput(master, "<span class='alert bold'>[bodytemp.desc]</span>")
					return

				out(master, bodytemp.desc)

			if ("stamina")
				out(master, "<span class='green'>[stamina.desc]</span>")

			if ("oxygen")
				out(master, "<span class='alert'>[oxygen.desc]</span>")

			if ("fire")
				out(master, "<span class='alert'>[fire.desc]</span>")

			if ("toxin")
				out(master, "<span class='alert'>[toxin.desc]</span>")

			if ("rad")
				out(master, "<span class='alert'>[rad.desc]</span>")

			if ("bleeding")
				out(master, "<span class='alert'>[bleeding.desc]</span>")

			if ("stats")
				src.update_stats()
				out(master, "<span class='alert'>[stats.desc]</span>")

			if ("legend")
				out(master, "<span class='alert'>[legend.desc]</span>")

			if ("tg_butts")
				var/icon_x = text2num(params["icon-x"])
				var/icon_y = text2num(params["icon-y"])
				if (icon_y <= 16)
					if (icon_x < 16)
						master.say_radio()
					else
						master.client << link("https://wiki.ss13.co/Construction")

			#define clicked_slot(slot) var/obj/item/W = master.get_slot(master.slot); if (W) { master.click(W, params); } else { var/obj/item/I = master.equipped(); if (!I || !master.can_equip(I, master.slot) || istype(I.loc, /obj/item/parts/)) { return; } master.u_equip(I); master.force_equip(I, master.slot); }
			if("belt")
				clicked_slot(slot_belt)
			if("storage1")
				clicked_slot(slot_l_store)
			if("storage2")
				clicked_slot(slot_r_store)
			if("back")
				clicked_slot(slot_back)
			if("shoes")
				clicked_slot(slot_shoes)
			if("gloves")
				clicked_slot(slot_gloves)
			if("id")
				clicked_slot(slot_wear_id)
			if("under")
				clicked_slot(slot_w_uniform)
			if("suit")
				clicked_slot(slot_wear_suit)
			if("glasses")
				clicked_slot(slot_glasses)
			if("ears")
				clicked_slot(slot_ears)
			if("mask")
				clicked_slot(slot_wear_mask)
			if("head")
				clicked_slot(slot_head)
			#undef clicked_slot

	MouseEntered(var/atom/movable/screen/hud/H, location, control, params)
		if (!H || usr != src.master) return
		var/obj/item/W = null
		var/obj/item/I

		#define entered_slot(slot) W = master.get_slot(master.slot); if (W) { W.MouseEntered(location,control,params); }
		#define test_slot(slot) if (!W) { I = master.equipped(); if (I && !master.can_equip(I, master.slot)) { I = null; } if (I && sel) { sel.screen_loc = H.screen_loc; } }

		switch(H.id)
			if("belt")
				entered_slot(slot_belt)
				test_slot(slot_belt)
			if("storage1")
				entered_slot(slot_l_store)
				test_slot(slot_l_store)
			if("storage2")
				entered_slot(slot_r_store)
				test_slot(slot_r_store)
			if("back") //mousing over the bag to trigger a sel outline is handled in small_storage_parent.dm off of the storage hud so we dont have to do typechecks
				entered_slot(slot_back)
				test_slot(slot_back)
			if("shoes")
				entered_slot(slot_shoes)
				test_slot(slot_shoes)
			if("gloves")
				entered_slot(slot_gloves)
				test_slot(slot_gloves)
			if("id")
				entered_slot(slot_wear_id)
				test_slot(slot_wear_id)
			if("under")
				entered_slot(slot_w_uniform)
				test_slot(slot_w_uniform)
			if("suit")
				entered_slot(slot_wear_suit)
				test_slot(slot_wear_suit)
			if("glasses")
				entered_slot(slot_glasses)
				test_slot(slot_glasses)
			if("ears")
				entered_slot(slot_ears)
				test_slot(slot_ears)
			if("mask")
				entered_slot(slot_wear_mask)
				test_slot(slot_wear_mask)
			if("head")
				entered_slot(slot_head)
				test_slot(slot_head)
			if ("lhand")
				entered_slot(slot_l_hand)
			if ("rhand")
				entered_slot(slot_r_hand)
			if ("intent")
				switch (master.a_intent)
					if (INTENT_DISARM)
						sel.icon_state = "intent-sel-disarm"
					if (INTENT_HARM)
						sel.icon_state = "intent-sel-harm"
					if (INTENT_HELP)
						sel.icon_state = "intent-sel-help"
					if (INTENT_GRAB)
						sel.icon_state = "intent-sel-grab"
				sel.screen_loc = H.screen_loc

			if ("throw")
				if (master.in_throw_mode)
					sel.icon_state = "throw1_over"
				else
					sel.icon_state = "throw0_over"
				sel.screen_loc = H.screen_loc

		#undef entered_slot
		#undef test_slot

	MouseExited(atom/movable/screen/hud/H)
		if (!H || usr != src.master) return
		if (sel)
			sel.screen_loc = null
			if (sel.icon_state != sel)
				//sel.icon_state = "sel"
				sel.appearance = default_sel_appearance

	MouseDrop(atom/movable/screen/hud/H, atom/over_object, src_location, over_location, over_control, params)
		if (!H) return
		var/obj/item/W = null
		#define mdrop_slot(slot) W = master.get_slot(master.slot); if (W) { W.MouseDrop(over_object, src_location, over_location, over_control, params); }
		switch(H.id)
			if("belt")
				mdrop_slot(slot_belt)
			if("storage1")
				mdrop_slot(slot_l_store)
			if("storage2")
				mdrop_slot(slot_r_store)
			if("back")
				mdrop_slot(slot_back)
			if("shoes")
				mdrop_slot(slot_shoes)
			if("gloves")
				mdrop_slot(slot_gloves)
			if("id")
				mdrop_slot(slot_wear_id)
			if("under")
				mdrop_slot(slot_w_uniform)
			if("suit")
				mdrop_slot(slot_wear_suit)
			if("glasses")
				mdrop_slot(slot_glasses)
			if("ears")
				mdrop_slot(slot_ears)
			if("mask")
				mdrop_slot(slot_wear_mask)
			if("head")
				mdrop_slot(slot_head)
			if ("lhand")
				mdrop_slot(slot_l_hand)
			if ("rhand")
				mdrop_slot(slot_r_hand)
		#undef mdrop_slot

	MouseDrop_T(atom/movable/screen/hud/H, atom/movable/O as obj, mob/user as mob)
		if (!H) return
		var/obj/item/W = null
		#define mdrop_slot(slot) W = master.get_slot(master.slot); if (W) { W._MouseDrop_T(O,user); }
		switch(H.id)
			if("belt")
				mdrop_slot(slot_belt)
			if("storage1")
				mdrop_slot(slot_l_store)
			if("storage2")
				mdrop_slot(slot_r_store)
			if("back")
				mdrop_slot(slot_back)
			if("shoes")
				mdrop_slot(slot_shoes)
			if("gloves")
				mdrop_slot(slot_gloves)
			if("id")
				mdrop_slot(slot_wear_id)
			if("under")
				mdrop_slot(slot_w_uniform)
			if("suit")
				mdrop_slot(slot_wear_suit)
			if("glasses")
				mdrop_slot(slot_glasses)
			if("ears")
				mdrop_slot(slot_ears)
			if("mask")
				mdrop_slot(slot_wear_mask)
			if("head")
				mdrop_slot(slot_head)
			if ("lhand")
				mdrop_slot(slot_l_hand)
			if ("rhand")
				mdrop_slot(slot_r_hand)
		#undef mdrop_slot

	proc/add_other_object(obj/item/I, loc) // this is stupid but necessary

		var/hide = 0 //hide from layotu based on the ignore_inventory_hide thingo
		for (var/atom/movable/screen/hud/H in inventory_bg)
			if (loc == H.screen_loc)
				hide = 1

		if (hide)
			inventory_items += I

		if (show_inventory || !hide)
			src.add_object(I, HUD_LAYER+2, loc)
		else
			I.screen_loc = loc

	proc/remove_item(obj/item/I)
		if (length(inventory_items))
			inventory_items -= I
		remove_object(I)

	proc/update_hands()
		if (master.limbs && !master.limbs.l_arm)
			lhand.icon_state = "handl[master.hand]d"
		else
			lhand.icon_state = "handl[master.hand]"

		if (master.limbs && !master.limbs.r_arm)
			rhand.icon_state = "handr[!master.hand]d"
		else
			rhand.icon_state = "handr[!master.hand]"

	proc/update_stats()
		var/newDesc = ""
		newDesc += "<div><img src='[resource("images/tooltips/heat.png")]' alt='' class='icon' /><span>Total Resistance (Heat): [master.get_heat_protection()]%</span></div>"
		newDesc += "<div><img src='[resource("images/tooltips/cold.png")]' alt='' class='icon' /><span>Total Resistance (Cold): [master.get_cold_protection()]%</span></div>"
		newDesc += "<div><img src='[resource("images/tooltips/radiation.png")]' alt='' class='icon' /><span>Total Resistance (Radiation): [master.get_rad_protection() * 100]%</span></div>"
		newDesc += "<div><img src='[resource("images/tooltips/disease.png")]' alt='' class='icon' /><span>Total Resistance (Disease): [master.get_disease_protection()]%</span></div>"
		newDesc += "<div><img src='[resource("images/tooltips/chemical.png")]' alt='' class='icon' /><span>Total Resistance (Chemical): [master.get_chem_protection()]%</span></div>"
		newDesc += "<div><img src='[resource("images/tooltips/explosion.png")]' alt='' class='icon' /><span>Total Resistance (Explosion): [master.get_explosion_resistance() * 100]%</span></div>"
		newDesc += "<div><img src='[resource("images/tooltips/bullet.png")]' alt='' class='icon' /><span>Total Ranged Protection: [master.get_ranged_protection()]</span></div>"
		newDesc += "<div><img src='[resource("images/tooltips/melee.png")]' alt='' class='icon' /><span>Total Melee Armor (Body): [master.get_melee_protection("chest")]</span></div>"
		newDesc += "<div><img src='[resource("images/tooltips/melee.png")]' alt='' class='icon' /><span>Total Melee Armor (Head): [master.get_melee_protection("head")]</span></div>"

		var/block = master.get_passive_block()
		if (block)
			newDesc += "<div><img src='[resource("images/tooltips/block.png")]' alt='' class='icon' /><span>Passive Block: [block]%</span></div>"

		var/prot = master.get_disorient_protection()
		var/disorientprot = 0
		if (prot >= 90)
			disorientprot = "[prot]% (MAX)"
		else
			disorientprot = "[prot]%"
		newDesc += "<div><img src='[resource("images/tooltips/protdisorient.png")]' alt='' class='icon' /><span>Total Resistance (Body Disorient): [disorientprot]</span></div>"

		prot = master.get_disorient_protection_eye()
		newDesc += "<div><img src='[resource("images/tooltips/protdisorient_eye.png")]' alt='' class='icon' /><span>Total Resistance (Eye Disorient): [prot]%</span></div>"

		prot = master.get_disorient_protection_ear()
		newDesc += "<div><img src='[resource("images/tooltips/protdisorient_ear.png")]' alt='' class='icon' /><span>Total Resistance (Ear Disorient): [prot]%</span></div>"

		newDesc += "<div><img src='[resource("images/tooltips/stun.png")]' alt='' class='icon' /><span>Total Resistance (Stuns): [master.get_stun_resist_mod()]%</span></div>"


		//newDesc += "<div><img src='[resource("images/tooltips/food.png")]' alt='' class='icon' /><span> Bonus: [master.get_food_bonus()]</span></div>"
		stats.desc = newDesc

	proc/update_throwing()
		if (!throwing) return 0
		throwing.icon_state = "throw[master.in_throw_mode]"
		if (sel.screen_loc == throwing.screen_loc)
			sel.icon_state = "[throwing.icon_state]_over"

	proc/update_intent()
		if (!intent) return 0
		intent.icon_state = "intent-[master.a_intent]"
		if (sel.screen_loc == intent.screen_loc)
			sel.icon_state = "intent-sel-[master.a_intent]"

	proc/update_mintent()
		if (!mintent) return 0
		mintent.icon_state = "move-[master.m_intent]"

	proc/update_pulling()
		if (!pulling) return 0
		pulling.icon_state = "pull[!!master.pulling]"

	proc/update_resting()
		if (!resting) return 0
		resting.icon_state = "rest[master.hasStatus("resting") ? 1 : 0]"

	proc/update_ability_hotbar()
		if (!master || !master.client)
			return
		if(isdead(master))
			return

		// remove genetics buttons
		for(var/atom/movable/screen/ability/topBar/genetics/G in src.objects)
			remove_object(G)
		for(var/atom/movable/screen/pseudo_overlay/PO in master.client.screen)
			master.client.screen -= PO
		for(var/obj/ability_button/B in master.client.screen)
			master.client.screen -= B
		var/pos_x = 1
		var/pos_y = 0

		if (master.abilityHolder) //abilities come first. no overlap from the upcoming buttons!
			master.abilityHolder.updateButtons()
			if (master.abilityHolder.any_abilities_displayed)
				pos_y = master.abilityHolder.y_occupied + 1

		// always show regular abilities
		for(var/obj/ability_button/B2 in master.item_abilities)
			B2.screen_loc = "NORTH-[pos_y],[pos_x]"
			master.client.screen += B2
			pos_x++
			if(pos_x > 15)
				pos_x = 1
				pos_y++

		// if toggled off, do not show genetics abilities
		if (show_genetics_abilities)
			var/datum/bioEffect/power/P
			for(var/ID in master.bioHolder.effects)
				P = master.bioHolder.GetEffect(ID)
				if (!istype(P, /datum/bioEffect/power/) || !istype(P.ability) || !istype(P.ability.object) || P.removed)
					continue
				var/datum/targetable/geneticsAbility/POWER = P.ability
				var/atom/movable/screen/ability/topBar/genetics/BUTTON = POWER.object
				BUTTON.update_on_hud(pos_x,pos_y)

				pos_x++
				if(pos_x > 15)
					pos_x = 1
					pos_y++

		if (istype(master.loc,/obj/vehicle/)) //so we always see vehicle buttons
			var/obj/vehicle/V = master.loc
			for(var/obj/ability_button/B2 in V.ability_buttons)
				B2.screen_loc = "NORTH-[pos_y],[pos_x]"
				master.client.screen += B2
				B2.the_mob = master
				pos_x++
				if(pos_x > 15)
					pos_x = 1
					pos_y++


	proc/update_sprinting()
		if (!sprinting || !master.client) return 0
		sprinting.icon_state = "sprint[master.client.check_key(KEY_RUN)]"

	proc/update_indicators()
		update_health_indicator()
		update_blood_indicator()
		update_temp_indicator()

	proc/update_health_indicator()
		if (!health)
			return

		var/stage = 0
		if (master?.mini_health_hud)
			health.icon_state = "blank"
			if (isdead(master) || master.fakedead)
				health_brute.icon_state = "mhealth7" // rip
				health_brute.tooltipTheme = "healthDam healthDam7"
				health_brute.name = "Health"
				health_brute.desc = "Seems like you've died. Bummer."
				health_burn.icon_state = "blank"
				health_tox.icon_state = "blank"
				health_oxy.icon_state = "blank"
				return

			var/brutedam = master.get_brute_damage()
			var/burndam = master.get_burn_damage()
			var/toxdam = master.get_toxin_damage()
			var/oxydam = master.get_oxygen_deprivation()

			switch (brutedam)
				if (-INFINITY to 0) // this goes the other way around from the normal health indicator since it's determined by how much of whatever damage you have
					stage = 0 // bright green
				if (0 to 15)
					stage = 1 // green
				if (15 to 30)
					stage = 2 // yellow
				if (30 to 45)
					stage = 3 // orange
				if (45 to 60)
					stage = 4 // dark orange
				if (60 to 75)
					stage = 5 // red
				if (75 to INFINITY)
					stage = 6 // crit

			health_brute.name = "Brute Damage"
			health_brute.icon_state = "mbrute[stage]"
			health_brute.tooltipTheme = "healthDam healthDam[stage]"

			switch (burndam)
				if (-INFINITY to 0)
					stage = 0 // bright green
				if (0 to 15)
					stage = 1 // green
				if (15 to 30)
					stage = 2 // yellow
				if (30 to 45)
					stage = 3 // orange
				if (45 to 60)
					stage = 4 // dark orange
				if (60 to 75)
					stage = 5 // red
				if (75 to INFINITY)
					stage = 6 // crit

			health_burn.name = "Burn Damage"
			health_burn.icon_state = "mburn[stage]"
			health_burn.tooltipTheme = "healthDam healthDam[stage]"

			switch (toxdam)
				if (-INFINITY to 0)
					stage = 0 // bright green
				if (0 to 15)
					stage = 1 // green
				if (15 to 30)
					stage = 2 // yellow
				if (30 to 45)
					stage = 3 // orange
				if (45 to 60)
					stage = 4 // dark orange
				if (60 to 75)
					stage = 5 // red
				if (75 to INFINITY)
					stage = 6 // crit

			health_tox.name = "Toxin Damage"
			health_tox.icon_state = "mtox[stage]"
			health_tox.tooltipTheme = "healthDam healthDam[stage]"

			switch (oxydam)
				if (-INFINITY to 0)
					stage = 0 // bright green
				if (0 to 15)
					stage = 1 // green
				if (15 to 30)
					stage = 2 // yellow
				if (30 to 45)
					stage = 3 // orange
				if (45 to 60)
					stage = 4 // dark orange
				if (60 to 75)
					stage = 5 // red
				if (75 to INFINITY)
					stage = 6 // crit

			health_oxy.name = "Oxygen Damage"
			health_oxy.icon_state = "moxy[stage]"
			health_oxy.tooltipTheme = "healthDam healthDam[stage]"

			// may as well let you see you're being irradiated if you can already see individual things like oxy/tox/burn/brute
			//update_rad_indicator(master.radiation ? 1 : 0)

			return

		else
			health_brute.icon_state = "blank"
			health_burn.icon_state = "blank"
			health_tox.icon_state = "blank"
			health_oxy.icon_state = "blank"
			update_rad_indicator(0)

			if (isdead(master) || master.fakedead)
				health.icon_state = "health7" // dead
				health.tooltipTheme = "healthDam healthDam7"
				health.desc = "Seems like you've died. Bummer."
				return

			var/health_state = ((master.health - master.fakeloss) / (master.max_health != 0 ? master.max_health : 1)) * 100
			switch(health_state)
				if(100 to INFINITY)
					stage = 0 // green with green marker
					health.desc = "You feel fine."
				if(80 to 100)
					stage = 1 // green
					health.desc = "You feel a little dinged up, but you're doing okay."
				if(60 to 80)
					stage = 2 // yellow
					health.desc = "You feel a bit hurt. Seeking medical attention couldn't hurt."
				if(40 to 60)
					stage = 3 // orange
					health.desc = "You feel pretty bad. You should seek medical attention."
				if(20 to 40)
					stage = 4 // dark orange
					health.desc = "You feel horrible! You need medical attention as soon as possible."
				if(0 to 20)
					stage = 5 // red
					health.desc = "You feel like you're on death's door... you need help <em>now!</em>"
				else
					stage = 6 // crit
					health.desc = "You're pretty sure you're dying!"

			health.icon_state = "health[stage]"
			health.tooltipTheme = "healthDam healthDam[stage]"

	proc/update_blood_indicator()
		if (!src.bleeding) return //doesn't have a hud element to update
		if (isdead(master))
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

	proc/update_oxy_indicator(var/status)
		if (!oxygen)
			return
		oxygen.icon_state = "oxy[status]"

	proc/update_fire_indicator(var/status)
		if (!fire)
			return
		fire.icon_state = "fire[status]"

	proc/update_rad_indicator(var/status)
		if (!rad) // not rad :'(
			return
		rad.icon_state = "rad[status]"

	proc/change_hud_style(var/icon/new_file)
		if (new_file)
			src.icon_hud = new_file

			for(var/atom/movable/screen/statusEffect/G in master.client.screen)
				G.icon = new_file

			if (invtoggle) invtoggle.icon = new_file
			if (belt) belt.icon = new_file
			if (storage1) storage1.icon = new_file
			if (storage2) storage2.icon = new_file
			if (back) back.icon = new_file
			if (lhand) lhand.icon = new_file
			if (rhand) rhand.icon = new_file
			if (throwing) throwing.icon = new_file
			if (intent) intent.icon = new_file
			if (mintent) mintent.icon = new_file
			if (resist) resist.icon = new_file
			if (pulling) pulling.icon = new_file
			if (resting) resting.icon = new_file
			if (sprinting) sprinting.icon = new_file

			if (health) health.icon = new_file
			if (bleeding) bleeding.icon = new_file
			if (stamina) stamina.icon = new_file
			if (stamina_back) stamina_back.icon = new_file
			if (bodytemp) bodytemp.icon = new_file
			if (oxygen) oxygen.icon = new_file
			if (fire) fire.icon = new_file
			if (toxin) toxin.icon = new_file
			if (rad) rad.icon = new_file
			if (ability_toggle) ability_toggle.icon = new_file

			if (health_brute) health_brute.icon = new_file
			if (health_burn) health_burn.icon = new_file
			if (health_tox) health_tox.icon = new_file
			if (health_oxy) health_oxy.icon = new_file

			for (var/atom/movable/screen/hud/H in inventory_bg)
				H.icon = new_file

			if (master.stamina_bar)
				master.stamina_bar.icon = new_file

	proc/set_sprint(var/on)
		if(stamina)
			stamina.icon_state = on ? "stamina_sprint" : "stamina"







//item moused over events

/mob/proc/moused_over(var/obj/item/I)
	.=0

/mob/proc/moused_exit(var/obj/item/I)
	.=0

/mob/living/carbon/human
	updateStatusUi()
		if(src.hud && istype(src.hud, /datum/hud/human))
			var/datum/hud/human/H = src.hud
			H.update_status_effects()
		return

	moused_over(var/obj/item/I)
		if (src.client && src.client.hand_ghosts)
			if (!src.equipped() && !I.anchored && src.hud?.sel && I != src.back && can_reach(src, I))
				if (I.two_handed)
					src.hud.sel.screen_loc = "[src.hud.lhand.screen_loc] to [src.hud.rhand.screen_loc]"
				else
					if (src.hand)
						src.hud.sel.screen_loc = src.hud.lhand.screen_loc
					else
						src.hud.sel.screen_loc = src.hud.rhand.screen_loc

				src.hud.sel.icon = I.icon
				src.hud.sel.icon_state = I.icon_state
				src.hud.sel.alpha = 120
				src.hud.sel.filters += filter(type = "outline")

	moused_exit(var/obj/item/I)
		if (src.client && src.client.hand_ghosts)
			if (src.hud?.sel?.screen_loc)
				src.hud.sel.screen_loc = null
				////src.hud.sel.icon = src.hud.icon_hud
				//src.hud.sel.icon_state = "sel"
				//src.hud.alpha = 255
				src.hud.sel.appearance = src.hud.default_sel_appearance
				src.hud.sel.filters = null
