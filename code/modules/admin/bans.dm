/////////////////////////
// BASE BAN PROCS
// Most of these have two steps (instead of double the procs)
// First step sends the initial query to the bans web API
// Second step handles the response
/////////////////////////


//Returns the expiry timestamp in a human readable format
/proc/getExpiry(minutes)
	var/CMinutes = (world.realtime / 10) / 60
	if(istext(minutes))
		minutes = text2num(minutes)
	var/exp = minutes - CMinutes
	if (exp <= 0)
		return 0
	else
		if (exp >= ((24 HOURS) / (1 MINUTE))) // 1 day in minutes
			exp = round(exp / 1440, 0.1)
			. = "[exp] Day[exp > 1 ? "s" : ""]"
		else if (exp >= ((1 HOUR) / (1 MINUTE))) // 1 hour in minutes
			exp = round(exp / 60, 0.1)
			. = "[exp] Hour[exp > 1 ? "s" : ""]"
		else
			. = "[exp] Minute[exp > 1 ? "s" : ""]"


//A dumb thing to cache the players seen per round, so I don't end up recording dudes when they reconnect a billion times
var/global/list/playersSeen = list()
/proc/managePlayerSeen(ckey, compID, ip)
	var/key = "[ckey]|[compID]|[ip]"
	if (key in playersSeen)
		return FALSE
	else
		playersSeen += key
		return TRUE


//Are ya banned? Well!? ARE YA?!
//A return 0 is a "this guy is ok let him in"
//Anything that returns as true is a "bad dude kill his connection"
//(this doesn't use the 'step' var thing because we need the response here and now)
//"record" tells the goonhub api to make a note of these details
/proc/checkBan(ckey, compID, ip, record = 0)
	set background = 1
	if (!ckey && !compID && !ip)
		logTheThing(LOG_DEBUG, null, "<b>Bans Error</b>: No details passed to <b>checkBan</b>")
		logTheThing(LOG_DIARY, null, "Bans Error: No details passed to checkBan", "debug")
		return 0

	if(!ip || ip == "127.0.0.1") return 0 //Ignore if localhost

	if (record)
		record = managePlayerSeen(ckey, compID, ip)

	//Check if this user has a ban already
	var/query[] = new()
	query["ckey"] = ckey
	query["compID"] = compID
	query["ip"] = ip
	query["record"] = record
	#ifdef RP_MODE
	query["rp_mode"] = true
	#endif

	var/list/data
	try
		data = apiHandler.queryAPI("bans/check", query, 1)
	catch ()
		//API is dead, let the person in without checking
		return 0

	//If the server returned nothing, a "no bans found" record, or a "this dude is exception'd"
	//Then they are good to go
	if (!data || data["none"] || data["exception"])
		return 0
	if (data["error"]) //Error returned from the API welp
		logTheThing(LOG_DEBUG, null, "<b>Bans Error</b>: Error returned in <b>checkBan</b> for <b>[ckey]</b>: [data["error"]]")
		logTheThing(LOG_DIARY, null, "Bans Error: Error returned in checkBan for [ckey]: [data["error"]]", "debug")
		return 0

	//We only care about the latest match for this (so far)
	var/list/row = data[data[1]]

	var/timestamp = text2num(row["timestamp"])

	var/expired = timestamp > 0 && !getExpiry(timestamp)

	//Are any of the details...different? This is to catch out ban evading jerks who change their ckey but forget to mask their IP or whatever
	var/timeAdded = 0
	if (!expired && (row["ckey"] != ckey || row["ip"] != ip || row["compID"] != compID)) //Insert a new ban for this JERK
		var/newChain = 0
		if (text2num(row["previous"]) > 0) //if we matched a previous auto-added ban
			if (text2num(row["chain"]) > 0)
				newChain = text2num(row["chain"]) + 1
			else //no multiplier present, default to x2 (this should never occur)
				newChain = 2
		else //didn't match a previous evasion ban, start off with x1
			newChain = 1

		timeAdded = (row["ckey"] != ckey && newChain > 1 ? 1 : 0) //only add time if a ckey didnt match, and it's a second evasion
		var/CMinutes = (world.realtime / 10) / 60
		var/remaining = (timestamp > 0 ? timestamp - CMinutes : timestamp)
		var/addData[] = new()
		addData["ckey"] = ckey
		addData["compID"] = row["compID"] || null // don't record CID if the original ban doesn't have one down
		addData["ip"] = ip
		addData["reason"] = row["reason"]
		addData["oakey"] = row["oakey"]
		addData["akey"] = "Auto Banner"
		addData["mins"] = remaining
		addData["previous"] = text2num(row["id"])
		addData["chain"] = newChain
		if (row["server"])
			addData["server"] = row["server"]
		addData["addTime"] = timeAdded
		var/rVal = addBan(addData)
		if (rVal)
			logTheThing(LOG_DEBUG, null, "<b>Bans Error</b>: Add ban in checkBan failed with message <b>[rVal]</b>")
			logTheThing(LOG_DIARY, null, "Bans Error: Add ban in checkBan failed with message [rVal]", "debug")

	var/oakey = (row["oakey"] == "N/A" ? row["akey"] : row["oakey"])
	if (timestamp > 0) //Temp ban found, determine if it should expire or not
		if (expired) //It expired! Go you!
			var/deleteData[] = new()
			deleteData["id"] = row["id"]
			deleteData["ckey"] = row["ckey"]
			deleteData["compID"] = row["compID"]
			deleteData["ip"] = row["ip"]
			deleteData["akey"] = "Auto Unbanner"
			var/rVal = deleteBan(deleteData)
			if (rVal)
				logTheThing(LOG_DEBUG, null, "<b>Bans Error</b>: Delete temp ban in checkBan failed with message <b>[rVal]</b>")
				logTheThing(LOG_DIARY, null, "Bans Error: Delete temp ban in checkBan failed with message [rVal]", "debug")
			return 0
		else //Temp ban still in effect. DENIED
			var/details = "[row["reason"]]<br>"
			details += "Banned By: [oakey]<br>"
			details += "This ban applies to [row["server"] ? "this server only" : "all servers"].<br>"
			details += "(This ban will be automatically removed in [getExpiry(timestamp)].)"
			details += "[timeAdded ? "<br>(5 days have been automatically added to your ban for attempted ban evasion)" : ""]"
			return details
	else //Permaban found, the player is DENIED
		var/details = "[row["reason"]]<br>"
		details += "Banned By: [oakey]<br>"
		details += "This ban applies to [row["server"] ? "this server only" : "all servers"].<br>"
		if(timestamp == 0)
			details += "This is a permanent ban, you can't appeal this ban until 30 days have passed."
		else if(timestamp == -1)
			details += "Please make an <a href='https://forum.ss13.co/forumdisplay.php?fid=54'>appeal on the forums</a> to have it lifted."
		return details

