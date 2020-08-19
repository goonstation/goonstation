
/obj/item/electronics/
	name = "electronic thing"
	icon = 'icons/obj/electronics.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	force = 5
	hit_type = DAMAGE_BLUNT
	throwforce = 5
	w_class = 1.0
	pressure_resistance = 10
	item_state = "electronic"
	flags = FPRINT | TABLEPASS | CONDUCT

/obj/item/electronics/New()
	desc = "A [src.name] used in electronic projects."
	return

/obj/item/electronics/proc/randompix()
	src.pixel_x = rand(8, 12)
	src.pixel_y = rand(8, 12)
	return

////////////////////////////////////////////////////////////////
/obj/item/electronics/battery
	name = "battery"
	icon_state = "batt1"
	module_research = list("electronics" = 2)

/obj/item/electronics/battery/New()
	src.icon_state = pick("batt1", "batt2", "batt3")
	randompix()
	..()
////////////////////////////////////////////////////////////////up
/obj/item/electronics/board
	name = "board"
	icon_state = "board1"
	module_research = list("electronics" = 2)

/obj/item/electronics/board/New()
	src.icon_state = pick("board1", "board2", "board3")
	randompix()
	..()
////////////////////////////////////////////////////////////////
/obj/item/electronics/fuse
	name = "fuse"
	icon_state = "fuse1"
	module_research = list("electronics" = 2)

/obj/item/electronics/fuse/New()
	src.icon_state = pick("fuse1", "fuse2", "fuse3")
	randompix()
	..()
////////////////////////////////////////////////////////////////
/obj/item/electronics/switc
	name = "switch"
	icon_state = "switch1"
	module_research = list("electronics" = 2)

/obj/item/electronics/switc/New()
	src.icon_state = pick("switch1", "switch2", "switch3")
	randompix()
	..()
////////////////////////////////////////////////////////////////up
/obj/item/electronics/keypad
	name = "keypad"
	icon_state = "keypad1"
	module_research = list("electronics" = 2)
/obj/item/electronics/keypad/New()
	src.icon_state = pick("keypad1", "keypad2", "keypad3")
	randompix()
	..()
////////////////////////////////////////////////////////////////up
/obj/item/electronics/screen
	name = "screen"
	icon_state = "screen1"
	module_research = list("electronics" = 2)
/obj/item/electronics/screen/New()
	src.icon_state = pick("screen1", "screen2", "screen3")
	randompix()
	..()
////////////////////////////////////////////////////////////////
/obj/item/electronics/capacitor
	name = "capacitor"
	icon_state = "capacitor1"
	module_research = list("electronics" = 2)
/obj/item/electronics/capacitor/New()
	src.icon_state = pick("capacitor1", "capacitor2", "capacitor3")
	randompix()
	..()
////////////////////////////////////////////////////////////////up
/obj/item/electronics/buzzer
	name = "buzzer"
	icon_state = "buzzer"
	module_research = list("electronics" = 2)
/obj/item/electronics/buzzer/New()
	randompix()
	..()
////////////////////////////////////////////////////////////////
/obj/item/electronics/resistor
	name = "resistor"
	icon_state = "resistor1"
	module_research = list("electronics" = 2)
/obj/item/electronics/resistor/New()
	src.icon_state = pick("resistor1", "resistor2")
	randompix()
	..()
////////////////////////////////////////////////////////////////
/obj/item/electronics/bulb
	name = "bulb"
	icon_state = "bulb1"
	module_research = list("electronics" = 2)
/obj/item/electronics/bulb/New()
	src.icon_state = pick("bulb1", "bulb2")
	randompix()
	..()
////////////////////////////////////////////////////////////////
/obj/item/electronics/relay
	name = "relay"
	icon_state = "relay1"
	module_research = list("electronics" = 2)
/obj/item/electronics/bulb/New()
	src.icon_state = pick("relay1", "relay2")
	randompix()
	..()
////////////////////////////////////////////////////////////////no
/obj/item/electronics/frame
	name = "frame"
	icon_state = "frame"
	var/store_type = null
	var/secured = 0
	var/viewstat = 0
	var/dir_needed = 0
	//var/list/parts = new/list()
	var/list/needed_parts = new/list()
	module_research = list("electronics" = 3, "engineering" = 1)
	var/obj/deconstructed_thing = null


	disposing()
		deconstructed_thing = null
		store_type = null
		..()

