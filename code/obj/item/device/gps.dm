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
	flags = FPRINT | TABLEPASS | CONDUCT
	w_class = W_CLASS_SMALL
	m_amt = 50
	g_amt = 100
	var/frequency = FREQ_GPS
	var/net_id

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
		return

	proc/show_HTML(var/mob/user)
		if (!user)
			return
		src.add_dialog(user)
		var/list/HTML = list({"<style type="text/css">
		.desc {
			background: #21272C;
			width: calc(100% - 5px);
			padding: 2px;
		}
		.buttons a {
			display: inline-flex;
			background: #58B4DC;
			width: calc(50% - 7px);
			text-transform: uppercase;
			text-decoration: none;
			color: #fff;
			margin: 1px;
			padding: 2px 0 2px 5px;
			font-size: 11px;
		}
		.buttons.refresh a {
			padding: 1px 0 1px 5px;
			width: calc(100% - 7px);
		}
		.buttons a:hover {
			background: #6BC7E8;
		}
		.buttons.gps a {
			display: block;
			width: calc(100% - 7px);
  			text-transform: none;
			border-top: 1px solid #58B4DC;
			background: #21272C;
			padding: 3px;
			margin: 0 0 1px 0;
			font-size: 11px;
		}
		.buttons.gps.distress a {
			border-top: 2px solid #BE3737;
			background: #2C2121;
		}
		.gps.group {
			background: #58B4DC;
			margin: 0;
			font-size: 12px;
		}
		</style>"})
		HTML += build_html_gps_form(src, FALSE, src.tracking_target)
		HTML += "<div><div class='buttons refresh'><A href='byond://?src=\ref[src];refresh=6'>(Refresh)</A></div>"
		HTML += "<div class='desc'>Each GPS is coined with a unique four digit number followed by a four letter identifier.<br>This GPS is assigned <b>[serial]-[identifier]</b>.</div><hr>"
		HTML += "<HR>"
		if (allowtrack == 0)
			HTML += "<A href='byond://?src=\ref[src];track1=2'>Enable Tracking</A> | "
		if (allowtrack == 1)
			HTML += "<A href='byond://?src=\ref[src];track2=3'>Disable Tracking</A> | "
		HTML += "<A href='byond://?src=\ref[src];changeid=4'>Change Identifier</A> | "
		HTML += "<A href='byond://?src=\ref[src];help=5'>Toggle Distress Signal</A></div>"
		HTML += "<hr>"

		HTML += "<div class='gps group'><b>GPS Units</b></div>"
		for_by_tcl(G, /obj/item/device/gps)
			LAGCHECK(LAG_LOW)
			if (G.allowtrack == 1)
				var/turf/T = get_turf(G.loc)
				if (!T)
					continue
				var/name = "[G.serial]-[G.identifier]"
				HTML += "<div class='buttons gps [G.distress ? "distress" : ""]'><A href='byond://?src=\ref[src];dest_cords=1;x=[T.x];y=[T.y];z=[T.z];name=[name]'><span><b>[name]</b>"
				HTML += "<span style='font-size:85%;float:right'>[G.distress ? "<font color=\"red\">(DISTRESS)</font>" : "<font color=666666>(DISTRESS)</font>"]</span><br>"
				HTML += "Located at: [T.x], [T.y]<span style='float:right'>[src.get_z_info(T)]</span></span></A></div>"

		HTML += "<div class='gps group'><b>Tracking Implants</b></div>"
		for_by_tcl(imp, /obj/item/implant/tracking)
			LAGCHECK(LAG_LOW)
			if (isliving(imp.loc))
				var/turf/T = get_turf(imp.loc)
				if (!T)
					continue
				HTML += "<div class='buttons gps'><A href='byond://?src=\ref[src];dest_cords=1;x=[T.x];y=[T.y];z=[T.z];name=[imp.loc.name]'><span><b>[imp.loc.name]</b><br><span>located at: [T.x], [T.y]</span><span style='float: right'>[src.get_z_info(T)]</span></span></A></div>"
		HTML += "<hr>"

		HTML += "<div class='gps group'><b>Beacons</b></div>"
		for (var/obj/B in by_type[/obj/warp_beacon])
			var/turf/T = get_turf(B.loc)
			HTML += "<div class='buttons gps'><A href='byond://?src=\ref[src];dest_cords=1;x=[T.x];y=[T.y];z=[T.z];name=[B.name]'><span><b>[B.name]</b><br><span>located at: [T.x], [T.y]</span><span style='float: right'>[src.get_z_info(T)]</span></span></A></div>"
		HTML += "<br></div>"

		user.Browse(HTML.Join(), "window=gps_[src];title=GPS;size=400x540;override_setting=1")
		onclose(user, "gps")

	attack_ai(mob/user)
		. = ..()
		src.show_HTML(user)

	attack_self(mob/user as mob)
		if ((user.contents.Find(src) || user.contents.Find(src.master) || BOUNDS_DIST(src, user) == 0))
			src.show_HTML(user)
		else
			user.Browse(null, "window=gps_[src]")
			src.remove_dialog(user)
		return

	Topic(href, href_list)
		..()
		if (usr.stat || usr.restrained() || usr.lying)
			return
		if (usr.contents.Find(src) || usr.contents.Find(src.master) || in_interact_range(src, usr) || issilicon(usr) || isAIeye(usr))
			src.add_dialog(usr)
			var/turf/T = get_turf(usr)
			if(href_list["getcords"])
				boutput(usr, "<span class='notice'>Located at: <b>X</b>: [T.x], <b>Y</b>: [T.y]</span>")
				return

			if(href_list["track1"])
				boutput(usr, "<span class='notice'>Tracking enabled.</span>")
				src.allowtrack = 1
			if(href_list["track2"])
				boutput(usr, "<span class='notice'>Tracking disabled.</span>")
				src.allowtrack = 0
			if(href_list["changeid"])
				var/t = strip_html(input(usr, "Enter new GPS identification name (must be 4 characters)", src.identifier) as text)
				if(length(t) > 4)
					boutput(usr, "<span class='alert'>Input too long.</span>")
					return
				if(length(t) < 4)
					boutput(usr, "<span class='alert'>Input too short.</span>")
					return
				if(!t)
					return
				src.identifier = t
				logTheThing(LOG_STATION, usr, "sets a GPS identification name to [t].")
			if(href_list["help"])
				if(!distress)
					boutput(usr, "<span class='alert'>Sending distress signal.</span>")
					distress = 1
					src.send_distress_signal(distress)
				else
					distress = 0
					boutput(usr, "<span class='alert'>Distress signal cleared.</span>")
					src.send_distress_signal(distress)
			if(href_list["refresh"])
				..()

			if(href_list["dest_cords"])
				obtain_target_from_coords(href_list)
			if(href_list["stop_tracking"])
				tracking_target = null
				active = null
				icon_state = "gps-off"

			var/obj/item/target = src.master || src
			target.updateSelfDialog()
			//we want this to do self dialog updates UNLESS the user is a silicon in which case we do regular updates
			for (var/client/client in src.clients_operating)
				var/mob/user = client.mob
				if (issilicon(user) || isAIeye(user))
					target.attack_ai(user)
			src.add_fingerprint(usr)
		else
			usr.Browse(null, "window=gps_[src]")
			return
		return


	New()
		..()
		serial = rand(4201,7999)
		START_TRACKING
		src.net_id = generate_net_id(src)
		MAKE_DEFAULT_RADIO_PACKET_COMPONENT(null, frequency)

	get_desc(dist, mob/user)
		. = "<br>Its serial code is [src.serial]-[identifier]."
		if (dist > 2)
			return
		. += "<br>There's a sticker on the back saying \"Net Identifier: [net_id]\" on it."

	proc/obtain_target_from_coords(href_list)
		if (href_list["dest_cords"])
			tracking_target = null
			var/x = text2num_safe(href_list["x"])
			var/y = text2num_safe(href_list["y"])
			if (!x || !y)
				boutput(usr, "<span class='alert'>Bad Topc call, if you see this something has gone wrong. And it's probably YOUR FAULT!</span>")
				return
			// This is to get a turf with the specified coordinates on the same Z as the device
			var/turf/T = get_turf(src) //bugfix for this not working when src was in containers
			var/z = T.z


			T = locate(x,y,z)
			//Set located turf to be the tracking_target
			if (isturf(T))
				src.tracking_target = T
				boutput(usr, "<span class='notice'>Now tracking: <b>[href_list["name"]]</b> at <b>X</b>: [T.x], <b>Y</b>: [T.y]</span>")

				begin_tracking()
			else
				boutput(usr, "<span class='alert'>Invalid GPS coordinates.</span>")
		sleep(1 SECOND)

	proc/begin_tracking()
		if(!active)
			if (!src.tracking_target)
				usr.show_text("No target specified, cannot activate the pinpointer.", "red")
				return
			active = 1
			process()
			boutput(usr, "<span class='notice'>You activate the gps.</span>")

	proc/send_distress_signal(distress)
		var/distressAlert = distress ? "help" : "clear"
		var/turf/T = get_turf(usr)
		var/datum/signal/reply = get_free_signal()
		reply.source = src
		reply.data["sender"] = src.net_id
		reply.data["identifier"] = "[src.serial]-[src.identifier]"
		reply.data["coords"] = "[T.x],[T.y]"
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
					reply.data["coords"] = "[T.x],[T.y]"
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
