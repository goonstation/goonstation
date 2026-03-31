//Motherboard is just used in assembly/disassembly, doesn't exist in the actual computer object.
TYPEINFO(/obj/item/motherboard)
	mats = 8

/obj/item/motherboard
	name = "Computer mainboard"
	desc = "A computer motherboard."
	icon = 'icons/obj/module.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	icon_state = "mainboard"
	item_state = "electronics"
	w_class = W_CLASS_SMALL
	var/created_name = null //If defined, result computer will have this name.
	var/integrated_floppy = 1 //Does the resulting computer have a built-in disk drive?
	var/font_color = "#19A319"
	var/bg_color = "#1B1E1B"
	var/bios_version = "<b>Thinktronic BIOS V2.1</b>"

/obj/item/motherboard/New()
	..()
	if (prob(60))
		switch(rand(1,2))
			if(1)
				font_color = "#E79C01"
			if(2)
				font_color = "#A5A5FF"
				bg_color = "#4242E7"

/obj/item/motherboard/clone()
	var/obj/item/motherboard/myclone = ..()
	if (!myclone)
		return

	myclone.font_color = src.font_color
	myclone.bg_color = src.bg_color

	return myclone


/obj/computer3frame
	density = 1
	anchored = UNANCHORED
	name = "Computer-frame"
	icon = 'icons/obj/computer_frame.dmi'
	icon_state = "0"
	material_amt = 0.5
	var/state = 0
	var/obj/item/motherboard/mainboard = null
	var/obj/item/disk/data/fixed_disk/hd = null
	var/max_peripherals = 3
	var/list/peripherals = list()
	var/created_icon_state = "computer_generic"
	var/computer_type = /obj/machinery/computer3
	var/glass_needed = 2 //How much glass does this need for a screen?
	var/metal_given = 5 //How much metal does this give when destroyed?

	terminal //Light frame
		name = "Terminal-frame"
		desc = "A light micro-computer frame used for terminal systems."
		icon = 'icons/obj/terminal_frame.dmi'
		created_icon_state = "dterm"
		computer_type = /obj/machinery/computer3/terminal
		material_amt = 0.3
		max_peripherals = 2
		metal_given = 3
		glass_needed = 1

	desktop //Those old desktop computers
		name = "Desktop Computer-frame"
		icon = 'icons/obj/computer_frame_desk.dmi'
		created_icon_state = "old"
		computer_type = /obj/machinery/computer3/generic/personal/personel_alt
		max_peripherals = 3
		metal_given = 3
		glass_needed = 1
		object_flags = NO_BLOCK_TABLE


	azungarcomputer_upper
		name = "Terminal Frame"
		icon = 'icons/obj/computerpanel_upper.dmi'
		created_icon_state = "4"
		max_peripherals = 3
		metal_given = 3
		glass_needed = 1

	azungarcomputer_lower
		name = "Terminal Frame"
		icon = 'icons/obj/computerpanel_lower.dmi'
		created_icon_state = "4"
		max_peripherals = 3
		metal_given = 3
		glass_needed = 1

	blob_act(var/power)
		if (prob(power * 2.5))
			qdel(src)

/obj/computer3frame/attack_hand(mob/user)
	if(..() || !src.maint_accessible(user))
		return

	src.add_dialog(user)

	var/dat = "<html><head><title>[name]</title></head><body>"

	dat += "<hr>"
	if(src.mainboard)
		dat += "<tt>Motherboard: [src.mainboard.name]</tt>"
	else
		dat += "<tt>Motherboard: ----</tt>"

	if(hd)
		dat += "<br><tt>Hard Drive: [hd.name]</tt> <a href='byond://?src=\ref[src];driveRemove=1'>(Remove)</a><br>"
	else if(src.state >= 3)
		dat += "<br><tt>Hard Drive: <a href='byond://?src=\ref[src];driveAdd=1'>----</a><br></tt>"
	else
		dat += "<br><tt>Hard Drive: ----</tt><br>"

	dat += "<hr>"
	dat += "<b>Peripherals:</b> [length(src.peripherals)]/[src.max_peripherals]<br>"

	for (var/i in 1 to length(src.peripherals))
		var/obj/item/peripheral/P = src.peripherals[i]
		var/cant_remove_reason = ""
		if(astype(P, /obj/item/peripheral/card_scanner)?.authid)
			cant_remove_reason = "Card inserted." //#BlameGlowbold
		if(!cant_remove_reason)
			dat += "&nbsp;&nbsp;- [P.name] <a href='byond://?src=\ref[src];periphID=[i]'>(Remove)</a><br>"
		else
			dat += "&nbsp;&nbsp;- [P.name] <s>(Remove)</s> <i>[cant_remove_reason]</i><br>"

	for (var/i in 1 to (src.max_peripherals - length(src.peripherals)))
		if(src.state >= 2)
			dat += "&nbsp;&nbsp;<a href='byond://?src=\ref[src];addPeriph=1'>----</a><br>"
		else
			dat += "&nbsp;&nbsp;----<br>"

	user.Browse(dat,"window=computer;size=320x245")
	onclose(user,"computer")
	return