/obj/item/electronics/frame/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W,/obj/item/electronics/))
		var/obj/item/electronics/E = W
		if(!(istype(E,/obj/item/electronics/disk)||istype(E,/obj/item/electronics/scanner)||istype(E,/obj/item/electronics/soldering)||istype(E,/obj/item/electronics/frame)))
			E.set_loc(src)
			user.u_equip(E)
			//parts.Add(E)
			boutput(user, "<span class='notice'>You add the [E.name] to the [src].</span>")
			return
		else if(istype(E,/obj/item/electronics/soldering))
			if(!secured)
				secured = 1
				viewstat = 1
				boutput(user, "<span class='notice'>You secure the [src].</span>")
			else if(secured == 1)
				secured = 0
				viewstat = 0
				boutput(user, "<span class='notice'>You unsecure the [src].</span>")
			else if(secured == 2)
				boutput(user, "<span class='alert'>You deploy the [src]!</span>")
				logTheThing("station", user, null, "deploys a [src.name] in [user.loc.loc] ([showCoords(src.x, src.y, src.z)])")
				if (!istype(user.loc,/turf) && (store_type in typesof(/obj/critter)))
					qdel(user.loc)

				actions.start(new/datum/action/bar/icon/build_electronics_frame(src), user)
				//deploy()
			return
	if (ispryingtool(W))
		if (!anchored)
			src.dir = turn(src.dir, 90)
			return
	else if (iswrenchingtool(W))
		boutput(user, "<span class='alert'>You deconstruct [src] into its base materials!</span>")
		src.drop_resources(W,user)
	..()

/obj/item/electronics/frame/MouseDrop_T(atom/movable/O as obj, mob/user as mob)
	if(!iscarbon(user) || user.stat || user.getStatusDuration("weakened") || user.getStatusDuration("paralysis"))
		return

	if(get_dist(user, src) > 1)
		return

	var/list/bad_types = list(/obj/item/electronics/disk, /obj/item/electronics/scanner, /obj/item/electronics/soldering, /obj/item/electronics/frame)
	if(!istype(O, /obj/item/electronics) || (O.type in bad_types))
		boutput(user, "<span class='alert'>That is not a valid component!</span>")
		return

	if (!src.secured)
		var/turf/source_turf = get_turf(O)
		if(!source_turf) return
		user.visible_message("<span class='notice'>[user] begins quickly adding components to [src]!</span>", "<span class='notice'>You begin to quickly add components to [src]!</span>")
		var/staystill = user.loc

		for(var/obj/item/electronics/I in source_turf)
			if(I.type in bad_types) continue
			I.set_loc(src)
			//parts.Add(I)
			sleep(0.3 SECONDS)
			if (user.loc != staystill) break

		boutput(user, "<span class='notice'>You finish adding components to [src]!</span>")
	else
		boutput(user, "<span class='alert'>The board is already secured!</span>")
	return

/obj/item/electronics/frame/attack_self(mob/user as mob)
	src.add_fingerprint(user)
	var/dat
	dat = "Parts:<BR>"

	switch(viewstat)

		if(0)
			for(var/obj/item/electronics/P in src.contents)
				dat += "[P.name]: <A href='?src=\ref[src];op=\ref[P];tp=move'>Remove</A><BR>"

				src.add_dialog(user)
				user.Browse("<HEAD><TITLE>Frame</TITLE></HEAD><TT>[dat]</TT>", "window=fkit")
				onclose(user, "fkit")

		if(1)
			var/check = parts_check()
			if(!check)
				boutput(user, "<span class='alert'>Incomplete Object, unable to finish!</span>")
				return
			if(dir_needed)
				var/dirr = input("Select A Direction!", "UDLR", null, null) in list("Up","Down","Left","Right")
				switch(dirr)
					if("Up")
						src.dir = 1
					if("Down")
						src.dir = 2
					if("Left")
						src.dir = 8
					if("Right")
						src.dir = 4
			boutput(user, "Ready to deploy!")
			switch(alert("Ready to deploy?",,"Yes","No"))
				if("Yes")
					boutput(user, "<span class='alert'>Place box and solder to deploy!</span>")
					viewstat = 2
					secured = 2
					icon_state = "dbox"
				if("No")
					return
		else
			return

