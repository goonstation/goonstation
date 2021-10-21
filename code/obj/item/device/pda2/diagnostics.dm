// Network Diagnostics PDA cart programs
// pingtool
// packet sniffer
// packet sender

/datum/computer/file/pda_program/pingtool
	name = "Ping Tool"
	size = 8
	var/send_freq = FREQ_PDA //Frequency signal is sent at, should be kept within normal radio ranges.
	var/range = 32
	var/mode = 0
	var/tmp/list/result

	on_activated(obj/item/device/pda2/pda)
		pda.AddComponent(
			/datum/component/packet_connected/radio, \
			"ping",\
			send_freq, \
			pda.net_id, \
			null, \
			null \
		)
		RegisterSignal(pda, COMSIG_MOVABLE_RECEIVE_PACKET, .proc/receive_signal)

	on_deactivated(obj/item/device/pda2/pda)
		qdel(get_radio_connection_by_id(pda, "ping"))
		UnregisterSignal(pda, COMSIG_MOVABLE_RECEIVE_PACKET)

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
				signal.data["address_1"] = "ping"
				signal.data["sender"] = master.net_id

				mode = 1
				master.updateSelfDialog()
				SEND_SIGNAL(src.master, COMSIG_MOVABLE_POST_RADIO_PACKET, signal, null, "ping")
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


	proc/receive_signal(obj/item/device/pda2/pda, datum/signal/signal, transmission_method, range, connection_id)
		if(signal.data["address_1"] == master.net_id && signal.data["command"] == "ping_reply")
			if(!result)
				result = new/list()
			if(get_dist(master,signal.source) <= range)
				result += "[signal.data["device"]] \[[signal.data["netid"]]\] [signal.data["data"]]<BR>"

	proc/adjust_frequency(var/old_freq, var/new_freq)
		get_radio_connection_by_id(src.master, "ping").update_frequency(new_freq)



/datum/computer/file/pda_program/packet_sniffer
	name = "Packet Sniffer"
	size = 16
	var/scan_freq = FREQ_PDA
	var/range = 32
	var/mode = 0
	var/tmp/list/result

	on_activated(obj/item/device/pda2/pda)
		pda.AddComponent(
			/datum/component/packet_connected/radio, \
			"sniffer",\
			scan_freq, \
			pda.net_id, \
			null, \
			null, \
			TRUE \
		)
		RegisterSignal(pda, COMSIG_MOVABLE_RECEIVE_PACKET, .proc/receive_signal)

	on_deactivated(obj/item/device/pda2/pda)
		qdel(get_radio_connection_by_id(pda, "sniffer"))
		UnregisterSignal(pda, COMSIG_MOVABLE_RECEIVE_PACKET)

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

	proc/receive_signal(obj/item/device/pda2/pda, datum/signal/signal, transmission_method, range, connection_id)
		if(!mode || connection_id != "sniffer")
			return

		if(!IN_RANGE(master, signal.source, src.range))
			return

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

		// ruck kit lock packets use this
		if(signal.encryption)
			t += "[signal.encryption]"
			t2 = stars(t2, 15)

		result += "[t][t2]"


		if(result.len > 100)
			result.Cut(1,2)
		master.updateSelfDialog()


	proc/adjust_frequency(var/old_freq, var/new_freq)
		get_radio_connection_by_id(src.master, "sniffer").update_frequency(new_freq)

/datum/computer/file/pda_program/packet_sender
	name = "Packet Sender"
	size = 8
	var/send_freq = FREQ_PDA
	var/range = 32
	var/tmp/list/keyval
	var/mode = 0

#define MAX_PACKET_KEYS 10

	on_activated(obj/item/device/pda2/pda)
		pda.AddComponent(
			/datum/component/packet_connected/radio, \
			"sender",\
			send_freq, \
			pda.net_id, \
			null, \
			null, \
			TRUE \
		)

	on_deactivated(obj/item/device/pda2/pda)
		qdel(get_radio_connection_by_id(pda, "sender"))

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
			get_radio_connection_by_id(src.master, "sender").update_frequency(send_freq)

		else if (href_list["set_freq"])
			var/new_freq = input(usr,"Target frequency (1141-1489):","Enter target frequency",send_freq) as num
			new_freq = sanitize_frequency_diagnostic(new_freq)
			send_freq = new_freq
			get_radio_connection_by_id(src.master, "sender").update_frequency(send_freq)


		else if(href_list["edit"])
			var/codekey = href_list["code"]

			var/newkey = copytext(ckeyEx( input("Enter Packet Key", "Packet Sender", codekey) as text|null ), 1, 16)
			if(!newkey)
				return

			if (!src.master?.is_user_in_interact_range(usr))
				return

			if(!(src.holder in src.master))
				return

			var/codeval = html_decode(keyval[codekey])
			var/newval = copytext(strip_html( input("Enter Packet Value", "Packer Sender", codeval) as text|null ), 1, 255)
			if(!newval)
				newval = codekey
				return

			if (!src.master?.is_user_in_interact_range(usr))
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

			if (!src.master?.is_user_in_interact_range(usr))
				return

			if(!(src.holder in src.master))
				return

			var/newval = copytext(strip_html( input("Enter Packet Value", "Packer Sender") as text|null ), 1, 255)
			if(!newval)
				newval = "1"
				return

			if(!keyval)
				keyval = new()

			if (!src.master?.is_user_in_interact_range(usr))
				return

			if(!(src.holder in src.master))
				return

			keyval[newkey] = newval

		else if (href_list["send"])
			mode = 1
			SPAWN_DBG( 0 )


				var/datum/signal/signal = get_free_signal()
				signal.source = src

				for(var/key in keyval)
					signal.data[key] = keyval[key]

				if ((send_freq == FREQ_PDA) && (!isnull(signal.data["message"])) && (signal.data["command"] == "text_message"))
					logTheThing("pdamsg", null, null, "<i><b>[src.master.owner]'s PDA used by [src.master.loc.name] ([src.master.fingerprintslast]) (as [isnull(signal.data["sender_name"]) ? "Nobody" : signal.data["sender_name"]]) &rarr; [isnull(signal.data["address_1"]) ? "Everybody" : "[signal.data["address_1"]]"]:</b></i> [signal.data["message"]]")

				SEND_SIGNAL(src.master, COMSIG_MOVABLE_POST_RADIO_PACKET, signal, null, "sender")
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

