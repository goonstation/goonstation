//Motherboard is just used in assembly/disassembly, doesn't exist in the actual computer object.
/obj/item/motherboard
	name = "Computer mainboard"
	desc = "A computer motherboard."
	icon = 'icons/obj/module.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	icon_state = "mainboard"
	item_state = "electronic"
	w_class = 2.0
	var/created_name = null //If defined, result computer will have this name.
	var/integrated_floppy = 1 //Does the resulting computer have a built-in disk drive?
	mats = 8

/obj/computer3frame
	density = 1
	anchored = 0
	name = "Computer-frame"
	icon = 'icons/obj/computer_frame.dmi'
	icon_state = "0"
	var/state = 0
	var/obj/item/motherboard/mainboard = null
	var/obj/item/disk/data/fixed_disk/hd = null
	var/max_peripherals = 3
	var/list/peripherals = list()
	var/created_icon_state = "computer_generic"
	var/glass_needed = 2 //How much glass does this need for a screen?
	var/metal_given = 5 //How much metal does this give when destroyed?

	terminal //Light frame
		name = "Terminal-frame"
		desc = "A light micro-computer frame used for terminal systems."
		icon = 'icons/obj/terminal_frame.dmi'
		created_icon_state = "dterm"
		max_peripherals = 2
		metal_given = 3
		glass_needed = 1

	desktop //Those old desktop computers
		name = "Desktop Computer-frame"
		icon = 'icons/obj/computer_frame_desk.dmi'
		created_icon_state = "old"
		max_peripherals = 3
		metal_given = 3
		glass_needed = 1


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

/obj/computer3frame/meteorhit(obj/O as obj)
	qdel(src)

