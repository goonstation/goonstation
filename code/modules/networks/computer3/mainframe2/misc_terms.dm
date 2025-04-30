//Miscellaneous Terminal Devices
//CONTENTS:
// Basic pnet machine
// HIGH-TECH tape storage
// A bomb simulator.  Test bombs in VR!
// Outpost self-destruct !nuke!
// A wirenet -> wireless link thing.
// A printer! All the fun of printing, now in SS13!
// Security system monitor
// A dangerous teleportation-oriented testing apparatus.
// Generic testing appartus

/obj/machinery/networked
	anchored = ANCHORED
	density = 1
	icon = 'icons/obj/networked.dmi'
	var/net_id = null
	var/host_id = null //Who are we connected to? (If we have a single host)
	var/old_host_id = null //Were we previously connected to someone?  Do we care?
	var/obj/machinery/power/data_terminal/link = null
	var/device_tag = "PNET_GENERICDV"
	var/timeout = 40 //The time until we auto disconnect (if we don't get a refresh ping)
	var/timeout_alert = 0 //Have we sent a timeout refresh alert?

	var/last_reset = 0 //Last world.time we were manually reset.
	var/net_number = 0 //A cute little bitfield (0-3 exposed) to allow multiple networks on one wirenet.  Differentiate between intended hosts, if they care.
	var/panel_open = 0

	proc/post_status(var/target_id, var/key, var/value, var/key2, var/value2, var/key3, var/value3, var/key4, var/value4)
		if(!src.link || !target_id)
			return

		var/datum/signal/signal = get_free_signal()
		signal.source = src
		signal.transmission_method = TRANSMISSION_WIRE
		signal.data[key] = value
		if(key2)
			signal.data[key2] = value2
		if(key3)
			signal.data[key3] = value3
		if(key4)
			signal.data[key4] = value4

		signal.data["address_1"] = target_id
		signal.data["sender"] = src.net_id

		src.link.post_signal(src, signal)

	proc/post_file(var/target_id, var/key, var/value, var/file)
		if(!src.link || !target_id)
			return

		var/datum/signal/signal = get_free_signal()
		signal.source = src
		signal.transmission_method = TRANSMISSION_WIRE
		signal.data[key] = value
		if(file)
			var/datum/computer/file/F = file
			signal.data_file = F.copy_file()

		signal.data["address_1"] = target_id
		signal.data["command"] = "term_file"
		signal.data["sender"] = src.net_id

		src.link.post_signal(src, signal)

	proc/net_switch_html()
		. = "<br>Configuration Switches:<br><table border='1' style='background-color:#7A7A7A'><tr>"
		for (var/i = 8, i >= 1, i >>= 1)
			var/styleColor = (net_number & i) ? "#60B54A" : "#CD1818"
			. += "<td style='background-color:[styleColor]'><a href='byond://?src=\ref[src];dipsw=[i]' style='color:[styleColor]'>##</a></td>"

		. += "</tr></table>"

	Topic(href, href_list)
		if (..())
			return 1

		if (href_list["dipsw"] && src.panel_open && GET_DIST(usr, src) < 2)
			var/switchNum = text2num_safe(href_list["dipsw"])
			if (switchNum < 1 || switchNum > 8)
				return 1

			switchNum = round(switchNum)
			if (net_number & switchNum)
				net_number &= ~switchNum
			else
				net_number |= switchNum

			src.updateUsrDialog()
			return 1

		return 0

	disposing()
		if (src.link)
			src.link.master = null
			src.link = null

		..()

	set_loc(atom/target)
		..()
		if(src.link)
			src.link.master = null
			src.link = null
		if(!isturf(src.loc))
			return
		var/turf/T = src.loc
		var/obj/machinery/power/data_terminal/test_link = locate() in T
		if(test_link && !DATA_TERMINAL_IS_VALID_MASTER(test_link, test_link.master))
			src.link = test_link
			src.link.master = src


TYPEINFO(/obj/machinery/networked/storage)
	mats = 12

/obj/machinery/networked/storage
	name = "Databank"
	desc = "A networked data storage device."
	anchored = ANCHORED
	density = 1
	icon_state = "tapedrive0"
	device_tag = "PNET_DATA_BANK"
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_CROWBAR | DECON_WELDER | DECON_WIRECUTTERS | DECON_MULTITOOL | DECON_DESTRUCT
	var/base_icon_state = "tapedrive"
	var/bank_id = null //Unique Identifier for this databank.
	var/locked = 1
	var/read_only = 0 //Read only, even if the disk isn't!
	var/obj/item/disk/data/tape = null
	var/setup_drive_size = 128
	var/setup_tape_tag = "tape"
	var/setup_tape_type = /obj/item/disk/data/tape //Parent type that can be used as disk.
	var/setup_drive_type = /obj/item/disk/data/tape //Use this path for the tape
	var/setup_spawn_with_tape = 1 //Spawn with tape in the drive.
	var/setup_access_click = 0 //Play tape drive noise when accessed.
	var/setup_allow_boot = 0 //We respond to bootreq requests.
	var/setup_accept_tapes = 1
	power_usage = 200

	tape_drive
		name = "Databank"
		desc = "A networked tape drive."
		icon_state = "tapedrive0"
		base_icon_state = "tapedrive"
		setup_access_click = 1
		setup_tape_tag = "tape"
		setup_tape_type = /obj/item/disk/data/tape
		setup_allow_boot = 1

	clone()
		var/obj/machinery/networked/storage/clonestore = ..()
		if (!clonestore)
			return

		clonestore.locked = src.locked
		clonestore.base_icon_state = src.base_icon_state
		clonestore.device_tag = src.device_tag
		clonestore.read_only = src.read_only
		clonestore.setup_access_click = src.setup_access_click
		clonestore.setup_allow_boot = src.setup_allow_boot
		clonestore.setup_tape_type = src.setup_tape_type
		clonestore.setup_drive_type = src.setup_drive_type
		clonestore.bank_id = src.bank_id
		if (src.tape)
			clonestore.tape = src.tape.clone()

		return clonestore

	New()
		..()
		if(!bank_id)
			bank_id = "GENERIC"

		src.net_id = generate_net_id(src)

		SPAWN(1 SECONDS)

			if(!src.link)
				var/turf/T = get_turf(src)
				var/obj/machinery/power/data_terminal/test_link = locate() in T
				if(test_link && !DATA_TERMINAL_IS_VALID_MASTER(test_link, test_link.master))
					src.link = test_link
					src.link.master = src

			if(!tape && (setup_drive_size > 0) && setup_spawn_with_tape)
				if(src.setup_drive_type)
					if (istext(src.setup_drive_type))
						src.setup_drive_type = text2path(src.setup_drive_type)

					src.tape = new src.setup_drive_type (src)
					src.tape.set_loc(src)

				if (src.tape)
					src.tape.file_amount = max(src.setup_drive_size, src.tape.file_amount)

			src.power_change() //Update the icon

	disposing()
		if (src.tape)
			src.tape.dispose()
			src.tape = null

		..()

	process()
		if(status & BROKEN)
			return
		..()
		if(status & NOPOWER)
			return

		if(!host_id || !link)
			return

		if(src.timeout == 0)
			src.post_status(host_id, "command","term_disconnect","data","timeout")
			src.host_id = null
			src.updateUsrDialog()
			src.timeout = initial(src.timeout)
			src.timeout_alert = 0
		else
			src.timeout--
			if(src.timeout <= 5 && !src.timeout_alert)
				src.timeout_alert = 1
				src.post_status(src.host_id, "command","term_ping","data","reply")

		return

	attack_hand(mob/user)
		if(..() && !(status & NOPOWER)) //Allow them to remove tapes even if the power's out.
			return

		src.add_dialog(user)

		var/dat = "<html><head><title>Databank - \[[bank_id]]</title></head><body>"

		dat += "<b>[capitalize(src.setup_tape_tag)]:</b> <a href='byond://?src=\ref[src];tape=1'>[src.tape ? "Eject" : "--------"]</a><hr>"

		if (status & NOPOWER)
			user.Browse(dat,"window=databank;size=245x302")
			onclose(user,"databank")
			return

		var/readout_color = "#000000"
		var/readout = "ERROR"
		if(src.host_id)
			readout_color = "#33FF00"
			readout = "OK CONNECTION"
		else
			readout_color = "#F80000"
			readout = "NO CONNECTION"

		dat += "Host Connection: "
		dat += "<table border='1' style='background-color:[readout_color]'><tr><td><font color=white>[readout]</font></td></tr></table><br>"

		dat += "<a href='byond://?src=\ref[src];reset=1'>Reset Connection</a><br>"

		dat += "<br>Read Only: "
		if(!src.read_only)
			dat += "<a href='byond://?src=\ref[src];read=1'>YES</a> <b>NO</b><br>"
		else
			dat += "<b>YES</b> <a href='byond://?src=\ref[src];read=1'>NO</a><br>"

		if (src.panel_open)
			dat += net_switch_html()

		user.Browse(dat,"window=databank;size=245x302")
		onclose(user,"databank")
		return

	Topic(href, href_list)
		if(..() && !(href_list["tape"] && (status & NOPOWER)))
			return

		src.add_dialog(usr)

		if(href_list["tape"])
			if(src.locked)
				boutput(usr, SPAN_ALERT("The cover is screwed shut."))
				return

			//Ai/cyborgs cannot physically remove a tape from a room away.
			if(issilicon(usr) && BOUNDS_DIST(src, usr) > 0)
				boutput(usr, SPAN_ALERT("You cannot press the ejection button."))
				return

			if(src.tape)
				src.tape.set_loc(src.loc)
				src.tape = null
				boutput(usr, "You remove the [src.setup_tape_tag] from the drive.")
				src.power_change()
				if (src.host_id && !(status & (NOPOWER|BROKEN)))
					src.post_status(src.host_id,"command","term_message","data","command=status&status=notape")

			else
				var/obj/item/I = usr.equipped()
				if (istype(I, src.setup_tape_type))
					usr.drop_item()
					I.set_loc(src)
					src.tape = I
					boutput(usr, "You insert [I].")
					src.sync(src.host_id)
				else if (istype(I, /obj/item/magtractor))
					var/obj/item/magtractor/mag = I
					if (istype(mag.holding, src.setup_tape_type))
						I = mag.holding
						mag.dropItem(0)
						I.set_loc(src)
						src.tape = I
						boutput(usr, "You insert [I].")
						src.sync(src.host_id)

				src.power_change()

			src.updateUsrDialog()
			return

		else if (href_list["reset"])
			if(last_reset && (last_reset + NETWORK_MACHINE_RESET_DELAY >= world.time))
				return

			if(!host_id && !old_host_id)
				return

			src.last_reset = world.time
			var/rem_host = src.host_id ? src.host_id : src.old_host_id
			src.host_id = null
			src.old_host_id = null
			src.post_status(rem_host, "command","term_disconnect")
			SPAWN(0.5 SECONDS)
				src.post_status(rem_host, "command","term_connect","device",src.device_tag)

			src.updateUsrDialog()
			return

		else if (href_list["read"])
			src.read_only = !src.read_only

			src.updateUsrDialog()
			return

		src.add_fingerprint(usr)
		return

	attackby(obj/item/W, mob/user)
		if (istype(W, src.setup_tape_type) && setup_accept_tapes) //INSERT SOME TAPES
			if (src.tape)
				boutput(user, SPAN_ALERT("There is already a [src.setup_tape_tag] in the drive."))
				return
			if (src.locked)
				boutput(user, SPAN_ALERT("The cover is screwed shut."))
				return
			user.drop_item()
			W.set_loc(src)
			src.tape = W
			boutput(user, "You insert [W].")
			src.power_change()
			src.updateUsrDialog()
			src.sync(src.host_id)
			return

		else if (isscrewingtool(W))
			playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
			src.locked = !src.locked
			src.panel_open = !src.locked
			boutput(user, "You [src.locked ? "secure" : "unscrew"] the cover.")
			src.updateUsrDialog()
			return

		else
			..()

		return

	receive_signal(datum/signal/signal)
		if(status & (NOPOWER) || !src.link)
			return
		if(!signal || !src.net_id || signal.encryption)
			return

		if(signal.transmission_method != TRANSMISSION_WIRE) //This is a wired device only.
			return

		var/target = signal.data["sender"]

		//They don't need to target us specifically to ping us.
		//Otherwise, if they aren't addressing us, ignore them
		if(signal.data["address_1"] != src.net_id)
			if((signal.data["address_1"] == "ping") && ((signal.data["net"] == null) || ("[signal.data["net"]]" == "[src.net_number]")) && signal.data["sender"])
				SPAWN(0.5 SECONDS) //Send a reply for those curious jerks
					src.post_status(target, "command", "ping_reply", "device", src.device_tag, "netid", src.net_id, "net", "[src.net_number]")

			return

		var/sigcommand = lowertext(signal.data["command"])
		if(!sigcommand || !signal.data["sender"])
			return

		switch(sigcommand)
			if("term_connect") //Terminal interface stuff.
//				if(target == src.host_id)
//					//WHAT IS THIS, HOW COULD THIS HAPPEN??
//					src.host_id = null
//					src.updateUsrDialog()
//					SPAWN(0.3 SECONDS)
//						src.post_status(target, "command","term_disconnect")
//					return

				if(src.host_id && src.host_id != target)
					return

				src.timeout = initial(src.timeout)
				src.timeout_alert = 0
				src.host_id = target
				src.old_host_id = target
				if(signal.data["data"] != "noreply")
					src.post_status(target, "command","term_connect","data","noreply","device",src.device_tag)
				src.updateUsrDialog()
				SPAWN(0.2 SECONDS) //Sign up with the driver (if a mainframe contacted us)
					src.post_status(target,"command","term_message","data","command=register&data=[src.bank_id]")
				return

			if("term_message","term_file")
				if(target != src.host_id) //Huh, who is this?
					return

				var/list/data = params2list(signal.data["data"])
				if(!data)
					return

				var/sessionid = data["session"]
				if (!sessionid)
					sessionid = 0

				if (setup_access_click)
					playsound(src.loc, 'sound/machines/driveclick.ogg', 25, 0, -2)
				switch(data["command"])
					if("sync")
						if (!src.tape)
							src.post_status(target,"command","term_message","data","command=status&status=notape&session=[sessionid]")
							return

						src.sync(target)
						return
					if("catalog") //List file directory/tape information
						if(!src.tape)
							src.post_status(target,"command","term_message","data","command=status&status=notape&session=[sessionid]")
							return
						var/datum/computer/file/record/catrec = new
						catrec.fields["/header"] = "name=[tape.title]&used=[tape.file_used]&size=[tape.file_amount]"
						if(!tape.root.contents.len)
							catrec.fields["NOFILE"] = "NOFILES"
						else
							for(var/datum/computer/file/F in tape.root.contents)
								catrec.fields[F.name] = "[F.extension] - [F.size]"

						SPAWN(0.2 SECONDS)
							src.post_file(target, "data","command=catalog",catrec)
							//qdel(catrec) //A copy is sent, the original is no longer needed.
							if (catrec)
								catrec.dispose()
						return
					if("filereq") //Send a file from tape if available.
						if(!src.tape)
							src.post_status(target,"command","term_message","data","command=status&status=notape&session=[sessionid]")
							return
						if(isnull(data["fname"]))
							src.post_status(target,"command","term_message","data","command=status&status=noparam&session=[sessionid]")
							return

						var/checkname = data["fname"]
						var/datum/computer/file/sought = get_file_name(checkname, src.tape.root)
						if(istype(sought))
							src.post_file(target, "data","command=file",sought)
						else
							src.post_status(target,"command","term_message","data","command=status&status=nofile&session=[sessionid]")
						return
					if("filestore") //Store a file on tape.
						if(!src.tape)
							src.post_status(target,"command","term_message","data","command=status&status=notape&session=[sessionid]")
							return

						if(src.tape.read_only || src.read_only)
							src.post_status(target,"command","term_message","data","command=status&status=readonly&session=[sessionid]")
							return

						var/datum/computer/file/newfile = signal.data_file
						if(!istype(newfile))
							src.post_status(target,"command","term_message","data","command=status&status=badfile&session=[sessionid]")
							return

						if(findtext(newfile.name, "/"))
							src.post_status(target,"command","term_message","data","command=status&status=badname&session=[sessionid]")
							return

						var/datum/computer/taken = get_file_name(newfile.name, src.tape.root)
						if(taken)
							if (istype(taken, newfile.type))
								taken.dispose()
								taken = null
							else
								src.post_status(target,"command","term_message","data","command=status&status=takenfile&session=[sessionid]")
								return

						var/datum/computer/file/F2 = newfile.copy_file()
						if(tape.root.add_file(F2) != 1)
							//qdel(F2)
							F2.dispose()
							F2 = null
							src.post_status(target,"command","term_message","data","command=status&status=noroom&session=[sessionid]")
							return

						src.post_status(target,"command","term_message","data","command=status&status=success&session=[sessionid]")

						return

					if("delfile")
						if(!src.tape)
							src.post_status(target,"command","term_message","data","command=status&status=notape&session=[sessionid]")
							return
						if(src.tape.read_only || src.read_only)
							src.post_status(target,"command","term_message","data","command=status&status=readonly&session=[sessionid]")
							return
						if(isnull(data["fname"]))
							src.post_status(target,"command","term_message","data","command=status&status=noparam&session=[sessionid]")
							return

						var/checkname = data["fname"]
						var/datum/computer/file/sought = get_file_name(checkname, src.tape.root)

						if(istype(sought))
							//qdel(sought)
							sought.dispose()
							src.post_status(target,"command","term_message","data","command=status&status=success&session=[sessionid]")
							return

						src.post_status(target,"command","term_message","data","command=status&status=nofile&session=[sessionid]")
						return
					if("modfile")
						if(!src.tape)
							src.post_status(target,"command","term_message","data","command=status&status=notape&session=[sessionid]")
							return
						if(src.tape.read_only || src.read_only)
							src.post_status(target,"command","term_message","data","command=status&status=readonly&session=[sessionid]")
							return
						if(isnull(data["fname"]) || isnull(data["field"]))
							src.post_status(target,"command","term_message","data","command=status&status=noparam&session=[sessionid]")
							return

						var/checkname = data["fname"]
						var/datum/computer/file/sought = get_file_name(checkname, src.tape.root)

						if(istype(sought))
							var/newval = data["val"]
							if (isnum(text2num_safe(newval)))
								newval = text2num_safe(newval)
							sought.metadata[data["field"]] = newval
							src.post_status(target,"command","term_message","data","command=status&status=success&session=[sessionid]")
							return

						src.post_status(target,"command","term_message","data","command=status&status=nofile&session=[sessionid]")
						return
					if("bootreq") //Special request for a mainframe OS file + any drivers on tape.
						if(!src.tape || !setup_allow_boot)
							src.post_status(target,"command","term_message","data","command=status&status=notape&session=[sessionid]")
							return

						var/datum/computer/file/mainframe_program/os/foundos = locate() in src.tape.root.contents
						if(!istype(foundos))
							src.post_status(target,"command","term_message","data","command=status&status=nofile&session=[sessionid]")
							return
						//Stuff it in a file archive.
						var/datum/computer/file/archive/archive = new
						archive.max_contained_size = src.tape.file_amount

						var/datum/computer/file/foundos_copy = foundos.copy_file()
						archive.add_file(foundos_copy)
						//Might as well stuff any other executable files hanging around too.
						for(var/datum/computer/file/mainframe_program/MP in src.tape.root.contents)
							if(MP == foundos)
								continue

							var/datum/computer/file/MP_copy = MP.copy_file()
							var/success = archive.add_file(MP_copy)
							if(!success)
								//qdel(MP_copy)
								MP_copy.dispose()
								break

						src.post_file(target, "data","command=file&session=[sessionid]",archive)
						return

				return

			if("term_ping")
				if(target != src.host_id)
					return
				if(signal.data["data"] == "reply")
					src.post_status(target, "command","term_ping")
				src.timeout = initial(src.timeout)
				src.timeout_alert = 0 //no really please stay zero
				return

			if("term_disconnect")
				if(target == src.host_id)
					src.host_id = null
				src.timeout = initial(src.timeout)
				src.timeout_alert = 0 //no really please stay zero
				src.updateUsrDialog()
				return

		return

	power_change()
		if(!src.tape)
			icon_state = "[base_icon_state]0"
			return

		else if(powered())
			icon_state = "[base_icon_state]1"
			status &= ~NOPOWER
		else
			SPAWN(rand(0, 15))
				icon_state = "[base_icon_state]-p"
				status |= NOPOWER

	proc //Computer3/Mainframe loan procs are the best procs!!
		is_name_invalid(string) //Check if a filename is invalid somehow
			if(!string)
				return 1

			if(ckey(string) != replacetext(lowertext(string), " ", null))
				return 1

			if(findtext(string, "/"))
				return 1

			return 0

		//Find a file with a given name
		get_file_name(string, var/datum/computer/folder/check_folder)
			if(!string || (!check_folder || !istype(check_folder)))
				return null

			var/datum/computer/taken = null
			for(var/datum/computer/file/F in check_folder.contents)
				var/string2 = ckey(F.name)

				if(cmptext(string,string2))
					taken = F
					break

			return taken

		sync(var/target)
			if (!src.tape || !target || src.status & (NOPOWER|BROKEN))
				return

			var/datum/computer/file/archive/archive = new
			archive.max_contained_size = src.tape.file_amount

			for(var/datum/computer/file/F in src.tape.root.contents)
				var/datum/computer/file/F_copy = F.copy_file()
				var/success = archive.add_file(F_copy)
				if(!success)
					//qdel(F_copy)
					F_copy.dispose()
					break

			src.post_file(target, "data","command=sync",archive)
			return

