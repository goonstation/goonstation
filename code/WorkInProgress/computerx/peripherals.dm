//CONTENTS:
//format_net_id proc (Eventually! Maybe when computer3 is dead?)
//Base peripheral card
//radio card
//powernet communication card
//combo powernet comm/printer terminal card
//printer card
//prize vending card
//ID scanning card
//Sound card
//Floppy drive
//Rom cart reader
//Electrical scanner interface.

/*
//Basically just reframing ref
/proc/format_net_id(var/refstring)
	if(!refstring)
		return
	var/id_attempt = copytext(refstring,4,(length(refstring)))
	id_attempt = add_zero(id_attempt, 8)

	return id_attempt

//A little more involved
/proc/generate_net_id(var/atom/da_atom)
	if(!da_atom) return
	var/tag_holder = da_atom.tag
	da_atom.tag = null //So we generate from internal ref id
	var/new_id = format_net_id("\ref[da_atom]")
	da_atom.tag = tag_holder

	return new_id
*/

//TO-DO: Major rewrite in communication method between peripherals and the host system.

TYPEINFO(/obj/item/peripheralx)
	mats = 8

/obj/item/peripheralx
	name = "Peripheral card"
	desc = "A computer circuit board."
	icon = 'icons/obj/module.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	icon_state = "id_mod"
	item_state = "electronic"
	w_class = W_CLASS_SMALL
	var/obj/machinery/computerx/host
	var/id = null
	var/func_tag = "GENERIC" //What kind of peripheral is this, huh??
	var/setup_has_badge = 0 //IF this is set, present return_badge() in the host's browse window

	New(location)
		..()
		if(istype(location,/obj/machinery/computerx))
			src.installed(location)
		src.id = "\ref[src]"

	disposing()
		host?.peripherals?.Remove(src)
		..()


	proc
		receive_command(obj/source, command, datum/computer/file/pfile)
			if((source != host) || !(src in host) || !command)
				return 1

			return 0

		send_command(command, datum/computer/file/pfile)
			if(!command || !host)
				return

			if(!istype(host) || (host.status & (NOPOWER|BROKEN)))
				return

			src.host.receive_command(src, command, pfile)

			return

		return_status_text()
			return "OK"

		installed(var/obj/machinery/computerx/newhost)
			if(!newhost)
				return 1

			if(newhost != src.host)
				src.host = newhost

			if(!(src in src.host.peripherals))
				src.host.peripherals.Add(src)

			return 0

		uninstalled() //Called when removed from computerxframe/computerx is taken apart
			return 0

		//If setup_has_badge is set, the text returned here will be available in the computerx browse window
		return_badge()
			return

	Topic(href, href_list)
		if(!src.host || !(src in src.host.contents))
			return 1

		if(usr.stat || usr.restrained())
			return 1

		if ((!usr.contents.Find(src.host) && (!in_interact_range(src.host, usr) || !istype(src.host.loc, /turf))) && (!issilicon(usr)))
			return 1

		if(src.host.status & (NOPOWER|BROKEN))
			return 1

		return 0


/obj/item/peripheralx/network
	var/code = null //Signal encryption code
	var/net_id = null //What is our ID on the network?
	var/last_ping = 0

