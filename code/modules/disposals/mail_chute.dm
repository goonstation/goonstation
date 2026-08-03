/obj/machinery/disposal/mail
	name = "mail chute"
	icon_state = "mailchute"
	desc = "A pneumatic mail-delivery chute."
	icon_style = "mail"
	light_style = "mailchute"
	repressure_speed = 0.2

	var/list/destinations = null

	var/net_id = null
	var/pdafrequency = FREQ_PDA
	var/frequency = FREQ_MAIL_CHUTE

	var/mail_tag = null
	var/mailgroup = null
	var/mailgroup2 = null
	var/message = null

/obj/machinery/disposal/mail/New()
	. = ..()

	src.net_id ||= global.generate_net_id(src)
	MAKE_DEFAULT_RADIO_PACKET_COMPONENT(src.net_id, "main", frequency)
	MAKE_SENDER_RADIO_PACKET_COMPONENT(src.net_id, "pda", pdafrequency)

	SPAWN(10 SECONDS)
		src.post_radio_status()

	START_TRACKING

/obj/machinery/disposal/mail/disposing()
	STOP_TRACKING
	. = ..()

/obj/machinery/disposal/mail/ui_data(mob/user)
	. = ..()
	. += list(
		"destinations" = src.destinations,
		"destinationTag" = src.destination_tag,
	)

/obj/machinery/disposal/mail/ui_act(action, params)
	. = ..()
	if (.)
		return .

	switch (action)
		if ("select-destination")
			if (src.destinations)
				src.destination_tag = params["destination"]
				src.update()
				. = TRUE

		if ("rescanDest")
			if (ON_COOLDOWN(src, "mail_inquire", 1 SECOND))
				return

			src.destinations = null
			var/datum/signal/signal = global.get_free_signal()
			signal.source = src
			signal.data["command"] = "mail_inquire"

			SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, signal, null, "main")

/obj/machinery/disposal/mail/proc/post_radio_status()
	var/datum/signal/signal = global.get_free_signal()
	signal.source = src
	signal.data["command"] = "mail_reply"
	signal.data["data"] = src.mail_tag

	SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, signal, null, "main")

/obj/machinery/disposal/mail/receive_signal(datum/signal/signal)
	if (signal.data["command"] == "mail_reply")
		src.destinations ||= list()

		var/destination = signal.data["data"]
		if (!destination || (destination in src.destinations))
			return

		src.destinations += destination
		global.sortList(src.destinations, /proc/cmp_text_asc)

	else if (signal.data["command"] == "mail_inquire")
		src.post_radio_status()

/obj/machinery/disposal/mail/flush()
	if (!src.destination_tag)
		return

	src.flushing = TRUE
	FLICK("[src.icon_state]-flush", src)

	var/obj/disposalholder/H = new /obj/disposalholder()
	H.init(src)
	H.mail_tag = src.destination_tag
	H.vent_on_exit = FALSE

	ZERO_GASES(air_contents)

	if (!global.instant_pipe_network)
		sleep(1 SECOND)
		playsound(src, 'sound/machines/disposalflush.ogg', 50, FALSE, 0)
		sleep(0.5 SECONDS) // wait for animation to finish

	H.start(src)
	src.flushing = FALSE

	// Now reset disposal state.
	src.flush = 0
	if (src.mode == 2)
		src.mode = 1

	src.update()

/obj/machinery/disposal/mail/expel()
	if (src.message && (src.mailgroup || src.mailgroup2))
		var/list/groups = list()
		if (src.mailgroup)
			groups += src.mailgroup
		if (src.mailgroup2)
			groups += src.mailgroup2

		groups += MGA_MAIL

		var/datum/signal/signal = global.get_free_signal()
		signal.source = src
		signal.data["command"] = "text_message"
		signal.data["sender_name"] = "CHUTE-MAILBOT"
		signal.data["message"] = "Mail delivery alert in [get_area(src)]."
		signal.data["address_1"] = "00000000"
		signal.data["group"] = groups
		signal.data["sender"] = src.net_id

		SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, signal, null, "pda")

	. = ..()


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


// Special mail chutes for QM.
/obj/machinery/disposal/mail/qm
	icon_state = "qm_mailchute"
	repressure_speed = 0.5
	name = "QM"
	mail_tag = "QM"
	mailgroup = MGT_CARGO
	message = TRUE
	icon_style = "qm_mail"
	light_style = "qm_mailchute"