/proc/addBan(data)
	set background = 1

	if (data["data_hub_callback"])
		if (data["error"])
			return data["error"]
		//we can get away with just this because addBan only ever returns the details we passed in to begin with
		var/list/row = data["ban"]

		var/client/adminC
		var/client/targetC
		for (var/client/C in clients) //grab clients if possible
			if (C.ckey == row["akey"])
				adminC = C
			if (C.ckey == row["ckey"])
				targetC = C

		row["reason"] = html_decode(row["reason"])

		if (text2num(row["chain"]) > 0) //Prepend our evasion attempt info for: the user, admins, notes (everything except the actual ban reason in the db)
			row["reason"] = "\[Evasion Attempt x[row["chain"]]\] Previous Reason: [row["reason"]]"

		var/replacement_text
		if (targetC)
			targetC.mob.unlock_medal("Banned", 1)
			boutput(targetC, "<span class='alert'><BIG><B>You have been banned by [row["akey"]].<br>Reason: [row["reason"]]</B></BIG></span>")
			boutput(targetC, "<span class='alert'>To try to resolve this matter head to https://forum.ss13.co</span>")
		else
			replacement_text = "[row["ckey"]] (IP: [row["ip"]], CompID: [row["compID"]])"

		if (!adminC)
			adminC = (row["akey"] ? row["akey"] : "N/A")

		var/expiry = getExpiry(row["timestamp"])
		var/serverLogSnippet = row["server"] ? "from [row["server"]]" : "from all servers"

		var/duration = expiry == 0 ? (data["text_ban_length"] || (text2num(row["timestamp"]) == 0 ? "Permanent" : "Until Appeal")) : expiry

		if (text2num(row["timestamp"]) <= 0)
			if (targetC)
				if(duration == "Permanent")
					boutput(targetC, "<span class='alert'>You have received a permanent ban, you can't appeal this ban until 30 days have passed.</span>")
				else if(duration == "Until Appeal")
					boutput(targetC, "<span class='alert'>You have received a ban. Make an <a href='https://forum.ss13.co/forumdisplay.php?fid=54'>appeal on the forums</a> to have it lifted.</span>")
				else
					boutput(targetC, "<span class='alert'>You have received a ban. Duration: [duration]</span>")
			logTheThing(LOG_ADMIN, adminC, "has banned [targetC ? "[constructTarget(targetC,"admin")]" : replacement_text] [serverLogSnippet]. duration: [duration] Reason: [row["reason"]].")
			logTheThing(LOG_DIARY, adminC, "has banned [targetC ? "[constructTarget(targetC,"diary")]" : replacement_text] [serverLogSnippet]. duration: [duration] Reason: [row["reason"]].", "admin")
			var/adminMsg = "<span class='notice'>"
			adminMsg += (isclient(adminC) ? key_name(adminC) : adminC)
			adminMsg += " has banned [targetC ? targetC : replacement_text] [serverLogSnippet].<br>Reason: [row["reason"]]</span>"
			message_admins(adminMsg)
		else
			if (targetC) boutput(targetC, "<span class='alert'>This is a temporary ban, it will be removed in [expiry].</span>")
			logTheThing(LOG_ADMIN, adminC, "has banned [targetC ? "[constructTarget(targetC,"admin")]" : replacement_text] [serverLogSnippet]. Reason: [row["reason"]]. This will be removed in [expiry].")
			logTheThing(LOG_DIARY, adminC, "has banned [targetC ? "[constructTarget(targetC,"diary")]" : replacement_text] [serverLogSnippet]. Reason: [row["reason"]]. This will be removed in [expiry].", "admin")
			var/adminMsg = "<span class='notice'>"
			adminMsg += (isclient(adminC) ? key_name(adminC) : adminC)
			adminMsg += " has banned [targetC ? targetC : replacement_text] [serverLogSnippet].<br>Reason: [row["reason"]]<br>This will be removed in [expiry].</span>"
			message_admins(adminMsg)

		if (row["ckey"] && row["ckey"] != "N/A")
			addPlayerNote(row["ckey"], row["akey"], "Banned [serverLogSnippet] by [row["akey"]], reason: [row["reason"]], duration: [duration]")

		var/ircmsg[] = new()
		ircmsg["key"] = row["akey"]
		ircmsg["key2"] = "[row["ckey"]] (IP: [row["ip"]], CompID: [row["compID"]])"
		ircmsg["msg"] = row["reason"]
		ircmsg["time"] = expiry
		ircmsg["timestamp"] = row["timestamp"]
		ircbot.export_async("ban", ircmsg)

		if(!targetC)
			targetC = find_player(row["ckey"])?.client
		if (targetC)
			del(targetC)
		else
			logTheThing(LOG_DEBUG, null, "<b>Bans:</b> Unable to find client with ckey '[row["ckey"]]' during banning.")

		targetC = find_player(row["ckey"])?.client
		if (targetC)
			logTheThing(LOG_DEBUG, null, "<b>Bans:</b> Client with ckey '[row["ckey"]]' somehow survived banning, retrying kick.")
			del(targetC)

		return 0

	else
		var/banTimestamp = data["mins"]
		if (data["mins"] > 0) //If a temp ban, calculate expiry
			var/CMinutes = (world.realtime / 10) / 60
			banTimestamp = (data["previous"] && data["addTime"] ? CMinutes + data["mins"] + 7200 : CMinutes + data["mins"]) //Add 5 days (7200 mins) onto the ban if it's an evasion attempt

		var/query[] = new()
		query["ckey"] = (data["ckey"] ? data["ckey"] : "N/A")
		query["compID"] = (data["compID"] ? data["compID"] : "N/A")
		query["ip"] = (data["ip"] ? data["ip"] : "N/A")
		query["reason"] = data["reason"]
		query["oakey"] = (data["oakey"] && data["oakey"] != "N/A" ? data["oakey"] : data["akey"])
		query["akey"] = data["akey"]
		query["timestamp"] = banTimestamp
		query["previous"] = (data["previous"] ? data["previous"] : 0)
		query["chain"] = (data["chain"] ? data["chain"] : 0)
		if (data["server"])
			query["server"] = data["server"]
		data = apiHandler.queryAPI("bans/add", query)


