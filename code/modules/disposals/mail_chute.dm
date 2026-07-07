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

/obj/machinery/disposal/mail/autoname
	autoname = TRUE

	// Mailtag types
	// All subtypes should exist across:
	// - /obj/mapping_helper/mailtag
	// - /obj/machinery/disposal/mail/autoname (here)
	// - /obj/machinery/disposal/mail/small/autoname

	janitor
		name = "Janitor"
		mail_tag = "janitor"
		mailgroup = "janitor"
		message = 1
	kitchen
		name = "Kitchen"
		mail_tag = "kitchen"
		mailgroup = MGT_CATERING
		message = 1
	bar
		name = "Bar"
		mail_tag = "bar"
		mailgroup = MGT_CATERING
		message = 1
	hydroponics
		name = "Hydroponics"
		mail_tag = "hydroponics"
		mailgroup = MGT_HYDROPONICS
		message = 1
	security
		name = "Security"
		mail_tag = "security"
		mailgroup = MGD_SECURITY
		message = 1

		brig
			name = "Brig"
			mail_tag = "brig"
		detective
			name = "Detective"
			mail_tag = "detective"
		armory
			name = "Armory"
			mail_tag = "armory"

	bridge
		name = "Bridge"
		mail_tag = "bridge"
		mailgroup = MGD_COMMAND
		message = 1
	chapel
		name = "Chapel"
		mail_tag = "chapel"
		mailgroup = MGT_SPIRITUALAFFAIRS
		message = 1
	engineering
		name = "Engineering"
		mail_tag = "engineering"
		mailgroup = MGD_ENGINEER
		message = 1
	mechanics
		name = "Mechanics"
		mail_tag = "mechanics"
		mailgroup = MGD_ENGINEER
		message = 1
	mining
		name = "Mining"
		mail_tag = "mining"
		mailgroup = MGT_MINING
		message = 1
	qm
		name = "QM"
		mail_tag = "QM"
		mailgroup = MGT_CARGO
		message = 1

		refinery
			name = "Refinery"
			mail_tag = "refinery"

	research
		name = "Research"
		mail_tag = "research"
		mailgroup = MGD_RESEARCH
		message = 1

		telescience
			name = "Telescience"
			mail_tag = "telescience"
		chemistry
			name = "Chemistry"
			mail_tag = "chemistry"
		testchamber
			name = "Test Chamber"
			mail_tag = "testchamber"

	medbay
		name = "Medbay"
		mail_tag = "medbay"
		mailgroup = MGD_MEDICAL
		message = 1

		robotics
			name = "Robotics"
			mail_tag = "robotics"
			mailgroup = MGT_ROBOTICS
		genetics
			name = "Genetics"
			mail_tag = "genetics"
			mailgroup = MGT_GENETICS
		pathology
			name = "Pathology"
			mail_tag = "pathology"
		morgue
			name = "Morgue"
			mail_tag = "morgue"
		booth
			name = "Medical Booth"
			mail_tag = "medical booth"

	checkpoint
		name = "Don't spawn me"
		mailgroup = MGD_SECURITY
		mailgroup2 = MGD_COMMAND
		message = 1

		arrivals
			name = "Arrivals Checkpoint"
			mail_tag = "arrivals checkpoint"
		escape
			name = "Escape Hallway Checkpoint"
			mail_tag = "escape checkpoint"
		customs
			name = "Customs Checkpoint"
			mail_tag = "customs checkpoint"
		sec_foyer
			name = "Security Foyer Checkpoint"
			mail_tag = "sec foyer checkpoint"
		podbay
			name = "Pod Bay Checkpoint"
			mail_tag = "podbay checkpoint"
		chapel
			name = "Chapel Checkpoint"
			mail_tag = "chapel checkpoint"
		cargo
			name = "Cargo Checkpoint"
			mail_tag = "cargo checkpoint"
		west
			name = "West Hallway Checkpoint"
			mail_tag = "west hallway checkpoint"
		east
			name = "East Hallway Checkpoint"
			mail_tag = "east hallway checkpoint"

	public
		name = "Don't spawn me"

		crew
			name = "Crew Quarters"
			mail_tag = "crew"
		crewA
			name = "Crew A"
			mail_tag = "crewA"
		crewB
			name = "Crew B"
			mail_tag = "crewB"
		arcade
			name = "Arcade"
			mail_tag = "arcade"
		market
			name = "Market"
			mail_tag = "market"
		cafeteria
			name = "Cafeteria"
			mail_tag = "cafeteria"
		arrivals
			name = "Arrivals"
			mail_tag = "arrivals hallway"
		escape
			name = "Escape"
			mail_tag = "escape hallway"
		medbay_lobby
			name = "Medbay Lobby"
			mail_tag = "medbay lobby"
		podbay
			name = "Pod Bay"
			mail_tag = "podbay"

