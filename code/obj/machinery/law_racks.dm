/obj/machinery/lawrack
	name = "AI Law Mount Rack"
	icon = 'icons/obj/large/32x48.dmi'
	icon_state = "airack_empty"
	desc = "A large electronics rack that can contain AI Law Circuits, to modify the behaivor of connected AIs."
	density = 1
	anchored = 1
	mats = list("MET-1" = 20, "MET-2" = 5, "INS-1" = 10, "CON-1" = 10) //this bitch should be expensive
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WELDER | DECON_WIRECUTTERS | DECON_MULTITOOL | DECON_WRENCH | DECON_NOBORG

	var/datum/light/light
	var/const/MAX_CIRCUITS = 9
	/// list of aiModules ref'd by slot number.
	var/obj/item/aiModule/law_circuits[MAX_CIRCUITS]
	/// welded status of law module by slot number
	var/list/welded[MAX_CIRCUITS]
	/// screwed status of law module by slot number
	var/list/screwed[MAX_CIRCUITS]

	New(loc)
		START_TRACKING
		. = ..()
		//if the ticker isn't initialised yet, it'll grab this rack when it is (see /datum/ai_rack_manager)
		ticker?.ai_law_rack_manager.register_new_rack(src)

		src.light = new/datum/light/point
		src.light.set_brightness(0.4)
		src.light.attach(src)
		UpdateIcon()

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
		ticker?.ai_law_rack_manager.unregister_rack(src)
		src.drop_all_modules()
		UpdateIcon()
		. = ..()


	was_built_from_frame(mob/user, newly_built)
		//this should always be hard to deconstruct, even if play built
		src.deconstruct_flags = DECON_SCREWDRIVER | DECON_WELDER | DECON_WIRECUTTERS | DECON_MULTITOOL | DECON_WRENCH | DECON_NOBORG
		ticker?.ai_law_rack_manager.register_new_rack(src)
		. = ..()

	updateHealth(var/prevHealth)
		if(_health <= 0)
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

	examine()
		. = ..()
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



	ex_act(severity)
		src.material?.triggerExp(src, severity)
		switch(severity)
			if(1.0)
				changeHealth(rand(-105,-90))
				return
			if(2.0)
				changeHealth(rand(-80,-50))
				return
			if(3.0)
				changeHealth(rand(-30,-10))
				return

	bullet_act(obj/projectile/P)
		var/damage = 0

		damage = round((0.15*P.power*P.proj_data.ks_ratio), 1.0)
		damage = damage - min(damage,3) //bullet resist
		if (damage < 1)
			if(!P.proj_data.silentshot)
				src.visible_message("<span class='alert'>[src] is hit by the [P] but it deflects harmlessly.</span>")
			return

		if (src.material)
			src.material.triggerOnBullet(src, src, P)

		switch (P.proj_data.damage_type)
			if (D_KINETIC)
				changeHealth(-damage)
			if (D_PIERCING)
				changeHealth(-damage*1.25)
			if (D_SLASHING)
				changeHealth(-damage*0.75)
			if (D_BURNING)
				changeHealth(-damage*0.5)
			if (D_ENERGY)
				changeHealth(-damage*0.75)

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
				boutput(user,"Oh no the rack is full")
			else
				SETUP_GENERIC_ACTIONBAR(user, src, 5 SECONDS, .proc/insert_module_callback, list(count,user,AIM), user.equipped().icon, user.equipped().icon_state, \
					"", INTERRUPT_ACTION | INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ACT)
		else if (istype(I, /obj/item/clothing/mask/moustache/))
			for_by_tcl(M, /mob/living/silicon/ai)
				if(M.law_rack_connection == src)
					M.moustache_mode = 1
					user.visible_message("<span class='alert'><b>[user.name]</b> uploads a moustache to [M.name]!</span>")
					M.update_appearance()
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

		if(isintangible(ui.user) || isdead(ui.user))
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
				if(!equipped:try_weld(ui.user, 1, burn_eyes = 1))
					return
				else
					if(welded[slotNum])
						ui.user.visible_message("<span class='alert'>[ui.user] starts cutting the welds on a module!</span>", "<span class='alert'>You start cutting the welds on the module!</span>")
					else
						ui.user.visible_message("<span class='alert'>[ui.user] starts welding a module in place!</span>", "<span class='alert'>You start to weld the module in place!</span>")
					playsound(src.loc, "sound/items/Welder.ogg", 50, 1)
					SETUP_GENERIC_ACTIONBAR(ui.user, src, 5 SECONDS, .proc/toggle_welded_callback, slotNum, equipped.icon, equipped.icon_state, \
			  		welded[slotNum] ? "[ui.user] cuts the welds on the module." : "[ui.user] welds the module into the rack.", \
			 		INTERRUPT_ACTION | INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ACT)

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
				SETUP_GENERIC_ACTIONBAR(ui.user, src, 5 SECONDS, .proc/toggle_screwed_callback, slotNum, ui.user.equipped().icon, ui.user.equipped().icon_state, \
				welded[slotNum] ? "[ui.user] unscrews the module." : "[ui.user] screws the module into the rack.", \
				INTERRUPT_ACTION | INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ACT)

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


	/// Takes a list or single target to show laws to
	proc/show_laws(var/who)
		var/list/L =list()
		L += who

		var/laws_text = src.format_for_logs()
		for (var/W in L)
			boutput(W, laws_text)

	/** Formats current laws for display or logging, argument glue defaults to <br>
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
			lawOut += "[law_counter++]: [X.get_law_text()]"

		return jointext(lawOut, glue)

	/** Formats current laws as a list in the format:
	 * {[lawnumber]=lawtext,etc.}
	 */
	proc/format_for_irc()
		var/list/laws = list()

		var/law_counter = 1
		for (var/obj/item/aiModule/X in law_circuits)
			if(!X)
				continue
			laws["[law_counter]"] = X.get_law_text()
			law_counter++

		return laws

	/** Pushes law updates to all connected AIs and Borgs - notification text allows you to customise the header
	* Defaults to <h3>Law update detected</h3>
	*/
	proc/UpdateLaws(var/notification_text="<h3>Law update detected</h3>")
		logTheThing("station", src, null, "Law Update: "+src.format_for_logs())
		var/list/affected_mobs = list()
		for (var/mob/living/silicon/R in mobs)
			if (isghostdrone(R))
				continue
			if(R.law_rack_connection == src)
				R.playsound_local(R, "sound/misc/lawnotify.ogg", 100, flags = SOUND_IGNORE_SPACE)
				R.show_text(notification_text, "red")
				src.show_laws(R)
				affected_mobs |= R

		for (var/mob/living/intangible/aieye/E in mobs)
			if(E.mainframe?.law_rack_connection == src)
				E.playsound_local(E, "sound/misc/lawnotify.ogg", 100, flags = SOUND_IGNORE_SPACE)
				src.show_laws(E)
				affected_mobs |= E.mainframe
		var/list/mobtextlist = list()
		for(var/mob/living/M in affected_mobs)
			mobtextlist += constructName(M, "admin")
		logTheThing("station", src, null, "the law update affects the following mobs: "+mobtextlist.Join(", "))

	proc/toggle_welded_callback(var/slot_number)
		src.welded[slot_number] = !src.welded[slot_number]
		tgui_process.update_uis(src)

	proc/toggle_screwed_callback(var/slot_number)
		src.screwed[slot_number] = !src.screwed[slot_number]
		tgui_process.update_uis(src)

	proc/insert_module_callback(var/slotNum,var/mob/user,var/obj/item/aiModule/equipped)
		src.law_circuits[slotNum]=equipped
		user.u_equip(equipped)
		equipped.set_loc(src)
		user.visible_message("<span class='alert'>[user] slides a module into the law rack</span>", "<span class='alert'>You slide the module into the rack.</span>")
		tgui_process.update_uis(src)
		logTheThing("station", user, src, "[user.name] inserts law module into rack([log_loc(src)]): [equipped] at slot [slotNum]")
		UpdateIcon()
		UpdateLaws()

	proc/remove_module_callback(var/slotNum,var/mob/user)
		//add circuit to hand
		logTheThing("station", user, src, "[user.name] removes law module from rack([log_loc(src)]): [src.law_circuits[slotNum]] at slot [slotNum]")
		user.visible_message("<span class='alert'>[user] slides a module out of the law rack</span>", "<span class='alert'>You slide the module out of the rack.</span>")
		user.put_in_hand_or_drop(src.law_circuits[slotNum])
		src.law_circuits[slotNum] = null
		tgui_process.update_uis(src)
		UpdateIcon()
		UpdateLaws()

	/// Sets an arbitrary slot to the passed aiModule - will override any module in the slot. Does not call UpdateLaws()
	proc/SetLaw(var/obj/item/aiModule/mod,var/slot=1,var/screwed_in=false,var/welded_in=false)
		if(mod && slot <= MAX_CIRCUITS)
			src.law_circuits[slot] = mod
			src.welded[slot] = welded_in
			src.screwed[slot] = screwed_in
			tgui_process.update_uis(src)
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
				//if the difference between target and current is less than the difference between current and best, and also is a module
				if(src.law_circuits[i] && abs(lawnumber - i) <= abs(i - lawnumber_actual))
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