/obj/item/electronics/frame/Topic(href, href_list)
	if (usr.stat)
		return
	if ((usr.contents.Find(src) || usr.contents.Find(src.master) || in_range(src, usr) && istype(src.loc, /turf)))
		src.add_dialog(usr)

		switch(href_list["tp"])
			if("move")
				if(href_list["op"])
					var/obj/Z = locate(href_list["op"]) in src.contents
					var/turf/T = src.loc
					if (ismob(T))
						T = T.loc
					Z.set_loc(T)
					//parts.Remove(Z)


		updateDialog()
	else
		usr.Browse(null, "window=fkit")
		src.remove_dialog(usr)
	return

/obj/item/electronics/frame/proc/deploy(mob/user)
	var/turf/T = get_turf(src)
	var/obj/O = null
	if (deconstructed_thing)
		O = deconstructed_thing
		O.set_loc(T)
		O.dir = src.dir
		O.was_built_from_frame(user, 0)
		deconstructed_thing = null
	else
		O = new store_type(T)
		O.dir = src.dir
		O.was_built_from_frame(user, 1)
	//O.mats = "Built"
	O.deconstruct_flags |= DECON_BUILT
	qdel(src)

	return

/obj/item/electronics/frame/proc/drop_resources(obj/item/W as obj, mob/user as mob)
	var/datum/manufacture/mechanics/R = null

	if (src.deconstructed_thing)
		for (var/datum/manufacture/mechanics/M in manuf_controls.custom_schematics)
			if (M.frame_path == deconstructed_thing.type)
				R = M
				break
	else
		for (var/datum/manufacture/mechanics/M in manuf_controls.custom_schematics)
			if (M.frame_path == src.store_type)
				R = M
				break

	if (istype(R))
		var/looper = round(R.item_amounts[1] / 10, 1)
		while (looper > 0)
			var/obj/item/material_piece/mauxite/M = unpool(/obj/item/material_piece/mauxite)
			M.set_loc(get_turf(src))
			looper--
		looper = round(R.item_amounts[2] / 10, 1)
		while (looper > 0)
			var/obj/item/material_piece/pharosium/P = unpool(/obj/item/material_piece/pharosium)
			P.set_loc(get_turf(src))
			looper--
		looper = round(R.item_amounts[3] / 10, 1)
		while (looper > 0)
			var/obj/item/material_piece/molitz/M = unpool(/obj/item/material_piece/molitz)
			M.set_loc(get_turf(src))
			looper--
	else
		boutput(user, "<span class='alert'>Could not reclaim resources.</span>")
	qdel(src)

/datum/action/bar/icon/build_electronics_frame
	duration = 10
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	id = "build_electronics_frame"
	icon = 'icons/ui/actions.dmi'
	icon_state = "working"
	var/obj/item/electronics/frame/F

	New(Frame)
		F = Frame
		..()

	onUpdate()
		..()
		if(get_dist(owner, F) > 1 || F == null || owner == null)
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		if(get_dist(owner, F) > 1 || F == null || owner == null)
			interrupt(INTERRUPT_ALWAYS)
			return

	onEnd()
		..()
		if(get_dist(owner, F) > 1 || F == null || owner == null)
			interrupt(INTERRUPT_ALWAYS)
			return
		if(owner && F)
			F.deploy(owner)


