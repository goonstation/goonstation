/*********************************
For the main html chat area
*********************************/


#define CTX_PM 1
#define CTX_SMSG 2
#define CTX_BOOT 4
#define CTX_BAN 8
#define CTX_GIB 16
#define CTX_POPT 32
#define CTX_JUMP 64
#define CTX_GET 128

#define CTX_OBSERVE 256
#define CTX_GHOSTJUMP 512

// minimum number of messages in a single tick to consider it a "burst"
#define CHAT_BURST_START 5
// amount of time after a "burst" starts to withhold messages
#define CHAT_BURST_TIME 0.2 SECONDS

//Precaching a bunch of shit
var/global
	savefile/iconCache = new /savefile("data/iconCache.sav") //Cache of icons for the browser output
	cFlagsShitguy = CTX_GIB | CTX_GET
	cFlagsSa = CTX_BAN | CTX_POPT | CTX_JUMP
	cFlagsMod = CTX_SMSG | CTX_BOOT | CTX_PM

	cFlagsDead = CTX_OBSERVE | CTX_GHOSTJUMP
	// Why is this defined this way you ask?
	// It's because if you define an associative list mapping constants inside strings
	// like "[LEVEL_MOD]" = FOOBAR_SHITFUCK_FUCKFACE
	// The byond object tree output gets completely fucked in the ass and generates
	// broken xml
	list/contextFlags = list(1 = 0,2 = cFlagsMod,3 = cFlagsSa,4 = 0,5 = 0,6 = cFlagsShitguy,7 = 0,8 = 0)

	/*
	8 = LEVEL_HOST
	7 = LEVEL_CODER
	6 = LEVEL_ADMIN
	5 = LEVEL_PA
	4 = LEVEL_IA
	3 = LEVEL_SA
	2 = LEVEL_MOD
	1 = LEVEL_BABBY
	*/

//On client, created on login
/datum/chatOutput
	/// client ref
	var/client/owner = null
	/// Has the client loaded the browser output area?
	var/loaded = 0
	/// How many times has the client tried to load the output area?
	var/loadAttempts = 0
	/// If they haven't loaded chat, this is where messages will go until they do
	var/list/messageQueue = list()
	var/burstTime = 0
	var/burstCount = 0
	/// If they have loaded chat but there's too much chat the messages go here
	var/list/burstQueue = null
	/// Context menu flags for the admin powers
	var/ctxFlag = 0
	/// Has the client sent a cookie for analysis
	var/cookieSent = 0
	/// Contains the connection history passed from chat cookie
	var/list/connectionHistory = list()
	/// Last ping value reported by the client
	var/last_ping = null

/datum/chatOutput/New(client/C)
	..()

	if (C)
		src.owner = C
		return 1

