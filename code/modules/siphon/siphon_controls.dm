//defines for physical click zones on siphon control
#define CLICK_ZONE_LEVER 1
#define CLICK_ZONE_PANEL 2

///manual control panel for core operation of siphon itself (raising and lowering, on and off); stays physically paired to the siphon
/obj/machinery/siphon_lever
	name = "Primary Siphon Control"
	desc = "Console with a sizable lever and hand pad for activation of a harmonic siphon from a distance."
	icon = 'icons/obj/machines/neodrill_32x32.dmi'
	icon_state = "siph-control-0"
	anchored = 1
	density = 1
	var/obj/machinery/siphon/core/paired_core = null
	var/lever_active = 0
	var/panel_active = 0

	New()
		..()
		SPAWN(0.7 SECONDS)
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
					var/device_netid = "DEV_[signal.data["netid"]]" //stored like this so it overwrites existing entries for partial refreshes
					var/list/manifest = new()
					manifest["Identifier"] = signal.data["device"]
					manifest["INT_TARGETID"] = signal.data["netid"]
					manifest += signal.data["devdat"]
					src.known_devices[device_netid] = manifest
					if(signal.data["REFRESH_UI"])
						src.updateUsrDialog()
				if("deinit")
					if(signal.data["device"] == "SIPHON")
						src.list_is_updated = FALSE
						src.known_devices.Cut()


	//construct command packet to send out; accepts netid for comms target device and a list of key-value paired commands
	proc/build_command(var/com_target,var/command_list)
		if(com_target)
			var/datum/signal/yell = new
			yell.data["address_1"] = com_target
			yell.data["command"] = "calibrate"
			yell.data += command_list
			SPAWN(0.5 SECONDS)
				src.post_signal(yell)


	proc/post_signal(datum/signal/signal,var/newfreq)
		if(!signal)
			return
		var/freq = newfreq
		if(!freq)
			freq = src.frequency

		signal.source = src
		signal.data["sender"] = src.net_id

		SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, signal, 20, freq)

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

	user.Browse(HTML, "window=siphonControl_\ref[src];title=Siphon Systems Control;size=350x550;")
	onclose(user, "siphonControl_\ref[src]")


//oh boy another place this gets duplicated
/obj/machinery/computer/siphon_control/proc/topicLink(action, subaction, var/list/extra)
	return "?src=\ref[src]&action=[action][subaction ? "&subaction=[subaction]" : ""]&[extra && islist(extra) ? list2params(extra) : ""]"

