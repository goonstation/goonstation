/var/global/datum/bansHandler/bansHandler = new

/datum/bansHandler
	/// Convert duration to something useful for Humans
	proc/getDurationHuman(seconds)
		var/exp = seconds / 60
		if (exp <= 0)
			. = 0
		else
			if (exp >= ((24 HOURS) / (1 MINUTE))) // 1 day in minutes
				exp = round(exp / 1440, 0.1)
				. = "[exp] Day[exp > 1 ? "s" : ""]"
			else if (exp >= ((1 HOUR) / (1 MINUTE))) // 1 hour in minutes
				exp = round(exp / 60, 0.1)
				. = "[exp] Hour[exp > 1 ? "s" : ""]"
			else
				. = "[exp] Minute[exp > 1 ? "s" : ""]"

	/// List all bans
	proc/getAll(list/filters = list(), sort_by = "id", descending = TRUE, page = "1", per_page = 30)
		var/datum/apiRoute/bans/get/getBans = new
		getBans.queryParams = list(
			"filters" = filters,
			"sort_by" = sort_by,
			"descending" = descending,
			"page" = page,
			"per_page" = per_page
		)
		var/datum/apiModel/Paginated/BanResourceList/bans
		try
			bans = apiHandler.queryAPI(getBans)
		catch (var/exception/e)
			var/datum/apiModel/Error/error = e.name
			throw EXCEPTION(error.message)

		return bans

	/// Add a ban
	proc/add(admin_ckey, server_id, ckey, comp_id, ip, reason, duration = FALSE, requires_appeal = FALSE, added_externally = FALSE)
		duration = floor(duration ? duration / 10 : duration) // duration given in deciseconds, api expects seconds

		var/datum/apiModel/Tracked/BanResource/ban
		if (!added_externally)
			var/datum/apiRoute/bans/add/addBan = new
			addBan.buildBody(
				admin_ckey,
				roundId,
				server_id,
				ckey,
				comp_id,
				ip,
				reason,
				duration,
				requires_appeal
			)
			try
				ban = apiHandler.queryAPI(addBan)
			catch (var/exception/e)
				var/datum/apiModel/Error/error = e.name
				throw EXCEPTION(error.message)

		// We do this instead of requiring an admin client argument because bans can be added multiple ways, e.g. from discord
		var/client/adminClient = find_client(admin_ckey)
		var/client/targetClient = find_client(ckey)

		var/durationHuman = duration ? src.getDurationHuman(duration) : "permanent"
		var/adminKey = adminClient ? adminClient.key : admin_ckey
		var/serverLogSnippet = server_id ? "from [server_id]" : "from all servers"
		var/replacementText = "[ckey] (IP: [ip], CompID: [comp_id])"

		// Tell admins
		var/logMsg = "has banned [targetClient ? "[constructTarget(targetClient,"admin")]" : replacementText] [serverLogSnippet]. Duration: [durationHuman] Reason: [reason]."
		logTheThing(LOG_ADMIN, adminClient ? adminClient : adminKey, logMsg)
		logTheThing(LOG_DIARY, adminClient ? adminClient : adminKey, logMsg, "admin")
		var/adminMsg = "<span class='notice'>"
		adminMsg += adminClient ? key_name(adminClient) : adminKey
		adminMsg += " has banned [targetClient ? targetClient : replacementText] [serverLogSnippet].<br>Reason: [reason]<br>Duration: [durationHuman]."
		if (ban)
			adminMsg += " <a href='[goonhub_href("/admin/bans/[ban.id]", TRUE)]'>View Ban</a>"
		adminMsg += "</span>"
		message_admins(adminMsg)

		if (!added_externally)
			// Tell discord
			var/ircmsg[] = new()
			ircmsg["key"] = adminKey
			ircmsg["key2"] = "[ckey] (IP: [ip], CompID: [comp_id])"
			ircmsg["msg"] = reason + "\n\n\[View Ban\](<[goonhub_href("/admin/bans/[ban.id]")]>)"
			ircmsg["time"] = durationHuman
			ircmsg["timestamp"] = ((world.realtime / 10) / 60) + (duration / 60) // duration is in seconds, bot expects minutes
			ircbot.export_async("ban", ircmsg)

		if (targetClient)
			targetClient.mob.unlock_medal("Banned", FALSE)
			boutput(targetClient, "<span class='alert'><BIG><B>You have been banned by [adminKey].<br>Reason: [reason]</B></BIG></span>")
			boutput(targetClient, "<span class='alert'>To try to resolve this matter head to https://forum.ss13.co</span>")
			if (duration)
				boutput(targetClient, "<span class='alert'>You have received a ban. Duration: [durationHuman]</span>")
			else
				if (requires_appeal)
					boutput(targetClient, "<span class='alert'>You have received a ban. Make an <a href='https://forum.ss13.co/forumdisplay.php?fid=54'>appeal on the forums</a> to have it lifted.</span>")
				else
					boutput(targetClient, "<span class='alert'>You have received a permanent ban, you can't appeal this ban until 30 days have passed.</span>")

			del(targetClient)
		else
			logTheThing(LOG_DEBUG, ckey, "Bans: unable to find client to kick for banned ckey [ckey]")

	/// Check if a ban exists
	proc/check(ckey, comp_id, ip)
		if (!ip || ip == "127.0.0.1") return FALSE // Ignore if localhost

		var/datum/apiRoute/bans/check/checkBan = new
		checkBan.queryParams = list(
			"ckey" = ckey,
			"comp_id" = comp_id,
			"ip" = ip,
			"server_id" = config.server_id
		)
		var/datum/apiModel/Tracked/BanResource/ban
		try
			ban = apiHandler.queryAPI(checkBan)
		catch
			return FALSE

		// If we haven't recorded any of the player's connection details, this counts as an evasion
		var/recordedCkey = FALSE
		var/recordedCompId = FALSE
		var/recordedIp = FALSE
		for (var/datum/apiModel/Tracked/BanDetail/banDetail in ban.details)
			if (!ckey || banDetail.ckey == ckey) recordedCkey = TRUE
			if (!comp_id || banDetail.comp_id == comp_id) recordedCompId = TRUE
			if (!ip || banDetail.ip == ip) recordedIp = TRUE

		// var/evasionAttempt = FALSE
		if (!recordedCkey || !recordedCompId || !recordedIp)
			// evasionAttempt = TRUE
			SPAWN(0)
				try
					// Add these details to the existing ban
					src.addDetails(ban.id, TRUE, "bot", ckey, comp_id, ip)
				catch (var/exception/e)
					var/logMsg = "Failed to add ban evasion details to ban [ban.id] because: [e.name]"
					logTheThing(LOG_ADMIN, "bot", logMsg)
					logTheThing(LOG_DIARY, "bot", logMsg, "admin")

		// Build a message to show to the player
		var/message = "[ban.reason]<br>"
		message += "Banned By: [ban.game_admin.ckey]<br>"
		message += "This ban applies to [ban.server_id ? "this server only" : "all servers"].<br>"
		if (ban.expires_at)
			message += "(This ban will be automatically removed in [ban.duration_human])"
		else
			if (ban.requires_appeal)
				message += "Please make an <a href='https://forum.ss13.co/forumdisplay.php?fid=54'>appeal on the forums</a> to have it lifted."
			else
				message += "This is a permanent ban, you can't appeal this ban until 30 days have passed."

		return list(
			"ban" = ban,
			"message" = message
		)

	/// Update an existing ban
	proc/update(banId, admin_ckey, server_id, ckey, comp_id, ip, reason, duration, requires_appeal)
		duration = floor(duration ? duration / 10 : duration) // duration given in deciseconds, api expects seconds
		var/datum/apiRoute/bans/update/updateBan = new
		updateBan.routeParams = list("[banId]")
		updateBan.buildBody(
			admin_ckey,
			roundId,
			server_id,
			ckey,
			comp_id,
			ip,
			reason,
			duration,
			requires_appeal
		)
		var/datum/apiModel/Tracked/BanResource/ban
		try
			ban = apiHandler.queryAPI(updateBan)
		catch (var/exception/e)
			var/datum/apiModel/Error/error = e.name
			throw EXCEPTION(error.message)

		var/originalBanDetail = ban.original_ban_detail
		var/client/adminClient = find_client(admin_ckey)
		var/target = "[originalBanDetail["ckey"]] (IP: [originalBanDetail["ip"]], CompID: [originalBanDetail["comp_id"]])"
		var/durationHuman = duration ? src.getDurationHuman(duration) : "permanent"
		var/serverLogSnippet = ban.server_id ? "Server: [ban.server_id]" : "Server: all"

		// Tell admins
		var/logMsg = "edited [constructTarget(target,"admin")]'s ban. Reason: [ban.reason] Duration: [durationHuman] [serverLogSnippet]"
		logTheThing(LOG_ADMIN, adminClient ? adminClient : admin_ckey, logMsg)
		logTheThing(LOG_DIARY, adminClient ? adminClient : admin_ckey, logMsg, "admin")
		message_admins("<span class='internal'>[key_name(adminClient ? adminClient : admin_ckey)] edited [target]'s ban. Reason: [ban.reason] Duration: [durationHuman] [serverLogSnippet]. <a href='[goonhub_href("/admin/bans/[ban.id]", TRUE)]'>View Ban</a></span>")

		// Tell Discord
		var/ircmsg[] = new()
		ircmsg["key"] = adminClient ? adminClient.key : admin_ckey
		ircmsg["name"] = (adminClient && adminClient.mob && adminClient.mob.name ? stripTextMacros(adminClient.mob.name) : "N/A")
		ircmsg["msg"] = "edited [target]'s ban. Reason: [ban.reason]. Duration: [durationHuman]. [serverLogSnippet].\n\n\[View Ban\](<[goonhub_href("/admin/bans/[ban.id]")]>)"
		ircbot.export_async("admin", ircmsg)

	/// Remove a ban
	proc/remove(banId, admin_ckey, ckey, comp_id, ip)
		try
			var/datum/apiRoute/bans/delete/deleteBan = new
			deleteBan.routeParams = list("[banId]")
			deleteBan.buildBody(admin_ckey)
			apiHandler.queryAPI(deleteBan)
		catch (var/exception/e)
			var/datum/apiModel/Error/error = e.name
			throw EXCEPTION(error.message)

		var/client/adminClient = find_client(admin_ckey)
		var/target = "[ckey] (IP: [ip], CompID: [comp_id])"

		// Tell admins
		logTheThing(LOG_ADMIN, adminClient ? adminClient : admin_ckey, "unbanned [target]")
		logTheThing(LOG_DIARY, adminClient ? adminClient : admin_ckey, "unbanned [target]", "admin")
		message_admins("<span class='internal'>[key_name(adminClient ? adminClient : admin_ckey)] unbanned [target]</span>")

		// Tell discord
		var/ircmsg[] = new()
		ircmsg["key"] = adminClient ? adminClient.key : admin_ckey
		ircmsg["name"] = adminClient && adminClient.mob && adminClient.mob.name ? stripTextMacros(adminClient.mob.name) : "N/A"
		ircmsg["msg"] = "deleted [ckey]'s ban."
		ircbot.export_async("admin", ircmsg)

	/// Add details to an existing ban
	proc/addDetails(banId, evasion = FALSE, admin_ckey, ckey, comp_id, ip)
		var/datum/apiRoute/bans/add_detail/addDetail = new
		addDetail.routeParams = list("[banId]")
		addDetail.buildBody(admin_ckey, roundId, ckey, comp_id, ip, evasion)
		var/datum/apiModel/Tracked/BanDetail/banDetail
		try
			banDetail = apiHandler.queryAPI(addDetail)
		catch (var/exception/e)
			var/datum/apiModel/Error/error = e.name
			throw EXCEPTION(error.message)
		var/client/adminClient = find_client(admin_ckey)
		var/messageAdminsAdmin = admin_ckey == "bot" ? admin_ckey : key_name(adminClient ? adminClient : admin_ckey)
		var/target = "(Ckey: [banDetail.ckey], IP: [banDetail.ip], CompID: [banDetail.comp_id])"

		var/original_ckey = banDetail.original_ban_detail.ckey

		// Tell admins
		var/msg = "added ban [evasion ? "evasion" : ""] details [target] to Ban ID <a href='[goonhub_href("/admin/bans/[banId]", TRUE)]'>[banId]</a>, Original Ckey: [original_ckey]"
		logTheThing(LOG_ADMIN, adminClient ? adminClient : admin_ckey, msg)
		logTheThing(LOG_DIARY, adminClient ? adminClient : admin_ckey, msg, "admin")
		message_admins("<span class='internal'>[messageAdminsAdmin] [msg]</span>")

		// Tell discord
		msg = "added ban [evasion ? "evasion" : ""] details [target] to Ban ID \[[banId]\](<[goonhub_href("/admin/bans/[banId]")]>), Original Ckey: [original_ckey]"
		var/ircmsg[] = new()
		ircmsg["key"] = adminClient ? adminClient.key : admin_ckey
		ircmsg["name"] = adminClient && adminClient.mob && adminClient.mob.name ? stripTextMacros(adminClient.mob.name) : "N/A"
		ircmsg["msg"] = msg
		ircbot.export_async("admin", ircmsg)

	/// Remove details from an existing ban
	proc/removeDetails(banDetailId, admin_ckey)
		var/datum/apiRoute/bans/remove_detail/removeDetail = new
		removeDetail.routeParams = list("[banDetailId]")
		try
			apiHandler.queryAPI(removeDetail)
		catch (var/exception/e)
			var/datum/apiModel/Error/error = e.name
			throw EXCEPTION(error.message)

		var/client/adminClient = find_client(admin_ckey)

		// Tell admins
		var/msg = "removed ban detail ID [banDetailId]"
		logTheThing(LOG_ADMIN, adminClient ? adminClient : admin_ckey, msg)
		logTheThing(LOG_DIARY, adminClient ? adminClient : admin_ckey, msg, "admin")
		message_admins("<span class='internal'>[key_name(adminClient ? adminClient : admin_ckey)] [msg]</span>")

		// Tell discord
		var/ircmsg[] = new()
		ircmsg["key"] = adminClient ? adminClient.key : admin_ckey
		ircmsg["name"] = adminClient && adminClient.mob && adminClient.mob.name ? stripTextMacros(adminClient.mob.name) : "N/A"
		ircmsg["msg"] = msg
		ircbot.export_async("admin", ircmsg)


