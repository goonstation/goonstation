//Mailsystem disposal chute

/obj/machinery/disposal/mail
	name = "mail chute"
	icon_state = "mailchute"
	desc = "A pneumatic mail-delivery chute."
	icon_style = "mail"
	var/mail_tag = null
	//var/destination_tag = null // dropped to parent /obj/machinery/disposal
	var/list/destinations = list()
	var/frequency = 1475
	var/datum/radio_frequency/radio_connection
	var/last_inquire = 0 //No signal spamming etc
	var/autoname = 0

	var/message = null
	var/mailgroup = null
	var/mailgroup2 = null
	var/net_id = null
	var/pdafrequency = 1149
	var/datum/radio_frequency/pda_connection

	New()
		..()
		if (src.autoname == 1 && !isnull(src.mail_tag))
			src.name = "mail chute ([src.mail_tag])"

		SPAWN_DBG(10 SECONDS)
			if (src)
				if (radio_controller)
					radio_connection = radio_controller.add_object(src, "[frequency]")
					pda_connection = radio_controller.add_object(src, "[pdafrequency]")
					src.post_radio_status()
				if (!src.net_id)
					src.net_id = generate_net_id(src)

		return

	disposing()
		radio_controller.remove_object(src, "[frequency]")
		radio_controller.remove_object(src, "[pdafrequency]")
		..()

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
				signal.transmission_method = TRANSMISSION_RADIO
				signal.data["command"] = "mail_inquire"

				if (radio_connection)
					radio_connection.post_signal(src, signal)

	proc/post_radio_status()

		var/datum/signal/signal = get_free_signal()
		signal.source = src
		signal.transmission_method = TRANSMISSION_RADIO
		signal.data["command"] = "mail_reply"
		signal.data["data"] = src.mail_tag

		radio_connection.post_signal(src, signal)
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
				src.destinations = sortList(src.destinations)

		else if (signal.data["command"] == "mail_inquire")
			src.post_radio_status()

	flush()

		if(!src.destination_tag)
			return

		flushing = 1
		if (istype(src, /obj/machinery/disposal/mail)) flick("mailchute-flush", src)
		else flick("disposal-flush", src)

		var/obj/disposalholder/H = unpool(/obj/disposalholder)	// virtual holder object which actually
																// travels through the pipes.

		H.init(src)	// copy the contents of disposer to holder
		H.mail_tag = src.destination_tag

		air_contents.zero()		// new empty gas resv.

		sleep(1 SECOND)
		playsound(src, 'sound/machines/disposalflush.ogg', 50, 0, 0)
		sleep(0.5 SECONDS) // wait for animation to finish


		H.start(src) // start the holder processing movement
		flushing = 0
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

			if (message && (mailgroup || mailgroup2) && pda_connection)
				var/groups = list()
				if (mailgroup)
					groups += mailgroup
				if (mailgroup2)
					groups += mailgroup2
				groups += MGA_MAIL

				var/datum/signal/newsignal = get_free_signal()
				newsignal.source = src
				newsignal.transmission_method = TRANSMISSION_RADIO
				newsignal.data["command"] = "text_message"
				newsignal.data["sender_name"] = "CHUTE-MAILBOT"
				newsignal.data["message"] = "[message]"

				newsignal.data["address_1"] = "00000000"
				newsignal.data["group"] = groups
				newsignal.data["sender"] = src.net_id

				pda_connection.post_signal(src, newsignal)

		..()
		return

	colosseum
		flush()
			flushing = 1
			if (istype(src, /obj/machinery/disposal/mail)) flick("mailchute-flush", src)
			else flick("disposal-flush", src)

			var/obj/disposalholder/H = unpool(/obj/disposalholder)	// virtual holder object which actually
																	// travels through the pipes.

			H.init(src)	// copy the contents of disposer to holder

			sleep(1 SECOND)
			playsound(src, 'sound/machines/disposalflush.ogg', 50, 0, 0)
			sleep(0.5 SECONDS) // wait for animation to finish


			H.start(src) // start the holder processing movement
			flushing = 0
			// now reset disposal state
			flush = 0
			if(mode == 2)	// if was ready,
				mode = 1	// switch to charging
			update()
			return

		ex_act(severity)
			return