/obj/item/peripheralx/network/radio
	name = "wireless card"
	desc = "A wireless computer card. It has a bit of a limited range."
	icon_state = "power_mod"
	func_tag = "RAD_ADAPTER"
	var/frequency = FREQ_FREE
	var/range = 8 //How far can our signal travel?? HOW FAR
	var/setup_freq_locked = 0 //If set, frequency cannot be adjusted.
	var/setup_netmode_norange = 1 //If set, there is no range limit in network mode.
	var/net_mode = 0 //If 1, act like a powernet card (ignore tranmissions not addressed to us.)
	//var/logstring = null //Log incoming transmissions.  With a string.

	locked //Locked wireless card
		name = "Limited Wireless card"
		desc = "A wireless computer card, capable of transmitting only at a single frequency."
		//range = 0 //Infinite range!! Infinite range!!
		setup_freq_locked = 1

		pda
			frequency = FREQ_PDA //Standard PDA comm frequency.
			net_mode = 1
			func_tag = "NET_ADAPTER"

		status //This one is for status display control.
			frequency = FREQ_STATUS_DISPLAY
			setup_netmode_norange = 0

	New()
		..()
		src.net_id = format_net_id("\ref[src]")
		MAKE_DEFAULT_RADIO_PACKET_COMPONENT("wireless", frequency)
		get_radio_connection_by_id(src, "wireless").update_all_hearing(TRUE) // I guess

	proc/set_frequency(new_frequency)
		frequency = new_frequency
		get_radio_connection_by_id(src, "wireless").update_frequency(new_frequency)

	receive_command(obj/source, command, datum/computer/file/signal/sfile)
		if(..())
			return

		if(!istype(sfile))
			return

		var/broadcast_range = src.range //No range in network mode!!
		if(setup_netmode_norange && src.net_mode)
			broadcast_range = 0

		switch(command)
			if("transmit")
				var/datum/signal/newsignal = get_free_signal()
				newsignal.data = sfile.data:Copy()
				if(sfile.data_file) //Gonna transfer so many files.
					newsignal.data_file = sfile.data_file.copy_file()
				newsignal.encryption = src.code
				if(src.net_mode)
					if(!newsignal.data["address_1"])
						//Net_mode demands an address_1 value!
						qdel(newsignal)
						return

					newsignal.data["sender"] = src.net_id

				SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, newsignal, broadcast_range)

				//src.logstring += "T@[src.frequency]:[src.code];"

			if("mode_net")
				src.net_mode = 1
				func_tag = "NET_ADAPTER" //Pretend to be that fukken wired card.

			if("mode_free")
				src.net_mode = 0
				func_tag = "RAD_ADAPTER"

			if("ping") //Just a shortcut for pinging the system, really.
				if(!src.net_mode)
					return

				if( (last_ping && ((last_ping + 10) >= world.time) ) || !src.net_id)
					return

				last_ping = world.time
				var/datum/signal/newsignal = get_free_signal()
				newsignal.data["address_1"] = "ping"
				newsignal.data["sender"] = src.net_id
				SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, newsignal, broadcast_range)

			else
				if(!src.setup_freq_locked)
					var/new_freq = round(text2num_safe(command))
					if(new_freq && (new_freq >= 1000 && new_freq <= 1500))
						src.set_frequency(new_freq)

		return

	receive_signal(datum/signal/signal)
		if(!src.host || host.status & (NOPOWER|BROKEN))
			return

		if(!signal || (signal.encryption && signal.encryption != code))
			return

		//src.logstring += "R@[src.frequency]:[src.code];"

		//It better be for us.  Or a ping request.
		if(src.net_mode)

			if(signal.data["address_1"] != src.net_id)
				if((signal.data["address_1"] == "ping") && signal.data["sender"])
					var/datum/signal/pingsignal = get_free_signal()
					pingsignal.source = host
					pingsignal.data["device"] = "WNET_ADAPTER"
					pingsignal.data["netid"] = src.net_id
					pingsignal.data["address_1"] = signal.data["sender"]
					pingsignal.data["command"] = "ping_reply"
					pingsignal.data["data"] = host.name
					var/broadcast_range = src.range
					if(src.setup_netmode_norange)
						broadcast_range = 0
					SPAWN(0.5 SECONDS) //Send a reply for those curious jerks
						SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, pingsignal, broadcast_range)

				return //Just toss out the rest of the signal then I guess

		var/datum/computer/file/signal/sfile = new
		sfile.data = signal.data:Copy()
		//if(src.code)
			//newsignal.encryption = src.code
		if(signal.data_file)
			sfile.data_file = signal.data_file.copy_file()

		send_command("receive",sfile)
		return


	return_status_text()
		var/status = "FREQ: [src.frequency]"
		if(src.net_mode)
			//We are in powernet card emulation mode.
			status += " | NETID: [src.net_id ? src.net_id : "NONE"]"
		else //We are in free radio mode.
			status += " | RANGE: [src.range ? "[src.range]" : "FULL"]"
		return status