/obj/item/electronics/frame/proc/parts_check()
//	if(src.contents.len != needed_parts.len)
//		return 0

	//for(var/tracker = 1, tracker <= parts:len, tracker ++)
	var/list/checkList = needed_parts.Copy()
	for(var/tracker = 1, tracker <= src.contents:len, tracker ++)
		var/partID
		//var/obj/T = parts[tracker]
		var/obj/T = src.contents[tracker]
		if(istype(T,/obj/item/electronics/battery))
			partID = "battery"
		else if(istype(T,/obj/item/electronics/fuse))
			partID = "fuse"
		else if(istype(T,/obj/item/electronics/switc))
			partID = "switch"
		else if(istype(T,/obj/item/electronics/capacitor))
			partID = "capacitor"
		else if(istype(T,/obj/item/electronics/resistor))
			partID = "resistor"
		else if(istype(T,/obj/item/electronics/bulb))
			partID = "bulb"
		else if(istype(T,/obj/item/electronics/relay))
			partID = "relay"
		else if(istype(T,/obj/item/electronics/board))
			partID = "board"
		else if(istype(T,/obj/item/electronics/keypad))
			partID = "keypad"
		else if(istype(T,/obj/item/electronics/screen))
			partID = "screen"
		else if(istype(T,/obj/item/electronics/buzzer))
			partID = "buzzer"

		if (!isnum(checkList[partID]) || (checkList[partID] < 1))
			continue

		checkList[partID] = checkList[partID] - 1

	for (var/i in checkList)
		if (checkList[i] > 0)
			return 0

	return 1

////////////////////////////////////////////////////////////////?
/obj/item/electronics/soldering
	name = "soldering iron"
	icon = 'icons/obj/electronics.dmi'
	icon_state = "solderingiron"
	force = 10
	hit_type = DAMAGE_BURN
	throwforce = 5
	w_class = 2.0
	pressure_resistance = 40
	module_research = list("electronics" = 3, "engineering" = 1)

	afterattack(atom/target as mob|obj|turf|area, mob/user as mob)
		if (!isobj(target))
			return
		var/obj/O = target
		var/decon_len = O.decon_contexts ? O.decon_contexts.len : 0
		O.decon_contexts = null
		if (O.build_deconstruction_buttons() != decon_len)
			boutput(user, "<span class='alert'>You repair [target]'s deconstructed state.</span>")
			return
		..()

////////////////////////////////////////////////////////////////no
/obj/item/electronics/disk
	name = "data module"
	icon_state = "disk"
	var/list/parts = new/list()
	var/item_name = "Error"

////////////////////////////////////////////////////////////////up
/obj/item/electronics/scanner
	name = "device analyzer"
	icon_state = "deviceana"
	desc = "Used for scanning certain items for use with the ruckingenur kit."
	force = 2
	hit_type = DAMAGE_BLUNT
	throwforce = 5
	w_class = 2.0
	pressure_resistance = 50
	var/list/scanned = list()
	var/viewstat = 0
	module_research = list("electronics" = 3, "engineering" = 3, "analysis" = 2)

	syndicate
		is_syndicate = 1

/obj/item/electronics/scanner/afterattack(var/obj/O, mob/user as mob)
	if(istype(O,/obj/machinery/rkit))
		return
	if(istype(O,/obj/))
		if(O.mats == 0 || O.disposed || (O.is_syndicate != 0 && src.is_syndicate == 0))
			// if this item doesn't have mats defined or was constructed or
			// attempting to scan a syndicate item and this is a normal scanner
			boutput(user, "<span class='alert'>The structure of this object is not compatible with the scanner.</span>")
			return

		user.visible_message("<B>[user.name]</B> scans [O].")

		var/final_type = O.mechanics_type_override ? O.mechanics_type_override : O.type

		for (var/X in src.scanned)
			if (final_type == X)
				boutput(user, "<span class='alert'>You have already scanned that object.</span>")
				return

		for(var/datum/electronics/scanned_item/I in mechanic_controls.scanned_items)
			if(final_type == I.item_type)
				boutput(user, "<span class='alert'>That object already exists in the scanned database.</span>")
				return
		animate_scanning(O, "#FFFF00")
		src.scanned += final_type
		boutput(user, "<span class='notice'>Item scan successful.</span>")

////////////////////////////////////////////////////////////////no
/obj/machinery/rkit
	name = "ruckingenur kit"
	desc = "Used for reverse engineering certain items."
	icon = 'icons/obj/electronics.dmi'
	icon_state = "rkit"
	anchored = 1
	density = 1
	//var/datum/electronics/electronics_items/link = null

	var/processing = 0
	var/net_id = null
	var/frequency = 1149
	var/datum/radio_frequency/radio_connection
	var/no_print_spam = 1 // In relation to world.time.