/datum/chatOutput/proc/start()
	//Check for existing chat
	if (!src.owner) return 0
	if (winget(src.owner, "browseroutput", "is-disabled") == "false") //Already setup
		src.doneLoading()
	else //Not setup
		src.load()

	return 1

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
				"browserassets/css/fonts/fontawesome-webfont.svg",
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
			apiHandler.queryAPI("versions/add", list(
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

/datum/chatOutput/proc/changeTheme(theme)
	var/data = json_encode(list("changeTheme" = theme))
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
		if (connData && islist(connData) && connData.len > 0 && connData["connData"])
			src.connectionHistory = connData["connData"] //lol fuck
			var/list/found = new()
			for (var/i = src.connectionHistory.len; i >= 1; i--)
				var/list/row = src.connectionHistory[i]
				if (!row || row.len < 3 || (!row["ckey"] && !row["compid"] && !row["ip"])) //Passed malformed history object
					return
				if (checkBan(row["ckey"], row["compid"], row["ip"]))
					found = row
					break

			//Uh oh this fucker has a history of playing on a banned account!!
			if (found.len > 0 && found["ckey"] != src.owner.ckey)
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
				banData["compID"] = src.owner.computer_id
				banData["akey"] = "Auto Banner"
				banData["ip"] = src.owner.address
				banData["reason"] = "\[Evasion Attempt\] Previous ckey: [found["ckey"]]"
				banData["mins"] = 0
				addBan(banData)
	src.cookieSent = 1

/datum/chatOutput/proc/getContextFlags()
	var/ret = src.ctxFlag
	if(src.owner && istype( src.owner.mob, /mob/dead/observer ))
		ret |= cFlagsDead
	return ret

/// Called in New() (/datum/admins)
/datum/chatOutput/proc/getContextFlag()
	if (!src.owner.holder) return
	var/level = src.owner.holder.level

	for (var/x = level; x >= -1 ; x--) //-1 is the lowest rank
		var/rankFlags = contextFlags[x+2] // X + 2 because fuck byond. See definition of contextflags at the top of this file.
		if (rankFlags)
			src.ctxFlag |= rankFlags

/// Called by js client on admin command via context menu
/datum/chatOutput/proc/handleContextMenu(command, target)
	if (!src.owner.holder && command != "observe" && command != "teleport") return // oopsy i'm so messy heehee
	var/datum/mind/targetMind = locate(target)
	var/mob/targetMob
	if (targetMind)
		targetMob = targetMind.current
	else //The mind no longer exists? What? How?!
		return

	switch(command)
		if ("pm")
			src.owner.cmd_admin_pm(targetMob)
		if ("smsg")
			src.owner.cmd_admin_subtle_message(targetMob)
		if ("jump")
			if (!istype(targetMob, /mob/dead/target_observer))
				src.owner.jumptomob(targetMob)
			else
				var/jumptarget = targetMob.eye
				if (jumptarget)
					src.owner.jumptoturf(get_turf(jumptarget))
		if ("get")
			if (tgui_alert(src.owner, "Are you sure you want to get [targetMob]?", "Confirmation", list("Yes", "No")) == "Yes")
				src.owner.Getmob(targetMob)
		if ("boot")
			src.owner.cmd_boot(targetMob)
		if ("ban")
			src.owner.addBanDialog(targetMob)
		if ("gib")
			src.owner.cmd_admin_gib(targetMob)
			logTheThing(LOG_ADMIN, src.owner, "gibbed [constructTarget(targetMob,"admin")].")
		if ("popt")
			if(src.owner.holder)
				src.owner.holder.playeropt(targetMob)
		if ("observe")
			if (istype(src.owner.mob, /mob/dead/target_observer))
				src.owner.mob:set_observe_target(targetMob)
			if(istype(src.owner.mob, /mob/dead/observer))
				src.owner.mob:insert_observer(targetMob)
		if ("teleport")
			if (istype(src.owner.mob, /mob/dead/target_observer))
				qdel(src.owner.mob)
			if(istype(src.owner.mob, /mob/dead/observer))
				src.owner.mob.set_loc(get_turf(targetMob))

//todo
/datum/chatOutput/proc/changeChatMode(mode)
	if (!mode) return
	var/data = json_encode(list("modeChange" = mode))
	data = url_encode(data)

	for (var/client/C in clients)
		ehjax.send(C, "browseroutput", data)

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

/datum/chatOutput/proc/adjustVolumeRaw(volume)
	var/data = json_encode(list("adjustVolume" = volume))
	data = url_encode(data)

	ehjax.send(src.owner, "browseroutput", data)

/datum/chatOutput/proc/adjustVolume(volume)
	var/data = json_encode(list("adjustVolume" = volume / 100))
	data = url_encode(data)

	ehjax.send(src.owner, "browseroutput", data)

/// Called by js client every 60 seconds
/datum/chatOutput/proc/ping(last_ping)
	last_ping = text2num(last_ping)
	if(last_ping > 0)
		src.last_ping = last_ping
	return "pong"


//Global chat procs

//Converts an icon to base64. Operates by putting the icon in the iconCache savefile,
// exporting it as text, and then parsing the base64 from that.
// (This relies on byond automatically storing icons in savefiles as base64)
/proc/icon2base64(icon, iconKey = "misc")
	if (!isicon(icon)) return 0

	iconCache[iconKey] << icon
	iconCache[iconKey + "_ts"] << world.time
	var/iconData = iconCache.ExportText(iconKey)
	var/list/partial = splittext(iconData, "{")
	return copytext(partial[2], 3, -5)


/proc/bicon(obj)
	if (ispath(obj))
		obj = new obj()

	var/baseData

	if (isicon(obj))
		baseData = icon2base64(obj)
		return "<img style=\"position: relative; left: -1px; bottom: -3px;\" class=\"icon misc\" src=\"data:image/png;base64,[baseData]\" />"

	if (obj && obj:icon)
		//Hash the darn dmi path and state
		var/iconKey = md5("[obj:icon][obj:icon_state]")
		var/iconData

		//See if key already exists in savefile
		var/iconTimestamp
		iconCache["[iconKey]_ts"] >> iconTimestamp
		iconData = iconCache.ExportText(iconKey)
		if (iconData && iconTimestamp && (world.time - iconTimestamp) < 1 WEEK)
			//It does! Ok, parse out the base64
			var/list/partial = splittext(iconData, "{")

			if (length(partial) < 2)
				logTheThing(LOG_DEBUG, null, "Got invalid savefile data for: [obj]")
				return

			baseData = copytext(partial[2], 3, -5)
		else
			//It doesn't exist! Create the icon
			var/icon/icon = icon(file(obj:icon), obj:icon_state, SOUTH, 1)

			if (!icon)
				logTheThing(LOG_DEBUG, null, "Unable to create output icon for: [obj]")
				return

			baseData = icon2base64(icon, iconKey)

		return "<img style=\"position: relative; left: -1px; bottom: -3px;\" class=\"icon [obj:icon_state]\" src=\"data:image/png;base64,[baseData]\" />"

/proc/boutput(target = 0, message = "", group = "", forceScroll=FALSE)
	if (target == world)
		for (var/client/C in clients)
			boutput(C, message, group, forceScroll)
		return

	//If the target is a list, attempt to send the message to each item in the list
	//(it's up to the caller to ensure the list contains actual things we can send to)
	if (islist(target))
		for (var/T in target)
			boutput(T, message, group, forceScroll)
		return

	//Otherwise, we're good to throw it at the user
	else if (istext(message))
		if (istext(target)) return

		//Some macros remain in the string even after parsing and fuck up the eventual output
		message = stripTextMacros(message)

		message = replacetext(message, "\u2028", "") // this character crashes the js side and I don't know how to fix it there

		//Grab us a client if possible
		var/client/C
		if (isclient(target))
			C = target
		else if (ismob(target))
			var/mob/M = target
			if (M.boutput_relay_mob)
				boutput(M.boutput_relay_mob, message, group, forceScroll)
			else if(istype(M, /mob/living/silicon/ai))
				var/mob/living/silicon/ai/AI = M
				if(AI.deployed_to_eyecam)
					C = AI.eyecam?.client
			else
				C = M.client
		else if (ismind(target) && target:current)
			C = target:current:client

		if (islist(C?.chatOutput?.messageQueue) && !C.chatOutput.loaded)
			//Client sucks at loading things, put their messages in a queue
			C.chatOutput.messageQueue += list(list("message" = message, "group" = group))
		else
			if (C?.chatOutput)
				if (islist(C.chatOutput.burstQueue))
					C.chatOutput.burstQueue += list(list("message" = message, "group" = group))
					return

				var/now = TIME
				if (C.chatOutput.burstTime != now)
					C.chatOutput.burstTime = now
					C.chatOutput.burstCount = 1
				else
					C.chatOutput.burstCount++

				if (C.chatOutput.burstCount > CHAT_BURST_START)
					C.chatOutput.burstQueue = list(
						list("message" = message, "group" = group, "forceScroll" = forceScroll)
					)
					SPAWN(CHAT_BURST_TIME)
						target << output(list2params(list(
							json_encode(C.chatOutput.burstQueue)
						)), "browseroutput:outputBatch")
						C.chatOutput.burstQueue = null
					return

			target << output(list2params(list(
				message,
				group,
				0,
				forceScroll
			)), "browseroutput:output")

//Aliases for boutput
/proc/out(target = 0, message = "", group = "")
	boutput(target, message, group)

/*
I spent so long on this regex I don't want to get rid of it :(

if (findtext(message, "<IMG CLASS=ICON"))
	var/regex/R = new("/<IMG CLASS=icon SRC=(\\\[.*?\\\]) ICONSTATE='(.*?)'>/\[insertIconImg($1,$2)\]/e")
	//if (R.Find(message))
	var/newtxt = R.Replace(message)
	while(newtxt)
		message = newtxt
		newtxt = R.ReplaceNext(message)

	world.log << html_encode(message)
*/

/*
/client/verb/reloadChat()
	set name = "Reload Chat"

	del(src.chatOutput)
	winset(src, "browseroutput", "is-disabled=true")
	src.chatOutput = new /datum/chatOutput(src)
	src.chatOutput.start()

	out(src, "Reloaded chat")
*/