//Starts the dialog for banning a dude
/client/proc/genericBanDialog(target)
	if (src.holder?.level >= LEVEL_SA)
		var/mob/M
		var/mobRef = 0
		if (target && ismob(target))
			mobRef = 1
			M = target

		if (mobRef)
			if (M.client && M.client.holder && (M.client.holder.level >= src.holder.level))
				alert("You can't ban another admin you huge jerk!!!!!")
				return null

		var/data[] = new()

		if (!mobRef)
			data["ckey"] = input(src, "Ckey (lowercase, only alphanumeric, no spaces, leave blank to skip)", "Ban") as null|text
			var/auto = alert("Attempt to autofill IP and compID with most recent?","Autofill?","Yes","No")
			if (auto == "No")
				data["compID"] = input(src, "Computer ID", "Ban") as null|text
				data["ip"] = input(src, "IP Address", "Ban") as null|text
			else if (data["ckey"])
				var/list/response
				try
					response = apiHandler.queryAPI("playerInfo/get", list("ckey" = data["ckey"]), forceResponse = 1)
				catch ()
					boutput(src, "<span class='alert'>Failed to query API, try again later.</span>")
					return
				if (text2num(response["seen"]) < 1)
					boutput(src, "<span class='alert'>No data found for target, IP and/or compID will be left blank.</span>")
				data["ip"] = response["last_ip"]
				data["compID"] = response["last_compID"]
		else
			data["ckey"] = M.ckey
			data["compID"] = M.computer_id
			data["ip"] = M.lastKnownIP

		if (!data["ckey"] && !data["ip"] && !data["compID"])
			boutput(src, "<span class='alert'>You need to input a ckey or IP or computer ID, all cannot be blank.</span>")
			return null

		boutput(src, "<span class='alert'><b>You are currently banning the following player:</b></span>")
		boutput(src, "<b>Mob:</b> [mobRef ? M.name : "N/A"]")
		boutput(src, "<b>Key:</b> [data["ckey"] ? data["ckey"] : "N/A"] (IP: [data["ip"] ? data["ip"] : "N/A"], CompID: [data["compID"] ? data["compID"] : "N/A"])")
		boutput(src, "<span class='alert'><b>Make sure this is who you want to ban before continuing!</b></span>")

		var/reason = input(src,"Reason for ban?","Ban") as null|text
		if(!reason)
			boutput(src, "<span class='alert'>You need to enter a reason for the ban.</span>")
			return
		data["reason"] = reason

		var/datum/game_server/game_server = global.game_servers.input_server(src, "What server does the ban apply to?", "Ban", can_pick_all=TRUE)
		if(isnull(game_server))
			return null
		data["server"] = istype(game_server) ? game_server.id : null // null = all servers

		var/ban_time = input(src,"How long will the ban be?","Ban") as null|anything in \
			list("Half-hour","One Hour","Six Hours","One Day","Half a Week","One Week","Two Weeks","One Month","Until Appeal","Permanent","Custom")
		var/mins = 0
		switch(ban_time)
			if("Half-hour")
				mins = 30
			if("One Hour")
				mins = 60
			if("Six Hours")
				mins = 360
			if("One Day")
				mins = 1440
			if("Half a Week")
				mins = 5040
			if("One Week")
				mins = 10080
			if("Two Weeks")
				mins = 20160
			if("One Month")
				mins = 43200
			if("Until Appeal")
				mins = -1
			if("Permanent")
				mins = 0
			else
				var/cust_mins = input(src,"How many minutes? (1440 = one day)","BAN HE",1440) as null|num
				if(!cust_mins)
					boutput(src, "<span class='alert'>No time entered, cancelling ban.</span>")
					return null
				if(cust_mins >= 525600)
					boutput(src, "<span class='alert'>Ban time too long. Ban shortened to one year (525599 minutes).</span>")
					mins = 525599
				else
					mins = cust_mins
		data["mins"] = mins
		data["text_ban_length"] = ban_time
		data["akey"] = src.ckey
		return data
	else
		alert("You need to be at least a Secondary Administrator to ban players.")
		return null


