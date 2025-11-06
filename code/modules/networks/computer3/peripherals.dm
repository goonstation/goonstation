//CONTENTS
//format_net_id proc
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
//Portables battery monitor card.




TYPEINFO(/obj/item/peripheral)
	mats = 8

/obj/item/peripheral
	name = "Peripheral card"
	desc = "A computer circuit board."
	icon = 'icons/obj/module.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	icon_state = "id_mod"
	item_state = "electronic"
	w_class = W_CLASS_SMALL
	var/obj/machinery/computer3/host
	var/id = null
	var/func_tag = "GENERIC" //What kind of peripheral is this, huh??
	var/setup_has_badge = 0 //IF this is set, present return_badge() in the host's browse window

	New(location)
		..()
		if(istype(location,/obj/machinery/computer3))
			host = location
			if (!host.peripherals)
				host.peripherals = list()
			host.peripherals.Add(src)
		src.id = "\ref[src]"

	/* new disposing() pattern should handle this. -singh
	disposing()
		host?.peripherals.Remove(src)
		..()
	*/

	disposing()
		if (host)
			host.peripherals?.Remove(src)
			host = null

		..()


	proc
		receive_command(obj/source, command, datum/signal/signal)
			if((source != host) || !(src in host))
				return 1

			if(!command || (signal?.encryption && signal.encryption != src.id))
				return 1

			return 0

		send_command(command, datum/signal/signal)
			if(!command || !host)
				return

			if(!istype(host) || (host.status & (NOPOWER|BROKEN)))
				return

			src.host.receive_command(src, command, signal)

			return

		return_status_text()
			return "OK"

		installed(var/obj/machinery/computer3/newhost)
			if(!newhost)
				return 1

			if(newhost != src.host)
				src.host = newhost

			if(!(src in src.host.peripherals))
				src.host.peripherals.Add(src)

			return 0

		uninstalled() //Called when removed from computer3frame/computer3 is taken apart
			return 0

		//If setup_has_badge is set, the text returned here will be available in the computer3 browse window
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


/obj/item/peripheral/network
	var/code = null //Signal encryption code
	var/net_id = null //What is our ID on the network?
	var/last_ping = 0

/obj/item/peripheral/network/radio
	name = "wireless card"
	desc = "A wireless computer card. It has a bit of a limited range."
	icon_state = "radio_mod"
	func_tag = "RAD_ADAPTER"
	var/frequency = FREQ_FREE
	var/range = 8 //How far can our signal travel?? HOW FAR
	var/setup_freq_locked = 0 //If set, frequency cannot be adjusted.
	var/setup_netmode_norange = 1 //If set, there is no range limit in network mode.
	var/net_mode = 0 //If 1, act like a powernet card (ignore tranmissions not addressed to us.)
	//var/logstring = null //Log incoming transmissions.  With a string.
	var/send_only = FALSE

	locked //Locked wireless card
		name = "Limited Wireless card"
		desc = "A wireless computer card, capable of transmitting only at a single frequency."
		//range = 0 //Infinite range!! Infinite range!!
		setup_freq_locked = 1

		pda
			frequency = FREQ_PDA //Standard PDA comm frequency.
			range = null
			/*net_mode = 1
			func_tag = "NET_ADAPTER"*/

			transmit_only
				send_only = TRUE

		status //This one is for status display control.
			frequency = FREQ_STATUS_DISPLAY
			setup_netmode_norange = 0

	New()
		..()
		src.net_id = format_net_id("\ref[src]")
		if(send_only)
			MAKE_SENDER_RADIO_PACKET_COMPONENT(src.net_id, "wireless", frequency)
		else
			MAKE_DEFAULT_RADIO_PACKET_COMPONENT(src.net_id, "wireless", frequency)

	receive_command(obj/source, command, datum/signal/signal)
		if(..())
			return 1

		var/broadcast_range = src.range //No range in network mode!!
		if(setup_netmode_norange && src.net_mode)
			broadcast_range = null

		switch(command)
			if("transmit")
				if (!signal)
					return
				var/datum/signal/newsignal = get_free_signal()
				newsignal.data = signal.data:Copy()
				if(signal.data_file) //Gonna transfer so many files.
					newsignal.data_file = signal.data_file.copy_file()
				newsignal.encryption = src.code
				newsignal.source = src
				if(src.net_mode)
					if(!newsignal.data["address_1"])
						//Net_mode demands an address_1 value!
						//qdel(newsignal)
						return 1

					newsignal.data["sender"] = src.net_id

				SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, newsignal, broadcast_range)

				return 0

			if("mode_net")
				src.net_mode = 1
				func_tag = "NET_ADAPTER" //Pretend to be that fukken wired card.
				get_radio_connection_by_id(src, "wireless").update_all_hearing(TRUE)
				return 0

			if("mode_free")
				src.net_mode = 0
				get_radio_connection_by_id(src, "wireless").update_all_hearing(FALSE)
				func_tag = "RAD_ADAPTER"
				return 0

			if ("ping")
				if(!src.net_mode)
					return 1

				if( (last_ping && ((last_ping + 10) >= world.time) ) || !src.net_id)
					return 1

				last_ping = world.time
				var/datum/signal/newsignal = get_free_signal()
				newsignal.data["address_1"] = "ping"
				newsignal.data["sender"] = src.net_id
				newsignal.source = src
				SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, newsignal, broadcast_range)
				return 0

			if ("help")
				return "Valid commands: transmit, mode_net, mode_free, ping, or 1000-1500 to set frequency."

			else
				if(!src.setup_freq_locked)
					var/new_freq = round(text2num_safe(command))
					if(new_freq && (new_freq >= 1000 && new_freq <= 1500))
						get_radio_connection_by_id(src, "wireless").update_frequency(new_freq)
						src.frequency = new_freq
						return 0


		return 1

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
					pingsignal.source = src
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

				return

		var/datum/signal/newsignal = get_free_signal()
		newsignal.data = signal.data:Copy()
		//if(src.code)
			//newsignal.encryption = src.code
		if(signal.data_file)
			newsignal.data_file = signal.data_file.copy_file()

		send_command("receive",newsignal)
		return


	return_status_text()
		. = "FREQ: [src.frequency]"
		if(src.net_mode)
			//We are in powernet card emulation mode.
			. += " | NETID: [src.net_id ? src.net_id : "NONE"]"
		else //We are in free radio mode.
			. += " | RANGE: [src.range ? "[src.range]" : "FULL"]"

