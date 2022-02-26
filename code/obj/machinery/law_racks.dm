/obj/machinery/computer/aiupload
	name = "AI Law Mount Rack"
	icon = 'icons/obj/large/32x48.dmi'
	icon_state = "airack_empty"
	desc = "A large electronics rack that can contain AI Law Circuits, to modify the behaivor of connected AIs."
	circuit_type = /obj/item/circuitboard/aiupload

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

	disposing()
		STOP_TRACKING
		//should almost certainly do some bullshit here about cleaning up ticker and stuff
		. = ..()

	update_icon()
		var/image/circuit_image = null
		var/image/color_overlay = null
		for (var/i=1, i <= MAX_CIRCUITS, i++)
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
		if (src.status & NOPOWER)
			boutput(user, "\The [src] has no power.")
			return
		if (src.status & BROKEN)
			boutput(user, "\The [src] computer is broken.")
			return

		if (!src.law_circuits)
			// YOU BETRAYED THE LAW!!!!!!
			boutput(user, "<span class='alert'>Oh dear, this really shouldn't happen. Call an admin.</span>")
			return

		boutput(user,"<b>This rack's laws are:</b>")
		src.show_laws(user)
		return ..()

	special_deconstruct(obj/computerframe/frame as obj)
		if(src.status & BROKEN)
			logTheThing("station", usr, null, "disassembles [src] (broken) [log_loc(src)]")
		else
			logTheThing("station", usr, null, "disassembles [src] [log_loc(src)]")
			//TODO: make law circuits fall out


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
		for (var/i=1, i <= MAX_CIRCUITS, i++)
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

		var/slotNum = text2num(params["rack_index"])
		switch(action)
			if("weld")
				if (!ui.user.equipped() || !isweldingtool(ui.user.equipped()))
					boutput(ui.user,"You need a welding tool for that!")
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
					ui.user.visible_message("<span class='alert'>[ui.user] tries to tug a module out of the rack, but it's still screwed in!</span>", "<span class='alert'>You struggle with the module but it's still screwd in!</span>")
					return

				if(law_circuits[slotNum])
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

	proc/UpdateLaws()
		for (var/mob/living/silicon/R in mobs)
			if (isghostdrone(R))
				continue
			R << sound('sound/misc/lawnotify.ogg', volume=100, wait=0)
			R.show_text("<h3>Law update detected.</h3>", "red")
			src.show_laws(R)

		for (var/mob/living/intangible/aieye/E in mobs)
			E << sound('sound/misc/lawnotify.ogg', volume=100, wait=0)

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
		for (var/i=1, i <= MAX_CIRCUITS, i++)
			src.DeleteLaw(i)
		return true