/obj/machinery/networked/storage/bomb_tester
	name = "Explosive Simulator"
	desc = "A networked device designed to simulate and analyze explosions.  Takes two tanks."
	anchored = ANCHORED
	density = 1
	icon_state = "bomb_scanner0"
	base_icon_state = "bomb_scanner"

	setup_access_click = FALSE
	read_only = TRUE
	setup_drive_size = 4
	setup_drive_type = /obj/item/disk/data/bomb_tester
	setup_accept_tapes = FALSE

	/// One of two tanks this holds as a basis for the simulation
	var/obj/item/tank/tank1 = null
	/// Two of two tanks this holds as a basis for the simulation
	var/obj/item/tank/tank2 = null
	/// File record where the simulation results are kept
	var/datum/computer/file/record/results = null
	/// Our VR TTV to attach tank1 and tank2 to
	var/obj/item/device/transfer_valve/vr/vrbomb = null
	power_usage = 200
	HELP_MESSAGE_OVERRIDE("Simulates the mixture of two tanks of gas.</br>\
						   You can use the <b>VR Goggles</b> typically found nearby to watch the simulation unfold.</br>\
						   A <b>screwdriver</b> can open the maintenence panel to manage the host connection.")
	/// Where the bomb gets dropped
	var/vr_landmark = LANDMARK_VR_BOMB

	power_change()
		if(powered())
			status &= ~NOPOWER
			UpdateIcon()
		else
			SPAWN(rand(0, 15))
				status |= NOPOWER
				UpdateIcon()
				if(src.vrbomb)
					qdel(src.vrbomb)
		return

	process()
		if(status & BROKEN)
			return
		..()
		if(status & NOPOWER)
			return

		if(!host_id || !link)
			return

		if(src.timeout == 0)
			src.post_status(host_id, "command","term_disconnect","data","timeout")
			src.host_id = null
			src.updateUsrDialog()
			src.timeout = initial(src.timeout)
			src.timeout_alert = 0
		else
			src.timeout--
			if(src.timeout <= 5 && !src.timeout_alert)
				src.timeout_alert = 1
				src.post_status(src.host_id, "command","term_ping","data","reply")

		return

	/// Handheld tanks and butts are both fair game here
	proc/is_valid_tank(obj/item/I)
		return (istype(I, /obj/item/tank) || istype(I, /obj/item/clothing/head/butt))

	/// Determine if the simulator is ready, returns a list of a bool for whether it's ready, and a dialogue for the user
	proc/can_simulate()
		if(!(src.tank1 && src.tank2))
			return list(FALSE, "Both tanks are required!")
		else if (GET_COOLDOWN(global, "bomb_simulator"))
			return list(FALSE, "Simulator not ready, please try again later.")
		else if (src.vrbomb)
			return list(TRUE, "Simulation in progress!")
		else
			return list(TRUE, "Simulator ready.")

#define TANK_ONE 1
#define TANK_TWO 2
/// Checks if we have a tank in the specified slot
#define HAS_TANK(tanknum) ((tanknum == TANK_ONE) && src.tank1) || ((tanknum == TANK_TWO) && src.tank2)
/// Add the tank to the slot being interact with in the device
#define ADD_TANK(tanknum, tank) tank.set_loc(src); if ((tanknum) == TANK_ONE) {src.tank1 = tank;}\
								else {src.tank2 = tank;};
	/// Interact with one of the tank slots on the machine. 1 for the first slot, 2 for the second. "null" to use an empty slot, if there is one.
	proc/add_tank(mob/user, obj/item/I, slot=null)
		if(issilicon(user) && BOUNDS_DIST(src, user) > 0)
			boutput(user, SPAN_ALERT("You cannot interact with \the [src] from that far away!"))
			return
		// No slot specified, try to interact with an empty slot
		if (!slot)
			if (HAS_TANK(TANK_ONE))
				if (HAS_TANK(TANK_TWO))
					boutput(user, SPAN_ALERT("There is no room to insert that into \the [src]!"))
					return
				else
					slot = TANK_TWO
			else
				slot = TANK_ONE
		// Magtractors need special handling
		if (istype(I, /obj/item/magtractor))
			var/obj/item/magtractor/mag = I
			I = mag.holding
			if (!src.is_valid_tank(I))
				boutput(user, "That won't work inside of the [src]!")
			else
				mag.dropItem(0)
				ADD_TANK(slot, I)
				playsound(src, 'sound/machines/click.ogg', 50, TRUE)
				boutput(user, "You insert \the [I].")
		else if (!src.is_valid_tank(I))
			boutput(user, "That won't work inside of the [src]!")
		else
			user.drop_item()
			ADD_TANK(slot, I)
			playsound(src, 'sound/machines/click.ogg', 50, TRUE)
			boutput(user, "You insert \the [I].")

	ui_act(action, params)
		. = ..()
		switch(action)
			if ("add_item")
				src.add_tank(usr, usr.equipped(), params["tank"])

			if ("remove_tank_one")
				if (HAS_TANK(TANK_ONE))
					usr.put_in_hand_or_eject(src.tank1)
					boutput(usr, "You eject \the [src.tank1].")
					src.tank1 = null
					if (src.vrbomb)
						qdel(src.vrbomb)

			if ("remove_tank_two")
				if (HAS_TANK(TANK_TWO))
					usr.put_in_hand_or_eject(src.tank2)
					boutput(usr, "You eject \the [src.tank2].")
					src.tank2 = null
					if (src.vrbomb)
						qdel(src.vrbomb)

			if("simulate")
				// Button is disabled on these conditions, but can't hurt to check em' twice
				var/simulator_dialogue = src.can_simulate()
				if (!simulator_dialogue[1])
					boutput(usr, SPAN_ALERT(simulator_dialogue[2]))
				ON_COOLDOWN(global, "bomb_simulator", 30 SECONDS)
				src.generate_vrbomb()
				src.updateUsrDialog()

			if ("reset")
				if (!host_id || ON_COOLDOWN(src, "reset", NETWORK_MACHINE_RESET_DELAY))
					return
				var/rem_host = src.host_id ? src.host_id : src.old_host_id
				src.host_id = null
				src.old_host_id = null
				src.post_status(rem_host, "command","term_disconnect")
				SPAWN(0.5 SECONDS)
					src.post_status(rem_host, "command","term_connect","device",src.device_tag)
				return

			if ("config_switch")
				src.net_number = src.net_number ^ (1 << params["switch_flicked"])

		tgui_process.update_uis(src)
		src.add_fingerprint(usr)
		return

#undef HAS_TANK
#undef ADD_TANK
#undef TANK_ONE
#undef TANK_TWO

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if (!ui)
			ui = new(user, src, "Bombsim", src.name)
			ui.open()

/// Gets relevant properties of the tank as a list for ui_data
#define TANK_AS_LIST(tank) (tank != null) ? list("name"=capitalize(tank.name),\
								"pressure"=((hasvar(tank, "air_contents") && tank.air_contents != null) ? MIXTURE_PRESSURE(tank.air_contents) : null),\
								"maxPressure"=TANK_FRAGMENT_PRESSURE) : list("name"=null, "pressure"=null,"maxPressure"=null)
	ui_data()
		var/simulator_dialogue = src.can_simulate()
		return list(
			"tank_one" = TANK_AS_LIST(src.tank1),
			"tank_two" = TANK_AS_LIST(src.tank2),
			"host_id" = src.host_id,
			"vr_bomb" = src.vrbomb,
			"panel_open" = src.panel_open,
			"is_ready" = simulator_dialogue[1],
			"cooldown" = "[GET_COOLDOWN(global, "bomb_simulator")/10] Second\s",
			"readiness_dialogue" = simulator_dialogue[2],
			"net_number" = src.net_number,
		)

	update_icon()
		if(tank1) //Update tank overlays.
			UpdateOverlays(image(src.icon,"bscanner-tank1"), "tank1")
		else
			UpdateOverlays(null, "tank1")
		if(tank2)
			UpdateOverlays(image(src.icon,"bscanner-tank2"), "tank2")
		else
			UpdateOverlays(null, "tank2")

		if(status & BROKEN)
			icon_state = "bomb_scannerb"
			return
		if(status & NOPOWER)
			icon_state = "bomb_scanner-p"
			return

		if(src.tank1 && src.tank2)
			icon_state = "bomb_scanner1"
		else
			icon_state = "bomb_scanner0"
		return

	attackby(obj/item/I, mob/user)
		..()
		if (src.is_valid_tank(I)) // Insert tanks by hand
			src.add_tank(user, I)

	attack_hand(mob/user)
		if(status & (NOPOWER|BROKEN))
			return

		if(user.lying || user.stat)
			return 1

		if ((BOUNDS_DIST(src, user) > 0 || !istype(src.loc, /turf)) && !issilicon(user))
			return 1

		src.ui_interact(user)

	proc/generate_vrbomb()
		if(!(src.tank1 && src.tank2))
			return

		if(src.vrbomb)
			qdel(src.vrbomb)

		var/turf/B = pick_landmark(vr_landmark)
		if(!B)
			playsound(src.loc, 'sound/machines/buzz-sigh.ogg', 50, 1)
			src.visible_message("[src] emits a somber ping.")
			return

		// Create and setup our vr explosive
		src.vrbomb = new
		src.vrbomb.set_loc(B)
		src.vrbomb.anchored = ANCHORED
		src.vrbomb.tester = src

		var/obj/item/tank/vrtank1 = new tank1.type
		var/obj/item/tank/vrtank2 = new tank2.type

		if (hasvar(src.tank1, "air_contents"))
			vrtank1.air_contents.copy_from(src.tank1.air_contents)
		if (hasvar(src.tank2, "air_contents"))
			vrtank2.air_contents.copy_from(src.tank2.air_contents)

		src.vrbomb.tank_one = vrtank1
		src.vrbomb.tank_two = vrtank2
		vrtank1.set_loc(src.vrbomb)
		vrtank2.set_loc(src.vrbomb)

		src.vrbomb.UpdateIcon()
		SPAWN(3 SECONDS)
			src.vrbomb.toggle_valve()

		var/area/to_reset = get_area(src.vrbomb) //Reset the magic vr turf.
		if(to_reset && to_reset.name != "Space")
			for(var/turf/unsimulated/bombvr/VT in to_reset)
				VT.icon_state = initial(VT.icon_state)
			for(var/turf/unsimulated/wall/bombvr/VT in to_reset)
				VT.icon_state = initial(VT.icon_state)
				VT.set_opacity(1)
				VT.set_density(1)

		src.new_bomb_log()
		return

	proc/new_bomb_log()
		if(!tape)
			return

		if(src.results)
			src.results.dispose()

		src.results = new
		src.results.name = "Bomblog"

		src.results.fields += "Test [time2text(world.realtime, "DDD MMM DD hh:mm:ss")], [CURRENT_SPACE_YEAR]"

		src.results.fields += "Atmospheric Tank #1:"
		if(tank1 && tank1?.air_contents)
			var/datum/gas_mixture/environment = tank1.return_air()
			var/pressure = MIXTURE_PRESSURE(environment)
			var/total_moles = TOTAL_MOLES(environment)

			src.results.fields += "Tank Pressure: [round(pressure,0.1)] kPa"
			if(total_moles)
				LIST_CONCENTRATION_REPORT(environment, src.results.fields)
				src.results.fields += "|n"

			else
				src.results.fields += "Tank Empty"
		else
			src.results.fields += "None. (Sensor Error?)"

		src.results.fields += "Atmospheric Tank #2:"
		if(tank2 && tank1?.air_contents)
			var/datum/gas_mixture/environment = tank2.return_air()
			var/pressure = MIXTURE_PRESSURE(environment)
			var/total_moles = TOTAL_MOLES(environment)

			src.results.fields += "Tank Pressure: [round(pressure,0.1)] kPa"
			if(total_moles)
				LIST_CONCENTRATION_REPORT(environment, src.results.fields)
				src.results.fields += "|n"

			else
				src.results.fields += "Tank Empty"
		else
			src.results.fields += "None. (Sensor Error?)"

		src.results.fields += "VR Bomb Monitor log:|nWaiting for monitor..."

		src.tape.root.add_file( src.results )
		src.sync(src.host_id)
		return

	///Called by our vrbomb as it heats up (Or doesn't.)
	proc/update_bomb_log(var/newdata, var/sync_log = 0)
		if(!src.results || !newdata || !tape)
			return

		src.results.fields += newdata
		if (sync_log)
			src.sync(src.host_id)
		return

///Generic disk to hold VR bomb log
/obj/item/disk/data/bomb_tester
	desc = "You shouldn't be seeing this!"
	title = "TEMPBUFFER"
	file_amount = 4


ADMIN_INTERACT_PROCS(/obj/machinery/networked/nuclear_charge, proc/activate, proc/deactivate, proc/detonate)

TYPEINFO(/obj/machinery/networked/nuclear_charge)
	mats = list("energy_extreme" = 27,
				"metal_superdense" = 25,
				"conductive_high" = 13,
				"crystal_dense" = 15) //haha this is a bad idea
/obj/machinery/networked/nuclear_charge
	name = "Nuclear Charge"
	anchored = ANCHORED_ALWAYS
	density = 1
	icon_state = "net_nuke0"
	desc = "A nuclear charge used as a self-destruct device. Uh oh!"
	device_tag = "PNET_NUCCHARGE"
	var/timing = 0
	var/time = 180
	power_usage = 120

	var/status_display_freq = FREQ_STATUS_DISPLAY