/obj/machinery/computer/siphon_control/proc/build_formatted_list()
	if(src.list_is_updated) return
	///The "upper" section of the list; keeps the Siphon's information on top when multiple devices are linked
	var/mainlist = ""
	///The "lower" section of the list; formats data from known devices (resonators) before being appended to the main list
	var/rollingtext = ""
	///Sum of resonator intensities (used to display effective extraction units per cycle, aka machine tick)
	var/intensity_sum = 0

	if(!length(src.known_devices))
		mainlist = {"<h2>NO CONNECTION TO DEVICES</h2><br>
		Displaying Default Message<br>
		<br>
		Welcome to HARMONIC SIPHON CONTROL<br>
		<br>
		To begin using the siphon, please place<br>
		one or more resonators within a radius<br>
		of four tiles. Use the floor coordinate<br>
		indicators for positional reference; they<br>
		will be reflected in this console once<br>
		the siphon is online and resonators<br>
		have completed pairing.<br>
		<br>
		Please note that siphon operation<br>
		<strong>does not begin when siphon is lowered;</strong><br>
		lowering the siphon locks and pairs<br>
		resonators, readying them for calibration<br>
		and subsequent operation. Additionally,<br>
		note that resource extraction may not<br>
		show in the siphon reservoir indicator<br>
		immediately, as extraction typically<br>
		occurs over several cycles.<br>
		<br>
		Using a wrench to manually anchor<br>
		resonators is optional, as an<br>
		automatic magnetic lock is utilized."}
		src.formatted_list = mainlist
		return

	mainlist += "<h2>CONNECTED DEVICES</h2>"

	for (var/device_index in src.known_devices)
		var/saveforsiphon = FALSE
		var/minitext = ""
		var/list/manifest = known_devices[device_index]
		for(var/field in manifest)
			if(field == "Intensity")
				var/maxintens = tidy_net_data(manifest["Maximum Intensity"])
				if(isnum(manifest[field]))
					intensity_sum += manifest[field]
				minitext += "<strong>[field]</strong> &middot; [tidy_net_data(manifest[field])][maxintens ? " / [maxintens]" : ""] "
				minitext += "<A href='[topicLink("calibrate","\ref[device_index]")]'>(Calibrate)</A><br>"
			else if(field != "INT_TARGETID" && field != "Maximum Intensity")
				if(field == "Identifier" && manifest[field] == "SIPHON") saveforsiphon = TRUE
				minitext += "<strong>[field]</strong> &middot; [tidy_net_data(manifest[field])]<br>"
		if(saveforsiphon)
			mainlist += minitext
		else
			rollingtext += minitext
			rollingtext += "<br>"

	mainlist += "<strong>EEU per Cycle</strong> &middot; [intensity_sum]<br><br>"
	mainlist += rollingtext
	src.formatted_list = mainlist
	src.list_is_updated = TRUE


/obj/machinery/computer/siphon_control/Topic(href, href_list)
	if(..())
		return

	switch (href_list["action"])
		if ("calibrate")
			var/manifest_identifier = locate(href_list["subaction"]) in src.known_devices
			var/list/manifest = known_devices[manifest_identifier]
			if(manifest && manifest["Identifier"])
				var/intensicap = manifest["Maximum Intensity"]
				var/scalex = input(usr,"Accepts values 0 through [intensicap]","Adjust Intensity","1") as num
				scalex = clamp(scalex,0,intensicap)
				var/list/commanderino = list("intensity" = scalex)
				src.build_command(manifest["INT_TARGETID"],commanderino)

	src.add_fingerprint(usr)





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

	///textified list of all indexed (non-hidden) minerals
	var/mineral_list = null


/obj/machinery/computer/siphon_db/attack_hand(var/mob/user as mob)
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
	<title>Resonance Calibration Database</title>
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

	HTML += "This computer lists our projections<br>"
	HTML += "for outcomes of certain resonant parameters<br>"
	HTML += "when applied to the harmonic siphon.<br>"
	HTML += "It <strong>does not control siphon function</strong>;<br>"
	HTML += "please use provided devices for that purpose.<br><br>"
	HTML += "A subset of these entries contain configurations for<br>"
	HTML += "resonator positions corresponding to successful<br>"
	HTML += "extraction of their listed resource; you are<br>"
	HTML += "not required to use these parameters.<br>"
	HTML += "They are given for reference and ease of initial use.<br><br>"
	HTML += "<strong>Please see end of list for a</strong><br>"
	HTML += "<strong>glossary of pertinent terms.</strong><br><br>"

	src.build_mineral_list()
	if (src.mineral_list)
		HTML += src.mineral_list

	HTML += "<h2>GLOSSARY</h2>"
	HTML += "<h3>EEU: Effective Extraction Units</h3>"
	HTML += "Each time the harmonic siphon cycles, one EEU is <br>"
	HTML += "produced for each unit of resonance in active <br>"
	HTML += "resonators; once cumulative EEU matches a material's <br>"
	HTML += "required EEU per extraction under appropriate resonant<br>"
	HTML += "conditions, a unit of that material is produced and added<br>"
	HTML += "to the siphon's internal resource buffer.<br><br>"
	HTML += "Increased total resonance results in more EEU per cycle;<br>"
	HTML += "maximum production is reached by matching the EEU<br>"
	HTML += "per cycle to the resource's EEU per extraction.<br><br>"
	HTML += "<strong>Warning: EEU per cycle greatly exceeding</strong><br>"
	HTML += "<strong>the required EEU per extraction on a</strong><br>"
	HTML += "<strong>sustained basis can cause resonator damage.</strong><br>"
	HTML += "<h3>LATERAL RESONANCE</h3>"
	HTML += "First of three resonant parameters, charted on<br>"
	HTML += "the letter axis. Type-AX resonators will raise or lower<br>"
	HTML += "this value by eight units per intensity at 'point-blank'<br>"
	HTML += "(columns D or F), diminishing by powers of two to a <br>"
	HTML += "minimum of one unit at max range (columns A or I).<br>"
	HTML += "<h3>VERTICAL RESONANCE</h3>"
	HTML += "Second of three resonant parameters, charted on<br>"
	HTML += "the number axis. Type-AX resonators will raise or lower<br>"
	HTML += "this value by eight units per intensity at 'point-blank'<br>"
	HTML += "(rows 3 or 5), diminishing by powers of two to a <br>"
	HTML += "minimum of one unit at max range (rows 0 or 8).<br>"
	HTML += "<h3>RESONANT SHEAR</h3>"
	HTML += "Third of three resonant parameters, a byproduct<br>"
	HTML += "of lateral and vertical resonance.<br>"
	HTML += "When positive and negative resonance values cancel out<br>"
	HTML += "on the same axis, a shear will be produced equal to<br>"
	HTML += "the amount of resonance cancelled.<br>"
	HTML += "Shear cannot be produced directly, but can be mitigated<br>"
	HTML += "by use of the Type-SM resonator, mitigating one to eight<br>"
	HTML += "units of shear per intensity, depending on distance.<br><br>"
	HTML += "<strong>Warning: A shear value of 64 or greater can cause</strong><br>"
	HTML += "<strong>significant malfunctions, intensifying with magnitude,</strong><br>"
	HTML += "<strong>if it does not match an extraction target.</strong><br>"
	HTML += "<h3>SENSITIVITY MARGIN</h3>"
	HTML += "Some extraction targets are more forgiving of <br>"
	HTML += "inexact parameters than others. If this value is listed,<br>"
	HTML += "<strong>any</strong> resonance parameter may differ by<br>"
	HTML += "the amount of the listed value without an<br>"
	HTML += "adverse effect on extraction.<br>"

	user.Browse(HTML, "window=siphonControl_\ref[src];title=Resonance Calibration Database;size=420x500;")
	onclose(user, "siphonControl_\ref[src]")

/obj/machinery/computer/siphon_db/proc/build_mineral_list()
	if(src.mineral_list) return
	var/rollingtext = ""

	var/obj/machinery/siphon/core/reference_core //talk to the core to see what it can extract
	for (var/obj/machinery/siphon/core/proxcore in orange(6, src))
		reference_core = proxcore
		break

	for (var/datum/siphon_mineral/mat in reference_core.can_extract)
		if(!mat.indexed)
			continue
		rollingtext += "<h2>[mat.name]</h2>"
		rollingtext += "<strong>EEU per Extraction:</strong> [mat.tick_req]<br>"
		if(mat.x_torque != null)
			rollingtext += "<strong>Target Lateral Resonance:</strong> [mat.x_torque]<br>"
		if(mat.y_torque != null)
			rollingtext += "<strong>Target Vertical Resonance:</strong> [mat.y_torque]<br>"
		if(mat.shear != null)
			rollingtext += "<strong>Target Resonant Shear:</strong> [mat.shear]<br>"
		rollingtext += "<strong>Sensitivity Margin:</strong> [mat.sens_window]<br>"
		if(mat.setup_guide)
			rollingtext += "<br><strong>Reference Configuration</strong><br>"
			for(var/stringerino in mat.setup_guide)
				rollingtext += stringerino
		rollingtext += "<br>"

	src.mineral_list = rollingtext
