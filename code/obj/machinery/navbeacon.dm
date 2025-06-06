// Navigation beacon for AI robots
// Functions as a transponder: looks for incoming signal matching

TYPEINFO(/obj/machinery/navbeacon)
	mats = 4

/obj/machinery/navbeacon

	icon = 'icons/obj/objects.dmi'
	icon_state = "navbeacon0"//-f"
	name = "navigation beacon"
	desc = "A radio beacon used for bot navigation."
	level = 1		// underfloor
	layer = 2.5 // TODO layer whatever
	anchored = ANCHORED
	plane = PLANE_NOSHADOW_BELOW

	var/open = 0		// true if cover is open
	var/locked = 1		// true if controls are locked
	var/freq = FREQ_NAVBEACON		// radio frequency
	var/location = ""	// location response text
	var/list/codes		// assoc. list of transponder codes
	var/codes_txt = ""	// codes as set on map: "tag1;tag2" or "tag1=value;tag2=value"
	var/net_id = ""
	var/datum/component/packet_connected/radio/code_component

	req_access = list(access_engineering,access_engineering_mechanic,access_research_director)
	object_flags = CAN_REPROGRAM_ACCESS | NO_GHOSTCRITTER
	mechanics_type_override = /obj/machinery/navbeacon

	New()
		START_TRACKING
		..()

		UnsubscribeProcess()

		var/turf/T = loc
		// the ruckingenur kit makes a temporary instance of an object when it is uploaded, which would cause issues here
		// possibly there are also other ways to get a navbeacon that is not on a turf
		if(isturf(T))
			hide(T.intact)

		if(!net_id)
			net_id = generate_net_id(src)

		set_codes()

	disposing()
		STOP_TRACKING
		. = ..()

	// set the transponder codes assoc list from codes_txt
	proc/set_codes()
		codes = new()

		var/list/entries = splittext(codes_txt, ";")	// entries are separated by semicolons

		for(var/e in entries)
			var/index = findtext(e, "=")		// format is "key=value"
			if(index)
				var/key = copytext(e, 1, index)
				var/val = copytext(e, index+1)
				codes[key] = val
			else
				codes[e] = "1"

		code_component = src.AddComponent( \
			/datum/component/packet_connected/radio, \
			"navbeacon", \
			src.freq, \
			src.net_id, \
			"receive_signal", \
			FALSE, \
			codes + list(location, "any"), \
			FALSE \
		)

	/// adds or edits a code and also makes sure the packet component tag is updated appropriately
	proc/set_code(var/code_key, var/code_value)
		//codes.Remove(code_key)
		codes[code_key] = code_value
		code_component.add_tag(code_key)

	/// removes a code and also makes sure the packet component tag is updated appropriately
	proc/remove_code(var/code_key)
		codes.Remove(code_key)
		code_component.remove_tag(code_key)

	// called when turf state changes
	// hide the object if turf is intact
	hide(var/intact)
		invisibility = intact ? INVIS_ALWAYS : INVIS_NONE
		UpdateIcon()

	// update the icon_state
	update_icon()
		icon_state="navbeacon[open]"
		alpha = invisibility ? 128 : 255

	// look for a signal of the form "findbeacon=X"
	// where X is any
	// or the location
	// or one of the set transponder keys
	// if found, return a signal
	receive_signal(datum/signal/signal)
		if (!signal || signal.encryption) return

		var/beaconrequest = signal.data["findbeacon"] || signal.data["address_tag"]
		if(beaconrequest && ((beaconrequest in codes) || beaconrequest == "any" || beaconrequest == location))
			var/post_target = signal.data["sender"] || signal.data["netid"]
			SPAWN(1 DECI SECOND)
				post_status(post_target)
			return

		if (!signal.data["address_1"] || !signal.data["sender"])
			// Not for us, ignore
			return

		if (signal.data["address_1"] != src.net_id)
			if (signal.data["address_1"] == "ping")
				send_ping_response(signal.data["sender"])
			return

		switch (signal.data["command"])
			if ("help")
				var/datum/signal/reply = get_free_signal()
				reply.source = src
				reply.transmission_method = 1
				reply.data["sender"] = net_id
				reply.data["address_1"] = signal.data["sender"]
				if (!signal.data["topic"])
					reply.data["description"] = "Nav Beacon - provides navigation data for bots"
					reply.data["topics"] = "status,set_location,set_code"
				else
					reply.data["topic"] = signal.data["topic"]
					switch (lowertext(signal.data["topic"]))
						if ("status")
							reply.data["description"] = {"Returns the status of the nav beacon. This includes the beacon
								location and all of the configurable transponder codes.
								Please consult your internal documentation for information about these codes"}
						if ("set_location")
							reply.data["description"] = "Sets the beacon location name"
							reply.data["args"] = "location"
						if ("set_code")
							reply.data["description"] = "Sets the value of a configurable transponder code"
							reply.data["args"] = "code_key,code_value"
						else
							reply.data["description"] = "ERROR: UNKNOWN TOPIC"
				SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, reply)
			if ("status")
				post_status(signal.data["sender"])
			if ("set_location")
				if (!signal.data["location"]) return
				var/newloq = adminscrub(signal.data["location"])
				src.location = newloq
				post_status(signal.data["sender"])
			if ("set_code")
				if (!signal.data["code_key"] || !signal.data["code_value"]) return
				var/code_key = adminscrub(signal.data["code_key"])
				var/code_value = adminscrub(signal.data["code_value"])
				src.set_code(code_key, code_value)
				post_status(signal.data["sender"])


	// return a signal giving location and transponder codes
	proc/post_status(var/target)
		var/datum/signal/signal = get_free_signal()
		signal.source = src
		signal.transmission_method = 1
		signal.data["beacon"] = location
		signal.data["netid"] = net_id
		if (target)
			signal.data["address_1"] = target

		for(var/key in codes)
			signal.data[key] = codes[key]

		SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, signal)

	proc/send_ping_response(var/target)
		if (!target) return

		var/datum/signal/pingsignal = get_free_signal()
		pingsignal.source = src
		pingsignal.data["device"] = "NAV_BEACON"
		pingsignal.data["netid"] = src.net_id
		pingsignal.data["sender"] = src.net_id
		pingsignal.data["address_1"] = target
		pingsignal.data["command"] = "ping_reply"

		SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, pingsignal)

	attackby(var/obj/item/I, var/mob/user)
		var/turf/T = loc
		if (T.intact)
			return		// prevent intraction when T-scanner revealed

		if (isscrewingtool(I))
			open = !open

			user.visible_message("[user] [open ? "opens" : "closes"] the beacon's cover.", "You [open ? "open" : "close"] the beacon's cover.")

			UpdateIcon()

		if (istype(get_id_card(I), /obj/item/card/id))
			if (open)
				if (src.allowed(user))
					src.locked = !src.locked
					boutput(user, "Controls are now [src.locked ? "locked." : "unlocked."]")
				else
					boutput(user, SPAN_ALERT("Access denied."))
				updateDialog()
			else
				boutput(user, "You must open the cover first!")
		return

	attack_ai(var/mob/user)
		interacted(user, 1)

	attack_hand(var/mob/user)
		if (isnpc(user))
			return
		interacted(user, 0)

	proc/interacted(var/mob/user, var/ai = 0)
		var/turf/T = loc
		if(T.intact)
			return		// prevent intraction when T-scanner revealed

		if(!open && !ai)	// can't alter controls if not open, unless you're an AI
			boutput(user, "The beacon's control cover is closed.")
			return


		var/t

		if(locked && !ai)
			t = {"<TT><B>Navigation Beacon</B><HR><BR>
<i>(swipe card to unlock controls)</i><BR>
Frequency: [format_frequency(freq)]<BR><HR>
Location: [location ? location : "(none)"]</A><BR>
Transponder Codes:<UL>"}

			for(var/key in codes)
				t += "<LI>[key] ... [codes[key]]"
			t+= "<UL></TT>"

		else

			t = {"<TT><B>Navigation Beacon</B><HR><BR>
<i>(swipe card to lock controls)</i><BR>
Frequency:
<A href='byond://?src=\ref[src];freq=-10'>-</A>
<A href='byond://?src=\ref[src];freq=-2'>-</A>
[format_frequency(freq)]
<A href='byond://?src=\ref[src];freq=2'>+</A>
<A href='byond://?src=\ref[src];freq=10'>+</A><BR>
<HR>
Location: <A href='byond://?src=\ref[src];locedit=1'>[location ? location : "(none)"]</A><BR>
Transponder Codes:<UL>"}

			for(var/key in codes)
				t += "<LI>[key] ... [codes[key]]"
				t += " <small><A href='byond://?src=\ref[src];edit=1;code=[key]'>(edit)</A>"
				t += " <A href='byond://?src=\ref[src];delete=1;code=[key]'>(delete)</A></small><BR>"
			t += "<small><A href='byond://?src=\ref[src];add=1;'>(add new)</A></small><BR>"
			t+= "<UL></TT>"

		user.Browse(t, "window=navbeacon")
		onclose(user, "navbeacon")
		return

	Topic(href, href_list)
		..()
		if (usr.stat)
			return
		if ((in_interact_range(src, usr) && istype(src.loc, /turf)) || (issilicon(usr)))
			if(open && !locked)
				src.add_dialog(usr)

				if (href_list["freq"])
					freq = sanitize_frequency(freq + text2num_safe(href_list["freq"]))
					set_frequency(freq)
					updateDialog()

				else if(href_list["locedit"])
					var/newloc = input("Enter New Location", "Navigation Beacon", location) as text|null
					newloc = copytext(adminscrub(newloc), 1, 64)
					if(newloc)
						location = newloc
						updateDialog()

				else if(href_list["edit"])
					var/codekey = href_list["code"]

					var/newkey = input("Enter Transponder Code Key", "Navigation Beacon", codekey) as text|null
					newkey = copytext(adminscrub(newkey), 1, 64)
					if(!newkey)
						return

					var/codeval = codes[codekey]
					var/newval = input("Enter Transponder Code Value", "Navigation Beacon", codeval) as text|null
					newval = copytext(adminscrub(newval), 1, 256)
					if(!newval)
						newval = codekey
						return

					src.remove_code(codekey)
					src.set_code(newkey, newval)

					updateDialog()

				else if(href_list["delete"])
					var/codekey = href_list["code"]
					src.remove_code(codekey)
					updateDialog()

				else if(href_list["add"])

					var/newkey = input("Enter New Transponder Code Key", "Navigation Beacon") as text|null
					newkey = copytext(adminscrub(newkey), 1, 64)
					if(!newkey)
						return

					var/newval = input("Enter New Transponder Code Value", "Navigation Beacon") as text|null
					newval = copytext(adminscrub(newval), 1, 64)
					if(!newval)
						newval = "1"
						return

					if(!codes)
						codes = new()

					src.set_code(newkey, newval)

					updateDialog()

	proc/set_frequency(var/new_freq)
		freq = new_freq
		get_radio_connection_by_id(src, "navbeacon").update_frequency(freq)

//Wired nav device
TYPEINFO(/obj/machinery/wirenav)
	mats = 8

/obj/machinery/wirenav
	name = "Wired Nav Beacon"
	icon = 'icons/obj/objects.dmi'
	icon_state = "wirednav"//-f"
	level = 1		// underfloor
	layer = OBJ_LAYER
	anchored = ANCHORED
	var/nav_tag = null
	var/net_id = null
	var/obj/machinery/power/data_terminal/link = null

	hide(var/intact)
		invisibility = intact ? INVIS_ALWAYS : INVIS_NONE
		//src.icon_state = "wirednav[invisibility ? "-f" : ""]"
		alpha = invisibility ? 128 : 255

	New()
		..()

		var/turf/T = get_turf(src)
		hide(T.intact)

		SPAWN(0.6 SECONDS)
			if(!nav_tag)
				src.nav_tag = "NOWHERE"
				var/area/A = get_area(src)
				if(A)
					src.nav_tag = A.name

			if(!src.net_id)
				src.net_id = generate_net_id(src)

			if(!src.link)
				var/obj/machinery/power/data_terminal/test_link = locate() in T
				if(test_link && !DATA_TERMINAL_IS_VALID_MASTER(test_link, test_link.master))
					src.link = test_link
					src.link.master = src

		return

	receive_signal(datum/signal/signal)
		if(status & NOPOWER || !src.link)
			return

		if(!signal || signal.encryption || !signal.data["sender"])
			return

		if(signal.transmission_method != TRANSMISSION_WIRE)
			return

		var/sender = signal.data["sender"]
		if((signal.data["address_1"] in list(src.net_id, "ping")) && sender)
			var/datum/signal/reply = new
			reply.data["address_1"] = sender
			reply.data["command"] = "ping_reply"
			reply.data["device"] = "PNET_NAV_BEACN"
			reply.data["netid"] = src.net_id
			reply.data["data"] = src.nav_tag
			reply.data["navdat"] = "x=[src.x]&y=[src.y]&z=[src.z]"
			SPAWN(0.5 SECONDS)
				src.link.post_signal(src, reply)
			return

		return

/obj/machinery/navbeacon/guardbot_buddytime
	name = "buddy time beacon"
	location = "buddytime"
	codes_txt = "patrol"

// Circular patrol pattern. I'm sure as hell not going to varedit all those things by hand.
// 20 should be sufficient for a full-sized map such as COG1 or 2 (Convair880).
/obj/machinery/navbeacon/guardbotsecbot_circularpatrol
	name = "bot patrol navigational beacon"

	beacon1_start
		location = "1"
		codes_txt = "patrol;next_patrol=2"
	beacon2
		location = "2"
		codes_txt = "patrol;next_patrol=3"
	beacon3
		location = "3"
		codes_txt = "patrol;next_patrol=4"
	beacon4
		location = "4"
		codes_txt = "patrol;next_patrol=5"
	beacon5
		location = "5"
		codes_txt = "patrol;next_patrol=6"
	beacon6
		location = "6"
		codes_txt = "patrol;next_patrol=7"
	beacon7
		location = "7"
		codes_txt = "patrol;next_patrol=8"
	beacon8
		location = "8"
		codes_txt = "patrol;next_patrol=9"
	beacon9
		location = "9"
		codes_txt = "patrol;next_patrol=10"
	beacon10
		location = "10"
		codes_txt = "patrol;next_patrol=11"
	beacon11
		location = "11"
		codes_txt = "patrol;next_patrol=12"
	beacon12
		location = "12"
		codes_txt = "patrol;next_patrol=13"
	beacon13
		location = "13"
		codes_txt = "patrol;next_patrol=14"
	beacon14
		location = "14"
		codes_txt = "patrol;next_patrol=15"
	beacon15
		location = "15"
		codes_txt = "patrol;next_patrol=16"
	beacon16
		location = "16"
		codes_txt = "patrol;next_patrol=17"
	beacon17
		location = "17"
		codes_txt = "patrol;next_patrol=18"
	beacon18
		location = "18"
		codes_txt = "patrol;next_patrol=19"
	beacon19
		location = "19"
		codes_txt = "patrol;next_patrol=20"
	beacon20_to_1_end
		location = "20"
		codes_txt = "patrol;next_patrol=1"

// Same deal for MULE delivery beacons (Convair880).
/obj/machinery/navbeacon/mule
	name = "MULE delivery beacon"

	QM1_north
		location = "QM #1"
		codes_txt = "delivery;dir=1"

		east
			codes_txt = "delivery;dir=4"
		south
			codes_txt = "delivery;dir=2"
		west
			codes_txt = "delivery;dir=8"
	QM2_north
		location = "QM #2"
		codes_txt = "delivery;dir=1"

		east
			codes_txt = "delivery;dir=4"
		south
			codes_txt = "delivery;dir=2"
		west
			codes_txt = "delivery;dir=8"
	crewA_north
		location = "Crew Quarters A"
		codes_txt = "delivery;dir=1"

		east
			codes_txt = "delivery;dir=4"
		south
			codes_txt = "delivery;dir=2"
		west
			codes_txt = "delivery;dir=8"
	crewB_north
		location = "Crew Quarters B"
		codes_txt = "delivery;dir=1"

		east
			codes_txt = "delivery;dir=4"
		south
			codes_txt = "delivery;dir=2"
		west
			codes_txt = "delivery;dir=8"
	catering_north
		location = "Catering"
		codes_txt = "delivery;dir=1"

		east
			codes_txt = "delivery;dir=4"
		south
			codes_txt = "delivery;dir=2"
		west
			codes_txt = "delivery;dir=8"
	toolstorage_north
		location = "Tool Storage"
		codes_txt = "delivery;dir=1"

		east
			codes_txt = "delivery;dir=4"
		south
			codes_txt = "delivery;dir=2"
		west
			codes_txt = "delivery;dir=8"
	hydroponics_north
		location = "Hydroponics"
		codes_txt = "delivery;dir=1"

		east
			codes_txt = "delivery;dir=4"
		south
			codes_txt = "delivery;dir=2"
		west
			codes_txt = "delivery;dir=8"
	chapel_north
		location = "Chapel"
		codes_txt = "delivery;dir=1"

		east
			codes_txt = "delivery;dir=4"
		south
			codes_txt = "delivery;dir=2"
		west
			codes_txt = "delivery;dir=8"
	security_north
		location = "Security"
		codes_txt = "delivery;dir=1"

		east
			codes_txt = "delivery;dir=4"
		south
			codes_txt = "delivery;dir=2"
		west
			codes_txt = "delivery;dir=8"
	courtroom_north
		location = "Courtroom"
		codes_txt = "delivery;dir=1"

		east
			codes_txt = "delivery;dir=4"
		south
			codes_txt = "delivery;dir=2"
		west
			codes_txt = "delivery;dir=8"
	market_north
		location = "Market"
		codes_txt = "delivery;dir=1"

		east
			codes_txt = "delivery;dir=4"
		south
			codes_txt = "delivery;dir=2"
		west
			codes_txt = "delivery;dir=8"
	podbay_north
		location = "Main Pod Bay"
		codes_txt = "delivery;dir=1"

		east
			codes_txt = "delivery;dir=4"
		south
			codes_txt = "delivery;dir=2"
		west
			codes_txt = "delivery;dir=8"
	engineering_north
		location = "Engineering"
		codes_txt = "delivery;dir=1"

		east
			codes_txt = "delivery;dir=4"
		south
			codes_txt = "delivery;dir=2"
		west
			codes_txt = "delivery;dir=8"
	research_north
		location = "Research"
		codes_txt = "delivery;dir=1"

		east
			codes_txt = "delivery;dir=4"
		south
			codes_txt = "delivery;dir=2"
		west
			codes_txt = "delivery;dir=8"
	medbay_north
		location = "Medbay"
		codes_txt = "delivery;dir=1"

		east
			codes_txt = "delivery;dir=4"
		south
			codes_txt = "delivery;dir=2"
		west
			codes_txt = "delivery;dir=8"
	bridge_north
		location = "Bridge"
		codes_txt = "delivery;dir=1"

		east
			codes_txt = "delivery;dir=4"
		south
			codes_txt = "delivery;dir=2"
		west
			codes_txt = "delivery;dir=8"
	cafeteria_north
		location = "Cafeteria"
		codes_txt = "delivery;dir=1"

		east
			codes_txt = "delivery;dir=4"
		south
			codes_txt = "delivery;dir=2"
		west
			codes_txt = "delivery;dir=8"
	hallway_escape_north
		location = "Escape Hallway"
		codes_txt = "delivery;dir=1"

		east
			codes_txt = "delivery;dir=4"
		south
			codes_txt = "delivery;dir=2"
		west
			codes_txt = "delivery;dir=8"
	hallway_arrivals_north
		location = "Arrivals Hallway"
		codes_txt = "delivery;dir=1"

		east
			codes_txt = "delivery;dir=4"
		south
			codes_txt = "delivery;dir=2"
		west
			codes_txt = "delivery;dir=8"
	hallway_fore_north
		location = "North Primary Hallway"
		codes_txt = "delivery;dir=1"

		east
			codes_txt = "delivery;dir=4"
		south
			codes_txt = "delivery;dir=2"
		west
			codes_txt = "delivery;dir=8"
	hallway_starboard_north
		location = "East Primary Hallway"
		codes_txt = "delivery;dir=1"

		east
			codes_txt = "delivery;dir=4"
		south
			codes_txt = "delivery;dir=2"
		west
			codes_txt = "delivery;dir=8"
	hallway_aft_north
		location = "South Primary Hallway"
		codes_txt = "delivery;dir=1"

		east
			codes_txt = "delivery;dir=4"
		south
			codes_txt = "delivery;dir=2"
		west
			codes_txt = "delivery;dir=8"
	hallway_port_north
		location = "West Primary Hallway"
		codes_txt = "delivery;dir=1"

		east
			codes_txt = "delivery;dir=4"
		south
			codes_txt = "delivery;dir=2"
		west
			codes_txt = "delivery;dir=8"
	hallway_central_north
		location = "Central Primary Hallway"
		codes_txt = "delivery;dir=1"

		east
			codes_txt = "delivery;dir=4"
		south
			codes_txt = "delivery;dir=2"
		west
			codes_txt = "delivery;dir=8"
	ranch_north
		location = "Ranch"
		codes_txt = "delivery;dir=1"

		east
			codes_txt = "delivery;dir=4"
		south
			codes_txt = "delivery;dir=2"
		west
			codes_txt = "delivery;dir=8"
	pool_north
		location = "Pool"
		codes_txt = "delivery;dir=1"

		east
			codes_txt = "delivery;dir=4"
		south
			codes_txt = "delivery;dir=2"
		west
			codes_txt = "delivery;dir=8"
	news_office
		location = "News Office"
		codes_txt = "delivery;dir=1"

		east
			codes_txt = "delivery;dir=4"
		south
			codes_txt = "delivery;dir=2"
		west
			codes_txt = "delivery;dir=8"
	mining_north
		location = "Mining"
		codes_txt = "delivery;dir=1"

		east
			codes_txt = "delivery;dir=4"
		south
			codes_txt = "delivery;dir=2"
		west
			codes_txt = "delivery;dir=8"

/obj/machinery/navbeacon/tour
	name = "tour beacon"
	freq = FREQ_TOUR_NAVBEACON

/obj/machinery/navbeacon/tour/cog1
	tour0
		name = "tour beacon - start"
		location = "tour0"
		codes_txt = "tour;next_tour=tour1;desc=Hello! Welcome to to the Nanotrasen C-Class Orbital Facility Tour! I will be your tourguide today on this adventure! Let's get started!"

	tour1
		name = "tour beacon - 'Bar'"
		location = "tour1"
		codes_txt = "tour;next_tour=tour2;desc=A happy crew is a productive crew! During approved breaks, please enjoy your station's cafeteria and lounge. Be sure to drink responsibly though!"

	tour2
		name = "tour beacon - 'Detective'"
		location = "tour2"
		codes_txt = "tour;next_tour=tour3;desc=Oh, um... here's where the detective works. I think they might have a drinking problem, but that's just between you and me. "

	tour3
		name = "tour beacon - 'Chapel'"
		location = "tour3"
		codes_txt = "tour;next_tour=tour4;desc=Are you in need of spiritual counseling? Your station's theological staff is here to provide counseling and uplifting advice in the Chapel. The pen-and-paper game club meets in here too! Your station's hard-working Janitor's office is down below the Chapel. There's also a fully equipped hydroponics facility on this end of the station, helping to keep everyone healthy with bushels and bushels of tasty fruits and veggies!"

	tour4
		name = "tour beacon - 'Lounge'"
		location = "tour4"
		codes_txt = "tour;next_tour=tour5;desc=This is the Arthur Muggins Memorial Jazz Lounge, brought to you by Nanotrasen Cultural Directive 45-T, Subsection 3."

	tour5
		name = "tour beacon - 'Fitness'"
		location = "tour5"
		codes_txt = "tour;next_tour=tour6;desc=It's important to remain fit and healthy while working in an extraplanetary workplace! You'll find a swimming pool below you and a boxing ring above. We also have a state-of-the-art virtual entertainment arcade for those of a less athletic persuasion."

	tour6
		name = "tour beacon - 'Crew Quarters'"
		location = "tour6"
		codes_txt = "tour;next_tour=tour7;desc=We are now in the crew quarters. Need a nap? Need a haircut? Here's your home away from home!"

	tour7
		name = "tour beacon - 'Security'"
		location = "tour7"
		codes_txt = "tour;next_tour=tour8;desc=Corporate espionage and criminal misdeeds are a sad fact of life out in deep space. If you see something, say something! Your helpful security team is hard at work keeping your station safe."

	tour8
		name = "tour beacon - 'Courtroom'"
		location = "tour8"
		codes_txt = "tour;next_tour=tour9;desc=This is your station's command lobby and courtroom. Your Head of Personnel might have some new work for you. You might also get to see the thrilling drama of the legal process at work!"

	tour9
		name = "tour beacon - 'Owlery'"
		location = "tour9"
		codes_txt = "tour;next_tour=tour10;desc=Hoot! Hoot! Did you know that your Regional Director is a noted amateur ornithologist? If you're feeling stressed out at work, please enjoy the company and soothing hoots of these majestic beasts. Pardon the darkness, they are nocturnal after all."

	tour10
		name = "tour beacon - 'EVA'"
		location = "tour10"
		codes_txt = "tour;next_tour=tour11;desc=Please keep your hands inside the station at all times! Remember, Safety First! In the event that you do need to go out in space though, you will probably want an EVA suit. Make sure to ask for permission first!"

	tour11
		name = "tour beacon - 'AI'"
		location = "tour11"
		codes_txt = "tour;next_tour=tour12;desc=Your station's hard-working and dependable AI construct lives near here! Please remember to treat it with respect. Vehicular pods may be available in the adjacent hangar, but due to budget constraints you may have to build your own. Please forward any complaints to your Head of Personnel."

	tour12
		name = "tour beacon - 'Research'"
		location = "tour12"
		codes_txt = "tour;next_tour=tour13;desc=What would a research station be without a research sector? Beats me! Anyways, that's what's in here. Authorized personnel only! Your station's science team is very busy working on very serious and important sciencey stuff!"

	tour13
		name = "tour beacon - 'Medbay'"
		location = "tour13"
		codes_txt = "tour;next_tour=tour14;desc=Safety first! Accidents do happen though, and if you find yourself injured in the line of work, please hurry along to see your Medbay staff. NOTICE: It has been zero (0) days since the last workplace injury."

	tour14
		name = "tour beacon - 'Engine'"
		location = "tour14"
		codes_txt = "tour;next_tour=tour15;desc=Thanks to advances in plasma research, your C-class station has been equipped with a new Thermo-Electric Generator engine! Singularity accidents are a thing of the past! Who ever thought it was a good idea to keep a black hole inside a space station anyways? Yeesh!"

	tour15
		name = "tour beacon - 'Quartermasters'"
		location = "tour15"
		codes_txt = "tour;next_tour=tour16;desc=Need some new equipment or supplies for your workplace? Come on down to your local Quartermasters' office! If they ain't got it, you probably don't want it anyways."

	tour16
		name = "tour beacon - 'Escape'"
		location = "tour16"
		codes_txt = "tour;next_tour=tour17;desc=In the event of catastrophic station damage or approved shift change, a shuttle will be dispatched from the regional Central Command dock to this location. Should this occur, remember to line up quietly and enter single-file. No shoving please!"

	tour17
		name = "tour beacon - end"
		location = "tour17"
		codes_txt = "tour;next_tour=tour18;desc=I hope you all have an excellent, safe and productive shift onboard this station! If you've enjoyed the tour, please put in a nice word about Murray if you see your captain."

	tour18
		name = "tour beacon - return"
		location = "tour18"
		codes_txt = "tour;next_tour=tour19;"

	tour19
		name = "tour beacon - return"
		location = "tour19"
		codes_txt = "tour;next_tour=tour20;"

	tour20
		name = "tour beacon - home"
		location = "tour20"
		codes_txt = "tour"

/obj/machinery/navbeacon/tour/cog2
	tour0
		name = "tour beacon - 'Arrivals'"
		location = "tour0"
		codes_txt = "tour;next_tour=tour1;desc=Hello! Welcome to to the Nanotrasen C-Class Orbital Facility Tour! I will be your tourguide today on this adventure! Let's get started!\nThis fine place is the arrival lobby!  It features a full shuttle dock for arriving workers!  It never takes leaving employees, though.  I think they fumigate the shuttle on the way back."

	tour1
		name = "tour beacon - 'Net Cafe'"
		location = "tour1"
		codes_txt = "tour;next_tour=tour2;desc=This is the \"Network Cafe!\"  It has computers...on a network!  I think it used to have a bulletin board set up, but the computer running that fell off a shelf and nobody has fixed it yet."

	tour2
		name = "tour beacon - 'Chapel'"
		location = "tour2"
		codes_txt = "tour;next_tour=tour3;desc=The station chapel is here to meet all of the crew's spiritual needs.  It is non-denominational and may serve as a chapel, synagogue, mosque, shrine, house of worship, or fire temple.  Also, sometimes there are bingo nights and it's a good place to store extra chairs."

	tour3
		name = "tour beacon - 'Fitness'"
		location = "tour3"
		codes_txt = "tour;next_tour=tour4;desc=Fitness is very important in space, as time spent in low or zero gravity rapidly diminishes muscle mass.  To combat this, the station has a full fitness and recreation center, including a pool!  I hear that pools are pretty fun, but I don't think water wings would work for me since I only have one arm.  Also because I am a robot and would die."

	tour4
		name = "tour beacon - 'Bar'"
		location = "tour4"
		codes_txt = "tour;next_tour=tour5;desc=The station bar is the primary dining area for station employees, offering a full assortment of great food and drinks.  The detective's office is connected in the back.  I, um, hope they don't fall off the wagon..."

	tour5
		name = "tour beacon - 'Podbays'"
		location = "tour5"
		codes_txt = "tour;next_tour=tour6;desc=Here are the station pod bays and outer engineering compartments.  Don't worry, the engine is supposed to be full of fire!  Um, the black tiled parts are, I mean.  Well, some of them.  Please try to avoid touching energy beams and hot surfaces."

	tour6
		name = "tour beacon - 'MedSci'"
		location = "tour6"
		codes_txt = "tour;next_tour=tour7;desc=The station's medical bay and research facilities are some of the most advanced out there!  For the purposes of that previous statement, \"out there\" is defined as \"on this side of the Channel wormhole, orbiting this gas giant, and at this particular apogee, perigee, and inclination.\"  Don't forget to come down here if you or a coworker need medical attention!"

	tour7
		name = "tour beacon - 'Cargo'"
		location = "tour7"
		codes_txt = "tour;next_tour=tour8;desc=The cargo bay serves the station's need for supplies and sells off surplus materials.  One time they spent the entire budget on crates of tapioca pudding."

	tour8
		name = "tour beacon - 'Mining'"
		location = "tour8"
		codes_txt = "tour;next_tour=tour9;desc=The station isn't the only thing in orbit!  There's also a wide variety of captured asteroids and similar objects.  Mining pulls them in and harvests them for resources.  I hope they fixed the thing where the asteroid keeps moving and shears the entire department off."

	tour9
		name = "tour beacon - 'Escape'"
		location = "tour9"
		codes_txt = "tour;next_tour=tour10;desc=This is the escape shuttle dock.  It's where you will leave the station at the end of your shift.  It's also the designated meeting area for the INCREDIBLY UNLIKELY case that a disaster occurs and the station needs to be evacuated."

	tour10
		name = "tour beacon - 'Bridge'"
		location = "tour10"
		codes_txt = "tour;next_tour=tour11;desc=If the engine is the station's heart, then the bridge is its brain!  And security here is its lymph nodes or kidneys or something.  I'm, um, not very good at biology, sorry."

	tour11
		name = "tour beacon - 'End'"
		location = "tour11"
		codes_txt = "tour;"

/obj/machinery/navbeacon/tour/destiny
	tour0
		name = "tour beacon - start"
		location = "tour0"
		codes_txt = "tour;next_tour=tour1;desc=Hello, vital crew member! You have been awakened for a shift on the NSS Destiny. This is year... five! of this exciting exploratory mission in the %system% system. If you would like to be re-familiarized with the ship layout, please follow me in an orderly manner!"
		New()
			var/system_name = pick(uppercase_letters) + pick(vowels_upper) + pick(consonants_upper)
			src.codes_txt = replacetext(src.codes_txt, "%system%", system_name)
			..()

	tour1
		name = "tour beacon - 'Cryogenics'"
		location = "tour1"
		codes_txt = "tour;next_tour=tour2;desc=I hope you had a good nap in cryosleep! Ha ha! I'm just making conversation, I know it's a dreamless silence.\nIn any case, please be careful around the cryonics equipment. Remember: just because somebody dared you to lick a coolant pipe doesn't mean you have to. I mean, if everyone else was jumping off an airbridge into the cold of space, would you? Statistically yes, but please don't."

	tour2
		name = "tour beacon - 'Bar'"
		location = "tour2"
		codes_txt = "tour;next_tour=tour3;desc=This is the bar! It will serve all of your dietary needs and act as a great place for social interaction and relaxation. There is also a full stock of bad action movie video tapes... somewhere..."

	tour3
		name = "tour beacon - 'Detective'"
		location = "tour3"
		codes_txt = "tour;next_tour=tour4;desc=This is the detective's office! They help investigate crimes and perform forensic work, not that there is much crime on the ship! I, um, think they might have a drinking problem...\nUp that hallway are the restroom facilities. The rest facilities of the NSS Destiny were more than doubled in size during construction due to growing... hygiene issues... on other NT facilities."

	tour4
		name = "tour beacon - 'Medbay'"
		location = "tour4"
		codes_txt = "tour;next_tour=tour5;desc=Safety first! Accidents do happen though, and if you find yourself injured in the line of work, please hurry along to see your Medbay staff. NOTICE: It has been zero (0) days since the last workplace injury."

	tour5
		name = "tour beacon - 'Engineering'"
		location = "tour5"
		codes_txt = "tour;next_tour=tour6;desc=Thanks to advances in plasma research, the NSS Destiny has been equipped with a new Thermo-Electric Generator engine! Singularity accidents are a thing of the past! Who ever thought it was a good idea to keep a black hole inside a spaceship anyways? Yeesh!"

	tour6
		name = "tour beacon - 'Security'"
		location = "tour6"
		codes_txt = "tour;next_tour=tour7;desc=This is the NSS Destiny's security office and courtroom. Corporate espionage and criminal misdeeds are a sad fact of life out in deep space. If you see something, say something! Your helpful security team is hard at work keeping the ship safe. You might also get to see the thrilling drama of the legal process at work!"

	tour7
		name = "tour beacon - 'EVA'"
		location = "tour7"
		codes_txt = "tour;next_tour=tour8;desc=Please keep your hands inside the station at all times! Remember, Safety First! In the event that you do need to go out in space though, you will probably want an EVA suit. Make sure to ask for permission first!"

	tour8
		name = "tour beacon - 'Fitness'"
		location = "tour8"
		codes_txt = "tour;next_tour=tour9;desc=Fitness is very important in space, as time spent in low or zero gravity rapidly diminishes muscle mass.  To combat this, the ship has a full fitness and recreation center, including a pool!  I hear that pools are pretty fun, but I don't think water wings would work for me since I only have one arm.  Also because I am a robot and would die."

	tour9
		name = "tour beacon - 'Cargo'"
		location = "tour9"
		codes_txt = "tour;next_tour=tour10;desc=The cargo bay serves the station's need for supplies and sells off surplus materials.  One time they spent the entire budget on crates of tapioca pudding."

	tour10
		name = "tour beacon - 'Research'"
		location = "tour10"
		codes_txt = "tour;next_tour=tour11;desc=What would a research vessel be without a research sector? Beats me! Anyways, that's what's in here. Authorized personnel only! The Destiny's science team is very busy working on very serious and important sciencey stuff!"

	tour11
		name = "tour beacon - 'Hydroponics'"
		location = "tour11"
		codes_txt = "tour;next_tour=tour12;desc=This is the Destiny's fully equipped hydroponics facility! It helps keep everyone healthy with bushels and bushels of tasty fruits and veggies, delivered straight to the kitchen!"

	tour12
		name = "tour beacon - 'Bridge'"
		location = "tour12"
		codes_txt = "tour;next_tour=tour13;desc=This is the core of the NSS Destiny, the bridge! Your station's hard-working and dependable AI construct lives here as well! Please remember to treat it with respect."

	tour13
		name = "tour beacon - 'Chapel'"
		location = "tour13"
		codes_txt = "tour;next_tour=tour14;desc=Are you in need of spiritual counseling? The Destiny's theological staff is here to provide counseling and uplifting advice in the Chapel. It is non-denominational and may serve as a chapel, synagogue, mosque, shrine, house of worship, or fire temple.  Also, sometimes there are bingo nights and it's a good place to store extra chairs."

	tour14
		name = "tour beacon - 'Crew Quarters'"
		location = "tour14"
		codes_txt = "tour;next_tour=tour15;desc=We are now in the crew quarters. Need a nap? Need a haircut? Here's your home away from home!"

	tour15
		name = "tour beacon - 'Net Cafe'"
		location = "tour15"
		codes_txt = "tour;next_tour=tour16;desc=This is the \"Network Cafe!\" It has computers... on a network! I think it used to have a bulletin board set up, but the computer running that fell off a shelf and nobody has fixed it yet."

	tour16
		name = "tour beacon - 'Heads'"
		location = "tour16"
		codes_txt = "tour;next_tour=tour17;desc=This is the Head of Personnel's office! You can come here to ask them for assistance with a variety of issues, from changing jobs to getting fired! The Captain's office is just up the hall, and the other department heads' quarters are just behind us. Boy, there sure are a lot of command staff all bunched up here in this thin, fragile part of the ship!"

	tour17
		name = "tour beacon - 'Aviary'"
		location = "tour17"
		codes_txt = "tour;next_tour=tour18;desc=Squawk! Squawk! Did you know that your Regional Director is a noted amateur ornithologist? If you're feeling stressed out at work, please enjoy the company and soothing squawks and hoots of these majestic beasts. Please don't leave anything valuable in the aviary, as the birds have been known to steal things left lying around."

	tour18
		name = "tour beacon - 'Escape'"
		location = "tour18"
		codes_txt = "tour;next_tour=tour19;desc=This is the escape shuttle dock. It's where you will leave the station at the end of your shift. It's also the designated meeting area for the INCREDIBLY UNLIKELY case that a disaster occurs and the station needs to be evacuated. Vehicular pods may be available in the adjacent hangar, but due to budget constraints you may have to build your own. Please forward any complaints to your Head of Personnel."

	tour19
		name = "tour beacon - end"
		location = "tour19"
		codes_txt = "tour;next_tour=tour20;desc=I hope you all have an excellent, safe and productive shift onboard the NSS Destiny! If you've enjoyed the tour, please put in a nice word about Mary if you see your captain."

	tour20
		name = "tour beacon - home"
		location = "tour20"
		codes_txt = "tour;"


/obj/machinery/navbeacon/tour/oshan
	tour0
		name = "tour beacon - 'Arrivals'"
		location = "tour0"
		codes_txt = "tour;next_tour=tour1;desc=Hello friend, and welcome to to the Nanotrasen Deep Sea Facility Tour! I will be your tourguide today on this adventure! Let's get started!\nThis lovely location is the arrivals lobby! It supports the PRISMA arrival pod system, which provides employees with their own private and efficient shuttle transport. Where do they launch from? Well, that's classified."

	tour1
		name = "tour beacon - 'Radio Lab'"
		location = "tour1"
		codes_txt = "tour;next_tour=tour2;desc=If you'll look to the east, you'll see our station's very own radio laboratory. Recently installed, it features everything you'd need to host an engaging show, and is equipped to broadcast all the way over to the next sector. Though, you'd have to pay Syndicate - um, syndication - fees first."

	tour2
		name = "tour beacon - 'Information Office'"
		location = "tour2"
		codes_txt = "tour;next_tour=tour3;desc=This is our information office. It's stocked with all sorts of reading materials and news equipment, if you'd ever like to try your hand at being a reporter. And if you ever feel lost and alone, you should see the station psychotherapist. But if they're off-duty, this is a pretty good alternative. The help desk should provide directions and insight, if not for your life, to the station's bar and on what drinks to order."

	tour3
		name = "tour beacon - 'Customs'"
		location = "tour3"
		codes_txt = "tour;next_tour=tour4;desc=Customs, the first stop for every new employee. Here, you can receive additional access, apply for a raise, or fill out the forms required for the deep sea transport of exotic birds or nuclear missiles." // TODO: Ask Haine if we can have a bird in a trench area that is actually a bomb

	tour4
		name = "tour beacon - 'Courtroom'"
		location = "tour4"
		codes_txt = "tour;next_tour=tour5;desc=Ah, the courtroom. Where trials are held and justice is served. Did you know that the concept for monkeys in suits and funny hats was popularized by the resident monkey, Tanhony, when he starred as a fresh-faced lawyer in The Tale of Heisenbee? Yes, it's really quite incredible."

	tour5
		name = "tour beacon - 'Bridge'"
		location = "tour5"
		codes_txt = "tour;next_tour=tour6;desc=Shh, you gotta be quiet here. Something important might be going on inside. After all, the bridge is where the all powerful heads of staff convene and confer on the most serious matters. Today, the legalization of space cannabis. Tomorrow, the working rights of the downtrodden simian and common staff assistant."

	tour6
		name = "tour beacon - 'Security'"
		location = "tour6"
		codes_txt = "tour;next_tour=tour7;desc=The security department here at Oshan Laboratory is exceptional. Contrary to popular belief, they're all pretty decent, upstanding folk, who really do want to make the station a better and safer place. Hooty McJudgementowl over there can attest. Bring them a donut and a coffee sometime!"

	tour7
		name = "tour beacon - 'Network Cafe'"
		location = "tour7"
		codes_txt = "tour;next_tour=tour8;desc=This is the network cafe, featuring a full range of state of the ark - er, art - computers and consoles. Here, you can check your email, work on your stock portfolio, or print some nice pamphlets. To preserve employee productivity and combat misinformation, all connections are monitored and filtered."

	tour8
		name = "tour beacon - 'Supply Lobby'"
		location = "tour8"
		codes_txt = "tour;next_tour=tour9;desc=Here, in the supply lobby, you can order whatever you'd like - a home networking kit, a Golden Gannet delivery, a haberdasher's crate - and watch in real time as expert quartermasters process your order and ensure its smooth delivery. It's wonderfully instant gratification."

	tour9
		name = "tour beacon - 'Fitness Room'"
		location = "tour9"
		codes_txt = "tour;next_tour=tour10;desc=The fitness room is where the crew visit if they're ever in need of some excitement or endorphins. We used to have weekly boxing tournaments, but they were eventually phased out after one too many traumatic brain injuries. Now we have Tango Tuesdays which do a great job of repurposing the boxing mat."

	tour10
		name = "tour beacon - 'Bar'"
		location = "tour10"
		codes_txt = "tour;next_tour=tour11;desc=Nanotrasen bars are known for their astounding array of tasty beverages. It was here at Oshan Laboratory that the first Tom Collins was mixed and served, named for the intrepid deep sea explorer Tom Collins, who one day disappeared into the trench, never to be seen again...\nTime and time again, our beloved bar has been bestowed awards and letters of appreciation for its bold and inventive take on classic drinks. Most recently, we've received an offer from Delectable Dan's to tour their new distillery and give advice on their offerings."

	tour11
		name = "tour beacon - 'Hydroponics'"
		location = "tour11"
		codes_txt = "tour;next_tour=tour12;desc=It's just as important to get your vitamins A through Z in the deep sea as it is in deep space! Nine out of ten of our botanists are licensed nutritionists and will happily assist you on your food journey. One out of ten are licensed bee caretakers and are unfortunately too busy for appointments."

	tour12
		name = "tour beacon - 'Crew Quarters'"
		location = "tour12"
		codes_txt = "tour;next_tour=tour13;desc=I like to think that each and every employee truly enjoys being here with us at Oshan Laboratory, but that ultimately is never the case. Life under the sea can get pretty isolating or even frustrating, and, really, I get it. If you're ever looking for a quiet place to de-stress and relax, crew quarters is your best bet. It's guaranteed space abestos free, and has good feng shui to boot."

	tour13
		name = "tour beacon - 'Chapel'"
		location = "tour13"
		codes_txt = "tour;next_tour=tour14;desc=According to a recent survey, the majority of Nanotrasen employees are nonreligious. But no matter what you do or don't believe in - some God, Sol, your ability to scarf down a hundred Little Danny's Snack Cakes - the chapel is your place to go for spiritual counseling. It also offers services such as marriage ceremonies, bee blessings, funerals, and other meaningful rituals."

	tour14
		name = "tour beacon - 'Medbay'"
		location = "tour14"
		codes_txt = "tour;next_tour=tour15;desc=Here at Oshan Laboratory, we truly want the best for our employees' physical and mental wellbeing. That's why our medical personnel consistently rank as the kindest and most competent on Nanotrasen's annual report. Got shrapnel stuck in you? They'll dig it out. In need of better physical facilities? Enjoy robotic limbs and a robotic heart. Need to be cloned after a tragic bible-farting? No problem! Want to pet Morty? They'll even let you scream at him!"

	tour15
		name = "tour beacon - 'Research'"
		location = "tour15"
		codes_txt = "tour;next_tour=tour16;desc=This is the research department. They're all very intense employees, so please disregard any screams or explosions or clouds of green smoke. That's how research gets done, and Oshan Laboratory has a reputation to keep, as one of Nanotrasen's most successful research stations!"

	tour16
		name = "tour beacon - 'Robot Depot'"
		location = "tour16"
		codes_txt = "tour;next_tour=tour17;desc=Oh hey! That's the Robot Depot, home to many station robuddies. We don't have to go in and say hi - I understand that you're rather shy."

	tour17
		name = "tour beacon - 'Data Center'"
		location = "tour17"
		codes_txt = "tour;next_tour=tour18;desc=This is the data center. Phase one of a new venture by Nano - bzZT - a pretty nondescript area for a nondescript name. Move along now!"

	tour18
		name = "tour beacon - 'Engineering'"
		location = "tour18"
		codes_txt = "tour;next_tour=tour19;desc=You probably don't have x-ray vision, but behind this airlock is engineering, the mitochondria of the station. Did you know that Oshan Laboratory was rated as one of Nanotrasen's most efficient stations, and presented with a PTL installation as an award? Our engineers make good use harnessing the thermal energy here in abundance under the sea, and I'm sure they'll make good use of the PTL as well!"

	tour19
		name = "tour beacon - 'Podbay'"
		location = "tour19"
		codes_txt = "tour;next_tour=tour20;desc=The deep sea trench which Oshan Laboratory was constructured around is teeming with new and undiscovered flora and fauna. This public access podbay allows crewmembers to take a pod and explore the area for themselves. I must caution you, however - going alone and without preparation proves quite dangerous!"

	tour20
		name = "tour beacon - 'Escape Shuttle Hallway'"
		location = "tour20"
		codes_txt = "tour;next_tour=tour21;desc=So we have come to the end of our rendezvous. I appreciate you listening to my anecdotes, and hope that you've learned something; perhaps about the station, perhaps about yourself. \nAt the end of every shift, all employees of the station gather here and wait for the emergency shuttle to dock - this is also where we'll part. Take care!"

	tour21
		name = "tour beacon - 'End'"
		location = "tour21"
		codes_txt = "tour;"

/obj/machinery/navbeacon/tour/atlas
	tour0
		name = "tour beacon - 'Arrivals'"
		location = "tour0"
		codes_txt = "tour;next_tour=tour1;desc=Hello and welcome to Nanotrasen's premier stellar cartography vessel, NCS Atlas! My name's Mabel and today I'll be taking you on a tour of all the ship essentials. There's not a huge amount of ground to cover, but stick close!"

	tour1
		name = "tour beacon - 'Cargo'"
		location = "tour1"
		codes_txt = "tour;next_tour=tour2;desc=Our first stop is the cargo bay, where our team of quartermasters can requisition any equipment that you might need to fulfill your role aboard ship. For a fair price, of course!"

	tour2
		name = "tour beacon - 'Engineering'"
		location = "tour2"
		codes_txt = "tour;next_tour=tour3;desc=Down this corridor to our left you'll find the entrance to our engineering wing. Atlas is powered by a conventional thermo-electric generator, watched over by our highly-trained team of engineers, don't be surprised if you bump in to them skulking around the maintenance shafts! The central core of our onboard artificial intelligence is also situated to our right."

	tour3
		name = "tour beacon - 'Teleporter'"
		location = "tour3"
		codes_txt = "tour;next_tour=tour4;desc=Infront of us here is the crew teleporter, if the ship researchers arrange an away mission, you'll muster here to join it! Remember that your personnel life-insurance does not cover you for extra-vehicular activities."

	tour4
		name = "tour beacon - 'Research Lobby'"
		location = "tour4"
		codes_txt = "tour;next_tour=tour5;desc=Over here we have the research wing lobby, just give the fella behind the desk a yell if you encounter any mysterious artifacts for them to investigate or require any exciting chemicals from the chemistry department."

	tour5
		name = "tour beacon - 'Medical Lobby'"
		location = "tour5"
		codes_txt = "tour;next_tour=tour6;desc=Here's one you'll want to remember, the medbay lobby! In your service to Nanotrasen you may find yourself with a mortal wound, debilitating disease or missing limb/organ and these nice folks will be on hand to stitch you back together. I'd recommend you make some friends here!"

	tour6
		name = "tour beacon - 'Cafeteria'"
		location = "tour6"
		codes_txt = "tour;next_tour=tour7;desc=If you find yourself with some downtime, you can visit the mess hall and grab a bite served by our ship chef or sit down at our full-service bar! Remember, no alcoholic beverages before your shift ends!"

	tour7
		name = "tour beacon - 'Cloning'"
		location = "tour7"
		codes_txt = "tour;next_tour=tour8;desc=To the left of us you have the waiting area for our cloning facility! Should a crewman lose their life in service to Nanotrasen, we have the ability to revive them! Or uh, a version of them at least. Try not to ask any prying questions to our cloned personnel. They tend to come out with a few lil memory gaps. Uh. Oh! On the right here is the bathroom! Yeah!"

	tour8
		name = "tour beacon - 'Customs'"
		location = "tour8"
		codes_txt = "tour;next_tour=tour9;desc=Up ahead you'll usually find the Head of Personnel manning their desk at customs. If you require re-assignment or amendments to your ID card's access, here's where to go! There's usually a lot of paperwork involved."

	tour9
		name = "tour beacon - 'Escape'"
		location = "tour9"
		codes_txt = "tour;next_tour=tour10;desc=Up here past the chapel is the escape arm. This one's super important so commit it to memory! If the worst should happen and the captain orders us to abandon ship, a Nanotrasen escape shuttle will dock here to whisk us away to safety! Atlas has never required emergency assistance in it's service history, but strange things can happen when you're out charting deep space."

	tour10
		name = "tour beacon - 'Security'"
		location = "tour10"
		codes_txt = "tour;next_tour=tour11;desc=This is the main desk of our security wing. If you find yourself the victim of a crime or suspect one of your fellow crew may be a turncoat or otherwise criminally incompetent, you'll want to come report them to a security officer to take care of. Stay vigilent, crewman!"

	tour11
		name = "tour beacon - 'Hydroponics'"
		location = "tour11"
		codes_txt = "tour;next_tour=tour12;desc=As we wind down, we're just heading past the hydroponics department, where our friendly botanists tend to the crops that supply the catering department and keep our personnel full and healthy! Please note that Greater Domestic Space Bees are supposed to be that big. No really!"

	tour12
		name = "tour beacon - 'Kitchen'"
		location = "tour12"
		codes_txt = "tour;next_tour=tour13;desc=Here at our last stop, you'll see the kitchen shutters which will open when mealtimes arrive. Make sure you don't miss it! And that's everything! Atlas is a compact stellar cartography ship which requires a minimal compliment to function, we're just pleased as punch that you made the cut and joined us aboard!"

	tour13
		name = "tour beacon - Finish"
		location = "tour13"
		codes_txt = "tour;"

/obj/machinery/navbeacon/tour/neon
	tour0
		name = "tour beacon - 'Arrivals'"
		location = "tour0"
		codes_txt = "tour;next_tour=tour1;desc=Hello and welcome to Nanotrasen's New-ish-est Research Facility on the surface of the planet Abzu. Let's start, shall we? \nThis here is the arrival lounge and cryogenics area. New crewmembers who were placed into stasis on their journey to the planet Abzu will be awakened here."

	tour1
		name = "tour beacon - 'Crew Quarters'"
		location = "tour1"
		codes_txt = "tour;next_tour=tour2;desc=Our first stop on our tour is the luxurious Crew Quarters featuring a spacious restroom facility, quiet resting chamber, and in this main room the lounge space!"

	tour2
		name = "tour beacon - 'Chapel'"
		location = "tour2"
		codes_txt = "tour;next_tour=tour3;desc=Next here we have the Nanotrasen Approved Multifaith and Nondenominational Religious or Nonreligious Chapel! All are welcome here to use this facility for any religious or non-religious ceremony."

	tour3
		name = "tour beacon - 'Engineering'"
		location = "tour3"
		codes_txt = "tour;next_tour=tour4;desc=This stop takes us outside our busy Engineering Department. These busy bees are hard at work ensuring our station is provided with ample power for continued operations."

	tour4
		name = "tour beacon - 'Cargo'"
		location = "tour4"
		codes_txt = "tour;next_tour=tour5;desc=Ah, the Cargo department. What can we say that they aren't using to demand greater pay and independence? They supply our station with lots of supplies and equipment! To the right is also the Pod Bay, Trader Dock, and Escape Shuttle Dock, where you may go in the event of emergencies or crew transfers."

	tour5
		name = "tour beacon - 'Bar'"
		location = "tour5"
		codes_txt = "tour;next_tour=tour6;desc=Oh goodie, the bar and cafeteria. If you find yourself in need of a break or a fine quality meal, this is the place! The chef has only been fined for sanitation related issues twice in the last 24 hours!"

	tour6
		name = "tour beacon - 'Bridge'"
		location = "tour6"
		codes_txt = "tour;next_tour=tour7;desc=The bridge. If Engineering is the beating heart of the station, the bridge is the brain! Commands and operations are dictated here by our fine Command staff. Perhaps if we're lucky we'll see the Captain!"

	tour7
		name = "tour beacon - 'Security'"
		location = "tour7"
		codes_txt = "tour;next_tour=tour8;desc=Wee woo wee woo, here comes Security! The Security staff are hard at work keeping our station safe from all kinds of threats, inside or outside. Don't break the law if you don't want to end up in the Brig!"

	tour8
		name = "tour beacon - 'Hydroponics'"
		location = "tour8"
		codes_txt = "tour;next_tour=tour9;desc=Can you smell that? Smells like something is being grown here. And that something is your food! Our Hydroponics department should be hard at work providing provisions for the Chef to prepare for your meals. Hopefully they're not growing weed..."

	tour9
		name = "tour beacon - 'Research'"
		location = "tour9"
		codes_txt = "tour;next_tour=tour10;desc=Click click clack. Can you hear that? That's the sound of PRODUCTIVITY! Our research staff are working hard to research the future for humanity! Perhaps even going on daring adventures..."

	tour10
		name = "tour beacon - 'Medical'"
		location = "tour10"
		codes_txt = "tour;next_tour=tour11;desc=CLEAR! Medical! If you find yourself ill or otherwise impaired due to adverse conditions, the Medical staff can get you patched up pronto! Medical insurance covered by your Nanotrasen standard employee contract. And if they can't treat your issue..."

	tour11
		name = "tour beacon - 'Cloning'"
		location = "tour11"
		codes_txt = "tour;next_tour=tour12;desc=...You get taken here, to our bleeding edge Cloning facility! Return to life within a matter of minutes!"

	tour12
		name = "tour beacon - '???'"
		location = "tour12"
		codes_txt = "tour;next_tour=tour13;desc= What would you do with a drunken spacer? What would you do with a..."

	tour13
		name = "tour beacon - 'Oh'"
		location = "tour13"
		codes_txt = "tour;next_tour=tour14;desc=Oh. You're still following me? Uhhh. Tour is over. Thank you. Go away."

	tour14
		name = "tour beacon - 'Back2base'"
		location = "tour14"
		codes_txt = "tour;"
