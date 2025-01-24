//CONTENTS
//Base disk
//Base fixed disk
//Base memcard
//Base tape reel (HEH)
//Base "read only" floppy.
//Computer3 boot floppy
//Network tools floppy
//Medical program floppy
//Security program floppy
//Research programs floppy
//Computer3-formatted fixed disk.
//Box of tapes


/obj/item/disk/data
	name = "data disk"
	icon = 'icons/obj/items/disks.dmi'
	icon_state = "datadisk0" //Gosh I hope syndies don't mistake them for the nuke disk.
	item_state = "card-id"
	w_class = W_CLASS_TINY
	var/read_only = 0 //Well,it's still a floppy disk
	//Filesystem vars
	var/datum/computer/folder/root = null
	var/file_amount = 32
	var/file_used = 0
	var/title = "Data Disk"

	New()
		..()
		src.root = new /datum/computer/folder
		src.root.holder = src
		src.root.name = "root"

	disposing()
		if (root)
			root.dispose()
			root = null
		. = ..()

	clone()
		var/obj/item/disk/data/D = ..()
		if (!D)
			return

		D.read_only = src.read_only
		D.title = src.title
		D.file_amount = src.file_amount
		if (src.root)
			D.root = src.root.copy_folder()
			D.root.holder = D

		return D

	proc/wipe_or_zap(mob/user)
		if(!read_only)
			user.visible_message(SPAN_ALERT("<b>[user] wipes the [src.name]!</b>"))
			elecflash(src,0, power=2, exclude_center = 0)
			if (src.root)
				src.root.dispose()

			src.root = new /datum/computer/folder
			src.root.holder = src
			src.root.name = "root"
		else
			user.visible_message(SPAN_ALERT("<b>[user] is zapped as the multitool backfires! The [src.name] seems unphased.</b>"))
			elecflash(user,0, power=2, exclude_center = 0)

	emp_act()
		. = ..()
		if (src.root)
			src.root.dispose()

		src.root = new /datum/computer/folder
		src.root.holder = src
		src.root.name = "root"

	attackby(obj/item/W, mob/user)
		if (ispulsingtool(W))
			user.visible_message(SPAN_ALERT("<b>[user] begins to wipe [src.name]!</b>"))
			SETUP_GENERIC_ACTIONBAR(user, src, 3 SECONDS, /obj/item/disk/data/proc/wipe_or_zap, list(user), src.icon, src.icon_state, null, null)

/obj/item/disk/data/floppy
	var/random_color = 1

/obj/item/disk/data/floppy/New()
	. = ..()
	if(random_color)
		var/diskcolor = pick(0,1,2)
		src.icon_state = "datadisk[diskcolor]"

/obj/item/disk/data/floppy/attack_self(mob/user as mob)
	src.read_only = !src.read_only
	boutput(user, "You flip the write-protect tab to [src.read_only ? "protected" : "unprotected"].")

/obj/item/disk/data/floppy/examine()
	. = ..()
	. += "The write-protect tab is set to [src.read_only ? "protected" : "unprotected"]."

/obj/item/disk/data/floppy/demo
	name = "data disk - 'Farmer Jeff'"
	read_only = 1

/obj/item/disk/data/floppy/monkey
	name = "data disk - 'Mr. Muggles'"
	read_only = 1

/obj/item/disk/data/floppy/lrt
	name = "galactic coordinate disk - 'Blank'"
	title = "Teleconsole"
	icon_state = "datadisktele0"
	random_color = FALSE

	var/target_name

	New()
		. = ..()
		var/datum/computer/file/lrt_data/place = new /datum/computer/file/lrt_data(src)
		place.place_name = src.target_name
		src.root.add_file( place )

	icemoon
		name = "galactic coordinate disk - 'Senex'"
		target_name = "Senex"

	solarium
		name = "galactic coordinate disk - 'Sol'"
		icon_state = "datadisktele1"
		target_name = "Sol"

	biodome
		name = "galactic coordinate disk - 'Fatuus'"
		target_name = "Fatuus"

	mars_outpost
		name = "galactic coordinate disk - 'Mars'"
		target_name = "Mars"

	lavamoon
		name = "galactic coordinate disk - 'Io'"
		target_name = "Io"

	luna_museum
		name = "galactic coordinate disk - 'Lunar Museum'"
		target_name = "Luna"

	ainley
		name = "galactic coordinate disk - 'Ainley'"
		target_name = "Ainley Staff Retreat"

	meat_derelict
		name = "galactic coordinate disk - 'Derelict Station'"
		target_name = "Derelict Station"