/client/proc/addBanDialog(target)
	var/data[] = genericBanDialog(target)
	if(data)
		addBan(data)


//Admin verb to add bans
/client/proc/cmd_admin_addban ()
	SET_ADMIN_CAT(ADMIN_CAT_UNUSED)
	set name = "Add Ban"
	set popup_menu = 0

	addBanDialog()
	return


/proc/editBan(data)
	set background = 1

	if (data["data_hub_callback"])
		if (data["error"])
			return data["error"]
		//we can get away with just this because editBan only ever acts on one ban (obviously)
		var/list/row = data["ban"]

		var/client/adminC
		for (var/client/C in clients) //grab us a good ol' admin client
			if (C.ckey == row["akey"])
				adminC = C
				break

		if (!adminC)
			adminC = (row["akey"] ? row["akey"] : "N/A")

		var/target = "[row["ckey"]] (IP: [row["ip"]], CompID: [row["compID"]])"
		var/expiry = getExpiry(text2num(row["timestamp"]))

		var/serverLogSnippet = row["server"] ? "Server: [row["server"]]" : "Server: all"

		var/duration = expiry == 0 ? data["text_ban_length"] : expiry

		logTheThing(LOG_ADMIN, adminC, "edited [constructTarget(target,"admin")]'s ban. Reason: [row["reason"]] Duration: [duration] [serverLogSnippet]")
		logTheThing(LOG_DIARY, adminC, "edited [constructTarget(target,"diary")]'s ban. Reason: [row["reason"]] Duration: [duration] [serverLogSnippet]", "admin")
		message_admins("<span class='internal'>[key_name(adminC)] edited [target]'s ban. Reason: [row["reason"]] Duration: [duration] [serverLogSnippet]</span>")

		var/ircmsg[] = new()
		ircmsg["key"] = (isclient(adminC) && adminC.key ? adminC.key : adminC)
		ircmsg["name"] = (isclient(adminC) && adminC.mob && adminC.mob.name ? stripTextMacros(adminC.mob.name) : "N/A")
		ircmsg["msg"] = "edited [target]'s ban. Reason: [row["reason"]]. Duration: [duration]. [serverLogSnippet]."
		ircbot.export_async("admin", ircmsg)

		return 0

	else
		var/banTimestamp = data["mins"]
		if (data["mins"] > 0) //If a temp ban, calculate expiry
			var/CMinutes = (world.realtime / 10) / 60
			banTimestamp = (data["previous"] ? CMinutes + data["mins"] + 7200 : CMinutes + data["mins"]) //Add 5 days (7200 mins) onto the ban if it's an evasion attempt

		var/query[] = new()
		query["id"] = data["id"]
		query["ckey"] = (data["ckey"] ? data["ckey"] : "N/A")
		query["compID"] = (data["compID"] ? data["compID"] : "N/A")
		query["ip"] = (data["ip"] ? data["ip"] : "N/A")
		query["reason"] = data["reason"]
		query["akey"] = data["akey"]
		query["timestamp"] = banTimestamp
		if (data["server"])
			query["server"] = data["server"]
		data = apiHandler.queryAPI("bans/edit", query)


