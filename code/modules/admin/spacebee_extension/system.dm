/*
	Welcome to the Highly Illegal Spacebee Subsystem (HISS).
	It basically adds Discord commands prefixed by ;; (it abuses asay to do this, ew).
*/

// we use a bit of a magic of storing the Discord username in `usr`, probably a bad idea but who cares!
#define ENSURE_USER if(!user) user = usr
//the range of server keys that refer to the main "live" servers
#define LIVE_SERVER_MIN 1
#define LIVE_SERVER_MAX 4

var/global/datum/spacebee_extension_system/spacebee_extension_system = new

/// the main thing that processes and runs the commands
/datum/spacebee_extension_system
	/// the list of all available commands indexed by their name
	var/list/datum/spacebee_extension_command/commands
	/// a list of the form list(username = proc) or list(username = list(object, proc)), if an username has a callback assigned it's used instead of the basic command processing
	var/list/active_callbacks
	var/static/regex/command_head_regex = new(@{"^([a-zA-Z_-]*)([0-9]*)$"})
	var/static/regex/whitespace_regex = new(@{"[\s\n]+"})


/datum/spacebee_extension_system/New()
	. = ..()
	src.commands = list()
	src.active_callbacks = list()
	for(var/command_type in concrete_typesof(/datum/spacebee_extension_command, FALSE))
		var/datum/spacebee_extension_command/command = new command_type(src)
		src.commands[command.name] = command

/// called from world.dm from asay processing
/datum/spacebee_extension_system/proc/process_asay(msg, user)
	if(copytext(msg, 1, 2) != SPACEBEE_EXTENSION_ASAY_PREFIX)
		return
	usr = user // big brain idea or very stupid? you decide
	logTheThing(LOG_ADMIN, user, "Spacebee command: [msg]")
	return src.process_raw_command(copytext(msg, 2), user)

/// paginates a message in a way that fits into Discord messages
/datum/spacebee_extension_system/proc/paginated_send(message)
	var/msg_length = 1900 // 2000 - some reserve for the initial spacebee stuff
	if(length(message) < msg_length)
		return ircbot.export("admin", list("msg" = message))
	var/list/lines = splittext(message, "\n")
	var/list/current_message = list()
	var/current_length = 0
	for(var/line in lines)
		if(length(line) + 1 + current_length >= msg_length)
			. = ircbot.export("admin", list("msg" = jointext(current_message, "\n")))
			if(!. || .["status"] == "error")
				return
			current_message.Cut()
			current_length = 0
		current_message += line
		current_length += 1 + length(line)
	if(length(current_message))
		return ircbot.export("admin", list("msg" = jointext(current_message, "\n")))

/// replies to a given user on Discord
/datum/spacebee_extension_system/proc/reply(msg, user)
	ENSURE_USER
	logTheThing(LOG_ADMIN, user, "Spacebee command reply: [msg]")
	if(config.env == "dev")
		message_admins("Spacebee command reply to [user]: [replacetext(msg, "\n", "<br>")]")
		return 1
	return paginated_send(msg)

/// processes and runs a string that's supposed to be a command (with arguments and such)
/datum/spacebee_extension_system/proc/process_raw_command(msg, user)
	ENSURE_USER
	if(msg == "cancel") // hack to cancel possible callbacks
		if(user in src.active_callbacks)
			src.active_callbacks -= user
			src.reply("Current command cancelled.", user)
		return

	// callbacks override base command processing if they exist
	if(user in src.active_callbacks)
		var/callback = src.active_callbacks[user]
		src.active_callbacks -= user
		if(islist(callback))
			call(callback[1], callback[2])(user, msg)
		else
			call(callback)(msg, user)
		return

	// get the command name and server key
	var/list/command_tokens = src.parse_command_head(msg)
	if(isnull(command_tokens))
		return null
	var/command_name = command_tokens[1]
	var/server_key = command_tokens[2]
	var/arg_string = command_tokens[3]

	// get the command itself
	var/datum/spacebee_extension_command/command = src.commands[command_name]
	if(!command)
		return

	// check if we're on the right server
	switch(command.server_targeting)
		if(COMMAND_TARGETING_SINGLE_SERVER)
			if(global.serverKey != server_key)
				return
		if(COMMAND_TARGETING_MAIN_SERVER)
			if(!server_key && global.config.server_id != SPACEBEE_EXTENSION_MAIN_SERVER)
				return
			else if(server_key && global.serverKey != server_key) // allow server override
				return
		if(COMMAND_TARGETING_ALL_SERVERS)
			if(server_key)
				return
		if (COMMAND_TARGETING_LIVE_SERVERS)
			if (global.serverKey < LIVE_SERVER_MIN || global.serverKey > LIVE_SERVER_MAX)
				return
		else
			CRASH("Invalid server targeting [command.server_targeting] on command [command.name].")

	// parse arguments
	var/list/arguments = src.parse_arguments(arg_string, command.argument_instances)
	if(isnull(arguments))
		var/datum/spacebee_extension_command/help/help_command = src.commands["help"]
		src.reply("Invalid arguments.\n" + help_command?.help_for_command(command), user)
		return

	// create a new instance for multi-stage commands and such
	if(command.instantiated)
		command = new command.type(src)

	// execute the damn thing finally
	command.execute(arglist(list(user) + arguments))

/// parses the name and the server key of the command (if any), returns list(name, server_key, the_rest)
/datum/spacebee_extension_system/proc/parse_command_head(msg)
	var/whitespace_index = whitespace_regex.Find(msg)
	var/command_part = msg
	if(whitespace_index)
		command_part = copytext(msg, 1, whitespace_index)
	var/rest = ""
	if(whitespace_index)
		rest = copytext(msg, whitespace_index + length(whitespace_regex.match))
	if(!command_head_regex.Find(command_part))
		return null
	var/command = command_head_regex.group[1]
	var/server_key = text2num(command_head_regex.group[2])
	return list(command, server_key, rest)

/// parses arguments or returns null if unable
/datum/spacebee_extension_system/proc/parse_arguments(arg_string, list/datum/command_argument/arg_templates)
	. = list()
	var/pos = 1
	for(var/datum/command_argument/arg in arg_templates)
		if(pos != 1) // not first => eat whitespace
			src.whitespace_regex.Find(arg_string, pos)
			pos += length(src.whitespace_regex.match)
		var/index = arg.regex.Find(arg_string, pos)
		if(index != pos)
			return null
		var/processed = arg.process_match()
		if(isnull(processed))
			return null
		. += processed
		pos += length(arg.regex.match)

/// registers a callback for a given user (it overrides default command processing)
/datum/spacebee_extension_system/proc/register_callback(user=null, callback_proc, callback_datum=null)
	ENSURE_USER
	if(callback_datum)
		src.active_callbacks[user] = list(callback_datum, callback_proc)
	else
		src.active_callbacks[user] = callback_proc

#undef LIVE_SERVER_MIN
#undef LIVE_SERVER_MAX
