//CONTENTS
//Base bot control program
//Secbot control
//Mulebot control


/datum/computer/file/pda_program/bot_control
	name = "bot control base"

	var/list/botlist = list()		// list of bots
	var/obj/machinery/bot/active 	// the active bot; if null, show bot list
	var/list/botstatus			// the status signal sent by the bot

	var/control_freq = 1447 //Just for sending, adjust what the actual pda hooks to for receive

	proc/post_status(var/freq, var/key, var/value, var/key2, var/value2, var/key3, var/value3)
		if(!src.master)
			return

		var/datum/signal/signal = get_free_signal()
		signal.source = src
		signal.transmission_method = 1
		signal.data[key] = value
		if(key2)
			signal.data[key2] = value2
		if(key3)
			signal.data[key3] = value3

		src.post_signal(signal, freq)

	init()
		//boutput(world, "<h5>Adding [master]@[master.loc]:[master.bot_freq],[master.beacon_freq]")
		radio_controller.add_object(master, "[master.bot_freq]")
		radio_controller.add_object(master, "[master.beacon_freq]")

/datum/computer/file/pda_program/bot_control/secbot
	name = "Securitron Access"
	var/header_thing = "Securitron Interlink"
	size = 8.0
	var/list/inactive_commands = list()
	var/list/active_commands = list()

	New(obj/holding)
		. = ..()
		inactive_commands = list("<BR><A href='byond://?src=\ref[src];op=scanbots'>Scan for active bots</A><BR>")
		active_commands = list("<BR>\[<A href='byond://?src=\ref[src];op=stop'>Stop Patrol</A>\] ",\
		"\[<A href='byond://?src=\ref[src];op=go'>Start Patrol</A>\] ",\
		"\[<A href='byond://?src=\ref[src];op=summon'>Summon Bot</A>\]<BR>",\
		"<HR><A href='byond://?src=\ref[src];op=botlist'>Return to bot list</A>")

	return_text()
		if(..())
			return

		. = src.return_text_header()

		. += "<h4>[header_thing]</h4>"

		if(!src.active)
			// list of bots
			if(!src.botlist || (src.botlist && src.botlist.len==0))
				. += "No bots found.<BR>"

			else
				for(var/obj/machinery/bot/secbot/B in src.botlist)
					. += "<A href='byond://?src=\ref[src];op=control;bot=\ref[B]'>[B] at [get_area(B)]</A><BR>"

			for(var/cmd in inactive_commands)
				. += cmd

		else	// bot selected, control it


			. += "<B>[src.active]</B><BR> Status: (<A href='byond://?src=\ref[src];op=control;bot=\ref[src.active]'><i>refresh</i></A>)<BR>"

			if(!src.botstatus)
				. += "Waiting for response...<BR>"
			else

				. += "Location: [src.botstatus["loca"] ]<BR>"
				. += "Mode: "

				switch(src.botstatus["mode"])
					if(0)
						. += "Ready"
					if(1)
						. += "Apprehending target"
					if(2,3)
						. += "Arresting target"
					if(4)
						. += "Starting patrol"
					if(5)
						. += "On patrol"
					if(6)
						. += "Responding to summons"

			for(var/cmd in active_commands)
				. += cmd


	Topic(href, href_list)
		if(..())
			return

		var/obj/item/device/pda2/PDA = src.master
		var/turf/summon_turf = get_turf(PDA)
		if (isAIeye(usr))
			summon_turf = get_turf(usr)
			if (!(summon_turf.cameras && summon_turf.cameras.len))
				summon_turf = get_turf(PDA)

		switch(href_list["op"])

			if("control")
				active = locate(href_list["bot"])
				post_status(control_freq, "command", "bot_status", "active", active)

			if("scanbots")		// find all bots
				botlist = null
				post_status(control_freq, "command", "bot_status")

			if("botlist")
				active = null
				PDA.updateSelfDialog()

			if("stop", "go")
				post_status(control_freq, "command", href_list["op"], "active", active)
				post_status(control_freq, "command", "bot_status", "active", active)

			if("summon")
				post_status(control_freq, "command", "summon", "active", active, "target", summon_turf )
				post_status(control_freq, "command", "bot_status", "active", active)

			if("proc")
				post_status(control_freq, "command", "proc", "active", active)
				post_status(control_freq, "command", "bot_status", "active", active)

			if("summonall")
				if (!botlist.len)
					return
				for(var/obj/machinery/bot/secbot/bot in src.botlist)
					post_status(control_freq, "command", "summon", "active", bot, "target", summon_turf )
					post_status(control_freq, "command", "bot_status", "active", bot)

		return

	receive_signal(datum/signal/signal)
		if(..())
			return