/obj/item/peripheralx/network/powernet_card
	name = "wired network card"
	desc = "A computer networking card designed to transmit information over power lines."
	icon_state = "power_mod"
	func_tag = "NET_ADAPTER"
	var/obj/machinery/power/data_terminal/link = null //For communicating with the powernet.

	New()
		..()
		SPAWN(1 SECOND)
			if(src.host && !src.link) //Wait for the map to load and hook up if installed() hasn't done it.
				src.check_connection()
			//Let's blindy attempt to generate a unique network ID!
			src.net_id = format_net_id("\ref[src]")



	installed(var/obj/machinery/computerx/newhost)
		if(..())
			return 1

		src.link = null
		src.check_connection()

		return 0

	uninstalled()
		//Clear our status as the link's master, then null out that link.

		if((src.link) && (src.link.master == src))
			src.link.master = null

		src.link = null
		return 0

	receive_command(obj/source, command, datum/computer/file/signal/signal)
		if(..())
			return

		if(!src.check_connection())
			return

		switch(command)
			if("transmit") //Transmit a copy of the command signal
				if(!istype(signal))
					return

				var/datum/signal/newsignal = get_free_signal()
				newsignal.data = signal.data:Copy()

				if(signal.data_file) //Gonna transfer so many files.
					newsignal.data_file = signal.data_file.copy_file()

				newsignal.data["sender"] = src.net_id //Override whatever jerk info they put here.
				newsignal.encryption = src.code
				newsignal.transmission_method = TRANSMISSION_WIRE
				src.link.post_signal(src, newsignal)

			if("ping") //Just a shortcut for pinging the system, really.
				if( (last_ping && ((last_ping + 10) >= world.time) ) || !src.net_id)
					return

				last_ping = world.time
				var/datum/signal/newsignal = get_free_signal()
				newsignal.data["address_1"] = "ping"
				newsignal.data["sender"] = src.net_id
				newsignal.transmission_method = TRANSMISSION_WIRE
				src.link.post_signal(src, newsignal)

		return

	receive_signal(datum/signal/signal)
		if(!src.host || host.status & (NOPOWER|BROKEN))
			return
		if(!signal || !src.net_id || (signal.encryption && signal.encryption != code))
			return

		if(signal.transmission_method != TRANSMISSION_WIRE) //No radio for us thanks
			return

		if(!src.link || !src.check_connection())
			return

		//They don't need to target us specifically to ping us.
		//Otherwise, ff they aren't addressing us, ignore them
		if(signal.data["address_1"] != src.net_id)
			if((signal.data["address_1"] == "ping") && signal.data["sender"])
				var/datum/signal/pingsignal = get_free_signal()
				pingsignal.data["device"] = "PNET_ADAPTER"
				pingsignal.data["netid"] = src.net_id
				pingsignal.data["address_1"] = signal.data["sender"]
				pingsignal.data["command"] = "ping_reply"
				pingsignal.transmission_method = TRANSMISSION_WIRE
				SPAWN(0.5 SECONDS) //Send a reply for those curious jerks
					src.link.post_signal(src, pingsignal)

			return //Just toss out the rest of the signal then I guess

		var/datum/computer/file/signal/newsignal = get_free_signal()
		newsignal.data = signal.data:Copy()

		if(signal.data_file) //Transfer all of the files.  Every file in the world.
			newsignal.data_file = signal.data_file.copy_file()

		send_command("receive",newsignal)
		return


	return_status_text()
		var/status = "LINK: [src.link ? "ACTIVE" : "!NONE!"]"
		status += " | NETID: [src.net_id ? src.net_id : "NONE"]"
		return status

	proc
		check_connection()
			//if there is a link, it has a master, and the master is valid..
			if(src.link && istype(src.link) && (src.link.master) && DATA_TERMINAL_IS_VALID_MASTER(src.link, src.link.master))
				if(src.link.master == src)
					return 1 //If it's already us, the connection is fine!
				else//Otherwise welp no this thing is taken.
					src.link = null
					return 0
			src.link = null
			var/turf/T = get_turf(src)
			var/obj/machinery/power/data_terminal/test_link = locate() in T
			if(test_link && !DATA_TERMINAL_IS_VALID_MASTER(test_link, test_link.master))
				src.link = test_link
				src.link.master = src
				return 1
			else
				return 0

			return 0

