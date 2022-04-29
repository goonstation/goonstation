/datum/spacebee_extension_command/pingall
	name = "pingall"
	server_targeting = COMMAND_TARGETING_ALL_SERVERS
	help_message = "All servers respond with pong."
	argument_types = list()
	execute(user)
		system.reply("pong", user)

/datum/spacebee_extension_command/ping
	name = "ping"
	server_targeting = COMMAND_TARGETING_SINGLE_SERVER
	help_message = "Target server responds with pong."
	argument_types = list()
	execute(user)
		system.reply("pong", user)

/datum/spacebee_extension_command/locate
	name = "locate"
	server_targeting = COMMAND_TARGETING_ALL_SERVERS
	help_message = "Locates a given ckey on all servers."
	argument_types = list(/datum/command_argument/string/ckey="ckey")
	execute(user, ckey)
		var/mob/M = ckey_to_mob(ckey, exact=FALSE)
		if(!M)
			return
		var/list/result = list()
		var/role = getRole(M, 1)
		if (M.name) result += M.name
		if (M.key) result += M.key
		if (isdead(M)) result += "DEAD"
		if (role) result += role
		if (checktraitor(M)) result += "\[T\]"
		system.reply(result.Join(" | "), user)

/datum/spacebee_extension_command/addnote
	name = "addnote"
	server_targeting = COMMAND_TARGETING_MAIN_SERVER
	help_message = "Adds a note to a given ckey."
	argument_types = list(/datum/command_argument/string/ckey="ckey", /datum/command_argument/the_rest="note")
	execute(user, ckey, note)
		addPlayerNote(ckey, user + " (Discord)", note)

		logTheThing("admin", "[user] (Discord)", null, "added a note for [ckey]: [note]")
		logTheThing("diary", "[user] (Discord)", null, "added a note for [ckey]: [note]", "admin")
		message_admins("<span class='internal'>[user] (Discord) added a note for [ckey]: [note]</span>")

		var/ircmsg[] = new()
		ircmsg["name"] = user
		ircmsg["msg"] = "Added a note for [ckey]: [note]"
		ircbot.export("admin", ircmsg)

/datum/spacebee_extension_command/addnotice
	name = "addnotice"
	server_targeting = COMMAND_TARGETING_MAIN_SERVER
	help_message = "Adds a login notice to a given ckey."
	argument_types = list(/datum/command_argument/string/ckey="ckey", /datum/command_argument/the_rest="notice")

	execute(user, ckey, notice)
		var/datum/player/player = make_player(ckey)
		player.cloud_fetch()
		if (player.cloud_get("login_notice"))
			system.reply("Error, [ckey] already has a login notice set.", user)
			return
		var/message = "Message from Admin [user] at [roundLog_date]:\n\n[notice]"
		if (!player.cloud_put("login_notice", message))
			system.reply("Error, issue saving login notice, try again later.", user)
			return
		// else it succeeded
		addPlayerNote(ckey, user + " (Discord)", "New login notice set:\n\n[notice]")
		logTheThing("admin", "[user] (Discord)", null, "added a login notice for [ckey]: [notice]")
		logTheThing("diary", "[user] (Discord)", null, "added a login notice for [ckey]: [notice]", "admin")
		message_admins("<span class='internal'>[user] (Discord) added a login notice for [ckey]: [notice]</span>")

		ircbot.export("admin", list(
		"name" = user,
		"msg" = "added an admin notice for [ckey]:\n[notice]"))

