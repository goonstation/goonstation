///Station's transception anrray, used for cargo I/O operations on maps that include one
var/global/obj/machinery/communications_dish/transception/transception_array

//Cost to "kick-start" a transception, charged against area APC in cell units of power
#define ARRAY_STARTCOST 150
//Cost to follow through on the transception, charged against grid in grid units of power
#define ARRAY_TELECOST 2500

/obj/machinery/communications_dish/transception
	name = "Transception Array"
	desc = "Sends and receives both energy and matter over considerable distance. Figuratively, but hopefully not literally, duct-taped together."
	icon = 'icons/obj/machines/transception.dmi'
	icon_state = "array"
	bound_height = 64
	bound_width = 96

	///Whether array permits transception; can be disabled temporarily by anti-overload measures, or toggled manually
	var/primed = TRUE
	///Whether array is currently transceiving
	var/is_transceiving = FALSE
	///Beam overlay
	var/obj/overlay/telebeam

	//Failsafe variables
	var/failsafe_enabled = TRUE
	var/failsafe_active = TRUE

	New()
		. = ..()
		src.telebeam = new /obj/overlay/transception_beam()
		src.vis_contents += telebeam
		src.UpdateIcon()
		if(!transception_array)
			transception_array = src

	power_change()
		. = ..()
		src.UpdateIcon()

	process()
		. = ..()
		if(src.failsafe_active)
			if(src.primed) //don't attempt restart if somehow primed while failsafe is online
				src.failsafe_active = FALSE
			else
				src.attempt_restart()

	///Respond to a pad's inquiry of whether a transception can occur
	proc/can_transceive(var/pad_netnum)
		. = FALSE
		if(src.is_transceiving)
			return
		if(!powered() || !src.primed)
			return
		if(src.failsafe_prompt())
			return
		var/datum/powernet/powernet = src.get_direct_powernet()
		var/netnum = powernet.number
		if(netnum != pad_netnum)
			return
		return TRUE

	///Respond to a pad's request to do a transception
	proc/transceive(var/pad_netnum)
		. = FALSE
		if(src.is_transceiving)
			return
		if(!powered() || !src.primed)
			return
		if(src.failsafe_prompt())
			return
		var/datum/powernet/powernet = src.get_direct_powernet()
		var/netnum = powernet.number
		if(netnum != pad_netnum)
			return
		if(!src.use_area_cell_power(ARRAY_STARTCOST))
			return
		src.is_transceiving = TRUE
		use_power(ARRAY_TELECOST)
		playsound(src.loc, "sound/effects/mag_forcewall.ogg", 50, 0)
		flick("beam",src.telebeam)
		SPAWN_DBG(0.1 SECONDS)
			src.is_transceiving = FALSE
		return TRUE

	///Directly discharge power from the area's cell
	proc/use_area_cell_power(var/use_amount)
		var/obj/machinery/power/apc/AC = get_local_apc(src)
		if (!AC)
			return 0
		var/obj/item/cell/C = AC.cell
		if (!C || C.charge < use_amount)
			return 0
		else
			C.use(use_amount)
			return 1

	///If failsafe mode is active, disable primed status if power grows too low and (to be implemented) notify pad terminals of this failure
	proc/failsafe_prompt() //returns true if error
		var/obj/machinery/power/apc/AC = get_local_apc(src)
		if (!AC)
			return
		if (AC && !AC.cell)
			return
		var/obj/item/cell/C = AC.cell
		var/combined_cost = (0.3 * C.maxcharge) + ARRAY_STARTCOST
		if (C.charge < combined_cost)
			playsound(src.loc, "sound/effects/manta_alarm.ogg", 50, 1)
			src.primed = FALSE
			src.failsafe_active = TRUE
			src.UpdateIcon()
			. = TRUE
		return

	///Primed status restarts when power is sufficiently restored
	proc/attempt_restart()
		var/obj/machinery/power/apc/AC = get_local_apc(src)
		if (!AC)
			return
		if (AC && !AC.cell)
			return
		var/obj/item/cell/C = AC.cell
		var/combined_cost = (0.4 * C.maxcharge) + ARRAY_STARTCOST
		if (C.charge > combined_cost)
			playsound(src.loc, "sound/machines/shieldgen_startup.ogg", 50, 1)
			src.primed = TRUE
			src.failsafe_active = FALSE
			src.UpdateIcon()
			. = TRUE
		return

	ex_act(severity) //tbi: damage and repair
		return