/obj/machinery/rkit/New()
	..()
	//link = mechanic_controls
	SPAWN_DBG(0.8 SECONDS)
		if(radio_controller)
			radio_connection = radio_controller.add_object(src, "[frequency]")
		if(!src.net_id)
			src.net_id = generate_net_id(src)
			mechanic_controls.rkit_addresses += src.net_id

/obj/machinery/rkit/disposing()
	if(radio_controller)
		radio_controller.remove_object(src, "[frequency]")
	radio_connection = null

	if (src.net_id)
		mechanic_controls.rkit_addresses -= src.net_id

	//link = null

	..()

/obj/machinery/rkit/receive_signal(datum/signal/signal)
	if(status & NOPOWER)
		return

	if(!signal || signal.encryption || !signal.data["sender"])
		return

	var/target = signal.data["sender"]
	if((signal.data["address_1"] == "ping") && target)
		SPAWN_DBG(0.5 SECONDS) //Send a reply for those curious jerks

			var/datum/signal/newsignal = get_free_signal()
			newsignal.source = src
			newsignal.transmission_method = TRANSMISSION_RADIO
			newsignal.data["command"] = "ping_reply"
			newsignal.data["device"] = "NET_RKANALZYER"
			newsignal.data["netid"] = src.net_id

			newsignal.data["address_1"] = target
			newsignal.data["sender"] = src.net_id

			radio_connection.post_signal(src, newsignal)

		return

	if(signal.data["address_1"] != src.net_id || !target || signal.data["command"] != "add" || !istype(signal.data_file, /datum/computer/file/electronics_scan))
		return

	var/datum/computer/file/electronics_scan/scanFile = signal.data_file
	for(var/datum/electronics/scanned_item/O in mechanic_controls.scanned_items)
		if(scanFile.scannedPath == O.item_type)
			SPAWN_DBG(0.5 SECONDS)

				var/datum/signal/newsignal = get_free_signal()
				newsignal.source = src
				newsignal.transmission_method = TRANSMISSION_RADIO
				newsignal.data["command"] = "text_message"
				newsignal.data["sender_name"] = "RKIT-MAILBOT"
				newsignal.data["message"] = "Notice: Item already in database."

				newsignal.data["address_1"] = target
				newsignal.data["sender"] = src.net_id

				radio_connection.post_signal(src, newsignal)
			return

	mechanic_controls.scan_in(scanFile.scannedName, scanFile.scannedPath, scanFile.scannedMats)
	SPAWN_DBG(0.5 SECONDS)

		var/datum/signal/newsignal = get_free_signal()
		newsignal.source = src
		newsignal.transmission_method = TRANSMISSION_RADIO
		newsignal.data["command"] = "text_message"
		newsignal.data["sender_name"] = "RKIT-MAILBOT"
		newsignal.data["message"] = "Notice: Item entered into database."

		newsignal.data["address_1"] = target
		newsignal.data["sender"] = src.net_id

		radio_connection.post_signal(src, newsignal)

/obj/machinery/rkit/attackby(obj/item/W as obj, mob/user as mob)
	if(status & (NOPOWER|BROKEN))
		return

	if(istype(W,/obj/item/electronics/scanner))
		var/obj/item/electronics/scanner/S = W
		var/add_count = 0
		var/match_check = 1
		for(var/X in S.scanned)
			match_check = 0
			for(var/datum/electronics/scanned_item/O in mechanic_controls.scanned_items)
				if(S.scanned == O.item_type)
					S.scanned -= X
					match_check = 1
					break
			if (!match_check)
				var/obj/tempobj = new X (src)
				mechanic_controls.scan_in(tempobj.name,tempobj.type,tempobj.mats)
				SPAWN_DBG(4 SECONDS)
					qdel(tempobj)
				S.scanned -= X
				add_count++

		if (add_count > 0)
			boutput(user, "<span class='notice'>[add_count] new items entered into kit.</span>")
		else
			boutput(user, "<span class='alert'>No new items entered into kit.</span>")

	else
		..()