/obj/item/peripheral/network/powernet_card
	name = "wired network card"
	desc = "A computer networking card designed to transmit information over power lines."
	icon_state = "power_mod"
	func_tag = "NET_ADAPTER"
	var/net_number = null
	var/obj/machinery/power/data_terminal/link = null //For communicating with the powernet.

	New()
		..()
		SPAWN(1 SECOND)
			if(src.host && !src.link) //Wait for the map to load and hook up if installed() hasn't done it.
				src.check_connection()
			//Let's blindy attempt to generate a unique network ID!
			src.net_id = format_net_id("\ref[src]")



	installed(var/obj/machinery/computer3/newhost)
		if(..())
			return 1

		src.link = null
		src.check_connection()

		return 0

	uninstalled()
		//Clear our status as the link's master, then null out that link.

		//boutput(world, "uninstalling")
		if((src.link) && (src.link.master == src))
			//boutput(world, "clearing link of [src]")
			src.link.master = null

		src.link = null
		return 0

	disposing()
		uninstalled()

		..()

	receive_command(obj/source, command, datum/signal/signal)
		if(..())
			return 1

		if(!src.check_connection())
			return 1

		if (command == "transmit") //Transmit a copy of the command signal
			if(!signal)
				return 1

			var/datum/signal/newsignal = get_free_signal()
			newsignal.data = signal.data:Copy()

			if(signal.data_file) //Gonna transfer so many files.
				newsignal.data_file = signal.data_file.copy_file()

			newsignal.data["sender"] = src.net_id //Override whatever jerk info they put here.
			newsignal.encryption = src.code
			newsignal.transmission_method = TRANSMISSION_WIRE
			newsignal.source = src
			src.link.post_signal(src, newsignal)
			return 0

		else if(dd_hasprefix(command, "ping")) //Just a shortcut for pinging the network.
			if( (last_ping && ((last_ping + 10) >= world.time) ) || !src.net_id)
				return 1

			last_ping = world.time
			var/datum/signal/newsignal = get_free_signal()
			newsignal.data["address_1"] = "ping"
			newsignal.data["sender"] = src.net_id
			if (length(command) > 4)
				var/new_net_number = text2num_safe( copytext(command, 5) )
				if (new_net_number != null && new_net_number >= 0 && new_net_number <= 16)
					newsignal.data["net"] = "[new_net_number]"
				else if (src.net_number)
					newsignal.data["net"] = "[net_number]"
			else if (src.net_number)
				newsignal.data["net"] = "[net_number]"

			newsignal.transmission_method = TRANSMISSION_WIRE
			newsignal.source = src
			src.link.post_signal(src, newsignal)
			return 0

		else if (dd_hasprefix(command, "subnet"))
			if (length(command) > 6)
				var/new_net_number = text2num_safe( copytext(command, 7) )
				if (new_net_number != null && new_net_number >= 0 && new_net_number <= 16)
					src.net_number = new_net_number
			else
				src.net_number = null

			return 0

		else if (command == "help")
			return "Valid commands: transmit, ping, or subnet# to set subnet"

		return 1

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
			if((signal.data["address_1"] == "ping") && ((signal.data["net"] == null) || ("[signal.data["net"]]" == "[src.net_number]")) && signal.data["sender"])
				var/datum/signal/pingsignal = get_free_signal()
				pingsignal.data["device"] = "PNET_ADAPTER"
				pingsignal.data["netid"] = src.net_id
				pingsignal.data["address_1"] = signal.data["sender"]
				pingsignal.data["command"] = "ping_reply"
				pingsignal.transmission_method = TRANSMISSION_WIRE
				pingsignal.source = src
				SPAWN(0.5 SECONDS) //Send a reply for those curious jerks
					src.link.post_signal(src, pingsignal)

			return //Just toss out the rest of the signal then I guess

		var/datum/signal/newsignal = get_free_signal()
		newsignal.data = signal.data:Copy()
		if(signal.data_file) //Gonna transfer so many files.
			newsignal.data_file = signal.data_file.copy_file()

		send_command("receive",newsignal)
		return


	return_status_text()
		. = "LINK: [src.link ? "ACTIVE" : "!NONE!"]"
		. += " | NETID: [src.net_id ? src.net_id : "NONE"]"