/obj/item/peripheralx/network/powernet_card/terminal
	name = "Terminal card"
	desc = "A networking/printing combo card designed to fit into a computer casing."
	icon_state = "card_mod"
	var/printing = 0

	receive_command(obj/source, command, datum/computer/file/pfile)
		if((source != host) || !(src in host))
			return

		if(!command)// || (signal?.encryption && signal.encryption != src.id))
			return

		if(!src.check_connection())
			return

		switch(command)
			if("transmit") //Transmit a copy of the command signal
				var/datum/computer/file/signal/signal = pfile
				if(!istype(signal))
					return

				var/datum/signal/newsignal = get_free_signal()
				newsignal.data = signal.data:Copy()

				if(signal.data_file) //Gonna transfer so many files.
					newsignal.data_file = signal.data_file.copy_file()

				newsignal.data["sender"] = src.net_id //Override whatever jerk info they put here.
				newsignal.encryption = src.code
				newsignal.transmission_method = TRANSMISSION_WIRE
				src.link.post_signal(src, newsignal)

			if("ping") //Just a shortcut for pinging the system, really.
				if( (last_ping && ((last_ping + 10) >= world.time) ) || !src.net_id)
					return

				last_ping = world.time
				var/datum/signal/newsignal = get_free_signal()
				newsignal.data["address_1"] = "ping"
				newsignal.data["sender"] = src.net_id
				newsignal.transmission_method = TRANSMISSION_WIRE
				src.link.post_signal(src, newsignal)

			if("print")
				var/datum/computer/file/text/txtfile = pfile
				if(!istype(txtfile) || src.printing)
					return
				src.printing = 1

				var/print_data = txtfile.data
				var/print_title = txtfile.name
				if(!print_data)
					src.printing = 0
					return
				SPAWN(5 SECONDS)
					var/obj/item/paper/P = new /obj/item/paper( src.host.loc )
					P.info = print_data
					if(print_title)
						P.name = "paper- '[print_title]'"

					src.printing = 0
					return

		return

/obj/item/peripheralx/printer
	name = "Printer module"
	desc = "A small printer designed to fit into a computer casing."
	icon_state = "card_mod"
	func_tag = "LAR_PRINTER"
	var/printing = 0

	receive_command(obj/source,command, datum/computer/file/text/txtfile)
		if(..())
			return

		if((command == "print") && istype(txtfile) && !src.printing)
			src.printing = 1

			var/print_data = txtfile.data
			var/print_title = txtfile.name
			if(!print_data)
				src.printing = 0
				return
			SPAWN(5 SECONDS)
				var/obj/item/paper/P = new /obj/item/paper( src.host.loc )
				P.info = print_data
				if(print_title)
					P.name = "paper- '[print_title]'"

				src.printing = 0
				return

		return

	return_status_text()
		var/status = "PRINTING?: [src.printing ? "YES" : "NO"]"

		return status


