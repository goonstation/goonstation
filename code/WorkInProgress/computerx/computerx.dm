//CONTENTS:
//Computerx-related globals
//Computerx machine object
//Computerx input client verb


var/obj/compx_icon/spacer/compx_grid_spacer = null
var/compx_gridy_max = 8
var/compx_gridx_max = 5

/obj/machinery/computerx
	name = "computer"
	desc = "A computer that uses a bleeding-edge command line OS."
	icon = 'icons/obj/computer.dmi'
	icon_state = "computer_generic"
	density = 1
	anchored = 1
	power_usage = 250
	var/base_icon_state = "computer_generic"
	var/datum/computer/file/terminalx_program/os/host_program //Our best pal, the operating system!
	var/list/processing_programs = list()
	var/list/peripherals = list()
	var/restarting = 0 //Are we currently restarting the system?
	var/obj/item/disk/data/fixed_disk/hd =  null
	var/setup_bg_color = "#1B1E1B"
	var/graphic_mode = 0 //0: Default browser 1: the window specified by the program.
	var/override_temp = null

	var/setup_starting_os = /datum/computer/file/terminalx_program/os/main_os
	var/setup_starting_drive = /obj/item/peripheralx/drive //Do we spawn with a disk?
	var/setup_drive_size = 64
	var/setup_drive_type = /obj/item/disk/data/fixed_disk/computer3 //Use this path for the hd
	var/setup_os_string = null
	var/setup_starting_peripheral0 = /obj/item/peripheralx/card_scanner //It is advised that this be a card scanner.
	var/setup_starting_peripheral1 = /obj/item/peripheralx/drive
	var/setup_starting_peripheral2 = /obj/item/peripheralx/drive

	New()
		..()

		if(!compx_grid_spacer)
			compx_grid_spacer = new

		SPAWN(0.4 SECONDS)
			if(ispath(src.setup_starting_drive))
				new src.setup_starting_drive(src)

			if(ispath(src.setup_starting_peripheral0))
				new src.setup_starting_peripheral0(src)

			if(ispath(src.setup_starting_peripheral1))
				new src.setup_starting_peripheral1(src) //Peripherals add themselves automatically if spawned inside a computer.

			if(ispath(src.setup_starting_peripheral2))
				new src.setup_starting_peripheral2(src)

			if(!hd && (setup_drive_size > 0))
				if(src.setup_drive_type)
					src.hd = new src.setup_drive_type
					src.hd.set_loc(src)
				else
					src.hd = new /obj/item/disk/data/fixed_disk(src)
				src.hd.file_amount = src.setup_drive_size

			if(ispath(src.setup_starting_os) && src.hd)
				var/datum/computer/file/terminalx_program/os/os = new src.setup_starting_os
				if((src.hd.root.size + os.size) >= src.hd.file_amount)
					src.hd.file_amount += os.size

				os.setup_string = src.setup_os_string
				src.host_program = os
				src.host_program.master = src
				src.processing_programs += src.host_program

				src.hd.root.add_file(os)

			src.base_icon_state = src.icon_state

			src.post_system()
		return


	process()
		if(status & (NOPOWER|BROKEN))
			return
		..()
		for(var/datum/computer/file/terminalx_program/P in src.processing_programs)
			P.process()

		return

	attack_hand(mob/user)
		if(..())
			return

		src.add_dialog(user)
		src.current_user = user

		var/wincheck = winexists(user, "compx_\ref[src]")
		//boutput(world, wincheck)
		if(wincheck != "MAIN")
			winclone(user, "compx", "compx_\ref[src]")
			winset(user, "compx_\ref[src].restart","command=\".compcommand \\\"\ref[src]%restart\"")
			winset(user, "compx_\ref[src].conin","command=\".compconsole \\\"\ref[src]\\\" \\\"")

		var/display_mode = src.graphic_mode
		var/workingTemp = null
		if(!src.host_program)
			display_mode = 0
		else
			workingTemp = src.host_program.get_temp()

		set_graphic_mode(src.graphic_mode, user)
		var/display_text = "DISPLAY ERROR -- 0xF8"

		if(display_mode)
			if(istype(workingTemp, /datum/compx_window))
			/*
				for(var/gridy = 1, gridy <= src.host_program.gridy_max, gridy++)
					for(var/gridx = 1, gridx <= src.host_program.gridx_max, gridx++)
						if(isnull(workingTemp[gridx][gridy]))
							user << output(compx_grid_spacer, "compx_\ref[src].grid:[gridx],[gridy]")
						else
							user << output(workingTemp[gridx][gridy], "compx_\ref[src].grid:[gridx],[gridy]")
			*/
				var/datum/compx_window/windowControl = workingTemp
				if (!winexists(user, "compxwindow_\ref[windowControl]"))
					winclone(user, windowControl.skinbase, "compxwindow_\ref[windowControl]")
					winset(user, "compxwindow_\ref[windowControl]", "is-visible=true")
				winset(user, "compx_\ref[src].screenholder","left=compxwindow_\ref[windowControl]")
				windowControl.update(user)
			else
				user << output(user, "compx_\ref[src].grid")

		else
			if(src.host_program && istext(workingTemp))
				display_text = workingTemp
			if(src.override_temp)
				display_text = src.override_temp
			user << output("<body bgcolor=[src.setup_bg_color] scroll=no><font color=#19A319><tt>[display_text]</tt></font>", "compx_\ref[src].screen")

		//Now for the peripheral interfaces.
		var/pcount = 1
		for(var/obj/item/peripheralx/px in src.peripherals)
			if(pcount > 4)
				break
			if(px.setup_has_badge) //Only put it up if it actually has something to present.
				user << output(px.return_badge(), "compx_\ref[src].periphs:[pcount],1")
				pcount++

		winshow(user,"compx_\ref[src]",1)

		onclose(user,"compx_\ref[src]")
		return

	Topic(href, href_list)
		if(..())
			return

		src.add_dialog(usr)

		if((href_list["conin"]) && src.host_program)
			src.host_program.input_text(href_list["conin"])

		else if(href_list["restart"] && !src.restarting)
			src.restart()

		src.add_fingerprint(usr)
		src.updateUsrDialog()
		return


	power_change()
		if(status & BROKEN)
			icon_state = src.base_icon_state
			src.icon_state += "b"

		else if(powered())
			icon_state = src.base_icon_state
			status &= ~NOPOWER
		else
			SPAWN(rand(0, 15))
				icon_state = src.base_icon_state
				src.icon_state += "0"
				status |= NOPOWER

	meteorhit(var/obj/O as obj)
		if(status & BROKEN)	qdel(src)
		set_broken()
		var/datum/effects/system/harmless_smoke_spread/smoke = new /datum/effects/system/harmless_smoke_spread()
		smoke.set_up(5, 0, src)
		smoke.start()
		return

	ex_act(severity)
		switch(severity)
			if(1)
				qdel(src)
				return
			if(2)
				if (prob(50))
					set_broken()
			if(3)
				if (prob(25))
					set_broken()
			else
		return

	blob_act(var/power)
		if (prob(power * 2.5))
			set_broken()
			src.set_density(0)

	proc
		set_broken()
			icon_state = src.base_icon_state
			icon_state += "b"
			status |= BROKEN

		set_graphic_mode(var/new_mode = 0, mob/user as mob)
			if(!user || !user.client)
				return
			//boutput(world, "The new mode is: [new_mode].")
			if (src.graphic_mode)
				winset(user, "compx_\ref[src].screen","is-visible=false")
				//winset(user, "compx_\ref[src].conin","is-visible=true")
				//winset(user, "compx_\ref[src].grid","is-visible=false")
			else
				winset(user, "compx_\ref[src].screen","is-visible=true")
				//winset(user, "compx_\ref[src].conin","is-visible=false")
				//winset(user, "compx_\ref[src].grid","is-visible=true")

			src.graphic_mode = new_mode
			return

		run_program(datum/computer/file/terminalx_program/program)
			if((!program) || (!program.holder))
				return 0

			if(!(program.holder in src) && !(program.holder.loc in src) && src.hd)
		//		boutput(world, "Not in src")
				program = new program.type
				program.transfer_holder(src.hd)

			if(program.master != src)
				program.master = src

			if(!src.host_program && istype(program, /datum/computer/file/terminalx_program/os))
				src.host_program = program

			if(!(program in src.processing_programs))
				src.processing_programs += program

			program.initialize()
			return 1

		//Stop processing a program (Unless it's the OS!!)
		unload_program(datum/computer/file/terminalx_program/program)
			if(!program)
				return 0

			if(program == src.host_program)
				return 0

			src.processing_programs -= program
			return 1

		delete_file(datum/computer/file/file)
			if((!file) || (!file.holder) || (file.holder.read_only))
				return 0

			//Don't delete the OS you jerk
			if(src.host_program == file)
				return 0

			qdel(file)
			return 1

		send_command(command, datum/computer/file/pfile, target_ref)
			var/result
			var/obj/item/peripheralx/P = locate(target_ref) in src.peripherals
			if(istype(P))
				result = P.receive_command(src, command, pfile)

			qdel(pfile)
			return result

		receive_command(obj/source, command, datum/computer/file/pfile)
			if(source in src.contents)

				for(var/datum/computer/file/terminalx_program/P in src.processing_programs)
					P.receive_command(src, command, pfile)
				qdel(pfile)

			return

		restart()
			if(src.restarting)
				return
			src.restarting = 1
			src.graphic_mode = 0
			src.override_temp = "Restarting..."
			src.updateUsrDialog()
			src.host_program = null

			SPAWN(2 SECONDS)
				//src.restarting = 0
				src.post_system()

			return

		post_system()
			src.override_temp = "Initializing system...<br>"

			if(!src.hd)
				src.override_temp += "<font color=red>1701 - NO FIXED DISK</font><br>"

			var/datum/computer/file/terminalx_program/to_run = null

			if(src.host_program) //Let the starting programs set up vars or whatever
				src.host_program.initialize()

			else

				for(var/obj/item/peripheralx/drive/DR in src.peripherals)
					if(!DR.disk)
						continue

					var/datum/computer/file/terminalx_program/os/newos = locate() in DR.disk.root.contents

					if(istype(newos))
						src.override_temp += "Booting from disk \[[DR.label]]...<br>"
						to_run = newos
						break

				if(!to_run && src.hd && src.hd.root)
					var/datum/computer/file/terminalx_program/os/newos = locate(/datum/computer/file/terminalx_program/os) in src.hd.root.contents

					if(newos && istype(newos))
						src.override_temp += "Booting from fixed disk...<br>"
						to_run = newos
					else
						src.override_temp += "<font color=red>Unable to boot from fixed disk.</font><br>"

			if(to_run)
				src.host_program = to_run
			else
				src.override_temp += "<font color=red>ERR - BOOT FAILURE</font><br>"

			src.updateUsrDialog()
			sleep(2 SECONDS)

			src.restarting = 0
			if(to_run)
				src.run_program(to_run)

			if(src.host_program)
				src.override_temp = null

			src.updateUsrDialog()

			return


/client/verb/compx_command(var/commandstring as text)
	set hidden = 1				// Hidden + no autocomplete
	set name = ".compcommand"

	//boutput(world, "compx command: \"[commandstring]\"")
	var/list/commands = splittext(commandstring,"%")
	if(commands.len < 2)
		return
	var/command = commands[2]
	var/obj/machinery/computerx/compx = locate(commands[1])
	if(istype(compx) && src.mob)
		usr = src.mob
		src.Topic(command, list("[command]"=1), compx)	// Topic redirection time!

	return

/client/verb/compx_console(var/compref as text, var/commandstring as text)
	set hidden = 1
	set name = ".compconsole"

	//boutput(world, "compx: \"[compref]\" command: \"[commandstring]\"")

	var/obj/machinery/computerx/compx = locate(compref)
	if(istype(compx) && src.mob)
		usr = src.mob

		src.Topic("conin", list("conin"=commandstring), compx)
	return