/obj/item/disk/data/fixed_disk
	name = "Storage Drive"
	icon_state = "harddisk"
	title = "Storage Drive"
	file_amount = 80

/obj/item/disk/data/memcard
	name = "Memory Board"
	icon_state = "memcard"
	desc = "A large board of non-volatile memory."
	title = "MEMCORE"
	file_amount = 640

/obj/item/disk/data/tape
	name = "ThinkTape"
	desc = "A form of proprietary magnetic data tape used by Thinktronic Data Systems, LLC."
	title = "MAGTAPE"
	icon_state = "tape"
	inhand_image_icon = 'icons/mob/inhand/hand_books.dmi'
	item_state = "paper"
	file_amount = 128

	New()
		. = ..()
		src.root.gen = 99 //No subfolders!!

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/pen))
			var/t = input(user, "Enter new tape label", src.name, null) as text
			t = copytext(strip_html(t), 1, 36)
			if (!in_interact_range(src, user) && src.loc != user)
				return
			if (!t)
				src.name = "ThinkTape"
				return

			src.name = "ThinkTape-'[t]'"
		else
			..()

//Floppy disks that are read-only ONLY.
//It's good to have a more permanent source of programs when somebody deletes everything (until they space all the disks)
//Remember to actually set them as read only after adding files in New()
/obj/item/disk/data/floppy/read_only
	name = "permafloppy"

	attack_self(mob/user as mob)
		boutput(user, SPAN_ALERT("You can't flip the write-protect tab, it's held in place with glue or something!"))
		return

/obj/item/disk/data/floppy/security
	icon_state = "datadiskmed" //yeah its "med" but its not used anywhere
	random_color = FALSE
	New()
		..()
		var/datum/computer/file/record/authrec = new /datum/computer/file/record {name = "SECAUTH";} (src)
		authrec.fields = list("SEC"="[netpass_security]")
		src.root.add_file( authrec )

/obj/item/disk/data/floppy/sec_command
	icon_state = "datadisksyn" //yeah its "syndie" but its not used anywhere
	random_color = FALSE

	New()
		..()
		var/datum/computer/file/record/authrec = new /datum/computer/file/record {name = "SECAUTH";} (src)
		authrec.fields = list("HEADS"="[netpass_heads]",
							"SEC"="[netpass_security]",)
		src.root.add_file(authrec)

/obj/item/disk/data/floppy/computer3boot
	name = "data disk-'ThinkDOS'"

	New()
		. = ..()
		src.root.add_file( new /datum/computer/file/terminal_program/os/main_os(src))
		var/datum/computer/folder/newfolder = new /datum/computer/folder(  )
		newfolder.name = "logs"
		src.root.add_file( newfolder )
		newfolder.add_file( new /datum/computer/file/record/c3help(src))
		newfolder = new /datum/computer/folder
		newfolder.name = "bin"
		src.root.add_file( newfolder )
		newfolder.add_file( new /datum/computer/file/terminal_program/writewizard(src))

/obj/item/disk/data/floppy/read_only/network_progs
	name = "data disk-'Network Tools'"
	desc = "A collection of network management tools."
	title = "Network Help"

	New()
		. = ..()
		src.root.add_file( new /datum/computer/file/terminal_program/background/ping(src))
		src.root.add_file( new /datum/computer/file/terminal_program/background/signal_catcher(src))
		src.root.add_file( new /datum/computer/file/terminal_program/file_transfer(src))
		//src.root.add_file( new /datum/computer/file/terminal_program/sigcrafter(src))
		src.root.add_file( new /datum/computer/file/terminal_program/sigpal(src))
		src.root.add_file( new /datum/computer/file/terminal_program/email(src))
		src.read_only = 1

/obj/item/disk/data/floppy/read_only/medical_progs
	name = "data disk-'Med-Trak 4'"
	desc = "The future of professional medical record management"
	title = "Med-Trak 4"

	New()
		. = ..()
		src.root.add_file( new /datum/computer/file/terminal_program/medical_records(src))
		src.read_only = 1