/client/proc/editBanDialog(id, ckey, compID, ip, oreason, otimestamp)
	if (src.holder?.level >= LEVEL_SA)
		var/CMinutes = (world.realtime / 10) / 60
		var/remaining = (text2num(otimestamp) - CMinutes)
		if(!remaining || remaining < 0) remaining = 0

		var/data[] = new()
		data["ckey"] = input(src, "Ckey (lowercase, only alphanumeric, no spaces)", "Ban", ckey) as null|text
		data["compID"] = input(src, "Computer ID (leave blank to skip)", "Ban", compID) as null|text
		data["ip"] = input(src, "IP Address", "Ban", ip) as null|text

		if (!data["ckey"] && !data["ip"] && !data["compID"])
			boutput(src, "<span class='alert'>You need to input a ckey or a compID or an IP, all cannot be blank.</span>")
			return

		var/reason = input(src,"Reason for ban?","Ban", oreason) as null|text
		if(!reason)
			boutput(src, "<span class='alert'>You need to enter a reason for the ban.</span>")
			return
		data["reason"] = reason

		var/datum/game_server/game_server = global.game_servers.input_server(src, "What server does the ban apply to?", "Ban", can_pick_all=TRUE)
		if(isnull(game_server))
			return
		data["server"] = istype(game_server) ? game_server.id : null // null = all servers

		var/ban_time = input(src,"How long will the ban be? (select Custom to alter existing duration)","Ban") as null|anything in \
			list("Half-hour","One Hour","Six Hours","One Day","Half a Week","One Week","One Month","Until Appeal","Permanent","Custom")
		var/mins = 0
		switch(ban_time)
			if("Half-hour")
				mins = 30
			if("One Hour")
				mins = 60
			if("Six Hours")
				mins = 360
			if("One Day")
				mins = 1440
			if("Half a Week")
				mins = 5040
			if("One Week")
				mins = 10080
			if("One Month")
				mins = 43200
			if("Until Appeal")
				mins = -1
			if("Permanent")
				mins = 0
			else
				var/cust_mins = input(src,"How many minutes? (1440 = one day)","BAN HE",remaining ? remaining : 1440) as null|num
				if(!cust_mins)
					boutput(src, "<span class='alert'>No time entered, cancelling ban.</span>")
					return
				if(cust_mins >= 525600)
					boutput(src, "<span class='alert'>Ban time too long. Ban shortened to one year (525599 minutes).</span>")
					mins = 525599
				else
					mins = cust_mins

		data["id"] = id
		data["reason"] = reason
		data["mins"] = mins
		data["text_ban_length"] = ban_time
		data["akey"] = src.ckey
		editBan(data)

		src.holder.banPanel()
	else
		alert("You need to be at least a Secondary Administrator to ban players.")
		return 1


/proc/deleteBan(data)
	set background = 1

	if (data["data_hub_callback"])
		if (data["error"])
			return data["error"]
		//we can get away with just this because deleteBan only ever acts on one ban (obviously)
		var/list/row = data["ban"]

		var/client/adminC
		for (var/client/C in clients)
			if (C.ckey == row["akey"])
				adminC = C
				break

		if (!adminC)
			adminC = (row["akey"] ? row["akey"] : "N/A")

		var/target = "[row["ckey"]] (IP: [row["ip"]], CompID: [row["compID"]])"
		var/expired = (row["akey"] == "Auto Unbanner" ? 1 : 0)

		if (expired)
			logTheThing(LOG_ADMIN, null, "[row["ckey"]]'s ban expired.")
			logTheThing(LOG_DIARY, null, "[row["ckey"]]'s ban expired.", "admin")
			message_admins("<span class='internal'>Ban expired for [target]</span>")
		else
			logTheThing(LOG_ADMIN, adminC, "unbanned [row["ckey"]]")
			logTheThing(LOG_DIARY, adminC, "unbanned [row["ckey"]]", "admin")
			message_admins("<span class='internal'>[key_name(adminC)] unbanned [target]</span>")

		var/ircmsg[] = new()
		ircmsg["key"] = (isclient(adminC) && adminC.key ? adminC.key : adminC)
		ircmsg["name"] = (expired ? "\[Expired\]" : "[isclient(adminC) && adminC.mob && adminC.mob.name ? stripTextMacros(adminC.mob.name) : "N/A"]")
		ircmsg["msg"] = (expired ? "[row["ckey"]]'s ban removed." : "deleted [row["ckey"]]'s ban.")
		ircbot.export_async("admin", ircmsg)

		return 0

	else
		var/query[] = new()
		query["id"] = data["id"]
		query["ckey"] = data["ckey"]
		query["compID"] = data["compID"]
		query["ip"] = data["ip"]
		query["akey"] = data["akey"]
		data = apiHandler.queryAPI("bans/delete", query)


