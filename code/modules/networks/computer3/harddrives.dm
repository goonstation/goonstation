/obj/item/disk/data/fixed_disk
	name = "storage drive"
	icon_state = "harddisk64"
	title = "Storage Drive"
	file_amount = 64
	var/max_file_amount = 64
	var/case_open = FALSE

	HELP_MESSAGE_OVERRIDE({"Use a <b>screwdriver</b> to open the case, allowing you to do the following:
		Use in-hand to toggle the write protect switch.
		Zap with a <b>multitool</b> to wipe the disk."})
		//Help intentionally does not mention the fact you can repair/tamper with circuitry since it's meant to be a neat hidden feature.

	clone()
		var/obj/item/disk/data/fixed_disk/D = ..()
		if (!D)
			return

		D.max_file_amount = src.max_file_amount
		D.case_open = src.case_open

		return D

	hd16
		file_amount = 16
		max_file_amount = 16
		icon_state = "harddisk"
		name = "storage drive"
		desc = "An old harddrive from a now-defunct company."

	hd32
		file_amount = 32
		max_file_amount = 32
		icon_state = "harddisk32"
		name = "storage drive-'Memtronic-32F'"
		title = "MT32F Drive"
		desc = "A first generation Thinktronics harddrive, from an era when files were still small. It makes a terrible sound while in use."

	hd64
		file_amount = 64
		max_file_amount = 64
		icon_state = "harddisk64"
		name = "storage drive-'Memtronic-64F'"
		title = "MT64F Drive"
		desc = "A second generation Thinktronics harddrive. Despite being older tech, it's by far the most common model in circulation due to its cost."

	hd96
		file_amount = 96
		max_file_amount = 128 //The rumours are true!!
		icon_state = "harddisk96"
		name = "storage drive-'Memtronic-96F'"
		title = "MT96F Drive"
		desc = "The latest mid-range entry in the Thinktronics brand of harddrives. Released alongside the Memtronic-128F, it's rumoured this drive has the same storage capacity as the 128F, but is intentionally gimped to save on production costs."

	hd128
		file_amount = 128
		max_file_amount = 128
		icon_state = "harddisk128"
		name = "storage drive-'Memtronic-128F'"
		title = "MT128F Drive"
		desc = "The latest high-range entry in the Thinktronics brand of harddrives. Expensive but bleeding edge file storage technology right at your fingertips."

/obj/item/disk/data/fixed_disk/examine()
	. = ..()
	if(case_open)
		. += "<b>The case is open, exposing the internal circuitry."
		. += "<b>The write-protect switch is set to [src.read_only ? "protected" : "unprotected"]."
		if(max_file_amount > file_amount)
			. += "<b>The circuit looks tampered with."

/obj/item/disk/data/fixed_disk/attackby(obj/item/W, mob/user)
	if (isscrewingtool(W))
		case_open = !case_open
		var/hdsize = max_file_amount <= 128 ? max_file_amount : 128
		icon_state = "harddisk"+(hdsize >= 32 ? "[hdsize]" : "")+ (case_open ? "_open" : "") //I hate tenerary operators
		boutput(user, "You [case_open ? "open" : "close"] the case of the [src].")
	else if (ispulsingtool(W))
		if(case_open)
			user.visible_message(SPAN_ALERT("<b>[user] begins to wipe [src]!</b>"))
			SETUP_GENERIC_ACTIONBAR(user, src, 3 SECONDS, /obj/item/disk/data/proc/wipe_or_zap, list(user), src.icon, src.icon_state, null, null)
		else
			boutput(user, "The case is closed, open it with a screwdriver first to wipe it with the [W].")
	else if(issolderingtool(W))
		if(case_open)
			if(file_amount < max_file_amount)
				boutput(user, "You begin repairing the [src]'s circuitry.")
				SETUP_GENERIC_ACTIONBAR(user, src, 30 SECONDS, /obj/item/disk/data/fixed_disk/proc/solder, list(user), src.icon, src.icon_state, null, null)
		else
			boutput(user, "The case is closed, open it with a screwdriver first.")
	else if(issnippingtool(W)) //Realistically no one would ever use this but I feel any action that can be done should be undoable in some way.
		if(case_open)
			if(file_amount > max_file_amount/4)
				boutput(user, "You begin tampering with the [src]'s circuitry.")
				SETUP_GENERIC_ACTIONBAR(user, src, 5 SECONDS, /obj/item/disk/data/fixed_disk/proc/cut_mem, list(user), src.icon, src.icon_state, null, null)
			else
				boutput(user, "The [src] is already too damaged, further tampering could break it permanently.")
		else
			boutput(user, "The case is closed, open it with a screwdriver first.")

/obj/item/disk/data/fixed_disk/proc/solder(mob/user)
	src.file_amount = src.max_file_amount
	boutput(user, "You finish repairing the [src].")

/obj/item/disk/data/fixed_disk/proc/cut_mem(mob/user)
	src.file_amount = src.file_amount - ceil(src.max_file_amount/4)
	if(file_amount < max_file_amount/4)src.file_amount = ceil(src.max_file_amount/4) //I don't want to think about what happens if a disk has 0 file space.

/obj/item/disk/data/fixed_disk/attack_self(mob/user as mob)
	if(case_open)
		src.read_only = !src.read_only
		boutput(user, "You flip the write-protect switch to [src.read_only ? "protected" : "unprotected"].")
	else
		boutput(user, "The case is closed, open it with a screwdriver first to flip the write-protect switch!")

//A fixed disk with some structure already set up for the main os I guess
/obj/item/disk/data/fixed_disk/hd64/computer3
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
/obj/item/disk/data/fixed_disk/hd128/techcomputer3
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