/obj/machinery/disposal/mail/autoname
	autoname = 1

	// Please keep the destinations identical to /obj/machinery/disposal/mail/small/autoname.
	janitor
		name = "Janitor"
		mail_tag = "janitor"
		mailgroup = "janitor"
		message = 1
	kitchen
		name = "Kitchen"
		mail_tag = "kitchen"
		mailgroup = MGD_KITCHEN
		message = 1
	hydroponics
		name = "Hydroponics"
		mail_tag = "hydroponics"
		mailgroup = MGD_BOTANY
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
		mailgroup = MGD_SPIRITUALAFFAIRS
		message = 1
	engineering
		name = "Engineering"
		mail_tag = "engineering"
		mailgroup = MGO_ENGINEER
		message = 1
	mechanics
		name = "Mechanics"
		mail_tag = "mechanics"
		mailgroup = MGO_MECHANIC
		message = 1
	mining
		name = "Mining"
		mail_tag = "mining"
		mailgroup = MGO_MINING
		message = 1
	qm
		name = "QM"
		mail_tag = "QM"
		mailgroup = MGD_CARGO
		message = 1

		refinery
			name = "Refinery"
			mail_tag = "refinery"

	research
		name = "Research"
		mail_tag = "research"
		mailgroup = MGD_SCIENCE
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
		mailgroup = MGD_MEDBAY
		mailgroup2 = MGD_MEDRESEACH
		message = 1

		robotics
			name = "Robotics"
			mail_tag = "robotics"
			mailgroup = MGD_MEDRESEACH
			mailgroup2 = null
		genetics
			name = "Genetics"
			mail_tag = "genetics"
			mailgroup = MGD_MEDRESEACH
			mailgroup2 = null
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
	handle_normal_state = "disposal-handle"
	density = 0

/obj/machinery/disposal/mail/small/autoname
	autoname = 1
