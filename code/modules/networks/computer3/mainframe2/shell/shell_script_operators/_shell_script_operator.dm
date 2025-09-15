ABSTRACT_TYPE(/datum/dwaine_shell_script_operator)
/**
 *	DWAINE shell script operators are operator lexical tokens that may be used in shell scripts. Operators that take operands
 *	follow Reverse Polish Notation, where the operands precede their operator. Several operators are inspired by operators from
 *	the Forth programming language.
 */
/datum/dwaine_shell_script_operator
	/// The name or names of this shell script operator.
	var/name = null
	/// The DWAINE shell that this shell script operator datum belongs to.
	var/datum/computer/file/mainframe_program/shell/shell = null

/datum/dwaine_shell_script_operator/New(datum/computer/file/mainframe_program/shell/shell)
	. = ..()
	src.shell = shell

/datum/dwaine_shell_script_operator/disposing()
	src.shell = null
	. = ..()

/// Execute this shell script operator.
/datum/dwaine_shell_script_operator/proc/execute(list/token_stream)
	return SCRIPT_SUCCESS