/obj/computer3frame/Topic(href, href_list)
	if(..())
		return

	src.add_dialog(usr)

	if(src.maint_accessible(usr) && can_act(usr) && !usr.lying)
		var/periphID = text2num(href_list["periphID"])
		if (periphID > 0 && periphID <= length(src.peripherals))
			var/obj/item/peripheral/peri = src.peripherals[periphID]

			peri.uninstalled()
			usr.put_in_hand_or_drop(peri)
			src.peripherals.Remove(peri)

			boutput(usr, SPAN_NOTICE("You remove the [peri] from the frame."))

			src.updateUsrDialog()

		if (href_list["addPeriph"])
			src.insert_periph(usr.equipped(),usr)

		if(href_list["driveRemove"])
			if(src.hd)
				usr.put_in_hand_or_drop(src.hd)
				boutput(usr, SPAN_NOTICE("You remove the drive."))
				src.hd = null

			src.updateUsrDialog()

		if(href_list["driveAdd"] && src.state >= 3)
			var/obj/item/disk/data/fixed_disk/P = usr.equipped()
			if(istype(P, /obj/item/disk/data/fixed_disk) && !src.hd)
				usr.drop_item()
				src.hd = P
				P.set_loc(src)
				boutput(usr, SPAN_NOTICE("You connect the drive to the cabling."))
			src.updateUsrDialog()

	src.add_fingerprint(usr)
	return

/obj/computer3frame/meteorhit(obj/O as obj)
	qdel(src)