/datum/spacebee_extension_command/ban
	name = "ban"
	server_targeting = COMMAND_TARGETING_MAIN_SERVER
	help_message = "Bans a given ckey. Arguments in the order of ckey, length (number of minutes, or put \"hour\", \"day\", \"halfweek\", \"week\", \"twoweeks\", \"month\", \"perma\" or \"untilappeal\"), and ban reason. Make sure you specify the server that the person is on. Also keep in mind that this bans them from all servers. e.g. ban1 shelterfrog perma Lol rip."
	argument_types = list(/datum/command_argument/string/ckey="ckey", /datum/command_argument/string="length",
	/datum/command_argument/the_rest="reason")
	execute(user, ckey, length, reason)
		if (!(ckey && length && reason))
			system.reply("Insufficient arguments.", user)
			return
		var/data[] = new()
		data["ckey"] = ckey
		var/mob/M = ckey_to_mob(ckey)
		if (M)
			data["compID"] = M.computer_id
			data["ip"] = M.lastKnownIP
		else
			var/list/response
			try
				response = apiHandler.queryAPI("playerInfo/get", list("ckey" = data["ckey"]), forceResponse = 1)
			catch ()
				var/ircmsg[] = new()
				ircmsg["name"] = user
				ircmsg["msg"] = "Failed to query API, try again later."
				ircbot.export("admin", ircmsg)
				return
			data["ip"] = response["last_ip"]
			data["compID"] = response["last_compID"]
		data["text_ban_length"] = length
		data["reason"] = reason
		if (length == "hour")
			length = 60
		else if (length == "day")
			length = 1440
		else if (length == "halfweek")
			length = 5040
		else if (length == "week")
			length = 10080
		else if (length == "twoweeks")
			length = 20160
		else if (length == "month")
			length = 43200
		else if (length == "perma")
			length = 0
			data["text_ban_length"] = "Permanent"
		else if (ckey(length) == "untilappeal")
			length = -1
			data["text_ban_length"] = "Until Appeal"
		else
			length = text2num(length)
		if (!isnum(length))
			system.reply("Ban length invalid.", user)
			return
		data["mins"] = length
		data["akey"] = ckey(user) + " (Discord)"
		addBan(data) // logging, messaging, and noting are all taken care of by this proc

		var/ircmsg[] = new()
		ircmsg["name"] = user
		ircmsg["msg"] = "Banned [ckey] from all servers for [length] minutes, reason: [reason]"
		ircbot.export("admin", ircmsg)

/datum/spacebee_extension_command/serverban
	name = "serverban"
	server_targeting = COMMAND_TARGETING_MAIN_SERVER
	help_message = "Bans a given ckey from a specified server. Arguments in the order of ckey, server ID (for example: main1/1/goon1), length (number of minutes, or put \"hour\", \"day\", \"halfweek\", \"week\", \"twoweeks\", \"month\", \"perma\" or \"untilappeal\"), and ban reason, e.g. serverban shelterfrog goon1 perma Lol rip."
	argument_types = list(/datum/command_argument/string/ckey="ckey", /datum/command_argument/string/optional="server", /datum/command_argument/string="length",
	/datum/command_argument/the_rest="reason")
	execute(user, ckey, server, length, reason)
		if (!(ckey && server && length && reason))
			system.reply("Insufficient arguments.", user)
			return
		var/data[] = new()
		data["ckey"] = ckey
		var/mob/M = ckey_to_mob(ckey)
		if (M)
			data["compID"] = M.computer_id
			data["ip"] = M.lastKnownIP
		else
			var/list/response
			try
				response = apiHandler.queryAPI("playerInfo/get", list("ckey" = data["ckey"]), forceResponse = 1)
			catch ()
				var/ircmsg[] = new()
				ircmsg["name"] = user
				ircmsg["msg"] = "Failed to query API, try again later."
				ircbot.export("admin", ircmsg)
				return
			data["ip"] = response["last_ip"]
			data["compID"] = response["last_compID"]
		if(server == "main1" || server == "1" || server == "goon1")
			server = "main1"
		else if(server == "main2" || server == "2" || server == "goon2")
			server = "main2"
		else if(server == "main3" || server == "3" || server == "goon3")
			server = "main3"
		else if(server == "main4" || server == "4" || server == "goon4")
			server = "main4"
		else
			system.reply("Invalid server.", user)
			return
		data["server"] = server
		data["text_ban_length"] = length
		data["reason"] = reason
		if (length == "hour")
			length = 60
		else if (length == "day")
			length = 1440
		else if (length == "halfweek")
			length = 5040
		else if (length == "week")
			length = 10080
		else if (length == "twoweeks")
			length = 20160
		else if (length == "month")
			length = 43200
		else if (length == "perma")
			length = 0
			data["text_ban_length"] = "Permanent"
		else if (ckey(length) == "untilappeal")
			length = -1
			data["text_ban_length"] = "Until Appeal"
		else
			length = text2num(length)
		if (!isnum(length))
			system.reply("Ban length invalid.", user)
			return
		data["mins"] = length
		data["akey"] = ckey(user) + " (Discord)"
		addBan(data) // logging, messaging, and noting are all taken care of by this proc

		var/ircmsg[] = new()
		ircmsg["name"] = user
		ircmsg["msg"] = "Banned [ckey] from [server] for [length] minutes, reason: [reason]"
		ircbot.export("admin", ircmsg)