/client/proc/deleteBanDialog(id, ckey, compID, ip, akey)
	if (src.holder?.level >= LEVEL_SA)
		if(alert(src, "Are you sure you want to unban [ckey]?", "Confirmation", "Yes", "No") == "Yes")
			var/data[] = new()
			data["id"] = id
			data["ckey"] = ckey
			data["compID"] = compID
			data["ip"] = ip
			data["akey"] = akey
			deleteBan(data)
			src.holder.banPanel()
	else
		alert("You need to be at least a Secondary Administrator to remove bans.")

/*
/proc/addException(step = 1, data)
	set background = 1

	if (step == 1)
		var/query[] = new()
		query["ckey"] = data["ckey"]
		query["akey"] = data["akey"]
		data = apiHandler.queryAPI("bans/addException", query)

	if (step == 2 || !centralConn)
		var/list/ldata = data
		if (!ldata) return "No data returned from query"
		if (ldata["error"])
			return ldata["error"]
		//we can get away with just this because deleteBan only ever acts on one ban (obviously)
		var/list/row = ldata[ldata[1]]

		var/client/adminC
		for (var/client/C in clients)
			if (C.ckey == row["akey"])
				adminC = C
				break

		if (!adminC)
			adminC = (row["akey"] ? row["akey"] : "N/A")

		var/target = "[row["ckey"]] (IP: [row["ip"]], CompID: [row["compID"]])"
		var/expired = (row["akey"] == "Auto Unbanner" ? 1 : 0)

		if (expired)
			logTheThing(LOG_ADMIN, null, "[row["ckey"]]'s ban expired.")
			logTheThing(LOG_DIARY, null, "[row["ckey"]]'s ban expired.", "admin")
			message_admins("<span class='internal'>Ban expired for [target]</span>")
		else
			logTheThing(LOG_ADMIN, adminC, "unbanned [row["ckey"]]")
			logTheThing(LOG_DIARY, adminC, "unbanned [row["ckey"]]", "admin")
			message_admins("<span class='internal'>[key_name(adminC)] unbanned [target]</span>")

		var/ircmsg[] = new()
		ircmsg["key"] = (isclient(adminC) && adminC.key ? adminC.key : adminC)
		ircmsg["name"] = (expired ? "\[Expired\]" : "[isclient(adminC) && adminC.mob && adminC.mob.name ? stripTextMacros(adminC.mob.name) : "N/A"]")
		ircmsg["msg"] = (expired ? "[row["ckey"]]'s ban removed." : "deleted [row["ckey"]]'s ban.")
		ircbot.export_async("admin", ircmsg)

		return 0


/client/proc/addExceptionDialog()
	if (src.holder && usr.level >= LEVEL_SA)
		if(alert(usr, "Are you sure you want to unban [ckey]?", "Confirmation", "Yes", "No") == "Yes")
			var/data[] = new()
			data["id"] = id
			data["ckey"] = ckey
			data["compID"] = compID
			data["ip"] = ip
			data["akey"] = akey
			deleteBan(data)
			src.holder.banPanel()
	else
		alert("You need to be at least a Secondary Administrator to add ban exceptions.")
*/

/////////////////////////
// BAN PANEL PROCS (called via ejhax)
/////////////////////////


/datum/admins/proc/banPanel()
	var/CMinutes = (world.realtime / 10) / 60
	var/bansHtml = grabResource("html/admin/banPanel.html")
	var/windowName = "banPanel"
	bansHtml = replacetext(bansHtml, "null /* window_name */", "'[windowName]'")
	bansHtml = replacetext(bansHtml, "null /* ref_src */", "'\ref[src]'")
	bansHtml = replacetext(bansHtml, "null /* cminutes */", "[CMinutes]")
	bansHtml = replacetext(bansHtml, "null /* api_data_params */", "'data_server=[serverKey]&data_id=[config.server_id]&data_version=[config.goonhub_api_version]'")
	if (centralConn)
		bansHtml = replacetext(bansHtml, "null /* api_key */", "'[md5(config.goonhub_api_web_token)]'")
	usr << browse(bansHtml,"window=[windowName];size=1080x500")