#undef ARRAY_TELECOST

/obj/machinery/communications_dish/transception/update_icon()
	if(powered())
		var/primed_state = "allquiet"
		if(src.primed)
			primed_state = "glow_primed"

		var/image/glowy = SafeGetOverlayImage("glows", 'icons/obj/machines/transception.dmi', "glow_online")
		glowy.plane = PLANE_ABOVE_LIGHTING
		UpdateOverlays(glowy, "glows", 0, 1)

		var/image/primer = SafeGetOverlayImage("primed", 'icons/obj/machines/transception.dmi', primed_state)
		primer.plane = PLANE_ABOVE_LIGHTING
		UpdateOverlays(primer, "primed", 0, 1)
	else
		ClearAllOverlays()

/obj/overlay/transception_beam
	icon = 'icons/obj/machines/transception.dmi'
	icon_state = "allquiet"
	plane = PLANE_ABOVE_LIGHTING
	mouse_opacity = 0

/obj/machinery/transception_pad
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "neopad"
	name = "\proper transception pad"
	anchored = 1
	density = 0
	layer = FLOOR_EQUIP_LAYER1
	mats = list("MET-2"=5,"CON-2"=2,"CON-1"=5)
	desc = "A sophisticated cargo pad capable of utilizing the station's transception antenna when connected by cable. Keep clear during operation."
	var/is_transceiving = FALSE
	var/frequency = FREQ_TRANSCEPTION_SYS
	var/net_id
	///Used for clarity in transception interlink computer
	var/pad_id = null

	New()
		src.net_id = generate_net_id(src)
		MAKE_DEFAULT_RADIO_PACKET_COMPONENT(null, src.frequency)
		src.pad_id = "[pick(vowels_upper)][prob(20) ? pick(consonants_upper) : rand(0,9)]-[rand(0,9)][rand(0,9)][rand(0,9)]"
		src.name = "transception pad [pad_id]"
		..()

	receive_signal(datum/signal/signal)
		if(status & NOPOWER)
			return

		if(!signal || signal.encryption || !signal.data["sender"])
			return

		var/sender = signal.data["sender"]
		if(!sender)
			return

		switch(signal.data["address_1"])
			if("ping")
				var/area/where_pad_is = get_area(src)
				var/name_of_place = where_pad_is.name ? where_pad_is.name : "UNKNOWN"
				var/datum/signal/reply = new
				reply.data["address_1"] = sender
				reply.data["command"] = "ping_reply"
				reply.data["device"] = "PNET_TRANSC_PAD"
				reply.data["netid"] = src.net_id
				reply.data["data"] = name_of_place
				reply.data["padid"] = src.pad_id
				reply.data["opstat"] = src.check_transceive()
				SPAWN_DBG(0.5 SECONDS)
					src.post_signal(reply)
			else
				if(signal.data["address_1"] != src.net_id) //this is dumb redundant
					return
				var/sigcommand = lowertext(signal.data["command"])
				switch(sigcommand)
					if("send")
						src.attempt_transceive()
					if("receive")
						var/sigindex = signal.data["data"]
						if(isnum_safe(sigindex))
							src.attempt_transceive(sigindex)
		return

	proc/post_signal(datum/signal/signal,var/newfreq)
		if(!signal)
			return
		var/freq = newfreq
		if(!freq)
			freq = src.frequency

		signal.source = src
		signal.data["sender"] = src.net_id

		SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, signal, 20, freq)

	///Polls to see if transception connection is online
	proc/check_transceive()
		. = FALSE
		if(!transception_array)
			return
		var/datum/powernet/powernet = src.get_direct_powernet()
		if(!powernet)
			return
		var/netnum = powernet.number
		if(transception_array.can_transceive(netnum) == FALSE)
			return
		return TRUE

	///Attempts to perform a transception operation; receive if it was passed an index for pending inbound cargo, send otherwise
	proc/attempt_transceive(var/cargo_index = null)
		if(src.is_transceiving)
			return
		if(!transception_array)
			return
		var/datum/powernet/powernet = src.get_direct_powernet()
		if(!powernet)
			return
		var/netnum = powernet.number
		if(transception_array.can_transceive(netnum) == FALSE)
			return
		if(cargo_index != null)
			if(shippingmarket.pending_crates[cargo_index])
				var/obj/inbound_target = shippingmarket.pending_crates[cargo_index]
				receive_a_thing(netnum,inbound_target)
			else
				return
		else
			send_a_thing(netnum)
		return

	proc/send_a_thing(var/netnumber)
		src.is_transceiving = TRUE
		playsound(src.loc, "sound/effects/ship_alert_minor.ogg", 50, 0) //incoming cargo warning (stand clear)
		SPAWN_DBG(2 SECONDS)
			flick("neopad_activate",src)
			SPAWN_DBG(0.3 SECONDS)
				var/atom/movable/thing2send
				var/list/oofed_nerds = list()
				for(var/atom/movable/O as obj|mob in src.loc)
					if(O.anchored) continue
					if(O == src) continue
					if(istype(O,/mob)) //no mobs
						if(istype(O,/mob/living/carbon/human) && prob(15))
							oofed_nerds += O
						continue
					if(istype(O,/obj/storage/crate))
						thing2send = O
						break //only one thing at a time!

				if(thing2send && transception_array.transceive(netnumber))
					for(var/nerd in oofed_nerds)
						telefrag(nerd) //did I mention NO MOBS
					thing2send.loc = src
					SPAWN_DBG(1 SECOND)
						shippingmarket.sell_crate(thing2send)

					showswirl(src.loc)
					use_power(200) //most cost is at the array
				src.is_transceiving = FALSE

		return

	proc/receive_a_thing(var/netnumber,var/atom/movable/thing2get)
		src.is_transceiving = TRUE
		if(thing2get in shippingmarket.pending_crates)
			shippingmarket.pending_crates.Remove(thing2get)
		playsound(src.loc, "sound/effects/ship_alert_minor.ogg", 50, 0) //incoming cargo warning (stand clear)
		SPAWN_DBG(2 SECONDS)
			flick("neopad_activate",src)
			SPAWN_DBG(0.4 SECONDS)
				if(transception_array.transceive(netnumber))
					for(var/atom/movable/O as mob in src.loc)
						if(istype(O,/mob/living/carbon/human) && prob(15))
							telefrag(O) //get out the way
					thing2get.loc = src.loc

					showswirl(src.loc)
					use_power(200) //most cost is at the array
				src.is_transceiving = FALSE

		return

	///Standing on the pad while it's trying to transport cargo is an extremely dumb idea, prepare to get owned
	proc/telefrag(var/mob/living/carbon/human/M)
		var/dethflavor = pick("suddenly vanishes","tears off in the teleport stream","disappears in a flash","violently disintegrates")

		switch(rand(1,4))
			if(1)
				if(M.limbs.l_arm)
					M.limbs.l_arm.delete()
					M.visible_message("<span class='alert'><B>[M]</B>'s arm [dethflavor]!</span>")
			if(2)
				if(M.limbs.r_arm)
					M.limbs.r_arm.delete()
					M.visible_message("<span class='alert'><B>[M]</B>'s arm [dethflavor]!</span>")
			if(3)
				if(M.limbs.l_leg)
					M.limbs.l_leg.delete()
					M.visible_message("<span class='alert'><B>[M]</B>'s leg [dethflavor]!</span>")
			if(4)
				if(M.limbs.r_leg)
					M.limbs.r_leg.delete()
					M.visible_message("<span class='alert'><B>[M]</B>'s leg [dethflavor]!</span>")

		playsound(M.loc, "sound/impact_sounds/Flesh_Tear_2.ogg", 75)
		M.emote("scream")
		M.changeStatus("stunned", 5 SECONDS)
		M.changeStatus("weakened", 5 SECONDS)