/obj/item/peripheralx/prize_vendor
	name = "Prize vending module"
	desc = "An arcade prize dispenser designed to fit inside a computer casing."
	icon_state = "id_mod"
	func_tag = "LAR_VENDOR"
	var/last_vend = 0 //Delay between vends so it can't be spammed (ie a dude is holding it and shaking stuff out)

	return_status_text()
		var/status_text = "RECHARGING"
		if((last_vend + 400) < world.time)
			status_text = "READY"
		return status_text

	receive_command(obj/source,command, datum/computer/file/pfile)
		if(..())
			return

		if((command == "vend") && ((last_vend + 400) < world.time))
			src.vend_prize()
			src.last_vend = world.time

		return

	attack_self(mob/user as mob)
		if( (last_vend + 400) < world.time)
			boutput(user, "You shake something out of [src]!")
			src.vend_prize()
			src.last_vend = world.time
		else
			boutput(user, "<span class='alert'>[src] isn't ready to dispense a prize yet.</span>")

		return

	proc/vend_prize()
		var/obj/item/prize
		var/prizeselect = rand(1,8)
		var/turf/prize_location = null

		if(src.host)
			prize_location = src.host.loc
		else
			prize_location = get_turf(src)

		switch(prizeselect)
			if(1)
				prize = new /obj/item/spacecash( prize_location )
				prize.name = "space ticket"
				prize.desc = "It's almost like actual currency!"
			if(2)
				prize = new /obj/item/device/radio/beacon( prize_location )
				prize.name = "electronic blink toy game"
				prize.anchored = FALSE
				prize.desc = "Blink.  Blink.  Blink."
			if(3)
				prize = new /obj/item/device/light/zippo( prize_location )
				prize.name = "Burno Lighter"
				prize.desc = "Almost like a decent lighter!"
			if(4)
				prize = new /obj/item/toy/sword( prize_location )
			if(5)
				prize = new /obj/item/instrument/harmonica( prize_location )
				prize.name = "reverse harmonica"
				prize.desc = "To the untrained eye it is like any other harmonica, but the professional will notice that it is BACKWARDS."
			if(6)
				prize = new /obj/item/wrench/gold(prize_location)
			if(7)
				prize = new /obj/item/firework( prize_location )
				prize.icon = 'icons/obj/items/device.dmi'
				prize.icon_state = "shield0"
				prize.name = "decloaking device"
				prize.desc = "A device for removing cloaks. Made in Space-Taiwan."
				prize:det_time = 5
			if(8)
				prize = new /obj/item/toy/gooncode(prize_location)
				prize.name = "Gooncode floppy disk"
				prize.desc = "They're really just handing these out now, huh?"


/obj/item/peripheralx/card_scanner
	name = "ID scanner module"
	desc = "A peripheral board for scanning ID cards."
	icon_state = "card_mod"
	setup_has_badge = 1
	func_tag = "ID_SCANNER"
	var/obj/item/card/id/authid = null
	var/can_manage_access = 0 //Can it change a card's accesses?
	var/can_manage_money = 0 //Can it adjust a card's money balance?

	editor
		name = "ID modifier module"
		desc = "A peripheral board for editing ID cards."
		can_manage_access = 1

	register //A card scanner...that manages money??
		name = "ATM card module"
		desc = "A peripheral board for managing an ID card's credit balance."
		func_tag = "ATM_SCANNER"
		can_manage_money = 1

		return_status_text()
			var/status_text = "No card loaded"
			if(src.authid)
				status_text = "Balance: [authid.money]"
			return status_text

	return_status_text()
		var/status_text = "No card loaded"
		if(src.authid)
			status_text = "Card: [authid.registered]"
		return status_text

	return_badge()
		var/dat = "Card: <a href='?src=\ref[src];card=1'>[src.authid ? "Eject" : "-----"]</a>"
		return dat

	proc/eject_card()
		if(src.authid)
			if(src.host)
				src.authid.set_loc(src.host.loc)
			else
				src.authid.set_loc(get_turf(src))

			src.authid = null
		return

	attack_self(mob/user as mob)
		if(authid)
			boutput(user, "The card falls out.")
			src.eject_card()

		return

	receive_command(obj/source,command, datum/computer/file/record/rec)
		if(..())
			return

		switch(command)
			if("eject")
				src.eject_card()

			if("scan_card")
				if(!src.authid)
					return "nocard"

				var/datum/computer/file/record/newrec = new
				newrec.fields["registered"] = src.authid.registered
				newrec.fields["assignment"] = src.authid.assignment
				newrec.fields["access"] = jointext(src.authid.access, ";")
				newrec.fields["balance"] = src.authid.money

				SPAWN(0.4 SECONDS)
					send_command("card_authed", newrec)

				return newrec

			if("checkaccess")
				if(!src.authid)
					return "nocard"
				var/new_access = 0
				if(istype(rec))
					new_access = text2num_safe(rec.fields["access"])

				if(!new_access || (new_access in src.authid.access))
					var/datum/computer/file/record/newrec = new
					newrec.fields["registered"] = src.authid.registered
					newrec.fields["assignment"] = src.authid.assignment
					newrec.fields["balance"] = src.authid.money
					SPAWN(0.4 SECONDS)
						send_command("card_authed", newrec)

					return newrec

			if("charge")
				if(!src.authid || !src.can_manage_money || !istype(rec))
					return "nocard"

				//We need correct PIN numbers you jerks.
				if(text2num_safe(rec.fields["pin"]) != src.authid.pin)
					SPAWN(0.4 SECONDS)
						send_command("card_bad_pin")
					return

				var/charge_amount = text2num_safe(rec.fields["amount"])
				if(!charge_amount || (charge_amount <= 0) || charge_amount > src.authid.money)
					SPAWN(0.4 SECONDS)
						send_command("card_bad_charge")
					return

				src.authid.money = max(src.authid.money - charge_amount, 0)
				//to-do: new balance reply.
				return

			if("grantaccess")
				if(!src.authid || !src.can_manage_access || !istype(rec))
					return "nocard"

				var/new_access = text2num_safe(rec.fields["access"])
				if(!new_access || (new_access <= 0))
					return

				if(!(new_access in src.authid.access))
					src.authid.access += new_access
