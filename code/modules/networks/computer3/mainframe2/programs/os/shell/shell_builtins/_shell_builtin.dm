ABSTRACT_TYPE(/datum/dwaine_shell_builtin)
/**
 *	DWAINE shell builtin datums are partial abstractions of the DWAINE shell that represent commands that are built into the
 *	shell itself, instead of being external programs.
 */
/datum/dwaine_shell_builtin
	/// The name or names of this shell builtin.
	var/name = null
	/// The DWAINE shell that this shell builtin datum belongs to.
	var/datum/computer/file/mainframe_program/shell/shell = null

/datum/dwaine_shell_builtin/New(datum/computer/file/mainframe_program/shell/shell)
	. = ..()
	src.shell = shell

/datum/dwaine_shell_builtin/disposing()
	src.shell = null
	. = ..()

/// Execute this shell builtin.
/datum/dwaine_shell_builtin/proc/execute(list/command_list, list/piped_list)
	return BUILTIN_SUCCESS
