/*
/datum/chatOutput/proc/load()
	if (src.owner)
		//For local-testing fallback
		if (!cdn)
			var/list/chatResources = list(
				"browserassets/js/jquery.min.js",
				"browserassets/js/errorHandler.js",
				//"browserassets/js/array.generics.min.js",
				//"browserassets/js/anchorme.js",
				"browserassets/js/browserOutput.js",
				"browserassets/css/fonts/fontawesome-webfont.eot",
				"browserassets/css/fonts/fontawesome-webfont.ttf",
				"browserassets/css/fonts/fontawesome-webfont.woff",
				"browserassets/css/font-awesome.css",
				"browserassets/css/browserOutput.css"
			)
			src.owner.loadResourcesFromList(chatResources)

		src.owner << browse(grabResource("html/browserOutput.html"), "window=browseroutput")

		if (src.loadAttempts < 5) //To a max of 5 load attempts
			SPAWN(20 SECONDS) //20 seconds
				if (src.owner && !src.loaded)
					src.loadAttempts++
					src.load()
		else
			//Exceeded. Maybe do something extra here
			return
	else
		//Client managed to logoff or otherwise get deleted
		return

/// Called on chat output done-loading by JS.
/datum/chatOutput/proc/doneLoading(ua)
	if (src.owner && !src.loaded)
		src.loaded = 1
		winset(src.owner, "browseroutput", "is-disabled=false")
		//if (src.owner.holder)
		src.loadAdmin()
		if (src.messageQueue)
			for (var/list/message in src.messageQueue)
				boutput(src.owner, message["message"], message["group"])
		src.messageQueue = null
		if (ua)
			//For persistent user tracking
			apiHandler?.queryAPI("versions/add", list(
				"ckey" = src.owner.ckey,
				"userAgent" = ua,
				"byondMajor" = src.owner.byond_version,
				"byondMinor" = src.owner.byond_build
			))

		else
			src.sendClientData()
			/* WIRE TODO: Fix this so the CDN dying doesn't break everyone
			SPAWN(1 MINUTE) //60 seconds
				if (!src.cookieSent) //Client has very likely futzed with their local html/js chat file
					out(src.owner, "<div class='fatalError'>Chat file tampering detected. Closing connection.</div>")
					del(src.owner)
			*/

/// Called in update_admins()
/datum/chatOutput/proc/loadAdmin()
		var/data = json_encode(list("loadAdminCode" = replacetext(replacetext(grabResource("html/adminOutput.html"), "\n", ""), "\t", "")))
		ehjax.send(src.owner, "browseroutput", url_encode(data))

/// Sends client connection details to the chat to handle and save
/datum/chatOutput/proc/sendClientData()
	//Fix for Cannot read null.ckey (how!?)
	if (!src.owner) return

	//Get dem deets
	var/list/deets = list("clientData" = list())
	deets["clientData"]["ckey"] = src.owner.ckey
	deets["clientData"]["ip"] = src.owner.address
	deets["clientData"]["compid"] = src.owner.computer_id
	var/data = json_encode(deets)
	ehjax.send(src.owner, "browseroutput", data)

/// Called by client, sent data to investigate (cookie history so far)
/datum/chatOutput/proc/analyzeClientData(cookie = "")
	if (!cookie) return
	if (cookie != "none")
		// Hotfix patch, credit to https://github.com/yogstation13/Yogstation/pull/9951
		var/regex/json_decode_crasher = regex("^\\s*(\[\\\[\\{\\}\\\]]\\s*){5,}")
		if (json_decode_crasher.Find(cookie))
			if (src.owner)
				message_admins("[src.owner] just attempted to crash the server using at least 5 '\['s in a row.")
				logTheThing(LOG_ADMIN, src.owner, "just attempted to crash the server using at least 5 '\['s in a row.", "admin")

				//Irc message too
				var/ircmsg[] = new()
				ircmsg["key"] = owner.key
				ircmsg["name"] = stripTextMacros(owner.mob.name)
				ircmsg["msg"] = "just attempted to crash the server using at least 5 '\['s in a row."
				ircbot.export_async("admin", ircmsg)
			return

		var/list/connData = json_decode(cookie)
		if (connData && islist(connData) && length(connData) && connData["connData"])
			src.connectionHistory = connData["connData"] //lol fuck
			var/list/found = new()
			for (var/i = src.connectionHistory.len; i >= 1; i--)
				var/list/row = src.connectionHistory[i]
				if (!row || length(row) < 3 || (!row["ckey"] && !row["compid"] && !row["ip"])) //Passed malformed history object
					return
				if (checkBan(row["ckey"], row["compid"], row["ip"]))
					found = row
					break

			//Uh oh this fucker has a history of playing on a banned account!!
			if (length(found) && found["ckey"] != src.owner.ckey)
				//TODO: add a new evasion ban for the CURRENT client details, using the matched row details
				message_admins("[key_name(src.owner)] has a cookie from a banned account! (Matched: [found["ckey"]], [found["ip"]], [found["compid"]])")
				logTheThing(LOG_DEBUG, src.owner, "has a cookie from a banned account! (Matched: [found["ckey"]], [found["ip"]], [found["compid"]])")
				logTheThing(LOG_DIARY, src.owner, "has a cookie from a banned account! (Matched: [found["ckey"]], [found["ip"]], [found["compid"]])", "debug")

				//Irc message too
				if(owner)
					var/ircmsg[] = new()
					ircmsg["key"] = owner.key
					ircmsg["name"] = stripTextMacros(owner.mob.name)
					ircmsg["msg"] = "has a cookie from banned account [found["ckey"]](IP: [found["ip"]], CompID: [found["compID"]])"
					ircbot.export_async("admin", ircmsg)

				var/banData[] = new()
				banData["ckey"] = src.owner.ckey
				banData["compID"] = (found["compID"] == "N/A" ? "N/A" : src.owner.computer_id) // don't add CID if original ban doesn't have one
				banData["akey"] = "Auto Banner"
				banData["ip"] = (found["ip"] == "N/A" ? "N/A" : src.owner.address) // don't add IP if original ban doesn't have one
				banData["reason"] = "\[Evasion Attempt\] Previous ckey: [found["ckey"]]"
				banData["mins"] = 0
				addBan(banData)
	src.cookieSent = 1

/datum/chatOutput/proc/playMusic(url, volume)
	if (!url || !volume) return
	var/data = json_encode(list("playMusic" = url, "volume" = volume / 100))
	data = url_encode(data)

	ehjax.send(src.owner, "browseroutput", data)

/datum/chatOutput/proc/playDectalk(url, trigger, volume)
	if (!url || !volume) return
	var/data = json_encode(list("dectalk" = url, "decTalkTrigger" = trigger, "volume" = volume / 100))
	data = url_encode(data)

	ehjax.send(src.owner, "browseroutput", data)

/datum/chatOutput/proc/adjustVolume(volume)
	var/data = json_encode(list("adjustVolume" = volume / 100))
	data = url_encode(data)
*/
	//ehjax.send(src.owner, "browseroutput", data)
