/obj/machinery/lawrack
	name = "AI Law Mount Rack"
	icon = 'icons/obj/large/32x48.dmi'
	icon_state = "airack_empty"
	desc = "A large electronics rack that can contain AI Law Circuits, to modify the behaivor of connected AIs."
	density = 1
	anchored = 1
	mats = list("MET-1" = 20, "MET-2" = 5, "INS-1" = 10, "CON-1" = 10) //this bitch should be expensive
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WELDER | DECON_WIRECUTTERS | DECON_MULTITOOL | DECON_WRENCH | DECON_NOBORG
	layer = EFFECTS_LAYER_UNDER_1 //high layer, same as trees which are also tall as shit
	///unique id for logs - please don't ever assign except in ai_law_rack_manager.register
	var/unique_id = "OMG THIS WASN'T SET OH NO THIS SHOULD NEVER HAPPEN AHHH"
	var/datum/light/light
	var/const/MAX_CIRCUITS = 9
	/// list of aiModules ref'd by slot number.
	var/obj/item/aiModule/law_circuits[MAX_CIRCUITS]
	/// used during UpdateLaws to determine which laws have changed
	var/list/last_laws[MAX_CIRCUITS]
	/// welded status of law module by slot number
	var/list/welded[MAX_CIRCUITS]
	/// screwed status of law module by slot number
	var/list/screwed[MAX_CIRCUITS]
	/// list of hologram expansions
	var/list/holo_expansions = list()

	New(loc)
		START_TRACKING
		. = ..()
		//if the ticker isn't initialised yet, it'll grab this rack when it is (see /datum/ai_rack_manager)
		ticker?.ai_law_rack_manager.register_new_rack(src)

		src.light = new/datum/light/point
		src.light.set_brightness(0.4)
		src.light.attach(src)
		UpdateIcon()
		update_last_laws()

	/// Causes all law modules to drop to the ground, does not call UpdateLaws()
	proc/drop_all_modules()
		for (var/i in 1 to MAX_CIRCUITS)
			src.welded[i] = false
			src.screwed[i] = false
			if(src.law_circuits[i])
				src.law_circuits[i].set_loc(get_turf(src))
				src.law_circuits[i] = null

	disposing()
		STOP_TRACKING
		ticker?.ai_law_rack_manager.unregister_rack(src)
		src.drop_all_modules()
		UpdateIcon()
		. = ..()

	was_deconstructed_to_frame(mob/user)
		logTheThing("station", user, null, "<b>deconstructed</b> rack [constructName(src)]")
		ticker?.ai_law_rack_manager.unregister_rack(src)
		src.drop_all_modules()
		UpdateIcon()
		. = ..()


	was_built_from_frame(mob/user, newly_built)
		if(isrestrictedz(src.z) || !issimulatedturf(src.loc))
			boutput(user, "Something about this area prevents you from constructing the [src]!")
			logTheThing("station", user, null, "tried to construct a [src] in restricted area [log_loc(src)]")
			var/obj/item/electronics/frame/F = new
			var/turf/target_loc = get_turf(src.loc)
			F.name = "[src.name] frame"
			F.deconstructed_thing = src
			src.set_loc(F)
			F.set_loc(target_loc)
			F.viewstat = 2
			F.secured = 2
			F.icon_state = "dbox_big"
			F.w_class = W_CLASS_BULKY
			src.was_deconstructed_to_frame(user)
			return
		//this should always be hard to deconstruct, even if player built
		src.deconstruct_flags = initial(src.deconstruct_flags)
		ticker?.ai_law_rack_manager.register_new_rack(src)
		logTheThing("station", user, null, "constructed a new rack [constructName(src)] from frame")
		. = ..()

	changeHealth(change,var/causer=null) //override so I can pass causer down the chain. Gross.
		var/prevHealth = _health
		_health += change
		_health = min(_health, _max_health)
		updateHealth(prevHealth,causer)


	updateHealth(var/prevHealth, var/causer = null)
		if(!causer)
			causer = "Unknown"

		if(_health <= 0)
			logTheThing("station", causer, null, "[causer] <b>destroyed</b> the [constructName(src)] causing a law update")
			src.visible_message("<span class='alert'><b>The [src] collapses completely!</b></span>")
			playsound(src.loc, "sound/impact_sounds/Machinery_Break_1.ogg", 50, 1)
			for(var/turf/T in range(src,0))
				make_cleanable(/obj/decal/cleanable/machine_debris, T)
			qdel(src)
			return
		var/law_update_needed = FALSE

		if(_health <= 75 && prevHealth > 75)
			//partially damaged - make a module glitch
			if(prob(50))
				src.cause_law_glitch(phrase_log.random_custom_ai_law(),rand(1,9),FALSE)
				playsound(src, "sound/effects/sparks6.ogg", 50)
				law_update_needed = TRUE
		if(_health <= 50 && prevHealth > 50)
			//more than half damaged, spit out a module or cause a severe glitch
			if(prob(50))
				src.cause_law_glitch(phrase_log.random_custom_ai_law(),rand(1,9),TRUE)
				playsound(src, "sound/effects/sparks4.ogg", 50)
				law_update_needed = TRUE
			else
				var/list/mod_index_list = list()
				for (var/i in 1 to MAX_CIRCUITS)
					if(src.law_circuits[i])
						mod_index_list += i
				if(length(mod_index_list) > 0)
					var/i = pick(mod_index_list)
					src.welded[i] = false
					src.screwed[i] = false
					src.law_circuits[i].set_loc(get_turf(src))
					src.law_circuits[i] = null
					src.visible_message("<span class='alert'><b>A module tumbles out of the [src]!</b></span>")
					playsound(src.loc, "sound/impact_sounds/Metal_Hit_Light_1.ogg", 50, 1)
					law_update_needed = TRUE
		if(_health <= 25 && prevHealth > 25)
			//severely damaged - we're basically falling apart here
			//break all the welds and screws, eject half of remaining modules
			for (var/i in 1 to MAX_CIRCUITS)
				src.welded[i] = false
				src.screwed[i] = false
				if(src.law_circuits[i] && prob(50))
					src.law_circuits[i].set_loc(get_turf(src))
					src.law_circuits[i] = null
					law_update_needed = TRUE
			playsound(src.loc, "sound/impact_sounds/Generic_Hit_Heavy_1.ogg", 50, 1)
			src.visible_message("<span class='alert'><b>Some of the [src]'s shelves collapse!</b></span>")

		if(law_update_needed)
			logTheThing("station", causer, null, "[causer] damaged the [constructName(src)] causing a law update")
			UpdateIcon()
			UpdateLaws()




		//handle particles
		if(_health <= 75)
			if(!src.GetParticles("rack_spark"))
				playsound(src, "sound/effects/electric_shock_short.ogg", 50)
				src.UpdateParticles(new/particles/rack_spark,"rack_spark")
				src.visible_message("<span class='alert'><b>The [src] starts sparking!</b></span>")
		else if(prevHealth <= 75)
			src.visible_message("<span class='alert'><b>The [src] stops sparking.</b></span>")
			src.ClearSpecificParticles("rack_spark")

		if(_health <= 50)
			if(!src.GetParticles("rack_smoke"))
				src.UpdateParticles(new/particles/rack_smoke,"rack_smoke")
				src.visible_message("<span class='alert'><b>The [src] begins to smoke!</b></span>")
		else if(prevHealth <= 50)
			src.visible_message("<span class='alert'><b>The [src] stops smoking.</b></span>")
			src.ClearSpecificParticles("rack_smoke")

	examine(mob/user)
		. = ..()
		if(issilicon(user) || isAI(user))
			var/mob/living/silicon/S = user
			var/test_connection = null
			if(isAIeye(user) || S.dependent)
				test_connection = S.mainframe.law_rack_connection
			else
				test_connection = S.law_rack_connection

			if(test_connection == src)
				. += "<b>You are connected to this law rack.<b>"
			else
				. += "You are not connected to this law rack."
		if(src._health == src._max_health)
			. += "It is operating normally."
		else if (src._health > src._max_health*0.9)
			. += "It looks a little dinged."
		else if (src._health > src._max_health*0.75)
			. += "It looks a bit battered."
		else if (src._health > src._max_health*0.5)
			. += "It's sparking oddly. It looks badly damaged."
		else if (src._health > src._max_health*0.25)
			. += "It's very badly damaged. Is it on fire?!"
		else if (src._health > src._max_health*0.1)
			. += "It's almost falling apart!"
		else
			. += "It's about to collapse!"

	blob_act(power)
		changeHealth(-power*0.15,"blob")

	ex_act(severity)
		src.material?.triggerExp(src, severity)
		switch(severity)
			if(1.0)
				changeHealth(rand(-105,-90),"explosion severity [severity]")
				return
			if(2.0)
				changeHealth(rand(-80,-50),"explosion severity [severity]")
				return
			if(3.0)
				changeHealth(rand(-30,-10),"explosion severity [severity]")
				return

	bullet_act(obj/projectile/P)
		var/damage = 0

		damage = round((0.15*P.power*P.proj_data.ks_ratio), 1.0)
		damage = damage - min(damage,3) //bullet resist
		if (damage < 1 || istype(P.proj_data,/datum/projectile/laser/heavy/law_safe))
			if(!P.proj_data.silentshot)
				src.visible_message("<span class='alert'>[src] is hit by the [P] but it deflects harmlessly.</span>")
			return

		if (src.material)
			src.material.triggerOnBullet(src, src, P)

		switch (P.proj_data.damage_type)
			if (D_KINETIC)
				changeHealth(-damage,P.shooter)
			if (D_PIERCING)
				changeHealth(-damage*1.25,P.shooter)
			if (D_SLASHING)
				changeHealth(-damage*0.75,P.shooter)
			if (D_BURNING)
				changeHealth(-damage*0.5,P.shooter)
			if (D_ENERGY)
				changeHealth(-damage*0.75,P.shooter)

		if(!P.proj_data.silentshot)
			src.visible_message("<span class='alert'>[src] is hit by the [P]!</span>")

	update_icon()
		var/image/circuit_image = null
		var/image/color_overlay = null
		for (var/i in 1 to MAX_CIRCUITS)
			circuit_image = null
			color_overlay = null
			if(law_circuits[i])
				circuit_image = image(src.icon, "aimod")
				circuit_image.pixel_x = 0
				circuit_image.pixel_y = -36 + i*4
				circuit_image.color = law_circuits[i].color
				color_overlay = image(src.icon, "aimod_over")
				color_overlay.color = law_circuits[i].highlight_color
				color_overlay.pixel_x = 0
				color_overlay.pixel_y = -36 + i*4
			src.UpdateOverlays(circuit_image,"module_slot_[i]")
			src.UpdateOverlays(color_overlay,"module_slot_[i]_overlay")

	attack_hand(mob/user as mob)
		if (!src.law_circuits)
			// YOU BETRAYED THE LAW!!!!!!
			boutput(user, "<span class='alert'>Oh dear, this really shouldn't happen. Call an admin.</span>")
			return

		if(issilicon(user) || isAI(user))
			var/mob/living/silicon/S = user
			var/test_connection = null
			if(isAIeye(user) || S.dependent)
				test_connection = S.mainframe.law_rack_connection
			else
				test_connection = S.law_rack_connection

			if(test_connection == src)
				boutput(user,"<b>You are connected to this law rack.<b>")
			else
				boutput(user,"You are not connected to this law rack.")

		boutput(user,"<b>This rack's laws are:</b>")
		src.show_laws(user)
		return ..()


	attackby(obj/item/I as obj, mob/user as mob)
		if(isweldingtool(I))
			if(I:try_weld(user,1))
				if(src._health < src._max_health)
					src.changeHealth(10)
					boutput(user,"You repair some of the damage to the rack.")
				else
					boutput(user,"There's no damage to repair!")
			return
		else if (istype(I,/obj/item/device/borg_linker) && !issilicon(user))
			var/obj/item/device/borg_linker/linker = I
			linker.linked_rack = src
			var/area/A = get_area(src.loc)
			boutput(user,"Linker: Linked to law rack at "+ A.name)
			return
		else if (istype(I, /obj/item/aiModule) && !issilicon(user))
			var/obj/item/aiModule/AIM = I
			var/inserted = false
			var/count = 1
			while (!inserted && count <= MAX_CIRCUITS)
				if(!src.law_circuits[count])
					inserted = true
				else
					count++
			if(!inserted)
				boutput(user,"<span class='alert'>There's no more space on the rack!</span>")
			else
				SETUP_GENERIC_ACTIONBAR(user, src, 5 SECONDS, .proc/insert_module_callback, list(count,user,AIM), user.equipped().icon, user.equipped().icon_state, \
					"", INTERRUPT_ACTION | INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ACT)
		else if (istype(I, /obj/item/clothing/mask/moustache/))
			for_by_tcl(M, /mob/living/silicon/ai)
				if(M.law_rack_connection == src)
					M.moustache_mode = 1
					user.visible_message("<span class='alert'><b>[user.name]</b> uploads a moustache to [M.name]!</span>")
					M.update_appearance()
		else if (istype(I, /obj/item/peripheral/videocard))
			var/obj/item/peripheral/videocard/V = I
			if (GET_COOLDOWN(src, "mine_cooldown") == 0)
				SETUP_GENERIC_ACTIONBAR(user, src, 5 SECONDS, .proc/insert_videocard_callback, list(user,V), user.equipped().icon, user.equipped().icon_state, \
						"", INTERRUPT_ACTION | INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ACT)
			else
				user.visible_message("<span class='alert'>The [src]'s graphics port isn't ready to accept [I] yet.</span>")
		else
			return ..()

	attack_ai(mob/user as mob)
		return src.Attackhand(user)


	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if(!ui)
			ui = new(user, src, "AIRack", src.name)
			ui.open()

	ui_static_data(mob/user)
		. = list(
			"lawSlots" = MAX_CIRCUITS
		)

	ui_data(mob/user)
		var/list/lawTitles[MAX_CIRCUITS]
		var/list/lawText[MAX_CIRCUITS]
		for (var/i in 1 to MAX_CIRCUITS)
			if(law_circuits[i])
				lawText[i] = law_circuits[i].get_law_text()
				lawTitles[i] = law_circuits[i].get_law_name()
			else
				src.welded[i] = false
				src.screwed[i] = false

		. = list(
			"lawTitles" = lawTitles,
			"lawText" = lawText,
			"welded" = src.welded,
			"screwed" = src.screwed
		)

	ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
		. = ..()
		if (.)
			return

		if(isintangible(ui.user) || isdead(ui.user) || isunconscious(ui.user) || ui.user.hasStatus("resting"))
			return

		var/slotNum = text2num(params["rack_index"])
		switch(action)
			if("weld")
				if(!in_interact_range(src, ui.user))
					return

				if (!ui.user.equipped() || !isweldingtool(ui.user.equipped()))
					boutput(ui.user,"You need a welding tool for that!")
					return

				if(!law_circuits[slotNum])
					boutput(ui.user,"There's nothing to weld!")
					return

				var/obj/item/weldingtool/equipped = ui.user.equipped()
				if(!equipped:try_weld(ui.user, 1, burn_eyes = 1, noisy = 2))
					return
				else
					if(welded[slotNum])
						ui.user.visible_message("<span class='alert'>[ui.user] starts cutting the welds on a module!</span>", "<span class='alert'>You start cutting the welds on the module!</span>")
					else
						ui.user.visible_message("<span class='alert'>[ui.user] starts welding a module in place!</span>", "<span class='alert'>You start to weld the module in place!</span>")
					var/positions = src.get_welding_positions(slotNum)
					playsound(src.loc, "sound/items/Welder.ogg", 50, 1)
					actions.start(new /datum/action/bar/private/welding(ui.user, src, 5 SECONDS, .proc/toggle_welded_callback, list(slotNum,ui.user), \
			  		"",	positions[1], positions[2]), ui.user)

				return
			if("screw")
				if(!in_interact_range(src, ui.user))
					return
				if (!ui.user.equipped() || !isscrewingtool(ui.user.equipped()))
					boutput(ui.user,"You need a screwdriver for that!")
					return

				if(!law_circuits[slotNum])
					boutput(ui.user,"There's nothing to screw in!")
					return

				if(screwed[slotNum])
					ui.user.visible_message("<span class='alert'>[ui.user] starts unscrewing a module!</span>", "<span class='alert'>You start unscrewing the module!</span>")
				else
					ui.user.visible_message("<span class='alert'>[ui.user] starts screwing a module in place!</span>", "<span class='alert'>You start to screw the module in place!</span>")
				playsound(src.loc, "sound/items/Screwdriver.ogg", 50, 1)
				SETUP_GENERIC_ACTIONBAR(ui.user, src, 5 SECONDS, .proc/toggle_screwed_callback, list(slotNum,ui.user), ui.user.equipped().icon, ui.user.equipped().icon_state, \
				"", INTERRUPT_ACTION | INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ACT)

				return
			if("rack")
				if(!in_interact_range(src, ui.user))
					return
				if (welded[slotNum])
					ui.user.visible_message("<span class='alert'>[ui.user] tries to tug a module out of the rack, but it's welded in place!</span>", "<span class='alert'>You struggle with the module but it's welded in place!</span>")
					return
				if (screwed[slotNum])
					ui.user.visible_message("<span class='alert'>[ui.user] tries to tug a module out of the rack, but it's still screwed in!</span>", "<span class='alert'>You struggle with the module but it's still screwed in!</span>")
					return

				if(law_circuits[slotNum])
					if(issilicon(ui.user))
						boutput(ui.user,"Your clunky robot hands can't grip the module!")
						return
					ui.user.visible_message("<span class='alert'>[ui.user] starts removing a module!</span>", "<span class='alert'>You start removing the module!</span>")
					SETUP_GENERIC_ACTIONBAR(ui.user, src, 5 SECONDS, .proc/remove_module_callback, list(slotNum,ui.user), law_circuits[slotNum].icon, law_circuits[slotNum].icon_state, \
					"", INTERRUPT_ACTION | INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ACT)
				else
					var/equipped = ui.user.equipped()
					if(!equipped)
						return

					if(!istype(equipped,/obj/item/aiModule))
						ui.user.visible_message("<span class='alert'>[ui.user] tries to shove \a [equipped] into the rack. Silly [ui.user]!</span>", "<span class='alert'>You try to put \a [equipped] into the rack. You feel very foolish.</span>")
						return

					ui.user.visible_message("<span class='alert'>[ui.user] starts inserting a module!</span>", "<span class='alert'>You start inserting the module!</span>")
					SETUP_GENERIC_ACTIONBAR(ui.user, src, 5 SECONDS, .proc/insert_module_callback, list(slotNum,ui.user,equipped), ui.user.equipped().icon, ui.user.equipped().icon_state, \
					"", INTERRUPT_ACTION | INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ACT)


	proc/get_welding_positions(var/slotNum)
		var/start
		var/stop
		start = list(-10,-15 + slotNum*4)
		stop = list(10,-15 + slotNum*4)

		if(src.welded[slotNum])
			. = list(stop,start)
		else
			. = list(start,stop)

	/// Takes a list or single target to show laws to
	proc/show_laws(var/who)
		var/list/L =list()
		L += who

		var/laws_text = src.format_for_display()
		for (var/W in L)
			boutput(W, laws_text)

	/** Formats current laws for logging, argument glue defaults to <br>
	 * Output is:
	 * [law number]: [law text]<br>
	 * [law number]: [law text]
	 * etc.
	*/
	proc/format_for_logs(var/glue = "<br>")
		var/law_counter = 1
		var/lawOut = list()
		for (var/obj/item/aiModule/X in law_circuits)
			if(!X)
				continue
			var/lt = X.get_law_text(TRUE)
			if(islist(lt))
				for(var/law in lt)
					lawOut += "[law_counter++]: [law]"
			else
				lawOut += "[law_counter++]: [lt]"

		return jointext(lawOut, glue)

	/** Formats current laws for display to game chat
	 * Output is the same as format_for_logs, but also includes removed laws at the top and styling for added laws
	**/
	proc/format_for_display(var/glue = "<br>")
		var/law_counter = 1 //make the laws always sequential regardless of where in the rack they are
		var/list/lawOut = new
		var/list/removed_laws = new

		for (var/i in 1 to MAX_CIRCUITS)
			var/obj/item/aiModule/module = law_circuits[i]
			if(!module)
				if (last_laws[i])
					//load the law number and text from our saved law list
					removed_laws += "<del class=\"alert\">[last_laws[i]["number"]]: [last_laws[i]["law"]]</del>"
				continue
			var/lt = module.get_law_text(TRUE)
			var/class = "regular"
			if (!last_laws[i] || lt != last_laws[i]["law"])
				class = "lawupdate"
			if(islist(lt))
				for(var/law in lt)
					lawOut += "<span class=\"[class]\">[law_counter++]: [law]</span>"
			else
				lawOut += "<span class=\"[class]\">[law_counter++]: [lt]</span>"

		var/text_output = ""
		if (length(removed_laws))
			text_output += "<span class=\"alert\">Removed law[(length(removed_laws) > 1) ? "s" : ""]:</span>" + glue + jointext(removed_laws, glue) + glue
		text_output += jointext(lawOut, glue)
		return text_output

	/** Formats current laws as a list in the format:
	 * {[lawnumber]=lawtext,etc.}
	 */
	proc/format_for_irc()
		var/list/laws = list()

		var/law_counter = 1
		for (var/obj/item/aiModule/X in law_circuits)
			if(!X)
				continue
			var/lt = X.get_law_text(TRUE)
			if(islist(lt))
				for(var/law in lt)
					laws["[law_counter++]"] = law
			else
				laws["[law_counter++]"] = lt
		return laws

	/// Saves the current law list to last_laws so we can see diffs
	proc/update_last_laws()
		var/law_counter = 1
		for (var/i in 1 to MAX_CIRCUITS)
			var/obj/item/aiModule/module = law_circuits[i]
			if (module)
				//save the law text and the displayed law number (not the rack position)
				last_laws[i] = list("law" = module.get_law_text(TRUE), "number" = law_counter++)
			else
				last_laws[i] = null

	/** Pushes law updates to all connected AIs and Borgs - notification text allows you to customise the header
	* Defaults to <h3>Law update detected</h3>
	*/
	proc/UpdateLaws(var/notification_text="<h3>Law update detected</h3>")
		var/list/affected_mobs = list()
		for (var/mob/living/silicon/R in mobs)
			if (isghostdrone(R))
				continue
			if(R.law_rack_connection == src)
				R.playsound_local(R, "sound/misc/lawnotify.ogg", 100, flags = SOUND_IGNORE_SPACE)
				R.show_text(notification_text, "red")
				src.show_laws(R)
				affected_mobs |= R
				if(isAI(R))
					var/mob/living/silicon/ai/holoAI = R
					holoAI.holoHolder.text_expansion = src.holo_expansions.Copy()

		for (var/mob/living/intangible/aieye/E in mobs)
			if(E.mainframe?.law_rack_connection == src)
				E.playsound_local(E, "sound/misc/lawnotify.ogg", 100, flags = SOUND_IGNORE_SPACE)
				src.show_laws(E)
				affected_mobs |= E.mainframe
				var/mob/living/silicon/ai/holoAI = E.mainframe
				holoAI.holoHolder.text_expansion = src.holo_expansions.Copy()
		var/list/mobtextlist = list()
		for(var/mob/living/M in affected_mobs)
			mobtextlist += constructName(M, "admin")
		logTheThing("station", src, null, "Law Update:<br> [src.format_for_logs()]<br>The law update affects the following mobs: "+mobtextlist.Join(", "))
		update_last_laws()

	proc/toggle_welded_callback(var/slot_number,var/mob/user)
		if(src.welded[slot_number])
			user.visible_message("<span class='alert'>[user] cuts the welds on the module.</span>","<span class='alert'>You cut the welds on the module.</span>")
		else
			user.visible_message("<span class='alert'>[user] welds the module in place.</span>","<span class='alert'>You weld the module in place.</span>")
		src.welded[slot_number] = !src.welded[slot_number]
		tgui_process.update_uis(src)

	proc/toggle_screwed_callback(var/slot_number,var/mob/user)
		if(src.screwed[slot_number])
			user.visible_message("<span class='alert'>[user] unscrews the module.</span>","<span class='alert'>You unscrew the module from the rack.</span>")
		else
			user.visible_message("<span class='alert'>[user] screws in the module.</span>","<span class='alert'>You screw the module into the rack.</span>")
		src.screwed[slot_number] = !src.screwed[slot_number]
		tgui_process.update_uis(src)

	proc/insert_module_callback(var/slotNum,var/mob/user,var/obj/item/aiModule/equipped)
		src.law_circuits[slotNum]=equipped
		user.u_equip(equipped)
		equipped.set_loc(src)
		playsound(src, "sound/machines/law_insert.ogg", 80)
		user.visible_message("<span class='alert'>[user] slides a module into the law rack</span>", "<span class='alert'>You slide the module into the rack.</span>")
		tgui_process.update_uis(src)
		if(istype(equipped,/obj/item/aiModule/hologram_expansion))
			var/obj/item/aiModule/hologram_expansion/holo = equipped
			src.holo_expansions |= holo.expansion
		logTheThing("station", user, null, "[constructName(user)] <b>inserts</b> law module into rack([constructName(src)]): [equipped]:[equipped.get_law_text()] at slot [slotNum]")
		message_admins("[key_name(user)] added a new law to rack at [log_loc(src)]: [equipped], with text '[equipped.get_law_text()]' at slot [slotNum]")
		UpdateIcon()
		UpdateLaws()

	proc/remove_module_callback(var/slotNum,var/mob/user)
		//add circuit to hand
		logTheThing("station", user, null, "[constructName(user)] <b>removes</b> law module from rack([constructName(src)]): [src.law_circuits[slotNum]]:[src.law_circuits[slotNum].get_law_text()] at slot [slotNum]")
		message_admins("[key_name(user)] removed a law from rack at ([log_loc(src)]): [src.law_circuits[slotNum]]:[src.law_circuits[slotNum].get_law_text()] at slot [slotNum]")
		playsound(src, "sound/machines/law_remove.ogg", 80)
		user.visible_message("<span class='alert'>[user] slides a module out of the law rack</span>", "<span class='alert'>You slide the module out of the rack.</span>")
		user.put_in_hand_or_drop(src.law_circuits[slotNum])
		if(istype(src.law_circuits[slotNum],/obj/item/aiModule/hologram_expansion))
			var/obj/item/aiModule/hologram_expansion/holo = src.law_circuits[slotNum]
			src.holo_expansions -= holo.expansion
		src.law_circuits[slotNum] = null
		tgui_process.update_uis(src)
		UpdateIcon()
		UpdateLaws()

	proc/insert_videocard_callback(var/mob/user, var/obj/item/peripheral/videocard/I)
		var/mob/living/target = null
		ON_COOLDOWN(src, "mine_cooldown", 30 SECONDS)
		user.u_equip(I)
		I.set_loc(src)
		playsound(src, "sound/misc/JetpackMK2on.ogg", 70, extrarange=3)
		src.visible_message("<span class='alert'>[I] emits a loud whirring noise as it connects into the [src]!</span>")
		SPAWN(6 SECONDS)
			if (src && !src.GetParticles("mine_spark"))
				playsound(src, "sound/effects/electric_shock_short.ogg", 50)
				src.UpdateParticles(new/particles/rack_spark,"mine_spark")
				src.visible_message("<span class='alert'><b>The [src] starts sparking!</b></span>")
			sleep(2 SECONDS)
			if (!src) return
			src.use_power(500)
			for (var/i in 1 to 10)
				sleep(0.4 SECONDS)
				if(src && prob(60))
					var/obj/mined = new /obj/item/spacecash/buttcoin
					mined.set_loc(src.loc)
					target = get_step(src, rand(1,8))
					for (var/mob/living/mob in view(7,src))
						if (!isintangible(mob))
							target = mob
							break
					playsound(src, "sound/machines/bweep.ogg", rand(45,70), 1, pitch = 1.6)
					mined.throw_at(target, 7, rand(4,6))
					src.visible_message("<span class='alert'>[I] energetically expels [mined]!</span>")
			sleep(1 SECOND)
			if (src && I)
				target = get_step(src, rand(1,8))
				I.set_loc(src.loc)
				for (var/mob/living/mob in view(7,src))
					if (!isintangible(mob))
						target = mob
						break
				playsound(src, "sound/impact_sounds/Metal_Clang_3.ogg", 90)
				I.throw_at(target, 7, rand(6,9))
				src.visible_message("<span class='alert'>The [I] is forcefully ejected from the [src]!</span>")
				src.ClearSpecificParticles("mine_spark")
			sleep(0.7 SECONDS) // just enough time to recognize the card
			if (I)
				fireflash(I,0,TRUE)
				I.combust()

	/// Sets an arbitrary slot to the passed aiModule - will override any module in the slot. Does not call UpdateLaws()
	proc/SetLaw(var/obj/item/aiModule/mod,var/slot=1,var/screwed_in=false,var/welded_in=false)
		if(mod && slot <= MAX_CIRCUITS)
			src.law_circuits[slot] = mod
			src.welded[slot] = welded_in
			src.screwed[slot] = screwed_in
			tgui_process.update_uis(src)
			if(istype(mod,/obj/item/aiModule/hologram_expansion))
				var/obj/item/aiModule/hologram_expansion/holo = mod
				src.holo_expansions |= holo.expansion
			UpdateIcon()
			return true

	/** Sets an arbitrary slot to a custom law specified by lawName and lawText - will override any module in the slot. Does not call UpdateLaws()
	 * Intended for Admemery
	*/
	proc/SetLawCustom(var/lawName,var/lawText,var/slot=1,var/screwed_in=false,var/welded_in=false)
		var/mod = new /obj/item/aiModule/custom(lawName,lawText)
		return src.SetLaw(mod,slot,screwed_in,welded_in)

	/// Deletes a law in an abritrary slot. Does not call UpdateLaws()
	proc/DeleteLaw(var/slot=1)
		if(istype(src.law_circuits[slot],/obj/item/aiModule/hologram_expansion))
			var/obj/item/aiModule/hologram_expansion/holo = src.law_circuits[slot]
			src.holo_expansions -= holo.expansion
		src.law_circuits[slot]=null
		src.welded[slot]=false
		src.screwed[slot]=false
		tgui_process.update_uis(src)
		UpdateIcon()

	/// Deletes all laws. Does not call UpdateLaws()
	proc/DeleteAllLaws()
		for (var/i in 1 to MAX_CIRCUITS)
			src.DeleteLaw(i)

	/** This will cause a module to glitch, either totally replace it law or adding picked_law
	* to its text (depening on replace). Lawnumber is a suggestion, not a guarentee - if there is no
	* law in that slot, this will trigger on the law closest to that slot
	* if there are no laws to glitch, just do nothing
	*/
	proc/cause_law_glitch(var/picked_law="Beep repeatedly.",var/lawnumber=1,var/replace=false)
		var/lawnumber_actual = 1
		if(src.law_circuits[lawnumber])
			lawnumber_actual = lawnumber
		else
			for (var/i in 1 to MAX_CIRCUITS)
				//if the difference between target and current is less than the difference between target and best, and also is a module
				if(src.law_circuits[i] && (abs(lawnumber - i) <= abs(lawnumber - lawnumber_actual)))
					lawnumber_actual = i
		if(!src.law_circuits[lawnumber_actual])
			return false //we could not find a law to modify, sorry
		else
			src.law_circuits[lawnumber_actual].make_glitchy(picked_law,replace)
			tgui_process.update_uis(src)
			if(replace)
				src.visible_message("<span class='alert'><b>The [src] sparks violently!</b></span>")
			else
				src.visible_message("<span class='alert'><b>The [src] makes a brief fizzing noise!</b></span>")
			return true

