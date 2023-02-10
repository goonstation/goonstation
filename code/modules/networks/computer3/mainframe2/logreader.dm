#define ACCESSLOG_RECORDS_LIMIT 256
#define DEFAULT_LOG_PATH "/var/log/door-access"
#define MAINFRAME_ACCESSLOG_DRIVER_HACK

/datum/computer/file/record/accesslog_default_config
	name = "accesslog"
	New()
		..()
		fields = list("logdir" = DEFAULT_LOG_PATH)

TYPEINFO(/obj/machinery/networked/logreader)
	mats = 14

/obj/machinery/networked/logreader
	icon = 'icons/obj/computer.dmi'
	icon_state = "computer_generic"
	name = "door access logs"
	density = 1
	anchored = 1
	device_tag = "PNET_LOGREADER"
	timeout = 10
	power_usage = 100
	var/static/list/required_fields = list("card_name", "door_name", "time_t", "timestamp", "door_id", "action")
	var/filter_name = null
	var/ftb_min = null
	var/ftb_sec = null
	var/fte_min = null
	var/fte_sec = null
	var/filter_door_id = null
	var/filter_action = null
	var/machine_screen = 1
	var/list/records = list()
	var/refreshing = 0
	var/refresh_id = 0
	var/timed_out = 0
	var/spoofed = 0

	New()
		..()
		SPAWN(0.5 SECONDS)
			src.net_id = generate_net_id(src)

			if(!src.link)
				var/turf/T = get_turf(src)
				var/obj/machinery/power/data_terminal/test_link = locate() in T
				if(test_link && !DATA_TERMINAL_IS_VALID_MASTER(test_link, test_link.master))
					src.link = test_link
					src.link.master = src

	attack_hand(var/mob/user)
		if(..() || (status & (NOPOWER|BROKEN)))
			return

		src.add_dialog(user)

		var/list/dat = list({"<html><head><title>Access Log Reader</title><style>
.conn-box {
	float: right;
	width: 12px;
	height: 12px;
	display: block;
	display: inline-block;
	border: 1px solid #888888;
}

.conn-ok {
	background-color: #33FF00;
}

.conn-no {
	background-color: #F80000;
}

.conn-error {
	background-color: #888888;
}

</style></head><body>"})


		var/readout_class = "conn-error"
		var/readout = "ERROR"
		if(src.host_id)
			readout_class = "conn-ok"
			readout = "OK CONNECTION"
		else
			readout_class = "conn-no"
			readout = "NO CONNECTION"

		dat += "<div class='conn-box [readout_class]'></div>"
		if (!refreshing)
			if (machine_screen == 1)
				dat += "<b>Connection</b> | <a href='?src=\ref[src];screen=2'>Data</a>"
			else if (machine_screen == 2)
				dat += "<a href='?src=\ref[src];screen=1'>Connection</a> | <b>Data</b>"
			else if (!refreshing)
				dat += "<a href='?src=\ref[src];screen=1'>Connection</a> | <a href='?src=\ref[src];screen=2'>Data</a>"


			dat += "<hr><br>"


			if (machine_screen == 1)
				dat += "<b>Host Connection:</b>"
				dat += "<table border='1' class='[readout_class]'><tr><td><font color=white>[readout]</font></td></tr></table><br>"
				dat += "<a href='?src=\ref[src];reset=1'>Reset Connection</a><br>"

				if (src.panel_open)
					dat += net_switch_html()

			else if (machine_screen == 2)
				dat += "<h3>Door access logs</h3>"
				if (spoofed)
					dat += "<i>Warning: could not verify authenticity of displayed data.</i><br>"
				if (timed_out)
					dat += "<i>Warning: last request to refresh records timed out with no response.</i><br>"
				if (spoofed || timed_out)
					dat += "<br>"
				dat += "<b>Filters</b><br>"
				dat += "<b>Card name (partial):</b> <a href='?src=\ref[src];card_name=1'>[filter_name ? filter_name : "&lt;not set&gt;"]</a>[filter_name ? " <a href='?src=\ref[src];card_name_clear=1'>\[X\]</a>" : null]<br>"
				dat += "<b>Time interval:</b> "
				if (ftb_min != null && ftb_sec != null && fte_min != null && fte_sec != null)
					dat += "<a href='?src=\ref[src];time_begin_min=1'>[ftb_min]</a>:"
					dat += "<a href='?src=\ref[src];time_begin_sec=1'>[ftb_sec]</a> - "
					dat += "<a href='?src=\ref[src];time_end_min=1'>[fte_min]</a>:"
					dat += "<a href='?src=\ref[src];time_end_sec=1'>[fte_sec]</a> "
					dat += "<a href='?src=\ref[src];time_clear=1'>\[X\]</a>"
				else
					dat += "<a href='?src=\ref[src];time=1'>&lt;not set&gt;</a>"
				dat += "<br>"
				dat += "<b>Action:</b> <a href='?src=\ref[src];action=1'>[filter_action ? filter_action : "&lt;not set&gt;"]</a>[filter_action ? " <a href='?src=\ref[src];action_clear=1'>\[X\]</a>" : null]<br>"
				dat += "<b>Door net ID:</b> <a href='?src=\ref[src];door_id=1'>[filter_door_id ? filter_door_id : "&lt;not set&gt;"]</a>[filter_door_id ? " <a href='?src=\ref[src];door_id_clear=1'>\[X\]</a>" : null]<br>"
				dat += "<a href='?src=\ref[src];refresh=1'>Refresh records</a><br><br>"

				dat += "<b>Record listing: </b><br>"
				if (!records.len)
					dat += "<i>No records currently loaded. Refresh the records to load data.</i><br>"
				else
					for (var/rec in records)
						dat += "[rec]<br>"
		else if (refreshing)
			dat += "<i>Refreshing data, please wait...</i>"

		user.Browse(dat.Join(),"window=net_logreader;size=545x302")
		onclose(user,"net_logreader")
		return

	Topic(href, href_list)
		if(..())
			return

		if (!(usr in range(1)))
			return

		src.add_dialog(usr)
		src.add_fingerprint(usr)

		if (href_list["reset"])
			if(last_reset && (last_reset + NETWORK_MACHINE_RESET_DELAY >= world.time))
				return

			src.last_reset = world.time
			var/rem_host = src.host_id ? src.host_id : src.old_host_id
			src.host_id = null
			src.old_host_id = null
			src.post_status(rem_host, "command","term_disconnect")
			SPAWN(0.5 SECONDS)
				src.post_status(rem_host, "command","term_connect","device",src.device_tag)

			src.updateUsrDialog()
			return

		if (href_list["screen"])
			machine_screen = text2num_safe(href_list["screen"])

		if (href_list["card_name"])
			filter_name = input("Partial name of card holder", "Card holder name", filter_name) as text|null
			filter_name = strip_html(filter_name)
		if (href_list["card_name_clear"])
			filter_name = null

		if (href_list["action"])
			filter_action = input("Door action", "Door action", filter_action) as null|anything in list("open","close","lock","unlock","reject")

		if (href_list["action_clear"])
			filter_action = null

		if (href_list["door_id"])
			filter_door_id = input("Net ID of door", "Door net ID", filter_door_id) as text|null

		if (href_list["door_id_clear"])
			filter_door_id = null

		if (href_list["time"])
			ftb_min = input("Filter start time: minutes", "Begin time minutes", 0) as num|null
			if (ftb_min == null)
				return
			ftb_sec = input("Filter start time: seconds", "Begin time seconds", 0) as num|null
			if (ftb_sec == null)
				ftb_min = null
				return
			fte_min = input("Filter end time: minutes", "End time minutes", 0) as num|null
			if (fte_min == null)
				ftb_min = null
				ftb_sec = null
				return
			fte_sec = input("Filter end time: seconds", "End time seconds", 0) as num|null
			if (fte_sec == null)
				ftb_min = null
				ftb_sec = null
				fte_min = null
				return

		if (href_list["time_begin_min"])
			var/n_ftb_min = input("Filter start time: minutes", "Begin time minutes", ftb_min) as num|null
			if (n_ftb_min != null)
				ftb_min = n_ftb_min

		if (href_list["time_begin_sec"])
			var/n_ftb_sec = input("Filter start time: seconds", "Begin time seconds", ftb_sec) as num|null
			if (n_ftb_sec != null)
				ftb_sec = n_ftb_sec

		if (href_list["time_end_min"])
			var/n_fte_min = input("Filter end time: minutes", "End time minutes", fte_min) as num|null
			if (n_fte_min != null)
				fte_min = n_fte_min

		if (href_list["time_end_sec"])
			var/n_fte_sec = input("Filter end time: seconds", "End time seconds", fte_sec) as num|null
			if (n_fte_sec != null)
				fte_sec = n_fte_sec

		if (href_list["time_clear"])
			ftb_min = null
			ftb_sec = null
			fte_min = null
			fte_sec = null

		if (href_list["refresh"])
			if (!src.host_id)
				return
			if (refreshing)
				return
			refreshing = 1
			refresh_id++
			var/my_refresh_id = refresh_id
			var/datum/signal/signal = get_free_signal()
			signal.source = src
			signal.transmission_method = TRANSMISSION_WIRE
			var/arguments = "-l 32 -f"
			if (ftb_min != null && ftb_sec != null && fte_min != null && fte_sec != null)
				var/st = ftb_min * 600 + ftb_sec * 10
				var/et = fte_min * 600 + fte_sec * 10
				arguments += " -t [st]:[et]"
			if (filter_action)
				arguments += " -m [filter_action]"
			if (filter_door_id)
				arguments += " -s [uppertext(ckey(filter_door_id))]"
			if (filter_name)
				arguments += " -- [bash_sanitize(filter_name)]"
			var/data = list2params(list("command"="record_query","query"="[arguments]"))
			src.post_status(src.host_id, "command", "term_message", "data", data, "netid", "[net_id]", "device", device_tag)
			SPAWN(30 SECONDS)
				if (refresh_id == my_refresh_id && refreshing)
					timed_out = 1
					refreshing = 0

		attack_hand(usr)
		return

	process()
		..()
		if(status & NOPOWER)
			return

		if(!host_id || !link)
			return

		if(src.timeout == 0)
			src.post_status(host_id, "command","term_disconnect","data","timeout")
			src.host_id = null
			src.updateUsrDialog()
			src.timeout = initial(src.timeout)
			src.timeout_alert = 0
		else
			src.timeout--
			if(src.timeout <= 5 && !src.timeout_alert)
				src.timeout_alert = 1
				src.post_status(src.host_id, "command","term_ping","data","reply")

		return

	receive_signal(datum/signal/signal)
		if(status & (NOPOWER) || !src.link)
			return
		if(!signal || !src.net_id || signal.encryption)
			return

		var/target = signal.data["sender"] ? signal.data["sender"] : signal.data["netid"]
		if(!target)
			return

		if(signal.data["target_device"] && signal.data["target_device"] != device_tag)
			return

		//We care very deeply about address_1.
		if(lowertext(signal.data["address_1"]) != lowertext(src.net_id))
			if((signal.data["address_1"] == "ping") && ((signal.data["net"] == null) || ("[signal.data["net"]]" == "[src.net_number]")))
				SPAWN(0.5 SECONDS) //Send a reply for those curious jerks
					if (signal.transmission_method == TRANSMISSION_WIRE)
						src.post_status(target, "command", "ping_reply", "device", src.device_tag, "netid", src.net_id, "net", "[net_number]")
					// else ????
				return
			if (!signal.data["target_device"])
				return

		var/sigcommand = lowertext(signal.data["command"])
		if(!sigcommand || !target)
			return

		switch(sigcommand)
			if("term_connect") //Terminal interface stuff.
				if(target == src.host_id)
					src.host_id = null
					src.updateUsrDialog()
					SPAWN(0.3 SECONDS)
						src.post_status(target, "command","term_disconnect")
					return

				if(src.host_id)
					return

				src.timeout = initial(src.timeout)
				src.timeout_alert = 0
				src.host_id = target
				src.old_host_id = target
				if(signal.data["data"] != "noreply")
					src.post_status(target, "command","term_connect","data","noreply","device",src.device_tag)
				src.updateUsrDialog()
				SPAWN(0.2 SECONDS) //Sign up with the driver (if a mainframe contacted us)
					src.post_status(target,"command","term_message","data","command=register")
				return

			if("term_message","term_file")
				if(target != src.host_id) //Huh, who is this?
					return
				var/data = signal.data["data"]
				if(!data || sigcommand == "term_message") // currently no action is taken without a file, so throw back term_message
					src.post_status(target,"command","term_message","data","command=status&status=failure")
					return

				var/datum/computer/file/archive/archive = signal.data_file
				if (!istype(archive))
					src.post_status(target,"command","term_message","data","command=status&status=failure")
					return

				records.len = 0
				for (var/datum/computer/file/record/R in archive.contained_files)
					var/bad = 0
					for (var/F in required_fields)
						if (!(F in R.fields))
							bad = 1
							break
					if (bad)
						continue
					records += accesslog_digest(R, 1)

				if (data == "ack")
					spoofed = 0
				else
					spoofed = 1

				timed_out = 0
				refreshing = 0

				src.post_status(target,"command","term_message","data","command=status&status=success")
				for (var/mob/M in range(1))
					if (M.using_dialog_of(src))
						attack_hand(M)
				return

			if("term_ping")
				if(target != src.host_id)
					return
				if(signal.data["data"] == "reply")
					src.post_status(target, "command","term_ping")
				src.timeout = initial(src.timeout)
				src.timeout_alert = 0
				return

			if("term_disconnect")
				if(target == src.host_id)
					src.host_id = null
				src.timeout = initial(src.timeout)
				src.timeout_alert = 0 //No need to be alerted about this anymore.
				src.updateUsrDialog()
				return

		return

proc/accesslog_digest(var/datum/computer/file/record/R, formatted = 0)
	if (!istype(R))
		return "unknown type [R.name], possibly not a record"
	var/action = R.fields["action"]
	var/card_name = R.fields["card_name"]
	var/time_t = R.fields["time_t"]
	var/door_name = R.fields["door_name"]
	if (!action)
		return "corrupted record [R.name] missing action"
	if (!card_name)
		return "corrupted record [R.name] missing user ID"
	if (!time_t)
		return "corrupted record [R.name] missing human readable time"
	if (!door_name)
		return "corrupted record [R.name] missing door designated name"
	if (action != "reject")
		if (!formatted)
			return "[time_t] [card_name] [action]s [door_name]"
		else
			return "<b>[time_t]</b> [card_name] <b>[action]s</b> [door_name]"
	else
		if (!formatted)
			return "[time_t] [door_name] rejected entry for [card_name]"
		else
			return "<b>[time_t]</b> [door_name] <b>rejected entry for</b> [card_name]"

/datum/computer/file/mainframe_program/srv/accesslog
	name = "accesslog"
	size = 1
	var/static/nextlog = 1
	var/opt_data = null

	receive_progsignal(var/sendid, var/list/data, var/datum/computer/file/file)
		. = ..()
		if (!.)
			if (data["command"] == DWAINE_COMMAND_REPLY)
				if (data["sender_tag"] == "getopt")
					opt_data = data["data"]
					return ESIG_USR4
				else
					return ESIG_GENERIC
			else if (data["command"] == DWAINE_COMMAND_MSG_TERM)
				message_user(data["data"])
			else
				return ESIG_GENERIC
			return ESIG_SUCCESS

	proc/usage()
		message_user("Usage:")
		message_user("[name] -a -s DOOR_ID -m (open|close|lock|unlock|reject) -t TIME USER_ID")
		message_user("[name] -l COUNT \[-f\] \[-s DOOR_ID\] \[-m (open|close|lock|unlock|reject)\] \[-b TIME_START:TIME_END\] \[USER_ID_FRAGMENT \]")

	proc/loglist(timestamp, action, door_id, card_name)
		var/list/ret = list()
		ret["action"] = action
		ret["door_id"] = door_id
		ret["card_name"] = card_name
		var/atom/door = locate("\[0x[door_id]\]")
		if (istype(door, /obj/machinery/door/airlock))
			ret["door_name"] = door.name
		else if (istype(door, /obj/machinery/networked))
			ret["door_name"] = "[door.name] (ALERT: network indicates this may not be door)"
		else
			ret["door_name"] = "Unknown device (0x[door_id])"
		var/time_n = istext(timestamp) ? text2num_safe(timestamp) : timestamp
		ret["timestamp"] = time_n
		var/min = round(time_n / 600)
		var/sec = round(time_n / 10) - min * 60
		ret["time_t"] = "[min < 10 ? 0 : null][min]:[sec < 10 ? 0 : null][sec]"
		return ret

	proc/message_reply_and_user(var/message)
		var/list/data = list("command"=DWAINE_COMMAND_REPLY, "data" = message, "sender_tag" = "accesslog")
		if (useracc)
			data["term"] = useracc.user_id
		var/sig = signal_program(parent_task.progid, data)
		if (sig != ESIG_USR4)
			message_user(message)

	initialize(var/initparams)
		if (..())
			mainframe_prog_exit
			return

		if (!initparams)
			usage()
			mainframe_prog_exit
			return

		var/log_to = DEFAULT_LOG_PATH
		var/datum/computer/file/record/conf_file = signal_program(1, list("command"=DWAINE_COMMAND_FGET, "path"="/etc/accesslog"))
		if (istype(conf_file))
			if (conf_file.fields["logdir"])
				log_to = conf_file.fields["logdir"]
				if (chs(log_to, 1) != "/")
					log_to = "/log_to"

		opt_data = null
		var/status = signal_program(1, list("command"=DWAINE_COMMAND_TSPAWN, "passusr" = 1, "path" = "/bin/getopt", "args" = "afl:m:s:t: [initparams]"))
		if (status == ESIG_NOTARGET)
			message_user("getopt: command not found")
			mainframe_prog_exit
			return
		if (!opt_data)
			message_user("accesslog: No response from getopt.")
			mainframe_prog_exit
			return
		if (copytext(opt_data, 1, 7) == "getopt")
			message_user(opt_data)
			mainframe_prog_exit
			return
		var/list/l = optparse(opt_data)
		if (!istype(l))
			message_user("accesslog: Error parsing options: [opt_data].")
			mainframe_prog_exit
			return
		var/list/opts = l[1]
		var/list/params = l[2]
		if (opts["a"] && opts["l"])
			usage()
			mainframe_prog_exit
			return

		if (opts["a"])
			if (opts["s"] && opts["t"] && opts["m"] && length(params))
				if (!(opts["m"] in list("open","close","lock","unlock","reject")))
					message_user("")
				var/mylog = nextlog
				nextlog++

				var/datum/computer/file/record/logfile = new()
				var/fname = "access[mylog]"
				logfile.name = fname
				if (useracc)
					logfile.metadata["owner"] = read_user_field("name")
				logfile.metadata["permissions"] = COMP_ROWNER | COMP_RGROUP
				logfile.fields = loglist(opts["t"], opts["m"], opts["s"], jointext(params, " "))
				var/datum/computer/folder/logs_dir = signal_program(1, list("command"=DWAINE_COMMAND_FGET, "path"=log_to))
				if (istype(logs_dir))
					var/idx = 0
					while (logs_dir.contents.len >= ACCESSLOG_RECORDS_LIMIT)
						idx++
						if (idx > logs_dir.contents.len)
							message_user("Could not make space for new entry.")
							mainframe_prog_exit
							return
						var/datum/computer/to_delete = logs_dir.contents[idx]
						if (istype(to_delete, /datum/computer/file/record))
							logs_dir.remove_file(to_delete)
							if (to_delete)
								qdel(to_delete)
							idx--
				var/result = signal_program(1, list("command"=DWAINE_COMMAND_FWRITE, "path"=log_to,"replace"=1,"mkdir"=1), logfile)
				if (result == ESIG_SUCCESS)
					message_user("Data recorded.")
				else
					message_user("File system error occurred while recording data.")
			else
				usage()
				mainframe_prog_exit
				return
		else if (opts["l"])
			var/time_begin = null
			var/time_end = null
			if (opts["t"])
				var/time_filter = opts["t"]
				var/list/tf_list = splittext(time_filter, ":")
				if (tf_list.len != 2)
					message_user("Invalid timestamp filter format [time_filter], usage: TIMESTAMP_BEGIN:TIMESTAMP_END.")
					mainframe_prog_exit
					return
				time_begin = text2num_safe(tf_list[1])
				time_end = text2num_safe(tf_list[2])
				if (!isnum(time_begin) || !isnum(time_end))
					message_user("Invalid timestamp filter [time_filter].")
					mainframe_prog_exit
					return
			var/datum/computer/folder/logs_folder = signal_program(1, list("command"=DWAINE_COMMAND_FGET, "path"=log_to))
			if (logs_folder == ESIG_NOFILE)
				message_user("No recorded data.")
				mainframe_prog_exit
				return
			if (!istype(logs_folder))
				message_user("Error: cannot access logs directory. Please check your permissions and try again.")
				mainframe_prog_exit
				return
			var/count = text2num_safe(opts["l"])
			if (!count)
				message_user("Invalid count: [opts["l"]]")
				mainframe_prog_exit
				return
			if (count < 0)
				message_user("Listing the last [count] records (do you honestly expect this to break anything?).")
				mainframe_prog_exit
				return
			if (count > 32)
				count = 32
			message_user("Listing the last [count] records:")
			var/paramsearch = null
			if (params.len)
				paramsearch = jointext(params, " ")
			var/list/records = logs_folder.contents.Copy()
			if (!records.len)
				message_user("No recorded data.")
			else
				var/printed = 0
				var/now = ticker.round_elapsed_ticks
				var/max = -1
				var/datum/computer/file/record/C = null
				for (var/Q in records)
					if (!istype(Q, /datum/computer/file/record))
						records -= Q
						continue
					var/datum/computer/file/record/R = Q
					if (!R.fields["door_id"] || !R.fields["timestamp"] || !R.fields["card_name"] || !R.fields["action"] || !R.fields["time_t"] || !R.fields["door_name"])
						records -= Q
					var/TS = R.fields["timestamp"]
					if (!TS)
						records -= Q
						continue
					if (!isnum(TS))
						TS = text2num_safe(TS)
						R.fields["timestamp"] = TS
					if (TS < 0)
						records -= Q
						continue
					if (opts["t"])
						if (TS < time_begin || TS > time_end)
							records -= Q
							continue
					if (opts["s"])
						if (R.fields["door_id"] != opts["s"])
							records -= Q
							continue
					if (opts["m"])
						if (R.fields["action"] != opts["m"])
							records -= Q
							continue
					if (params.len)
						if (!findtext(R.fields["card_name"], paramsearch))
							records -= Q
							continue

				var/list/printing = list()
				while (printed < count && length(records))
					max = -1
					for (var/datum/computer/file/record/R in records)
						var/TS = R.fields["timestamp"]
						if (!isnum(TS))
							TS = text2num_safe(TS)
							R.fields["timestamp"] = TS
						if (R.fields["timestamp"] > max && R.fields["timestamp"] < now - 300)
							max = R.fields["timestamp"]
							C = R
					if (C)
						printing += C
						records -= C
						printed++
					else
						break

				for (var/i = printing.len, i >= 1, i--)
					var/datum/computer/file/record/R = printing[i]
					if (opts["f"])
						message_reply_and_user("[log_to]/[R.name]")
					else
						message_reply_and_user(accesslog_digest(R))

		mainframe_prog_exit
		return

/datum/computer/file/mainframe_program/driver/mountable/logreader
	name = "logreader"
	setup_processes = 1
	var/tmp/list/records = list()
	var/tmp/archive_path = null

	initialize(var/initparams)
		if (..())
			return

		signal_program(1, list("command"=DWAINE_COMMAND_MOUNT, "id"=src.name, "link"="logreader"))
		return

	process()
		return

	receive_progsignal(var/sendid, var/list/data, var/datum/computer/file/file)
		. = ..()
		if (!.)
			if (data["command"] == DWAINE_COMMAND_REPLY)
				if (data["sender_tag"] == "accesslog")
					records += data["data"]
					return ESIG_USR4
				else if (data["sender_tag"] == "tar")
					archive_path = data["data"]
					return ESIG_USR4
				else
					return ESIG_GENERIC
			else if (data["command"] == DWAINE_COMMAND_MSG_TERM)
				message_user(data["data"])
			else
				return ESIG_GENERIC
			return ESIG_SUCCESS

	terminal_input(var/data, var/datum/computer/file/theFile)
		if (..() || !data)
			return 1


		var/list/dataList = params2list(data)
		if (!dataList || !length(dataList))
			return 1


		switch (lowertext(dataList["command"]))
			if ("record_query")
				records.len = 0
				var/datum/computer/file/mainframe_program/P = signal_program(1, list("command"=DWAINE_COMMAND_FGET, "path"="/sys/srv/accesslog"))
				if (istype(P))
					var/list/siglist = list("command"=DWAINE_COMMAND_TSPAWN, "passusr"=1, "path"="/sys/srv/accesslog", "args"=strip_html(dataList["query"]))
					signal_program(1, siglist)
					// see what i did here? heh? HEH?
					// doubly so, it almost sounds like tar gz
					var/targs = jointext(records, " ")
					archive_path = null
					siglist = list("command"=DWAINE_COMMAND_TSPAWN, "passusr"=1, "path"="/bin/tar", "args"="-cqt -- [targs]")
					signal_program(1, siglist)
					if (!archive_path)
						return 1
					var/datum/computer/file/archive/archive = signal_program(1, list("command"=DWAINE_COMMAND_FGET, "path"="[archive_path]"))
					if (!istype(archive))
						return 1
					message_device("ack", archive)
					//archive.dispose() // we don't need that tempfile anymore
		return 0

	add_file(var/datum/computer/file/theFile)
		if (!initialized)
			return 0

		if (istype(theFile, /datum/computer/file/archive))
			var/datum/computer/file/archive/R = theFile
			message_device("suppl", R)
			theFile.dispose()
			return 1

		return 0

	change_metadata(var/datum/computer/file/file, var/field, var/newval)
		return 0

#undef DEFAULT_LOG_PATH
#undef ACCESSLOG_RECORDS_LIMIT
