//This is a big messy copy & paste job of several things and thus has been banished to its own file.
//Shouldve probably done it like ibm and have based it on a networked thing instead of duplicating it all here.
//im coder

/obj/item/mechanics/networkcomp
	name = "Powernet-networking component"
	desc = ""
	icon = 'icons/obj/networked.dmi'
	icon_state = "generic-p"

	var/net_id = null
	var/host_id = null //Who are we connected to? (If we have a single host)
	var/old_host_id = null //Were we previously connected to someone?  Do we care?
	var/obj/machinery/power/data_terminal/link = null
	var/device_tag = "PNET_MECHNET"

	var/last_reset = 0 //Last world.time we were manually reset.
	var/net_number = 0 //A cute little bitfield (0-3 exposed) to allow multiple networks on one wirenet.  Differentiate between intended hosts, if they care

	var/self_only = 1

	var/register = 1 // Whether or not to automagically send command=register&data=MECHNET to connecting devices

	var/ready = 1

	New()
		. = ..()
		src.net_id = generate_net_id(src)
		verbs -= /obj/item/mechanics/verb/setvalue
		mechanics.addInput("send packet", "spacket")

	verb/togglenwcomps()
		set src in view(1)
		set name = "\[Toggle Self-only messages\]"
		set desc = "Sets whether the component only listens to messages adressed to it."

		if (!isliving(usr))
			return
		if (usr.stat)
			return
		if (!mechanics.allowChange(usr))
			boutput(usr, "<span style=\"color:red\">[MECHFAILSTRING]</span>")
			return

		self_only = !self_only
		boutput(usr, "[self_only ? "Now only processing messages adressed at us.":"Now processing all messages recieved."]")
		return
		
	verb/toggleregister() //shameless copy from above verb
		set src in view(1)
		set name = "\[Toggle Mainframe registration\]"
		set desc = "Toggles whether or not the component registers with the Mainframe when connected to by it."

		if (!isliving(usr))
			return
		if (usr.stat)
			return
		if (!mechanics.allowChange(usr))
			boutput(usr, "<span style=\"color:red\">[MECHFAILSTRING]</span>")
			return

		register = !register
		boutput(usr, "[register ? "Now registering with mainframes.":"Now no longer registering with mainframes."]")
		return
		
	proc/spacket(var/datum/mechanicsMessage/input)
		if(!ready) return
		ready = 0
		SPAWN_DBG(2 SECONDS) ready = 1
		post_raw(input.signal)
		return

	proc/post_raw(var/rawstring)
		if(!src.link)
			return

		var/datum/signal/signal = get_free_signal()
		signal.source = src
		signal.transmission_method = TRANSMISSION_WIRE

		var/list/inputlist = params2complexlist(rawstring)

		for(var/x in inputlist)
			signal.data[x] = inputlist[x]

		src.link.post_signal(src, signal)

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

		//command=term_message&data=command=trigger&data=yoursignal&adress_1=targetId&sender=senderId

	proc/sendRaw(var/datum/signal/S)
		var/dataStr = ""//list2params(S.data)  Using list2params() will result in weird glitches if the data already contains a set of params, like in terminal comms
		for (var/i in S.data)
			dataStr += "[i][isnull(S.data[i]) ? ";" : "=[S.data[i]];"]"
		var/datum/mechanicsMessage/msg = mechanics.newSignal(dataStr)
		mechanics.fireOutgoing(msg)
		animate_flash_color_fill(src,"#00AA00",1, 1)
		return

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

	disposing()
		if (src.link)
			src.link.master = null
			src.link = null

		..()

	attackby(obj/item/W as obj, mob/user as mob)
		if(..(W, user))
			if(src.level == 1) //wrenched down
				var/turf/T = get_turf(src)
				var/obj/machinery/power/data_terminal/test_link = locate() in T
				src.icon_state = "generic0"
				if(test_link && !DATA_TERMINAL_IS_VALID_MASTER(test_link, test_link.master))
					src.link = test_link
					src.link.master = src
					src.icon_state = "generic1"
			else if (src.level == 2) //loose
				resetConnection()
				src.icon_state = "generic-p"
				if(src.link)
					src.link.master = null
					src.link = null
		return

	proc/resetConnection()
		if(!host_id)
			return

		var/rem_host = src.host_id ? src.host_id : src.old_host_id
		src.host_id = null
		src.old_host_id = null
		src.post_status(rem_host, "command","term_disconnect")
		SPAWN_DBG(0.5 SECONDS)
			src.post_status(rem_host, "command","term_connect","device",src.device_tag)
		return

	receive_signal(datum/signal/signal)
		if(!src.link)
			return

		if(!signal || !src.net_id || signal.encryption || (signal.source == src))
			return

		if(signal.transmission_method != TRANSMISSION_WIRE) //No radio for us thanks
			return

		var/target = signal.data["sender"]

		if((signal.data["address_1"] != src.net_id))
			if((signal.data["address_1"] == "ping") && ((signal.data["net"] == null) || ("[signal.data["net"]]" == "[src.net_number]")) && signal.data["sender"])
				SPAWN_DBG(0.5 SECONDS)
					src.post_status(target, "command", "ping_reply", "device", src.device_tag, "netid", src.net_id, "net", "[net_number]")

			if(self_only) return

		sendRaw(signal)

		var/sigcommand = lowertext(signal.data["command"])
		if(sigcommand && signal.data["sender"])
			switch(sigcommand)
				if("term_connect") //Terminal interface stuff.
					if(target == src.host_id)
						//WHAT IS THIS, HOW COULD THIS HAPPEN??
						src.host_id = null
						src.updateUsrDialog()
						SPAWN_DBG(0.3 SECONDS)
							src.post_status(target, "command","term_disconnect")
						return

					if(src.host_id)
						return

					src.host_id = target
					src.old_host_id = target
					if(signal.data["data"] != "noreply")
						src.post_status(target, "command","term_connect","data","noreply","device",src.device_tag)
					src.updateUsrDialog()
					if(src.register)
						SPAWN_DBG(0.2 SECONDS) //Sign up with the driver (if a mainframe contacted us)
							src.post_status(target,"command","term_message","data","command=register&data=MECHNET")
					return

				if("term_ping")
					if(target != src.host_id)
						return
					if(signal.data["data"] == "reply")
						src.post_status(target, "command","term_ping")
					return

				if("term_disconnect")
					if(target == src.host_id)
						src.host_id = null
					return

		return