/datum/spacebee_extension_command/boot
	name = "boot"
	server_targeting = COMMAND_TARGETING_SINGLE_SERVER
	help_message = "Boot a given ckey off the specified server."
	argument_types = list(/datum/command_argument/string/ckey="ckey")

	execute(user, ckey)
		for(var/client/C)
			if (C.ckey == ckey)
				del(C)
				logTheThing("admin", "[user] (Discord)", null, "booted [constructTarget(C,"admin")].")
				logTheThing("diary", "[user] (Discord)", null, "booted [constructTarget(C,"diary")].", "admin")
				system.reply("Booted [ckey].", user)
				return
		system.reply("Could not locate [ckey].", user)

/datum/spacebee_extension_command/alert
	name = "alert"
	server_targeting = COMMAND_TARGETING_SINGLE_SERVER
	help_message = "Send an admin alert to a given ckey."
	argument_types = list(/datum/command_argument/string/ckey="ckey", /datum/command_argument/the_rest="message")

	execute(user, ckey, message)
		for(var/client/C)
			if (C.ckey == ckey)
				message_admins("[user] (Discord) displayed an alert to [ckey] with the message \"[message]\"")
				system.reply("Displayed an alert to [ckey].", user)
				logTheThing("admin", "[user] (Discord)", null, "displayed an alert to [constructTarget(C,"admin")] with the message \"[message]\"")
				logTheThing("diary", "[user] (Discord)", null, "displayed an alert to  [constructTarget(C,"diary")] with the message \"[message]\"", "admin")
				if (C?.mob)
					SPAWN(0)
						C.mob.playsound_local(C.mob, "sound/voice/animal/goose.ogg", 100, flags = SOUND_IGNORE_SPACE)
						if (alert(C.mob, message, "!! Admin Alert !!", "OK") == "OK")
							message_admins("[ckey] acknowledged the alert from [user] (Discord).")
							system.reply("[ckey] acknowledged the alert.", user)
				return
		system.reply("Could not locate [ckey].", user)

/datum/spacebee_extension_command/prison
	name = "prison"
	server_targeting = COMMAND_TARGETING_SINGLE_SERVER
	help_message = "Sends a given ckey to the prison zone."
	argument_types = list(/datum/command_argument/string/ckey="ckey")

	execute(user, ckey)
		for(var/client/C)
			if (C.ckey == ckey)
				var/mob/M = C.mob
				if (M && ismob(M) && !isAI(M) && !isobserver(M))
					var/prison = pick_landmark(LANDMARK_PRISONWARP)
					if (prison)
						M.changeStatus("paralysis", 8 SECONDS)
						M.set_loc(prison)
						M.show_text("<h2><font color=red><b>You have been sent to the penalty box, and an admin should contact you shortly. If nobody does within a minute or two, please inquire about it in adminhelp (F1 key).</b></font></h2>", "red")
						logTheThing("admin", "[user] (Discord)", null, "prisoned [constructTarget(C,"admin")].")
						logTheThing("diary", "[user] (Discord)", null, "prisoned [constructTarget(C,"diary")].", "admin")
						system.reply("Prisoned [ckey].", user)
						return
					system.reply("Could not locate prison zone.", user)
					return
				system.reply("[ckey] was of mob type [M.type] and could not be prisoned.", user)
				return
		system.reply("Could not locate [ckey].", user)