/*
					//Send a reply to confirm the granting of this access.
					var/datum/signal/newrec = new
					newrec.fields["access"] = new_access
*/
					SPAWN(0.4 SECONDS)
						send_command("card_add")

					return

			if("removeaccess")
				if(!src.authid || !src.can_manage_access || !istype(rec))
					return "nocard"

				var/rem_access = text2num_safe(rec.fields["access"])
				if(!rem_access || (rem_access <= 0))
					return

				if(rem_access in src.authid.access)
					src.authid.access -= rem_access
/*
					//Send a reply to confirm the granting of this access.
					var/datum/signal/newrec = new
					newrec.fields["access"] = rem_access
*/
					SPAWN(0.4 SECONDS)
						send_command("card_remove")

					return


		return

	Topic(href, href_list)
		if(..())
			return

		if(issilicon(usr) && BOUNDS_DIST(src, usr) > 0)
			boutput(usr, "<span class='alert'>You cannot press the ejection button.</span>")
			return

		if(src.host)
			src.add_dialog(usr).host

		if(href_list["card"])
			if(!isnull(src.authid))
				src.eject_card()
			else
				var/obj/item/I = usr.equipped()
				if (istype(I, /obj/item/card/id))
					usr.drop_item()
					I.set_loc(src)
					src.authid = I

		src.host.updateUsrDialog()
		return

/obj/item/peripheralx/sound_card
	name = "Sound synthesizer module"
	desc = "A computer module designed to synthesize voice and sound."
	icon_state = "std_mod"
	func_tag = "LAR_SOUND"

	receive_command(obj/source,command, datum/computer/file/record/rec)
		if(..())
			return

		switch(command)
			if("beep")
				playsound(src.host.loc, 'sound/machines/twobeep.ogg', 50, 1)
				for (var/mob/O in hearers(3, src.host.loc))
					O.show_message(text("[bicon(src.host)] *beep*"))

			if("speak")
				if(!istype(rec))
					return

				var/speak_name = rec.fields["name"]
				var/speak_data = rec.fields["data"]
				if(!speak_data)
					return
				if(!speak_name)
					speak_name = src.host.name

				for(var/mob/O in hearers(src.host, null))
					O.show_message("<span class='game say'><span class='name'>[speak_name]</span> [bicon(src.host)] beeps, \"[speak_data]\"",2)


		return