/obj/computer3frame/attackby(obj/item/P, mob/user)
	var/datum/action/bar/icon/callback/action_bar = new /datum/action/bar/icon/callback(user, src, 2 SECONDS, /obj/computer3frame/proc/state_actions,\
	list(P,user), P.icon, P.icon_state, null)

	//We can slap in periphs at any point as long as maint is accessible
	if (istype(P, /obj/item/peripheral) && src.maint_accessible(user))
		src.insert_periph(P,user)
		return

	switch(state)
		if(0)
			if(iswrenchingtool(P))
				playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
				actions.start(action_bar, user)
			if(isweldingtool(P) && P:try_weld(user,0,-1) )
				actions.start(action_bar, user)
		if(1)
			if (iswrenchingtool(P))
				playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
				actions.start(action_bar, user)
			if (istype(P, /obj/item/motherboard) && !mainboard)
				playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
				boutput(user, SPAN_NOTICE("You place the mainboard inside the frame."))
				src.icon_state = "1"
				src.mainboard = P
				user.drop_item()
				P.set_loc(src)
			else if (istype(P, /obj/item/circuitboard) && !mainboard && istype_exact(src,/obj/computer3frame))
				var/obj/computerframe/new_computer = new(src.loc)
				new_computer.state = 1
				new_computer.anchored = src.anchored
				new_computer.dir = src.dir
				new_computer.setMaterial(src.material)
				new_computer.Attackby(P, user)
				qdel(src)
			if (isscrewingtool(P) && mainboard)
				playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
				boutput(user, SPAN_NOTICE("You screw the mainboard into place."))
				src.state = 2
				src.icon_state = "2"
			if (ispryingtool(P) && mainboard)
				playsound(src.loc, 'sound/items/Crowbar.ogg', 50, 1)
				boutput(user, SPAN_NOTICE("You remove the mainboard."))
				src.state = 1
				src.icon_state = "0"
				mainboard.set_loc(src.loc)
				src.mainboard = null

		if(2)
			if (isscrewingtool(P) && mainboard)
				if(length(src.peripherals) <= 0)
					playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
					boutput(user, SPAN_NOTICE("You unfasten the mainboard."))
					src.state = 1
					src.icon_state = "1"
				else
					boutput(user, SPAN_ALERT("Remove peripheral boards first."))


			if (ispryingtool(P) && length(src.peripherals) > 0)
				playsound(src.loc, 'sound/items/Crowbar.ogg', 50, 1)
				boutput(user, SPAN_NOTICE("You remove the peripheral boards."))
				for(var/obj/item/peripheral/W in src.peripherals)
					W.set_loc(src.loc)
					src.peripherals.Remove(W)
					W.uninstalled()
				src.updateUsrDialog()

			if (istype(P, /obj/item/cable_coil))
				if (P.amount >= 5)
					playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
					actions.start(action_bar, user)
		if(3)
			if (issnippingtool(P))
				playsound(src.loc, 'sound/items/Wirecutter.ogg', 50, 1)
				boutput(user, SPAN_NOTICE("You remove the cables."))
				src.state = 2
				src.icon_state = "2"
				var/obj/item/cable_coil/A = new /obj/item/cable_coil( src.loc )
				A.amount = 5
				A.UpdateIcon()
				if(src.hd)
					src.hd.set_loc(src.loc)
					src.hd = null
					src.updateUsrDialog()

			if (istype(P, /obj/item/disk/data/fixed_disk) && !src.hd)
				user.drop_item()
				src.hd = P
				P.set_loc(src)
				boutput(user, SPAN_NOTICE("You connect the drive to the cabling."))
				src.updateUsrDialog()

			if (ispryingtool(P) && src.hd)
				playsound(src.loc, 'sound/items/Crowbar.ogg', 50, 1)
				boutput(user, SPAN_NOTICE("You remove the hard drive."))
				src.hd.set_loc(src.loc)
				src.hd = null
				src.updateUsrDialog()

			if (istype(P, /obj/item/sheet))
				var/obj/item/sheet/S = P
				if (S.material && S.material.getMaterialFlags() & MATERIAL_CRYSTAL)
					if (S.amount >= src.glass_needed)
						playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
						actions.start(action_bar, user)
					else
						boutput(user, SPAN_ALERT("There's not enough sheets on the stack."))
				else
					boutput(user, SPAN_ALERT("You need sheets of some kind of crystal or glass for this."))
		if(4)
			if (ispryingtool(P))
				playsound(src.loc, 'sound/items/Crowbar.ogg', 50, 1)
				boutput(user, SPAN_NOTICE("You remove the glass panel."))
				src.state = 3
				src.icon_state = "3"
				var/obj/item/sheet/glass/A = new /obj/item/sheet/glass(src.loc)
				A.amount = src.glass_needed

			else if (isscrewingtool(P))
				playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
				boutput(user, SPAN_NOTICE("You connect the monitor."))
				if(!ispath(computer_type, /obj/machinery/computer3))
					src.computer_type = /obj/machinery/computer3
				var/obj/machinery/computer3/C= new src.computer_type( src.loc )
				C.set_dir(src.dir)
				if(src.material) C.setMaterial(src.material)
				C.icon_state = src.created_icon_state
				C.setup_frame_type = src.type
				if(src.mainboard)
					C.mainboard = src.mainboard
					if(mainboard.integrated_floppy) C.setup_has_internal_disk = 1

				if(hd)
					C.hd = hd
					hd.set_loc(C)
				for(var/obj/item/peripheral/W in src.peripherals)
					W.set_loc(C)
					W.installed(C) //Set C as their host, etc
				//dispose()
				src.dispose()
			else
				return src.attack_hand(user)

