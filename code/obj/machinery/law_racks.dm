/obj/machinery/lawrack
	name = "AI Law Mount Rack"
	icon = 'icons/obj/large/32x48.dmi'
	icon_state = "airack_empty"
	desc = "A large electronics rack that can contain AI Law Circuits, to modify the behaivor of connected AIs."
	density=1
	mats = list("MET-1" = 20, "MET-2" = 5, "INS-1" = 10, "CON-1" = 10) //this bitch should be expensive
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WELDER | DECON_WIRECUTTERS | DECON_MULTITOOL | DECON_WRENCH

	var/datum/light/light
	var/const/MAX_CIRCUITS = 9
	var/obj/item/aiModule/law_circuits[MAX_CIRCUITS] //asssoc list to ref slot num with law board obj
	var/list/welded[MAX_CIRCUITS]
	var/list/screwed[MAX_CIRCUITS] //there has to be a less hacky way of doing this, but I can't think of it right now

	New(loc)
		START_TRACKING
		. = ..()
		//if the ticker isn't initialised yet, it'll grab this rack when it is (see )
		ticker?.ai_law_rack_manager.register_new_rack(src)

		src.light = new/datum/light/point
		src.light.set_brightness(0.4)
		src.light.attach(src)
		UpdateIcon()

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
		ticker?.ai_law_rack_manager.register_new_rack(src)
		. = ..()

	update_icon()
		var/image/circuit_image = null
		var/image/color_overlay = null
		for (var/i in 1 to MAX_CIRCUITS)
			circuit_image = null
			color_overlay = null
			if(law_circuits[i])
				circuit_image = image(src.icon, "aimod") //law_circuits[i].icon_state
				circuit_image.pixel_x = 0
				circuit_image.pixel_y = -36 + i*4 //I expect this is bad practice, so maybe fix this
				color_overlay = image(src.icon, "aimod_over")
				color_overlay.color = law_circuits[i].highlight_color
				color_overlay.pixel_x = 0
				color_overlay.pixel_y = -36 + i*4 //I expect this is bad practice, so maybe fix this
				//circuit_image.overlays += circuit_image
				//circuit_image.color = law_circuits[i].color
				//src.overlays += circuit_image
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
		if (istype(I, /obj/item/aiModule) && !isghostdrone(user))
			var/obj/item/aiModule/AIM = I
			var/inserted = false
			var/count = 1
			while (!inserted && count <= MAX_CIRCUITS)
				if(!src.law_circuits[count])
					src.law_circuits[count] = AIM
					user.visible_message("<span class='alert'><b>[user.name]</b> inserts a module into the first empty slot on the rack!</span>")
					inserted = true
					user.u_equip(AIM)
				count++
			if(!inserted)
				boutput(user,"Oh no the rack is full")
			else
				UpdateIcon()
				UpdateLaws()
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
					SETUP_GENERIC_ACTIONBAR(ui.user, src, 5 SECONDS, .proc/toggle_welded, slotNum, equipped.icon, equipped.icon_state, \
			  		welded[slotNum] ? "You cut the welds on the module." : "You weld the module into the rack.", \
			 		INTERRUPT_ACTION | INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ACT)

				return
			if("screw")
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
				SETUP_GENERIC_ACTIONBAR(ui.user, src, 5 SECONDS, .proc/toggle_screwed, slotNum, ui.user.equipped().icon, ui.user.equipped().icon_state, \
				welded[slotNum] ? "You unscrew the module." : "You screw the module into the rack.", \
				INTERRUPT_ACTION | INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ACT)

				return
			if("rack")
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
					//add circuit to hand
					ui.user.visible_message("<span class='alert'>[ui.user] slides a module out of the law rack</span>", "<span class='alert'>You slide the module out of the rack.</span>")
					ui.user.put_in_hand_or_drop(law_circuits[slotNum])
					law_circuits[slotNum] = null
					UpdateIcon()
					UpdateLaws()
				else

					var/equipped = ui.user.equipped()
					if(!equipped)
						return

					if(!istype(equipped,/obj/item/aiModule))
						ui.user.visible_message("<span class='alert'>[ui.user] tries to shove \a [equipped] into the rack. Silly [ui.user]!</span>", "<span class='alert'>You try to put \a [equipped] into the rack. You feel very foolish.</span>")
						return

					law_circuits[slotNum]=equipped
					ui.user.u_equip(equipped)
					ui.user.visible_message("<span class='alert'>[ui.user] slides a module into the law rack</span>", "<span class='alert'>You slide the module into the rack.</span>")

					UpdateIcon()
					UpdateLaws()

	proc/show_laws(var/who)
		var/list/L = who
		if (!istype(who, /list))
			L = list(who)

		var/laws_text = src.format_for_logs()
		for (var/W in L)
			boutput(W, laws_text)

	proc/format_for_logs(var/glue = "<br>")
		var/law_counter = 1
		var/lawOut = list()
		for (var/obj/item/aiModule/X in law_circuits)
			if(!X)
				continue
			lawOut += "[law_counter++]: [X.get_law_text()]"

		return jointext(lawOut, glue)

	proc/format_for_irc()
		var/list/laws = list()

		var/law_counter = 1
		for (var/obj/item/aiModule/X in law_circuits)
			if(!X)
				continue
			laws["[law_counter]"] = X.get_law_text()
			law_counter++

		return laws

	proc/UpdateLaws(var/notification_text="<h3>Law update detected</h3>")
		for (var/mob/living/silicon/R in mobs)
			if (isghostdrone(R))
				continue
			if(R.law_rack_connection == src)
				R.playsound_local(R, "sound/misc/lawnotify.ogg", 100, flags = SOUND_IGNORE_SPACE)
				R.show_text(notification_text, "red")
			src.show_laws(R)

		for (var/mob/living/intangible/aieye/E in mobs)
			if(E.mainframe?.law_rack_connection == src)
				E.playsound_local(E, "sound/misc/lawnotify.ogg", 100, flags = SOUND_IGNORE_SPACE)

	proc/toggle_welded(var/slot_number)
		src.welded[slot_number] = !src.welded[slot_number]

	proc/toggle_screwed(var/slot_number)
		src.screwed[slot_number] = !src.screwed[slot_number]

	proc/SetLaw(var/obj/item/aiModule/mod,var/slot=1,var/screwed_in=false,var/welded_in=false)
		if(mod && slot <= MAX_CIRCUITS)
			src.law_circuits[slot] = mod
			src.welded[slot] = welded_in
			src.screwed[slot] = screwed_in
			UpdateIcon()
			return true
		else
			return false

	proc/SetLawCustom(var/lawName,var/lawText,var/slot=1,var/screwed_in=false,var/welded_in=false)
		var/mod = new /obj/item/aiModule/custom(lawName,lawText)
		return src.SetLaw(mod,slot,screwed_in,welded_in)

	proc/DeleteLaw(var/slot=1)
		src.law_circuits[slot]=null
		src.welded[slot]=false
		src.screwed[slot]=false
		UpdateIcon()
		return true

	proc/DeleteAllLaws()
		for (var/i in 1 to MAX_CIRCUITS)
			src.DeleteLaw(i)
		return true

	proc/cause_law_glitch(var/picked_law="Beep repeatedly.",var/lawnumber=1,var/replace=false)
		//This will cause a module to glitch, either totally replace it law or adding picked_law
		//to its text (depening on replace). Lawnumber is a suggestion, not a guarentee - if there is no
		//law in that slot, this will trigger on the law closest to that slot
		//if there are no laws to glitch, just do nothing
		var/lawnumber_actual = 1
		if(src.law_circuits[lawnumber])
			lawnumber_actual = lawnumber
		else
			for (var/i in 1 to MAX_CIRCUITS)
				if(src.law_circuits[i] && abs(lawnumber - i) <= abs(i - lawnumber_actual))
					lawnumber_actual = i
		if(!src.law_circuits[lawnumber_actual])
			return false //we could not find a law to modify, sorry
		else
			return src.law_circuits[lawnumber_actual].make_glitchy(picked_law,replace)