/datum/spacebee_extension_command/where_is
	name = "whereis"
	server_targeting = COMMAND_TARGETING_SINGLE_SERVER
	help_message = "Get where a given ckey is currently located ingame."
	argument_types = list(/datum/command_argument/string/ckey="ckey")

	execute(user, ckey)
		var/mob/M = ckey_to_mob(ckey)
		if (!M)
			system.reply("Could not locate [ckey].", user)
			return
		var/area/A = get_area(M)
		system.reply("[ckey] ([M]) is at [A.x], [A.y], [A.z] in [A].", user)

/datum/spacebee_extension_command/announce
	name = "announce"
	server_targeting = COMMAND_TARGETING_SINGLE_SERVER
	help_message = "Creates a command report on a given server."
	argument_types = list(/datum/command_argument/string="headline", /datum/command_argument/the_rest="body")
	execute(user, headline, body)
		for_by_tcl(C, /obj/machinery/communications_dish)
			C.add_centcom_report(ALERT_GENERAL, body)
		body = discord_emojify(body)
		headline = discord_emojify(headline)
		command_alert(body, headline, "sound/misc/announcement_1.ogg")
		logTheThing("admin", "[user] (Discord)", null, "has created a command report: [body]")
		logTheThing("diary", "[user] (Discord)", null, "has created a command report: [body]", "admin")
		message_admins("[user] (Discord) has created a command report")
		system.reply("Command report created.", user)
		global.cooldowns["transmit_centcom"] = 0 // reset cooldown for reply

/datum/spacebee_extension_command/mode
	name = "mode"
	server_targeting = COMMAND_TARGETING_SINGLE_SERVER
	help_message = "Check the gamemode of a server or set it by providing an argument (\"secret\", \"intrigue\", \"extended\")."
	argument_types = list(/datum/command_argument/string/optional="new_mode")

	execute(user, new_mode)
		if(new_mode in global.valid_modes)
			var/which = "next round's "
			if (current_state <= GAME_STATE_PREGAME)
				master_mode = new_mode
				which = ""
			world.save_mode(new_mode)
			logTheThing("admin", "[user] (Discord)", null, "set the [which]mode as [new_mode]")
			logTheThing("diary", "[user] (Discord)", null, "set the [which]mode as [new_mode]", "admin")
			message_admins("[user] (Discord) set the [which]mode as [new_mode].")
			system.reply("Set the [which]mode to [new_mode].", user)
		else if(length(new_mode) > 0)
			system.reply("Invalid mode [new_mode]. Available game modes: [jointext(global.valid_modes, ", ")].", user)
		else
			var/detail_mode = isnull(ticker?.mode) ? "not started yet" : ticker.mode.name
			var/next_mode = "N/A"
			var/next_mode_text = file2text("data/mode.txt")
			if(next_mode_text)
				var/list/lines = splittext(next_mode_text, "\n")
				if (lines[1])
					next_mode = lines[1]
			system.reply("Current mode is [master_mode] ([detail_mode]) ([ticker.hide_mode ? "hidden" : "not hidden"]). Next mode is [next_mode].", user)

