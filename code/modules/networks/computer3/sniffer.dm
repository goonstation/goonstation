//A packet sniffer!!

/obj/item/device/net_sniffer
	name = "Packet Sniffer"
	desc = "An electronic device designed to intercept network transmissions."
	icon_state = "sniffer0"
	item_state = "electronic"
	w_class = W_CLASS_BULKY
	rand_pos = 0
	var/mode = 0
	var/obj/machinery/power/data_terminal/link = null
	var/filter_id = null
	var/list/sniffFilters = list()
	var/last_intercept = 0
	var/list/packet_data = list()
	var/max_logs = 8

	New()
		..()
		if (global.current_state < GAME_STATE_PLAYING)
			new /obj/item/paper/packets(src.loc)

	attack_ai(mob/user as mob)
		if(mode)
			src.interacted(user)
		return

	attack_hand(mob/user)
		if(mode)
			src.interacted(user)
			return

		else
			..()

	attackby(var/obj/item/I, var/mob/user)
		if (isscrewingtool(I))
			if (!mode)
				var/turf/T = loc
				if(isturf(T) && !T.intact)
					var/obj/machinery/power/data_terminal/test_link = locate() in T
					if(test_link && !DATA_TERMINAL_IS_VALID_MASTER(test_link, test_link.master))
						src.link = test_link
						src.link.master = src

						anchored = ANCHORED
						mode = 1
						user.visible_message("[user] attaches the [src] to the data terminal.","You attach the [src] to the data terminal.")

						icon_state = "sniffer1"

					else

						boutput(user, SPAN_ALERT("The [src] couldn't be attached here!"))
						return

				else
					boutput(user, "Device must be placed over a free data terminal to attach to it.")
					return
			else
				anchored = UNANCHORED
				mode = 0
				user.visible_message("[user] detaches the [src] from the data terminal.","You detach the [src] from the data terminal.")
				icon_state = "sniffer0"
				src.link?.master = null
				src.link = null
				return
		else
			..()

	attack_self(mob/user as mob)
		return interacted(user)

	proc/interacted(mob/user as mob)

		var/dat = "<html><head><title>Packet Sniffer</title></head><body>"

		dat += "Current sender filter: <a href='byond://?src=\ref[src];filtid=1'>[src.filter_id ? src.filter_id : "NONE"]</a><br>"

		dat += "<hr><b>Packet log:</b><hr>"
		if(packet_data.len)
			for(var/a in packet_data)
				dat += "<tt>[a]</tt><br>"
		else
			dat += "<b>NONE</b>"

		dat += "<hr>"
		user.Browse(dat,"window=packets")
		onclose(user,"packets")
		return

	Topic(href, href_list)
		..()

		if (!issilicon(usr) && !isAIeye(usr))
			if (!(src in usr.contents) && !(src.master in usr.contents) && !(istype(src.loc, /turf) && (BOUNDS_DIST(src, usr) == 0)))
				return
			if (usr.stat || usr.restrained())
				return

			src.add_fingerprint(usr)
		src.add_dialog(usr)

		if(href_list["filtid"])
			var/t = input(usr, "Please enter new filter net id", src.name, src.filter_id) as text
			if (!t)
				src.filter_id = null
				src.updateIntDialog()
				return

			if (!issilicon(usr) && !isAIeye(usr))//Only check range for organics
				if (!in_interact_range(src, usr) || usr.stat || usr.restrained())
					return

			if(length(t) != 8 || !is_hex(t))
				src.filter_id = null
				src.updateIntDialog()
				return

			src.filter_id = t
			src.updateIntDialog()

		return

	proc/updateIntDialog()
		if(mode)
			src.updateUsrDialog()
		else
			src.updateSelfDialog()
		return

	receive_signal(datum/signal/signal)
		if(!mode || !src.link)
			return
		if(!signal || signal.encryption)
			return

		if(signal.transmission_method != TRANSMISSION_WIRE) //No radio for us thanks
			return

		var/target = signal.data["sender"]
		if(src.filter_id && src.filter_id != target)
			return

		var/badcheck = 0
		for(var/check in src.sniffFilters)
			if(!(check in signal.data) || signal.data[check] != src.sniffFilters[check])
				badcheck = 1
				break
		if(badcheck)
			return

		if(!src.last_intercept || src.last_intercept + 40 <= world.time)
			playsound(src.loc, 'sound/machines/twobeep.ogg', 25, 1)
		//src.packet_data = signal.data:Copy()
		var/newdat = "<b>\[[time2text(world.timeofday,"mm:ss")]:[(world.timeofday%10)]\]:</b>"
		for (var/i in signal.data)
			newdat += "[strip_html(i)][isnull(signal.data[i]) ? "; " : "=[strip_html(signal.data[i])]; "]"

		if (signal.data_file)
			. = signal.data_file.asText()
			newdat += "<br>Included file ([strip_html(signal.data_file.name)], [strip_html(signal.data_file.extension)]): [. ? . : "Not printable."]"

		src.packet_data += newdat
		if (length(src.packet_data) > src.max_logs)
			src.packet_data.Cut(1,2)
		src.last_intercept = world.time
		src.updateIntDialog()
		return
