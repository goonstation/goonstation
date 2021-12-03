#define CLICK_ZONE_LEVER 1
#define CLICK_ZONE_PANEL 2

///manual control panel for core operation of siphon itself (raising and lowering, on and off); stays physically paired to the siphon
/obj/machinery/siphon_lever
	name = "Primary Siphon Control"
	desc = "Console with a sizable lever and hand pad for activation of a harmonic siphon from a distance."
	icon = 'icons/obj/machines/neodrill_32x32.dmi'
	icon_state = "siph-control-0"
	density = 1
	var/obj/machinery/siphon/core/paired_core = null
	var/lever_active = 0
	var/panel_active = 0

	New()
		..()
		SPAWN_DBG(0.7 SECONDS)
			src.pair_siphon()

	proc/pair_siphon()
		src.paired_core?.paired_lever = null
		src.paired_core = locate(/obj/machinery/siphon/core, orange(6,src))
		if(paired_core)
			src.paired_core.paired_lever = src
			switch(src.paired_core.mode)
				if("high")
					src.vis_setlever(0)
					src.vis_setpanel(0)
				if("low")
					src.vis_setlever(1)
					src.vis_setpanel(0)
				if("active")
					src.vis_setlever(1)
					src.vis_setpanel(1)
		else
			src.vis_setlever(0)
			src.vis_setpanel(0)

	proc/vis_setlever(var/external_swap_type)
		if(external_swap_type != null)
			src.lever_active = external_swap_type
		src.icon_state = "siph-control-[src.lever_active]"
		var/image/warnglow = SafeGetOverlayImage("warn", 'icons/obj/machines/neodrill_32x32.dmi', "siph-warnglow-[src.lever_active]")
		warnglow.plane = PLANE_OVERLAY_EFFECTS
		UpdateOverlays(warnglow, "warn", 0, 1)

	proc/vis_setpanel(var/external_swap_type)
		if(external_swap_type != null)
			src.panel_active = external_swap_type
		var/image/panelglow = SafeGetOverlayImage("panel", 'icons/obj/machines/neodrill_32x32.dmi', "siph-panelglow-[src.panel_active]")
		panelglow.plane = PLANE_OVERLAY_EFFECTS
		UpdateOverlays(panelglow, "panel", 0, 1)

	RawClick(location,control,params)
		var/mob/user = usr
		if (ismobcritter(user) || issilicon(user) || isobserver(user))
			return
		if(can_act(user) && can_reach(user, src))
			var/list/paramList = params2list(params)

			var/obj/item/I = user.equipped()
			if(I) //no hitting the controls with stuff to operate them!
				src.attackby(I,user)
				return

			//Determine spot that was clicked
			var/click_zone_override = null
			switch(text2num(paramList["icon-x"]))
				if(3 to 16) //Lever horizontal range
					switch(text2num(paramList["icon-y"]))
						if(11 to 28) //Lever vertical range
							click_zone_override = CLICK_ZONE_LEVER
				if(21 to 29) //Panel horizontal range
					switch(text2num(paramList["icon-y"]))
						if(14 to 23) //Panel vertical range
							click_zone_override = CLICK_ZONE_PANEL
			switch(click_zone_override)
				if(CLICK_ZONE_LEVER)
					if(powered() && paired_core.toggle_drill(TRUE))
						src.lever_active = !src.lever_active
						src.vis_setlever()
					else
						boutput(user,"The lever seems to be locked in place.")
				if(CLICK_ZONE_PANEL)
					if(powered() && paired_core.toggle_operating(TRUE))
						src.panel_active = !src.panel_active
						src.vis_setpanel()
					else
						boutput(user,"The hand pad doesn't respond when you touch it.")

#undef CLICK_ZONE_LEVER
#undef CLICK_ZONE_PANEL


