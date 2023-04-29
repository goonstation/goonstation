
//This is a big messy copy & paste job of several things and thus has been banished to its own file.
//Shouldve probably done it like ibm and have based it on a networked thing instead of duplicating it all here.
//im coder

/obj/item/mechanics/networkcomp
	name = "Powernet-networking component"
	desc = ""
	icon = 'icons/obj/networked.dmi'
	icon_state = "generic-p"
	cabinet_banned = 1 // non-functional, abuse potential. B&
	plane = PLANE_DEFAULT
	var/net_id = null
	var/host_id = null //Who are we connected to?(If we have a single host)
	var/old_host_id = null //Were we previously connected to someone?  Do we care?
	var/obj/machinery/power/data_terminal/link = null
	var/device_tag = "PNET_MECHNET"

	var/last_reset = 0 //Last world.time we were manually reset.
	var/net_number = 0 //A cute little bitfield(0-3 exposed) to allow multiple networks on one wirenet.  Differentiate between intended hosts, if they care

	var/self_only = 1

	var/register = 1 // Whether or not to automagically send command=register&data=MECHNET to connecting devices

	cooldown_time = 4 DECI SECONDS

	get_desc()
		. += {"<br><span class='notice'>[self_only ? "Only receiving signals addressed to [net_id]":"Receiving all signals regardless of address_1."]<br>
		[register ? "Registering with mainframes.":"Not registering with mainframes."]<br>
		Current NetID: [net_id]</span>"}

	New()
		. = ..()
		src.net_id = generate_net_id(src)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"send packet", .proc/spacket)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Toggle Self-Only Messages",.proc/toggleSelfOnly)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Toggle Mainframe Registration",.proc/toggleMainframeReg)

	disposing()
		if(src.link)
			src.link.master = null
			src.link = null
		..()

	proc/toggleSelfOnly(obj/item/W as obj, mob/user as mob)
		self_only = !self_only
		boutput(user, "[self_only ? "Now only processing messages adressed at us.":"Now processing all messages received."]")
		tooltip_rebuild = 1

	proc/toggleMainframeReg(obj/item/W as obj, mob/user as mob)
		register = !register
		boutput(user, "[register ? "Now registering with mainframes.":"Now no longer registering with mainframes."]")
		tooltip_rebuild = 1

	secure()
		var/turf/T = get_turf(src)
		var/obj/machinery/power/data_terminal/test_link = locate() in T
		src.icon_state = "generic0"
		if(test_link && !DATA_TERMINAL_IS_VALID_MASTER(test_link, test_link.master))
			src.link = test_link
			src.link.master = src
			src.icon_state = "generic1"

	loosen()
		resetConnection()
		src.icon_state = "generic-p"
		if(src.link)
			src.link.master = null
			src.link = null

	proc/spacket(var/datum/mechanicsMessage/input)
		if(ON_COOLDOWN(src, SEND_COOLDOWN_ID, src.cooldown_time)) return
		post_raw(input.signal, input.data_file?.copy_file())
		return

	proc/post_raw(var/rawstring, var/datum/computer/file/data_file=null)
		if(!src.link)
			return

		var/datum/signal/signal = get_free_signal()
		signal.source = src
		signal.transmission_method = TRANSMISSION_WIRE

		var/list/inputlist = params2complexlist(rawstring)

		for(var/x in inputlist)
			signal.data[x] = inputlist[x]

		if(data_file)
			signal.data_file = data_file

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
		for(var/i in S.data)
			dataStr += "[i][isnull(S.data[i]) ? ";" : "=[S.data[i]];"]"
		SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_SIGNAL, dataStr, S.data_file?.copy_file())
		animate_flash_color_fill(src,"#00AA00",1, 1)
		return

	proc/resetConnection()
		if(!host_id)
			return

		var/rem_host = src.host_id ? src.host_id : src.old_host_id
		src.host_id = null
		src.old_host_id = null
		src.post_status(rem_host, "command","term_disconnect")
		SPAWN(0.5 SECONDS)
			src.post_status(rem_host, "command","term_connect","device",src.device_tag)
		return

	receive_signal(datum/signal/signal)
		if(!src.link)
			return

		if(!signal || !src.net_id || signal.encryption ||(signal.source == src))
			return

		if(signal.transmission_method != TRANSMISSION_WIRE) //No radio for us thanks
			return

		var/target = signal.data["sender"]

		if((signal.data["address_1"] != src.net_id))
			if((signal.data["address_1"] == "ping") &&((signal.data["net"] == null) ||("[signal.data["net"]]" == "[src.net_number]")) && signal.data["sender"])
				SPAWN(0.5 SECONDS)
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
						SPAWN(0.3 SECONDS)
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
						SPAWN(0.2 SECONDS) //Sign up with the driver(if a mainframe contacted us)
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
