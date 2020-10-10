//Assorted small programs not worthy of their own file
//CONTENTS:
//~*~Banking Software~*~
//Crew Manifest viewer
//Status display controller
//Remote signaling program
//Cargo orders monitor
//Bicycle Horn Synth
//Janitor mop-locating program
//Remote door control program
//Atmospherics Alert-checking program
//Power checker program
//Hydroponics plant monitor
//Emergency alert program
//Self destruct detomatix program
//Old-style detomatix program
//Detomatix Detomanual
//Ticket writer
//Cargo request
//Station Namer

//Banking
/datum/computer/file/pda_program/banking
	name = "BankBuddy"
	size = 8

	var/tmp/datum/data/record/bank_record = null

	return_text()
		if (..())
			return

		var/dat = src.return_text_header()

		//todo

		return dat

	proc/locate_bank_record()
		if (!src.master || !src.master.owner)
			return 0

		for(var/datum/data/record/B in data_core.bank)
			if(lowertext(B.fields["name"]) == lowertext(src.master.owner))
				src.bank_record = B
				return 1
		return 0


//Manifest
/datum/computer/file/pda_program/manifest
	name = "Manifest"

	return_text()
		if(..())
			return

		var/dat = src.return_text_header()

		dat += "<h4>Crew Manifest</h4>"
		dat += "Entries cannot be modified from this terminal.<br><br>"

		for (var/datum/data/record/t in data_core.general)
			dat += "[t.fields["name"]] - [t.fields["rank"]]<br>"
		dat += "<br>"

		return dat

//Status Display
/datum/computer/file/pda_program/status_display
	name = "Status Controller"
	size = 8
	var/message1	// For custom messages on the displays.
	var/message2

	return_text()
		if(..())
			return

		var/dat = src.return_text_header()

		dat += "<h4>Station Status Display Interlink</h4>"

		dat += "\[ <A HREF='?src=\ref[src];statdisp=blank'>Clear</A> \]<BR>"
		dat += "\[ <A HREF='?src=\ref[src];statdisp=shuttle'>Shuttle ETA</A> \]<BR>"
		dat += "\[ <A HREF='?src=\ref[src];statdisp=message'>Message</A> \]"

		dat += "<ul><li> Line 1: <A HREF='?src=\ref[src];statdisp=setmsg1'>[ message1 ? message1 : "(none)"]</A>"
		dat += "<li> Line 2: <A HREF='?src=\ref[src];statdisp=setmsg2'>[ message2 ? message2 : "(none)"]</A></ul><br>"
		dat += "\[ Alert: <A HREF='?src=\ref[src];statdisp=alert;alert=default'>None</A> |"

		dat += " <A HREF='?src=\ref[src];statdisp=alert;alert=redalert'>Red Alert</A> |"
		dat += " <A HREF='?src=\ref[src];statdisp=alert;alert=lockdown'>Lockdown</A> |"
		dat += " <A HREF='?src=\ref[src];statdisp=alert;alert=biohazard'>Biohazard</A> \]<BR>"

		return dat


	Topic(href, href_list)
		if(..())
			return

		if(href_list["statdisp"])
			switch(href_list["statdisp"])
				if("message")
					post_status("message", message1, message2)
				if("alert")
					post_status("alert", href_list["alert"])

				if("setmsg1")
					if (!src.master || !in_range(src.master, usr) && src.master.loc != usr)
						return

					if(!(src.holder in src.master))
						return

					message1 = input("Line 1", "Enter Message Text", message1) as text|null
					message1 = copytext(adminscrub(message1), 1, MAX_MESSAGE_LEN)
					src.master.updateSelfDialog()

				if("setmsg2")
					if (!src.master || !in_range(src.master, usr) && src.master.loc != usr)
						return

					if(!(src.holder in src.master))
						return

					message2 = input("Line 2", "Enter Message Text", message2) as text|null
					message2 = copytext(adminscrub(message2), 1, MAX_MESSAGE_LEN)
					src.master.updateSelfDialog()
				else
					post_status(href_list["statdisp"])

		src.master.add_fingerprint(usr)
		src.master.updateSelfDialog()
		return

	proc/post_status(var/command, var/data1, var/data2)
		if(!src.master)
			return

		var/datum/signal/status_signal = get_free_signal()
		status_signal.source = src.master
		status_signal.transmission_method = 1
		status_signal.data["command"] = command

		switch(command)
			if("message")
				status_signal.data["msg1"] = data1
				status_signal.data["msg2"] = data2
			if("alert")
				status_signal.data["picture_state"] = data1

		src.post_signal(status_signal,"1435")