/client/proc/openBanPanel()
	set name = "Ban Panel"
	SET_ADMIN_CAT(ADMIN_CAT_PLAYERS)
	if (src.holder && !src.holder.tempmin)
		src.holder.banPanel()
	else
		alert("UM, EXCUSE ME??  YOU AREN'T AN ADMIN, GET DOWN FROM THERE!")
		src << sound('sound/voice/farts/poo2.ogg')
		logTheThing(LOG_ADMIN, src, "tried to access the ban panel")
		logTheThing(LOG_DIARY, src, "tried to access the ban panel", "admin")
		message_admins("[key_name(src)] tried to access the ban panel but was denied.")
		del(usr.client)
	return


//DEBUG (gets the latest ban and prints it out)
/proc/debugBans(data)
	set background = 1

	if (islist(data) && data["data_hub_callback"])
		var/list/ban = data["ban"]
		for (var/e = 1, e <= ban.len, e++) //each ban
			var/id = ban[e]
			var/list/details = ban[id]
			boutput(world, id)
			for (var/i = 1, i <= details.len, i++) //each item for this ban
				boutput(world, "[details[i]]: [details[details[i]]]")

	else
		apiHandler.queryAPI("bans/debug")


/////////////////////////
// LOCAL AND REMOTE DB SYNCHRONISATION
/////////////////////////


/proc/writeToBanLog(data)
	if (!data) return 0

	var/banLog = "data/banLog.log"
	var/lastID = 0
	if (fexists(banLog))
		//Here we fetch the latest logID, increment it, then append our data as json
		var/list/log = dd_file2list(banLog)
		var/lastIndex = (log.len > 1 ? log.len - 1 : 1)
		var/lastRow = log[lastIndex]
		var/list/rowDetails = splittext(lastRow, ":")
		lastID = text2num(rowDetails[1])

	var/newID = lastID + 1
	var/append = json_encode(data)
	var/logFile = file(banLog)
	boutput(logFile, "[newID]:[append]")

	return 1


/proc/clearBanLog()
	var banLog = "data/banLog.log"
	if (fexists(banLog))
		fdel(banLog)

	return 1


/proc/forceUpdateLocalBans(latestLocalID, latestRemoteID)
	//Construct the log IDs we need from the remote
	var/needBans = ""
	for (var/id = latestLocalID + 1, id <= latestRemoteID, id++)
		needBans += "[id],"

	needBans = copytext(needBans, 1, -1) //Remove the trailing comma

	//Ask the remote for them
	var/query[] = new()
	query["ids"] = needBans
	var/data[] = apiHandler.queryAPI("bans/updateLocal", query, 1)
	if (!data) return 0

	if (data["error"]) //Error returned from the API welp
		logTheThing(LOG_DEBUG, null, "<b>Bans Error</b>: Error returned in <b>forceUpdateLocalBans</b>: [data["error"]]")
		logTheThing(LOG_DIARY, null, "Bans Error: Error returned in forceUpdateLocalBans: [data["error"]]", "debug")
		return 0

	logTheThing(LOG_DEBUG, null, "UPDATE LOCAL DEBUG: data: [list2params(data)]")

	//Loop through the bans we were given
	for (var/row in data)
		var/logID = row
		if (!row) break
		logTheThing(LOG_DEBUG, null, "UPDATE LOCAL DEBUG: logID: [logID]")
		var/list/details = json_decode(row[logID])
		logTheThing(LOG_DEBUG, null, "UPDATE LOCAL DEBUG: details: [list2params(details)]")
		var/type = details["type"]
		details.Remove(details["type"])

		//Decide what to do with it
		var/returnData[] = new()
		if (type == "add")
			returnData = addBanApiFallback(details)
		if (type == "edit")
			returnData = editBanApiFallback(details)
		if (type == "delete")
			returnData = deleteBanApiFallback(details)

		if (returnData["error"]) //Error returned from the local db jeeeeez aint nothing going our way
			logTheThing(LOG_DEBUG, null, "<b>Local API Error</b> - Callback failed in <b>[type]BanApiFallback</b> with message: <b>[returnData["error"]]</b>")
			logTheThing(LOG_DIARY, null, "<b>Local API Error</b> - Callback failed in [type]BanApiFallback with message: [returnData["error"]]", "debug")
			if (returnData["showAdmins"])
				message_admins("<span class='internal'><b>Failed for route [type]BanApiFallback</b>: [returnData["error"]]</span>")

			return 0

	/*
	for (var/e = 1, e <= data.len, e++) //each ban
		var/logID = data[e]
		logTheThing(LOG_DEBUG, null, "UPDATE LOCAL DEBUG: logID: [logID]")
		var/list/details = json_decode(data[logID])
		logTheThing(LOG_DEBUG, null, "UPDATE LOCAL DEBUG: details: [list2params(details)]")
		var/type = details["type"]
		details.Remove(details["type"])

		//Decide what to do with it
		var/returnData[] = new()
		if (type == "add")
			returnData = addBanApiFallback(details)
		if (type == "edit")
			returnData = editBanApiFallback(details)
		if (type == "delete")
			returnData = deleteBanApiFallback(details)

		if (returnData["error"]) //Error returned from the local db jeeeeez aint nothing going our way
			logTheThing(LOG_DEBUG, null, "<b>Local API Error</b> - Callback failed in <b>[type]BanApiFallback</b> with message: <b>[returnData["error"]]</b>")
			logTheThing(LOG_DIARY, null, "<b>Local API Error</b> - Callback failed in [type]BanApiFallback with message: [returnData["error"]]", "debug")
			if (returnData["showAdmins"])
				message_admins("<span class='internal'><b>Failed for route [type]BanApiFallback</b>: [returnData[</span>"error"]]")

			return 0
	*/

	return 1


