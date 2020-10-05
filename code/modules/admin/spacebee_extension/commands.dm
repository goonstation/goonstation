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
		var/mob/M = whois_ckey_to_mob_reference(ckey, exact=FALSE)
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

/datum/spacebee_extension_command/announce
	name = "announce"
	server_targeting = COMMAND_TARGETING_SINGLE_SERVER
	help_message = "Creates a command report on a given server."
	argument_types = list(/datum/command_argument/string="headline", /datum/command_argument/the_rest="body")
	execute(user, headline, body)
		for (var/obj/machinery/communications_dish/C in by_type[/obj/machinery/communications_dish])
			C.add_centcom_report("[command_name()] Update", body)
		body = discord_emojify(body)
		headline = discord_emojify(headline)
		command_alert(body, headline, "sound/misc/announcement_1.ogg")
		logTheThing("admin", "[user] (Discord)", null, "has created a command report: [body]")
		logTheThing("diary", "[user] (Discord)", null, "has created a command report: [body]", "admin")
		message_admins("[user] (Discord) has created a command report")
		system.reply("Command report created.", user)
		global.cooldowns["transmit_centcom"] = 0 // reset cooldown for reply

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
		var/obj/to_send = new /obj/storage/crate/packing
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