///////////////////////////
// Temp ban management, remove when new ban panel exists
///////////////////////////

/client/proc/addBanTempDialog(target)
	var/mob/M
	if (target && ismob(target)) M = target

	var/ckey = ckey(input(src.mob, "Ckey of the player", "Ckey", M ? M.ckey : "") as text)
	if (!ckey) return

	var/datum/player/player = find_player(ckey)
	var/client/targetC = player?.client

	var/defaultIp = targetC ? targetC.address : (M ? M.lastKnownIP : "")
	var/ip = input(src.mob, "IP of the player", "IP", defaultIp) as text
	var/defaultCompId = targetC ? targetC.computer_id : (M ? M.computer_id : "")
	var/compId = input(src.mob, "Computer ID of the player", "Computer ID", defaultCompId) as text

	var/datum/game_server/game_server = global.game_servers.input_server(src.mob, "What server does the ban apply to?", "Ban", can_pick_all=TRUE)
	if(isnull(game_server))
		return null
	var/serverId = istype(game_server) ? game_server.id : null // null = all servers

	var/list/durations = list(
		"Permanent" = "",
		"Half hour" = 30 MINUTES,
		"One hour" = 1 HOUR,
		"Six hours" = 6 HOURS,
		"One day" = 1 DAY,
		"Half a week" = 3.5 DAYS,
		"One week" = 1 WEEK,
		"Two weeks" = 2 WEEKS,
		"One month" = 30 DAYS,
		"Three months" = 90 DAYS,
		"Six months" = 26 WEEKS,
		"One year" = 52 WEEKS
	)
	var/durationName = tgui_input_list(src.mob, "How long should the ban last?", "Duration", durations)
	if (isnull(durationName)) return
	var/duration = durations[durationName]
	if (!duration) duration = FALSE

	var/reason = tgui_input_text(src.mob, "What is the reason for this ban?", "Reason", "", null, TRUE)
	if (!reason) return

	return list(
		"akey" = src.ckey,
		"server" = serverId,
		"ckey" = ckey,
		"compId" = compId,
		"ip" = ip,
		"reason" = reason,
		"duration" = duration
	)

/client/proc/addBanTemp(mob/target)
	ADMIN_ONLY
	var/list/data = src.addBanTempDialog(target)
	if (!data) return

	try
		bansHandler.add(data["akey"], data["server"], data["ckey"], data["compId"], data["ip"], data["reason"], data["duration"])
	catch (var/exception/e)
		tgui_alert(src.mob, "Failed to add ban because: [e.name]", "Error")

/client/proc/addBanTempUntargetted()
	set name = "Add Ban"
	set desc = "Add a ban"
	set popup_menu = 0
	SET_ADMIN_CAT(ADMIN_CAT_PLAYERS)
	ADMIN_ONLY
	SHOW_VERB_DESC


	src.addBanTemp()
