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
	argument_types = list(/datum/command_argument/string="ckey")
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
	argument_types = list(/datum/command_argument/string="ckey", /datum/command_argument/the_rest="note")
	execute(user, ckey, note)
		addPlayerNote(ckey, user + " (Discord)", note)

/datum/spacebee_extension_command/announcement
	name = "announcement"
	server_targeting = COMMAND_TARGETING_SINGLE_SERVER
	help_message = "Creates a command report on a given server."
	argument_types = list(/datum/command_argument/string="headline", /datum/command_argument/the_rest="body")
	execute(user, headline, body)
		for (var/obj/machinery/communications_dish/C in by_type[/obj/machinery/communications_dish])
			C.add_centcom_report("[command_name()] Update", body)
		command_alert(body, headline, "sound/misc/announcement_1.ogg")
		logTheThing("admin", "[user] (Discord)", null, "has created a command report: [body]")
		logTheThing("diary", "[user] (Discord)", null, "has created a command report: [body]", "admin")
		message_admins("[user] (Discord) has created a command report")
		system.reply("Command report created.", user)

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

/datum/spacebee_extension_command/state_based/confirmation/gib
	name = "gib"
	server_targeting = COMMAND_TARGETING_SINGLE_SERVER
	help_message = "Gibs a given ckey on a server."
	argument_types = list(/datum/command_argument/string="ckey")

	var/ckey
	prepare(user, ckey)
		src.ckey = ckey
		var/mob/M = whois_ckey_to_mob_reference(ckey)
		if(!M)
			system.reply("Ckey not found.", user)
			return null
		return "You are about to gib [M] ([ckey])[isdead(M) ? " DEAD" : ""][checktraitor(M) ? " \[T\]" : ""]."

	do_it(user)
		var/mob/M = whois_ckey_to_mob_reference(ckey)
		system.reply("Gibbing [M] ([ckey])[isdead(M) ? " DEAD" : ""][checktraitor(M) ? " \[T\]" : ""].", user)
		M.transforming = 1
		M.gib()
