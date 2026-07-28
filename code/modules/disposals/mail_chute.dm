//Mailsystem disposal chute

/obj/machinery/disposal/mail
	name = "mail chute"
	icon_state = "mailchute"
	desc = "A pneumatic mail-delivery chute."
	icon_style = "mail"
	light_style = "mailchute"
	repressure_speed = 0.2
	var/mail_tag = null
	//var/destination_tag = null // dropped to parent /obj/machinery/disposal
	var/list/destinations = list()
	var/frequency = FREQ_MAIL_CHUTE
	var/last_inquire = 0 //No signal spamming etc
	var/autoname = FALSE

	var/message = null
	var/mailgroup = null
	var/mailgroup2 = null
	var/net_id = null
	var/pdafrequency = FREQ_PDA

	New()
		..()
		if (src.autoname && !isnull(src.mail_tag))
			src.name = "mail chute ([src.mail_tag])"

		if (!src.net_id)
			src.net_id = generate_net_id(src)
		MAKE_DEFAULT_RADIO_PACKET_COMPONENT(src.net_id, "main", frequency)
		MAKE_SENDER_RADIO_PACKET_COMPONENT(src.net_id, "pda", pdafrequency)
		SPAWN(10 SECONDS)
			src.post_radio_status()

		START_TRACKING

	disposing()
		STOP_TRACKING
		. = ..()

	ui_data(mob/user)
		. = ..()
		. += list(
			"destinations" = src.destinations,
			"destinationTag" = src.destination_tag,
		)

	ui_act(action, params)
		. = ..()
		if (.)
			return .
		switch (action)
			if ("select-destination")
				if (src.destinations)
					var/destination = params["destination"]
					src.destination_tag = destination
					update()
					. = TRUE
			if ("rescanDest")
				if (last_inquire && world.time < (last_inquire + 10))
					return
				destinations = null
				var/datum/signal/signal = get_free_signal()
				signal.source = src
				signal.data["command"] = "mail_inquire"

				SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, signal, null, "main")

	proc/post_radio_status()

		var/datum/signal/signal = get_free_signal()
		signal.source = src
		signal.data["command"] = "mail_reply"
		signal.data["data"] = src.mail_tag

		SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, signal, null, "main")
		return

	receive_signal(datum/signal/signal)
		if (signal.data["command"] == "mail_reply")
			if (!src.destinations)
				src.destinations = new()

			var/destination = signal.data["data"]
			if (!destination)
				return

			if (!(destination in src.destinations))
				src.destinations += destination
				sortList(src.destinations, /proc/cmp_text_asc)

		else if (signal.data["command"] == "mail_inquire")
			src.post_radio_status()

	flush()

		if(!src.destination_tag)
			return

		flushing = TRUE
		if (istype(src, /obj/machinery/disposal/mail)) FLICK("[src.icon_state]-flush", src)
		else FLICK("disposal-flush", src)

		var/obj/disposalholder/H = new /obj/disposalholder	// virtual holder object which actually
																// travels through the pipes.

		H.init(src)	// copy the contents of disposer to holder
		H.mail_tag = src.destination_tag
		H.vent_on_exit = FALSE

		ZERO_GASES(air_contents)

		if (!global.instant_pipe_network)
			sleep(1 SECOND)
			playsound(src, 'sound/machines/disposalflush.ogg', 50, FALSE, 0)
			sleep(0.5 SECONDS) // wait for animation to finish

		H.start(src) // start the holder processing movement
		flushing = FALSE
		// now reset disposal state
		flush = 0
		if(mode == 2)	// if was ready,
			mode = 1	// switch to charging
		update()
		return


	expel()

		if (message)
			var/myarea = get_area(src)
			message = "Mail delivery alert in [myarea]."

			if (message && (mailgroup || mailgroup2))
				var/groups = list()
				if (mailgroup)
					groups += mailgroup
				if (mailgroup2)
					groups += mailgroup2
				groups += MGA_MAIL

				var/datum/signal/newsignal = get_free_signal()
				newsignal.source = src
				newsignal.data["command"] = "text_message"
				newsignal.data["sender_name"] = "CHUTE-MAILBOT"
				newsignal.data["message"] = "[message]"
				newsignal.data["address_1"] = "00000000"
				newsignal.data["group"] = groups
				newsignal.data["sender"] = src.net_id

				SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, newsignal, null, "pda")

		..()
		return

/obj/machinery/disposal/mail/small
	icon = 'icons/obj/disposal_small.dmi'
	handle_normal_state = "mail-handle"
	light_style = "disposal"
	density = 0
	provides_grip = FALSE

	north
		dir = NORTH
		pixel_y = 32
	east
		dir = EAST
	south
		dir = SOUTH
	west
		dir = WEST

/// special mail chutes for the cargo bay
/obj/machinery/disposal/mail/qm
	icon_state = "qm_mailchute"
	repressure_speed = 0.5
	name = "QM"
	mail_tag = "QM"
	mailgroup = MGT_CARGO
	message = TRUE
	icon_style = "qm_mail"
	light_style = "qm_mailchute"

	autoname
		autoname = TRUE
