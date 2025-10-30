ABSTRACT_TYPE(/datum/dwaine_syscall)
/**
 *	DWAINE syscall datums are partial abstractions of the DWAINE kernel that allow programs to request a specific service of
 *	the kernel.
 */
/datum/dwaine_syscall
	/// The ID integer of this syscall.
	var/id = null
	/// The DWAINE kernel that this syscall datum belongs to.
	var/datum/computer/file/mainframe_program/os/kernel/kernel = null

/datum/dwaine_syscall/New(datum/computer/file/mainframe_program/os/kernel/kernel)
	. = ..()
	src.kernel = kernel

/datum/dwaine_syscall/disposing()
	src.kernel = null
	. = ..()

/// Execute this system call.
/datum/dwaine_syscall/proc/execute(sendid, list/data, datum/computer/file/file)
	return ESIG_SUCCESS