// why is the connection checked like this - do we really need to disconnect then reconnect?
/obj/item/peripheral/network/powernet_card/proc/check_connection()
	//if there is a link, it has a master, and the master is valid..
	if(istype(src.link) && DATA_TERMINAL_IS_VALID_MASTER(src.link, src.link.master))
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
		//boutput(world, "couldn't link")
		return 0

/obj/item/peripheral/network/powernet_card/terminal
	name = "Terminal card"
	desc = "A networking/printing combo card designed to fit into a computer casing."
	icon_state = "card_mod"
	var/printing = 0

	receive_command(obj/source, command, datum/signal/signal)
		if((source != host) || !(src in host))
			return 1

		if(!command || (signal?.encryption && signal.encryption != src.id))
			return 1

		if(!src.check_connection())
			return 1

		switch(command)
			if("transmit") //Transmit a copy of the command signal
				if(!signal)
					return 1

				var/datum/signal/newsignal = get_free_signal()
				newsignal.data = signal.data:Copy()

				if(signal.data_file) //Gonna transfer so many files.
					newsignal.data_file = signal.data_file.copy_file()

				newsignal.data["sender"] = src.net_id //Override whatever jerk info they put here.
				newsignal.encryption = src.code
				newsignal.transmission_method = TRANSMISSION_WIRE
				newsignal.source = src
				src.link.post_signal(src, newsignal)



				//src.logstring += "T@[time2text(world.realtime, "hh:mm:ss")]|[src.code]|[strip_html(command)];"
/*
			if("ping")
				if( (last_ping && ((last_ping + 10) >= world.time) ) || !src.net_id)
					return

				last_ping = world.time
				var/datum/signal/newsignal = get_free_signal()
				newsignal.data["address_1"] = "ping"
				newsignal.data["sender"] = src.net_id
				newsignal.transmission_method = TRANSMISSION_WIRE
				src.link.post_signal(src, newsignal)
*/
			if("print")
				if(src.printing)
					return 1
				src.printing = 1

				var/print_data = signal.data["data"]
				var/print_title = signal.data["title"]
				if(!print_data)
					src.printing = 0
					return 1
				SPAWN(5 SECONDS)
					var/obj/item/paper/thermal/P = new /obj/item/paper/thermal
					P.set_loc(src.host.loc)

					playsound(src.host.loc, 'sound/machines/printer_thermal.ogg', 50, 1)
					P.info = "<tt>[print_data]</tt>"
					if(print_title)
						P.name = "paper- '[print_title]'"

					src.printing = 0

			if("help")
				return "Valid commands: transmit, print, or subnet# to set subnet."

			else
				if(dd_hasprefix(command, "ping"))
					if( (last_ping && ((last_ping + 10) >= world.time) ) || !src.net_id)
						return 1

					last_ping = world.time
					var/datum/signal/newsignal = get_free_signal()
					newsignal.data["address_1"] = "ping"
					newsignal.data["sender"] = src.net_id

					if (length(command) > 4)
						var/new_net_number = text2num_safe( copytext(command, 5) )
						if (new_net_number != null && new_net_number >= 0 && new_net_number <= 16)
							newsignal.data["net"] = "[new_net_number]"
						else if (src.net_number)
							newsignal.data["net"] = "[net_number]"
					else if (src.net_number)
						newsignal.data["net"] = "[net_number]"

					newsignal.transmission_method = TRANSMISSION_WIRE
					newsignal.source = src
					src.link.post_signal(src, newsignal)

				else if (dd_hasprefix(command, "subnet"))
					if (length(command) > 6)
						var/new_net_number = text2num_safe( copytext(command, 7) )
						if (new_net_number != null && new_net_number >= 0 && new_net_number <= 16)
							src.net_number = new_net_number
					else
						src.net_number = null

		return 0

