/datum/db_manager_menu
	/// The database manager program that this menu belongs to.
	var/datum/computer/file/terminal_program/db_manager/parent = null
	/// Whether this menu is currently accepting commands.
	var/accept_commands = TRUE

/datum/db_manager_menu/New(datum/computer/file/terminal_program/db_manager/parent)
	. = ..()
	src.parent = parent

/// Load this menu, displaying its contents to the user.
/datum/db_manager_menu/proc/load()
	return

/// Unload this menu. Used to clear variables.
/datum/db_manager_menu/proc/unload()
	return

/// Handle a text input from a user.
/datum/db_manager_menu/proc/input_text(text)
	return

/// Pause execution for a specified duration, during which the user cannot issue any further commands.
/datum/db_manager_menu/proc/wait(time)
	SHOULD_NOT_OVERRIDE(TRUE)
	src.accept_commands = FALSE
	sleep(time)
	src.accept_commands = TRUE