/proc/forceUpdateRemoteBans(latestLocalID, latestRemoteID)
	logTheThing(LOG_DEBUG, null, "UPDATE REMOTE DEBUG: latestLocalID: [latestLocalID]")
	logTheThing(LOG_DEBUG, null, "UPDATE REMOTE DEBUG: latestRemoteID: [latestRemoteID]")
	//Construct the log IDs the remote is missing
	var/sendBans[] = new()
	for (var/id = latestRemoteID + 1, id <= latestLocalID, id++)
		sendBans.Add(id)

	logTheThing(LOG_DEBUG, null, "UPDATE REMOTE DEBUG: sendBans: [list2params(sendBans)]")

	var/list/log = dd_file2list("data/banLog.log")

	//Get the data for those log IDs
	var/parsedLog[] = new()
	for (var/i = 1, i <= log.len, i++)
		var/row = log[i]
		logTheThing(LOG_DEBUG, null, "UPDATE REMOTE DEBUG: row: [row]")
		var/list/rowDetails = splittext(row, ":")
		logTheThing(LOG_DEBUG, null, "UPDATE REMOTE DEBUG: rowDetails: [list2params(rowDetails)]")
		var/logID = rowDetails[1]
		logID = text2num(logID)
		logTheThing(LOG_DEBUG, null, "UPDATE REMOTE DEBUG: logID: [logID]")
		if (logID in sendBans)
			var/lengthToCut = length(logID)+3 //+1 for the colon, +2 for copytext being a shitass
			var/details = copytext(row, lengthToCut)
			logTheThing(LOG_DEBUG, null, "UPDATE REMOTE DEBUG: details: [details]")
			parsedLog["[logID]"] = details

	logTheThing(LOG_DEBUG, null, "UPDATE REMOTE DEBUG: parsedLog: [json_encode(parsedLog)]")

	//Send it to the remote so it can update
	var/query[] = new()
	query["bans"] = json_encode(parsedLog)
	apiHandler.queryAPI("bans/updateRemote", query)

	return 1


//Universal proc for checking if both the local ban db and the remote are synced
/proc/bansParityCheck()
	//Ok we should probably make sure this shit doesn't run on local servers
	//yes we are checking filesize of the ban db here. it is a nice independent way of doing it
	if (!centralConn || !fexists("data/localBans.db") || length(file("data/localBans.db")) < 102400)
		return 0

	//Get the latest logID from the local ban log
	var/banLog = "data/banLog.log"
	var/banLogF = file(banLog)
	var/latestLocalID = 0

	//Only operate on the log if it...exists and has stuff, naturally
	if (fexists(banLog) && length(file2text(banLogF)) > 0)
		var/list/log = dd_file2list(banLog)
		var/lastIndex = (log.len > 1 ? log.len - 1 : 1)
		var/lastRow = log[lastIndex]
		log = splittext(lastRow, ":")
		latestLocalID = log[1]

	//Get the latest logID from the API
	var/query[] = new()
	query["latestLocalID"] = latestLocalID
	var/data[] = apiHandler.queryAPI("bans/parity", query, 1)
	if (!data) return 0

	var/list/row = data[data[1]]
	if (!row["logID"])
		return "ERROR: logID is not present from remote, cannot compare parity."
	var/latestRemoteID = row["logID"]

	//Just making sure
	latestLocalID = text2num(latestLocalID)
	latestRemoteID = text2num(latestRemoteID)

	//Local bans are out of date
	if (latestLocalID < latestRemoteID)
		if (forceUpdateLocalBans(latestLocalID, latestRemoteID))
			clearBanLog() //we're synced! clean up
			return "Updated local bans to match central server"
		return

	//Remote bans are out of date
	if (latestRemoteID < latestLocalID)
		if (forceUpdateRemoteBans(latestLocalID, latestRemoteID))
			clearBanLog() //we're synced! clean up
			return "Updated remote bans to match cached local changes"
		return

	//Nothing is out of date supposedly possibly maybe??
	clearBanLog() //we're synced! clean up
	return "Both databases are up to date. Yay!"


/proc/debugToggleCentralConn()
	if (centralConn)
		centralConn = 0
		centralConnTries = 5
		return "Set centralConn OFF"
	else
		centralConn = 1
		centralConnTries = 0
		return "Set centralConn ON"

