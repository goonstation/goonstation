/datum/db_manager_menu
	var/datum/computer/file/terminal_program/db_manager/parent = null
	var/accept_commands = TRUE

/datum/db_manager_menu/New(datum/computer/file/terminal_program/db_manager/parent)
	. = ..()
	src.parent = parent

/datum/db_manager_menu/proc/load()
	return

/datum/db_manager_menu/proc/unload()
	return

/datum/db_manager_menu/proc/input_text(text)
	return

/datum/db_manager_menu/proc/wait(time)
	src.accept_commands = FALSE
	sleep(time)
	src.accept_commands = TRUE