/obj/computer3frame/attackby(obj/item/P as obj, mob/user as mob)
	switch(state)
		if(0)
			if (iswrenchingtool(P))
				playsound(src.loc, "sound/items/Ratchet.ogg", 50, 1)
				if(do_after(user, 2 SECONDS))
					boutput(user, "<span class='notice'>You wrench the frame into place.</span>")
					src.anchored = 1
					src.state = 1
			if(isweldingtool(P))
				playsound(src.loc, "sound/items/Welder.ogg", 50, 1)
				if(do_after(user, 2 SECONDS))
					boutput(user, "<span class='notice'>You deconstruct the frame.</span>")
					var/obj/item/sheet/A = new /obj/item/sheet( src.loc )
					if(src.material)
						A.setMaterial(src.material)
					else
						var/datum/material/M = getMaterial("steel")
						A.setMaterial(M)
					A.amount = src.metal_given
					qdel(src)
		if(1)
			if (iswrenchingtool(P))
				playsound(src.loc, "sound/items/Ratchet.ogg", 50, 1)
				if(do_after(user, 2 SECONDS))
					boutput(user, "<span class='notice'>You unfasten the frame.</span>")
					src.anchored = 0
					src.state = 0
			if (istype(P, /obj/item/motherboard) && !mainboard)
				playsound(src.loc, "sound/items/Deconstruct.ogg", 50, 1)
				boutput(user, "<span class='notice'>You place the mainboard inside the frame.</span>")
				src.icon_state = "1"
				src.mainboard = P
				user.drop_item()
				P.set_loc(src)
			if (isscrewingtool(P) && mainboard)
				playsound(src.loc, "sound/items/Screwdriver.ogg", 50, 1)
				boutput(user, "<span class='notice'>You screw the mainboard into place.</span>")
				src.state = 2
				src.icon_state = "2"
			if (ispryingtool(P) && mainboard)
				playsound(src.loc, "sound/items/Crowbar.ogg", 50, 1)
				boutput(user, "<span class='notice'>You remove the mainboard.</span>")
				src.state = 1
				src.icon_state = "0"
				mainboard.set_loc(src.loc)
				src.mainboard = null
			if (istype(P, /obj/item/circuitboard))
				boutput(user, "<span class='alert'>This is the wrong type of frame, it won't fit!</span>")

		if(2)
			if (isscrewingtool(P) && mainboard && (!peripherals.len))
				playsound(src.loc, "sound/items/Screwdriver.ogg", 50, 1)
				boutput(user, "<span class='notice'>You unfasten the mainboard.</span>")
				src.state = 1
				src.icon_state = "1"

			if (istype(P, /obj/item/peripheral))
				if(src.peripherals.len < src.max_peripherals)
					user.drop_item()
					src.peripherals.Add(P)
					P.set_loc(src)
					boutput(user, "<span class='notice'>You add [P] to the frame.</span>")
				else
					boutput(user, "<span class='alert'>There is no more room for peripheral cards.</span>")

			if (ispryingtool(P) && src.peripherals.len)
				playsound(src.loc, "sound/items/Crowbar.ogg", 50, 1)
				boutput(user, "<span class='notice'>You remove the peripheral boards.</span>")
				for(var/obj/item/peripheral/W in src.peripherals)
					W.set_loc(src.loc)
					src.peripherals.Remove(W)
					W.uninstalled()

			if (istype(P, /obj/item/cable_coil))
				if(P:amount >= 5)
					playsound(src.loc, "sound/items/Deconstruct.ogg", 50, 1)
					if(do_after(user, 2 SECONDS))
						if (!P) //Wire: Fix for Cannot read null.amount
							return
						P:amount -= 5
						if(!P:amount) qdel(P)
						boutput(user, "<span class='notice'>You add cables to the frame.</span>")
						src.state = 3
						src.icon_state = "3"
		if(3)
			if (issnippingtool(P))
				playsound(src.loc, "sound/items/Wirecutter.ogg", 50, 1)
				boutput(user, "<span class='notice'>You remove the cables.</span>")
				src.state = 2
				src.icon_state = "2"
				var/obj/item/cable_coil/A = new /obj/item/cable_coil( src.loc )
				A.amount = 5
				if(src.hd)
					src.hd.set_loc(src.loc)
					src.hd = null

			if (istype(P, /obj/item/disk/data/fixed_disk) && !src.hd)
				user.drop_item()
				src.hd = P
				P.set_loc(src)
				boutput(user, "<span class='notice'>You connect the drive to the cabling.</span>")

			if (ispryingtool(P) && src.hd)
				playsound(src.loc, "sound/items/Crowbar.ogg", 50, 1)
				boutput(user, "<span class='notice'>You remove the hard drive.</span>")
				src.hd.set_loc(src.loc)
				src.hd = null

			if (istype(P, /obj/item/sheet))
				var/obj/item/sheet/S = P
				if (S.material && S.material.material_flags & MATERIAL_CRYSTAL)
					if (S.amount >= src.glass_needed)
						playsound(src.loc, "sound/items/Deconstruct.ogg", 50, 1)
						if(do_after(user, 2 SECONDS) && S)
							S.amount -= src.glass_needed
							if(S.amount < 1)
								qdel(S)
							boutput(user, "<span class='notice'>You put in the glass panel.</span>")
							src.state = 4
							src.icon_state = "4"
					else
						boutput(user, "<span class='alert'>There's not enough sheets on the stack.</span>")
				else
					boutput(user, "<span class='alert'>You need sheets of some kind of crystal or glass for this.</span>")
		if(4)
			if (ispryingtool(P))
				playsound(src.loc, "sound/items/Crowbar.ogg", 50, 1)
				boutput(user, "<span class='notice'>You remove the glass panel.</span>")
				src.state = 3
				src.icon_state = "3"
				var/obj/item/sheet/glass/A = new /obj/item/sheet/glass(src.loc)
				A.amount = src.glass_needed

			if (isscrewingtool(P))
				playsound(src.loc, "sound/items/Screwdriver.ogg", 50, 1)
				boutput(user, "<span class='notice'>You connect the monitor.</span>")
				var/obj/machinery/computer3/C= new /obj/machinery/computer3( src.loc )
				if(src.material) C.setMaterial(src.material)
				C.setup_drive_size = 0
				C.icon_state = src.created_icon_state
				C.setup_frame_type = src.type
				if(mainboard.created_name) C.name = mainboard.created_name
				if(mainboard.integrated_floppy) C.setup_has_internal_disk = 1
				//qdel(mainboard)
				mainboard.dispose()
				if(hd)
					C.hd = hd
					hd.set_loc(C)
				for(var/obj/item/peripheral/W in src.peripherals)
					W.set_loc(C)
					W.installed(C) //Set C as their host, etc
				//dispose()
				src.dispose()