#define DISARM_CUTOFF 10 //Can't disarm past this point! OH NO!

	deconstruct_flags = DECON_NONE
	is_syndicate = 1 //^ Agreed

	New()
		..()
		src.net_id = generate_net_id(src)
		MAKE_DEFAULT_RADIO_PACKET_COMPONENT(src.net_id, null, status_display_freq)
		SPAWN(0.5 SECONDS)
			if(!src.link)
				var/turf/T = get_turf(src)
				var/obj/machinery/power/data_terminal/test_link = locate() in T
				if(test_link && !DATA_TERMINAL_IS_VALID_MASTER(test_link, test_link.master))
					src.link = test_link
					src.link.master = src

	attack_hand(mob/user)
		if(..() || status & NOPOWER)
			return

		var/dat = "<html><head><title>Nuclear Charge</title></head><body>"

		dat += "<hr>[src.timing ? "SYSTEM ACTIVE" : "System Idle"]<br>Time: [src.time]<hr>"

		var/readout_color = "#000000"
		var/readout = "ERROR"
		if(src.host_id)
			readout_color = "#33FF00"
			readout = "OK CONNECTION"
		else
			readout_color = "#F80000"
			readout = "NO CONNECTION"

		dat += "Host Connection: "
		dat += "<table border='1' style='background-color:[readout_color]'><tr><td><font color=white>[readout]</font></td></tr></table><br>"

		dat += "<a href='byond://?src=\ref[src];reset=1'>Reset Connection</a><br>"

		if (src.panel_open)
			dat += net_switch_html()

		user.Browse(dat,"window=pnetnuke;size=245x302")
		onclose(user,"pnetnuke")
		return

	Topic(href, href_list)
		if(..())
			return

		src.add_dialog(usr)

		if (href_list["reset"])
			if(last_reset && (last_reset + NETWORK_MACHINE_RESET_DELAY >= world.time))
				return

			if(!host_id)
				return

			src.last_reset = world.time
			var/rem_host = src.host_id ? src.host_id : src.old_host_id
			src.host_id = null
			src.old_host_id = null
			src.post_status(rem_host, "command","term_disconnect")
			SPAWN(0.5 SECONDS)
				src.post_status(rem_host, "command","term_connect","device",src.device_tag)

			src.updateUsrDialog()
			return

		src.add_fingerprint(usr)
		return

	was_deconstructed_to_frame(mob/user)
		. = ..()
		src.timing = FALSE
		src.time = initial(src.time)

	process()
		..()
		if(status & NOPOWER)
			return

		if(!host_id || !link)
			return

		if(src.timeout == 0)
			src.post_status(host_id, "command","term_disconnect","data","timeout")
			src.host_id = null
			src.updateUsrDialog()
			src.timeout = initial(src.timeout)
			src.timeout_alert = 0
		else
			src.timeout--
			if(src.timeout <= 5 && !src.timeout_alert)
				src.timeout_alert = 1
				src.post_status(src.host_id, "command","term_ping","data","reply")

		if(src.timing)
			src.time--
			post_display_status(src.time)
			if(src.time <= 0)
				outpost_destroyed = 1
				src.detonate()
				return
			if(src.time == DISARM_CUTOFF)
				playsound_global(world, 'sound/misc/airraid_loop_short.ogg', 90)
			if(src.time <= DISARM_CUTOFF)
				src.icon_state = "net_nuke2"
				boutput(world, SPAN_ALERT("<b>[src.time] seconds until nuclear charge detonation.</b>"))
			else
				src.time -= 2
				src.icon_state = "net_nuke1"

			src.updateUsrDialog()
		else
			src.icon_state = "net_nuke0"

		return

	power_change()
		if(powered())
			status &= ~NOPOWER
			if(src.timing)
				if(src.time <= DISARM_CUTOFF)
					src.icon_state = "net_nuke2"
				else
					src.icon_state = "net_nuke1"
			else
				src.icon_state = "net_nuke0"
		else
			SPAWN(rand(0, 15))
				icon_state = "net_nuke-p"
				status |= NOPOWER

		return

	attackby(obj/item/W, mob/user)
		if (isscrewingtool(W))
			playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
			boutput(user, "You [src.panel_open ? "secure" : "unscrew"] the maintenance panel.")
			src.panel_open = !src.panel_open
			src.updateUsrDialog()
			return
		else
			..()

	receive_signal(datum/signal/signal)
		if(status & (NOPOWER) || !src.link)
			return
		if(!signal || !src.net_id || signal.encryption)
			return

		if(signal.transmission_method != TRANSMISSION_WIRE)
			return

		var/target = signal.data["sender"]

		//They don't need to target us specifically to ping us.
		//Otherwise, if they aren't addressing us, ignore them
		if(signal.data["address_1"] != src.net_id)
			if((signal.data["address_1"] == "ping") && ((signal.data["net"] == null) || ("[signal.data["net"]]" == "[src.net_number]")) && signal.data["sender"])
				SPAWN(0.5 SECONDS) //Send a reply for those curious jerks
					src.post_status(target, "command", "ping_reply", "device", src.device_tag, "netid", src.net_id, "net", "[src.net_number]")

			return

		var/sigcommand = lowertext(signal.data["command"])
		if(!sigcommand || !signal.data["sender"])
			return

		switch(sigcommand)
			if("term_connect") //Terminal interface stuff.
//				if(target == src.host_id)
//					//WHAT IS THIS, HOW COULD THIS HAPPEN??
//					src.host_id = null
//					src.updateUsrDialog()
//					SPAWN(0.3 SECONDS)
//						src.post_status(target, "command","term_disconnect")
//					return

				if(src.host_id && src.host_id != target)
					return

				src.timeout = initial(src.timeout)
				src.timeout_alert = 0
				src.host_id = target
				src.old_host_id = target
				if(signal.data["data"] != "noreply")
					src.post_status(target, "command","term_connect","data","noreply","device",src.device_tag)
				src.updateUsrDialog()
				SPAWN(0.2 SECONDS) //Sign up with the driver (if a mainframe contacted us)
					src.post_status(target,"command","term_message","data","command=register&data=nucharge")
				return

			if("term_message","term_file")
				if(target != src.host_id) //Huh, who is this?
					return

				var/list/data = params2list(signal.data["data"])
				if(!data)
					return

				var/sessionid = data["session"]
				if (!sessionid)
					sessionid = 0

				switch(data["command"])
					if("status")
						var/status_string = "command=n_status"
						status_string += "&active=[src.timing]&timeleft=[src.time]&session=[sessionid]"
						SPAWN(0)
							src.post_status(target,"command","term_message","data",status_string)
						return

					if("settime")
						if(src.timing) //No changing the time when we're already timing!
							src.post_status(target,"command","term_message","data","command=status&status=failure&session=[sessionid]")
							return
						var/thetime = text2num_safe(data["time"])
						if(isnull(thetime))
							src.post_status(target,"command","term_message","data","command=status&status=noparam&session=[sessionid]")
							return
						thetime = clamp(thetime, MIN_NUKE_TIME, MAX_NUKE_TIME)
						src.time = thetime
						src.post_status(target,"command","term_message","data","command=status&status=success&session=[sessionid]")
						return
					if("act")
						if(src.timing)
							src.post_status(target,"command","term_message","data","command=status&status=failure&session=[sessionid]")
							return
						if(data["auth"] != netpass_heads)
							src.post_status(target,"command","term_message","data","command=status&status=badauth&session=[sessionid]")
							return

						src.post_status(target,"command","term_message","data","command=status&status=success&session=[sessionid]")
						src.activate()
						return
					if("deact")
						if(data["auth"] != netpass_heads)
							src.post_status(target,"command","term_message","data","command=status&status=badauth&session=[sessionid]")
							return
						if(!src.timing || src.time <= DISARM_CUTOFF)
							src.post_status(target,"command","term_message","data","command=status&status=failure&session=[sessionid]")
							return

						src.post_status(target,"command","term_message","data","command=status&status=success&session=[sessionid]")
						src.deactivate()
						return

				return

			if("term_ping")
				if(target != src.host_id)
					return
				if(signal.data["data"] == "reply")
					src.post_status(target, "command","term_ping")
				src.timeout = initial(src.timeout)
				src.timeout_alert = 0
				return

			if("term_disconnect")
				if(target == src.host_id)
					src.host_id = null
				src.timeout = initial(src.timeout)
				src.timeout_alert = 0 //no really please stay zero
				src.updateUsrDialog()
				return

		return

	proc/activate()
		src.timing = 1
		var/admessage = "NUKE: Network Nuclear Charge armed for [time] seconds."
		var/turf/T = get_turf(src)
		if(T)
			admessage += "<b> ([T.x],[T.y],[T.z])</b>"
		message_admins(admessage)
		//World announcement.
		if (src.z == Z_LEVEL_STATION)
			command_alert("The [station_or_ship()]'s self-destruct sequence has been activated at coordinates (<b>X</b>: [src.x], <b>Y</b>: [src.y], <b>Z</b>: [src.z]), please evacuate the [station_or_ship()] or abort the sequence as soon as possible. Detonation in T-[src.time] seconds", "Self-Destruct Activated", alert_origin = ALERT_STATION)
			playsound_global(world, 'sound/machines/engine_alert2.ogg', 40)
		else
			command_alert("A nuclear charge at [get_area(src)] has been activated, please stay clear or abort the sequence as soon as possible. Detonation in T-[src.time] seconds", "Nuclear Charge Activated", alert_origin = ALERT_STATION)
			playsound_global(world, 'sound/misc/airraid_loop.ogg', 25)

	proc/deactivate()
		src.timing = 0
		src.time = max(src.time,MIN_NUKE_TIME) //so we don't have some jerk letting it tick down to 11 and then saving it for later.
		src.icon_state = "net_nuke0"
		//World announcement.
		if (src.z == Z_LEVEL_STATION)
			command_alert("The [station_or_ship()]'s detonation has been aborted. Please return to your regular duties.", "Self-Destruct Aborted", alert_origin = ALERT_STATION)
			playsound_global(world, 'sound/misc/announcement_1.ogg', 25)
		else
			command_alert("The nuclear charge at [get_area(src)] has been de-activated.", "Nuclear Charge De-activated", alert_origin = ALERT_STATION)
			playsound_global(world, 'sound/misc/announcement_1.ogg', 25)
		post_display_status(-1)

	proc/detonate()
		playsound_global(world, 'sound/effects/kaboom.ogg', 70)
		//explosion(src, src.loc, 10, 20, 30, 35)
		explosion_new(src, get_turf(src), 10000)
		//dispose()
		src.dispose()
		return



	proc/post_display_status(var/timeleft)
		var/datum/signal/status_signal = get_free_signal()
		status_signal.source = src
		status_signal.transmission_method = 1
		status_signal.data["address_tag"] = "STATDISPLAY"
		if(timeleft < 0)
			status_signal.data["command"] = "blank"
		else
			status_signal.data["command"] = "destruct"
			status_signal.data["time"] = "[timeleft]"

		SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, status_signal)

#undef DISARM_CUTOFF


TYPEINFO(/obj/machinery/networked/radio)
	mats = 8

/obj/machinery/networked/radio
	name = "Network Radio"
	desc = "A networked radio interface."
	anchored = ANCHORED
	density = 1
	icon_state = "net_radio"
	device_tag = "PNET_PR6_RADIO"
	//var/freq = FREQ_BUDDY
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_CROWBAR | DECON_WELDER | DECON_WIRECUTTERS | DECON_MULTITOOL | DECON_DESTRUCT
	var/list/frequencies = list()
	var/transmission_range = 100 //How far does our signal reach?
	var/take_radio_input = 1 //Do we echo radio signals addresed to us back to our host?
	var/can_be_host = 0
	power_usage = 100
	var/last_ping = 0

	New()
		..()

		src.net_id = generate_net_id(src)

		SPAWN(0.5 SECONDS)

			if (radio_controller)
				add_frequency(FREQ_AIRLOCK)
				add_frequency(FREQ_FREE)

			if(!src.link)
				var/turf/T = get_turf(src)
				var/obj/machinery/power/data_terminal/test_link = locate() in T
				if(test_link && !DATA_TERMINAL_IS_VALID_MASTER(test_link, test_link.master))
					src.link = test_link
					src.link.master = src

	proc/add_frequency(newFreq)
		frequencies["[newFreq]"] = MAKE_DEFAULT_RADIO_PACKET_COMPONENT(src.net_id, "f[newFreq]", newFreq)

	attack_hand(mob/user)
		if(..() || (status & (NOPOWER|BROKEN)))
			return

		src.add_dialog(user)

		var/dat = "<html><head><title>Network Radio</title></head><body>"

		dat += "Active  Frequencies:<hr>"
		if (frequencies.len)
			var/linebreakCounter = 2
			for (var/theFreq in frequencies)
				dat += "[copytext(theFreq, 1, 4)].[copytext(theFreq, 4)] MHz&nbsp;&nbsp;&nbsp;"
				if (linebreakCounter-- < 1)
					linebreakCounter = 2
					dat += "<br>"

		else
			dat += "<center>None</center>"


		var/readout_color = "#000000"
		var/readout = "ERROR"
		if(src.host_id)
			readout_color = "#33FF00"
			readout = "OK CONNECTION"
		else
			readout_color = "#F80000"
			readout = "NO CONNECTION"

		dat += "<hr>Host Connection: "
		dat += "<table border='1' style='background-color:[readout_color]'><tr><td><font color=white>[readout]</font></td></tr></table><br>"

		dat += "<a href='byond://?src=\ref[src];reset=1'>Reset Connection</a><br>"

		if (src.panel_open)
			dat += net_switch_html()

		user.Browse(dat,"window=net_radio;size=245x302")
		onclose(user,"net_radio")
		return

	attackby(obj/item/W, mob/user)
		if (isscrewingtool(W))
			playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
			boutput(user, "You [src.panel_open ? "secure" : "unscrew"] the maintenance panel.")
			src.panel_open = !src.panel_open
			src.updateUsrDialog()
			return
		else
			..()

	Topic(href, href_list)
		if(..())
			return

		src.add_dialog(usr)

		if (href_list["reset"])
			if(last_reset && (last_reset + NETWORK_MACHINE_RESET_DELAY >= world.time))
				return

			if(!host_id)
				return

			src.last_reset = world.time
			var/rem_host = src.host_id ? src.host_id : src.old_host_id
			src.host_id = null
			src.old_host_id = null
			src.post_status(rem_host, "command","term_disconnect")
			SPAWN(0.5 SECONDS)
				src.post_status(rem_host, "command","term_connect","device",src.device_tag)

			src.updateUsrDialog()
			return

		src.add_fingerprint(usr)
		return


	power_change()
		if(powered())
			icon_state = "net_radio"
			status &= ~NOPOWER
		else
			SPAWN(rand(0, 15))
				icon_state = "net_radio0"
				status |= NOPOWER

	process()
		..()
		if(status & NOPOWER)
			return

		if(!host_id || !link)
			return

		if(src.timeout == 0)
			src.post_status(host_id, "command","term_disconnect","data","timeout")
			src.host_id = null
			src.updateUsrDialog()
			src.timeout = initial(src.timeout)
			src.timeout_alert = 0
		else
			src.timeout--
			if(src.timeout <= 5 && !src.timeout_alert)
				src.timeout_alert = 1
				src.post_status(src.host_id, "command","term_ping","data","reply")

		return

	receive_signal(datum/signal/signal, transmission_type, range, connection_id)
		if(status & (NOPOWER) || !src.link)
			return
		if(!signal || !src.net_id || signal.encryption)
			return
		var/theFreq = isnull(connection_id) ? null : text2num_safe(copytext(connection_id, 2))

		var/target = signal.data["sender"] ? signal.data["sender"] : signal.data["netid"]
		if(!target)
			return

		//We care very deeply about address_1.
		if(!cmptext(signal.data["address_1"], src.net_id))
			if((signal.data["address_1"] == "ping") && ((signal.data["net"] == null) || ("[signal.data["net"]]" == "[src.net_number]")))
				SPAWN(0.5 SECONDS) //Send a reply for those curious jerks
					if (signal.transmission_method == TRANSMISSION_RADIO)
						var/datum/signal/rsignal = get_free_signal()
						rsignal.source = src
						rsignal.data = list("address_1"=target, "command"="ping_reply", "device"=src.device_tag, "netid"=src.net_id, "net"="[net_number]", "sender" = src.net_id)
						SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, rsignal, null, connection_id)
					else
						src.post_status(target, "command", "ping_reply", "device", src.device_tag, "netid", src.net_id, "net", "[net_number]")
				return

			if (signal.transmission_method == TRANSMISSION_WIRE)
				return
		//	if (!signal.data["target_device"])
		//		return

		if(signal.transmission_method == TRANSMISSION_RADIO && src.take_radio_input)
			if(!host_id)
				if (can_be_host && signal.data["address_2"])
					var/datum/signal/redirected_signal = get_free_signal()
					redirected_signal.source = src
					redirected_signal.transmission_method = TRANSMISSION_WIRE
					redirected_signal.data = signal.data:Copy()
					redirected_signal.data["address_1"] = redirected_signal.data["address_2"]
					redirected_signal.data["sender1"] = redirected_signal.data["sender"]
					redirected_signal.data["sender"] = src.net_id
					src.link.post_signal(src, redirected_signal)

				return
			//var/list/working = signal.data:Copy()
			var/datum/computer/working_file = null
			if(signal.data_file)
				working_file = signal.data_file.copy_file()

			var/workparams = list2params(signal.data)
			if(!workparams)
				//qdel(working)
			//	if (working)
			//		working.len = 0
			//		working = null
				//qdel(working_file)
				if (working_file)
					working_file.dispose()
				return

			if (theFreq)
				workparams += "&_freq=[theFreq]"

			SPAWN(0.2 SECONDS)
				if(working_file)
					src.post_file(src.host_id,"data",workparams,working_file)
				else
					src.post_status(src.host_id,"command","term_message","data",workparams)

			return

		var/sigcommand = lowertext(signal.data["command"])
		if(!sigcommand || !target)
			return

		switch(sigcommand)
			if("term_connect") //Terminal interface stuff.
//				if(target == src.host_id)
//					src.host_id = null
//					src.updateUsrDialog()
//					SPAWN(0.3 SECONDS)
//						src.post_status(target, "command","term_disconnect")
//					return

				if (src.host_id && src.host_id != target)
					return

				src.timeout = initial(src.timeout)
				src.timeout_alert = 0
				src.host_id = target
				src.old_host_id = target
				if(signal.data["data"] != "noreply")
					src.post_status(target, "command","term_connect","data","noreply","device",src.device_tag)
				src.updateUsrDialog()
				SPAWN(0.5 SECONDS) //Sign up with the driver (if a mainframe contacted us)
					src.post_status(target,"command","term_message","data","command=register[(length(frequencies)) ? "&freqs=[jointext(frequencies,",")]" : ""]")
				return

			if("term_message","term_file")
				if(target != src.host_id) //Huh, who is this?
					return

				var/list/data = params2list(signal.data["data"])
				if(!data || !data["_freq"])// || (!data["_command"] && !data["address_1"] && data["acc_code"] != netpass_heads) ) //Either address a specific bot or have the code for all of them, buddy
					src.post_status(target,"command","term_message","data","command=status&status=failure")
					return

				if (data["_command"])
					switch (lowertext(data["_command"]))
						if ("add")
							var/newFreq = "[round(clamp(text2num_safe(data["_freq"]), 1000, 1500))]"
							if (newFreq && !(newFreq in frequencies))
								add_frequency(newFreq)

						if ("remove")
							var/newFreq = "[round(clamp(text2num_safe(data["_freq"]), 1000, 1500))]"
							if (newFreq && (newFreq in frequencies))
								qdel(frequencies[newFreq])
								frequencies -= newFreq

						if ("clear")
							for (var/x in frequencies)
								qdel(frequencies[x])

							frequencies.len = 0

						else
							src.post_status(target,"command","term_message","data","command=status&status=failure")
					return

				var/newFreq = round(clamp(text2num_safe(data["_freq"]), 1000, 1500))
				data -= "_freq"
				if (!newFreq || !radio_controller || !length(data))
					src.post_status(target,"command","term_message","data","command=status&status=failure")
					return

				if(!("[newFreq]" in src.frequencies))
					src.post_status(target,"command","term_message","data","command=status&status=failure")
					return

				var/datum/signal/rsignal = get_free_signal()
				rsignal.source = src
				rsignal.data = data.Copy()

				rsignal.data["sender"] = src.net_id

				SPAWN(0)
					SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, rsignal, transmission_range, "f[newFreq]")
					FLICK("net_radio-blink", src)
				src.post_status(target,"command","term_message","data","command=status&status=success")

				return

			if("term_ping")
				if(target != src.host_id)
					return
				if(signal.data["data"] == "reply")
					src.post_status(target, "command","term_ping")
				src.timeout = initial(src.timeout)
				src.timeout_alert = 0
				return

			if("term_disconnect")
				if(target == src.host_id)
					src.host_id = null
				src.timeout = initial(src.timeout)
				src.timeout_alert = 0 //No need to be alerted about this anymore.
				src.updateUsrDialog()
				return

		return


