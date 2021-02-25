// Network Diagnostics PDA cart programs
// pingtool
// packet sniffer
// packet sender

/datum/computer/file/pda_program/pingtool
	name = "Ping Tool"
	size = 8
	var/send_freq = 1149 //Frequency signal is sent at, should be kept within normal radio ranges.
	var/range = 32
	var/mode = 0
	var/tmp/list/result


	init()
		radio_controller.add_object(master, "[send_freq]")

	return_text()
		if(..())
			return

		var/dat = src.return_text_header()

		dat +="<h4>Wireless Ping Tool</h4>"

		dat += "Device ID: \[[master.net_id]]<br>"

		dat += {"Freq: <tt>
<a href='byond://?src=\ref[src];adj_freq=-100'>-</a>
<a href='byond://?src=\ref[src];adj_freq=-10'>-</a>
<a href='byond://?src=\ref[src];adj_freq=-2'>-</a>
<a href='byond://?src=\ref[src];set_freq=1'>[format_frequency(send_freq)]</a>
<a href='byond://?src=\ref[src];adj_freq=2'>+</a>
<a href='byond://?src=\ref[src];adj_freq=10'>+</a>
<a href='byond://?src=\ref[src];adj_freq=100'>+</a></tt> | "}

		dat += "Range: <tt>"
		switch(range)
			if(16)
				dat += "- Low <a href='byond://?src=\ref[src];range=1'>+</A>"
			if(32)
				dat += "<A href='byond://?src=\ref[src];range=-1'>-</A> Med <A href='byond://?src=\ref[src];range=1'>+</A>"
			if(64)
				dat += "<A href='byond://?src=\ref[src];range=-1'>-</A> Max +"
		dat +="</tt><br>"

		if(mode == 0)
			dat += "<a href='byond://?src=\ref[src];send=1'>Send ping</A><BR><HR>"

			if(length(result))
				for(var/t in result)
					dat+=t

			else
				dat += "<i>No devices found</i><br>"

		else
			dat += "<i>Listening...</i><br>"


		return dat

	Topic(href, href_list)
		if(..())
			return

		if (href_list["send"])
			SPAWN_DBG( 0 )
				if(result) result.Cut()
				var/datum/signal/signal = get_free_signal()
				signal.source = src
				signal.transmission_method = TRANSMISSION_RADIO
				signal.data["address_1"] = "ping"
				signal.data["sender"] = master.net_id

				mode = 1
				master.updateSelfDialog()
				src.post_signal(signal,"[send_freq]")
				sleep(2 SECONDS)
				mode = 0
				master.updateSelfDialog()

		else if (href_list["range"])
			var/rd = text2num(href_list["range"])
			switch(range)
				if(16)
					range = 32
				if(32)
					if(rd>0)
						range = 64
					else
						range = 16
				if(64)
					range = 32

		else if (href_list["adj_freq"])
			var/new_freq = sanitize_frequency_diagnostic(send_freq + text2num(href_list["adj_freq"]))
			adjust_frequency(send_freq, new_freq)
			send_freq = new_freq

		else if (href_list["set_freq"])
			var/new_freq = input(usr,"Target frequency (1141-1489):","Enter target frequency",send_freq) as num
			new_freq = sanitize_frequency_diagnostic(new_freq)
			adjust_frequency(send_freq, new_freq)
			send_freq = new_freq

		src.master.add_fingerprint(usr)
		src.master.updateSelfDialog()
		return


	receive_signal(datum/signal/signal)

		//boutput(world, "[master.net_id] Recieved signal from [signal.source] ([get_dist(master,signal.source)])")
		//
		//for(var/x in signal.data)
		//	boutput(world, "[x] = [signal.data[x]]")
		//boutput(world, "---------------")

		if(..())
			return


		if(signal.data["address_1"] == master.net_id && signal.data["command"] == "ping_reply")
			if(!result)
				result = new/list()
			if(get_dist(master,signal.source) <= range)
				result += "[signal.data["device"]] \[[signal.data["netid"]]\] [signal.data["data"]]<BR>"

	proc/adjust_frequency(var/old_freq, var/new_freq)
		if (old_freq != 1149) // don't unregister the PDA itself
			radio_controller.remove_object(master, "[old_freq]")
		radio_controller.add_object(master, "[new_freq]")



/datum/computer/file/pda_program/packet_sniffer
	name = "Packet Sniffer"
	size = 16
	var/scan_freq = 1149
	var/range = 32
	var/mode = 0
	var/tmp/list/result

	init()
		radio_controller.add_object(master, "[scan_freq]")

	return_text()
		if(..())
			return

		var/dat = src.return_text_header()

		dat +="<h4>Wireless Network Sniffer</h4>"

		dat += {"Freq: <tt>
<a href='byond://?src=\ref[src];adj_freq=-100'>-</a>
<a href='byond://?src=\ref[src];adj_freq=-10'>-</a>
<a href='byond://?src=\ref[src];adj_freq=-2'>-</a>
<a href='byond://?src=\ref[src];set_freq=1'>[format_frequency(scan_freq)]</a>
<a href='byond://?src=\ref[src];adj_freq=2'>+</a>
<a href='byond://?src=\ref[src];adj_freq=10'>+</a>
<a href='byond://?src=\ref[src];adj_freq=100'>+</a></tt> | "}

		dat += "Range: <tt>"
		switch(range)
			if(16)
				dat += "- Low <a href='byond://?src=\ref[src];range=1'>+</A>"
			if(32)
				dat += "<A href='byond://?src=\ref[src];range=-1'>-</A> Med <A href='byond://?src=\ref[src];range=1'>+</A>"
			if(64)
				dat += "<A href='byond://?src=\ref[src];range=-1'>-</A> Max +"
		dat +="</tt><br>"

		if(mode == 0)
			dat += "<A href='byond://?src=\ref[src];run=1'>Start</A>"
		else
			dat += "<A href='byond://?src=\ref[src];run=0'>Stop</A>"

		dat += " <A href='byond://?src=\ref[src];clear=1'>Clear</A><BR><HR>"

		if(result)
			for(var/r in result)
				dat += "<tt>[r]</tt><BR>"

		dat +="<HR>"
		if(mode == 0)
			dat += "<A href='byond://?src=\ref[src];run=1'>Start</A>"
		else
			dat += "<A href='byond://?src=\ref[src];run=0'>Stop</A>"

		dat += " <A href='byond://?src=\ref[src];clear=1'>Clear</A><BR>"


		return dat

	Topic(href, href_list)
		if(..())
			return

		if (href_list["adj_freq"])
			var/new_freq = sanitize_frequency_diagnostic(scan_freq + text2num(href_list["adj_freq"]))
			adjust_frequency(scan_freq, new_freq)
			scan_freq = new_freq

		else if (href_list["set_freq"])
			var/new_freq = input(usr,"Target frequency (1141-1489):","Enter target frequency",scan_freq) as num
			new_freq = sanitize_frequency_diagnostic(new_freq)
			adjust_frequency(scan_freq, new_freq)
			scan_freq = new_freq

		else if (href_list["run"])
			mode = text2num(href_list["run"])

		else if (href_list["clear"])
			if(result)
				result.Cut()

		else if (href_list["range"])
			var/rd = text2num(href_list["range"])
			switch(range)
				if(16)
					range = 32
				if(32)
					if(rd>0)
						range = 64
					else
						range = 16
				if(64)
					range = 32




		src.master.add_fingerprint(usr)
		src.master.updateSelfDialog()
		return

	network_hook(datum/signal/signal, rx_method, rx_freq)

		if(!mode)
			return


		/////
		//boutput(world, "[master.net_id] Recieved signal @[rx_freq] from [signal.source] ([get_dist(master,signal.source)])")
		//for(var/x in signal.data)
		//	boutput(world, "[x] = [signal.data[x]]")
		//boutput(world, "----")
		/////

		if(rx_freq != "[scan_freq]")
			return


		if(get_dist(master, signal.source) > range)
			return

		//boutput(world, "====")


		if(!result)
			result = new/list()
		var/t = "\[[time2text(world.timeofday,"mm:ss")]:[(world.timeofday%10)]\]:"

		var/t2 = ""
		for(var/d in signal.data)
			t2 += "[d]=[signal.data[d]]; "

		// look for detomax packet and obscure it (so it won't be easy to copy)
		if(signal.data["command"] == "text_message" && signal.data["batt_adjust"] == netpass_syndicate)
			t += "ERR_12939_CORRUPT_PACKET:"
			t2 = stars(t2, 15)

		result += "[t][t2]"


		if(result.len > 100)
			result.Cut(1,2)
		master.updateSelfDialog()


	proc/adjust_frequency(var/old_freq, var/new_freq)
		if (old_freq != 1149) // don't unregister the PDA itself
			radio_controller.remove_object(master, "[old_freq]")
		radio_controller.add_object(master, "[new_freq]")



/datum/computer/file/pda_program/packet_sender
	name = "Packet Sender"
	size = 8
	var/send_freq = 1149
	var/range = 32
	var/tmp/list/keyval
	var/mode = 0

#define MAX_PACKET_KEYS 10

	init()
		radio_controller.add_object(master, "[send_freq]")

	return_text()
		if(..())
			return

		var/dat = src.return_text_header()

		dat +="<h4>Manual Packet Sender</h4>"

		dat += {"Freq: <tt>
<a href='byond://?src=\ref[src];adj_freq=-100'>-</a>
<a href='byond://?src=\ref[src];adj_freq=-10'>-</a>
<a href='byond://?src=\ref[src];adj_freq=-2'>-</a>
<a href='byond://?src=\ref[src];set_freq=1'>[format_frequency(send_freq)]</a>
<a href='byond://?src=\ref[src];adj_freq=2'>+</a>
<a href='byond://?src=\ref[src];adj_freq=10'>+</a>
<a href='byond://?src=\ref[src];adj_freq=100'>+</a></tt> | "}

		dat += "Range: <tt>"
		switch(range)
			if(16)
				dat += "- Low <a href='byond://?src=\ref[src];range=1'>+</A>"
			if(32)
				dat += "<A href='byond://?src=\ref[src];range=-1'>-</A> Med <A href='byond://?src=\ref[src];range=1'>+</A>"
			if(64)
				dat += "<A href='byond://?src=\ref[src];range=-1'>-</A> Max +"
		dat +="</tt><br><HR><UL><TT>"

		for(var/key in keyval)
			dat += "<LI>[key] ... [keyval[key]]"
			dat += " <small><A href='byond://?src=\ref[src];edit=1;code=[key]'>(edit)</A>"
			dat += " <A href='byond://?src=\ref[src];delete=1;code=[key]'>(delete)</A></small><BR>"
		dat += "</UL><small><A href='byond://?src=\ref[src];add=1;'>(add new)</A></small><BR>"
		dat += "</TT>"

		dat +="<HR>"
		if(mode)
			dat += "<I>Sending...</I><BR>"
		else
			dat += " <A href='byond://?src=\ref[src];send=1'>Send Packet</A><BR>"


		return dat

	Topic(href, href_list)
		if(..())
			return

		if (href_list["adj_freq"])
			send_freq = sanitize_frequency_diagnostic(send_freq + text2num(href_list["adj_freq"]))

		else if (href_list["set_freq"])
			var/new_freq = input(usr,"Target frequency (1141-1489):","Enter target frequency",send_freq) as num
			new_freq = sanitize_frequency_diagnostic(new_freq)
			send_freq = new_freq


		else if(href_list["edit"])
			var/codekey = href_list["code"]

			var/newkey = copytext(ckeyEx( input("Enter Packet Key", "Packet Sender", codekey) as text|null ), 1, 16)
			if(!newkey)
				return

			if (!src.master || !in_range(src.master, usr) && src.master.loc != usr)
				return

			if(!(src.holder in src.master))
				return

			var/codeval = html_decode(keyval[codekey])
			var/newval = copytext(strip_html( input("Enter Packet Value", "Packer Sender", codeval) as text|null ), 1, 255)
			if(!newval)
				newval = codekey
				return

			if (!src.master || !in_range(src.master, usr) && src.master.loc != usr)
				return

			if(!(src.holder in src.master))
				return

			keyval.Remove(codekey)
			keyval[newkey] = newval


		else if(href_list["delete"])
			var/codekey = href_list["code"]
			keyval.Remove(codekey)

		else if(href_list["add"])

			if(keyval && (keyval.len >= MAX_PACKET_KEYS))
				return

			var/newkey = copytext(ckeyEx( input("Enter Packet Key", "Packet Sender") as text|null ), 1, 16)
			if(!newkey)
				return

			if (!src.master || !in_range(src.master, usr) && src.master.loc != usr)
				return

			if(!(src.holder in src.master))
				return

			var/newval = copytext(strip_html( input("Enter Packet Value", "Packer Sender") as text|null ), 1, 255)
			if(!newval)
				newval = "1"
				return

			if(!keyval)
				keyval = new()

			if (!src.master || !in_range(src.master, usr) && src.master.loc != usr)
				return

			if(!(src.holder in src.master))
				return

			keyval[newkey] = newval

		else if (href_list["send"])
			mode = 1
			SPAWN_DBG( 0 )


				var/datum/signal/signal = get_free_signal()
				signal.source = src
				signal.transmission_method = TRANSMISSION_RADIO

				for(var/key in keyval)
					signal.data[key] = keyval[key]

				if ((send_freq == 1149) && (!isnull(signal.data["message"])) && (signal.data["command"] == "text_message"))
					logTheThing("pdamsg", null, null, "<i><b>[src.master.owner]'s PDA used by [src.master.loc.name] ([src.master.fingerprintslast]) (as [isnull(signal.data["sender_name"]) ? "Nobody" : signal.data["sender_name"]]) &rarr; [isnull(signal.data["address_1"]) ? "Everybody" : "[signal.data["address_1"]]"]:</b></i> [signal.data["message"]]")

				src.post_signal(signal,"[send_freq]")
				master.updateSelfDialog()
				sleep(1 SECOND)
				mode = 0
				master.updateSelfDialog()



		else if (href_list["range"])
			var/rd = text2num(href_list["range"])
			switch(range)
				if(16)
					range = 32
				if(32)
					if(rd>0)
						range = 64
					else
						range = 16
				if(64)
					range = 32



		src.master.add_fingerprint(usr)
		src.master.updateSelfDialog()
		return


#undef MAX_PACKET_KEYS


/proc/sanitize_frequency_diagnostic(var/f)
	f = round(f)
	f = max(1141, f) // 114.1
	f = min(1489, f) // 148.9
	if ((f % 2) == 0)
		f += 1
	return f

