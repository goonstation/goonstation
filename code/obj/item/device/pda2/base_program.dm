
//base pda program

/datum/computer/file/pda_program
	name = "blank program"
	extension = "PPROG"
	var/obj/item/device/pda2/master = null
	var/id_tag = null
	var/setup_use_process = 0 //Does the master PDA need to be on the processing item list?

	os
		name = "blank system program"
		extension = "PSYS"

	scan
		name = "blank scan program"
		extension = "PSCAN"

	New(obj/holding as obj)
		..()
		if(holding)
			src.holder = holding

			if(istype(src.holder.loc,/obj/item/device/pda2))
				src.master = src.holder.loc

	proc
		return_text()
			if((!src.holder) || (!src.master))
				return 1

			if((!istype(holder)) || (!istype(master)))
				return 1

			if(!(holder in src.master.contents))
				//boutput(world, "Holder [holder] not in [master] of prg:[src]")
				if(master.active_program == src)
					master.active_program = null
				return 1

			return 0

		build_grid(mob/user as mob, theGrid)
			if (!istype(src.holder) || !istype(src.master))
				return 1

			if (!user || !theGrid)
				return 1

			if (!(holder in src.master.contents))
				return 1

			return 0

		process()
			if((!src.holder) || (!src.master))
				return 1

			if((!istype(holder)) || (!istype(master)))
				return 1

			if(!(holder in src.master.contents))
				if(master.active_program == src)
					master.active_program = null
				return 1

			if(!src.holder.root)
				src.holder.root = new /datum/computer/folder
				src.holder.root.holder = src
				src.holder.root.name = "root"

			return 0

		//maybe remove this, I haven't found a good use for it yet
		send_os_command(list/command_list)
			if(!src.master || !src.holder || src.master.host_program || !command_list)
				return 1

			if(!istype(src.master.host_program) || src.master.host_program == src)
				return 1

			src.master.host_program.receive_os_command()

			return 0

		return_text_header()
			if(!src.master || !src.holder)
				return

			. = "<a href='byond://?src=\ref[src];quit=1'>Main Menu</a> | <a href='byond://?src=\ref[src.master];refresh=1'>Refresh</a>"


		post_signal(datum/signal/signal, newfreq)
			master?.post_signal(signal, newfreq)
			//else
				//qdel(signal)

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

			if(istype(newholder.loc,/obj/item/device/pda2))
				src.master = newholder.loc

			//boutput(world, "Setting [src.holder] to [newholder]")
			src.holder = newholder
			return 1


		receive_signal(datum/signal/signal, rx_method, rx_freq)
			if((!src.holder) || (!src.master))
				return 1

			if((!istype(holder)) || (!istype(master)))
				return 1

			if(!(holder in src.master.contents))
				if(master.active_program == src)
					master.active_program = null
				return 1

			return 0

		// called when a program is run
		init()
			return

		// to allow promiscuous mode
		network_hook()
			return


	Topic(href, href_list)
		if((!src.holder) || (!src.master))
			return 1
		if((!istype(holder)) || (!istype(master)))
			return 1
		if((src.master.active_program != src) && !(href_list["input"] && href_list["input"] == "message")) // Disgusting but works
			return 1
		if ((!usr.contents.Find(src.master) && (!in_range(src.master, usr) || !istype(src.master.loc, /turf) || !isAI(usr))) && (!issilicon(usr) && !isAI(usr)))
			return 1
		if(usr.stat || usr.restrained())
			return 1
		if(!(holder in src.master.contents))
			if(master.active_program == src)
				master.active_program = null
			return 1
		src.master.add_dialog(usr)

		if (href_list["close"])
			src.master.remove_dialog(usr)
			usr.Browse(null, "window=pda2_\ref[src]")
			return 0
		if (href_list["quit"])
//			src.master.processing_programs.Remove(src)
			src.master.unload_active_program()
			return 1
		return 0