/obj/computer3frame/proc/state_actions(obj/item/P, mob/user)
	switch(state)
		if(0)
			if(user.equipped(P) && iswrenchingtool(P))
				boutput(user, SPAN_NOTICE("You wrench the frame into place."))
				src.anchored = ANCHORED
				src.state = 1
			if(user.equipped(P) && isweldingtool(P))
				boutput(user, SPAN_NOTICE("You deconstruct the frame."))
				src.eject_all(FALSE)
				var/obj/item/sheet/A = new /obj/item/sheet( src.loc )
				A.amount = metal_given
				if (src.material)
					A.setMaterial(src.material)
				else
					var/datum/material/M = getMaterial("steel")
					A.setMaterial(M)
				qdel(src)
		if(1)
			if(user.equipped(P) && iswrenchingtool(P))
				boutput(user, SPAN_NOTICE("You unfasten the frame."))
				src.anchored = UNANCHORED
				src.state = 0
		if(2)
			if(user.equipped(P) && istype(P, /obj/item/cable_coil))
				var/obj/item/cable_coil/coil = P
				if (coil?.use(5))
					boutput(user, SPAN_NOTICE("You add cables to the frame."))
					src.state = 3
					src.icon_state = "3"
		if(3)
			if(user.equipped(P) && istype(P, /obj/item/sheet))
				boutput(user, SPAN_NOTICE("You put in the glass panel."))
				P.change_stack_amount(-glass_needed)
				src.state = 4
				src.icon_state = "4"

/obj/computer3frame/bullet_act(obj/projectile/P)
	. = ..()
	switch (P.proj_data.damage_type)
		if (D_KINETIC, D_PIERCING, D_SLASHING)
			if (prob(P.power))
				switch(state)
					if(0)
						new /obj/item/scrap(src.loc)
						src.eject_all(TRUE) //Shouldn't come up but just for sanity's sake
						qdel(src)
					if(1)
						if(src.mainboard)
							src.eject_mainboard(TRUE)
						else
							src.anchored = UNANCHORED
							src.state = 0
					if(2)
						if(length(src.peripherals))
							src.eject_peripherals(TRUE)
						else if(src.mainboard)
							src.eject_mainboard(TRUE)
					if(3)
						if (src.hd)
							src.eject_harddrives(TRUE)
						else
							var/obj/item/cable_coil/debris = new /obj/item/cable_coil(src.loc)
							debris.amount = 1
							debris.UpdateIcon()
							debris.throw_at(get_offset_target_turf(src, rand(5)-rand(5), rand(5)-rand(5)), rand(2,4), 2)
							src.state = 2
							src.icon_state = "2"
					if(4)
						var/obj/item/raw_material/shard/glass/debris = new /obj/item/raw_material/shard/glass(src.loc)
						debris.throw_at(get_offset_target_turf(src, rand(5)-rand(5), rand(5)-rand(5)), rand(2,4), 2)
						src.state = 3
						src.icon_state = "3"

/obj/computer3frame/proc/eject_all(fling)
	src.eject_mainboard(fling)
	src.eject_harddrives(fling)
	src.eject_peripherals(fling)

/obj/computer3frame/proc/eject_mainboard(fling)
	if(isnull(src.mainboard)) return
	src.mainboard.set_loc(get_turf(src))
	if(fling)
		src.mainboard.throw_at(get_offset_target_turf(src, rand(5)-rand(5), rand(5)-rand(5)), rand(2,4), 2)
	src.mainboard = null
	src.state = 1
	src.icon_state = "1"

/obj/computer3frame/proc/eject_harddrives(fling)
	if(isnull(src.hd))
		return
	src.hd.set_loc(get_turf(src))
	if(fling)
		src.hd.throw_at(get_offset_target_turf(src, rand(5)-rand(5), rand(5)-rand(5)), rand(2,4), 2)
	src.hd = null

/obj/computer3frame/proc/eject_peripherals(fling)
	if (length(src.peripherals) == 0) return
	for(var/obj/item/peripheral/peripheral in src.peripherals)
		peripheral.set_loc(get_turf(src))
		if(fling)
			peripheral.throw_at(get_offset_target_turf(src, rand(5)-rand(5), rand(5)-rand(5)), rand(2,4), 2)
		src.peripherals.Remove(peripheral)
		peripheral.uninstalled()

/obj/computer3frame/proc/maint_accessible(mob/user)
	return (src.state >= 2 && BOUNDS_DIST(src, user) <= 0)

/obj/computer3frame/proc/insert_periph(obj/item/peripheral/P, mob/user)
	if(!istype(P))
		return
	if(length(src.peripherals) < src.max_peripherals)
		user.drop_item()
		src.peripherals.Add(P)
		P.set_loc(src)
		boutput(user, SPAN_NOTICE("You add \the [P] to the frame."))
		src.updateUsrDialog()
	else
		boutput(user, SPAN_ALERT("There is no more room for peripheral cards."))
