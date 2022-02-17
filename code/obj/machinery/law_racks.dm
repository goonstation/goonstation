/obj/machinery/computer/aiupload
	name = "AI Law Mount Rack"
	icon = 'icons/obj/large/32x48.dmi'
	icon_state = "airack_empty"
	desc = "A large electronics rack that can contain AI Law Circuits, to modify the behaivor of connected AIs."
	circuit_type = /obj/item/circuitboard/aiupload
	var/module_icon = 'icons/obj/module.dmi'


	var/datum/light/light
	var/const/MAX_CIRCUITS = 9
	var/obj/item/aiModule/law_circuits[MAX_CIRCUITS] //asssoc list to ref slot num with law board obj

	New(loc)
		. = ..()
		law_circuits[1] = new /obj/item/aiModule/asimov1
		law_circuits[2] = new /obj/item/aiModule/asimov2
		law_circuits[3] = new /obj/item/aiModule/asimov3

		light = new/datum/light/point
		light.set_brightness(0.4)
		light.attach(src)
		UpdateIcon()

	update_icon()
		for (var/i=1, i <= MAX_CIRCUITS, i++)
			if(law_circuits[i])
				var/image/circuit_image = image(src.module_icon, "aimod_[i]",,layer = src.layer + 0.005)
				circuit_image.pixel_x = 0
				circuit_image.pixel_y = i*6
				src.overlays += circuit_image

	attack_hand(mob/user as mob)
		if (src.status & NOPOWER)
			boutput(user, "\The [src] has no power.")
			return
		if (src.status & BROKEN)
			boutput(user, "\The [src] computer is broken.")
			return

		if (!law_circuits)
			// YOU BETRAYED THE LAW!!!!!!
			boutput(user, "<span class='alert'>WARNING: No laws detected. This unit may be corrupt.</span>")
			return

		var/lawOut = list("<b>The AI's current laws are:</b>")


		var/law_counter = 1
		for (var/obj/item/aiModule/X in law_circuits)
			if(!X)
				continue
			lawOut += "[law_counter++]: [X.get_law_text()]"

		boutput(user, jointext(lawOut, "<br>"))

	special_deconstruct(obj/computerframe/frame as obj)
		if(src.status & BROKEN)
			logTheThing("station", usr, null, "disassembles [src] (broken) [log_loc(src)]")
		else
			logTheThing("station", usr, null, "disassembles [src] [log_loc(src)]")
			//TODO: make law circuits fall out


	attackby(obj/item/I as obj, mob/user as mob)
		if (istype(I, /obj/item/aiModule) && !isghostdrone(user))
			var/obj/item/aiModule/AIM = I
			AIM.install(src, user)
		else if (istype(I, /obj/item/clothing/mask/moustache/))
			for_by_tcl(M, /mob/living/silicon/ai)
				M.moustache_mode = 1
				user.visible_message("<span class='alert'><b>[user.name]</b> uploads a moustache to [M.name]!</span>")
				M.update_appearance()
		else
			return ..()


	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if(!ui)
			ui = new(user, src, "lawrack", src.name)
			ui.open()

	ui_static_data(mob/user)
		. = list(
			"lawSlots" = MAX_CIRCUITS
		)

	ui_data(mob/user)
		. = list(
			"laws" = src.law_circuits
		)

	ui_act(action, params)
		. = ..()
		if (.)
			return
		switch(action)
			if("toggle-input")
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