TYPEINFO(/obj/machinery/networked/printer)
	mats = 6

/obj/machinery/networked/printer
	name = "Printer"
	desc = "A networked printer.  It's designed to print."
	anchored = ANCHORED
	density = 1
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_WIRECUTTERS | DECON_MULTITOOL | DECON_DESTRUCT
	icon_state = "printer0"
	device_tag = "PNET_PRINTDEVC"
	power_usage = 50
	machine_registry_idx = MACHINES_PRINTERS
	var/print_id = null //Just like databanks.
	var/temp_msg = "PRINTER OK" //Appears in the interface window.
	var/printing = 0 //Are we printing RIGHT NOW?
	var/list/print_buffer = list() //Are we waiting to print anything?
	var/jam = 0 //Oh no! A jam! I hope somebody unjams us right quick!
	var/blinking = 0 //Is our indicator light blinking?
	var/sheets_remaining = 15 //How many blank sheets of paper do we have left?

#define MAX_SHEETS 20
#define SETUP_JAM_IGNITION 6 //How jammed do we have to be before we break down?
#define MAX_PRINTBUFFER_SIZE 10

	New()
		START_TRACKING
		..()
		src.AddComponent(/datum/component/obj_projectile_damage)
		if(!print_id)
			src.print_id = "GENERIC"

		SPAWN(0.5 SECONDS)
			src.net_id = generate_net_id(src)

			if(!src.link)
				var/turf/T = get_turf(src)
				var/obj/machinery/power/data_terminal/test_link = locate() in T
				if(test_link && !DATA_TERMINAL_IS_VALID_MASTER(test_link, test_link.master))
					src.link = test_link
					src.link.master = src

			src.UpdateIcon() //Update the icon
		return

	disposing()
		STOP_TRACKING
		..()


	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/paper)) //Load up the printer!
			if (sheets_remaining >= MAX_SHEETS)
				boutput(user, SPAN_ALERT("The tray is full!"))
				return

			if(W:info)
				boutput(user, SPAN_ALERT("That paper has already been used!"))
				return

			user.drop_item()
			qdel(W)
			boutput(user, "You load the paper into [src].")
			if(!src.sheets_remaining && !src.jam)
				src.clear_alert()

			src.sheets_remaining++
			src.updateUsrDialog()
			return

		else if (istype(W, /obj/item/paper_bin)) //Load up the printer!
			var/obj/item/paper_bin/bin = W
			if (sheets_remaining >= MAX_SHEETS)
				boutput(user, SPAN_ALERT("The tray is full!"))
				return

			var/to_remove = MAX_SHEETS - sheets_remaining
			if(bin.amount_left > to_remove)
				bin.amount_left -= to_remove
				boutput(user, "You load [to_remove] sheets into the tray.")
				src.sheets_remaining += to_remove
			else
				boutput(user, "You load [bin.amount_left] sheets into the tray.")
				src.sheets_remaining += bin.amount_left
				user.drop_item()
				qdel(W)

			if(!src.jam)
				src.clear_alert()

			if(src.temp_msg == "PC LOAD LETTER")
				src.temp_msg = "PRINTER OK"
			src.updateUsrDialog()
			return

		else if (isscrewingtool(W))
			playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
			boutput(user, "You [src.panel_open ? "secure" : "unscrew"] the maintenance panel.")
			src.panel_open = !src.panel_open
			src.updateUsrDialog()
			return

		else
			return attack_hand(user)

	onDestroy()
		if (src.powered())
			elecflash(src, power = 2)
		playsound(src.loc, 'sound/impact_sounds/Machinery_Break_1.ogg', 50, 1)
		. = ..()

	attack_hand(mob/user)
		if(..() || (status & (NOPOWER|BROKEN)))
			return

		src.add_dialog(user)

		var/dat = "<html><head><title>Printer - \[[print_id]]</title></head><body>"

		dat += "<hr><tt>[temp_msg]</tt><hr>"

		if(jam)
			dat += "<b>Printing:</b> <a href='byond://?src=\ref[src];unjam=1'>JAMMED</a><br>"
		else
			dat += "<b>Printing:</b> [printing ? "YES" : "NO"]<br>"

		var/readout_color = "#000000"
		var/readout = "ERROR"
		if(src.host_id)
			readout_color = "#33FF00"
			readout = "OK CONNECTION"
		else
			readout_color = "#F80000"
			readout = "NO CONNECTION"

		dat += "Host Connection: "
		dat += "<table border='1' style='background-color:[readout_color]'><tr><td><font color=white>[readout]</font></td></tr></table><br>"

		dat += "<a href='byond://?src=\ref[src];reset=1'>Reset Connection</a><br>"

		if (src.panel_open)
			dat += net_switch_html()

		user.Browse(dat,"window=printer;size=245x302")
		onclose(user,"printer")
		return

	Topic(href, href_list)
		if(..())
			return

		src.add_dialog(usr)

		if (href_list["unjam"])
			if(src.jam)
				if(BOUNDS_DIST(src, usr) > 0)
					boutput(usr, "You are too far away to unjam it.")
					return
				src.jam = 0
				src.blinking = 0
				src.UpdateIcon()
				src.temp_msg = "PRINTER OK"
				src.updateUsrDialog()
				boutput(usr, SPAN_NOTICE("You clear the jam."))
			else
				boutput(usr, "There is no jam to clear.")

		else if (href_list["reset"])
			if(last_reset && (last_reset + NETWORK_MACHINE_RESET_DELAY >= world.time))
				return

			if(!host_id)
				return

			src.print_buffer.len = 0
			src.last_reset = world.time
			var/rem_host = src.host_id ? src.host_id : src.old_host_id
			src.host_id = null
			src.old_host_id = null
			src.post_status(rem_host, "command","term_disconnect")
			SPAWN(0.5 SECONDS)
				src.post_status(rem_host, "command","term_connect","device",src.device_tag)

			src.updateUsrDialog()
			return

		src.add_fingerprint(usr)
		return

	process()
		if(status & BROKEN)
			printing = 0
			return
		..()
		if(status & NOPOWER)
			printing = 0
			return

		if(!host_id || !link)
			return

		if(src.timeout == 0)
			src.post_status(host_id, "command","term_disconnect","data","timeout")
			src.host_id = null
			src.updateUsrDialog()
			src.timeout = initial(src.timeout)
			src.timeout_alert = 0
		else
			src.timeout--
			if(src.timeout <= 5 && !src.timeout_alert)
				src.timeout_alert = 1
				src.post_status(src.host_id, "command","term_ping","data","reply")

		if(!printing && length(print_buffer))
			src.print()

		return

	receive_signal(datum/signal/signal)
		if(status & (NOPOWER|BROKEN) || !src.link)
			return
		if(!signal || !src.net_id || signal.encryption)
			return

		if(signal.transmission_method != TRANSMISSION_WIRE) //No radio for us thanks
			return

		var/target = signal.data["sender"]

		if(signal.data["address_1"] != src.net_id)
			if((signal.data["address_1"] == "ping") && ((signal.data["net"] == null) || ("[signal.data["net"]]" == "[src.net_number]")) && signal.data["sender"])
				SPAWN(0.5 SECONDS)
					src.post_status(target, "command", "ping_reply", "device", src.device_tag, "netid", src.net_id, "net", "[net_number]")

			return

		var/sigcommand = lowertext(signal.data["command"])
		if(!sigcommand || !signal.data["sender"])
			return

		switch(sigcommand)
			if("term_connect") //Terminal interface stuff.
/*
				if(target == src.host_id)
					//WHAT IS THIS, HOW COULD THIS HAPPEN??
					src.host_id = null
					src.updateUsrDialog()
					SPAWN(0.3 SECONDS)
						src.post_status(target, "command","term_disconnect")
					return
*/
				if (src.host_id && src.host_id != target)
					return

				src.timeout = initial(src.timeout)
				src.timeout_alert = 0
				src.host_id = target
				src.old_host_id = target
				if(signal.data["data"] != "noreply")
					src.post_status(target, "command","term_connect","data","noreply","device",src.device_tag)
				src.updateUsrDialog()
				SPAWN(0.2 SECONDS) //Sign up with the driver (if a mainframe contacted us)
					src.post_status(target,"command","term_message","data","command=register&data=[src.print_id]")
				return

			if("term_message","term_file")
				if(target != src.host_id) //Huh, who is this?
					return

				var/list/data = params2list(signal.data["data"])
				if(!data)
					return

				switch(data["command"])
					if("print")

						if(!signal.data_file || (!istype(signal.data_file, /datum/computer/file/text) && !istype(signal.data_file, /datum/computer/file/record) && !istype(signal.data_file, /datum/computer/file/image)))
							src.post_status(target,"command","term_message","data","command=status&status=badfile")
							return

						if(print_buffer.len+1 > MAX_PRINTBUFFER_SIZE)
							src.post_status(target,"command","term_message","data","command=status&status=bufferfull")
							return

						var/buffer_add = null
						if (istype(signal.data_file, /datum/computer/file/image)) // pic-a-ture
							buffer_add = signal.data_file:data
							if (!buffer_add)
								src.post_status(target,"command","term_message","data","command=status&status=badfile")
								return
						else
							if(istype(signal.data_file, /datum/computer/file/record))
								var/datum/computer/file/record/rec = signal.data_file
								if (rec.fields)
									buffer_add = jointext(rec.fields, "<br>")
							else
								buffer_add = signal.data_file:data

							if(!buffer_add)
								src.post_status(target,"command","term_message","data","command=status&status=badfile")
								return


							var/title = copytext(data["title"], 1, 64)
							if (!title)
								title = "printout"

							buffer_add = "[title]&title;[buffer_add]"
						src.print_buffer += buffer_add
						return
					if("clearbuffer")
						src.print_buffer.len = 0
						src.post_status(target,"command","term_message","data","command=status&status=success")
						return
				return

			if("term_ping")
				if(target != src.host_id)
					return
				if(signal.data["data"] == "reply")
					src.post_status(target, "command","term_ping")
				src.timeout = initial(src.timeout)
				src.timeout_alert = 0
				return

			if("term_disconnect")
				if(target == src.host_id)
					src.host_id = null
				src.timeout = initial(src.timeout)
				src.timeout_alert = 0
				src.updateUsrDialog()
				return

		return

	proc
		print()
			if(status & (NOPOWER|BROKEN))
				return 0
			if(!src.host_id)
				return 0
			if(src.printing || !length(print_buffer))
				return 0

			var/print_text = print_buffer[1]
			print_buffer.Cut(1,2) //Remove the first stage.

//			if(!userid)
//				src.post_status(src.host_id,"command","term_message","data","command=status&status=nouser")
//				return 0

			if(!sheets_remaining)
				src.post_status(src.host_id,"command","term_message","data","command=status&status=nopaper")
				return 0
			if(prob(1) || src.jam)
				if(jam())
					return 1
				src.post_status(src.host_id,"command","term_message","data","command=status&status=jam")
				src.print_alert()
				return 1

			src.printing = 1
			if(!print_text)
				src.printing = 0
				return 0

			sheets_remaining--
			use_power(200)

			FLICK("printer-printing",src)
			playsound(src.loc, 'sound/machines/printer_dotmatrix.ogg', 50, 1)
			SPAWN(3.2 SECONDS)

				if (istype(print_text, /datum/computer/file/image)) // trying to print a photo! :I
					var/datum/computer/file/image/IMG = print_text
					/*var/obj/item/photo/P = */new/obj/item/photo(src.loc, IMG.ourImage, IMG.ourIcon, IMG.img_name, IMG.img_desc)
					/*P.fullImage = IMG.ourImage ? IMG.ourImage : image(IMG.ourIcon)
					P.fullIcon = IMG.ourIcon
					P.name = IMG.img_name
					P.desc = IMG.img_desc*/
				else
					var/obj/item/paper/P = new /obj/item/paper
					P.set_loc(src.loc)


					var/titlepoint = findtext(print_text, "&title;",1 , 72)
					if (titlepoint)
						P.name = "paper- '[copytext(print_text,1,titlepoint)]'"
						print_text = copytext(print_text, titlepoint+7)
					else
						P.name = "paper- 'Printout'"

					P.info = print_text

					var/formStartPoint = 1
					var/formEndPoint = 0

					if (!P.form_startpoints)
						P.form_startpoints = list()
						P.form_endpoints = list()

					. = 0
					while (formStartPoint)
						formStartPoint = findtext(P.info, "__", formStartPoint)
						if (formStartPoint)
							formEndPoint = formStartPoint + 1
							while (copytext(P.info, formEndPoint, formEndPoint+1) == "_")
								formEndPoint++

							P.form_startpoints["[.]"] = formStartPoint
							P.form_endpoints["[.++]"] = formEndPoint

							formStartPoint = formEndPoint+1

				src.printing = 0

			if(sheets_remaining <= 0)
				temp_msg = "PC LOAD LETTER"
				src.print_alert()
				src.post_status(src.host_id,"command","term_message","data","command=status&status=lowpaper")
			else
				src.post_status(src.host_id,"command","term_message","data","command=status&status=success")
			src.updateUsrDialog()
			return 1

		jam()
			jam++
			if(jam >= SETUP_JAM_IGNITION && !(status & BROKEN))
				status |= BROKEN
				src.visible_message(SPAN_ALERT("<b>[src]</b> bursts into flames!"))
				src.printing = 0
				src.print_buffer.len = 0

				src.UpdateIcon()

				elecflash(src,power = 3)
				if(src.host_id) //welp, we're broken.
					src.post_status(src.host_id,"command","term_message","data","command=status&status=thermalert")
				return 1

			src.printing = 0
			src.print_buffer.len = 0
			return 0

		print_alert()
			blinking = 1
			src.UpdateIcon()
			playsound(src.loc, 'sound/machines/buzz-sigh.ogg', 50, 1)
			src.visible_message(SPAN_ALERT("[src] pings!"))
			return

		clear_alert()
			blinking = 0
			src.UpdateIcon()
			return

	update_icon()
		if(src.jam) //Update jam overlay.
			src.UpdateOverlays(image(src.icon,"printer-jamoverlay"), "jam")
		else
			src.UpdateOverlays(null, "jam")

		if(status & BROKEN)
			icon_state = "printerb"
			return
		if(status & NOPOWER)
			icon_state = "printer-p"
			return

		if(src.blinking)
			icon_state = "printer-blink"
		else
			icon_state = "printer0"
		return

#undef MAX_SHEETS
#undef SETUP_JAM_IGNITION
#undef MAX_PRINTBUFFER_SIZE

/obj/machinery/networked/storage/scanner
	name = "Scanner"
	desc = "A networked drum scanner.  It's designed to...scan documents."
	anchored = ANCHORED
	density = 1
	icon_state = "scanner0"
	deconstruct_flags = DECON_DESTRUCT
	//device_tag = "PNET_SCANDEVC"
	var/scanning = 0 //Are we scanning RIGHT NOW?
	var/obj/item/scanned_thing //Ideally, this would be a paper or photo.

	var/datum/computer/file/scan_buffer

	setup_access_click = 0
	read_only = 1
	setup_drive_size = 16
	setup_drive_type = /obj/item/disk/data/bomb_tester
	setup_accept_tapes = 0
	power_usage = 50

	New()
		..()
		if (!dd_hasprefix(uppertext(src.bank_id),"SC-"))
			src.bank_id = "SC-[bank_id]"

	attack_hand(mob/user)
		if(status & (NOPOWER|BROKEN))
			return

		if(user.lying || user.stat)
			return 1

		if ((BOUNDS_DIST(src, user) > 0 || !istype(src.loc, /turf)) && !issilicon(user))
			return 1

		src.add_dialog(user)

		var/dat = "<html><head><title>Scanner - \[[copytext(bank_id,4)]]</title></head><body>"

		dat += "<b>Document:</b> <a href='byond://?src=\ref[src];document=1'>[src.scanned_thing ? src.scanned_thing.name : "-----"]</a><br>"

		var/readout_color = "#000000"
		var/readout = "ERROR"
		if(src.host_id)
			readout_color = "#33FF00"
			readout = "OK CONNECTION"
		else
			readout_color = "#F80000"
			readout = "NO CONNECTION"

		dat += "Host Connection: "
		dat += "<table border='1' style='background-color:[readout_color]'><tr><td><font color=white>[readout]</font></td></tr></table><br>"

		dat += "<a href='byond://?src=\ref[src];reset=1'>Reset Connection</a><br>"

		if (src.panel_open)
			dat += net_switch_html()

		user.Browse(dat,"window=scanner;size=245x302")
		onclose(user,"scanner")
		return

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/paper) || istype(W, /obj/item/photo))
			if (scanned_thing)
				boutput(user, SPAN_ALERT("There is already something in the scanner!"))
				return

			user.drop_item()
			W.set_loc(src)
			scanned_thing = W
			power_change()
			SPAWN(0)
				if(!scan_document())
					use_power(200)
			src.updateUsrDialog()

		else
			return ..()

	MouseDrop_T(obj/item/W, mob/user)
		if (!in_interact_range(src, user)  || BOUNDS_DIST(W, user) > 0 || !can_act(user))
			return
		else
			if (istype(W, /obj/item/paper) || istype(W, /obj/item/photo))
				if (scanned_thing)
					boutput(user, SPAN_ALERT("There is already something in the scanner!"))
					return

				W.set_loc(src)
				scanned_thing = W
				power_change()
				SPAWN(0)
					if(!scan_document(0))
						use_power(200)
				src.updateUsrDialog()

			else
				return ..()

	Topic(href, href_list)
		if(..())
			return

		src.add_dialog(usr)

		if (href_list["document"])
			if(issilicon(usr) && BOUNDS_DIST(src, usr) > 0)
				boutput(usr, SPAN_ALERT("There is no electronic control over the actual document."))
				return

			if (scanned_thing)
				scanned_thing.set_loc(src.loc)
				scanned_thing = null
			else
				var/obj/item/I = usr.equipped()
				if (istype(I, /obj/item/magtractor))
					var/obj/item/magtractor/mag = I
					if (istype(mag.holding, /obj/item/paper) || istype(mag.holding, /obj/item/photo))
						I = mag.holding
						mag.dropItem(0)
					else
						return
				else if (istype(I, /obj/item/paper) || istype(I, /obj/item/photo))
					usr.drop_item()
				else
					return
				I.set_loc(src)
				src.scanned_thing = I
				boutput(usr, "You insert [I].")
				SPAWN(0)
					if(!scan_document())
						use_power(200)

			src.power_change()
			src.updateUsrDialog()


		src.add_fingerprint(usr)
		return

	power_change()
		if(powered())
			status &= ~NOPOWER
			src.icon_state = "scanner[!isnull(scanned_thing)]"
		else
			SPAWN(rand(0, 15))
				status |= NOPOWER
				src.icon_state = "scanner[!isnull(scanned_thing)]-p"
		return

	process()
		if(status & BROKEN)
			return
		..()
		if(status & NOPOWER)
			return

		if(!host_id || !link)
			return

		if(src.timeout == 0)
			src.post_status(host_id, "command","term_disconnect","data","timeout")
			src.host_id = null
			src.updateUsrDialog()
			src.timeout = initial(src.timeout)
			src.timeout_alert = 0
		else
			src.timeout--
			if(src.timeout <= 5 && !src.timeout_alert)
				src.timeout_alert = 1
				src.post_status(src.host_id, "command","term_ping","data","reply")

		return

	proc/scan_document()
		if ((status & (NOPOWER|BROKEN)) || !src.host_id || src.scanning)
			return 1

		if (!scanned_thing)
			return 1

		scanning = 1
		FLICK("scanner-scanning",src)
		sleep(2 SECONDS)
		if (scan_buffer)
			scan_buffer.dispose()
			scan_buffer = null

		if (istype(scanned_thing, /obj/item/paper))
			var/obj/item/paper/paper_thing = scanned_thing
			var/datum/computer/file/record/scanned = new
			scanned.fields = process_paper_info( paper_thing.info )
			scanned.name = "document"
			if (src.tape.root.add_file( scanned ))
				scan_buffer = scanned
				src.sync(src.host_id)
				playsound(src.loc, 'sound/machines/ping.ogg', 50, 0)
			else
				scanned.dispose()

			scanning = 0
			return 0
		else if (istype(scanned_thing, /obj/item/photo))
			var/obj/item/photo/photo_thing = scanned_thing
			var/datum/computer/file/image/scanned = new
			scanned.ourIcon = photo_thing.fullIcon
			scanned.name = "document"
			scanned.img_name = photo_thing.name
			scanned.img_desc = photo_thing.desc
			if (src.tape.root.add_file( scanned ))
				scan_buffer = scanned
				src.sync(src.host_id)
				playsound(src.loc, 'sound/machines/ping.ogg', 50, 0)
			else
				scanned.dispose()

			scanning = 0
			return 0

		scanning = 0
		return 1

	proc/process_paper_info(var/info)
		if (!istext(info))
			return null

		var/list/output = list()
		var/infoLength = length(info)
		var/searchPosition = 1
		var/findPosition = 1

		while (1)
			findPosition = findtext(info, "<br>", searchPosition, 0)
			. = copytext(info, searchPosition, findPosition)
			var/innerOpen = 1
			var/innerClose = 1
			while (1)
				innerOpen = findtext(., "<", 1, 0)
				innerClose = findtext(., ">", innerOpen, 0)
				if (!innerOpen || !innerClose)
					break

				. = copytext(., 1, innerOpen) + copytext(., innerClose + 1)


			output += .
			if (!findPosition)
				break

			searchPosition = findPosition + 4
			if (searchPosition > infoLength)
				break

		return output