/obj/machinery/computer/transception
	name = "\improper Transception Interlink"
	desc = "A console capable of remotely connecting to and operating cargo transception pads."
	icon = 'icons/obj/computer.dmi'
	icon_state = "QMpad"
	req_access = list(access_cargo)
	circuit_type = /obj/item/circuitboard/transception
	object_flags = CAN_REPROGRAM_ACCESS
	frequency = FREQ_TRANSCEPTION_SYS
	var/net_id
	var/last_ping = 0
	var/temp = null
	///list of transception pads known to the interlink
	var/list/known_pads = list()
	///formatted version of above pad list
	var/formatted_list = null
	///thing to avoid having to update the list every time you click the window
	var/list_is_updated = FALSE
	///variable to queue dialog update after list is refreshed
	var/queue_dialog_update = FALSE

	light_r = 1
	light_g = 0.9
	light_b = 0.7

	New()
		..()
		if(prob(1))
			desc = "A console capable of remotely connecting to and operating cargo transception pads. Smells faintly of cilantro."
		src.net_id = generate_net_id(src)
		MAKE_DEFAULT_RADIO_PACKET_COMPONENT(null, src.frequency)

	receive_signal(datum/signal/signal)
		if(status & NOPOWER)
			return

		if(!signal || signal.encryption || !signal.data["sender"])
			return

		var/sender = signal.data["sender"]

		if(sender)
			switch(signal.data["command"])
				if("ping_reply")
					if(signal.data["device"] != "PNET_TRANSC_PAD")
						return
					src.list_is_updated = FALSE
					var/device_netid = "DEV_[signal.data["netid"]]" //stored like this so it overwrites existing entries for partial refreshes
					var/list/manifest = new()
					manifest["Identifier"] = signal.data["padid"]
					manifest["INT_TARGETID"] = signal.data["netid"]
					manifest["Location"] = signal.data["data"]
					manifest["Array Connection"] = signal.data["opstat"] ? "OK" : "ERR"
					src.known_pads[device_netid] = manifest
					src.queue_dialog_update = TRUE
		return

	process()
		..()
		if(src.queue_dialog_update)
			src.updateUsrDialog()
			src.queue_dialog_update = FALSE

	//construct command packet to send out; specify cargo index for receive, otherwise defaults to send
	proc/build_command(var/com_target,var/cargo_index)
		if(com_target)
			var/datum/signal/yell = new
			yell.data["address_1"] = com_target
			if(cargo_index)
				yell.data["command"] = "receive"
				yell.data["data"] = cargo_index
			else
				yell.data["command"] = "send"
			SPAWN_DBG(0.5 SECONDS)
				src.post_signal(yell)
		return

	proc/try_pad_ping()
		if( (last_ping && ((last_ping + 10) >= world.time) ) || !src.net_id)
			return 1

		src.known_pads.Cut()
		src.list_is_updated = FALSE

		last_ping = world.time
		var/datum/signal/newsignal = get_free_signal()
		newsignal.data["address_1"] = "ping"
		newsignal.data["sender"] = src.net_id
		newsignal.source = src
		src.post_signal(newsignal)

	proc/post_signal(datum/signal/signal,var/newfreq)
		if(!signal)
			return
		var/freq = newfreq
		if(!freq)
			freq = src.frequency

		signal.source = src
		signal.data["sender"] = src.net_id

		SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, signal, 20, freq)

