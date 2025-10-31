/* Current Commands:

	NAME		OPTS			DESC
	cat							Concatenate computer files.
	cd							Change directory.
	chmod						Change file permissions.
	chown						Change file owner/group (Sysop only).
	cp							Copy files.
	date		ht:				Get the current round time, with optional formatting.
	getopt						Pre-1986 POSIX `getopt`; rearranges options and parameters for easier processing.
	grep		hiors			Regex plaintext search.
	ln							Link directories using a symlink.
	ls			l				List the contents of a directory.
	mkdir		p				Create directories.
	mount						Mount eligible device drivers (Sysop only).
	mv							Move files.
	pwd							Print working directory.
	rm			fir				Remove files.
	scnt						Rescan device drivers (Sysop only).
	su							Ascend to sysop status.
	tar			cf:klqtvx		Archiving utility, used to create compressed archive files.

*/


/**
 *	Utilities are commands used for various purposes such as system operation and maintenance, search queries, date formatting,
 *	and so forth.
 */
/datum/computer/file/mainframe_program/utility
	size = 1





/// Parse the output of `getopt` into a list of options with their parameters, and command parameters.
/proc/optparse(data)
	var/list/string_list = global.bash_explode(data)
	var/list/options = list()
	var/list/unaffected = list()
	var/previous_option = null

	for (var/i in 1 to length(string_list))
		var/string = string_list[i]
		if (string == "--")
			unaffected = string_list.Copy(i + 1)
			break

		if (dd_hasprefix(string, "-"))
			if (length(string) != 2)
				return

			if (previous_option)
				options[previous_option] = 1

			previous_option = string[2]

		else
			if (!previous_option)
				return

			options[previous_option] = string
			previous_option = null

	if (previous_option)
		options[previous_option] = 1

	return list(options, unaffected)