/obj/item/disk/data/floppy/read_only/security_progs
	name = "data disk-'SecMate 6'"
	desc = "It manages security records.  It is the law."
	title = "SecMate 6"

	New()
		. = ..()
		src.root.add_file( new /datum/computer/file/terminal_program/secure_records(src))
		src.root.add_file( new /datum/computer/file/terminal_program/manifest(src))
		src.read_only = 1

/obj/item/disk/data/floppy/read_only/research_progs
	name = "data disk-'AutoMate'"
	desc = "A disk containing a popular robotics research application."
	title = "Research"

	New()
		. = ..()
		src.root.add_file( new /datum/computer/file/terminal_program/robotics_research(src))
		src.read_only = 1

/obj/item/disk/data/floppy/read_only/ext_research_progs
	name = "data disk-'Research Suite'"
	desc = "A disk of research programs."
	title = "Research"

	New()
		. = ..()
		src.root.add_file( new /datum/computer/file/terminal_program/artifact_research(src))
		src.root.add_file( new /datum/computer/file/terminal_program/disease_research(src))
		src.root.add_file( new /datum/computer/file/terminal_program/robotics_research(src))
		src.read_only = 1

/obj/item/disk/data/floppy/read_only/terminal_os
	name = "data disk-'TermOS B'"
	desc = "A boot-disk for terminal systems."
	title = "TermOS"

	New()
		. = ..()
		src.root.add_file( new /datum/computer/file/terminal_program/os/terminal_os(src))
		src.read_only = 1

/obj/item/disk/data/floppy/read_only/communications
	name = "data disk-'COMMaster'"
	desc = "A disk for station communication programs."
	title = "COMMaster"

	New()
		. = ..()
		src.root.add_file( new /datum/computer/file/terminal_program/communications(src))
		src.root.add_file( new /datum/computer/file/terminal_program/manifest(src))
		src.read_only = 1
#ifdef SINGULARITY_TIME
/obj/item/disk/data/floppy/read_only/engine_prog
	name = "data disk-'EngineMaster'"
	desc = "A disk with an engine startup program."
	title = "EngineDisk"

	New()
		. = ..()
		src.root.add_file( new /datum/computer/file/terminal_program/engine_control(src))
		src.read_only = 1
#endif

TYPEINFO(/obj/item/disk/data/floppy/read_only/authentication)
	mats = 15

/obj/item/disk/data/floppy/read_only/authentication
	name = "Authentication Disk"
	desc = "Capable of storing entire kilobytes of information, this disk carries activation codes for various secure things that aren't nuclear bombs."
	icon_state = "nucleardisk"
	item_state = "card-id"
	object_flags = NO_GHOSTCRITTER
	w_class = W_CLASS_TINY
	random_color = 0
	file_amount = 32
	HELP_MESSAGE_OVERRIDE({"Use on an armed nuclear bomb to alter the time remaining until detonation.
	Use on an armory authorization computer to issue an emergency authorization or unauthorization.
	Use on an escape shuttle launch computer to alter the time until departure."})

	New()
		. = ..()
		SPAWN(1 SECOND) //Give time to actually generate network passes I guess.
			if (!root) return
			var/datum/computer/file/record/authrec = new /datum/computer/file/record {name = "GENAUTH";} (src)
			authrec.fields = list("HEADS"="[netpass_heads]",
								"SEC"="[netpass_security]",
								"MED"="[netpass_medical]")

			src.root.add_file( authrec )
			src.root.add_file( new /datum/computer/file/terminal_program/communications(src))
			src.read_only = 1

	attack_self(mob/user as mob)
		if(ON_COOLDOWN(user, "showoff_item", SHOWOFF_COOLDOWN))
			return
		user.visible_message("[user] flashes the [name].", "You show off the [name].")
		actions.start(new /datum/action/show_item(user, src, "disk"), user)

	attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
		if(ON_COOLDOWN(user, "showoff_item", SHOWOFF_COOLDOWN))
			return
		user.visible_message("[user] flashes the [name] at [target.name].", "You show off the [name] to [target.name]")
		actions.start(new /datum/action/show_item(user, src, "disk"), user)

/obj/item/disk/data/floppy/devkit
	name = "data disk-'Development'"
	title = "T-DISK"

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