/obj/item/peripheral/network/omni
	name = "omni network card"
	desc = "A computer networking card designed to transmit information over either power lines or wirelessly.  It has a mode_wire mode in addition to the typical mode_net and mode_free options."
	icon_state = "radio_mod"
	func_tag = "RAD_ADAPTER"
	var/mode = 2 //0: is free radio, 1 is network radio, 2 is wired network
	var/printing = 0

	var/obj/machinery/power/data_terminal/wired_link = null
	var/subnet = null

	var/frequency = FREQ_FREE
	var/wireless_range = 8

	New()
		..()
		SPAWN(1 SECOND)
			if(src.host && !src.wired_link) //Wait for the map to load and hook up if installed() hasn't done it.
				src.check_wired_connection()
			//Let's blindy attempt to generate a unique network ID!
		src.net_id = format_net_id("\ref[src]")
		MAKE_DEFAULT_RADIO_PACKET_COMPONENT(src.net_id, "wireless", frequency)


	receive_command(obj/source, command, datum/signal/signal)
		if((source != host) || !(src in host))
			return 1

		if(!command || (signal?.encryption && signal.encryption != src.id))
			return 1

		command = lowertext(command)
		switch(command)
			if ("transmit")
				if (src.mode < 2)
					var/datum/signal/newsignal = get_free_signal()
					newsignal.data = signal.data:Copy()

					if(signal.data_file) //Gonna transfer so many files.
						newsignal.data_file = signal.data_file.copy_file()

					if (src.mode == 1)
						newsignal.data["sender"] = src.net_id
					newsignal.source = src

					SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, newsignal, src.mode == 1 ? null : src.wireless_range, "wireless")
					return 0

				else
					if (!wired_link && !check_wired_connection())
						return 1

					var/datum/signal/newsignal = get_free_signal()
					newsignal.data = signal.data:Copy()

					if(signal.data_file) //Gonna transfer so many files.
						newsignal.data_file = signal.data_file.copy_file()

					newsignal.data["sender"] = src.net_id
					newsignal.transmission_method = TRANSMISSION_WIRE
					newsignal.source = src
					src.wired_link.post_signal(src, newsignal)
					return 0

			if ("mode_free")
				src.mode = 0
				get_radio_connection_by_id(src, "wireless").update_all_hearing(TRUE)
				func_tag = "RAD_ADAPTER"
				return 0

			if ("mode_net")
				src.mode = 1
				get_radio_connection_by_id(src, "wireless").update_all_hearing(FALSE)
				func_tag = "NET_ADAPTER"
				return 0

			if ("mode_wire")
				src.mode = 2
				get_radio_connection_by_id(src, "wireless").update_all_hearing(FALSE)
				func_tag = "NET_ADAPTER"
				return 0

			if("print")
				if(src.printing)
					return 1
				src.printing = 1

				var/print_data = signal.data["data"]
				var/print_title = signal.data["title"]
				if(!print_data)
					src.printing = 0
					return 1
				SPAWN(5 SECONDS)
					var/obj/item/paper/thermal/P = new /obj/item/paper/thermal
					P.set_loc(src.host.loc)

					playsound(src.host.loc, 'sound/machines/printer_thermal.ogg', 50, 1)
					P.info = "<tt>[print_data]</tt>"
					if(print_title)
						P.name = "paper- '[print_title]'"

					src.printing = 0

			if("help")
				return "Valid commands: transmit, mode_net, mode_free, mode_wire, print, ping, subnet# to set subnet, or 1000-1500 to set frequency in wireless modes."

			else
				if (copytext(command, 1, 5) == "ping")
					if (src.mode == 1)
						if( (last_ping && ((last_ping + 10) >= world.time) ) || !src.net_id)
							return 1

						last_ping = world.time
						var/datum/signal/newsignal = get_free_signal()
						newsignal.data["address_1"] = "ping"
						newsignal.data["sender"] = src.net_id

						newsignal.source = src
						SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, newsignal, null, "wireless")

						return 0

					else if (src.mode == 2)
						if (!wired_link)
							return 1

						if( (last_ping && ((last_ping + 10) >= world.time) ) || !src.net_id)
							return 1

						last_ping = world.time
						var/datum/signal/newsignal = get_free_signal()
						newsignal.data["address_1"] = "ping"
						newsignal.data["sender"] = src.net_id

						if (src.subnet)
							newsignal.data["net"] = "[subnet]"

						newsignal.transmission_method = TRANSMISSION_WIRE
						newsignal.source = src
						src.wired_link.post_signal(src, newsignal)

						return 0

					return 1

				else if (copytext(command, 1, 7) == "subnet")
					. = text2num_safe( copytext(command, 7) )
					if (. != null && . >= 0 && . <= 16)
						src.subnet = .
					else
						src.subnet = null

					return 0

				else if (mode < 2)
					. = text2num_safe(command)
					if (isnum(.))
						. = round( clamp(., 1000, 1500) )
						get_radio_connection_by_id(src, "wireless").update_frequency(.)
						src.frequency = .
						return 0

		return 1

	receive_signal(datum/signal/signal)
		if(!src.host || host.status & (NOPOWER|BROKEN))
			return

		if(!signal || !src.net_id || signal.encryption)
			return

		if(src.mode == 2 && (!src.wired_link || !src.check_wired_connection()))
			return

		if(signal.data["address_1"] != src.net_id)
			if((signal.data["address_1"] == "ping") && ((signal.data["net"] == null) || ("[signal.data["net"]]" == "[src.subnet]")) && signal.data["sender"])
				var/datum/signal/pingsignal = get_free_signal()
				pingsignal.data["device"] = "[src.mode == 2 ? "P" : null]NET_ADAPTER"
				pingsignal.data["netid"] = src.net_id
				pingsignal.data["address_1"] = signal.data["sender"]
				pingsignal.data["command"] = "ping_reply"
				pingsignal.transmission_method = src.mode == 2 ? TRANSMISSION_WIRE : TRANSMISSION_RADIO
				pingsignal.source = src
				SPAWN(0.5 SECONDS) //Send a reply for those curious jerks
					if (src.mode == 2 && src.wired_link)
						src.wired_link.post_signal(src, pingsignal)
					else
						SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, pingsignal, null, "wireless")

			return //Just toss out the rest of the signal then I guess

		var/datum/signal/newsignal = get_free_signal()
		newsignal.data = signal.data:Copy()
		if(signal.data_file) //Gonna transfer so many files.
			newsignal.data_file = signal.data_file.copy_file()

		send_command("receive", newsignal)
		return

	installed(var/obj/machinery/computer3/newhost)
		if(..())
			return 1

		if(!get_radio_connection_by_id(src, "wireless"))
			MAKE_DEFAULT_RADIO_PACKET_COMPONENT(src.net_id, "wireless", frequency)
			get_radio_connection_by_id(src, "wireless").update_all_hearing(TRUE)

		src.check_wired_connection()

		return 0

	uninstalled()
		//Clear our status as the wired link's master, then null out that link.
		if((src.wired_link) && (src.wired_link.master == src))
			src.wired_link.master = null

		src.wired_link = null
		return 0

	return_status_text()
		if (src.mode < 2)
			. = "FREQ: [src.frequency]"
			if(src.mode == 1)
				//We are in powernet card emulation mode.
				. += " | NETID: [src.net_id ? src.net_id : "NONE"]"
			else //We are in free radio mode.
				. += " | RANGE: [src.wireless_range ? "[src.wireless_range]" : "FULL"]"

		else
			. = "LINK: [src.wired_link ? "ACTIVE" : "!NONE!"]"
			. += " | NETID: [src.net_id ? src.net_id : "NONE"]"

	disposing()
		uninstalled()
		..()

	proc/check_wired_connection()
		//if there is a link, it has a master, and the master is valid..
		if(istype(src.wired_link) && DATA_TERMINAL_IS_VALID_MASTER(src.wired_link, src.wired_link.master))
			if(src.wired_link.master == src)
				return 1 //If it's already us, the connection is fine!
			else//Otherwise welp no this thing is taken.
				src.wired_link = null
				return 0

		src.wired_link = null
		var/turf/T = get_turf(src)
		var/obj/machinery/power/data_terminal/test_link = locate() in T
		if(test_link && !DATA_TERMINAL_IS_VALID_MASTER(test_link, test_link.master))
			src.wired_link = test_link
			src.wired_link.master = src
			return 1
		else
			return 0