/*
		boutput(world, "recvd:[src.master] : [signal.source]")
		for(var/d in signal.data)
			boutput(world, "- [d] = [signal.data[d]]")
*/
		if(signal.data["type"] == "secbot")
			if(!botlist)
				botlist = new()

			botlist |= signal.source

			if(active == signal.source)
				var/list/b = signal.data
				botstatus = b.Copy()

			src.master.updateSelfDialog()

		return

/datum/computer/file/pda_program/bot_control/secbot/pro
	name = "Securitron Access PRO"
	size = 8.0
	header_thing = "Securitron Interlink PRO"

	New(obj/holding)
		. = ..()
		inactive_commands = list("<BR><A href='byond://?src=\ref[src];op=scanbots'>Scan for active bots</A><BR>",\
	"<BR><A href='byond://?src=\ref[src];op=summonall'>Summon all active bots</A><BR>")
		active_commands = list("<BR>\[<A href='byond://?src=\ref[src];op=stop'>Stop Patrol</A>\] ",\
		"\[<A href='byond://?src=\ref[src];op=go'>Start Patrol</A>\] ",\
		"\[<A href='byond://?src=\ref[src];op=summon'>Summon Bot</A>\]<BR>",\
		"\[<A href='byond://?src=\ref[src];op=proc'>Force Bot Action</A>\]<BR>",\
		"<HR><A href='byond://?src=\ref[src];op=botlist'>Return to bot list</A>")

