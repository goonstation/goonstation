/var/global/datum/bans/bans = new

/datum/bans

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

	/// Add a ban
	proc/add(admin_ckey, server_id, ckey, comp_id, ip, reason, duration = FALSE, requires_appeal = FALSE)
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
			var/datum/apiModel/Tracked/BanResource/ban = apiHandler.queryAPI(addBan)
			// TODO: anything?
		catch (var/exception/e)
			var/datum/apiModel/Error/error = e.name
			out(world, error.message)
			// TODO: log + message admins about failure
			return

		// We do this instead of requiring an admin client argument because bans can be added multiple ways, e.g. from discord
		var/client/adminClient = find_client(admin_ckey)
		var/client/targetClient = find_client(ckey)

		var/durationHuman = duration ? src.getDurationHuman(duration) : "permanent"
		var/adminKey = adminClient ? adminClient.key : admin_ckey
		var/serverLogSnippet = server_id ? "from [server_id]" : "from all servers"
		var/replacementText = "[ckey] (IP: [ip], CompID: [comp_id])"

		// Handle target messaging, admin notices, and logging

		var/logMsg = "has banned [targetClient ? "[constructTarget(targetClient,"admin")]" : replacementText] [serverLogSnippet]. Duration: [durationHuman] Reason: [reason]."
		logTheThing(LOG_ADMIN, adminClient ? adminClient : adminKey, logMsg)
		logTheThing(LOG_DIARY, adminClient ? adminClient : adminKey, logMsg, "admin")

		var/adminMsg = "<span class='notice'>"
		adminMsg += adminClient ? key_name(adminClient) : adminKey
		adminMsg += " has banned [targetClient ? targetClient : replacementText] [serverLogSnippet].<br>Reason: [reason]<br>Duration: [durationHuman].</span>"
		message_admins(adminMsg)

		var/ircmsg[] = new()
		ircmsg["key"] = adminKey
		ircmsg["key2"] = "[ckey] (IP: [ip], CompID: [comp_id])"
		ircmsg["msg"] = reason
		ircmsg["time"] = durationHuman
		ircmsg["timestamp"] = duration / 60 // duration is in seconds, bot expects minutes
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

	/// Check if a ban exists
	proc/check(ckey, comp_id, ip)
		if (ip == "127.0.0.1") return FALSE // Ignore if localhost

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
		catch (var/exception/e)
			var/datum/apiModel/Error/error = e.name
			out(world, error.message)
			// TODO: log + message admins about failure
			return FALSE

		// Check for an evasion attempt
		var/originalBanDetails = ban.original_ban_detail
		if ((!isnull(originalBanDetails["ckey"]) && ckey != originalBanDetails["ckey"]) || \
				(!isnull(originalBanDetails["comp_id"]) && comp_id != originalBanDetails["comp_id"]) || \
				(!isnull(originalBanDetails["ip"]) && ip != originalBanDetails["ip"]))
			// TODO: add ban details to record an "evasion"

		// Build a message to show to the player
		var/message = "[ban.reason]<br>"
		message += "Banned By: [ban.game_admin["ckey"]]<br>"
		message += "This ban applies to [ban.server_id ? "this server only" : "all servers"].<br>"
		if (ban.expires_at)
			// TODO: get human readable duration remaining
			message += "(This ban will be automatically removed at [ban.expires_at])"
		else
			if (ban.requires_appeal)
				message += "Please make an <a href='https://forum.ss13.co/forumdisplay.php?fid=54'>appeal on the forums</a> to have it lifted."
			else
				message += "This is a permanent ban, you can't appeal this ban until 30 days have passed."

		return message

	/// Update an existing ban
	proc/update()
		//

	/// Remove a ban
	proc/remove()
		//

	/// Add details to an existing ban
	proc/addDetails()
		//

	/// Remove details from an existing ban
	proc/removeDetails()
		//