/obj/item/peripheral/printer
	name = "Printer module"
	desc = "A small printer designed to fit into a computer casing."
	icon_state = "card_mod"
	func_tag = "LAR_PRINTER"
	var/printing = 0

	receive_command(obj/source,command, datum/signal/signal)
		if(..())
			return 1

		if(!signal)
			return 1

		if((command == "print") && !src.printing)
			src.printing = 1

			var/print_data = signal.data["data"]
			var/print_title = signal.data["title"]
			if(!print_data)
				src.printing = 0
				return
			SPAWN(5 SECONDS)
				var/obj/item/paper/thermal/P = new /obj/item/paper/thermal
				P.set_loc(src.host.loc)

				playsound(src.host.loc, 'sound/machines/printer_thermal.ogg', 50, 1)
				P.info = "<tt>[print_data]</tt>"
				if(print_title)
					P.name = "paper- '[print_title]'"

				src.printing = 0
		else if (command == "help")
			return "Valid command: print, accompanied by a file to print."


		return 1

	return_status_text()
		var/status = "PRINTING?: [src.printing ? "YES" : "NO"]"

		return status


/obj/item/peripheral/prize_vendor
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

	receive_command(obj/source,command, datum/signal/signal)
		if(..())
			return 1

		if((command == "vend") && ((last_vend + 400) < world.time))
			src.vend_prize()
			src.last_vend = world.time
			return 0

		else
			return "Valid command: \"vend\" to vend prize."

	attack_self(mob/user as mob)
		if( (last_vend + 400) < world.time)
			boutput(user, "You shake something out of [src]!")
			src.vend_prize()
			src.last_vend = world.time
		else
			boutput(user, SPAN_ALERT("[src] isn't ready to dispense a prize yet."))

		return

	proc/vend_prize()
		var/obj/item/prize
		var/prizeselect = rand(1,7)
		var/turf/prize_location = null

		if(src.host)
			prize_location = src.host.loc
		else
			prize_location = get_turf(src)

		switch(prizeselect)
			if(1)
				var/obj/item/currency/spacecash/P = new /obj/item/currency/spacecash
				P.setup(prize_location)
				prize = P
				prize.name = "space ticket"
				prize.desc = "It's almost like actual currency!"
			if(2)
				prize = new /obj/item/device/radio/beacon( prize_location )
				prize.name = "electronic blink toy game"
				prize.desc = "Blink.  Blink.  Blink."
				prize.anchored = UNANCHORED
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