/*

/obj/machinery/ai_law_rack
	name = "AI Law Mount Rack"
	icon //todo
	icon_state //todo
	desc = "A large electronics rack that can contain AI Law Circuits, to modify the behaivor of connected AIs."
	density = 1
	anchored = 1
	power_usage = 250

	var/datum/light/light

	var/my_id //ref
	var/connected_silicons = list() //only allow mob/living/silicon in here!!!

	var/law_circuits[0] //asssoc list to ref slot num with law board obj
	var/const/MAX_CIRCUITS = 9

	New(loc)
		..()
		my_id = "\ref[src]"

		find_connected_silicons()

		light = new/datum/light/point
		light.set_brightness(0.4)
		light.attach(src)

		UnsubscribeProcess()

		for (var/i=0, i < MAX_CIRCUITS, i++) //init asimov laws by default
			switch(i)
				if (1)
					law_circuits[i] = new /obj/item/aiModule/asimov1
				if (2)
					law_circuits[i] = new /obj/item/aiModule/asimov2
				if (3)
					law_circuits[i] = new /obj/item/aiModule/asimov3
				else
					law_circuits[i] = null

	attack_hand(user as mob) // The microwave Menu
		if (isghostdrone(user))
			boutput(user, "<span style=\"color:red\">You just can't make any sense of this strange blinky thing!</span>")
			return
		/*if (status & NOPOWER)																	replace with button on GUI, make buttons not work
			boutput(user, "The rack seems to have no power!")
			return */
		if(status & (NOPOWER|BROKEN))
			boutput(user, "The upload computer is broken!")
			return

		return


	attackby(obj/item/I as obj, mob/user as mob)
		if (ispulsingtool(I))
			find_connected_silicons()

	add_law(var/obj/item/aiModule/C, var/slotnum, var/updater)
		law_circuits[slotnum] = C
		log_lawchange(updater, C, 0)

	remove_law(var/slotnum, var/mob/remover)
		var/obj/item/aiModule/oldboard = law_circuits[slotnum]
		log_lawchange(remover, oldboard, 1)
		remover.put_in_hand_or_drop(oldboard)
		law_circuits[slotnum] = null

	find_connected_silicons()
		connected_silicons = list()
		for (var/mob/living/silicon/ai/foundAI in mobs)
			if (foundAI.rack_id == my_id)
				foundAI += connected_silicons
		for (var/mob/living/silicon/robot/foundBot in mobs)
			if (foundBot.rack_id == my_id)
				foundBot += connected_silicons

	update_laws(var/mob/updater) //triggered by the update button on the rack interface
		notify_silicons_lawchange(updater)
		notify_admins_lawchange(updater)
		updater.unlock_medal("Format Complete", 1)

	notify_silicons_lawchange(var/mob/updater) //maybe should be a popup instead of in chat?
		for (var/mob/living/silicon/mySilly in connected_silicons)
			boutput(mySilly, "<span style='color: blue; font-weight: bold;'>[updater.name] has modified your lawset. From now on, these are your laws:")
			for (var/obj/item/aiModule/C in src.contents) // need to add index of law ERROR TODO, TODO show by law number
				boutput(mySilly, C.lawtext) //include law number TODO

	notify_admins_lawchange(var/mob/updater)
		message_admins("[key_name(updater)] updated the laws of [connected_silicons.len] silicons. The new laws are:")
		for (var/i=0, i< law_circuits.len, i++)
			var/lawnumber = law_circuits[i]
			message_admins("[law_circuits[i]]. [C.lawtext]")

	log_lawchange(var/mob/sender, var/newcircuit, var/remove)
		logTheThing("admin", sender, null, "removed/inserted the law [newcircuit.lawtext] - Law Rack #[my_id].")
		logTheThing("diary", sender, null, "removed/inserted the law [newcircuit.lawtext] - Law Rack #[my_id].", "admin")



	Topic(href, href_list)
		if (status & (NOPOWER|BROKEN)) return
		if (usr.stat || usr.restrained()) return
		if (!in_range(src, usr)) return

		usr.machine = src
		src.add_fingerprint(usr)

	//	empty slot
	//		if (istype(I, /obj/item/ai_law_circuit))
	//			I.set_loc(src)
	//			add_law(I, slotnum)
	//			notify_admins_lawchange(user, I)




	meteorhit(var/obj/O as obj)
		if(status & BROKEN)
			qdel(src)
			return
		set_broken()

	ex_act(severity)
		switch(severity)
			if(1.0)
				qdel(src)
				return
			if(2.0)
				if (prob(50))
					set_broken()
			if(3.0)
				if (prob(25))
					set_broken()

	emp_act()
		..()
		if(prob(20))
			set_broken()
		return

	blob_act(var/power)
		if (prob(50 * power / 20))
			set_broken()

	power_change()
		if(status & BROKEN)
			icon_state = initial(icon_state)
			src.icon_state += "b"
			light.disable()

		else if(powered())
			icon_state = initial(icon_state)
			status &= ~NOPOWER
			light.enable()
		else
			icon_state = initial(icon_state)
			src.icon_state += "0"
			status |= NOPOWER
			light.disable()

	process()
		if(status & BROKEN)
			return
		..()
		if(status & NOPOWER)
			return
		use_power(power_usage)

	set_broken()
		if (status & BROKEN) return
		var/datum/effects/system/harmless_smoke_spread/smoke = new /datum/effects/system/harmless_smoke_spread()
		smoke.set_up(5, 0, src)
		smoke.start()
		icon_state = initial(icon_state)
		icon_state += "b"
		light.disable()
		status |= BROKEN


*/