/obj/machinery/computer/transception/attack_hand(var/mob/user as mob)
	if(!src.allowed(user))
		boutput(user, "<span class='alert'>Access Denied.</span>")
		return

	if(..())
		return

	src.add_dialog(user)
	var/HTML

	var/header_thing_chui_toggle = (user.client && !user.client.use_chui) ? {"
		<style type='text/css'>
			body {
				font-family: Verdana, sans-serif;
				background: #222228;
				color: #ddd;
				text-align: center;
				}
			strong {
				color: #fff;
				}
			a {
				color: #6ce;
				text-decoration: none;
				}
			a:hover, a:active {
				color: #cff;
				}
			img, a img {
				border: 0;
				}
		</style>
	"} : {"
	<style type='text/css'>
		/* when chui is on apparently do nothing, cargo cult moment */
	</style>
	"}

	HTML += {"
	[header_thing_chui_toggle]
	<title>Transception Interlink</title>
	<style type="text/css">
		h1, h2, h3, h4, h5, h6 {
			margin: 0.2em 0;
			background: #111520;
			text-align: center;
			padding: 0.2em;
			border-top: 1px solid #456;
			border-bottom: 1px solid #456;
		}

		h2 { font-size: 130%; }
		h3 { font-size: 110%; margin-top: 1em; }
	</style>"}

	src.build_formatted_list()
	if (src.formatted_list)
		HTML += src.formatted_list

	user.Browse(HTML, "window=transception_\ref[src];title=Transception Interlink;size=350x550;")
	onclose(user, "transception_\ref[src]")
	return

/obj/machinery/computer/transception/proc/build_formatted_list()
	if(src.list_is_updated) return
	var/rollingtext = "<h2>Connected Pads <A href='[topicLink("ping")]'>(Ping)</A></h2>" //ongoing contents chunk, begun with head bit

	if(!length(src.known_pads))
		rollingtext += "NO DEVICES DETECTED<br>"
		rollingtext += "Please Use Refresh Ping,<br>"
		rollingtext += "Then Wait For Reply"
	else
		rollingtext += "Receive command will pick from<br>"
		rollingtext += "pending cargo, or immediately import<br>"
		rollingtext += "if pending cargo is label-identical.<br><br>"

	for (var/device_index in src.known_pads)
		var/minitext = ""
		var/list/manifest = known_pads[device_index]
		for(var/field in manifest)
			if(field != "INT_TARGETID")
				minitext += "<strong>[field]</strong> &middot; [manifest[field]]<br>"
		rollingtext += minitext
		rollingtext += "<A href='[topicLink("send","\ref[device_index]")]'>Send</A> | "
		rollingtext += "<A href='[topicLink("receive","\ref[device_index]")]'>Receive</A><br><br>"

	src.formatted_list = rollingtext
	src.list_is_updated = TRUE
	return

//aa ee oo
/obj/machinery/computer/transception/proc/topicLink(action, subaction, var/list/extra)
	return "?src=\ref[src]&action=[action][subaction ? "&subaction=[subaction]" : ""]&[extra && islist(extra) ? list2params(extra) : ""]"

/obj/machinery/computer/transception/Topic(href, href_list)
	if(..())
		return

	var/subaction = (href_list["subaction"] ? href_list["subaction"] : null)

	switch (href_list["action"])
		if ("ping")
			src.try_pad_ping()

		if ("receive")
			var/manifest_identifier = locate(subaction) in src.known_pads
			var/list/manifest = known_pads[manifest_identifier]
			if(manifest["Identifier"])
				var/wanted_thing = input(usr,"! WORK IN PROGRESS !","Select Cargo",null) in shippingmarket.pending_crates
				var/thingpos = shippingmarket.pending_crates.Find(wanted_thing)
				if(thingpos)
					src.build_command(manifest["INT_TARGETID"],thingpos)

		if ("send")
			var/manifest_identifier = locate(subaction) in src.known_pads
			var/list/manifest = known_pads[manifest_identifier]
			if(manifest["Identifier"])
				src.build_command(manifest["INT_TARGETID"])

	src.add_fingerprint(usr)
	return