/datum/spacebee_extension_command/help
	name = "help"
	server_targeting = COMMAND_TARGETING_MAIN_SERVER
	help_message = "Shows a helpful help message."
	argument_types = list(/datum/command_argument/string/optional="command")

	proc/help_for_command(datum/spacebee_extension_command/command)
		. = list()
		. += command.name + (command.server_targeting == COMMAND_TARGETING_SINGLE_SERVER ? "#" : "")
		for(var/datum/command_argument/arg in command.argument_instances)
			var/name = command.argument_instances[arg]
			. += arg.format_help(name)
		. = jointext(., " ")
		if(command.help_message)
			. += "\n\t[command.help_message]"

	execute(user, maybe_command)
		if(maybe_command)
			var/datum/spacebee_extension_command/command = system.commands[maybe_command]
			if(!command)
				system.reply("Unknown command.", user)
				return
			system.reply(src.help_for_command(command), user)
		else
			var/list/message = list()
			message += "You can put text arguments in quotes if you want spaces in them!"
			message += "# means you need to add a server id.\n"
			for(var/command_name in system.commands)
				var/datum/spacebee_extension_command/command = system.commands[command_name]
				message += src.help_for_command(command)
			// cancel isn't actually a proper command so we hackily insert it here, rip
			message += "cancel\n\tCancels an in-progress multi-part command."
			system.reply(message.Join("\n"), user)

/datum/spacebee_extension_command/state_based/confirmation/mob_targeting/gib
	name = "gib"
	help_message = "Gibs a given ckey on a server."
	action_name = "gib"

	perform_action(user, mob/target)
		logTheThing("admin", "[user] (Discord)", target, "gibbed [constructTarget(target,"admin")]")
		logTheThing("diary", "[user] (Discord)", target, "gibbed [constructTarget(target,"diary")].", "admin")
		message_admins("[user] (Discord) gibbed [key_name(target)].")
		target.transforming = 1
		target.gib()
		return TRUE

/datum/spacebee_extension_command/state_based/confirmation/mob_targeting/delimb
	name = "delimb"
	help_message = "Delimbs a given ckey on a server."
	action_name = "delimb"

	perform_action(user, mob/target)
		if(!ishuman(target))
			system.reply("Error, target is not human.", user)
			return FALSE
		var/mob/living/carbon/human/H = target
		H.limbs.sever("all")
		logTheThing("admin", "[user] (Discord)", target, "delimbed [constructTarget(target,"admin")]")
		logTheThing("diary", "[user] (Discord)", target, "delimbed [constructTarget(target,"diary")].", "admin")
		message_admins("[user] (Discord) delimbed [key_name(target)].")
		return TRUE

/datum/spacebee_extension_command/state_based/confirmation/mob_targeting/send_to_arrivals
	name = "sendtoarrivals"
	help_message = "Sends a given ckey to arrivals."
	action_name = "send to arrivals"

	perform_action(user, mob/target)
		logTheThing("admin", "[user] (Discord)", target, "sent [constructTarget(target,"admin")] to arrivals")
		logTheThing("diary", "[user] (Discord)", target, "sent [constructTarget(target,"diary")] to arrivals.", "admin")
		message_admins("[user] (Discord) sent [key_name(target)] to arrivals.")
		target.set_loc(pick_landmark(LANDMARK_LATEJOIN, locate(150, 150, 1)))
		return TRUE

/datum/spacebee_extension_command/state_based/confirmation/mob_targeting/respawn
	name = "respawn"
	help_message = "Respawns a given ckey."
	action_name = "respawn"

	perform_action(user, mob/target)
		logTheThing("admin", "[user] (Discord)", target, "respawned [constructTarget(target,"admin")]")
		logTheThing("diary", "[user] (Discord)", target, "respawned [constructTarget(target,"diary")].", "admin")
		message_admins("[user] (Discord) respawned [key_name(target)].")

		var/mob/new_player/newM = new()
		newM.adminspawned = 1

		newM.key = target.key
		if (target.mind)
			target.mind.damned = 0
			target.mind.transfer_to(newM)
		newM.Login()
		newM.sight = SEE_TURFS //otherwise the HUD remains in the login screen
		qdel(target)

		boutput(newM, "<b>You have been respawned.</b>")
		return TRUE


