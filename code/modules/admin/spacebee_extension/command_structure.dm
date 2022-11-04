ABSTRACT_TYPE(/datum/spacebee_extension_command)
/// A command for the Spacebee extension thing
/datum/spacebee_extension_command
	/// how the command is actually called
	var/name
	/// help message shown in the ;;help command
	var/help_message
	/// a list of subtypes of /datum/command_argument of the form list(type = name), name used only for help messages
	var/list/argument_types
	/// how is the server processing this command chosen, see COMMAND_TARGETING_ defines
	var/server_targeting
	/// if TRUE a new copy is created for each call of the command, useful for /datum/spacebee_extension_command/state_based
	var/instantiated = FALSE

	/// instantiated arguments (singletons of the types)
	var/list/datum/command_argument/argument_instances
	/// the spacebee extension system this command is bound to
	var/datum/spacebee_extension_system/system

/datum/spacebee_extension_command/New(datum/spacebee_extension_system/system)
	SHOULD_CALL_PARENT(TRUE)
	. = ..()
	src.system = system
	src.argument_instances = list()
	for(var/arg_type in src.argument_types)
		src.argument_instances[get_singleton(arg_type)] = src.argument_types[arg_type]

/// the actual command code
/datum/spacebee_extension_command/proc/execute(user, ...)



ABSTRACT_TYPE(/datum/spacebee_extension_command/state_based)
/**
	For commands with multiple states (several stages of entering inputs, confirmation dialogs etc.).
	Define a proc for each state and use `go_to_state(new_state)` to go to that state. When the
	user inputs their next command instead of being processed by the Spacebee extension system it will
	get processed by said state of this command.
*/
/datum/spacebee_extension_command/state_based
	instantiated = TRUE
	var/user
	var/state

/datum/spacebee_extension_command/state_based/execute(user, ...)
	SHOULD_CALL_PARENT(TRUE)
	src.user = user
	. = ..()

/datum/spacebee_extension_command/state_based/proc/go_to_state(new_state)
	if(!istext(new_state))
		state = null
		return
	state = new_state
	system.register_callback(src.user, "callback", src)

/datum/spacebee_extension_command/state_based/proc/callback(user, msg)
	if(!src.state)
		CRASH("Invalid command state in callback.")
	return call(src, src.state)(user, msg)



ABSTRACT_TYPE(/datum/spacebee_extension_command/state_based/confirmation)
/**
	For dangerous commands that the user should really doublecheck. Override
	prepare to check the validity of the vars and return a message (or null to cancel).
	User will need to reply with ;;yes to continue at which point do_it gets called.
*/
/datum/spacebee_extension_command/state_based/confirmation

/datum/spacebee_extension_command/state_based/confirmation/execute(user, ...)
	. = ..()
	var/warning_msg = src.prepare(arglist(args))
	if(!warning_msg)
		return
	system.reply("[warning_msg]\nType in \';;yes\' to continue.")
	src.go_to_state("confirm")

/datum/spacebee_extension_command/state_based/confirmation/proc/prepare(user, ...)

/datum/spacebee_extension_command/state_based/confirmation/proc/do_it(user)

/datum/spacebee_extension_command/state_based/confirmation/proc/confirm(user, msg)
	if(msg == "yes")
		src.do_it(user)
	else
		system.reply("Command cancelled.", user)

// TODO document the rest
// short version: some additional stuff to make commands that operate just with a target mob easier to write

ABSTRACT_TYPE(/datum/spacebee_extension_command/state_based/confirmation/mob_targeting)
/datum/spacebee_extension_command/state_based/confirmation/mob_targeting
	server_targeting = COMMAND_TARGETING_SINGLE_SERVER
	argument_types = list(/datum/command_argument/string="ckey")
	var/action_name
	var/ckey

/datum/spacebee_extension_command/state_based/confirmation/mob_targeting/prepare(user, ckey)
	src.ckey = ckey
	var/mob/M = ckey_to_mob(ckey, 0)
	if(!M)
		system.reply("Ckey not found.", user)
		return null
	src.ckey = M.ckey // make sure we can do exact match in do_it(), partial matches could get fucked up by newjoiners etc
	return "You are about to [src.action_name] [M] ([M.ckey])[isdead(M) ? " DEAD" : ""][checktraitor(M) ? " \[T\]" : ""]."

/datum/spacebee_extension_command/state_based/confirmation/mob_targeting/do_it(user)
	var/mob/M = ckey_to_mob(ckey)
	if(!M)
		system.reply("Ckey [ckey] disappeared in the meantime, huh.", user)
		return
	var/success_msg = "Done: [src.action_name] [M] ([M.ckey])[isdead(M) ? " DEAD" : ""][checktraitor(M) ? " \[T\]" : ""]."
	if(src.perform_action(user, M))
		system.reply(success_msg, user)

/datum/spacebee_extension_command/state_based/confirmation/mob_targeting/proc/perform_action(user, mob/target)
