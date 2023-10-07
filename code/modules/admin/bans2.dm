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

	/// List all bans
	proc/getAll(filters, sort_by = "id", descending = TRUE, per_page = 30)
		var/datum/apiRoute/bans/get/getBans = new
		getBans.queryParams = list(
			"filters" = filters,
			"sort_by" = sort_by,
			"descending" = descending,
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
			apiHandler.queryAPI(addBan)
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
		adminMsg += " has banned [targetClient ? targetClient : replacementText] [serverLogSnippet].<br>Reason: [reason]<br>Duration: [durationHuman].</span>"
		message_admins(adminMsg)

		// Tell discord
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
		catch
			return FALSE

		// If we haven't recorded any of the player's connection details, this counts as an evasion
		var/recordedCkey = FALSE
		var/recordedCompId = FALSE
		var/recordedIp = FALSE
		for (var/datum/apiModel/Tracked/BanDetail/banDetail in ban.details)
			if (banDetail.ckey == ckey) recordedCkey = TRUE
			if (banDetail.comp_id == comp_id) recordedCompId = TRUE
			if (banDetail.ip == ip) recordedIp = TRUE

		// var/evasionAttempt = FALSE
		if (!recordedCkey || !recordedCompId || !recordedIp)
			// evasionAttempt = TRUE
			SPAWN(0)
				try
					// Add these details to the existing ban
					src.addDetails(ban.id, ckey, comp_id, ip)
				catch
					// pass

		// Build a message to show to the player
		var/message = "[ban.reason]<br>"
		message += "Banned By: [ban.game_admin["ckey"]]<br>"
		message += "This ban applies to [ban.server_id ? "this server only" : "all servers"].<br>"
		if (ban.expires_at)
			// TODO: get human readable duration remaining (date handling in byond urghh)
			message += "(This ban will be automatically removed at [ban.expires_at])"
		else
			if (ban.requires_appeal)
				message += "Please make an <a href='https://forum.ss13.co/forumdisplay.php?fid=54'>appeal on the forums</a> to have it lifted."
			else
				message += "This is a permanent ban, you can't appeal this ban until 30 days have passed."

		return message

	/// Update an existing ban
	proc/update(banId, admin_ckey, server_id, ckey, comp_id, ip, reason, duration, requires_appeal)
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
		message_admins("<span class='internal'>[key_name(adminClient ? adminClient : admin_ckey)] edited [target]'s ban. Reason: [ban.reason] Duration: [durationHuman] [serverLogSnippet]</span>")

		// Tell Discord
		var/ircmsg[] = new()
		ircmsg["key"] = adminClient ? adminClient.key : admin_ckey
		ircmsg["name"] = (adminClient && adminClient.mob && adminClient.mob.name ? stripTextMacros(adminClient.mob.name) : "N/A")
		ircmsg["msg"] = "edited [target]'s ban. Reason: [ban.reason]. Duration: [durationHuman]. [serverLogSnippet]."
		ircbot.export_async("admin", ircmsg)

	/// Remove a ban
	proc/remove(banId, admin_ckey, ckey, comp_id, ip)
		var/datum/apiRoute/bans/delete/deleteBan = new
		deleteBan.routeParams = list("[banId]")
		try
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
	proc/addDetails(banId, admin_ckey, ckey, comp_id, ip)
		var/datum/apiRoute/bans/add_detail/addDetail = new
		addDetail.routeParams = list("[banId]")
		addDetail.buildBody(ckey, comp_id, ip)
		var/datum/apiModel/Tracked/BanDetail/banDetail
		try
			banDetail = apiHandler.queryAPI(addDetail)
		catch (var/exception/e)
			var/datum/apiModel/Error/error = e.name
			throw EXCEPTION(error.message)

		var/client/adminClient = find_client(admin_ckey)
		var/target = "[banDetail.ckey] (IP: [banDetail.ip], CompID: [banDetail.comp_id])"

		// Tell admins
		var/msg = "added ban details to ban ID [banId] [target]"
		logTheThing(LOG_ADMIN, adminClient ? adminClient : admin_ckey, msg)
		logTheThing(LOG_DIARY, adminClient ? adminClient : admin_ckey, msg, "admin")
		message_admins("<span class='internal'>[key_name(adminClient ? adminClient : admin_ckey)] [msg]</span>")

		// Tell discord
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