//IR tripwire/threat analyzer.
/obj/machinery/networked/secdetector
	name = "IR Detector"
	desc = "An infrared tripwire and video camera coupled with a sophisticated threat-analysis system."
	icon_state = "secdetector0"
	device_tag = "PNET_IR_DETECT"

	var/detector_id = null
	var/obj/beam/ir_beam/scan_beam = null
	var/online = 1 //Are we looking for anything or just sitting there?
	var/state = 1 //1 idle, 2 active, 3 triggered.
	var/active_time = 0 //Set >0 when active, decrement every tick, return to idle state when zero.

	var/active_brightness = 0.7 //Luminosity when seeking (State == 2)
	var/alert_brightness = 0.4

	var/setup_beam_length = 24 //Max length of scan_beam.
	var/setup_active_time = 20 //Length of time active after beam is crossed.
	var/setup_alerted_time = 60 //Length of time alerted after seeing a threat.
	var/area_access = access_heads //ID access required to not be considered a threat.

	var/datum/light/light

	New()
		..() //Set detector ID if not already set, generate net ID, then update icon.
		if(!detector_id)
			src.detector_id = "GENERIC"

		light = new /datum/light/point
		light.set_color(0.20, 0.65, 0.20)
		light.attach(src)

		SPAWN(0.5 SECONDS)
			src.net_id = generate_net_id(src)

			if(!src.link)
				var/turf/T = get_turf(src)
				var/obj/machinery/power/data_terminal/test_link = locate() in T
				if(test_link && !DATA_TERMINAL_IS_VALID_MASTER(test_link, test_link.master))
					src.link = test_link
					src.link.master = src

			src.UpdateIcon()
		return
/*
	disposing()
		if (src.scan_beam)
			qdel(src.scan_beam)

		..()
*/
	disposing()
		if (src.scan_beam)
			src.scan_beam.dispose()
			src.scan_beam = null
		if (src.link)
			src.link.master = null
			src.link = null

		..()

	attack_hand(mob/user)
		if(..() || (status & (NOPOWER|BROKEN)))
			return

		src.add_dialog(user)

		var/dat = "<html><head><title>IR Detector - \[[detector_id]]</title></head><body>"

		dat += "Status: "
		switch (state)
			if (0)
				dat += "<b>INACTIVE</b>"
			if (1)
				dat += "<b>IDLE</b>"
			if (2)
				dat += "<b>ON GUARD</b>"
			if (3)
				dat += "<b>ALERTED</b>"
			else
				dat += "<b>ERROR</b>"

		var/readout_color = "#000000"
		var/readout = "ERROR"
		if(src.host_id)
			readout_color = "#33FF00"
			readout = "OK CONNECTION"
		else
			readout_color = "#F80000"
			readout = "NO CONNECTION"

		dat += "<br>Host Connection: "
		dat += "<table border='1' style='background-color:[readout_color]'><tr><td><font color=white>[readout]</font></td></tr></table><br>"

		dat += "<a href='byond://?src=\ref[src];reset=1'>Reset Connection</a><br>"

		if (src.panel_open)
			dat += net_switch_html()

		user.Browse(dat,"window=secdetector;size=245x302")
		onclose(user,"secdetector")
		return

	Topic(href, href_list)
		if(..())
			return

		src.add_dialog(usr)

		if (href_list["reset"])
			if(last_reset && (last_reset + NETWORK_MACHINE_RESET_DELAY >= world.time))
				return

			if(!host_id)
				return

			src.last_reset = world.time
			var/rem_host = src.host_id ? src.host_id : src.old_host_id
			src.host_id = null
			src.old_host_id = null
			src.post_status(rem_host, "command","term_disconnect")
			SPAWN(0.5 SECONDS)
				src.post_status(rem_host, "command","term_connect","device",src.device_tag)

			src.updateUsrDialog()
			return

		src.add_fingerprint(usr)
		return

	process()
		if (status & BROKEN)
			return
		power_usage = max(20, 20*src.state)
		..()
		if (status & NOPOWER)
			return

		if (active_time > 0)
			active_time--
			if (!active_time)
				//src.state = src.online
				src.UpdateIcon(src.online)

		switch (src.state)
			if (0)
				if (src.scan_beam)
					qdel(src.scan_beam)
					src.scan_beam = null
			if (1)
				if (!src.scan_beam)
					var/turf/beamTurf = get_step(src, src.dir)
					if (!istype(beamTurf) || beamTurf.density)
						return
					src.scan_beam = new /obj/beam/ir_beam(beamTurf, setup_beam_length)
					src.scan_beam.master = src
					src.scan_beam.set_dir(src.dir)

				return
			if (2)
				for (var/mob/living/C in view(7,src))
					if (C.stat)
						continue

					if (assess_threat(C))
						src.state = 3
						src.active_time = src.setup_alerted_time

						if (src.host_id)
							src.post_status(src.host_id,"command","term_message","data","command=statechange&state=alert")

						src.UpdateIcon(3)
						playsound(src.loc, 'sound/machines/whistlealert.ogg', 50, 1)
						return

				return

		return

	receive_signal(datum/signal/signal)
		if((status & (NOPOWER|BROKEN)) || !src.link)
			return
		if(!signal || !src.net_id || signal.encryption)
			return

		if(signal.transmission_method != TRANSMISSION_WIRE) //Wired comms only.
			return

		var/target = signal.data["sender"]

		if(signal.data["address_1"] != src.net_id)
			if((signal.data["address_1"] == "ping") && ((signal.data["net"] == null) || ("[signal.data["net"]]" == "[src.net_number]")) && signal.data["sender"])
				SPAWN(0.5 SECONDS)
					src.post_status(target, "command", "ping_reply", "device", src.device_tag, "netid", src.net_id, "net", "[src.net_number]")

			return

		var/sigcommand = lowertext(signal.data["command"])
		if(!sigcommand || !signal.data["sender"])
			return

		switch(sigcommand)
			if("term_connect") //Terminal interface stuff.
//				if(target == src.host_id)

//					src.host_id = null
//					src.updateUsrDialog()
//					SPAWN(0.3 SECONDS)
//						src.post_status(target, "command","term_disconnect")
//					return

				if (src.host_id && src.host_id != target)
					return

				src.timeout = initial(src.timeout)
				src.timeout_alert = 0
				src.host_id = target
				src.old_host_id = target
				if(signal.data["data"] != "noreply")
					src.post_status(target, "command","term_connect","data","noreply","device",src.device_tag)
				src.updateUsrDialog()
				SPAWN(0.2 SECONDS) //Sign up with the driver (if a mainframe contacted us)
					src.post_status(target,"command","term_message","data","command=register&data=[src.detector_id]")
				return

			if("term_message","term_file")
				if(target != src.host_id) //Huh, who is this?
					return

				var/list/data = params2list(signal.data["data"])
				if(!data)
					return

				switch(lowertext(data["command"]))
					if("activate")
						src.online = 1
						src.UpdateIcon(max(1, src.state))

					if("deactivate")
						src.online = 0
						src.active_time = 0
						src.UpdateIcon(0)


				return

			if("term_ping")
				if(target != src.host_id)
					return
				if(signal.data["data"] == "reply")
					src.post_status(target, "command","term_ping")
				src.timeout = initial(src.timeout)
				src.timeout_alert = 0
				return

			if("term_disconnect")
				if(target == src.host_id)
					src.host_id = null
				src.timeout = initial(src.timeout)
				src.timeout_alert = 0
				src.updateUsrDialog()
				return

		return

	ex_act(severity)
		switch(severity)
			if(1)
				qdel(src)
				return
			if(2)
				if (prob(50))
					src.status |= BROKEN
					src.UpdateIcon(0)
			if(3)
				if (prob(25))
					src.status |= BROKEN
					src.UpdateIcon(0)

	power_change()
		if(powered(ENVIRON))
			status &= ~NOPOWER
		else
			status |= NOPOWER

		src.UpdateIcon(src.state)


	update_icon(var/newState = 1)
		if (status & (NOPOWER|BROKEN))
			light.disable()
			icon_state = "secdetector-p"
			if (src.scan_beam)
				qdel(src.scan_beam)
				src.scan_beam = null
			src.state = src.online
			return

		var/change = (src.state != newState)
		src.state = newState

		icon_state = "secdetector[src.state]"
		switch (src.state)
			if (2 to 3)
				light.set_brightness(src.state == 2 ? src.active_brightness : src.alert_brightness)
				light.enable()
			if (1)
				light.disable()
				if (src.host_id && change)
					SPAWN(0)
						src.post_status(src.host_id,"command","term_message","data","command=statechange&state=idle")
			if (0)
				light.disable()
				if (src.host_id && change)
					SPAWN(0)
						src.post_status(src.host_id,"command","term_message","data","command=statechange&state=inactive")

		return
	proc
		beam_crossed() //Called when anything solid crosses the beam, places us into the alert state.
			if (src.state != 1)
				return
			//qdel(src.scan_beam)
			if (src.scan_beam)
				src.scan_beam.dispose()
			src.active_time = src.setup_active_time
			UpdateIcon(2)
			if (src.host_id)
				src.post_status(src.host_id,"command","term_message","data","command=statechange&state=onguard")
			playsound(src.loc, 'sound/machines/whistlebeep.ogg', 50, 1)
			return

		assess_threat(mob/living/threat as mob) //Default scanners just check for humans without proper access and aliens.

			if (issilicon(threat))
				return 0

			if (ismonkey(threat))
				return 0

			if (!ishuman(threat))
				return 1

			var/mob/living/carbon/human/humanThreat = threat
			if (humanThreat.wear_id)
				if(area_access in humanThreat.wear_id:access)
					return 0

			return 1

/obj/beam
	var/obj/beam/next
	var/limit = 48

	layer = NOLIGHT_EFFECTS_LAYER_BASE
	anchored = ANCHORED
	flags = TABLEPASS
	event_handler_flags = USE_FLUID_ENTER

	disposing()
		if (src.next)
			qdel(src.next)
			src.next = null
		..()

	Bumped()
		src.hit()
		return

	Crossed(atom/movable/AM as mob|obj)
		..()
		if (istype(AM, /obj/beam) || istype(AM, /mob/living/critter/aberration) || isobserver(AM) || isintangible(AM))
			return
		SPAWN( 0 )
			src.hit(AM)
			return
		return

	proc
		hit(atom/movable/AM as mob|obj)

		generate_next()
			if (src.limit < 1)
				return

			var/turf/nextTurf = get_step(src, src.dir)
			if (istype(nextTurf))
				if (nextTurf.density)
					return

				src.next = new src.type(nextTurf, src.limit-1)
				//next.master = src.master
				next.set_dir(src.dir)
				for (var/atom/movable/hitAtom in nextTurf)
					if (hitAtom.density && !hitAtom.anchored)
						src.hit(hitAtom)

					continue
			return

//Infrared beam for secdetector
/obj/beam/ir_beam
	name = "infrared beam"
	desc = "A beam of infrared light."
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "ibeam"
	invisibility = INVIS_CLOAK
	//var/obj/beam/ir_beam/next = null
	var/obj/machinery/networked/secdetector/master = null
	//var/limit = 24
	anchored = ANCHORED
	flags = TABLEPASS
	event_handler_flags = USE_FLUID_ENTER

	New(location, newLimit)
		..()
		if (newLimit != null)
			src.limit = newLimit
		SPAWN(0.3 SECONDS)
			generate_next()
		return
/*
	disposing()
		if (src.next)
			qdel(src.next)

		..()
*/
	disposing()

		src.master = null

		..()


	Crossed(atom/movable/AM as mob|obj)
		..()
		if(isobserver(AM) || isintangible(AM)) return
		if (istype(AM, /obj/beam))
			return
		SPAWN( 0 )
			src.hit()
			return
		return

	hit()
		if (istype(src.master))
			src.master.beam_crossed()
		//dispose()
		src.dispose()
		return

	generate_next()
		if (src.limit < 1)
			return

		var/turf/nextTurf = get_step(src, src.dir)
		if (istype(nextTurf))
			if (nextTurf.density)
				return

			src.next = new /obj/beam/ir_beam(nextTurf, src.limit-1)
			next:master = src.master
			next.set_dir(src.dir)
		return

//Rather fancy science emitter gizmo
/obj/machinery/networked/h7_emitter
	name = "HEPT emitter"
	desc = "An incredibly complex and dangerous analysis tool that generates a particle-transposition beam via applied use of telecrystal properties."
	icon_state = "heptemitter0"
	device_tag = "PNET_HEPT_EMIT"
	dir = NORTH

	var/obj/linked_laser/h7_beam/beam = null
	var/list/telecrystals[5]
	var/crystalCount = 0
	power_usage = 0

	New()
		..()

		SPAWN(0.5 SECONDS)
			src.net_id = generate_net_id(src)

			if(!src.link)
				var/turf/T = get_turf(src)
				var/obj/machinery/power/data_terminal/test_link = locate() in T
				if(test_link && !DATA_TERMINAL_IS_VALID_MASTER(test_link, test_link.master))
					src.link = test_link
					src.link.master = src

			src.UpdateIcon()
		return