/obj/item/peripheralx/drive
	name = "Floppy drive module"
	desc = "A peripheral board containing a floppy diskette interface."
	setup_has_badge = 1
	icon_state = "card_mod"
	func_tag = "SHU_FLOPPY"
	var/label = "fd"
	var/obj/item/disk/data/disk = null
	var/setup_disk_type = /obj/item/disk/data/floppy //Inserted disks need to be a child type of this.

	return_badge()
		var/dat = "Disk: <a href='?src=\ref[src];disk=1'>[src.disk ? "Eject" : "-----"]</a>"
		return dat

	return_status_text()
		var/status_text = "No disk loaded"
		if(src.disk)
			status_text = "Disk loaded"
		return status_text

	installed(var/obj/machinery/computerx/newhost)
		if(..())
			return 1

		src.label = initial(src.label)

		var/count = 0
		for(var/obj/item/peripheralx/drive/D in newhost.peripherals)
			if(D == src)
				continue

			if(initial(D.label) == src.label)
				count++

		src.label = "[src.label][count]"

		if(src.disk)
			for(var/datum/computer/file/terminalx_program/P in src.host.processing_programs)
				P.disk_inserted(src.disk)

		return 0

	proc/eject_disk()
		if(src.host && src.host.restarting)
			return
		if(src.disk)
			var/obj/ejected = src.disk
			src.disk = null //We need to clear src.disk before letting the OS know or things get screwy OK
			if(src.host)
				//Let the host programs know the disk is going out.
				for(var/datum/computer/file/terminalx_program/P in src.host.processing_programs)
					P.disk_ejected(ejected)
				ejected.set_loc(src.host.loc)
			else
				ejected.set_loc(get_turf(src))

		return

	Topic(href, href_list)
		if(..())
			return

		if(issilicon(usr) && BOUNDS_DIST(src, usr) > 0)
			boutput(usr, "<span class='alert'>You cannot press the ejection button.</span>")
			return

		if(src.host)
			src.add_dialog(usr).host

		if(href_list["disk"])
			if(!isnull(src.disk))
				src.eject_disk()
			else
				var/obj/item/I = usr.equipped()
				if (istype(I, src.setup_disk_type))
					usr.drop_item()
					I.set_loc(src)
					src.disk = I
					//Let the host programs know the disk is coming in.
					for(var/datum/computer/file/terminalx_program/P in src.host.processing_programs)
						P.disk_inserted(I)

		src.host.updateUsrDialog()
		return

	attack_self(mob/user as mob)
		if(src.disk)
			boutput(user, "The disk pops out.")
			src.eject_disk()

		return

/obj/item/peripheralx/drive/cart_reader
	name = "ROM cart reader module"
	desc = "A peripheral board for reading ROM carts."
	setup_disk_type = /obj/item/disk/data/cartridge
	func_tag = "SHU_ROM"
	label = "sr"

	return_badge()
		var/dat = "Cart: <a href='?src=\ref[src];disk=1'>[src.disk ? "Eject" : "-----"]</a>"
		return dat

	return_status_text()
		var/status_text = "No cart loaded"
		if(src.disk)
			status_text = "Cart loaded"
		return status_text

	attack_self(mob/user as mob)
		if(src.disk)
			boutput(user, "The cart pops out.")
			src.eject_disk()

		return

/obj/item/peripheralx/drive/tape_reader
	name = "Tape drive module"
	desc = "A peripheral board designed for reading magnetic data tape."
	setup_disk_type = /obj/item/disk/data/tape
	func_tag = "SHU_TAPE"
	label = "st"

	return_badge()
		var/dat = "Tape: <a href='?src=\ref[src];disk=1'>[src.disk ? "Eject" : "-----"]</a>"
		return dat

	return_status_text()
		var/status_text = "No tape loaded"
		if(src.disk)
			status_text = "Tape loaded"
		return status_text

	attack_self(mob/user as mob)
		if(src.disk)
			boutput(user, "The reel pops out.")
			src.eject_disk()

		return

