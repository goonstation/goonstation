//CONTENTS:
//Base computerx program datum
//Compx_icon object (Used for GUI system)
//Compxwindow datum (Used for GUI system)


/datum/computer/file/terminalx_program
	name = "program"
	extension = "TPROG"
	var/obj/machinery/computerx/master = null
	var/list/req_access = list()
	var/executable = 1
	var/gui_app = 0
	var/datum/compx_window/temp = null
	var/initialized = 0
	var/list/gui_icons = list()
	var/meta_params = null


	os
		name = "system program"
		extension = "TSYS"
		executable = 0
		var/tmp/setup_string = null

		os_call(var/call_params, var/datum/computer/file/terminal_program/caller, var/datum/computer/file/file)
			if(!master || master.status & (NOPOWER|BROKEN))
				return 1
			if(!caller || !call_params)
				return 1

			return 0

	New(obj/holding as obj)
		..()
		if(holding)
			src.holder = holding

			if(istype(src.holder.loc,/obj/machinery/computerx))
				src.master = src.holder.loc

		if(meta_params)
			src.metadata += params2list(meta_params)

	disposing()
		master?.processing_programs.Remove(src)
		..()

	Topic(href, href_list)
		if((!src.holder) || (!src.master))
			return 1

		if((!istype(holder)) || (!istype(master)))
			return 1

		if(master.status & (NOPOWER|BROKEN))
			return 1

		if ((!usr.contents.Find(src.master) && (!in_interact_range(src.master, usr) || !istype(src.master.loc, /turf))) && (!issilicon(usr)))
			return 1

		if(!(holder in src.master.contents) && !(holder.loc in src.master.contents))
			return 1

		src.add_dialog(usr).master

		return 0

	proc
		os_call(var/call_params, var/datum/computer/file/file)
			if (!master || !master.host_program)
				return 0

			master.host_program.os_call(call_params, src, file)
			return 1

		initialize() //Called when a program starts running.
			if(src.initialized || !master)
				return 1
			return 0

		quit()
			src.master?.unload_program(src)
			return

		input_text(var/text, source=0)
			if((!src.holder) || (!src.master) || !text)
				return 1

			if((!istype(holder)) || (!istype(master)))
				return 1

			if(master.status & (NOPOWER|BROKEN))
				return 1

			if(!(holder in src.master.contents) && !(holder.loc in src.master.contents))
				return 1

			if(!src.holder.root)
				src.holder.root = new /datum/computer/folder
				src.holder.root.holder = src
				src.holder.root.name = "root"

			//boutput(world, text)
			return 0

		process()
			if((!src.holder) || (!src.master))
				return 1

			if((!istype(holder)) || (!istype(master)))
				return 1

			if(!(holder in src.master.contents) && !(holder.loc in src.master.contents))
				if(master.host_program == src)
					master.host_program = null
				master.processing_programs.Remove(src)
				return 1

			if(!src.holder.root)
				src.holder.root = new /datum/computer/folder
				src.holder.root.holder = src
				src.holder.root.name = "root"

			return 0

		receive_command(obj/source, command, datum/computer/file/pfile)
			if((!src.holder) || (!src.master) || (!source) || (source != src.master))
				return 1

			if((!istype(holder)) || (!istype(master)))
				return 1

			if(master.status & (NOPOWER|BROKEN))
				return 1

			if(!(holder in src.master.contents) && !(holder.loc in src.master.contents))
				return 1

			return 0

		peripheral_command(command, datum/computer/file/pfile, target_ref)
			if(master)
				return master.send_command(command, pfile, target_ref)
			else
				qdel(pfile)

			return null

		transfer_holder(obj/item/disk/data/newholder,datum/computer/folder/newfolder)

			if((newholder.file_used + src.size) > newholder.file_amount)
				return 0

			if(!newholder.root)
				newholder.root = new /datum/computer/folder
				newholder.root.holder = newholder
				newholder.root.name = "root"

			if(!newfolder)
				newfolder = newholder.root

			if((src.holder && src.holder.read_only) || newholder.read_only)
				return 0

			if((src.holder) && (src.holder.root))
				src.holder.root.remove_file(src)

			newfolder.add_file(src)

			if(istype(newholder.loc,/obj/machinery/computerx))
				src.master = newholder.loc
			else if (istype(newholder.loc, /obj/item/peripheralx/drive))
				var/obj/item/peripheralx/dx = newholder.loc
				if(dx.host)
					src.master = dx.host

			//boutput(world, "Setting [src.holder] to [newholder]")
			src.holder = newholder
			return 1

		disk_inserted(var/obj/item/disk/data/inserted)
			return

		disk_ejected(var/obj/item/disk/data/ejected)
			if(src.holder == ejected)
				src.quit()

			return

		get_temp()
			return src.temp



//This should be used for fancy grid GUI magics!!
/obj/compx_icon
	name = "Icon"
	icon = 'icons/misc/compgui.dmi'
	icon_state = "x"
	var/action_tag = "none" //When clicked, send actiontag = actionarg to our owning program's Topic().
	var/action_arg = 1
	var/datum/computer/file/terminalx_program/owner = null
	var/icon_id = null
	var/grid_x = 0
	var/grid_y = 0
	var/no_drag = 0

	debug
		name = "Finder"
		icon_state = "folder"
		action_tag = "boop"
		action_arg = "beep"

	spacer
		name = ""
		icon_state = null

	New(var/datum/computer/file/terminalx_program/new_owner)
		..()
		if(istype(new_owner))
			src.owner = new_owner
		icon_id = "G[generate_net_id(src)]"
		return

	Click()
		if(!istype(owner) || !usr)
			return

		usr.Topic("[action_tag]=[action_arg];gid=[src.icon_id]", list("[action_tag]"="[action_arg]","gid"=src.icon_id), src.owner)	// Topic redirection time!
		return

	mouse_drop(obj/O, null, var/src_location, var/control_orig, var/control_new, var/params)
		if(!istype(owner) || !usr || src.no_drag)
			return

		if(control_orig != control_new) //Dragging icons into the real world/another computer desktop would be weird.
			return

		//boutput(world, "loc: [src_location]<br>co: [control_orig]<br>cn: [control_new]<br>usr: [usr]")
		usr.Topic("drag=[src_location];gid=[src.icon_id]", list("drag"=src_location,"gid"=src.icon_id), src.owner)	// More Topic redirection.
		return

/datum/compx_window
	var/skinbase = "cxwind_console"
	var/datum/computer/file/terminalx_program/owner = null

	New(var/datum/computer/file/terminalx_program/newOwner)
		..()

		if (istype(newOwner))
			src.owner = newOwner


	grid
		skinbase = "cxwind_grid"

		var/list/gridList = list()

		update(mob/user as mob)
			if (..())
				return

			for(var/gridy = 1, gridy <= compx_gridy_max, gridy++)
				for(var/gridx = 1, gridx <= compx_gridx_max, gridx++)
					if(isnull(gridList[gridx][gridy]))
						user << output(compx_grid_spacer, "compxwindow_\ref[src].grid:[gridx],[gridy]")
					else
						user << output(gridList[gridx][gridy], "compxwindow_\ref[src].grid:[gridx],[gridy]")

			return

	proc/update(mob/user as mob)
		if (!istype(user) || !user.client || !owner)
			return 1

		return 0