/datum/computer/file/pda_program/bot_control/mulebot
	name = "MULE Bot Control"
	size = 16.0
	var/list/beacons

	return_text()
		if(..())
			return

		. = list(src.return_text_header())
		. += "<h4>M.U.L.E. bot Interlink V0.8</h4>"

		if(!src.active)
			// list of bots
			if(!src.botlist || (src.botlist && src.botlist.len==0))
				. += "No bots found.<BR>"

			else
				for(var/obj/machinery/bot/mulebot/B in src.botlist)
					. += "<A href='byond://?src=\ref[src];op=control;bot=\ref[B]'>[B] at [get_area(B)]</A><BR>"



			. += "<BR><A href='byond://?src=\ref[src];op=scanbots'>Scan for active bots</A><BR>"

		else	// bot selected, control it


			. += "<B>[src.active]</B><BR> Status: (<A href='byond://?src=\ref[src];op=control;bot=\ref[src.active]'><i>refresh</i></A>)<BR>"

			if(!src.botstatus)
				. += "Waiting for response...<BR>"
			else

				. += "Location: [src.botstatus["loca"] ]<BR>"
				. += "Mode: "

				switch(src.botstatus["mode"])
					if(0)
						. += "Ready"
					if(1)
						. += "Loading/Unloading"
					if(2)
						. += "Navigating to Delivery Location"
					if(3)
						. += "Navigating to Home"
					if(4)
						. += "Waiting for clear path"
					if(5,6)
						. += "Calculating navigation path"
					if(7)
						. += "Unable to locate destination"
				var/obj/storage/crate/C = src.botstatus["load"]
				. += "<BR>Current Load: [ !C ? "<i>none</i>" : "[C.name] (<A href='byond://?src=\ref[src];op=unload'><i>unload</i></A>)" ]<BR>"
				. += "<A href='byond://?src=\ref[src];op=scanbeacons'>Scan destinations</a><br>"
				. += "Destination: [!src.botstatus["dest"] ? "<i>none</i>" : src.botstatus["dest"] ] (<A href='byond://?src=\ref[src];op=setdest'><i>set</i></A>)<BR>"
				. += "Power: [src.botstatus["powr"]]%<BR>"
				. += "Home: [!src.botstatus["home"] ? "<i>none</i>" : src.botstatus["home"] ]<BR>"
				. += "Auto Return Home: [src.botstatus["retn"] ? "<B>On</B> <A href='byond://?src=\ref[src];op=retoff'>Off</A>" : "(<A href='byond://?src=\ref[src];op=reton'><i>On</i></A>) <B>Off</B>"]<BR>"
				. += "Auto Pickup Crate: [src.botstatus["pick"] ? "<B>On</B> <A href='byond://?src=\ref[src];op=pickoff'>Off</A>" : "(<A href='byond://?src=\ref[src];op=pickon'><i>On</i></A>) <B>Off</B>"]<BR><BR>"

				. += "\[<A href='byond://?src=\ref[src];op=stop'>Stop</A>\] "
				. += "\[<A href='byond://?src=\ref[src];op=go'>Proceed</A>\] "
				. += "\[<A href='byond://?src=\ref[src];op=home'>Return Home</A>\]<BR>"
				. += "<HR><A href='byond://?src=\ref[src];op=botlist'>Return to bot list</A>"
		. = jointext(., "")

	Topic(href, href_list)
		if(..())
			return

		var/obj/item/device/pda2/PDA = src.master
		var/cmd = "command"
		if(active) cmd = "command_[ckey(active.suffix)]"

		switch(href_list["op"])

			if("control")
				active = locate(href_list["bot"])
				post_status(control_freq, cmd, "bot_status")

			if("scanbots")		// find all bots
				botlist = null
				post_status(control_freq, "command", "bot_status")

			if("scanbeacons")
				beacons = null
				src.post_status(src.master.beacon_freq, "findbeacon", "delivery")

			if("botlist")
				active = null
				PDA.updateSelfDialog()

			if("unload")
				post_status(control_freq, cmd, "unload")
				post_status(control_freq, cmd, "bot_status")
			if("setdest")
				if(beacons)
					var/dest = input("Select Bot Destination", "Mulebot [active.suffix] Interlink", active:destination) as null|anything in beacons
					if(dest)
						post_status(control_freq, cmd, "target", "destination", dest)
						post_status(control_freq, cmd, "bot_status")

			if("retoff")
				post_status(control_freq, cmd, "autoret", "value", 0)
				post_status(control_freq, cmd, "bot_status")
			if("reton")
				post_status(control_freq, cmd, "autoret", "value", 1)
				post_status(control_freq, cmd, "bot_status")

			if("pickoff")
				post_status(control_freq, cmd, "autopick", "value", 0)
				post_status(control_freq, cmd, "bot_status")
			if("pickon")
				post_status(control_freq, cmd, "autopick", "value", 1)
				post_status(control_freq, cmd, "bot_status")

			if("stop", "go", "home")
				post_status(control_freq, cmd, href_list["op"])
				post_status(control_freq, cmd, "bot_status")
		return

	receive_signal(datum/signal/signal)
		if(..())
			return

		if(signal.data["type"] == "mulebot")
			if(!botlist)
				botlist = new()

			botlist |= signal.source

			if(active == signal.source)
				var/list/b = signal.data
				botstatus = b.Copy()

			src.master.updateSelfDialog()

		else if(signal.data["beacon"])
			if(!beacons)
				beacons = new()

			beacons[signal.data["beacon"] ] = signal.source

		return