/obj/machinery/rkit/attack_hand(mob/user as mob)
	src.add_fingerprint(user)
	var/dat
	dat = "<b>Ruckingenur Kit</b><HR>"

	dat += "<b>Scanned Items:</b><br>"
	for(var/datum/electronics/scanned_item/S in mechanic_controls.scanned_items)
		dat += "<u>[S.name]</u><small> "
		//dat += "<A href='?src=\ref[src];op=\ref[S];tp=done'>Frame</A>"
		if (S.blueprint)
			dat += " * <A href='?src=\ref[src];op=\ref[S];tp=blueprint'>Blueprint</A>"
		dat += "</small><br>"
	dat += "<br>"

	dat += "<HR>"

	src.add_dialog(user)
	user.Browse("<HEAD><TITLE>Ruckingenur Kit Control Panel</TITLE></HEAD><TT>[dat]</TT>", "window=rkit")
	onclose(user, "rkit")

/obj/machinery/rkit/Topic(href, href_list)
	if (usr.stat)
		return
	if ((in_range(src, usr) && istype(src.loc, /turf)) || (issilicon(usr)))
		src.add_dialog(usr)

		switch(href_list["tp"])

			if("done")
				if(href_list["op"])
					var/datum/electronics/scanned_item/O = locate(href_list["op"])
					if(istype(O,/datum/electronics/scanned_item/))
						var/obj/item/electronics/frame/F = new/obj/item/electronics/frame(src.loc)
						F.name = "[O.name]-frame"
						F.store_type = O.item_type
						F.needed_parts = O.item_mats

			if("blueprint")
				if(href_list["op"])
					if (src.no_print_spam && world.time < src.no_print_spam + 50)
						usr.show_text("[src] isn't done with the previous print job.", "red")
					else
						var/datum/electronics/scanned_item/O = locate(href_list["op"]) in mechanic_controls.scanned_items
						if (istype(O.blueprint, /datum/manufacture/mechanics/))
							usr.show_text("Print job started...", "blue")
							var/datum/manufacture/mechanics/M = O.blueprint
							playsound(src.loc, 'sound/machines/printer_thermal.ogg', 50, 1)
							src.no_print_spam = world.time
							SPAWN_DBG (50)
								if (src)
									new /obj/item/paper/manufacturer_blueprint(src.loc, M)

		updateDialog()
	else
		usr.Browse(null, "window=rkit")
		src.remove_dialog(usr)
	return

/obj/item/deconstructor
	name = "deconstruction device"
	desc = "A device meant to facilitate the deconstruction of scannable machines."
	icon = 'icons/obj/items/device.dmi'
	icon_state = "deconstruction-saw"
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	item_state = "deconstruction-saw"
	force = 10
	throwforce = 4
	hitsound = 'sound/machines/chainsaw_green.ogg'
	hit_type = DAMAGE_CUT
	tool_flags = TOOL_SAWING
	w_class = 3.0
	module_research = list("electronics" = 3, "engineering" = 1)

	proc/finish_decon(atom/target,mob/user)
		if (!isobj(target))
			return
		var/obj/O = target
		logTheThing("station", user, null, "deconstructs [target] in [user.loc.loc] ([showCoords(user.x, user.y, user.z)])")
		playsound(user.loc, 'sound/items/Deconstruct.ogg', 50, 1)
		user.visible_message("<B>[user.name]</B> deconstructs [target].")


		var/obj/item/electronics/frame/F = new(get_turf(target))
		F.name = "[target.name] frame"
		F.deconstructed_thing = target
		O.set_loc(F)
		F.viewstat = 2
		F.secured = 2
		F.icon_state = "dbox_big"
		F.w_class = 4

		elecflash(src,power=2)

		O.was_deconstructed_to_frame(user)

	MouseDrop_T(atom/target, mob/user)
		if (!isobj(target))
			return
		src.afterattack(target,user)
		..()

	afterattack(atom/target as mob|obj|turf|area, mob/user as mob)
		if (!isobj(target))
			return
		var/obj/O = target

		var/decon_complexity = O.build_deconstruction_buttons()
		if (!decon_complexity)
			boutput(user, "<span class='alert'>[target] cannot be deconstructed.</span>")
			if (O.deconstruct_flags & DECON_ACCESS)
				boutput(user, "<span class='alert'>[target] is under an access lock and must have its access requirements removed first.</span>")
			return

		if ((!O.allowed(user) || O.is_syndicate) && !(O.deconstruct_flags & DECON_BUILT))
			boutput(user, "<span class='alert'>You cannot deconstruct [target] without sufficient access to operate it.</span>")
			return

		if (isrestrictedz(O.z) && !isitem(target))
			boutput(user, "<span class='alert'>You cannot bring yourself to deconstruct [target] in this area.</span>")
			return

		if (O.decon_contexts && O.decon_contexts.len <= 0) //ready!!!
			boutput(user, "Deconstructing [O], please remain still...")
			playsound(user.loc, 'sound/effects/pop.ogg', 50, 1)
			actions.start(new/datum/action/bar/icon/deconstruct_obj(target,src,(decon_complexity * 2.5 SECONDS)), user)
		else
			user.showContextActions(O.decon_contexts, O)
			boutput(user, "<span class='alert'>You need to use some tools on [target] before it can be deconstructed.</span>")
			return