/particles/rack_smoke
	icon = 'icons/effects/effects.dmi'
	icon_state = list("smoke")
	color = "#777777"
	width = 150
	height = 200
	count = 200
	lifespan = generator("num", 20, 35, UNIFORM_RAND)
	fade = generator("num", 50, 100, UNIFORM_RAND)
	position = generator("box", list(-4,0,0), list(4,15,0), UNIFORM_RAND)
	velocity = generator("box", list(-1,0.5,0), list(1,2,0), NORMAL_RAND)
	gravity = list(0.07, 0.02, 0)
	grow = list(0.02, 0)
	fadein = 10

/particles/rack_spark
	icon = 'icons/effects/lines.dmi'
	icon_state = list("lght")
	color = "#ffffff"
	spawning = 0.1
	count = 20
	lifespan = generator("num", 1, 3, UNIFORM_RAND)
	fade = 0
	position = generator("box", list(-10,-20,0), list(10,20,0), UNIFORM_RAND)
	velocity = list(0, 0, 0)
	gravity = list(0, 0, 0)
	scale = generator("box", list(0.1,0.1,1), list(0.3,0.3,1), UNIFORM_RAND)
	rotation = generator("num", 0, 360, UNIFORM_RAND)
	grow = list(0.01, 0)
	fadein = 0


/obj/machinery/lawrack/syndicate
	name = "AI Law Mount Rack - Syndicate Model"
	icon_state = "airack_syndicate_empty"
	desc = "A large electronics rack that can contain AI Law Circuits, to modify the behaivor of connected AIs. This one has a little S motif on the side."
