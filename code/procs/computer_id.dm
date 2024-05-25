

/datum/compid_info
	var/compid = ""
	var/last_seen = 0 //The time this was last spotted
	var/last_ckey = "" //The latest key associated with this ID
	var/times_seen = 0

proc/initialize_compid_savefile()
	if(!compid_file)
		compid_file = new /savefile("data/compid_file.sav")

	return compid_file

proc/load_compids(var/ckey)
	var/savefile/SF = initialize_compid_savefile()

	var/path = "/[copytext(ckey, 1, 2)]/[ckey]"
	var/list/datum/compid_info/cid_list = list()

	SF.cd = path
	while (!SF.eof)
		var/datum/compid_info/CI
		SF >> CI
		cid_list += CI

	return cid_list

proc/save_compids(var/ckey, var/list/datum/compid_info/cid_list)
	var/savefile/SF = initialize_compid_savefile()
	var/path = "/[copytext(ckey, 1, 2)]/[ckey]"

	SF.cd = path
	SF.eof = -1
	for(var/datum/compid_info/CI in cid_list)
		SF << CI

proc/check_compid_list(var/client/C)
	C.compid_info_list = load_compids(C.ckey)

	var/append_CID = 1

	for(var/datum/compid_info/CI in C.compid_info_list)
		if(CI.compid == C.computer_id) //Seen this computer ID before
			append_CID = 0
			/* This will never happen what the fuck is wrong with me?
			if (CI.last_ckey != C.ckey) //Computer-sharing? Sneaky jerk? Who knows.
				message_admins("[C.key] (ID:[C.computer_id]) shares a computerID with [CI.last_ckey]")
				logTheThing(LOG_ADMIN, C, "[C.key] (ID:[C.computer_id]) shares a computerID with [CI.last_ckey]")
				CI.last_ckey = C.ckey
			*/
			CI.last_seen = world.realtime
			CI.times_seen++
			break

	if(append_CID) //Did not find an entry
		var/datum/compid_info/CI = new
		CI.compid = C.computer_id
		CI.last_seen = world.realtime
		CI.last_ckey = C.ckey
		CI.times_seen = 1

		//Has this computerid changed recently and does it have a habit of changing?
		if(length(C.compid_info_list) >= 2) //Do they have more than 2 CID's on file? Weird
			var/today = time2text(world.realtime, "YYYYMMDD")
			var/current_hour = time2text(world.realtime, "hh")
			var/current_minute = time2text(world.realtime, "mm")
			var/hits = 0
			for(var/datum/compid_info/CII in C.compid_info_list)
				if(today == time2text(CII.last_seen, "YYYYMMDD"))
					var/last_seen_hour = time2text(CII.last_seen, "hh")
					var/last_seen_minute = time2text(CII.last_seen, "nn")
					var/time_diff = ( text2num(current_hour) * 60 + text2num(current_minute) ) -  ( text2num(last_seen_hour) * 60 + text2num(last_seen_minute) )

					if(time_diff <= 180 && CI.times_seen < 30)
						//If the ID changed within 3 hours and the ID hasn't been seen several times (unlikely to happen with automatically generated IDs
						hits++
			if(hits)
				var/ircmsg[] = new()
				ircmsg["key"] =  C.key
				ircmsg["name"] = stripTextMacros(C.mob.real_name)
				var/msg = "'s compID changed [hits] time[hits>1 ? "s" : null] within the last 180 minutes - [C.compid_info_list.len + 1] IDs on file."
				if(hits >= 2) //This person used 3 computers within as many hours
					if(!cid_test) cid_test = list()
					if(!cid_tested) cid_tested = list()
					if(!(C.ckey in cid_test) && !(C.ckey in cid_tested)) //They aren't yet scheduled for a test or they have been tested
						cid_test[C.ckey] = C.computer_id
						cid_tested += C.ckey
						msg += " Executing automatic test."
						SPAWN(1 SECOND)
							del(C) //RIP
					message_admins("[key_name(C)][msg]")
					logTheThing(LOG_ADMIN, C, msg)
					logTheThing(LOG_DIARY, C, msg, "admin")

				else
					message_admins("[key_name(C)][msg]")
					logTheThing(LOG_ADMIN, C, "[key_name(C)][msg]")
					logTheThing(LOG_DIARY, C, "[key_name(C)][msg]", "admin")

				ircmsg["msg"] = "(IP: [C.address]) [msg]"
				ircbot.export_async("admin", ircmsg)


		//Done with the analysis

		C.compid_info_list += CI
	/* Pointless alert
	if(length(C.compid_info_list) > 10) //Holy evasion, Batman!
		message_admins("[key_name(C)] (ID:[C.computer_id]) has been seen having [C.compid_info_list.len] IDs!")
		logTheThing(LOG_ADMIN, C, "(ID:[C.computer_id]) has been seen having [C.compid_info_list.len] IDs!")
	*/

	save_compids(C.ckey, C.compid_info_list)