/*
	disposing()
		if (src.beam)
			qdel(src.beam)

		..()
*/
	disposing()
		if (src.beam)
			src.beam.dispose()
			src.beam = null

		if (src.link)
			src.link.master = null
			src.link = null

		for (var/obj/item/I in src.telecrystals)
			I.set_loc(src.loc)

		src.telecrystals.len = 0
		..()

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/raw_material/telecrystal))
			return attack_hand(user)
		else if (isscrewingtool(W))
			playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
			boutput(user, "You [src.panel_open ? "secure" : "unscrew"] the maintenance panel.")
			src.panel_open = !src.panel_open
			src.updateUsrDialog()
			return
		else
			..()
		return

	attack_hand(mob/user)
		if(..() || (status & (NOPOWER|BROKEN)))
			return

		src.add_dialog(user)

		var/dat = "<html><head><title>HEPT Emitter</title></head><body><hr><center>Emission Crystals<br>"

		if (!telecrystals)
			telecrystals = new/list(5)

		if (beam)
			dat += "<i>Panel is locked while active</i><br><table border='1'><tr>"
		else
			dat += "<table border='1'><tr>"

		for (var/i = 1, i <= telecrystals.len, i++)
			if (src.beam)

				if (isnull(telecrystals[i]))
					dat += "<td style='background-color:#F80000'><font color=white>-----</font></td>"
				else
					dat += "<td style='background-color:#33FF00'><font color=white>+++++</font></td>"
			else
				if (isnull(telecrystals[i]))
					dat += "<td style='background-color:#F80000'><font color=white><a href='byond://?src=\ref[src];insert=[i]'>-----</a></font></td>"
				else
					dat += "<td style='background-color:#33FF00'><font color=white><a href='byond://?src=\ref[src];eject=[i]'>EJECT</a></font></td>"

		var/readout_color = "#000000"
		var/readout = "ERROR"
		if(src.host_id)
			readout_color = "#33FF00"
			readout = "OK CONNECTION"
		else
			readout_color = "#F80000"
			readout = "NO CONNECTION"

		dat += "</tr></table></center><hr><br>Host Connection: "
		dat += "<table border='1' style='background-color:[readout_color]'><tr><td><font color=white>[readout]</font></td></tr></table><br>"

		dat += "<a href='byond://?src=\ref[src];reset=1'>Reset Connection</a><br>"

		if (src.panel_open)
			dat += net_switch_html()

		user.Browse(dat,"window=h7emitter;size=285x302")
		onclose(user,"h7emitter")
		return

	Topic(href, href_list)
		if(..())
			return

		src.add_dialog(usr)
		src.add_fingerprint(usr)

		if (href_list["insert"])
			if (src.beam)
				boutput(usr, SPAN_ALERT("The panel is locked."))
				return

			var/targetSlot = round(text2num_safe(href_list["insert"]))
			if (!targetSlot || (targetSlot < 1) || (targetSlot > telecrystals.len))
				return

			if (telecrystals[targetSlot] != null)
				return

			var/obj/item/I = usr.equipped()
			if (istype(I, /obj/item/raw_material/telecrystal))
				usr.drop_item()
				I.set_loc(src)
				telecrystals[targetSlot] = I
				crystalCount = min(crystalCount + 1, telecrystals.len)
				boutput(usr, SPAN_NOTICE("You insert [I] into the slot."))
			else if (istype(I, /obj/item/magtractor))
				var/obj/item/magtractor/mag = I
				if (istype(mag.holding, /obj/item/raw_material/telecrystal))
					I = mag.holding
					mag.dropItem(0)
					I.set_loc(src)
					telecrystals[targetSlot] = I
					crystalCount = min(crystalCount + 1, telecrystals.len)
					boutput(usr, SPAN_NOTICE("You insert [I] into the slot."))

			src.updateUsrDialog()
			return

		else if (href_list["eject"])
			if (src.beam)
				boutput(usr, SPAN_ALERT("The panel is locked."))
				return

			var/targetCrystal = round(text2num_safe(href_list["eject"]))
			if (!targetCrystal || (targetCrystal < 1) || (targetCrystal > telecrystals.len))
				return

			var/obj/item/toEject = telecrystals[targetCrystal]
			if (toEject)
				telecrystals[targetCrystal] = null
				crystalCount = max(crystalCount - 1, 0)
				toEject.set_loc(get_turf(src))
				usr.put_in_hand_or_eject(toEject) // try to eject it into the users hand, if we can
				boutput(usr, SPAN_NOTICE("You remove [toEject] from the slot."))

			src.updateUsrDialog()
			return

		else if (href_list["reset"])
			if(last_reset && (last_reset + NETWORK_MACHINE_RESET_DELAY >= world.time))
				return

			if(!host_id)
				return

			src.last_reset = world.time
			var/rem_host = src.host_id ? src.host_id : src.old_host_id
			src.host_id = null
			src.old_host_id = null
			src.post_status(rem_host, "command","term_disconnect")
			SPAWN(0.5 SECONDS)
				src.post_status(rem_host, "command","term_connect","device",src.device_tag)

			src.updateUsrDialog()
			return

		src.add_fingerprint(usr)
		return

	process()
		if (status & BROKEN)
			return
		power_usage = 200 * crystalCount
		..()
		if (status & NOPOWER)
			return
		return

	receive_signal(datum/signal/signal)
		if(status & (NOPOWER|BROKEN) || !src.link)
			return
		if(!signal || !src.net_id || signal.encryption)
			return

		if(signal.transmission_method != TRANSMISSION_WIRE)
			return

		var/target = signal.data["sender"]

		if(signal.data["address_1"] != src.net_id)
			if((signal.data["address_1"] == "ping") && ((signal.data["net"] == null) || ("[signal.data["net"]]" == "[src.net_number]")) && signal.data["sender"])
				SPAWN(0.5 SECONDS)
					src.post_status(target, "command", "ping_reply", "device", src.device_tag, "netid", src.net_id, "net", "[src.net_number]")

			return

		var/sigcommand = lowertext(signal.data["command"])
		if(!sigcommand || !signal.data["sender"])
			return

		switch(sigcommand)
			if("term_connect")
/*				if(target == src.host_id)

					src.host_id = null
					src.updateUsrDialog()
					SPAWN(0.3 SECONDS)
						src.post_status(target, "command","term_disconnect")
					return
*/
				if (src.host_id && src.host_id != target)
					return

				src.timeout = initial(src.timeout)
				src.timeout_alert = 0
				src.host_id = target
				src.old_host_id = target
				if(signal.data["data"] != "noreply")
					src.post_status(target, "command","term_connect","data","noreply","device",src.device_tag)
				src.updateUsrDialog()
				SPAWN(0.2 SECONDS) //Sign up with the driver (if a mainframe contacted us)
					src.post_status(target,"command","term_message","data","command=register&data=[isnull(src.beam) ? "0" : "1"]")
				return

			if("term_message","term_file")
				if(target != src.host_id)
					return

				var/list/data = params2list(signal.data["data"])
				if(!data)
					return

				switch(lowertext(data["command"]))
					if("activate")
						if (!src.beam && src.generate_beam())
							src.post_status(target,"command","term_message","data","command=ack")
						else
							src.post_status(target,"command","term_message","data","command=nack")

					if("deactivate")
						if (src.beam)
							//qdel(src.beam)
							src.beam.dispose()
						src.post_status(target,"command","term_message","data","command=ack")

				return

			if("term_ping")
				if(target != src.host_id)
					return
				if(signal.data["data"] == "reply")
					src.post_status(target, "command","term_ping")
				src.timeout = initial(src.timeout)
				src.timeout_alert = 0
				return

			if("term_disconnect")
				if(target == src.host_id)
					src.host_id = null
				src.timeout = initial(src.timeout)
				src.timeout_alert = 0
				src.updateUsrDialog()
				return

		return

	power_change()
		if(powered())
			status &= ~NOPOWER
			src.UpdateIcon()
		else
			SPAWN(rand(0, 15))
				status |= NOPOWER
				src.UpdateIcon()

	ex_act(severity)
		switch(severity)
			if(1)
				//dispose()
				src.dispose()
				return
			if(2)
				if (prob(50))
					src.status |= BROKEN
					src.UpdateIcon()
			if(3)
				if (prob(25))
					src.status |= BROKEN
					src.UpdateIcon()

	update_icon()
		if (status & (NOPOWER|BROKEN))
			src.icon_state = "heptemitter-p"
			if (src.beam)
				//qdel(src.beam)
				src.beam.dispose()
		else
			src.icon_state = "heptemitter[src.beam ? "1" : "0"]"
		return

	proc
		generate_beam()
			if ((status & (NOPOWER|BROKEN)) || !crystalCount)
				return 0

			if (!beam)
				var/turf/beamTurf = get_step(src, src.dir)
				if (!istype(beamTurf) || beamTurf.density)
					return 0
				src.beam = new /obj/linked_laser/h7_beam(beamTurf, src.dir)
				src.beam.master = src
				src.beam.try_propagate()
			else
				src.beam.traverse(/obj/linked_laser/h7_beam/proc/update_master_power)

			UpdateIcon()
			src.updateUsrDialog()
			return 1

//Deathbeam for preceding death emitter

//Generic test apparatus
TYPEINFO(/obj/machinery/networked/test_apparatus)
	mats = 8

/obj/machinery/networked/test_apparatus
	name = "Generic Testing Apparatus"
	desc = "A large device designed to facilitate...some manner... of analysis."
	icon_state = "pathmanip0"

	var/active = 0 //If this device is currently activated in some manner. The device will assume the icon state of setup_base_icon_state + active (1 : 0) when the icon is updated.
	var/session = null

	var/setup_base_icon_state = "pathmanip"
	var/setup_test_id = "GENERIC" //Simple test identifier, sent upon mainframe connection.
	var/setup_device_name = "Testing Apparatus" //Device name to appear in html interface
	var/setup_capability_value = "E" //E for Enactor (provides a stimulus), S for Sensor (Records stimulus), or B for both.
	//Don't forget to give devices unique device_tag values of the form "PNET_XXXXXXXXX"
	device_tag = "PNET_TEST_APPT" //This is the device tag used to interface with the mainframe GTPIO driver.
	deconstruct_flags = DECON_DESTRUCT

	power_usage = 200
	var/dragload = 0 // can we click-drag a machinery-type artifact into this machine?

	New()
		..()

		SPAWN(0.5 SECONDS)
			src.net_id = generate_net_id(src)

			if(!src.link)
				var/turf/T = get_turf(src)
				var/obj/machinery/power/data_terminal/test_link = locate() in T
				if(test_link && !DATA_TERMINAL_IS_VALID_MASTER(test_link, test_link.master))
					src.link = test_link
					src.link.master = src

			src.UpdateIcon()
		return

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/raw_material/telecrystal))
			return attack_hand(user)

		else if (isscrewingtool(W))
			playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
			boutput(user, "You [src.panel_open ? "secure" : "unscrew"] the maintenance panel.")
			src.panel_open = !src.panel_open
			src.updateUsrDialog()
			return
		else
			..()
		return

	attack_hand(mob/user)
		if(..() || (status & (NOPOWER|BROKEN)))
			return

		src.add_dialog(user)

		var/dat = "<html><head><title>[setup_device_name]</title></head><body>"

		dat += "<hr>[return_html_interface()]<hr>"

		var/readout_color = "#000000"
		var/readout = "ERROR"
		if(src.host_id)
			readout_color = "#33FF00"
			readout = "OK CONNECTION"
		else
			readout_color = "#F80000"
			readout = "NO CONNECTION"

		dat += "<br>Host Connection: "
		dat += "<table border='1' style='background-color:[readout_color]'><tr><td><font color=white>[readout]</font></td></tr></table><br>"

		dat += "<a href='byond://?src=\ref[src];reset=1'>Reset Connection</a><br>"

		if (src.panel_open)
			dat += net_switch_html()

		user.Browse(dat,"window=testap\ref[src];size=285x302")
		onclose(user,"testap\ref[src]")
		return

	MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
		if (!istype(O,/obj/) || O.anchored) return
		if (BOUNDS_DIST(src, O) > 0 || !isturf(O.loc)) return
		if (!in_interact_range(user, O) || !in_interact_range(user, src) || !isalive(user)) return
		if (src.dragload)
			if (src.contents.len)
				boutput(user, SPAN_ALERT("[src.name] is already loaded!"))
				return
			src.visible_message("<b>[user.name]</b> loads [O] into [src.name]!")
			O.set_loc(src)
			src.UpdateIcon()
		else return

	mouse_drop(obj/over_object as obj, src_location, over_location)
		ejectContents(usr, over_object)

	verb/eject()
		set name = "Eject"
		set src in oview(1)
		set category = "Local"

		ejectContents(usr, get_turf(src))
		return

	proc/ejectContents(var/mob/unloader, var/target_location)
		if (!istype(target_location, /turf/)) return
		if (BOUNDS_DIST(src, target_location) > 0) return
		if (!in_interact_range(unloader, target_location) || !in_interact_range(unloader, src) || !isalive(unloader)) return
		if (src.active)
			boutput(unloader, SPAN_ALERT("You can't unload it while it's active!"))
			return
		for (var/atom/movable/O in src.contents) O.set_loc(target_location)
		src.visible_message("<b>[unloader.name]</b> unloads [src.name]!")
		src.UpdateIcon()

	Topic(href, href_list)
		if(..())
			return

		src.add_dialog(usr)
		src.add_fingerprint(usr)

		interface_topic(href_list)

		if (href_list["reset"])
			if(last_reset && (last_reset + NETWORK_MACHINE_RESET_DELAY >= world.time))
				return

			if(!host_id)
				return

			src.last_reset = world.time
			var/rem_host = src.host_id ? src.host_id : src.old_host_id
			src.host_id = null
			src.old_host_id = null
			src.post_status(rem_host, "command","term_disconnect")
			SPAWN(0.5 SECONDS)
				src.post_status(rem_host, "command","term_connect","device",src.device_tag)

			src.updateUsrDialog()
			return

		src.add_fingerprint(usr)
		return

	process()
		if (status & BROKEN)
			return 1
		..()
		if (status & NOPOWER)
			return 1

		if(active)
			use_power(power_usage) // power use doubles when active

		return 0

	receive_signal(datum/signal/signal)
		if(status & (NOPOWER|BROKEN) || !src.link)
			return
		if(!signal || !src.net_id || signal.encryption)
			return

		if(signal.transmission_method != TRANSMISSION_WIRE)
			return

		var/target = signal.data["sender"]

		if(signal.data["address_1"] != src.net_id)
			if((signal.data["address_1"] == "ping") && ((signal.data["net"] == null) || ("[signal.data["net"]]" == "[src.net_number]")) && signal.data["sender"])
				SPAWN(0.5 SECONDS)
					src.post_status(target, "command", "ping_reply", "device", src.device_tag, "netid", src.net_id, "net", "[src.net_number]")

			return

		var/sigcommand = lowertext(signal.data["command"])
		if(!sigcommand || !signal.data["sender"])
			return

		switch(sigcommand)
			if("term_connect")
/*
				if(target == src.host_id)

					src.host_id = null
					src.updateUsrDialog()
					SPAWN(0.3 SECONDS)
						src.post_status(target, "command","term_disconnect")
					return
*/
				if (src.host_id && src.host_id != target)
					return

				src.timeout = initial(src.timeout)
				src.timeout_alert = 0
				src.host_id = target
				src.old_host_id = target
				if(signal.data["data"] != "noreply")
					src.post_status(target, "command","term_connect","data","noreply","device",src.device_tag)
				src.updateUsrDialog()
				SPAWN(0.2 SECONDS) //Sign up with the driver (if a mainframe contacted us)
					src.message_host("command=register&id=[src.setup_test_id]&data=[isnull(src.active) ? "0" : "1"]&capability=[setup_capability_value]")
				return

			if("term_message","term_file")
				if(target != src.host_id)
					return

				var/list/data = params2list(signal.data["data"])
				if(!data)
					return

				if (data["session"])
					src.session = data["session"]
				else
					src.session = null

				src.message_interface(data)
				return

			if("term_ping")
				if(target != src.host_id)
					return
				if(signal.data["data"] == "reply")
					src.post_status(target, "command","term_ping")
				src.timeout = initial(src.timeout)
				src.timeout_alert = 0
				return

			if("term_disconnect")
				if(target == src.host_id)
					src.host_id = null
				src.timeout = initial(src.timeout)
				src.timeout_alert = 0
				src.updateUsrDialog()
				return

		return

	power_change()
		if(powered())
			status &= ~NOPOWER
			src.UpdateIcon()
		else
			SPAWN(rand(0, 15))
				status |= NOPOWER
				src.UpdateIcon()

	ex_act(severity)
		switch(severity)
			if(1)
				//dispose()
				src.dispose()
				return
			if(2)
				if (prob(50))
					src.status |= BROKEN
					src.UpdateIcon()
			if(3)
				if (prob(25))
					src.status |= BROKEN
					src.UpdateIcon()

	update_icon()
		if (status & (NOPOWER|BROKEN))
			src.icon_state = "[setup_base_icon_state]-p"
		else
			src.icon_state = "[setup_base_icon_state][src.active ? "1" : "0"]"
		return

	proc
		//Generate html interface to appear in interaction window above the host connection controls
		return_html_interface()
			return

		//The accompanying Topic to go with the html interface. Mob proximity and the reset input are already handled outside of this.
		interface_topic(list/href_list)
			return

		//Mainframe terminal message interface. Typically, a command is contained within the "command" key in the list, all values as strings.
		//Though this will generally be used by an appropriate mainframe driver, it IS possible for players to connect directly and issue their own commands
		//over the terminal interface.
		//Example response to "read" command:
		//	message_host("command=read&data=hello&format=sread")
		//Example response to "info" command:
		//	message_host("command=info&id=[src.setup_test_id]&capability=[setup_capability_value]&status=[src.active ? "1" : "0"]&valuelist=Power-Charge")
		message_interface(var/list/packetData)
			return

		//Send a terminal message to our host device
		message_host(var/message, var/datum/computer/file/file)
			if (!src.host_id || !message)
				return

			if (file)
				if (src.session)
					message += "&session=[src.session]"
				src.post_file(src.host_id,"data",message, file)
			else
				if (src.session)
					message += "&session=[src.session]"
				src.post_status(src.host_id,"command","term_message","data",message)

			return

//A test enactor that fires small objects at things. Things like artifacts.
/obj/machinery/networked/test_apparatus/pitching_machine
	name = "Automatic Pitching Machine"
	desc = "A large computer-controlled pitching machine."
	icon_state = "pitching0"

	setup_base_icon_state = "pitching"
	setup_test_id = "PITCHER"
	setup_device_name = "Pitching Machine"
	setup_capability_value = "E"

	var/throw_strength = 50
	var/setup_max_objects = 10

	return_html_interface()
		return "<b>Pitching:</b> [src.active ? "YES" : "NO"]<br><br><b>Strength:</b> [src.throw_strength]%"

	message_interface(var/list/packetData)
		switch (lowertext(packetData["command"]))
			if ("info")
				message_host("command=info&id=[src.setup_test_id]&capability=[setup_capability_value]&status=[src.active ? "1" : "0"]&valuelist=Power")

			if ("status")
				message_host("command=status&data=[src.active ? "1" : "0"]")

			if ("poke")
				if (lowertext(packetData["field"]) != "power")
					message_host("command=nack")
					return

				var/newPower = text2num_safe(packetData["value"])
				if (!isnum(newPower) || (newPower < 1) || (newPower > 100))
					message_host("command=nack")
					return

				throw_strength = round(newPower)
				message_host("command=ack")

			if ("peek")
				if (lowertext(packetData["field"]) != "power")
					message_host("command=nack")
					return

				message_host("command=peeked&field=power&value=[throw_strength]")

			if ("activate")
				if (src.contents.len)
					active = length(src.contents)
					message_host("command=ack")
					src.UpdateIcon()
				else
					message_host("command=nack")

			if ("pulse")
				var/duration = text2num_safe(packetData["duration"])
				if (isnum(duration))
					duration = round(clamp(duration, 1, 255))
				else
					src.active = 0
					message_host("command=nack")
					return

				src.active = duration
				message_host("command=ack")
				src.UpdateIcon()

			if ("deactivate")
				active = 0
				message_host("command=ack")
				src.UpdateIcon()

		return

	process()
		if (..())
			return
		if (src.active)
			if (src.contents.len)
				src.active--
				var/atom/movable/to_toss = pick(src.contents)
				if (istype(to_toss))
					to_toss.set_loc(src.loc)
					src.visible_message("<b>[src.name]</b> launches [to_toss]!")
					playsound(src.loc, 'sound/effects/syringeproj.ogg', 50, 1)
					to_toss.throw_at(get_edge_target_turf(src, src.dir), throw_strength, throw_strength/50, bonus_throwforce=throw_strength/4)

				if (!src.active)
					src.visible_message("<b>[src.name]</b> pings.")
					src.active = 0
					playsound(src, 'sound/machines/buzz-two.ogg', 50, TRUE)
					src.UpdateIcon()
				return

			src.visible_message("<b>[src.name]</b> pings.")
			src.active = 0
			playsound(src, 'sound/machines/chime.ogg', 50, TRUE)
			src.UpdateIcon()

		return

	attackby(var/obj/item/I, mob/user)
		if (src.status & (NOPOWER|BROKEN))
			return
		if (istype(I, /obj/item/grab))
			return
		if(!istype(I))
			boutput(user, "That is far too big to fit!")
			return

		var/obj/item/magtractor/mag
		if (istype(I, /obj/item/magtractor))
			mag = I
			if (isitem(mag.holding))
				I = mag.holding
			else
				return

		if (I.w_class < W_CLASS_BULKY)
			if (length(src.contents) < src.setup_max_objects)
				if(I.cant_drop)
					return
				if (mag)
					mag.dropItem(0)
				else if (I == user.equipped())
					user.drop_item()
				I.set_loc(src)
				user.visible_message("<b>[user]</b> loads [I] into [src.name]!")
				return
			else
				boutput(user, "There is no room left for that!")
				return
		else
			boutput(user, "That is far too big to fit!")
			return

	MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
		if (!istype(O,/obj/) || O.anchored) return
		if (BOUNDS_DIST(src, O) > 0 || !isturf(O.loc)) return
		if (!in_interact_range(user, O) || !in_interact_range(user, src) || !isalive(user)) return
		src.Attackby(O, user)