/obj/item/peripheral/card_scanner
	name = "ID scanner module"
	desc = "A peripheral board for scanning ID cards."
	icon_state = "card_mod"
	setup_has_badge = 1
	func_tag = "ID_SCANNER"
	var/obj/item/card/id/authid = null
	var/can_manage_access = 0 //Can it change a card's accesses?
	var/can_manage_money = 0 //Can it adjust a card's money balance?
	var/clownifies_card = 0 //Does it set the card's assignment to clown on ejecting?

	editor
		name = "ID modifier module"
		desc = "A peripheral board for editing ID cards."
		can_manage_access = 1

		return_badge()
			// label text, icon, contents
			. = list("label" = "Card","icon" = "edit","contents" = src.authid)

	register //A card scanner...that manages money??
		name = "ATM card module"
		desc = "A peripheral board for managing an ID card's credit balance."
		func_tag = "ATM_SCANNER"
		can_manage_money = 1

		return_badge()
			// label text, icon, contents
			. = list("label" = "Card","icon" = "credit-card","contents" = src.authid)

		return_status_text()
			var/status_text = "No card loaded"
			if(src.authid)
				status_text = "Balance: [authid.money]"
			return status_text

	clownifier //An ID scanner that set's the user's assignment to "Clown" on ejecting. What a fun prank!
		name = "Circus board"
		desc = "A weird-looking peripheral board made out of brightly-colored plastic. It looks like there's a slot to insert an ID card."
		icon_state = "gpu_mod"
		func_tag = "CLOWN_ID_SCANNER"
		clownifies_card = 1

		return_badge()
			// label text, icon, contents
			. = list("label" = "Card","icon" = "id-card","contents" = src.authid,"Clown" = TRUE)

	return_status_text()
		var/status_text = "No card loaded"
		if(src.authid)
			if (src.clownifies_card)
				src.authid.assignment = "Clown"
				src.authid.update_name()
				playsound(src.host.loc, 'sound/musical_instruments/Bikehorn_1.ogg', 50, 1)
			status_text = "Card: [authid.registered]"
		return status_text

	return_badge()
		// label text, icon, contents
		. = list("label" = "Card","icon" = "id-card","contents" = src.authid)

	proc/eject_card()
		if(src.authid)
			src.authid.set_loc(get_turf(src))
			usr.put_in_hand_or_eject(src.authid) // try to eject it into the users hand, if we can
			src.authid = null
		return

	attack_self(mob/user as mob)
		if(authid)
			boutput(user, "The card falls out.")
			src.eject_card()

		return

	receive_command(obj/source,command, datum/signal/signal)
		if(..())
			return 1

		switch(command)
			if("eject")
				src.eject_card()
				return 0

			if("scan_card")
				if(!src.authid)
					return "nocard"

				if (!src.authid.registered)
					return "noreg"
				else if (!src.authid.assignment)
					return "noassign"

				var/datum/signal/newsignal = get_free_signal()
				newsignal.data["registered"] = src.authid.registered
				newsignal.data["assignment"] = src.authid.assignment
				newsignal.data["access"] = jointext(src.authid.access, ";")
				newsignal.data["balance"] = src.authid.money

				SPAWN(0.4 SECONDS)
					send_command("card_authed", newsignal)

				return newsignal

			if("checkaccess")
				if(!src.authid)
					return "nocard"
				var/new_access = 0
				if(signal)
					new_access = text2num_safe(signal.data["access"])

				if(!new_access || (new_access in src.authid.access))
					var/datum/signal/newsignal = get_free_signal()
					newsignal.data["registered"] = src.authid.registered
					newsignal.data["assignment"] = src.authid.assignment
					newsignal.data["balance"] = src.authid.money

					SPAWN(0.4 SECONDS)
						send_command("card_authed", newsignal)

					return newsignal

			if("charge")
				if(!src.authid || !src.can_manage_money || !signal)
					return "nocard"