var/global/list/cid_test = list()
var/global/list/cid_tested = list()

proc/do_computerid_test(var/client/C)
	var/cid = cid_test[C.ckey]
	if(!cid) return //They were not scheduled for testing
	var/is_fucker = cid != C.computer_id //IT CHANGED!!!
	cid_test -= C.ckey

	var/msg = " [is_fucker ? "failed" : "passed"] the automatic cid dll test."

	var/ircmsg[] = new()
	ircmsg["key"] =  C.key
	ircmsg["name"] = stripTextMacros(C.mob.real_name)
	ircmsg["msg"] = " [msg]"
	ircbot.export_async("admin", ircmsg)
	message_admins("[key_name(C)][msg]")
	logTheThing(LOG_ADMIN, C, msg)
	logTheThing(LOG_DIARY, C, msg, "admin")
	if(is_fucker)
		//message_admins("[key_name(C)] was automatically banned for using the CID DLL.")
		bansHandler.add(
			"bot",
			null,
			C.ckey,
			C.computer_id,
			C.address,
			"Using a modified dreamseeker client.",
			FALSE
		)


proc/view_client_compid_list(mob/user, var/C)
	if(!user.client || !user.client.holder)
		return

	var/list/datum/compid_info/cid_list = null
	var/ckey = ""
	if(isclient(C))
		var/client/CL = C
		cid_list = CL.compid_info_list
		ckey = CL.ckey
	else if(istext(C))
		cid_list = load_compids(C)
		ckey = C
		if(!cid_list.len)
			user.show_text("Could not find the ckey [C]!", "red")
			return
	else
		message_coders("[key_name(user)] gave the compid thing [C]; that's neither text nor a client. What a jerk.")
		return

	var/dat = {"<html>
				<head>
					<title>Computer ID viewer</title>
					<style>
						table {
							border: 1px solid black;
							border-collapse: collapse;
							padding: 2px;
						}
						tr {
							border: 1px solid black;
							padding: 2px
						}
						th {
							border: 1px solid black;
							padding: 2px
						}
						td {
							border: 1px solid black;
							padding: 2px
						}
					</style>
				</head>

				<body>
					<h3>CompID list for [ckey]</h2>
					<hr>
					This jerk: [key_name(whom=C, admins=0)]
					<table>
						<tr>
							<th>Comp ID</th><th>Last Ckey</th><th>Last Seen</th><th>Times Seen</th>
						</tr>"}

	for (var/datum/compid_info/CI in cid_list)
		dat += "<tr><td>[CI.compid]</td><td>[CI.last_ckey]</td><td>[time2text(CI.last_seen, "YYYY-MM-DD hh:mm")]</td><td>[CI.times_seen]</td></tr>"

	dat += {"		</table>
				</body>
			</html>"}

	user.Browse(dat, "window=compid_info_view")