/obj/machinery/networked/test_apparatus/impact_pad
	name = "Impact Sensor Pad"
	desc = "A floor pad that detects the physical reactions of objects placed on it."
	icon_state = "impactpad0"
	density = 0

	setup_base_icon_state = "impactpad"
	setup_test_id = "IMPACTPAD"
	setup_device_name = "Impact Pad"
	setup_capability_value = "S"

	var/list/sensed = list("0","0")

	return_html_interface()
		return "<b>Detecting:</b> [src.active ? "YES" : "NO"]<br><br><b>Stand Extended:</b> [src.density ? "YES" : "NO"]"

	message_interface(var/list/packetData)
		switch (lowertext(packetData["command"]))
			if ("info")
				message_host("command=info&id=[src.setup_test_id]&capability=[setup_capability_value]&status=[src.active ? "1" : "0"]&valuelist=Stand&readinglist=Vibration Amplitude-VF,Vibration Frequency-VPS")

			if ("status")
				message_host("command=status&data=[src.active ? "1" : "0"]")

			if ("poke")
				if (lowertext(packetData["field"]) != "stand")
					message_host("command=nack")
					return

				var/standval = text2num_safe(packetData["value"])
				if (standval < 0 || standval > 1)
					message_host("command=nack")
					return

				if (standval == 1 && src.density == 0)
					if (!locate(/obj/item/) in src.loc.contents)
						src.visible_message("<b>[src.name]</b> extends its stand.")
						src.set_density(1)
						src.setup_base_icon_state = "impactstand"
						FLICK("impactpad-extend",src)
						src.UpdateIcon()
						playsound(src.loc, 'sound/effects/pump.ogg', 50, 1)
					else
						src.visible_message(SPAN_ALERT("<b>[src.name]</b> clanks and clatters noisily!"))
						playsound(src.loc, 'sound/impact_sounds/Metal_Clang_1.ogg', 50, 1)
					message_host("command=ack")
				else if (standval == 0 && src.density == 1)
					src.visible_message("<b>[src.name]</b> retracts its stand.")
					src.set_density(0)
					src.setup_base_icon_state = "impactpad"
					FLICK("impactstand-retract",src)
					src.UpdateIcon()
					playsound(src.loc, 'sound/effects/pump.ogg', 50, 1)
					message_host("command=ack")
				else
					message_host("command=ack")
					return

			if ("peek")
				if (lowertext(packetData["field"]) != "stand")
					message_host("command=nack")
					return

				message_host("command=peeked&field=stand&value=[density]")

			if ("read")
				if(src.sensed[1] == null || src.sensed[2] == null)
					message_host("command=nack")
				else
					message_host("command=read&data=[src.sensed[1]],[src.sensed[2]]")
					message_host("command=ack")

		return

	attackby(var/obj/item/I, mob/user)
		if (istype(I, /obj/item/grab))
			return
		var/obj/item/magtractor/mag
		if (istype(I, /obj/item/magtractor))
			mag = I
			if (isitem(mag.holding))
				I = mag.holding
			else
				return

		if (src.density)
			if (locate(/obj/item/) in src.loc.contents)
				boutput(user, SPAN_ALERT("There's already something on the stand!"))
				return
			else
				if(isitem(I) && I.cant_drop)
					return
				if (mag)
					mag.dropItem(0)
				else if (I == user.equipped())
					user.drop_item()
				I.set_loc(src.loc)
		else
			if(isitem(I) && I.cant_drop)
				return
			if (mag)
				mag.dropItem(0)
			else
				user.drop_item()
			I.set_loc(src.loc)

		return

	MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
		if (!istype(O,/obj/) || O.anchored) return
		if (BOUNDS_DIST(src, O) > 0 || !isturf(O.loc)) return
		if (!in_interact_range(user, O) || !in_interact_range(user, src) || !isalive(user)) return
		src.Attackby(O, user)

	hitby(atom/movable/M, datum/thrown_thing/thr)
		if (src.density)
			for (var/obj/item/I in src.loc.contents)
				I.hitby(M)
				if (istype(I.artifact,/datum/artifact/) && isitem(M))
					var/obj/item/ITM = M
					var/obj/ART = I
					src.impactpad_senseforce(ART, ITM)
		..()

	bullet_act(var/obj/projectile/P)
		if (src.density)
			for (var/obj/item/I in src.loc.contents)
				I.bullet_act(P)
				switch (P.proj_data.damage_type)
					if(D_KINETIC,D_PIERCING,D_SLASHING)
						src.impactpad_senseforce_shot(I, P)
				return

	proc/impactpad_senseforce(var/obj/I, var/obj/item/M)
		if (istype(I.artifact,/datum/artifact/))
			var/datum/artifact/ARTDATA = I.artifact
			var/stimforce = M.throwforce
			src.sensed[1] = stimforce * ARTDATA.react_mpct[1]
			src.sensed[2] = stimforce * ARTDATA.react_mpct[2]
			if (src.sensed[2] != 0 && length(ARTDATA.faults))
				src.sensed[2] += rand(ARTDATA.faults.len / 2,ARTDATA.faults.len * 2)
			var/datum/artifact_trigger/AT = ARTDATA.get_trigger_by_string("force")
			if (AT)
				src.sensed[1] *= 5
				src.sensed[2] *= 5
		else
			src.sensed[1] = "???"
			src.sensed[2] = "0"
		src.visible_message("<b>[src.name]</b> registers an impact and chimes.")
		playsound(src.loc, 'sound/machines/chime.ogg', 50, 1)

	proc/impactpad_senseforce_shot(var/obj/I, var/datum/projectile/P)
		if (istype(I.artifact,/datum/artifact/))
			var/datum/artifact/ARTDATA = I.artifact
			var/stimforce = P.power
			src.sensed[1] = stimforce * ARTDATA.react_mpct[1]
			src.sensed[2] = stimforce * ARTDATA.react_mpct[2]

			if (src.sensed[2] != 0 && length(ARTDATA.faults))
				src.sensed[2] += rand(ARTDATA.faults.len / 2,ARTDATA.faults.len * 2)

			var/datum/artifact_trigger/AT = ARTDATA.get_trigger_by_string("force")
			if (AT)
				src.sensed[1] *= 5
				src.sensed[2] *= 5
		else
			src.sensed[1] = "???"
			src.sensed[2] = "0"

		src.visible_message("<b>[src.name]</b> registers an impact and chimes.")
		playsound(src, 'sound/machines/chime.ogg', 50, TRUE)

/obj/machinery/networked/test_apparatus/electrobox
	name = "Electrical Testing Apparatus"
	desc = "A contained unit for exposing machinery to electrical currents."
	icon_state = "elecbox0"
	density = 1
	dragload = 1
	power_usage = 220

	setup_base_icon_state = "elecbox"
	setup_test_id = "ELEC_BOX"
	setup_device_name = "Electrical Testing Apparatus"
	setup_capability_value = "B"

	var/voltage = 10 // runs from 1 to 100
	var/amperage = 1  // runs from 1 to 50
	var/timer = 0
	var/list/sensed = list("???","???","100")

	return_html_interface()
		return "<b>Loaded:</b> [src.contents.len ? "YES" : "NO"]<br><b>Active:</b> [src.active ? "YES" : "NO"]<br><br><b>Amperage:</b> [src.amperage]A<br><b>Voltage:</b> [src.voltage]V"

	update_icon()
		if (src.contents.len)
			src.UpdateOverlays(image('icons/obj/networked.dmi', "elecbox-doors"), "doors")
		else
			src.UpdateOverlays(null, "doors")
		..()

	process()
		if (..())
			if (src.active && (status & NOPOWER))
				src.active = 0
			return
		if (!src.contents.len && src.active)
			src.active = 0
			src.visible_message("<b>[src.name]</b> buzzes angrily and stops operating!")
			playsound(src.loc, 'sound/machines/buzz-two.ogg', 50, 1)
			src.UpdateIcon()
			return

		if (src.active)
			use_power(src.amperage * src.voltage)
			if (src.timer > 0)
				src.timer--
			if (src.timer == 0)
				src.active = 0
				src.timer = -1
				src.visible_message("<b>[src.name]</b> emits a buzz and shuts down.")
				playsound(src.loc, 'sound/machines/buzz-sigh.ogg', 50, 1)
				src.UpdateIcon()
				return
			src.electrify_contents()

		return

	proc/electrify_contents()
		var/wattage = src.amperage * src.voltage
		if (locate(/mob/living/) in src.contents)
			for (var/mob/living/carbon/OUCH in src.contents)
				OUCH.TakeDamage("All",0,wattage / 500)
		else if(length(src.contents))
			var/obj/O = pick(src.contents)
			if (istype(O.artifact,/datum/artifact/))
				O.ArtifactStimulus("elec", wattage)

	attackby(var/obj/item/I, mob/user)
		if (src.status & (NOPOWER|BROKEN))
			return
		if (istype(I, /obj/item/grab))
			return // do this later when everything else is ironed out
		var/obj/item/magtractor/mag
		if (istype(I, /obj/item/magtractor))
			mag = I
			if (isitem(mag.holding))
				I = mag.holding
			else
				return

		if (!src.contents.len)
			if(I.cant_drop)
				return
			if (mag)
				mag.dropItem(0)
			else
				user.drop_item()
			I.set_loc(src)
			user.visible_message("<b>[user]</b> loads [I] into [src.name]!")
			src.UpdateIcon()
			return
		else
			boutput(user, "There is no room left for that!")
			return

	message_interface(var/list/packetData)
		switch (lowertext(packetData["command"]))
			if ("info")
				message_host("command=info&id=[src.setup_test_id]&capability=[setup_capability_value]&status=[src.active ? "1" : "0"]&valuelist=Voltage,Amperage&readinglist=Load Impedance-Ohm,Returned Amperage-A,Circuit Capacity-J,Interference-%")

			if ("status")
				message_host("command=status&data=[src.active ? "1" : "0"]")

			if ("poke")
				if (lowertext(packetData["field"]) != "voltage" && lowertext(packetData["field"]) != "amperage")
					message_host("command=nack")
					return

				var/pokeval = text2num_safe(packetData["value"])
				if (lowertext(packetData["field"]) == "voltage")
					if (pokeval < 1 || pokeval > 100)
						message_host("command=nack")
						return
					src.voltage = pokeval

				if (lowertext(packetData["field"]) == "amperage")
					if (pokeval < 1 || pokeval > 50)
						message_host("command=nack")
						return
					src.amperage = pokeval

				if (src.active)
					src.electrify_contents()
				message_host("command=ack")
				return

			if ("peek")
				if (lowertext(packetData["field"]) != "voltage" && lowertext(packetData["field"]) != "amperage")
					message_host("command=nack")
					return

				if (lowertext(packetData["field"]) == "voltage")
					message_host("command=peeked&field=voltage&value=[voltage]")
				else if (lowertext(packetData["field"]) == "amperage")
					message_host("command=peeked&field=amperage&value=[amperage]")

			if ("read")
				if(src.sensed[1] == null || src.sensed[2] == null || src.sensed[3] == null || !src.active)
					message_host("command=nack")
				else
					// Electrobox - returns Ohms, Return Amperage, Circuit Capacity, Circuit Interference
					var/ohms = "ERROR"
					if (src.amperage > 0 && src.voltage > 0)
						ohms = src.voltage / src.amperage
					message_host("command=read&data=[ohms],[src.sensed[1]],[src.sensed[2]],[src.sensed[3]]")
					message_host("command=ack")

			if ("sense")
				if (src.contents.len && src.active)
					var/obj/M = pick(src.contents)
					if (istype(M.artifact,/datum/artifact/))
						var/datum/artifact/A = M.artifact

						if (A.react_elec[1] == "equal")
							src.sensed[1] = src.amperage
						else
							src.sensed[1] = src.amperage * A.react_elec[1]

						src.sensed[2] = A.react_elec[2]

						src.sensed[3] = A.react_elec[3]

						if (A.artitype.name == "eldritch")
							src.sensed[3] += rand(-7,7)

						for(var/datum/artifact_fault in A.faults)
							if (prob(50))
								src.sensed[1] *= randfloat(1.5,4.0)
							else
								src.sensed[1] /= randfloat(1.5,4.0)
							src.sensed[3] += rand(-4,4)

						var/datum/artifact_trigger/AT = A.get_trigger_by_string("elec")
						if (AT)
							src.sensed[3] *= 3
					else
						src.sensed[1] = "???"
						src.sensed[2] = "???"
						src.sensed[3] = "100"
				else message_host("command=nack")
				// Electrobox - returns Ohms, Return Amperage, Circuit Capacity, Circuit Interference

			if ("activate")
				if (src.contents.len && !src.active)
					active = 1
					src.timer = -1
					src.electrify_contents()
					message_host("command=ack")
					src.UpdateIcon()
				else
					message_host("command=nack")

			if ("pulse")
				var/duration = text2num_safe(packetData["duration"])
				if (isnum(duration) && !src.active)
					duration = round(clamp(duration, 1, 255))
				else
					src.active = 0
					message_host("command=nack")
					return

				src.active = 1
				src.timer = duration
				src.electrify_contents()
				message_host("command=ack")
				src.UpdateIcon()

			if ("deactivate")
				src.active = 0
				src.timer = -1
				message_host("command=ack")
				src.UpdateIcon()
		return

/obj/machinery/networked/test_apparatus/xraymachine
	name = "X-Ray Scanner"
	desc = "Performs radiography on objects to determine their structure."
	icon_state = "xray0"
	density = 1
	dragload = 1

	setup_base_icon_state = "xray"
	setup_test_id = "X_RAY"
	setup_device_name = "X-Ray Scanner"
	setup_capability_value = "B"

	var/radstrength = 1 // 1 to 10
	var/list/sensed = list("???","???","???","NO","NONE")
	// X-ray - returns Density, Structural Consistency, Structural Integrity

	return_html_interface()
		return "<b>Loaded:</b> [src.contents.len ? "YES" : "NO"]<br><b>Active:</b> [src.active ? "YES" : "NO"]<br><br>Radiation Strength:</b> [src.radstrength * 10]%"

	update_icon()
		if (src.contents.len)
			src.UpdateOverlays(image('icons/obj/networked.dmi', "xray-lid"), "lid")
		else
			src.UpdateOverlays(null, "lid")
		..()

	attackby(var/obj/item/I, mob/user)
		if (src.status & (NOPOWER|BROKEN))
			return
		if (istype(I, /obj/item/grab))
			return
		var/obj/item/magtractor/mag
		if (istype(I, /obj/item/magtractor))
			mag = I
			if (isitem(mag.holding))
				I = mag.holding
			else
				return

		if (!src.contents.len)
			if(I.cant_drop)
				return
			if (mag)
				mag.dropItem(0)
			else
				user.drop_item()
			I.set_loc(src)
			user.visible_message("<b>[user]</b> loads [I] into [src.name]!")
			src.UpdateIcon()
			return
		else
			boutput(user, "There is no room left for that!")
			return

	message_interface(var/list/packetData)
		switch (lowertext(packetData["command"]))
			if ("info")
				message_host("command=info&id=[src.setup_test_id]&capability=[setup_capability_value]&status=[src.active ? "1" : "0"]&valuelist=Radstrength&readinglist=Radiation Strength-%,Object Density-p,Structural Consistency-%,Structural Integrity-%,Radiation Response,Special Traits")

			if ("status")
				message_host("command=status&data=[src.active ? "1" : "0"]")

			if ("poke")
				var/pokeval = text2num_safe(packetData["value"])
				if (lowertext(packetData["field"]) == "radstrength")
					if (pokeval < 1 || pokeval > 10)
						message_host("command=nack")
						return

					src.radstrength = round(pokeval)
					message_host("command=ack")
					return

				message_host("command=nack")
				return

			if ("peek")
				if (lowertext(packetData["field"]) != "radstrength")
					message_host("command=nack")
					return

				message_host("command=peeked&field=radstrength&value=[radstrength]")

			if ("read")
				if(src.sensed[1] == null || src.sensed[2] == null || src.sensed[3] == null || src.sensed[4] == null || src.sensed[5] == null || src.active)
					message_host("command=nack")
				else
					// X-ray - returns Density, Structural Consistency, Structural Integrity, Response
					message_host("command=read&data=[src.radstrength * 10],[src.sensed[1]],[src.sensed[2]],[src.sensed[3]],[src.sensed[4]],[src.sensed[5]]")
					message_host("command=ack")

			if ("sense","deactivate")
				message_host("command=nack")

			if ("activate", "pulse")
				if (src.contents.len && !src.active)
					message_host("command=ack")
					active = 1
					src.UpdateIcon()
					src.visible_message("<b>[src.name]</b> begins to operate.")
					playsound(src.loc, 'sound/machines/genetics.ogg', 50, 1)

					if (src.contents.len)
						var/obj/M = pick(src.contents)
						if (istype(M.artifact,/datum/artifact/))
							var/datum/artifact/A = M.artifact

							// Density
							var/density = A.react_xray[1]

							if (A.artitype.name == "eldritch" && prob(33))
								var/randval = rand(-2,6)
								if (prob(50))
									density *= rand(-2,6)
								else
									density /= (randval == 0 ? 1 : randval)
							if (A.artitype.name == "eldritch" && prob(6))
								density = 666

							src.sensed[1] = density

							// Structural Consistency
							var/consistency = A.react_xray[2]

							if (consistency > 85 && A.artitype.name == "martian")
								consistency = 85

							if (A.artitype.name == "eldritch" && prob(20))
								consistency *= rand(2,6)

							src.sensed[2] = consistency

							// Structural Integrity
							var/integrity = A.react_xray[3]

							for (var/datum/artifact_fault in A.faults)
								integrity -= 7

							if (A.artitype.name == "eldritch" && prob(33))
								if (prob(50)) integrity *= rand(2,4)
								else integrity /= rand(2,4)

							if (integrity > 80 && A.artitype.name == "martian")

								integrity = 80

							if (integrity < 0) src.sensed[3] = "< 1"
							else src.sensed[3] = integrity

							// Radiation Response
							var/responsive = A.react_xray[4]
							if (A.artitype.name == "martian")
								responsive -= 3
							if (A.artitype.name == "eldritch" && prob(33))
								responsive += rand(-2,2)
							if (responsive <= src.radstrength)
								src.sensed[4] = "WEAK RESPONSE"
							else
								src.sensed[4] = "NO RESPONSE"

							var/datum/artifact_trigger/AT = A.get_trigger_by_string("radiate")
							if (AT)
								if (src.sensed[4] == "WEAK RESPONSE")
									src.sensed[4] = "POWERFUL RESPONSE"
								else
									src.sensed[4] = "STRONG RESPONSE"

							// Special Features
							src.sensed[5] = A.react_xray[5]
							if (A.artitype.name == "martian")
								src.sensed[5] += ",ORGANIC"
							if (M.contents.len)
								src.sensed[5] += ",CONTAINS OTHER OBJECT"
							if (A.artitype.name == "eldritch" && prob(6))
								src.sensed[5] = "ERROR"

							M.ArtifactStimulus("radiate", src.radstrength)

						else
							src.sensed[1] = "???"
							src.sensed[2] = "???"
							src.sensed[3] = "???"
							src.sensed[4] = "NO"
							src.sensed[5] = "NONE"

					SPAWN(5 SECONDS)
						src.visible_message("<b>[src.name]</b> finishes working and shuts down.")
						playsound(src, 'sound/machines/chime.ogg', 50, TRUE)
						active = 0
						src.UpdateIcon()
				else
					message_host("command=nack")
		return