/*
				//We need correct PIN numbers you jerks.
				if(text2num_safe(signal.data["pin"]) != src.authid.pin)
					SPAWN(0.4 SECONDS)
						send_command("card_bad_pin")
					return
*/
				var/charge_amount = text2num_safe(signal.data["data"])
				if(!charge_amount || (charge_amount <= 0) || charge_amount > src.authid.money)
					SPAWN(0.4 SECONDS)
						send_command("card_bad_charge")
					return 1

				src.authid.money = max(src.authid.money - charge_amount, 0)
				//to-do: new balance reply.
				return "[src.authid.money]"

			if("grantaccess")
				if(!src.authid || !src.can_manage_access || !signal)
					return "nocard"

				var/new_access = text2num_safe(signal.data["access"])
				if(!new_access || (new_access <= 0))
					return

				if(!(new_access in src.authid.access))
					src.authid.access += new_access

					//Send a reply to confirm the granting of this access.
					var/datum/signal/newsignal = get_free_signal()
					newsignal.data["access"] = new_access

					SPAWN(0.4 SECONDS)
						send_command("card_add")

					return 0

			if("removeaccess")
				if(!src.authid || !src.can_manage_access || !signal)
					return "nocard"

				var/rem_access = text2num_safe(signal.data["access"])
				if(!rem_access || (rem_access <= 0))
					return 1

				if(rem_access in src.authid.access)
					src.authid.access -= rem_access

					//Send a reply to confirm the granting of this access.
					var/datum/signal/newsignal = get_free_signal()
					newsignal.data["access"] = rem_access

					SPAWN(0.4 SECONDS)
						send_command("card_remove")

					return 0

			else
				return "Valid commands: eject, scan_card, checkaccess[src.can_manage_access ? ", grantaccess or removeaccess with signal with access=X" : null]"


		return

	Topic(href, href_list)
		if(..())
			return

		if(issilicon(usr) && BOUNDS_DIST(src, usr) > 0)
			boutput(usr, SPAN_ALERT("You cannot press the ejection button."))
			return

		src.host?.add_dialog(usr)

		if(href_list["card"])
			if(!isnull(src.authid))
				src.eject_card()
			else
				var/obj/item/I = usr.equipped()
				if (istype(I, /obj/item/card/id))
					usr.drop_item()
					I.set_loc(src)
					src.authid = I
				else if (istype(I, /obj/item/magtractor))
					var/obj/item/magtractor/mag = I
					if (istype(mag.holding, /obj/item/card/id))
						I = mag.holding
						mag.dropItem(0)
						I.set_loc(src)
						src.authid = I

		src.host.updateUsrDialog()
		return

TYPEINFO(/obj/item/peripheral/sound_card)
	start_speech_modifiers = null
	start_speech_outputs = list(SPEECH_OUTPUT_SPOKEN_SOUND_CARD)

/obj/item/peripheral/sound_card
	name = "Sound synthesizer module"
	desc = "A computer module designed to synthesize voice and sound."
	icon_state = "std_mod"
	func_tag = "LAR_SOUND"
	speech_verb_say = "beeps"
	default_speech_output_channel = SAY_CHANNEL_OUTLOUD

	receive_command(obj/source,command, datum/signal/signal)
		if(..())
			return 1

		switch(command)
			if("beep")
				playsound(src.host.loc, 'sound/machines/twobeep.ogg', 50, 1)
				for (var/mob/O in hearers(3, src.host.loc))
					O.show_message(text("[bicon(src.host)] *beep*"))

			if("speak")
				if(!signal)
					return 1

				var/speak_name = signal.data["name"]
				var/speak_data = signal.data["data"]
				if(!speak_data)
					return 1
				if(!speak_name)
					speak_name = src.host.name

				src.say(speak_data, flags = SAYFLAG_IGNORE_POSITION, message_params = list("speaker_to_display" = speak_name))

			else
				return "Valid commands: beep, speak with signal containing name=X, data=Y"


		return 0