/obj/machinery/disposal/mail/small
	icon = 'icons/obj/disposal_small.dmi'
	handle_normal_state = "mail-handle"
	light_style = "disposal"
	density = 0
	provides_grip = FALSE

/obj/machinery/disposal/mail/small/autoname
	autoname = TRUE

	// Mailtag types
	// All subtypes should exist across:
	// - /obj/mapping_helper/mailtag
	// - /obj/machinery/disposal/mail/autoname
	// - /obj/machinery/disposal/mail/small/autoname (here)

	janitor
		name = "Janitor"
		mail_tag = "janitor"
		mailgroup = "janitor"
		message = 1

	kitchen
		name = "Kitchen"
		mail_tag = "kitchen"
		mailgroup = MGT_CATERING
		message = 1

	bar
		name = "Bar"
		mail_tag = "bar"
		mailgroup = MGT_CATERING
		message = 1

	hydroponics
		name = "Hydroponics"
		mail_tag = "hydroponics"
		mailgroup = MGT_HYDROPONICS
		message = 1

	security
		name = "Security"
		mail_tag = "security"
		mailgroup = MGD_SECURITY
		message = 1

		brig
			name = "Brig"
			mail_tag = "brig"

		detective
			name = "Detective"
			mail_tag = "detective"

	bridge
		name = "Bridge"
		mail_tag = "bridge"
		mailgroup = MGD_COMMAND
		message = 1

	chapel
		name = "Chapel"
		mail_tag = "chapel"
		mailgroup = MGT_SPIRITUALAFFAIRS
		message = 1

	engineering
		name = "Engineering"
		mail_tag = "engineering"
		mailgroup = MGD_ENGINEER
		message = 1

	mechanics
		name = "Mechanics"
		mail_tag = "mechanics"
		mailgroup = MGD_ENGINEER
		message = 1

	mining
		name = "Mining"
		mail_tag = "mining"
		mailgroup = MGT_MINING
		message = 1

	qm
		name = "QM"
		mail_tag = "QM"
		mailgroup = MGT_CARGO
		message = 1

		refinery
			name = "Refinery"
			mail_tag = "refinery"

	research
		name = "Research"
		mail_tag = "research"
		mailgroup = MGD_RESEARCH
		message = 1

		telescience
			name = "Telescience"
			mail_tag = "telescience"

		chemistry
			name = "Chemistry"
			mail_tag = "chemistry"

		testchamber
			name = "Test Chamber"
			mail_tag = "testchamber"

	medbay
		name = "Medbay"
		mail_tag = "medbay"
		mailgroup = MGD_MEDICAL
		message = 1

		robotics
			name = "Robotics"
			mail_tag = "robotics"
			mailgroup = MGT_ROBOTICS

		genetics
			name = "Genetics"
			mail_tag = "genetics"
			mailgroup = MGT_GENETICS

		pathology
			name = "Pathology"
			mail_tag = "pathology"

		morgue
			name = "Morgue"
			mail_tag = "morgue"

		booth
			name = "Medical Booth"
			mail_tag = "medical booth"

	checkpoint
		name = "Don't spawn me"
		mailgroup = MGD_SECURITY
		mailgroup2 = MGD_COMMAND
		message = 1

		arrivals
			name = "Arrivals Checkpoint"
			mail_tag = "arrivals checkpoint"

		escape
			name = "Escape Hallway Checkpoint"
			mail_tag = "escape checkpoint"

		customs
			name = "Customs Checkpoint"
			mail_tag = "customs checkpoint"

		sec_foyer
			name = "Security Foyer Checkpoint"
			mail_tag = "sec foyer checkpoint"

		podbay
			name = "Pod Bay Checkpoint"
			mail_tag = "podbay checkpoint"

		chapel
			name = "Chapel Checkpoint"
			mail_tag = "chapel checkpoint"

		cargo
			name = "Cargo Checkpoint"
			mail_tag = "cargo checkpoint"

		west
			name = "West Hallway Checkpoint"
			mail_tag = "west hallway checkpoint"

		east
			name = "East Hallway Checkpoint"
			mail_tag = "east hallway checkpoint"

	public
		name = "Don't spawn me"

		crew
			name = "Crew Quarters"
			mail_tag = "crew"

		crewA
			name = "Crew A"
			mail_tag = "crewA"

		crewB
			name = "Crew B"
			mail_tag = "crewB"

		arcade
			name = "Arcade"
			mail_tag = "arcade"

		market
			name = "Market"
			mail_tag = "market"

		cafeteria
			name = "Cafeteria"
			mail_tag = "cafeteria"

		arrivals
			name = "Arrivals"
			mail_tag = "arrivals hallway"

		escape
			name = "Escape"
			mail_tag = "escape hallway"

		medbay_lobby
			name = "Medbay Lobby"
			mail_tag = "medbay lobby"

		podbay
			name = "Pod Bay"
			mail_tag = "podbay"