/obj/item/peripheralx/electrical
	name = "Electrical scanner interface"
	desc = "A sophisticated peripheral board for interfacing with an electrical scanner."
	icon_state = "elec_mod"
	func_tag = "ELEC_ADAPTER"
	var/obj/item/electronics/scanner/scanner = null

	return_status_text()
		var/status_text = "UNLOADED"
		if(src.scanner)
			status_text = "LOADED"
		return status_text

	return_badge()
		var/dat = "Scan: <a href='?src=\ref[src];scanner=1'>[src.scanner ? "Eject" : "-----"]</a>"
		return dat

	Topic(href, href_list)
		if(..())
			return

		if(issilicon(usr) && BOUNDS_DIST(src, usr) > 0)
			boutput(usr, "<span class='alert'>You cannot press the ejection button.</span>")
			return

		if(src.host)
			src.add_dialog(usr).host

		if(href_list["scanner"])
			if(!isnull(src.scanner))
				src.eject_scanner()
			else
				var/obj/item/I = usr.equipped()
				if (istype(I, /obj/item/electronics/scanner))
					usr.drop_item()
					if(src.host)
						I.set_loc(src.host)
					else
						I.set_loc(src)
					src.scanner = I

		src.host.updateUsrDialog()
		return

	attack_self(mob/user as mob)
		if(src.scanner)
			boutput(user, "The scanner pops out.")
			src.eject_scanner()

		return

	proc/eject_scanner()
		if(src.scanner)
			src.scanner.set_loc(get_turf(src))
			src.scanner = null

		return
/*
/obj/item/peripheralx/cell_monitor
	name = "cell monitor module"
	desc = "A peripheral board for monitoring charges in power applications."
	icon_state = "elec_mod"
	setup_has_badge = 1
	func_tag = "PWR_MONITOR"

	return_status_text()
		var/obj/machinery/computerx/luggable/checkhost = src.host
		var/status_text = "CELL: No cell!"
		if(istype(checkhost) && checkhost.cell)
			var/obj/item/cell/cell = checkhost.cell
			var/charge_percentage = round((cell.charge/cell.maxcharge)*100)
			status_text = "CELL: [charge_percentage]%"

		return status_text

	return_badge()
		var/obj/machinery/computerx/luggable/checkhost = src.host
		if(!istype(checkhost))
			return null

		var/obj/item/cell/cell = checkhost.cell
		var/readout_color = "#000000"
		var/readout = "NONE"
		if(cell)
			var/charge_percentage = round((cell.charge/cell.maxcharge)*100)
			switch(charge_percentage)
				if(0 to 10)
					readout_color = "#F80000"
				if(11 to 25)
					readout_color = "#FFCC00"
				if(26 to 50)
					readout_color = "#CCFF00"
				if(51 to 75)
					readout_color = "#33CC00"
				if(76 to 100)
					readout_color = "#33FF00"

			readout = charge_percentage

		var/dat = {"Cell: <font color=[readout_color]>[readout]%</font>"}
		return dat
*/

/obj/item/peripheralx/videocard
	name = "fancy video card"
	desc = "A G0KU FACTORY-OC eXeter 4950XL. You have no clue what any of that means."
	icon_state = "gpu_mod"
	func_tag = "VGA_ADAPTER"

	throwforce = 10

	installed(var/obj/machinery/computerx/newhost)
		if(..())
			return 1

		SPAWN(rand(50,100))
			if(host)
				for(var/mob/M in viewers(host, null))
					if(M.client)
						M.show_message(text("<span class='alert'>You hear a loud whirring noise coming from the [src.host.name].</span>"), 2)
				// add a sound effect maybe
				sleep(rand(50,100))
				if(host)
					if(prob(50))
						for(var/mob/M in viewers(host, null))
							if(M.client)
								M.show_message(text("<span class='alert'><B>The [src.host.name] explodes!</B></span>"), 1)
						var/turf/T = get_turf(src.host.loc)
						if(T)
							T.hotspot_expose(700,125)
							explosion(src, T, -1, -1, 2, 3)
						qdel(src)
						return
					for(var/mob/M in viewers(host, null))
						if(M.client)
							M.show_message(text("<span class='alert'><B>The [src.host.name] catches on fire!</B></span>"), 1)
						fireflash(src.host.loc, 0)
						playsound(src.host.loc, 'sound/items/Welder2.ogg', 50, 1)
						src.host.set_broken()
						qdel(src)
						return
		return 0
