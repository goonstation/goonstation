///Station's transception anrray, used for cargo I/O operations on maps that include one
var/global/obj/machinery/communications_dish/transception/transception_array

//Cost to "kick-start" a transception, charged against area APC in cell units of power
#define ARRAY_STARTCOST 80
//Cost to follow through on the transception, charged against grid in grid units of power
#define ARRAY_TELECOST 2500

//Alert codes
#define TRANSCEIVE_BUSY 0
#define TRANSCEIVE_NOPOWER 1
#define TRANSCEIVE_POWERWARN 2
#define TRANSCEIVE_NOWIRE 3
#define TRANSCEIVE_OK 4

//Delay after a successful transception before another one may begin
#define TRANSCEPTION_COOLDOWN 0.1

/obj/machinery/communications_dish/transception
	name = "Transception Array"
	desc = "Sends and receives both energy and matter over a considerable distance. Questionably safe."
	icon = 'icons/obj/machines/transception.dmi'
	icon_state = "array"
	bound_height = 64
	bound_width = 96
	mats = 0

	///Whether array permits transception; can be disabled temporarily by anti-overload measures, or toggled manually
	var/primed = TRUE
	///Whether array is currently transceiving
	var/is_transceiving = FALSE
	///Beam overlay
	var/obj/overlay/telebeam

	///Determines if failsafe threshold is equipment power threshold plus transception cost (true) or transception cost (false).
	var/equipment_failsafe = TRUE
	///While failsafe is active, communications capability is retained but cargo transception is unavailable. Prompts attempt_restart periodically.
	var/failsafe_active = FALSE

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
		. = TRANSCEIVE_BUSY
		if(src.is_transceiving)
			return
		if(!powered() || !src.primed)
			return TRANSCEIVE_NOPOWER
		if(src.apc_power_check())
			return TRANSCEIVE_POWERWARN
		var/datum/powernet/powernet = src.get_direct_powernet()
		var/netnum = powernet.number
		if(netnum != pad_netnum)
			return TRANSCEIVE_NOWIRE
		return TRANSCEIVE_OK

	///Respond to a pad's request to do a transception
	proc/transceive(var/pad_netnum)
		. = FALSE
		if(src.is_transceiving)
			return
		if(!powered() || !src.primed)
			return
		if(src.apc_power_check())
			return
		var/datum/powernet/powernet = src.get_direct_powernet()
		var/netnum = powernet.number
		if(netnum != pad_netnum)
			return
		if(!src.use_area_cell_power(ARRAY_STARTCOST))
			return
		src.is_transceiving = TRUE
		use_power(ARRAY_TELECOST)
		playsound(src.loc, 'sound/effects/mag_forcewall.ogg', 50, 0)
		flick("beam",src.telebeam)
		SPAWN(TRANSCEPTION_COOLDOWN)
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

	///Checks status of local APC, disables transception if power is insufficient (just over 30% if equipment failsafe is enabled, 1 transception
	proc/apc_power_check() //returns true if error
		var/obj/machinery/power/apc/AC = get_local_apc(src)
		if (!AC)
			return
		if (AC && !AC.cell)
			return
		var/obj/item/cell/C = AC.cell
		var/combined_cost = (0.3 * C.maxcharge) + ARRAY_STARTCOST
		if (equipment_failsafe && C.charge < combined_cost)
			playsound(src.loc, 'sound/effects/manta_alarm.ogg', 50, 1)
			src.primed = FALSE
			src.failsafe_active = TRUE
			src.UpdateIcon()
			. = TRUE
		else if(C.charge <= ARRAY_STARTCOST)
			playsound(src.loc, 'sound/effects/manta_alarm.ogg', 50, 1)
			src.primed = FALSE
			src.failsafe_active = TRUE
			src.UpdateIcon()
			. = TRUE

	///Primed status restarts when power is sufficiently restored
	proc/attempt_restart()
		var/obj/machinery/power/apc/AC = get_local_apc(src)
		if (!AC)
			return
		if (AC && !AC.cell)
			return
		var/obj/item/cell/C = AC.cell
		var/combined_cost
		if (equipment_failsafe)
			combined_cost = (0.4 * C.maxcharge) + ARRAY_STARTCOST
		else
			combined_cost = (0.1 * C.maxcharge) + ARRAY_STARTCOST
		if (C.charge > combined_cost)
			playsound(src.loc, 'sound/machines/shieldgen_startup.ogg', 50, 1)
			src.primed = TRUE
			src.failsafe_active = FALSE
			src.UpdateIcon()
			. = TRUE
		return

	ex_act(severity) //tbi: damage and repair
		return

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

