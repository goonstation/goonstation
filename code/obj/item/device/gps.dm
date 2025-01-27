TYPEINFO(/obj/item/device/gps)
	mats = 2

/obj/item/device/gps
	name = "space GPS"
	desc = "A navigation device that can tell you your position, and the position of other GPS devices. Uses coordinate beacons."
	icon_state = "gps-off"
	item_state = "electronic"
	var/allowtrack = 1 // defaults to on so people know where you are (sort of!)
	var/serial = "4200" // shouldnt show up as this
	var/identifier = "NT13" // four characters max plz
	var/distress = 0
	var/active = 0		//probably should
	var/atom/tracking_target = null		//unafilliated with allowtrack, which essentially just lets your gps appear on other gps lists
	flags = TABLEPASS | CONDUCT
	w_class = W_CLASS_SMALL
	m_amt = 50
	g_amt = 100
	var/frequency = FREQ_GPS
	var/net_id
	var/wrenched_in = FALSE //! is this wrenched in a cabinet frame?

	var/tracking_string
	var/list/gps_devices = list()
	var/list/gps_names = list()
	var/list/gps_coords = list()
	var/list/gps_distress = list()
	var/list/imps = list()
	var/list/imp_names = list()
	var/list/imp_coords = list()
	var/list/warp_beacons = list()
	var/list/warp_names = list()
	var/list/warp_coords = list()
	var/list/gps_refs = list()

	proc/get_z_info(var/turf/T)
		. =  "Landmark: Unknown"
		if (!T)
			return
		if (!istype(T))
			T = get_turf(T)
		if (!T)
			return
		if (T.z == 1)
			. = "Landmark: [capitalize(station_or_ship())]"