/datum/spacebee_extension_command/state_based/confirmation/mob_targeting/heal
	name = "heal"
	help_message = "Heal / revive a given ckey."
	action_name = "heal"

	perform_action(user, mob/target)
		if(!config.allow_admin_rev)
			system.reply("Healing disabled.", "user")
			return FALSE
		if(isobserver(target))
			var/mob/dead/observer/observer = target
			target = observer.corpse
			observer.reenter_corpse()
		if(!target)
			system.reply("Valid mob not found.", "user")
			return FALSE
		target.revive()
		message_admins("<span class='alert'>Admin [user] (Discord) healed / revived [key_name(target)]!</span>")
		logTheThing("admin", "[user] (Discord)", target, "healed / revived [constructTarget(target,"admin")]")
		logTheThing("diary", "[user] (Discord)", target, "healed / revived [constructTarget(target,"diary")]", "admin")
		return TRUE

/datum/spacebee_extension_command/state_based/confirmation/mob_targeting/heal/revive
	name = "revive"
	help_message = "Heal / revive a given ckey. (alias of ;;heal)"
	action_name = "revive"

/datum/spacebee_extension_command/all_admins
	name = "adminsall"
	server_targeting = COMMAND_TARGETING_ALL_SERVERS
	help_message = "All servers respond with their list of admins (probably)."
	argument_types = list()
	execute(user)
		var/list/admins = list()
		for(var/client/C in clients)
			if(!C.holder)
				continue
			if (C.stealth || C.alt_key)
				admins += "[C.key] (as [C.fakekey])"
			else
				admins += C.key
		if(length(admins))
			system.reply(admins.Join(", "), user)

/datum/spacebee_extension_command/context
	name = "context"
	server_targeting = COMMAND_TARGETING_SINGLE_SERVER
	help_message = "Gets last N log entries of a given ckey."
	argument_types = list(/datum/command_argument/string/ckey="ckey", /datum/command_argument/string="log_name", /datum/command_argument/number/integer="N")
	execute(user, ckey, log_name, n)
		if(log_name == "audit")
			system.reply("No peeking in the audit log.", user)
			return
		if(!(log_name in logs))
			system.reply("Invalid log name. Valid log names: [logs.Join(" ")]")
			return
		var/list/log = logs[log_name]
		var/list/result = list()
		for(var/i=length(log); i >= 1 && n > 0; i--)
			var/log_line = log[i]
			if(findtext(log_line, ckey, 1, null))
				result += strip_html_tags(log_line)
				n--
		if(!length(result))
			system.reply("No results.", user)
		else
			system.reply(reverse_list(result).Join("\n"), user)

/datum/spacebee_extension_command/crate
	name = "crate"
	server_targeting = COMMAND_TARGETING_SINGLE_SERVER
	help_message = "Sends items in a crate to cargo. Separate typepaths by spaces."
	argument_types = list(/datum/command_argument/the_rest="types")
	execute(user, types)
		var/obj/to_send = new /obj/storage/crate/wooden
		var/list/type_str_list = splittext(types, " ")
		for(var/type_str in type_str_list)
			var/type = text2path(type_str)
			if(isnull(type))
				system.reply("Unknown type [type_str], aborting.", user)
				qdel(to_send)
				return
			new type(to_send)
		shippingmarket.receive_crate(to_send)
		system.reply("Crate sent.")

/datum/spacebee_extension_command/logs
	name = "logs"
	server_targeting = COMMAND_TARGETING_SINGLE_SERVER
	help_message = "Returns a link to the weblog of requested server. You really are lazy."
	execute(user)
		var/ircmsg[] = new()
		ircmsg["key"] = "Loggo"
		ircmsg["name"] = "Lazy Admin Logs"
		// ircmsg["msg"] = "Logs for this round can be found here: https://mini.xkeeper.net/ss13/admin/log-get.php?id=[config.server_id]&date=[roundLog_date]"
		ircmsg["msg"] = "Logs for this round can be found here: https://mini.xkeeper.net/ss13/admin/log-viewer.php?server=[config.server_id]&redownload=1&view=[roundLog_date].html"
		ircbot.export("help", ircmsg)

