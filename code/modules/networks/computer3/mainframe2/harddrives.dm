/obj/item/disk/data/fixed_disk
	name = "Storage Drive"
	icon_state = "harddisk"
	title = "Storage Drive"
	file_amount = 80

//A fixed disk with some structure already set up for the main os I guess
/obj/item/disk/data/fixed_disk/computer3
	New()
		. = ..()
		//First off, create the directory for logging stuff
		var/datum/computer/folder/newfolder = new /datum/computer/folder(  )
		newfolder.name = "logs"
		src.root.add_file( newfolder )
		newfolder.add_file( new /datum/computer/file/record/c3help(src))
		//This is the bin folder. For various programs I guess sure why not.
		newfolder = new /datum/computer/folder
		newfolder.name = "bin"
		src.root.add_file( newfolder )
		//newfolder.add_file( new /datum/computer/file/terminal_program/sigcrafter(src))
		newfolder.add_file( new /datum/computer/file/terminal_program/sigpal(src))
		newfolder.add_file( new /datum/computer/file/terminal_program/background/signal_catcher(src))
		if (prob(75))
			newfolder.add_file( new /datum/computer/file/terminal_program/writewizard(src))
		else
			newfolder.add_file( new /datum/computer/file/terminal_program/file_transfer(src))

//A computer disk with the hottest software, for nerds
/obj/item/disk/data/fixed_disk/techcomputer3
	New()
		. = ..()
		var/datum/computer/folder/newfolder = new /datum/computer/folder(  )
		newfolder.name = "logs"
		src.root.add_file( newfolder )
		newfolder.add_file( new /datum/computer/file/record/c3help(src))
		newfolder = new /datum/computer/folder
		newfolder.name = "bin"
		src.root.add_file( newfolder )
		newfolder.add_file( new /datum/computer/file/terminal_program/sigpal(src))
		newfolder.add_file( new /datum/computer/file/terminal_program/background/signal_catcher(src))
		newfolder.add_file( new /datum/computer/file/terminal_program/writewizard(src))
		newfolder.add_file( new /datum/computer/file/terminal_program/file_transfer(src))