//Signaler
/datum/computer/file/pda_program/signaler
	name = "Signalix 5"
	size = 8
	var/send_freq = 1457 //Frequency signal is sent at, should be kept within normal radio ranges.
	var/send_code = 30
	var/last_transmission = 0 //No signal spamming etc

	return_text()
		if(..())
			return

		var/dat = src.return_text_header()

		dat += "<h4>Remote Signaling System</h4>"
		dat += {"
<a href='byond://?src=\ref[src];send=1'>Send Signal</A><BR>

Frequency:
<a href='byond://?src=\ref[src];adj_freq=-10'>-</a>
<a href='byond://?src=\ref[src];adj_freq=-2'>-</a>
[format_frequency(send_freq)]
<a href='byond://?src=\ref[src];adj_freq=2'>+</a>
<a href='byond://?src=\ref[src];adj_freq=10'>+</a><br>
<br>
Code:
<a href='byond://?src=\ref[src];adj_code=-5'>-</a>
<a href='byond://?src=\ref[src];adj_code=-1'>-</a>
[send_code]
<a href='byond://?src=\ref[src];adj_code=1'>+</a>
<a href='byond://?src=\ref[src];adj_code=5'>+</a><br>"}

		return dat

	Topic(href, href_list)
		if(..())
			return

		if (href_list["send"])
			if(last_transmission && world.time < (last_transmission + 5))
				return
			last_transmission = world.time
			SPAWN_DBG( 0 )
				logTheThing("signalers", usr, null, "used [src.master] @ location ([showCoords(src.master.loc.x, src.master.loc.y, src.master.loc.z)]) <B>:</B> [format_frequency(send_freq)]/[send_code]")

				var/datum/signal/signal = get_free_signal()
				signal.source = src
				//signal.encryption = send_code
				signal.data["message"] = "ACTIVATE"
				signal.data["code"] = send_code

				src.post_signal(signal,"[send_freq]")
				return

		else if (href_list["adj_freq"])
			src.send_freq = sanitize_frequency(src.send_freq + text2num(href_list["adj_freq"]))

		else if (href_list["adj_code"])
			src.send_code += text2num(href_list["adj_code"])
			src.send_code = round(src.send_code)
			src.send_code = min(100, src.send_code)
			src.send_code = max(1, src.send_code)

		src.master.add_fingerprint(usr)
		src.master.updateSelfDialog()
		return

//Supply record monitor
/datum/computer/file/pda_program/qm_records
	name = "Supply Records"
	size = 8

	return_text()
		if(..())
			return

		var/dat = src.return_text_header()
		dat += "<h4>Supply Record Interlink</h4>"

		dat += "Order History: <BR><ol>"
		for(var/S in shippingmarket.supply_history)
			dat += S
		dat += "</ol>"

		dat += "Current requests: <BR><ol>"
		for(var/S in shippingmarket.supply_requests)
			var/datum/supply_order/SO = S
			dat += "<li>[SO.object.name] requested by [SO.orderedby]</li>"
		dat += "</ol><font size=\"-3\">Upgrade NOW to Space Parts & Space Vendors PLUS for full remote order control and inventory management."

		return dat

//Clown horn emulator.  honk.
/datum/computer/file/pda_program/honk_synth
	name = "Honk Synthesizer"
	size = 4
	var/honk_volume = 2
	var/last_honk = 0

	return_text()
		if(..())
			return

		var/dat = src.return_text_header()
		dat += "<h4>Honk Synthesizer V2</h4>"

		dat += "<TT>Volume: "
		dat += "<a href='byond://?src=\ref[src];adj_volume=-1'>-</a> "
		dat += "[src.honk_volume] "
		dat += "<a href='byond://?src=\ref[src];adj_volume=1'>+</a> "
		dat += "</TT><br>"

		dat += "<a href='?src=\ref[src];honk=1'>Honk</a>"

		return dat

	Topic(href, href_list)
		if(..())
			return

		if (href_list["adj_volume"])
			var/adjust_num = text2num(href_list["adj_volume"])
			src.honk_volume += adjust_num
			if(src.honk_volume < 1)
				src.honk_volume = 1
			if(src.honk_volume > 4)
				src.honk_volume = 4

		else if(href_list["honk"])
			src.honk()

		src.master.add_fingerprint(usr)
		src.master.updateSelfDialog()
		return

	proc/honk()
		if(!src.master || src.master.active_program != src)
			return
		if (last_honk && world.time < last_honk + 20)
			return
		playsound(src.master.loc, "sound/musical_instruments/Bikehorn_1.ogg", (src.honk_volume * 25), 1)
		src.last_honk = world.time

		return

//TO-DO: Change to use radio system I guess
/datum/computer/file/pda_program/mopfinder
	name = "Mop Locator"
	size = 8

	return_text()
		if(..())
			return

		var/dat = src.return_text_header()
		dat += "<h4>Persistent Custodial Object Locator</h4>"

		var/turf/cl = get_turf(src.master)
		if (cl)
			dat += "Current Orbital Location: <b>\[[cl.x],[cl.y]\]</b>"

			dat += "<h4>Located Mops:</h4>"

			var/ldat
			for_by_tcl(M, /obj/item/mop)
				var/turf/ml = get_turf(M)

				if(!ml || !istype(ml))
					continue

				if (ml.z != cl.z)
					continue

				ldat += "Mop - <b>\[[ml.x],[ml.y] ([get_area(ml)])\]</b> - [M.reagents.total_volume ? "Wet" : "Dry"]<br>"

			if (!ldat)
				dat += "None"
			else
				dat += "[ldat]"

			dat += "<h4>Located Mop Buckets:</h4>"

			ldat = null
			for_by_tcl(B, /obj/mopbucket)
				var/turf/bl = get_turf(B)

				if(!bl || !istype(bl))
					continue

				if (bl.z != cl.z)
					continue

				ldat += "Bucket - <b>\[[bl.x],[bl.y] ([get_area(bl)])\]</b> - Water level: [B.reagents.total_volume]/50<br>"

			if (!ldat)
				dat += "None"
			else
				dat += "[ldat]"

			dat += "<h4>Located Cleanbots:</h4>"

			ldat = null
			for (var/obj/machinery/bot/cleanbot/B in machine_registry[MACHINES_BOTS])
				var/turf/cb = get_turf(B)

				if(!cb || !istype(cb))
					continue

				if (cb.z != cl.z)
					continue

				ldat += "Cleanbot - <b>\[[cb.x],[cb.y] ([get_area(cb)])\]</b> - [B.on ? "Online" : "Offline"]<br>"

			if (!ldat)
				dat += "None"
			else
				dat += "[ldat]"

		else
			dat += "ERROR: Unable to determine current location."

		return dat


/datum/computer/file/pda_program/door_control
	name = "DoorMaster"
	size = 8
	var/id = 1.0
	var/last_toggle = 0

	syndicate
		id = "syndicate"

	return_text()
		if(..())
			return

		var/dat = src.return_text_header()

		dat += "<h4>DoorMaster 5.1.9 Pod-Door Control System</h4>"
		dat += "<a href='?src=\ref[src];toggle=1'>Toggle Doors</a><br><br>"
		dat += "<font size=1><i>Like this program? Send $9.95 to SPACETREND MICROSYSTEMS in Neo Toronto, Ontario for more bargain software!</i></font>"

		return dat

	Topic(href, href_list)
		if(..())
			return

		if(href_list["toggle"] && (world.time >= last_toggle + 20))
			for (var/obj/machinery/door/poddoor/M)
				if (M.id != src.id)
					continue
				if (M.density)
					SPAWN_DBG(0)
						M.open()
				else
					SPAWN_DBG(0)
						M.close()

		src.master.add_fingerprint(usr)
		src.master.updateSelfDialog()
		return



//Ask the atmos alert computer for alert data.
/datum/computer/file/pda_program/atmos_alerts
	name = "AtmosAlerter"
	size = 8
	var/list/minor_alerts = list()
	var/list/severe_alerts = list()
	var/temp = null
	var/last_scan = 0

	return_text()
		if(..())
			return

		var/dat = src.return_text_header()

		dat += "<h4>Atmos Alert Manager</h4>"

		dat += "<a href='?src=\ref[src];scan=1'>Scan for Alerts</a><br>"

		var/severe_text
		var/minor_text

		if(severe_alerts.len)
			for(var/zone in severe_alerts)
				severe_text += "<font color='red'><b>[zone]</b></font><br>"
		else
			severe_text = "No priority alerts detected.<br>"

		if(minor_alerts.len)
			for(var/zone in minor_alerts)
				minor_text += "<b>[zone]</b><br>"
		else
			minor_text = "No minor alerts detected.<br>"

		if(!src.temp)
			dat += {"
			<b>Priority Alerts:</b><br>
			[severe_text]
			<br>
			<hr>
			<b>Minor Alerts:</b><br>
			[minor_text]
			<br>"}
		else
			dat += src.temp

		return dat

	Topic(href, href_list)
		if(..())
			return

		if(href_list["scan"] && (world.time >= last_scan + 20))
			src.temp = "Waiting for reply, please hold..."
			src.severe_alerts = list()
			src.minor_alerts = list()

			var/datum/signal/signal = get_free_signal()
			signal.data["sender"] = src.master.net_id
			signal.data["command"] = "report_alerts"

			src.post_signal(signal)

		src.master.add_fingerprint(usr)
		src.master.updateSelfDialog()
		return

	receive_signal(datum/signal/signal)
		if(..() || !src.temp)
			return

		if(signal.data["command"] == "reply_alerts")
			src.temp = null

			if(signal.data["severe_list"])
				src.severe_alerts = splittext(signal.data["severe_list"], ";")
			if(signal.data["minor_list"])
				src.minor_alerts = splittext(signal.data["minor_list"], ";")

			src.master.updateSelfDialog()

		return


//PDA program for displaying engine data and laser output. By FishDance
//Note: Could display weird results if there is more than one engine or PTL around.
/datum/computer/file/pda_program/power_checker
	name = "Power Checker 0.14"
	size = 4

	var/obj/machinery/atmospherics/binary/circulatorTemp/circ1
	var/obj/machinery/atmospherics/binary/circulatorTemp/right/circ2
	var/obj/machinery/power/pt_laser/laser
	var/obj/machinery/power/generatorTemp/generator

	return_text()
		if(..())
			return
		if (!laser)
			laser = locate() in machine_registry[MACHINES_POWER]
		if (!generator)
			generator = locate() in machine_registry[MACHINES_POWER]
		if (!generator || !circ1)
			circ1 = generator.circ1
		if (!generator || !circ2)
			circ2 = generator.circ2


		var/stuff = src.return_text_header()

		if (generator)
			stuff += "<BR><B>Thermo-Electric Generator Status</B><BR>"
			stuff += "Output : [engineering_notation(generator.lastgen)]W<BR>"
			stuff += "<BR>"

			stuff += "<B>Hot Loop</B><BR>"
			stuff += "Temperature Inlet: [round(circ1.air1.temperature, 0.1)] K  Outlet: [round(circ1.air2.temperature, 0.1)] K<BR>"
			stuff += "Pressure Inlet: [round(MIXTURE_PRESSURE(circ1.air1), 0.1)] kPa  Outlet: [round(MIXTURE_PRESSURE(circ1.air2), 0.1)] kPa<BR>"
			stuff += "<BR>"

			stuff += "<B>Cold Loop</B><BR>"
			stuff += "Temperature Inlet: [round(circ2.air1.temperature, 0.1)] K  Outlet: [round(circ2.air2.temperature, 0.1)] K<BR>"
			stuff += "Pressure Inlet: [round(MIXTURE_PRESSURE(circ2.air1), 0.1)] kPa  Outlet: [round(MIXTURE_PRESSURE(circ2.air2), 0.1)] kPa<BR>"
			stuff += "<BR>"
		else
			stuff += "Error! No engine detected!<BR><BR>"
		if (laser)
			stuff += "<B>Power Transmition Laser Status</B><BR>"
			stuff += "Currently Active: "

			if(laser.firing)
				stuff += "Yes<BR>"
			else
				stuff += "No<BR>"

			stuff += "Power Stored: [engineering_notation(laser.charge)]J ([round(100.0*laser.charge/laser.capacity, 0.1)]%)<BR>"
			stuff += "Power Input: [engineering_notation(laser.chargelevel)]W<BR>"
			stuff += "Power Output: [engineering_notation(laser.output)]W<BR>"
		else
			stuff += "Error! No PTL detected!"
		return stuff

//Hydroponics plant monitor.
/datum/computer/file/pda_program/hydro_monitor
	name = "Plant Monitor"
	size = 8

	var/temp = null
	var/last_scan = 0
	var/report_freq = 1447
	var/list/status_reports = list()

	proc/post_status(var/key, var/value, var/key2, var/value2, var/key3, var/value3)
		if(!src.master)
			return

		var/datum/signal/signal = get_free_signal()
		signal.source = src.master
		signal.transmission_method = 1
		signal.data[key] = value
		if(key2)
			signal.data[key2] = value2
		if(key3)
			signal.data[key3] = value3

		signal.data["sender"] = src.master.net_id

		src.post_signal(signal, report_freq)

	init()
		//boutput(world, "<h5>Adding [master]@[master.loc]:[report_freq]")
		radio_controller.add_object(master, "[report_freq]")

	return_text()
		if(..())
			return

		var/dat = src.return_text_header()

		dat += "<h4>Botanical System Monitor</h4>"

		dat += "<a href='?src=\ref[src];scan=1'>Refresh Status</a><br>"

		var/status_text

		dat += "<b>Status Reports:</b><br>"

		if(status_reports.len)
			for(var/i in status_reports)
				status_text += "<b>[i]</b><br>"
		else
			status_text = "No status data loaded.<br>"

		if(!src.temp)
			dat += "[status_text]<br>"
		else
			dat += src.temp

		return dat

	Topic(href, href_list)
		if(..())
			return

		if(href_list["scan"] && (world.time >= last_scan + 20))
			src.temp = "Waiting for reply, please hold..."
			src.status_reports.len = 0

			src.post_status("command","status_req")

		src.master.add_fingerprint(usr)
		src.master.updateSelfDialog()
		return

//Emergency alert program
/datum/computer/file/pda_program/emergency_alert
	name = "Crisis Alert"
	size = 4

	var/tmp/confirm_menu = 0
	var/last_transmission = 0

	return_text()
		if (..())
			return

		var/dat = src.return_text_header()

		dat += "<h4>Emergency Alert System</h4>"

		if (!confirm_menu)
			if (last_transmission && (last_transmission + 3000 > ticker.round_elapsed_ticks))
				dat += "Alert Sent -- Please wait for a response.<br>Additional alerts will be available shortly."

			else
				dat += "<center>Please select alert type:<br>"
				dat += "<a href='?src=\ref[src];alert=1'>Medical Alert</a><br>"
				dat += "<a href='?src=\ref[src];alert=2'>Engineering Alert</a><br>"
				dat += "<a href='?src=\ref[src];alert=3'>Security Alert</a>"

		else
			dat += "<center><b>Please confirm: <a href='?src=\ref[src];confirm=y'>Y</a> / <a href='?src=\ref[src];confirm=n'>N</a></b></center>"

		return dat

	Topic(href, href_list)
		if(..())
			return

		if (href_list["alert"])
			confirm_menu = text2num(href_list["alert"])

		else if (href_list["confirm"])
			if (href_list["confirm"] == "y")
				send_alert(confirm_menu)

			confirm_menu = 0

		src.master.add_fingerprint(usr)
		src.master.updateSelfDialog()
		return

	proc/send_alert(var/mailgroupNum=0)
		if(!src.master || !isnum(mailgroupNum) || (last_transmission && (last_transmission + 3000 > ticker.round_elapsed_ticks)))
			return

		last_transmission = ticker.round_elapsed_ticks
		var/mailgroup
		switch (round(mailgroupNum))
			if (-INFINITY to 1)
				mailgroup = MGD_MEDBAY
			if (2)
				mailgroup = "engineer"
			if (3 to INFINITY)
				mailgroup = MGD_SECURITY

		var/datum/signal/signal = get_free_signal()
		signal.source = src.master
		signal.transmission_method = TRANSMISSION_RADIO
		signal.data["address_1"] = "00000000"
		signal.data["command"] = "text_message"
		signal.data["sender_name"] = src.master.owner
		signal.data["group"] = mailgroup
		var/area/an_area = get_area(src.master)

		if (isAIeye(usr))
			var/turf/eye_loc = get_turf(usr)
			if (!(eye_loc.cameras && eye_loc.cameras.len))
				an_area = get_area(eye_loc)

		signal.data["message"] = "<b><span class='alert'>***CRISIS ALERT*** Location: [an_area ? an_area.name : "nowhere"]!</span></b>"

		src.post_signal(signal)

//Whoever runs this gets to explode.
/datum/computer/file/pda_program/bomb
	name = "BOMB"
	size = 8
	var/detonating = 0

	return_text()
		if(..())
			return

		var/dat = src.return_text_header()

		dat += "<center><b><font color='red'>!!! NOW OVERLOADING BATTERY !!!</font></b></center>"
		dat += "<font size=1><i>Thank you for choosing the Syndicate Robust Electronic Program Bureau</i></font>"

		if(!detonating)
			src.detonating = 1
			SPAWN_DBG(1 SECOND)
				src.master.explode()

		return dat

//oh boy it's old-style detomatixing
/datum/computer/file/pda_program/missile
	name = "MISSILE"
	size = 8
	var/tmp/charges = 0 //Don't let jerks copy the program to have extra charges.
	var/list/pdas = list()

	return_text()
		if(..())
			return

		var/dat = src.return_text_header()
		dat += "<h4>PDA Detonation System V5.9</h4>"

		dat += "<b>Charges remaining:</b> [src.charges]<br>"

		dat += "<font size=2><a href='byond://?src=\ref[src];import=1'>Import PDA List</a></font><br>"
		dat += "<b>Known PDAs</b><br>"

		dat += "<ul>"
		var/count = 0
		for (var/P_id in src.pdas)
			var/P_name = src.pdas[P_id]
			if (!P_name)
				src.pdas -= P_id
				continue
			else if (P_id == src.master.net_id) //I guess this can happen if somebody copies the system file.
				src.pdas -= P_id
				continue

			dat += "<li>PDA-[P_name]"
			dat += " (<a href='byond://?src=\ref[src];detonate=[P_id]'>*DETONATE*</a>)"

			dat += "</li>"
			count++

		dat += "</ul>"

		if (count == 0)
			dat += "None detected.<br>"

		return dat

	Topic(href, href_list)
		if(..())
			return

		if (href_list["import"])
			if(src.master.host_program && istype(src.master.host_program, /datum/computer/file/pda_program/os/main_os))
				src.pdas = src.master.host_program:detected_pdas

		else if(href_list["detonate"])
			if(src.charges <= 0)
				return
			var/target_id = href_list["detonate"]
			if(!(target_id in src.pdas))
				return
			var/datum/signal/signal = get_free_signal()
			signal.data["command"] = "text_message"
			signal.data["message"] = "BOOM"
			signal.data["batt_adjust"] = netpass_syndicate
			signal.data["sender_name"] = pick("George Melons","Farmer Jeff","Jones","The Space King")
			signal.data["sender"] = src.master.net_id
			signal.data["address_1"] = target_id
			src.post_signal(signal)
			src.charges--
			src.pdas -= target_id

		src.master.add_fingerprint(usr)
		src.master.updateSelfDialog()
		return

/datum/computer/file/text/bomb_manual
	name = "Bomb Readme"

	data = {"
Electronic Bomb Program Manual<hr>
Using electronic "Detomatix" MISSILE program is simple!<br>
<ul>
<li>Open PDA MESSENGER and SCAN FOR PDAS!</li>
<li>now run MISSILE.PPROG and select IMPORT PDA LIST</li>
<li>select up to four (4) PDAs you want EXPLODED from DISTANCE!</li>
</ul><br>
Using electronic "Detomatix" BOMB program is perhaps less simple!<br>
<ul>
<li>Copy BOMB.PPROG to main drive, as cart programs cannot be edited!</li>"
<li>Simply rename new BOMB.PPROG to unassuming, safe name such as <i>"PRETTY PLANTS.PPROG"</i></li>
<li>Now, COPY renamed file and open MESSENGER.  Select your target and SEND THEM the file!</li>
<li>Finally, they run file expecting some attractive plants, but instead get EXPLODED PDA!</li>
</ul>
<br>
<b>Caution: </b>Do not run BOMB.PPROG on your own system!  It will explode!
"}

//Security ticket writer - not really a small prog any more but oh well
/datum/computer/file/pda_program/security_ticket
	name = "Ticket Master"
	size = 4
	var/mode = 0
	var/message = null

	return_text()
		if(..())
			return

		var/dat = src.return_text_header()

		if(!message)
			switch(mode)
				if(0) //menu
					dat += "<br><br>\[ <a href='byond://?src=\ref[src];ticket=1'>Issue Ticket</a> \]<br>"
					dat += "\[ <a href='byond://?src=\ref[src];fine=1'>Issue Fine</a> \]<br><br>"
					dat += "\[ <a href='byond://?src=\ref[src];viewtickets=1'>View Tickets</a> \]<br>"
					dat += "View Fines: \[ <a href='byond://?src=\ref[src];viewfinerequests=1'>Requested</a> | <a href='byond://?src=\ref[src];viewoutstandingfines=1'>Unpaid</a> | <a href='byond://?src=\ref[src];viewpaidfines=1'>Paid</a> \]<br>"

				if(1) //tickets
					dat += "<br><br><a href='byond://?src=\ref[src];back=1'>Back</a>"

					dat += "<h4>Ticket List</h4>"

					// this is also bad
					var/list/people_with_tickets = list()
					for (var/datum/ticket/T in data_core.tickets)
						people_with_tickets |= T.target

					for(var/N in people_with_tickets)
						dat += "<b>[N]</b><br><br>"
						for(var/datum/ticket/T in data_core.tickets)
							if(T.target == N)
								dat += "[T.text]<br>"

				if(2) //requested fines
					var/can_approve = 0

					var/PDAowner = src.master.owner
					var/PDAownerjob = "Unknown Job"
					for(var/datum/data/record/G in data_core.general) //there is probably a better way of doing this
						if(G.fields["name"] == PDAowner)
							PDAownerjob = G.fields["rank"]
							break

					if(PDAownerjob in list("Head of Security","Head of Personnel","Captain")) can_approve = 1

					dat += "<br><br><a href='byond://?src=\ref[src];back=1'>Back</a>"

					dat += "<h4>Fine Request List</h4>"

					for (var/datum/fine/F in data_core.fines)
						if(!F.approver)
							dat += "[F.target]: [F.amount] credits<br>Reason: [F.reason]<br>Requested by: [F.issuer] - [F.issuer_job]"
							if(can_approve) dat += "<br><a href='byond://?src=\ref[src];approve=\ref[F]'>Approve Fine</a>"
							dat += "<br><br>"

				if(3) //unpaid fines
					dat += "<br><br><a href='byond://?src=\ref[src];back=1'>Back</a>"

					dat += "<h4>Unpaid Fine List</h4>"

					for (var/datum/fine/F in data_core.fines)
						if(!F.paid && F.approver)
							dat += "[F.target]: [F.amount] credits<br>Reason: [F.reason]<br>[F.issuer != F.approver ? "Requested by: [F.issuer] - [F.issuer_job]<br>Approved by: [F.approver] - [F.approver_job]" : "Issued by: [F.approver] - [F.approver_job]"]<br>Paid: [F.paid_amount] credits<br><br>"

				if(4) //paid fines
					dat += "<br><br><a href='byond://?src=\ref[src];back=1'>Back</a>"

					dat += "<h4>Paid Fine List</h4>"

					for (var/datum/fine/F in data_core.fines)
						if(F.paid)
							dat += "[F.target]: [F.amount] credits<br>Reason: [F.reason]<br>[F.issuer != F.approver ? "Requested by: [F.issuer] - [F.issuer_job]<br>Approved by: [F.approver] - [F.approver_job]" : "Issued by: [F.approver] - [F.approver_job]"]<br><br>"
		else
			dat += "<br><br>[message]<br><br>"
			dat += "<a href='byond://?src=\ref[src];ok=1'>Ok</a>"

		return dat

	Topic(href, href_list)
		if(..())
			return

		if(href_list["ticket"])
			var/PDAowner = src.master.owner
			var/PDAownerjob = "Unknown Job"
			for(var/datum/data/record/G in data_core.general) //there is probably a better way of doing this
				if(G.fields["name"] == PDAowner)
					PDAownerjob = G.fields["rank"]
					break

			var/ticket_target = input(usr, "Ticket recipient:",src.name) as text
			if(!ticket_target) return
			ticket_target = copytext(sanitize(html_encode(ticket_target)), 1, MAX_MESSAGE_LEN)
			var/ticket_reason = input(usr, "Ticket reason:",src.name) as text
			if(!ticket_reason) return
			ticket_reason = copytext(sanitize(html_encode(ticket_reason)), 1, MAX_MESSAGE_LEN)

			var/ticket_text = "[ticket_target] has been officially [pick("cautioned","warned","told off","yelled at","berated","sneered at")] by Nanotrasen Corporate Security for [ticket_reason] on [time2text(world.realtime, "DD/MM/53")].<br>Issued by: [PDAowner] - [PDAownerjob]<br>"

			var/datum/ticket/T = new /datum/ticket()
			T.target = ticket_target
			T.reason = ticket_reason
			T.issuer = PDAowner
			T.issuer_job = PDAownerjob
			T.text = ticket_text
			T.target_byond_key = get_byond_key(T.target)
			T.issuer_byond_key = get_byond_key(T.issuer)
			data_core.tickets += T

			playsound(get_turf(src.master), "sound/machines/printer_thermal.ogg", 50, 1)
			SPAWN_DBG(3 SECONDS)
				var/obj/item/paper/p = unpool(/obj/item/paper)
				p.set_loc(get_turf(src.master))
				p.name = "Official Caution - [ticket_target]"
				p.info = ticket_text
				p.icon_state = "paper_caution"


/*			for(var/datum/data/record/S in data_core.security) //there is probably a better way of doing this too
				if(S.fields["name"] == ticket_target)
					if(S.fields["notes"] == "No notes.")
						S.fields["notes"] = ticket_text
					else S.fields["notes"] += ticket_text
					break*/

		else if(href_list["fine"])
			var/PDAowner = src.master.owner
			var/PDAownerjob = "Unknown Job"
			for(var/datum/data/record/G in data_core.general) //there is probably a better way of doing this
				if(G.fields["name"] == PDAowner)
					PDAownerjob = G.fields["rank"]
					break

			var/ticket_target = input(usr, "Fine recipient:",src.name) as text
			if(!ticket_target) return
			ticket_target = copytext(strip_html(ticket_target),	 1, MAX_MESSAGE_LEN)
			var/has_bank_record = 0
			for(var/datum/data/record/B in data_core.bank) //this too
				if(B.fields["name"] == ticket_target)
					has_bank_record = 1
					break
			if(!has_bank_record)
				message = "Error: No bank records found for [ticket_target]."
				src.master.updateSelfDialog()
				return
			var/ticket_reason = input(usr, "Fine reason:",src.name) as text
			if(!ticket_reason) return
			ticket_reason = copytext(strip_html(ticket_reason), 1, MAX_MESSAGE_LEN)
			var/fine_amount = input(usr, "Fine amount (1-1000):",src.name, 0) as num
			if(!fine_amount) return
			fine_amount = min(fine_amount,1000)
			fine_amount = max(fine_amount,1)

			var/datum/fine/F = new /datum/fine()
			F.target = ticket_target
			F.reason = ticket_reason
			F.amount = fine_amount
			F.issuer = PDAowner
			F.issuer_job = PDAownerjob
			F.target_byond_key = get_byond_key(F.target)
			F.issuer_byond_key = get_byond_key(F.issuer)
			data_core.fines += F

			if(PDAownerjob in list("Head of Security","Head of Personnel","Captain"))
				var/ticket_text = "[ticket_target] has been fined [fine_amount] credits by Nanotrasen Corporate Security for [ticket_reason] on [time2text(world.realtime, "DD/MM/53")].<br>Issued and approved by: [PDAowner] - [PDAownerjob]<br>"
				playsound(get_turf(src.master), "sound/machines/printer_thermal.ogg", 50, 1)
				SPAWN_DBG(3 SECONDS)
					F.approve(PDAowner,PDAownerjob)
					var/obj/item/paper/p = unpool(/obj/item/paper)
					p.set_loc(get_turf(src.master))
					p.name = "Official Fine Notification - [ticket_target]"
					p.info = ticket_text
					p.icon_state = "paper_caution"
			else
				message = "Fine request created, awaiting approval from the Captain, Head of Security or Head of Personnel."

		else if(href_list["approve"])
			var/PDAowner = src.master.owner
			var/PDAownerjob = "Unknown Job"
			for(var/datum/data/record/G in data_core.general) //there is probably a better way of doing this
				if(G.fields["name"] == PDAowner)
					PDAownerjob = G.fields["rank"]
					break

			var/datum/fine/F = locate(href_list["approve"])

			playsound(get_turf(src.master), "sound/machines/printer_thermal.ogg", 50, 1)
			SPAWN_DBG(3 SECONDS)
				F.approve(PDAowner,PDAownerjob)
				var/ticket_text = "[F.target] has been fined [F.amount] credits by Nanotrasen Corporate Security for [F.reason] on [time2text(world.realtime, "DD/MM/53")].<br>Requested by: [F.issuer] - [F.issuer_job]<br>Approved by: [PDAowner] - [PDAownerjob]<br>"
				var/obj/item/paper/p = unpool(/obj/item/paper)
				p.set_loc(get_turf(src.master))
				p.name = "Official Fine Notification - [F.target]"
				p.info = ticket_text
				p.icon_state = "paper_caution"

		else if(href_list["back"])
			mode = 0

		else if(href_list["viewtickets"])
			mode = 1

		else if(href_list["viewfinerequests"])
			mode = 2

		else if(href_list["viewoutstandingfines"])
			mode = 3

		else if(href_list["viewpaidfines"])
			mode = 4

		else if(href_list["ok"])
			message = null

		src.master.add_fingerprint(usr)
		src.master.updateSelfDialog()
		return

//made global so fines can use it too, might also be useful for other stuff
/proc/get_byond_key(var/name)
	for(var/mob/M in mobs)
		if(M.real_name == name && M.key)
			return M.key
	return "N/A"

#define SPAM_DELAY 20
//cargo request
/datum/computer/file/pda_program/cargo_request
	name = "Cargo Request"
	size = 2
	var/tmp/temp = null
	var/tmp/antispam = 0

	return_text()
		if(..())
			return

		var/dat = src.return_text_header()
		if (src.temp)
			dat += "<br>[src.temp]"
		else
			dat += {"<br><B>Supply Ordering Program</B><HR>
			<B>Shipping Budget:</B> [wagesystem.shipping_budget] Credits<BR>
			<A href='?src=\ref[src];viewrequests=1'>View Requests</A><BR>
			<A href='?src=\ref[src];order=1'>Request Items</A><BR>"}
		return dat


	Topic(href, href_list)
		if(..())
			return

		if (href_list["order"])
			src.temp = {"<B>Shipping Budget:</B> [wagesystem.shipping_budget] Credits<BR><HR>
			<B>Please select the Supply Package you would like to request:</B><BR><BR>"}
			for(var/S in childrentypesof(/datum/supply_packs) )
				var/datum/supply_packs/N = new S()
				if(N.hidden || N.syndicate) continue
				// Have to send the type instead of a reference to the obj because it would get caught by the garbage collector. oh well.
				src.temp += {"<A href='?src=\ref[src];doorder=[N.type]'><B><U>[N.name]</U></B></A><BR>
				<B>Cost:</B> [N.cost] Credits<BR>
				<B>Contents:</B> [N.desc]<BR><BR>"}
			src.temp += "<BR><A href='?src=\ref[src];mainmenu=1'>OK</A>"

		else if (href_list["doorder"])
			var/datum/supply_order/O = new/datum/supply_order ()
			var/supplytype = href_list["doorder"]
			if (!dd_hasprefix(supplytype, "/datum/supply_packs"))
				qdel(O)
				return
			var/datum/supply_packs/P = new supplytype ()

			if(P.syndicate || P.hidden)
				// Get that jerk
				trigger_anti_cheat(usr, "tried to href exploit order packs on [src]")
				return

			O.object = P
			O.orderedby = src.master.owner
			O.console_location = get_area(src.master)
			shippingmarket.supply_requests += O
			src.temp = "Request sent to Supply Console. The Quartermasters will process your request as soon as possible.<BR>"

			// pda alert ////////
			if (!antispam || (antispam < (ticker.round_elapsed_ticks)) )
				antispam = ticker.round_elapsed_ticks + SPAM_DELAY
				var/datum/radio_frequency/transmit_connection = radio_controller.return_frequency("1149")
				var/datum/signal/pdaSignal = get_free_signal()
				pdaSignal.data = list("address_1"="00000000", "command"="text_message", "sender_name"="CARGO-MAILBOT",  "group"=MGD_CARGO, "sender"="00000000", "message"="Notification: [O.object] requested by [O.orderedby] at [O.console_location].")
				pdaSignal.transmission_method = TRANSMISSION_RADIO
				if(transmit_connection != null)
					transmit_connection.post_signal(src, pdaSignal)
			//////////////////
			src.temp += "<BR><A href='?src=\ref[src];mainmenu=1'>OK</A>"

		else if (href_list["viewrequests"])
			src.temp = "<B>Current Requests:</B><BR><BR>"
			for(var/S in shippingmarket.supply_requests)
				var/datum/supply_order/SO = S
				src.temp += "[SO.object.name] requested by [SO.orderedby] from [SO.console_location].<BR>"
			src.temp += "<BR><A href='?src=\ref[src];mainmenu=1'>OK</A>"

		else if (href_list["mainmenu"])
			src.temp = null

		src.master.add_fingerprint(usr)
		src.master.updateSelfDialog()
		return
#undef SPAM_DELAY

/datum/computer/file/pda_program/station_name
	name = "Station Namer"
	size = 2

	return_text()
		if(..())
			return

		var/dat = src.return_text_header()

		dat += "<h4>Station Namer Delux 3000</h4>"

		if (station_name_changing)
			var/nextName = lastStationNameChange + stationNameChangeDelay
			if (nextName > world.timeofday)
				dat += "<b>The station naming coils are recharging, you must wait [(nextName - world.timeofday) / 10] seconds.</b><br><br>"
			else
				dat += "<a href='?src=\ref[src];change=1'>Change Name</a><br><br>"
		else
			dat += "<b>Cosmic interference is preventing station name changes right now. Yep.</b><br><br>"

		dat += "Current station name: [station_name()]"

		return dat

	Topic(href, href_list)
		if(..())
			return

		if (href_list["change"])
			if (station_name_changing)
				usr.openStationNameChangeWindow(src, "submitChange=1")
			else
				src.master.updateSelfDialog()

		if (href_list["submitChange"])
			if (station_name_changing)
				var/nextName = lastStationNameChange + stationNameChangeDelay
				if (nextName > world.timeofday)
					alert("You must wait for the station naming coils to recharge! Did space school teach you nothing?!")
					usr.Browse(null, "window=stationnamechanger")
					src.master.updateSelfDialog()
					return

				lastStationNameChange = world.timeofday
				var/newName = href_list["newName"]

				if (set_station_name(usr, newName))
					command_alert("The new station name is [station_name]", "Station Naming Ceremony Completion Detection Algorithm")

			usr.Browse(null, "window=stationnamechanger")
			src.master.updateSelfDialog()

		src.master.add_fingerprint(usr)
		return