/obj/machinery/computer/trsc_array
	name = "Transception Array Control"
	desc = "Endpoint for status reporting and configuration for a nearby transception array."

	icon = 'icons/obj/computer.dmi'
	icon_state = "alert:0"
	flags = TGUI_INTERACTIVE
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_WIRECUTTERS | DECON_MULTITOOL

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if(!ui)
			ui = new(user, src, "TrscArray")
			ui.open()

	ui_data(mob/user)
		var/obj/machinery/power/apc/arrayapc = get_local_apc(transception_array)
		var/obj/item/cell/arraycell = arrayapc.cell
		var/cellstat_formatted
		var/celldiff_val
		var/safe_transceptions
		var/max_transceptions
		if(arraycell)
			cellstat_formatted = "[round(arraycell.charge)]/[arraycell.maxcharge]"
			celldiff_val = arraycell.charge / arraycell.maxcharge
			var/check_safe = round((arraycell.charge - (0.3 * arraycell.maxcharge)) / ARRAY_STARTCOST)
			var/check_max = round(arraycell.charge / ARRAY_STARTCOST)
			safe_transceptions = "[check_safe]"
			max_transceptions = "[check_max]"
		else
			cellstat_formatted = "ERROR"
			celldiff_val = 0
			safe_transceptions = "ERROR"
			max_transceptions = "ERROR"
		. = list(
			"cellStat" = cellstat_formatted,
			"cellDiff" = celldiff_val,
			"sendsSafe" = safe_transceptions,
			"sendsMax" = max_transceptions,
			"failsafeThreshold" = transception_array.equipment_failsafe ? "STANDARD" : "MINIMUM",
			"failsafeStat" = transception_array.failsafe_active ? "FAILSAFE HALT" : "OPERATIONAL",
			"arrayImage" = icon2base64(icon(initial(transception_array.icon), initial(transception_array.icon_state))),
			"arrayHealth" = "NOMINAL" //when array can be damaged, provides a string describing current level of damage
		)

	ui_act(action, list/params)
		. = ..()
		if (.)
			return
		else if (action == "toggle_failsafe")
			transception_array.equipment_failsafe = !(transception_array.equipment_failsafe)