/*			if (ismap("DESTINY"))
				. =  "Landmark: NSS Destiny"
			else if (ismap("CLARION"))
				. =  "Landmark: NSS Clarion"
			else
				. =  "Landmark: Station"
*/
		else if (T.z == 2)
			. =  "Landmark: Restricted"
		else if (T.z == 3)
			. =  "Landmark: Debris Field"
		else if (T.z == 5)
			#ifdef UNDERWATER_MAP
			. =  "Landmark: Trench"
			#else
			. =  "Landmark: Asteroid Field"
			#endif

	proc/get_gps_info()
		gps_refs = list()

		gps_devices = list()
		gps_names = list()
		gps_coords = list()
		gps_distress = list()
		for_by_tcl(G, /obj/item/device/gps)
			if (!G.allowtrack)
				continue
			var/turf/T = get_turf(G.loc)
			if (!T)
				continue
			gps_devices += G
			gps_refs += "\ref[G]"
			gps_names += "[G.serial]-[G.identifier]"
			gps_coords += "Located at: [T.x], [T.y] | [src.get_z_info(T)]"
			gps_distress += !!G.distress

		imps = list()
		imp_names = list()
		imp_coords = list()
		for_by_tcl(imp, /obj/item/implant/tracking)
			if (!isliving(imp.loc))
				continue
			var/turf/T = get_turf(imp.loc)
			if (!T)
				continue
			imps += imp
			gps_refs += "\ref[imp]"
			imp_names += imp.loc.name
			imp_coords += "Located at: [T.x], [T.y] | [src.get_z_info(T)]"

		warp_beacons = list()
		warp_names = list()
		warp_coords = list()
		for (var/obj/B in by_type[/obj/warp_beacon])
			var/turf/T = get_turf(B.loc)
			warp_beacons += B
			gps_refs += "\ref[B]"
			warp_names += B.name
			warp_coords += "Located at: [T.x], [T.y] | [src.get_z_info(T)]"

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if (!ui)
			ui = new(user, src, "GPS")
			ui.open()

	ui_data(mob/user)
		var/turf/T = get_turf(src)
		src.get_gps_info()
		. = list(
			"src_x" = T.x,
			"src_y" = T.y,
			"tracking" = src.tracking_string,
			"trackable" = src.allowtrack,
			"src_name" = "[src.serial]-[src.identifier]",
			"distress" = src.distress,
			"gps_names" = src.gps_names,
			"gps_coords" = src.gps_coords,
			"gps_distress" = src.gps_distress,
			"imp_names" = src.imp_names,
			"imp_coords" = src.imp_coords,
			"warp_names" = src.warp_names,
			"warp_coords" = src.warp_coords,
			"gps_refs" = src.gps_refs
		)

	ui_act(action, params)
		. = ..()
		if (.)
			return
		. = TRUE
		switch (action)
			if ("toggle_trackable")
				src.allowtrack = !src.allowtrack
			if ("toggle_distress")
				src.distress = !src.distress
				src.send_distress_signal(src.distress)
			if ("change_identifier")
				var/t = strip_html(tgui_input_text(usr, "Enter new GPS identification name (must be 4 characters)", src.identifier))
				if(length(t) > 4)
					boutput(usr, SPAN_ALERT("Input too long."))
					return
				if(length(t) < 4)
					boutput(usr, SPAN_ALERT("Input too short."))
					return
				if(!t)
					return
				src.identifier = t
				logTheThing(LOG_STATION, usr, "sets a GPS identification name to [t].")
			if ("track_gps")
				if ("gps_ref" in params)
					var/gps_ref = params["gps_ref"]
					var/atom/A
					for (var/atom/atom as anything in (src.gps_devices + src.imps + src.warp_beacons))
						if ("\ref[atom]" == gps_ref)
							A = atom
							break
					src.track_turf(get_turf(A))
				else if (src.tracking_target)
					src.tracking_target = null
					src.active = null
					src.icon_state = "gps-off"
					src.tracking_string = null
				else
					var/target_x = tgui_input_number(usr, "Select x of target:", "Coordinate Entry", 1, world.maxx, 1)
					if (!target_x)
						return
					var/target_y = tgui_input_number(usr, "Select y of target:", "Coordinate Entry", 1, world.maxy, 1)
					if (!target_y)
						return
					var/turf/T = get_turf(src)
					src.track_turf(locate(target_x, target_y, T.z))

	proc/track_turf(turf/target_turf)
		// This is to get a turf with the specified coordinates on the same Z as the device
		var/turf/T = get_turf(src) //bugfix for this not working when src was in containers
		T = locate(target_turf.x, target_turf.y, T.z)
		//Set located turf to be the tracking_target
		if (!isturf(T))
			return
		src.tracking_target = T
		src.active = TRUE
		src.tracking_string = "([T.x], [T.y])"
		process()

	attack_hand(mob/user)
		if(src.wrenched_in) return
		..()

	attackby(obj/item/used_tool, mob/user)
		if(iswrenchingtool(used_tool))
			if(src.wrenched_in)
				boutput(user, "You detach the [src] from the housing.")
				logTheThing(LOG_STATION, user, "detaches a <b>[src]</b> from the housing at [log_loc(src)].")
				src.wrenched_in = FALSE
				src.anchored = UNANCHORED
				return

			else
				if(istype(src.stored?.linked_item,/obj/item/storage/mechanics))
					boutput(user, "You attach the [src] to the housing.")
					logTheThing(LOG_STATION, user, "attaches a <b>[src]</b> to the housing  at [log_loc(src)].")
					src.wrenched_in = TRUE
					src.anchored = ANCHORED
					return
		..()

	attack_self(mob/user as mob)
		src.ui_interact(user)

	New()
		..()
		serial = rand(4201,7999)
		START_TRACKING
		src.net_id = generate_net_id(src)
		MAKE_DEFAULT_RADIO_PACKET_COMPONENT(src.net_id, null, frequency)

	get_desc(dist, mob/user)
		. = "<br>Its serial code is [src.serial]-[identifier]."
		if (dist > 2)
			return
		. += "<br>There's a sticker on the back saying \"Net Identifier: [net_id]\" on it."

	proc/send_distress_signal(distress)
		var/distressAlert = distress ? "help" : "clear"
		var/turf/T = get_turf(usr)
		var/datum/signal/reply = get_free_signal()
		reply.source = src
		reply.data["sender"] = src.net_id
		reply.data["identifier"] = "[src.serial]-[src.identifier]"
		reply.data["x"] = "[T.x]"
		reply.data["y"] = "[T.y]"
		reply.data["location"] = "[src.get_z_info(T)]"
		reply.data["distress_alert"] = "[distressAlert]"
		SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, reply)

	process()
		if(!active || !tracking_target)
			active = 0
			icon_state = "gps-off"
			return

		src.set_dir(get_dir(src,tracking_target))
		if (GET_DIST(src,tracking_target) == 0)
			icon_state = "gps-direct"
		else
			icon_state = "gps"

		SPAWN(0.5 SECONDS) .()

	disposing()
		STOP_TRACKING
		..()

	receive_signal(datum/signal/signal)
		if(!signal || signal.encryption)
			return

		var/sender = signal.data["sender"]

		if (lowertext(signal.data["distress_alert"]))
			var/senderName = strip_html(signal.data["identifier"])
			if (!senderName)
				return
			if (lowertext(signal.data["distress_alert"] == "help"))
				src.visible_message("<b>[bicon(src)] [src]</b> beeps, \"NOTICE: Distress signal received from GPS [senderName].\".")
			else if (lowertext(signal.data["distress_alert"] == "clear"))
				src.visible_message("<b>[bicon(src)] [src]</b> beeps, \"NOTICE: Distress signal cleared by GPS [senderName].\".")
			return
		else if (!signal.data["sender"])
			return
		else if (signal.data["address_1"] == src.net_id && src.allowtrack)
			var/datum/signal/reply = get_free_signal()
			reply.source = src
			reply.data["sender"] = src.net_id
			reply.data["address_1"] = sender
			switch (lowertext(signal.data["command"]))
				if ("help")
					if (!signal.data["topic"])
						reply.data["description"] = "GPS unit - Provides space-coordinates and transmits distress signals"
						reply.data["topics"] = "status"
					else
						reply.data["topic"] = signal.data["topic"]
						switch (lowertext(signal.data["topic"]))
							if ("status")
								reply.data["description"] = "Returns the status of the GPS unit, including identifier, coords, location, and distress status. Does not require any arguments"
							else
								reply.data["topic"] = signal.data["topic"]
								reply.data["description"] = "ERROR: UNKNOWN TOPIC"
				if ("status")
					var/turf/T = get_turf(src)
					reply.data["identifier"] = "[src.serial]-[src.identifier]"
					reply.data["x"] = "[T.x]"
					reply.data["y"] = "[T.y]"
					reply.data["location"] = "[src.get_z_info(T)]"
					reply.data["distress"] = "[src.distress]"
				else
					return //COMMAND NOT RECOGNIZED
			SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, reply)

		else if (lowertext(signal.data["address_1"]) == "ping" && src.allowtrack)
			var/datum/signal/pingsignal = get_free_signal()
			pingsignal.source = src
			pingsignal.data["device"] = "WNET_GPS"
			pingsignal.data["netid"] = src.net_id
			pingsignal.data["address_1"] = sender
			pingsignal.data["command"] = "ping_reply"
			pingsignal.data["data"] = "[src.serial]-[src.identifier]"
			pingsignal.data["distress"] = "[src.distress]"

			SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, pingsignal)