/obj/item/peripheral/drive
	name = "Floppy drive module"
	desc = "A peripheral board containing a floppy diskette interface."
	setup_has_badge = 1
	icon_state = "card_mod"
	func_tag = "SHU_FLOPPY"
	var/obj/item/disk/data/disk = null
	var/setup_disk_type = /obj/item/disk/data/floppy //Inserted disks need to be a child type of this.

	disposing()
		disk = null

		..()

	installed(var/obj/machinery/computer3/newhost)
		if(..())
			return 1

		if(src.disk)
			newhost.contents += src.disk

		return 0

	return_badge()
		// label text, icon, contents
		. = list("label" = "Disk","icon" = "rom","contents" = src.disk)

	uninstalled()
		src.disk?.set_loc(src)

		return 0

	return_status_text()
		var/status_text = "No disk loaded"
		if(src.disk)
			status_text = "Disk loaded"
		return status_text

	proc/eject_disk()
		if(src.disk)
			if(src.host)
				//Let the host programs know the disk is going out.
				for(var/datum/computer/file/terminal_program/P in src.host.processing_programs)
					P.disk_ejected(src.disk)
				src.disk.set_loc(src.host.loc)
			else
				src.disk.set_loc(get_turf(src))

			usr.put_in_hand_or_eject(src.disk) // try to eject it into the users hand, if we can
			src.disk = null
		return

	Topic(href, href_list)
		if(..())
			return

		if(issilicon(usr) && BOUNDS_DIST(src, usr) > 0)
			boutput(usr, SPAN_ALERT("You cannot press the ejection button."))
			return

		src.host?.add_dialog(usr)

		if(href_list["disk"])
			if(!isnull(src.disk))
				src.eject_disk()
			else
				var/obj/item/I = usr.equipped()
				if (istype(I, src.setup_disk_type))
					usr.drop_item()
					if (src.host)
						I.set_loc(src.host)
					else
						I.set_loc(src)
					src.disk = I

				else if (istype(I, /obj/item/magtractor))
					var/obj/item/magtractor/mag = I
					if (istype(mag.holding, src.setup_disk_type))
						I = mag.holding
						mag.dropItem(0)
						if (src.host)
							I.set_loc(src.host)
						else
							I.set_loc(src)
						src.disk = I

		src.host.updateUsrDialog()
		return

	attack_self(mob/user as mob)
		if(src.disk)
			boutput(user, "The disk pops out.")
			src.eject_disk()

		return

/obj/item/peripheral/drive/cart_reader
	name = "ROM cart reader module"
	desc = "A peripheral board for reading ROM carts."
	setup_disk_type = /obj/item/disk/data/cartridge
	func_tag = "SHU_ROM"

	return_badge()
		// label text, icon, contents
		. = list("label" = "Cart","icon" = "microchip","contents" = src.disk)

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

/obj/item/peripheral/drive/tape_reader
	name = "Tape drive module"
	desc = "A peripheral board designed for reading magnetic data tape."
	setup_disk_type = /obj/item/disk/data/tape
	func_tag = "SHU_TAPE"

	return_badge()
		// label text, icon, contents
		. = list("label" = "Tape","icon" = "database","contents" = src.disk)

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

/obj/item/peripheral/cell_monitor
	name = "cell monitor module"
	desc = "A peripheral board for monitoring charges in power applications."
	icon_state = "elec_mod"
	setup_has_badge = 1
	func_tag = "PWR_MONITOR"

	return_status_text()
		var/obj/machinery/computer3/luggable/checkhost = src.host
		var/status_text = "CELL: No cell!"
		if(istype(checkhost) && checkhost.cell)
			var/obj/item/cell/cell = checkhost.cell
			var/charge_percentage = round((cell.charge/cell.maxcharge)*100)
			status_text = "CELL: [charge_percentage]%"

		return status_text

	return_badge()
		// label text, icon, contents
		var/status_text = "Cell: No cell!"
		var/obj/machinery/computer3/luggable/checkhost = src.host

		if(checkhost?.cell)
			var/obj/item/cell/cell = checkhost.cell
			var/charge_percentage = round((cell.charge/cell.maxcharge)*100)
			status_text = "Cell: [charge_percentage]%"

			. = list("label" = status_text,"icon" = "id-card","contents" = cell)



/obj/item/peripheral/videocard
	name = "fancy video card"
	desc = "A G0KU FACTORY-OC eXeter 4950XL. You have no clue what any of that means."
	icon_state = "gpu_mod"
	func_tag = "VGA_ADAPTER"

	throwforce = 10

	installed(var/obj/machinery/computer3/newhost)
		if(..())
			return 1

		SPAWN(rand(50,100))
			if(host)
				for(var/mob/M in hearers(host, null))
					if(M.client)
						M.show_message(SPAN_ALERT("You hear a loud whirring noise coming from the [src.host.name]."), 2)
				// add a sound effect maybe
				sleep(rand(50,100))
				if(host)
					if(prob(50))
						for(var/mob/M in AIviewers(host, null))
							if(M.client)
								M.show_message(SPAN_ALERT("<B>The [src.host.name] explodes!</B>"), 1)
						var/turf/T = get_turf(src.host.loc)
						if(T)
							T.hotspot_expose(700,125)
							explosion(src, T, -1, -1, 2, 3)
						//dispose()
						src.dispose()
						return
					for(var/mob/M in AIviewers(host, null))
						if(M.client)
							M.show_message(SPAN_ALERT("<B>The [src.host.name] catches on fire!</B>"), 1)
						fireflash(src.host.loc, 0, chemfire = CHEM_FIRE_RED)
						playsound(src.host.loc, 'sound/items/Welder2.ogg', 50, 1)
						src.host.set_broken()
						//dispose()
						src.dispose()
						return
		return 0
