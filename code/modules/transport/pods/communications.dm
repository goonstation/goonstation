/obj/item/device/radio/intercom/ship
	name = "Communication Panel"
	anchored = 1.0

/obj/item/device/radio/intercom/ship/send_hear()
	if (src.listening)
		var/list/shiphears = list()
		for(var/mob/M in src.loc)
			shiphears += M
		return shiphears

/obj/item/shipcomponent/communications
	power_used = 10
	active = 0
	name = "Robustco Communication Array"
	desc = "Enables long-distance communications and interfacing with pod bay door controls."
	power_used = 10
	system = "Communications"
	icon_state = "com"
	color = "#16CC77"
	var/list/access_type = null
	var/access_type_secondary = null
	var/obj/item/device/ship_radio_control/rc_ship = null

	mining
		name = "NT Magnet Link Array"
		desc = "Allows a pod to communicate with a Mining Magnet for more convenient mining."
		power_used = 30
		color = "#FABF0F"

		External()
			for(var/obj/machinery/mining_magnet/MM in range(7,src.ship))
				MM.generate_interface(usr)
				return null
			boutput(usr, "<span class='alert'>No magnet found in range of seven meters.</span>")
			return null

	syndicate
		name = "Radioarbeiten Communication Array"
		desc = "A cheaper soviet-made shipboard communicator. Often used by those who oppose NanoTrasen."
		color = "#BA1313"
		access_type = -1

	wizard
		name = "MagicaTech Communication Array"
		desc = "A expensive magical-looking shipboard communicator. Often used by those who shoot fireballs!"
		color = "#E62DE6"
		access_type = -2

	security
		name = "Robustco Security Communication Array"
		desc = "Enables long-distance communications and interfacing with pod bay door controls. Also allows to open security doors."
		color = "#d6194b"
		access_type = 1
		access_type_secondary = 2

	opencomputer(mob/user as mob)
		ship.intercom?.attack_self(user)
		return

	deactivate()
		..()
		if(ship.intercom)
			ship.intercom.broadcasting = 0
			ship.intercom.listening = 0

	New()
		..()
		rc_ship = new /obj/item/device/ship_radio_control( src )
		rc_ship.com = src
		return

	proc/External()
		var/broadcast = copytext(html_encode(input(usr, "Please enter what you want to say over the external speaker.", "[src.name]")), 1, MAX_MESSAGE_LEN)
		if(!broadcast)
			return
		logTheThing("diary", usr, null, "(POD) : [broadcast]", "say")
		if (ishuman(usr))//istype(usr:wear_mask, /obj/item/clothing/mask/gas/voice))
			var/mob/living/carbon/human/H = usr
			if (H.wear_mask && H.wear_mask.vchange && H.wear_id)
				. = H.wear_id:registered
			else
				. = usr.name
		else
			. = usr.real_name

		for(var/mob/M in ship)
			M.show_message("<font color='green'><b>[bicon(ship)]\[[.]\]</b> says, \"[broadcast]\"</font>")
		for(var/mob/O in hearers(ship, null))
			O.show_message("<font color='green'><b>[bicon(ship)]\[[.]\]</b> says, \"[broadcast]\"</font>")

		return null

/obj/item/device/ship_radio_control
	name = "Ship Radio Control"
	var/frequency = 1142
	var/net_id = null
	var/obj/item/shipcomponent/communications/com = null

	New()
		..()
		SPAWN_DBG(0.5 SECONDS)
			radio_controller?.add_object(src, "[frequency]")

			src.net_id = format_net_id("\ref[src]")

	disposing()
		radio_controller.remove_object(src, "[frequency]")
		..()

	receive_signal(datum/signal/signal)
		if(..())
			return
		return

	proc/post_signal(datum/signal/signal,var/newfreq)
		if(!signal)
			return
		var/freq = newfreq
		if(!freq)
			freq = src.frequency

		signal.source = src

		var/datum/radio_frequency/frequency = radio_controller.return_frequency("[freq]")

		signal.transmission_method = TRANSMISSION_RADIO
		if(frequency)
			return frequency.post_signal(src, signal)
		//else
		//	qdel(signal)

	proc/open_hangar(mob/user as mob)
		var/pass = input(usr, "Please enter panel access number.", "Access Number") as text
		pass = copytext(html_encode(pass), 1, 32)
		if(!pass)
			return

		var/datum/signal/newsignal = get_free_signal()
		newsignal.data["command"] = "open door"
		if (com)
			newsignal.data["access_type"] = com.access_type
			newsignal.data["access_type"] = com.access_type_secondary
		else
			newsignal.data["access_type"] = 0
		newsignal.data["doorpass"] = pass
		newsignal.data["sender"] = net_id
		src.post_signal(newsignal)

	proc/return_to_station(mob/user as mob)
		// todo
		return 1