#undef ARRAY_STARTCOST
#undef ARRAY_TELECOST
#undef TRANSCEPTION_COOLDOWN

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
		START_TRACKING
		src.net_id = generate_net_id(src)
		MAKE_DEFAULT_RADIO_PACKET_COMPONENT(null, src.frequency)
		src.pad_id = "[pick(vowels_upper)][prob(20) ? pick(consonants_upper) : rand(0,9)]-[rand(0,9)][rand(0,9)][rand(0,9)]"
		src.name = "transception pad [pad_id]"
		..()

	disposing()
		STOP_TRACKING
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
				SPAWN(0.5 SECONDS)
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


	proc/post_signal(datum/signal/signal,var/newfreq)
		if(!signal)
			return
		var/freq = newfreq
		if(!freq)
			freq = src.frequency

		signal.source = src
		signal.data["sender"] = src.net_id

		SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, signal, 20, freq)

	///Polls to see if pad's transception connection is operable
	proc/check_transceive()
		. = "ERR_NO_ARRAY"
		if(!transception_array)
			return
		var/datum/powernet/powernet = src.get_direct_powernet()
		if(!powernet)
			return "NO_WIRE_ENDPOINT"
		var/netnum = powernet.number
		var/error_code = transception_array.can_transceive(netnum)
		switch(error_code)
			if(TRANSCEIVE_BUSY) //connection's fine it's just busy at this particular time
				return "OK"
			if(TRANSCEIVE_NOPOWER)
				return "ERR_ARRAY_APC"
			if(TRANSCEIVE_POWERWARN)
				return "ARRAY_POWER_LOW"
			if(TRANSCEIVE_NOWIRE)
				return "ERR_WIRE"
			if(TRANSCEIVE_OK)
				return "OK"
			else
				return "ERR_OTHER" //what

	///Attempts to perform a transception operation; receive if it was passed an index for pending inbound cargo or a manual receive, send otherwise
	proc/attempt_transceive(var/cargo_index = null,var/obj/manual_receive = null)
		if(src.is_transceiving)
			return
		if(!transception_array)
			return
		var/datum/powernet/powernet = src.get_direct_powernet()
		if(!powernet)
			return
		var/netnum = powernet.number
		if(transception_array.can_transceive(netnum) != TRANSCEIVE_OK)
			return
		if(cargo_index || manual_receive)
			var/obj/inbound_target
			if(manual_receive)
				inbound_target = manual_receive
			else if(shippingmarket.pending_crates[cargo_index])
				inbound_target = shippingmarket.pending_crates[cargo_index]
			else
				return
			if(inbound_target)
				receive_a_thing(netnum,inbound_target)
		else
			send_a_thing(netnum)


	proc/send_a_thing(var/netnumber)
		src.is_transceiving = TRUE
		playsound(src.loc, 'sound/effects/ship_alert_minor.ogg', 50, 0) //outgoing cargo warning (stand clear)
		SPAWN(2 SECONDS)
			flick("neopad_activate",src)
			SPAWN(0.3 SECONDS)
				var/obj/thing2send
				var/list/oofed_nerds = list()
				for(var/atom/movable/AM as obj|mob in src.loc)
					if(AM.anchored) continue
					if(AM == src) continue
					if(istype(AM,/mob/living/carbon/human) && prob(25)) //telefrag
						oofed_nerds += AM
						continue
					if(isobj(AM))
						var/obj/O = AM
						if(istype(O,/obj/storage/crate) || O.artifact)
							thing2send = O
							break //only one thing at a time!
				for(var/nerd in oofed_nerds)
					telefrag(nerd) //did I mention NO MOBS
				if(thing2send && transception_array.transceive(netnumber))
					thing2send.loc = src
					SPAWN(1 SECOND)

						if (istype(thing2send, /obj/storage/crate/biohazard/cdc))
							QM_CDC.receive_pathogen_samples(thing2send)

						else if(istype(thing2send,/obj/storage/crate) || istype(thing2send,/obj/storage/secure/crate))
							var/sold_to_trader = FALSE
							for (var/datum/trader/T in shippingmarket.active_traders)
								if (T.crate_tag == thing2send.delivery_destination)
									shippingmarket.sell_crate(thing2send, T.goods_buy)
									sold_to_trader = TRUE
									break
							if(!sold_to_trader)
								shippingmarket.sell_crate(thing2send)

						else if(thing2send.artifact)
							var/datum/artifact/art = thing2send.artifact
							shippingmarket.sell_artifact(thing2send,art)

						else //how even
							logTheThing(LOG_DEBUG, null, "Telepad attempted to send [thing2send], which is not a crate or artifact")

				showswirl(src.loc)
				use_power(200) //most cost is at the array
				src.is_transceiving = FALSE


	proc/receive_a_thing(var/netnumber,var/atom/movable/thing2get)
		src.is_transceiving = TRUE
		if(thing2get in shippingmarket.pending_crates)
			shippingmarket.pending_crates.Remove(thing2get) //avoid received thing being queued into multiple pads at once
		playsound(src.loc, 'sound/effects/ship_alert_minor.ogg', 50, 0) //incoming cargo warning (stand clear)
		SPAWN(2 SECONDS)
			flick("neopad_activate",src)
			SPAWN(0.4 SECONDS)
				var/tele_obstructed = FALSE
				var/turf/receive_turf = get_turf(src)
				if(length(receive_turf.contents) < 10) //fail if there is excessive clutter or dense object
					for(var/atom/movable/O in receive_turf)
						if(istype(O,/obj))
							if(O.density)
								tele_obstructed = TRUE
						if(istype(O,/mob/living/carbon/human) && prob(25))
							telefrag(O) //get out the way
				else
					tele_obstructed = TRUE
				if(!tele_obstructed && transception_array.transceive(netnumber))
					thing2get.loc = src.loc
					showswirl(src.loc)
					use_power(200) //most cost is at the array
				else
					shippingmarket.pending_crates.Add(thing2get)
					playsound(src.loc, 'sound/machines/pod_alarm.ogg', 30, 0)
					src.visible_message("<span class='alert'><B>[src]</B> emits an [tele_obstructed ? "obstruction" : "array status"] warning.</span>")
				src.is_transceiving = FALSE


	///Standing on the pad while it's trying to transport cargo is an extremely dumb idea, prepare to get owned
	proc/telefrag(var/mob/living/carbon/human/M)
		var/dethflavor = pick("suddenly vanishes","tears off in the teleport stream","disappears in a flash","violently disintegrates")
		var/limb_ripped = FALSE

		switch(rand(1,4))
			if(1)
				if(M.limbs.l_arm)
					limb_ripped = TRUE
					M.limbs.l_arm.delete()
					M.visible_message("<span class='alert'><B>[M]</B>'s arm [dethflavor]!</span>")
			if(2)
				if(M.limbs.r_arm)
					limb_ripped = TRUE
					M.limbs.r_arm.delete()
					M.visible_message("<span class='alert'><B>[M]</B>'s arm [dethflavor]!</span>")
			if(3)
				if(M.limbs.l_leg)
					limb_ripped = TRUE
					M.limbs.l_leg.delete()
					M.visible_message("<span class='alert'><B>[M]</B>'s leg [dethflavor]!</span>")
			if(4)
				if(M.limbs.r_leg)
					limb_ripped = TRUE
					M.limbs.r_leg.delete()
					M.visible_message("<span class='alert'><B>[M]</B>'s leg [dethflavor]!</span>")

		if(limb_ripped)
			playsound(M.loc, 'sound/impact_sounds/Flesh_Tear_2.ogg', 75)
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
					manifest["Array Link"] = signal.data["opstat"]
					src.known_pads[device_netid] = manifest
					src.queue_dialog_update = TRUE


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
			SPAWN(0.5 SECONDS)
				src.post_signal(yell)


	proc/try_pad_ping()
		if( ON_COOLDOWN(src, "ping", 1 SECOND) || !src.net_id)
			return 1

		src.known_pads.Cut()
		src.list_is_updated = FALSE

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

	var/pending_crate_ct = length(shippingmarket.pending_crates)
	HTML += "PENDING CARGO ITEMS: [pending_crate_ct]<br>"

	src.build_formatted_list()
	if (src.formatted_list)
		HTML += src.formatted_list

	user.Browse(HTML, "window=transception_\ref[src];title=Transception Interlink;size=350x550;")
	onclose(user, "transception_\ref[src]")

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
				minitext += "<strong>[field]</strong> &middot; [tidy_net_data(manifest[field])]<br>"
		rollingtext += minitext
		rollingtext += "<A href='[topicLink("send","\ref[device_index]")]'>Send</A> | "
		rollingtext += "<A href='[topicLink("receive","\ref[device_index]")]'>Receive</A><br><br>"

	src.formatted_list = rollingtext
	src.list_is_updated = TRUE

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


#undef TRANSCEIVE_BUSY
#undef TRANSCEIVE_NOPOWER
#undef TRANSCEIVE_POWERWARN
#undef TRANSCEIVE_NOWIRE
#undef TRANSCEIVE_OK