///control for siphon and associated resonators: receives siphon and resonator data, and controls resonator operation
/obj/machinery/computer/siphon_control
	name = "Siphon Systems Control"
	icon = 'icons/obj/computerpanel.dmi'
	icon_state = "engine1"
	req_access = list(access_research)
	object_flags = CAN_REPROGRAM_ACCESS
	var/net_id
	var/temp = null
	///list of devices known to the siphon control device
	var/list/known_devices = list()
	///formatted version of above device manifest
	var/formatted_list = null
	///thing to avoid having to update the list every time you click the window
	var/list_is_updated = FALSE

	light_r = 0.8
	light_g = 1
	light_b = 1

	New()
		..()
		src.net_id = generate_net_id(src)
		MAKE_DEFAULT_RADIO_PACKET_COMPONENT(null, FREQ_HARMONIC_SIPHON)

	receive_signal(datum/signal/signal)
		if(status & NOPOWER)
			return

		if(!signal || signal.encryption || !signal.data["sender"])
			return

		var/sender = signal.data["sender"]

		if(sender)
			switch(signal.data["command"])
				if("devdat")
					src.list_is_updated = FALSE
					var/device_netid = signal.data["netid"]
					var/list/manifest = new()
					manifest["Identifier"] = signal.data["device"]
					manifest += signal.data["devdat"]
					src.known_devices[device_netid] = manifest
				if("deinit")
					if(signal.data["device"] == "SIPHON")
						src.list_is_updated = FALSE
						src.known_devices.Cut()
		return

/obj/machinery/computer/siphon_control/attack_hand(var/mob/user as mob)
	if(!src.allowed(user))
		boutput(user, "<span class='alert'>Access Denied.</span>")
		return

	if(..())
		return

	src.add_dialog(user)
	var/HTML

	///if it works, don't break it?
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
	<title>Siphon Systems Control</title>
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

	user.Browse(HTML, "window=siphonControl_\ref[src];title=Siphon Systems Console;size=350x550;")
	onclose(user, "siphonControl_\ref[src]")
	return

//oh boy another place this gets duplicated
/obj/machinery/computer/siphon_control/proc/topicLink(action, subaction, var/list/extra)
	return "?src=\ref[src]&action=[action][subaction ? "&subaction=[subaction]" : ""]&[extra && islist(extra) ? list2params(extra) : ""]"

/obj/machinery/computer/siphon_control/proc/build_formatted_list()
	if(src.list_is_updated) return
	var/mainlist = "" //held separately so the siphon can always start the list
	var/rollingtext = "" //list of entries for not siphon

	if(!length(src.known_devices))
		mainlist = "<h2>NO CONNECTION TO DEVICES</h2><br>Lower siphon to initialize"
		src.formatted_list = mainlist
		return

	mainlist += "<h2>CONNECTED DEVICES</h2><br><br>"

	for (var/device_index in src.known_devices)
		var/saveforsiphon = FALSE
		var/minitext = ""
		var/list/manifest = known_devices[device_index]
		for(var/field in manifest)
			if(field == "Intensity") //calibration isn't in yet, add it, seriously !!!!!!!!!!!
				minitext += "<strong>[field]</strong> &middot; [manifest[field]] <A href='[topicLink("calibrate","\ref[manifest]")]'>(Calibrate)</A><br>"
			else
				if(field == "Identifier" && manifest[field] == "SIPHON") saveforsiphon = TRUE
				minitext += "<strong>[field]</strong> &middot; [manifest[field]]<br>"
		if(saveforsiphon)
			mainlist += minitext
			mainlist += "<br>"
		else
			rollingtext += minitext
			rollingtext += "<br>"

	mainlist += rollingtext
	src.formatted_list = mainlist
	src.list_is_updated = TRUE
	return





//database to look up requirements for extraction, including in some cases a recommendation for parameters
/obj/machinery/computer/siphon_db
	name = "Resonance Calibration Database"
	icon = 'icons/obj/computerpanel.dmi'
	icon_state = "qmreq1"
	object_flags = CAN_REPROGRAM_ACCESS
	var/temp = null

	light_r = 0.8
	light_g = 1
	light_b = 1