/datum/spacebee_extension_command/state_based/confirmation/mob_targeting/rename
	name = "rename"
	help_message = "Rename a given ckey's mob."
	action_name = "rename"
	argument_types = list(/datum/command_argument/string="ckey", /datum/command_argument/the_rest="new_name")
	var/new_name = null

	prepare(user, ckey, new_name)
		. = ..()
		src.new_name = new_name

	perform_action(user, mob/target)
		if(isnull(src.new_name))
			return FALSE
		message_admins("<span class='alert'>Admin [user] (Discord) renamed [key_name(target)] to [src.new_name]!</span>")
		logTheThing("admin", "[user] (Discord)", target, "renamed [constructTarget(target,"admin")] to [src.new_name]!")
		logTheThing("diary", "[user] (Discord)", target, "renamed [constructTarget(target,"diary")] to [src.new_name]!", "admin")
		target.real_name = src.new_name
		target.name = src.new_name
		target.choose_name(1, null, target.real_name, force_instead=TRUE)
		return TRUE


/datum/spacebee_extension_command/vpn_whitelist
	name = "vpnwhitelist"
	help_message = "Whitelists a given ckey from the VPN checker."
	argument_types = list(/datum/command_argument/string/ckey="ckey")
	server_targeting = COMMAND_TARGETING_SINGLE_SERVER

	execute(user, ckey)
		try
			apiHandler.queryAPI("vpncheck-whitelist/add", list("ckey" = ckey, "akey" = user + " (Discord)"))
		catch(var/exception/e)
			system.reply("Error while adding ckey [ckey] to the VPN whitelist: [e.name]")
			return FALSE
		global.vpn_ip_checks?.Cut() // to allow them to reconnect this round
		message_admins("Ckey [ckey] added to the VPN whitelist by [user] (Discord).")
		logTheThing("admin", "[user] (Discord)", null, "Ckey [ckey] added to the VPN whitelist.")
		system.reply("[ckey] added to the VPN whitelist.")
		return TRUE

/datum/spacebee_extension_command/hard_reboot
	name = "hardreboot"
	help_message = "Toggle a hard server reboot"
	argument_types = list()
	server_targeting = COMMAND_TARGETING_SINGLE_SERVER

	execute(user)
		var/logMessage = ""
		if (fexists(hardRebootFilePath))
			fdel(hardRebootFilePath)
			logMessage = "removed a server hard reboot"
		else
			file(hardRebootFilePath) << ""
			logMessage = "queued a server hard reboot"

		logTheThing("debug", "[user] (Discord)", null, logMessage)
		logTheThing("diary", "[user] (Discord)", null, logMessage, "admin")
		message_admins("[user] (Discord) [logMessage]")
		system.reply(logMessage)


/datum/spacebee_extension_command/state_based/confirmation/renamestation
	name = "renamestation"
	help_message = "Rename the station."
	argument_types = list(/datum/command_argument/the_rest="new_name")
	server_targeting = COMMAND_TARGETING_SINGLE_SERVER
	var/new_name = null

	prepare(user, new_name)
		src.new_name = new_name
		return "You are about to rename the station to `[new_name]`."

	do_it(user)
		if(isnull(src.new_name))
			return
		set_station_name(user, new_name, admin_override=TRUE)
		message_admins("<span class='alert'>Admin [user] (Discord) renamed station to [src.new_name]!</span>")
		logTheThing("admin", "[user] (Discord)", null, "renamed station to [src.new_name]!")
		logTheThing("diary", "[user] (Discord)", null, "renamed station to [src.new_name]!", "admin")
		var/success_msg = "Station renamed to [src.new_name]."
		system.reply(success_msg)