/// special mail chutes for the cargo bay
/obj/machinery/disposal/mail/qm
	icon_state = "qm_mailchute"
	repressure_speed = 0.5
	name = "QM"
	mail_tag = "QM"
	mailgroup = MGT_CARGO
	message = 1
	icon_style = "qm_mail"
	light_style = "qm_mailchute"

	autoname
		autoname = TRUE


SET_UP_DIRECTIONALS(/obj/machinery/disposal/mail/small, OFFSETS_DISPOSALCHUTE)
SET_UP_DIRECTIONALS(/obj/machinery/disposal/mail/small/autoname, OFFSETS_DISPOSALCHUTE)
SET_UP_DIRECTIONALS(/obj/machinery/disposal/mail/small/autoname/janitor, OFFSETS_DISPOSALCHUTE)
SET_UP_DIRECTIONALS(/obj/machinery/disposal/mail/small/autoname/kitchen, OFFSETS_DISPOSALCHUTE)
SET_UP_DIRECTIONALS(/obj/machinery/disposal/mail/small/autoname/bar, OFFSETS_DISPOSALCHUTE)
SET_UP_DIRECTIONALS(/obj/machinery/disposal/mail/small/autoname/hydroponics, OFFSETS_DISPOSALCHUTE)
SET_UP_DIRECTIONALS(/obj/machinery/disposal/mail/small/autoname/security, OFFSETS_DISPOSALCHUTE)
SET_UP_DIRECTIONALS(/obj/machinery/disposal/mail/small/autoname/security/brig, OFFSETS_DISPOSALCHUTE)
SET_UP_DIRECTIONALS(/obj/machinery/disposal/mail/small/autoname/security/detective, OFFSETS_DISPOSALCHUTE)
SET_UP_DIRECTIONALS(/obj/machinery/disposal/mail/small/autoname/bridge, OFFSETS_DISPOSALCHUTE)
SET_UP_DIRECTIONALS(/obj/machinery/disposal/mail/small/autoname/chapel, OFFSETS_DISPOSALCHUTE)
SET_UP_DIRECTIONALS(/obj/machinery/disposal/mail/small/autoname/engineering, OFFSETS_DISPOSALCHUTE)
SET_UP_DIRECTIONALS(/obj/machinery/disposal/mail/small/autoname/mechanics, OFFSETS_DISPOSALCHUTE)
SET_UP_DIRECTIONALS(/obj/machinery/disposal/mail/small/autoname/mining, OFFSETS_DISPOSALCHUTE)
SET_UP_DIRECTIONALS(/obj/machinery/disposal/mail/small/autoname/qm, OFFSETS_DISPOSALCHUTE)
SET_UP_DIRECTIONALS(/obj/machinery/disposal/mail/small/autoname/qm/refinery, OFFSETS_DISPOSALCHUTE)
SET_UP_DIRECTIONALS(/obj/machinery/disposal/mail/small/autoname/research, OFFSETS_DISPOSALCHUTE)
SET_UP_DIRECTIONALS(/obj/machinery/disposal/mail/small/autoname/research/telescience, OFFSETS_DISPOSALCHUTE)
SET_UP_DIRECTIONALS(/obj/machinery/disposal/mail/small/autoname/research/chemistry, OFFSETS_DISPOSALCHUTE)
SET_UP_DIRECTIONALS(/obj/machinery/disposal/mail/small/autoname/research/testchamber, OFFSETS_DISPOSALCHUTE)
SET_UP_DIRECTIONALS(/obj/machinery/disposal/mail/small/autoname/medbay, OFFSETS_DISPOSALCHUTE)
SET_UP_DIRECTIONALS(/obj/machinery/disposal/mail/small/autoname/medbay/robotics, OFFSETS_DISPOSALCHUTE)
SET_UP_DIRECTIONALS(/obj/machinery/disposal/mail/small/autoname/medbay/genetics, OFFSETS_DISPOSALCHUTE)
SET_UP_DIRECTIONALS(/obj/machinery/disposal/mail/small/autoname/medbay/pathology, OFFSETS_DISPOSALCHUTE)
SET_UP_DIRECTIONALS(/obj/machinery/disposal/mail/small/autoname/medbay/morgue, OFFSETS_DISPOSALCHUTE)
SET_UP_DIRECTIONALS(/obj/machinery/disposal/mail/small/autoname/medbay/booth, OFFSETS_DISPOSALCHUTE)
SET_UP_DIRECTIONALS(/obj/machinery/disposal/mail/small/autoname/checkpoint/arrivals, OFFSETS_DISPOSALCHUTE)
SET_UP_DIRECTIONALS(/obj/machinery/disposal/mail/small/autoname/checkpoint/escape, OFFSETS_DISPOSALCHUTE)
SET_UP_DIRECTIONALS(/obj/machinery/disposal/mail/small/autoname/checkpoint/customs, OFFSETS_DISPOSALCHUTE)
SET_UP_DIRECTIONALS(/obj/machinery/disposal/mail/small/autoname/checkpoint/sec_foyer, OFFSETS_DISPOSALCHUTE)
SET_UP_DIRECTIONALS(/obj/machinery/disposal/mail/small/autoname/checkpoint/podbay, OFFSETS_DISPOSALCHUTE)
SET_UP_DIRECTIONALS(/obj/machinery/disposal/mail/small/autoname/checkpoint/chapel, OFFSETS_DISPOSALCHUTE)
SET_UP_DIRECTIONALS(/obj/machinery/disposal/mail/small/autoname/checkpoint/cargo, OFFSETS_DISPOSALCHUTE)
SET_UP_DIRECTIONALS(/obj/machinery/disposal/mail/small/autoname/checkpoint/west, OFFSETS_DISPOSALCHUTE)
SET_UP_DIRECTIONALS(/obj/machinery/disposal/mail/small/autoname/checkpoint/east, OFFSETS_DISPOSALCHUTE)
SET_UP_DIRECTIONALS(/obj/machinery/disposal/mail/small/autoname/public/crew, OFFSETS_DISPOSALCHUTE)
SET_UP_DIRECTIONALS(/obj/machinery/disposal/mail/small/autoname/public/crewA, OFFSETS_DISPOSALCHUTE)
SET_UP_DIRECTIONALS(/obj/machinery/disposal/mail/small/autoname/public/crewB, OFFSETS_DISPOSALCHUTE)
SET_UP_DIRECTIONALS(/obj/machinery/disposal/mail/small/autoname/public/arcade, OFFSETS_DISPOSALCHUTE)
SET_UP_DIRECTIONALS(/obj/machinery/disposal/mail/small/autoname/public/market, OFFSETS_DISPOSALCHUTE)
SET_UP_DIRECTIONALS(/obj/machinery/disposal/mail/small/autoname/public/cafeteria, OFFSETS_DISPOSALCHUTE)
SET_UP_DIRECTIONALS(/obj/machinery/disposal/mail/small/autoname/public/arrivals, OFFSETS_DISPOSALCHUTE)
SET_UP_DIRECTIONALS(/obj/machinery/disposal/mail/small/autoname/public/escape, OFFSETS_DISPOSALCHUTE)
SET_UP_DIRECTIONALS(/obj/machinery/disposal/mail/small/autoname/public/medbay_lobby, OFFSETS_DISPOSALCHUTE)
SET_UP_DIRECTIONALS(/obj/machinery/disposal/mail/small/autoname/public/podbay, OFFSETS_DISPOSALCHUTE)