/obj/machinery/networked/test_apparatus/heater
	name = "Heater Plate"
	desc = "Exposes artifacts to heat and measures their reaction."
	icon_state = "heater0"
	density = 0
	var/image/heat_overlay = null

	setup_base_icon_state = "heater"
	setup_test_id = "HEATER"
	setup_device_name = "Heater Plate"
	setup_capability_value = "B"

	var/temptarget = 310  // 200 to 400
	var/temperature = 310 // the plate's actual current temperature
	var/stopattarget = 0  // pulse mode - do we automatically stop when we hit the target temp?
	var/list/sensed = list("UNKNOWN","UNKNOWN","UNKNOWN")
	// Heat Plate - returns Artifact Temp, Heat Response, Cold Response
	power_usage = 200

	New()
		..()
		heat_overlay = image('icons/obj/networked.dmi', "")

	return_html_interface()
		return "<b>Active:</b> [src.active ? "YES" : "NO"]<br><br>Target Temperature:</b> [src.temptarget]K<br>Current Temperature:</b> [src.temperature]K"

	update_icon()
		switch(src.temperature)
			if (371 to INFINITY)
				heat_overlay.icon_state = "heat+3"
			if (351 to 370)
				heat_overlay.icon_state = "heat+2"
			if (331 to 350)
				heat_overlay.icon_state = "heat+1"
			if (270 to 289)
				heat_overlay.icon_state = "heat-1"
			if (250 to 269)
				heat_overlay.icon_state = "heat-2"
			if (-INFINITY to 249)
				heat_overlay.icon_state = "heat-3"
			else
				heat_overlay.icon_state = ""
		src.UpdateOverlays(heat_overlay, "heat")
		..()

	attackby(var/obj/item/I, mob/user)
		if (istype(I, /obj/item/grab))
			return

		var/obj/item/magtractor/mag
		if (istype(I, /obj/item/magtractor))
			mag = I
			if (isitem(mag.holding))
				I = mag.holding
			else
				return

		if (locate(/obj/) in src.loc.contents)
			..()
		else
			if(I.cant_drop)
				return
			if (mag)
				mag.dropItem(0)
			else
				user.drop_item()
			I.set_loc(src.loc)
		return

	process()
		if (src.active)
			power_usage = 280
		else
			power_usage = 200
		if (..())
			return

		if (src.active)
			if (src.temperature < src.temptarget)
				src.temperature += min(5, src.temptarget-src.temperature)
			else if (src.temperature > src.temptarget)
				src.temperature -= min(5, src.temperature-src.temptarget)

			if (src.temperature != 310)
				for (var/atom/movable/AM in src.loc.contents)
					AM.temperature_expose(null, src.temperature, CELL_VOLUME)

			if (src.stopattarget && src.temperature == src.temptarget)
				src.active = 0
				src.visible_message("<b>[src.name]</b> reaches its target temperature and shuts down.")
				playsound(src.loc, 'sound/machines/chime.ogg', 50, 1)
		else
			if (src.temperature > 310)
				src.temperature--
			else if (src.temperature < 310)
				src.temperature++

		src.UpdateIcon()

		return

	message_interface(var/list/packetData)
		switch (lowertext(packetData["command"]))
			if ("info")
				message_host("command=info&id=[src.setup_test_id]&capability=[setup_capability_value]&status=[src.active ? "1" : "0"]&valuelist=Temptarget,Temperature&readinglist=Target Temperature-K,Current Temperature-K,Artifact Temperature-K,Temperature Response,Details")

			if ("status")
				message_host("command=status&data=[src.active ? "1" : "0"]")

			if ("poke")
				if (lowertext(packetData["field"]) != "temptarget")
					message_host("command=nack")
					return

				var/pokeval = text2num_safe(packetData["value"])
				if (pokeval < 200 || pokeval > 400)
					message_host("command=nack")
					return
				src.temptarget = pokeval

				message_host("command=ack")
				return

			if ("peek")
				if (lowertext(packetData["field"]) == "temperature")
					message_host("command=peeked&field=temperature&value=[temperature]")
				else if (lowertext(packetData["field"]) == "temptarget")
					message_host("command=peeked&field=temptarget&value=[temptarget]")
				else
					message_host("command=nack")

			if ("read")
				if(src.sensed[1] == null || src.sensed[2] == null || src.sensed[3] == null)
					message_host("command=nack")
				else
					// Heat Plate - returns Artifact Temp, Heat Response, Cold Response
					message_host("command=read&data=[src.temptarget],[src.temperature],[src.sensed[1]],[src.sensed[2]],[src.sensed[3]]")
					message_host("command=ack")

			if ("sense")
				// Heat Plate - returns Artifact Temp, Heat Response, Cold Response

				var/obj/M = null
				for(var/obj/M2 in src.loc.contents)
					if (M2 == src)
						continue
					if (M2.artifact)
						M = M2
						break

				if (!M)
					src.sensed[1] = "ERROR"
					src.sensed[2] = "ERROR"
					src.sensed[3] = "ERROR"

				else

					if (istype(M.artifact,/datum/artifact/))
						var/datum/artifact/A = M.artifact

						// Artifact Temperature
						var/tempdiff = (src.temperature - 310) * A.react_heat[1]
						src.sensed[1] = "[310 + tempdiff]"

						// Response
						var/datum/artifact_trigger/AT_H = A.get_trigger_by_path(/datum/artifact_trigger/heat)
						var/datum/artifact_trigger/AT_C = A.get_trigger_by_path(/datum/artifact_trigger/cold)
						if ((istype(AT_H) && src.temperature > 310) || (istype(AT_C) && src.temperature < 310))
							src.sensed[2] = "YES"
						else
							src.sensed[2] = "NO"

						src.sensed[3] = A.react_heat[2]

					else
						src.sensed[1] = "???"
						src.sensed[2] = "NO"
						src.sensed[3] = "NONE"

				message_host("command=ack")

			if ("activate")
				src.active = 1
				src.stopattarget = 0
				message_host("command=ack")
				src.UpdateIcon()

			if ("pulse")
				var/duration = text2num_safe(packetData["duration"])
				if (isnum(duration) )
					if(duration >= 200 && duration <= 400)
						temptarget = duration
				else
					message_host("command=nack")
					return

				src.stopattarget = 1
				src.active = 1
				message_host("command=ack")
				src.UpdateIcon()

			if ("deactivate")
				src.active = 0
				message_host("command=ack")
				src.UpdateIcon()
		return

/* Finish this later when I can think of how exactly to implement it
/obj/machinery/networked/test_apparatus/laserE
	name = "Laser Emitter"
	desc = "Emits a laser beam for artifact testing purposes."
	icon_state = "laserE0"
	density = 1

	setup_base_icon_state = "laserE"
	setup_test_id = "LASER_E"
	setup_device_name = "Laser Emitter"
	setup_capability_value = "E"

	var/strength = 1 // 1 to 5?
	var/duration = -1 // seconds

	power_usage = 200

	return_html_interface()
		return "<b>Active:</b> [src.active ? "YES" : "NO"]<br><br>Laser Strength:</b> [src.strength]"

	process()
		if (active)
			power_usage = 200 + src.strength * 500
		else
			power_usage = 200
		if (..())
			return

		if (src.active)
			use_power(src.strength * 500)
			src.duration--
			if (src.duration == 0)
				src.active = 0
		else
			use_power(20)

		return

	message_interface(var/list/packetData)
		switch (lowertext(packetData["command"]))
			if ("info")
				message_host("command=info&id=[src.setup_test_id]&capability=[setup_capability_value]&status=[src.active ? "1" : "0"]&valuelist=Strength,Duration")

			if ("status")
				message_host("command=status&data=[src.active ? "1" : "0"]")

			if ("poke")
				if (lowertext(packetData["field"]) != "strength")
					message_host("command=nack")
					return

				var/pokeval = text2num_safe(packetData["value"])
				if (pokeval < 1 || pokeval > 5)
					message_host("command=nack")
					return
				src.strength = pokeval

				message_host("command=ack")
				return

			if ("peek")
				if (lowertext(packetData["field"]) != "strength")
					message_host("command=nack")
					return

				if (lowertext(packetData["field"]) == "strength") message_host("command=peeked&value=[src.strength]")

			if ("activate")
				if (!src.active)
					src.active = 1
					src.duration = -1
					message_host("command=ack")
					src.UpdateIcon()
				else message_host("command=nack")

			if ("pulse")
				var/timer = text2num_safe(packetData["duration"])
				if (!src.active)
					if (isnum(duration)) src.duration = timer
					else message_host("command=nack")
				else message_host("command=nack")

				src.active = 1
				message_host("command=ack")
				src.UpdateIcon()

			if ("deactivate")
				src.active = 0
				src.duration = -1
				message_host("command=ack")
				src.UpdateIcon()
		return

/obj/machinery/networked/test_apparatus/laserR
	name = "Laser receiver"
	desc = "Catches a laser beam and analyses how it was changed since emission."
	icon_state = "laserR0"
	density = 1

	setup_base_icon_state = "laserR"
	setup_test_id = "LASER_R"
	setup_device_name = "Laser receiver"
	setup_capability_value = "S"

	var/list/sensed = list(null,null)*/


/obj/machinery/networked/test_apparatus/gas_sensor
	icon_state = "gsensor1"
	name = "Gas Sensor"
	desc = "A device that detects the composition of the air nearby."
	plane = PLANE_FLOOR //They're supposed to be embedded in the floor.
	density = 0
	dragload = 0

	setup_base_icon_state = "gsensor"
	setup_test_id = "GAS_0"
	setup_device_name = "Gas Sensor"
	setup_capability_value = "S"
	active = 1
	power_usage = 20

	var/setup_tag = null
			//Pressure, Temperature, gases, trace gases sum
	var/list/sensed = null

	New()
		..()
		if (src.setup_tag)
			setup_test_id = "GAS_[uppertext( copytext(src.setup_tag,1,9) )]"

	return_html_interface()
		return "<b>Active:</b> [src.active ? "YES" : "NO"]"

	message_interface(var/list/packetData)
		switch (lowertext(packetData["command"]))
			if ("info")
				#define _FIELD_LABELS(_, _, NAME, ...) "[NAME]-%,"+
				message_host("command=info&id=[src.setup_test_id]&capability=[setup_capability_value]&status=[src.active ? "1" : "0"]&valuelist=None&readinglist=Pressure-kPa,Temperature-K,[APPLY_TO_GASES(_FIELD_LABELS) ""]Misc-%")
				// undefined at the end of the file because of https://secure.byond.com/forum/post/2072419

			if ("status")
				message_host("command=status&data=[src.active ? "1" : "0"]")

			if ("poke","peek")
				message_host("command=nack")

			if ("sense")
				var/datum/gas_mixture/air_sample = return_air()
				var/total_moles = max(TOTAL_MOLES(air_sample), 1)
				sensed?.Cut()
				if(isnull(sensed))
					sensed = list()
				if (air_sample)
					sensed.Add(round(MIXTURE_PRESSURE(air_sample), 0.1))
					sensed.Add(round(air_sample.temperature, 0.1))
					#define _SET_SENSED_GAS(GAS, ...) sensed.Add(round(100*air_sample.GAS/total_moles, 0.1));
					APPLY_TO_GASES(_SET_SENSED_GAS)
					#undef _SET_SENSED_GAS

				else
					sensed = list("???")

				message_host("command=ack")

			if ("read")
				if (!sensed)
					message_host("command=nack")
					return
				for (var/i=1,i<=sensed.len,i++)
					if (sensed[i] == null)
						message_host("command=nack")
						return

				message_host("command=read&data=[sensed.Join(",")]")
				message_host("command=ack")
		return



/obj/machinery/networked/test_apparatus/mechanics
	name = "IO Block"
	desc = "An 8 input, 8 output interface for mechanics components."
	icon_state = "generic0"
	density = 1
	dragload = 0
	setup_base_icon_state = "generic"

	setup_test_id = "PIO"
	setup_device_name = "IO Block"
	setup_capability_value = "B"

	var/output_word = 0
	var/input_word = 0
	var/buffered_input_word = 0
	var/pulses = 0 //If nonzero, we will pulse this many times and then deactivate
	var/tmp/datum/mechanicsMessage/lastSignal = null
	power_usage = 200

	New()
		..()

		AddComponent(/datum/component/mechanics_holder)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"input 0", PROC_REF(fire0))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"input 1", PROC_REF(fire1))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"input 2", PROC_REF(fire2))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"input 3", PROC_REF(fire3))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"input 4", PROC_REF(fire4))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"input 5", PROC_REF(fire5))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"input 6", PROC_REF(fire6))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"input 7", PROC_REF(fire7))

	return_html_interface()
		. = {"<b>INPUT STATUS</b>
		<table border='1' style='color:#FFFFFF'>
		<tr>"}

		for (var/bit = 7, bit >= 0, bit--)
			. += "<td id='bit[bit]'> <div align=left style='background-color=[input_word & (1<<bit) ? "#33FF00" : "#F80000"]'>[bit]</div></td>"

		. += "</tr></table>"

	message_interface(var/list/packetData)
		switch (lowertext(packetData["command"]))
			if ("info")
				message_host("command=info&id=[src.setup_test_id]&capability=[setup_capability_value]&status=[src.active ? "1" : "0"]&valuelist=OutputWord&readinglist=Input Line")

			if ("status")
				message_host("command=status&data=[src.active ? "1" : "0"]")

			if ("poke")
				. = lowertext(packetData["field"])
				if (. == "outputword")
					var/pokeval = text2num_safe(packetData["value"])
					if (pokeval < 0 || pokeval > 255)
						message_host("command=nack")
						return

					src.output_word = pokeval

					message_host("command=ack")

				else if (copytext(.,1,7) == "output")
					. = round( text2num_safe(copytext(.,7)) )

					if (!isnum(.) || . < 0 || . > 7)
						message_host("command=nack")
						return

					if (packetData["value"] == "1")
						output_word |= 1<<.

					else if (packetData["value"] == "0")
						output_word &= ~(1<<.)

					else
						message_host("command=nack")
						return

					message_host("command=ack")

				else
					message_host("command=nack")
					return

				return

			if ("peek")
				if (lowertext(packetData["field"]) == "outputword")
					message_host("command=peeked&field=outputword&value=[output_word]")
				message_host("command=nack")

			if ("read")
				message_host("command=read&data=[buffered_input_word ? "TRUE" : "FALSE"]")

				message_host("command=ack")

			if ("sense")
				buffered_input_word = input_word

				message_host("command=ack")

			if ("activate")
				src.pulses = 0
				src.active = 1
				message_host("command=ack")
				src.UpdateIcon()

			if ("pulse")
				var/duration = text2num_safe(packetData["duration"])
				if (isnum(duration))
					src.pulses = clamp(round(duration), 0, 255)
				else
					message_host("command=nack")
					return

				src.active = 1
				message_host("command=ack")
				src.UpdateIcon()

			if ("deactivate")
				src.active = 0
				src.pulses = 0
				message_host("command=ack")
				src.UpdateIcon()
		return

	process()
		if (src.active)
			power_usage = 300
		else
			power_usage = 200
		if (..())
			return

		if (src.active)

			if (lastSignal)
				lastSignal.signal = "[output_word]"
				SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_MSG,lastSignal)
				lastSignal = null

			else
				SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_SIGNAL,"[output_word]")


			if (pulses)
				pulses--
				if (pulses < 1)
					active = 0

		return

	proc
		fire0(var/datum/mechanicsMessage/anInput)

			if (anInput?.isTrue())
				input_word |= 1

			else
				input_word &= ~1

			lastSignal = anInput

		fire1(var/datum/mechanicsMessage/anInput)

			if (anInput?.isTrue())
				input_word |= 2

			else
				input_word &= ~2

			lastSignal = anInput

		fire2(var/datum/mechanicsMessage/anInput)

			if (anInput?.isTrue())
				input_word |= 4

			else
				input_word &= ~4

			lastSignal = anInput

		fire3(var/datum/mechanicsMessage/anInput)

			if (anInput?.isTrue())
				input_word |= 8

			else
				input_word &= ~8

			lastSignal = anInput

		fire4(var/datum/mechanicsMessage/anInput)

			if (anInput?.isTrue())
				input_word |= 16

			else
				input_word &= ~16

			lastSignal = anInput

		fire5(var/datum/mechanicsMessage/anInput)

			if (anInput?.isTrue())
				input_word |= 32

			else
				input_word &= ~32

		fire6(var/datum/mechanicsMessage/anInput)

			if (anInput?.isTrue())
				input_word |= 64

			else
				input_word &= ~64

			lastSignal = anInput

		fire7(var/datum/mechanicsMessage/anInput)

			if (anInput?.isTrue())
				input_word |= 128

			else
				input_word &= ~128

			lastSignal = anInput

#undef _FIELD_LABELS