/obj/var/list/decon_contexts = null

/obj/disposing()
	if (src.decon_contexts)
		for(var/datum/contextAction/C in src.decon_contexts)
			C.dispose()
	..()

/obj/proc/was_deconstructed_to_frame(mob/user)
	.= 0

/obj/proc/was_built_from_frame(mob/user, newly_built)
	.= 0

/obj/proc/build_deconstruction_buttons()
	.= 0

	if (deconstruct_flags & DECON_ACCESS)
		if (src.has_access_requirements())
			return

	if (deconstruct_flags)
		.= 1

		if (src.decon_contexts != null)	//dont need rebuild
			return

		src.decon_contexts = list() //empty list would mean we are ready for deconstruction. otherwise you need to clear contexts by tool usage

		if (deconstruct_flags & DECON_SCREWDRIVER)
			var/datum/contextAction/deconstruction/screw/newcon = new
			decon_contexts += newcon
		if (deconstruct_flags & DECON_WRENCH)
			var/datum/contextAction/deconstruction/wrench/newcon = new
			decon_contexts += newcon
		if (deconstruct_flags & DECON_CROWBAR)
			var/datum/contextAction/deconstruction/pry/newcon = new
			decon_contexts += newcon
		if (deconstruct_flags & DECON_WELDER)
			var/datum/contextAction/deconstruction/weld/newcon = new
			decon_contexts += newcon
		if (deconstruct_flags & DECON_WIRECUTTERS)
			var/datum/contextAction/deconstruction/cut/newcon = new
			decon_contexts += newcon
		if (deconstruct_flags & DECON_MULTITOOL)
			var/datum/contextAction/deconstruction/pulse/newcon = new
			decon_contexts += newcon

		.+= decon_contexts.len


/datum/action/bar/icon/deconstruct_obj
	duration = 20
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	id = "deconstruct_obj"
	icon = 'icons/ui/actions.dmi'
	icon_state = "decon"
	var/obj/O
	var/obj/item/deconstructor/D
	New(Obj, Decon, ExtraTime)
		O = Obj
		D = Decon
		duration += ExtraTime
		..()

	onUpdate()
		..()
		if(get_dist(owner, O) > 1 || O == null || owner == null || D == null)
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		if(get_dist(owner, O) > 1 || O == null || owner == null || D == null)
			interrupt(INTERRUPT_ALWAYS)
			return

	onEnd()
		..()
		if(get_dist(owner, O) > 1 || O == null || owner == null || D == null)
			interrupt(INTERRUPT_ALWAYS)
			return
		if (ismob(owner))
			var/mob/M = owner
			if (!(D in M.equipped_list()))
				interrupt(INTERRUPT_ALWAYS)
				return
		D.finish_decon(O,owner)

	onInterrupt()
		if (O && owner)
			boutput(owner, "<span class='alert'>Deconstruction of [O] interrupted!</span>")
		..()

/obj/item/deconstructor/borg
	name = "deconstruction device"
	desc = "A device meant to facilitate the deconstruction of scannable machines. This one has been modified for safe use by borgs."
	icon = 'icons/obj/items/device.dmi'
	icon_state = "deconstruction"
	force = 0
	throwforce = 0
	hitsound = 'sound/impact_sounds/Generic_Hit_1.ogg'
	hit_type = DAMAGE_BLUNT
	tool_flags = null
	w_class = 3.0