/*
	New() // Would be more elegant, but I want them to be aligned properly in the map editor.
		..()
		if (src.dir == NORTH)
			src.pixel_y = 32
		return
*/
	// Please keep the destinations identical to /obj/machinery/disposal/mail/autoname.
	janitor
		name = "Janitor"
		mail_tag = "janitor"
		mailgroup = "janitor"
		message = 1

		north
			dir = NORTH
			pixel_y = 32
		east
			dir = EAST
		south
			dir = SOUTH
		west
			dir = WEST

	kitchen
		name = "Kitchen"
		mail_tag = "kitchen"
		mailgroup = MGD_KITCHEN
		message = 1

		north
			dir = NORTH
			pixel_y = 32
		east
			dir = EAST
		south
			dir = SOUTH
		west
			dir = WEST

	hydroponics
		name = "Hydroponics"
		mail_tag = "hydroponics"
		mailgroup = MGD_BOTANY
		message = 1

		north
			dir = NORTH
			pixel_y = 32
		east
			dir = EAST
		south
			dir = SOUTH
		west
			dir = WEST

	security
		name = "Security"
		mail_tag = "security"
		mailgroup = MGD_SECURITY
		message = 1

		north
			dir = NORTH
			pixel_y = 32
		east
			dir = EAST
		south
			dir = SOUTH
		west
			dir = WEST

		brig
			name = "Brig"
			mail_tag = "brig"

			north
				dir = NORTH
				pixel_y = 32
			east
				dir = EAST
			south
				dir = SOUTH
			west
				dir = WEST

		detective
			name = "Detective"
			mail_tag = "detective"

			north
				dir = NORTH
				pixel_y = 32
			east
				dir = EAST
			south
				dir = SOUTH
			west
				dir = WEST

	bridge
		name = "Bridge"
		mail_tag = "bridge"
		mailgroup = MGD_COMMAND
		message = 1

		north
			dir = NORTH
			pixel_y = 32
		east
			dir = EAST
		south
			dir = SOUTH
		west
			dir = WEST

	chapel
		name = "Chapel"
		mail_tag = "chapel"
		mailgroup = MGD_SPIRITUALAFFAIRS
		message = 1

		north
			dir = NORTH
			pixel_y = 32
		east
			dir = EAST
		south
			dir = SOUTH
		west
			dir = WEST

	engineering
		name = "Engineering"
		mail_tag = "engineering"
		mailgroup = MGO_ENGINEER
		message = 1

		north
			dir = NORTH
			pixel_y = 32
		east
			dir = EAST
		south
			dir = SOUTH
		west
			dir = WEST

	mechanics
		name = "Mechanics"
		mail_tag = "mechanics"
		mailgroup = MGO_MECHANIC
		message = 1

		north
			dir = NORTH
			pixel_y = 32
		east
			dir = EAST
		south
			dir = SOUTH
		west
			dir = WEST

	mining
		name = "Mining"
		mail_tag = "mining"
		mailgroup = MGO_MINING
		message = 1

		north
			dir = NORTH
			pixel_y = 32
		east
			dir = EAST
		south
			dir = SOUTH
		west
			dir = WEST

	qm
		name = "QM"
		mail_tag = "QM"
		mailgroup = MGD_CARGO
		message = 1

		north
			dir = NORTH
			pixel_y = 32
		east
			dir = EAST
		south
			dir = SOUTH
		west
			dir = WEST

		refinery
			name = "Refinery"
			mail_tag = "refinery"

			north
				dir = NORTH
				pixel_y = 32
			east
				dir = EAST
			south
				dir = SOUTH
			west
				dir = WEST

	research
		name = "Research"
		mail_tag = "research"
		mailgroup = MGD_SCIENCE
		message = 1

		north
			dir = NORTH
			pixel_y = 32
		east
			dir = EAST
		south
			dir = SOUTH
		west
			dir = WEST

		telescience
			name = "Telescience"
			mail_tag = "telescience"

			north
				dir = NORTH
				pixel_y = 32
			east
				dir = EAST
			south
				dir = SOUTH
			west
				dir = WEST

		chemistry
			name = "Chemistry"
			mail_tag = "chemistry"

			north
				dir = NORTH
				pixel_y = 32
			east
				dir = EAST
			south
				dir = SOUTH
			west
				dir = WEST

		testchamber
			name = "Test Chamber"
			mail_tag = "testchamber"

			north
				dir = NORTH
				pixel_y = 32
			east
				dir = EAST
			south
				dir = SOUTH
			west
				dir = WEST

	medbay
		name = "Medbay"
		mail_tag = "medbay"
		mailgroup = MGD_MEDBAY
		mailgroup2 = MGD_MEDRESEACH
		message = 1

		north
			dir = NORTH
			pixel_y = 32
		east
			dir = EAST
		south
			dir = SOUTH
		west
			dir = WEST

		robotics
			name = "Robotics"
			mail_tag = "robotics"
			mailgroup = MGD_MEDRESEACH
			mailgroup2 = null

			north
				dir = NORTH
				pixel_y = 32
			east
				dir = EAST
			south
				dir = SOUTH
			west
				dir = WEST

		genetics
			name = "Genetics"
			mail_tag = "genetics"
			mailgroup = MGD_MEDRESEACH
			mailgroup2 = null

			north
				dir = NORTH
				pixel_y = 32
			east
				dir = EAST
			south
				dir = SOUTH
			west
				dir = WEST

		pathology
			name = "Pathology"
			mail_tag = "pathology"

			north
				dir = NORTH
				pixel_y = 32
			east
				dir = EAST
			south
				dir = SOUTH
			west
				dir = WEST

		morgue
			name = "Morgue"
			mail_tag = "morgue"

			north
				dir = NORTH
				pixel_y = 32
			east
				dir = EAST
			south
				dir = SOUTH
			west
				dir = WEST

		booth
			name = "Medical Booth"
			mail_tag = "medical booth"

			north
				dir = NORTH
				pixel_y = 32
			east
				dir = EAST
			south
				dir = SOUTH
			west
				dir = WEST

	checkpoint
		name = "Don't spawn me"
		mailgroup = MGD_SECURITY
		mailgroup2 = MGD_COMMAND
		message = 1

		arrivals
			name = "Arrivals Checkpoint"
			mail_tag = "arrivals checkpoint"

			north
				dir = NORTH
				pixel_y = 32
			east
				dir = EAST
			south
				dir = SOUTH
			west
				dir = WEST

		escape
			name = "Escape Hallway Checkpoint"
			mail_tag = "escape checkpoint"

			north
				dir = NORTH
				pixel_y = 32
			east
				dir = EAST
			south
				dir = SOUTH
			west
				dir = WEST

		customs
			name = "Customs Checkpoint"
			mail_tag = "customs checkpoint"

			north
				dir = NORTH
				pixel_y = 32
			east
				dir = EAST
			south
				dir = SOUTH
			west
				dir = WEST

		sec_foyer
			name = "Security Foyer Checkpoint"
			mail_tag = "sec foyer checkpoint"

			north
				dir = NORTH
				pixel_y = 32
			east
				dir = EAST
			south
				dir = SOUTH
			west
				dir = WEST

		podbay
			name = "Pod Bay Checkpoint"
			mail_tag = "podbay checkpoint"

			north
				dir = NORTH
				pixel_y = 32
			east
				dir = EAST
			south
				dir = SOUTH
			west
				dir = WEST

		chapel
			name = "Chapel Checkpoint"
			mail_tag = "chapel checkpoint"

			north
				dir = NORTH
				pixel_y = 32
			east
				dir = EAST
			south
				dir = SOUTH
			west
				dir = WEST

		cargo
			name = "Cargo Checkpoint"
			mail_tag = "cargo checkpoint"

			north
				dir = NORTH
				pixel_y = 32
			east
				dir = EAST
			south
				dir = SOUTH
			west
				dir = WEST

		west
			name = "West Hallway Checkpoint"
			mail_tag = "west hallway checkpoint"

			north
				dir = NORTH
				pixel_y = 32
			east
				dir = EAST
			south
				dir = SOUTH
			west
				dir = WEST

		east
			name = "East Hallway Checkpoint"
			mail_tag = "east hallway checkpoint"

			north
				dir = NORTH
				pixel_y = 32
			east
				dir = EAST
			south
				dir = SOUTH
			west
				dir = WEST

	public
		name = "Don't spawn me"

		crew
			name = "Crew Quarters"
			mail_tag = "crew"

			north
				dir = NORTH
				pixel_y = 32
			east
				dir = EAST
			south
				dir = SOUTH
			west
				dir = WEST

		crewA
			name = "Crew A"
			mail_tag = "crewA"

			north
				dir = NORTH
				pixel_y = 32
			east
				dir = EAST
			south
				dir = SOUTH
			west
				dir = WEST

		crewB
			name = "Crew B"
			mail_tag = "crewB"

			north
				dir = NORTH
				pixel_y = 32
			east
				dir = EAST
			south
				dir = SOUTH
			west
				dir = WEST

		arcade
			name = "Arcade"
			mail_tag = "arcade"

			north
				dir = NORTH
				pixel_y = 32
			east
				dir = EAST
			south
				dir = SOUTH
			west
				dir = WEST

		market
			name = "Market"
			mail_tag = "market"

			north
				dir = NORTH
				pixel_y = 32
			east
				dir = EAST
			south
				dir = SOUTH
			west
				dir = WEST

		cafeteria
			name = "Cafeteria"
			mail_tag = "cafeteria"

			north
				dir = NORTH
				pixel_y = 32
			east
				dir = EAST
			south
				dir = SOUTH
			west
				dir = WEST

		arrivals
			name = "Arrivals"
			mail_tag = "arrivals hallway"

			north
				dir = NORTH
				pixel_y = 32
			east
				dir = EAST
			south
				dir = SOUTH
			west
				dir = WEST

		escape
			name = "Escape"
			mail_tag = "escape hallway"

			north
				dir = NORTH
				pixel_y = 32
			east
				dir = EAST
			south
				dir = SOUTH
			west
				dir = WEST

		medbay_lobby
			name = "Medbay Lobby"
			mail_tag = "medbay lobby"

			north
				dir = NORTH
				pixel_y = 32
			east
				dir = EAST
			south
				dir = SOUTH
			west
				dir = WEST

		podbay
			name = "Pod Bay"
			mail_tag = "podbay"

			north
				dir = NORTH
				pixel_y = 32
			east
				dir = EAST
			south
				dir = SOUTH
			west
				dir = WEST
