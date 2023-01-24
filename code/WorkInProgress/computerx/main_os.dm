//CONTENTS:
//Primary OS for Computerx


/datum/computer/file/terminalx_program/os/main_os
	name = "System"
	gui_app = 1

	var/tmp/mode = 1
	var/list/known_drives = list()
	var/tmp/datum/computer/file/terminalx_program/application = null
	var/tmp/datum/computer/folder/current_folder = null

	var/const
		setup_taskbar_y = 1
		setup_titlestring_x = 3

	disposing()
		src.clear_icons()
		..()
		return
/*
	get_temp()
		if (istype(application))
			return application.get_temp()

		return src.temp
*/
	proc

		add_compicon(var/obj/compx_icon/new_compicon, gx=1, gy=1)
			if(!istype(new_compicon) || !istype(src.temp, /datum/compx_window/grid))
				return

			var/datum/compx_window/grid/gridwind = src.temp

			if(gx <= 0 || gy <= 0)
				return

			gridwind.gridList[gx][gy] = new_compicon
			src.gui_icons[new_compicon.icon_id] = new_compicon
			new_compicon.grid_x = gx
			new_compicon.grid_y = gy
			return

		clear_icons()
			for(var/i in src.gui_icons)
				var/obj/compx_icon/killme = src.gui_icons[i]
				qdel(killme)

			src.gui_icons.len = 0
			return

		set_mode(var/new_mode=0)
			src.mode = new_mode
			if(new_mode > 0)

				if (!istype(src.temp, /datum/compx_window/grid))
					src.temp = new /datum/compx_window/grid(src)
					qdel(src.temp:gridList)
					src.temp:gridList = new /list(compx_gridx_max, compx_gridy_max)


				//src.temp = new /list(gridx_max, gridy_max)
				src.clear_icons()

				var/obj/compx_icon/temp_icon = new /obj/compx_icon(src)
				temp_icon.action_tag = "menu"
				temp_icon.action_arg = "main"
				temp_icon.icon_state = "menu-main"
				temp_icon.name = ""
				temp_icon.no_drag = 1

				src.add_compicon(temp_icon, 1, setup_taskbar_y)

				//src.temp = new /datum/compx_window/grid(src)
				src.master.graphic_mode = 1

			switch(new_mode)
				if(0) //Text console mode.
					//TO-DO
					src.master.graphic_mode = 0
					if (istype(src.temp))
						qdel(src.temp)



					return

				if(1) //Desktop display mode.
					if (!istype(src.temp, /datum/compx_window/grid))
						return

					var/datum/compx_window/grid/gridTemp = temp
					//Let's go back up a folder!
					var/obj/compx_icon/temp_icon
					if(src.current_folder != src.current_folder.holder.root)
						temp_icon = new /obj/compx_icon(src)
						temp_icon.action_tag = "system"
						temp_icon.action_arg = "root"
						temp_icon.icon_state = "arrow"
						temp_icon.set_dir(1)
						temp_icon.name = ""
						temp_icon.no_drag = 1

						src.add_compicon(temp_icon, compx_gridx_max-1, setup_taskbar_y)

					//Drive switching button
					temp_icon = new /obj/compx_icon(src)
					temp_icon.action_tag = "system"
					temp_icon.action_arg = "drive"
					if(!src.current_folder)
						src.current_folder = src.holding_folder
					temp_icon.icon_state = "disk-[istype(src.current_folder.holder, /obj/item/disk/data/fixed_disk) ? "hd" : "fd"]"
					temp_icon.name = ""
					temp_icon.no_drag = 1

					src.add_compicon(temp_icon, compx_gridx_max, setup_taskbar_y)

					gridTemp.gridList[setup_titlestring_x][setup_taskbar_y] = "<b>[src.current_folder.holder.title]</b>"

					var/i = ( (compx_gridy_max - 1) * (compx_gridx_max) )
					var/ix = 0
					var/iy = setup_taskbar_y + 1
					for(var/datum/computer/C in src.current_folder.contents)
						i--
						if(i <= 0)
							break

						ix++
						if(ix > compx_gridx_max)
							ix = 0
							iy++

						var/obj/compx_icon/file_icon = new /obj/compx_icon(src)
						file_icon.name = copytext(C.name, 1, 10)
						if(istype(C, /datum/computer/folder))
							file_icon.icon_state = "folder"
						else
							if(C.metadata["ico"])
								file_icon.icon_state = C.metadata["ico"]
							else
								file_icon.icon_state = "file-generic"
						file_icon.action_tag = "file"
						file_icon.action_arg = "\ref[C]"

						src.add_compicon(file_icon, ix, iy)

			src.master.updateUsrDialog()
			return

		detect_drives()
			if(!src.master)
				return
			src.known_drives.len = 0
			if(src.master.hd)
				src.known_drives += src.master.hd

			for(var/obj/item/peripheralx/drive/DR in src.master.peripherals)
				if(DR.disk)
					src.known_drives += DR.disk

			return

		run_program(datum/computer/file/terminalx_program/program)
			if (!master.run_program(program))
				return 0

			if (!program.gui_app)
				set_mode(0)

			src.application = program
			return 1


	initialize()
		if(..())
			return

		src.detect_drives()
		src.current_folder = src.holder.root

		src.set_mode(1)
		return

	Topic(href, href_list)
		if(..())
			return

		if(href_list["drag"])
			if(!istype(src.temp, /datum/compx_window/grid))
				return

			var/datum/compx_window/grid/window = src.temp
			//If everything works out here, coords[1] should be x and coords[2] should be y of the new grid location.
			var/list/coords = splittext(href_list["drag"], ",")
			if(coords.len != 2)
				return

			var/new_x = text2num_safe(coords[1])
			var/new_y = text2num_safe(coords[2])
			if(!isnum(new_x) || !isnum(new_y))
				return

			//boutput(world, "New-X: [new_x]<br>New-Y: [new_y]")
			if(new_x <= 0 || new_x > compx_gridx_max || new_y <= 1 || new_y > compx_gridy_max)
				//boutput(world, "new coords out of bounds")
				return

			var/obj/compx_icon/calling_icon = gui_icons[href_list["gid"]]
			if(!istype(calling_icon))
				return

			var/new_loc_check = window.gridList[new_x][new_y]
			if(!isnull(new_loc_check))
				return

			window.gridList[new_x][new_y] = calling_icon
			window.gridList[calling_icon.grid_x][calling_icon.grid_y] = null
			calling_icon.grid_x = new_x
			calling_icon.grid_y = new_y

			src.master.updateUsrDialog()
			return

		else if (href_list["system"])
			switch(href_list["system"])
				if("root")
					if(istype(src.current_folder.holding_folder))
						src.current_folder = src.current_folder.holding_folder
					else
						src.current_folder = src.current_folder.holder.root
					src.set_mode(1)
				if("drive")
					var/pick_next = 0
					var/loop_around = 1
					for(var/obj/item/disk/data/D in src.known_drives)
						if(D == src.current_folder.holder)
							pick_next = 1
							continue

						if(pick_next)
							src.current_folder = D.root
							loop_around = 0
							break

					if(loop_around && src.known_drives.len > 1)
						var/obj/item/disk/data/tempD = src.known_drives[1]
						if(istype(tempD))
							src.current_folder = tempD.root

					src.set_mode(1)

		else if (href_list["menu"])
			switch(href_list["menu"])
				if("main")
					if(src.mode != 2)
						src.set_mode(2)
					else
						src.set_mode(1)
			return

		else if (href_list["file"])
			var/datum/computer/C = locate(href_list["file"]) in src.current_folder.contents
			if(!istype(C))
				return

			//To-Do
			//boutput(world, "[istype(C, /datum/computer/file) ? "<b>File</b> Folder" : "File <b>Folder</b>"]: <b>Name:</b> \"[C.name]\"")
			if(istype(C, /datum/computer/folder))
				src.current_folder = C
				src.set_mode(1)

			if(istype(C, /datum/computer/file/terminalx_program) && C:executable && !(C in master.processing_programs))
				src.run_program(C)

			return

		//boutput(world, "Topic Input: \"[href]\"")
		return

	disk_inserted(var/obj/item/disk/data/inserted)
		if(!(inserted in src.known_drives))
			src.known_drives += inserted

		return

	disk_ejected(var/obj/item/disk/data/ejected)
		if(src.holder == ejected)
			src.clear_icons()

			src.master.override_temp = "<font color=red><b>Fatal Error:</b> Unable to read system file.</font>"
			src.master.graphic_mode = 0
			src.master.updateUsrDialog()

			src.quit()
			return

		if(src.current_folder && src.current_folder.holder == ejected)
			src.current_folder = src.holder.root

		src.detect_drives()
		if(src.mode > 0)
			src.set_mode(src.mode)
		return

	input_text(var/text, source=0)
		if(..())
			return

		src.master.visible_message("<b>[src.master]</b> <i>beeps</i>, \"[text]\"")
		return


/obj/item/disk/data/floppy/computerxboot
	name = "data disk-'ThinkOS/2'"

	New()
		..()
		src.root.add_file( new /datum/computer/file/terminalx_program/os/main_os(src))
		var/datum/computer/folder/newfolder = new /datum/computer/folder(  )
		newfolder.name = "logs"
		src.root.add_file( newfolder )
		newfolder.add_file( new /datum/computer/file/record/c3help(src))
		newfolder = new /datum/computer/folder
		newfolder.name = "bin"
		src.root.add_file( newfolder )
		//newfolder.add_file( new /datum/computer/file/terminal_program/writewizard(src))
