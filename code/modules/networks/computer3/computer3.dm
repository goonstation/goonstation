
#define MAX_INPUT_HISTORY_LENGTH 100 //! Maximum amount of things some nerd can put in here until we've had enough

/obj/machinery/computer3
	name = "computer"
	desc = "A computer that uses the bleeding-edge command line OS ThinkDOS."
	icon = 'icons/obj/computer.dmi'
	icon_state = "computer_generic"
	density = 1
	anchored = ANCHORED
	var/base_icon_state = "computer_generic"
	var/temp = "<b>Thinktronic BIOS V2.1</b><br>"
	var/temp_add = null
	var/obj/item/disk/data/fixed_disk/hd = null
	var/datum/computer/file/terminal_program/active_program
	var/datum/computer/file/terminal_program/host_program //active is set to this when the normal active quits, if available
	var/list/processing_programs = list()
	var/obj/item/disk/data/floppy/diskette = null
	var/list/peripherals = list()
	var/restarting = 0 //Are we currently restarting the system?
	var/datum/light/light

	//Does it spawn with a card scanner? (It should, the main os needs one of these now.)
	var/setup_idscan_path = null
	var/setup_has_internal_disk = 0 //Do we use that magic disk drive that has no peripheral attached?
	var/setup_drive_size = 64
	var/setup_drive_type = null //Use this path for the hd
	var/setup_frame_type = /obj/computer3frame //What kind of frame does it spawn while disassembled.  This better be a type of /obj/compute3frame !!
	var/setup_starting_program = null //This program will start out installed on the drive (can be a path or a list of paths)
	var/setup_starting_os = null //This program will start out installed AND AS ACTIVE PROGRAM
	var/setup_starting_peripheral1 = null //Please note that the user cannot install more than 3.
	var/setup_starting_peripheral2 = null //And the os tends to need that third one for the card reader
	var/setup_os_string = null
	var/setup_font_color = "#19A319"
	var/setup_bg_color = "#1B1E1B"
	/// does it have a glow in the dark screen? see computer_screens.dmi
	var/glow_in_dark_screen = TRUE
	var/image/screen_image

	// Vars for command history
	var/list/list/tgui_input_history //! (Keyed by CKEY) A list of strings representing the terminal's command execution history. New history is appended as commands are executed
	var/list/tgui_input_index //! (Keyed by CKEY)  An index pointing to the position in tgui_input_history to update tgui_last_accessed with
	var/list/tgui_last_accessed //! (Keyed by CKEY)  The most recently accessed command from the console

	power_usage = 250

	generic //Generic computer, standard os and card scanner
		setup_drive_type = /obj/item/disk/data/fixed_disk/computer3
		setup_starting_os = /datum/computer/file/terminal_program/os/main_os
		setup_idscan_path = /obj/item/peripheral/card_scanner
		setup_has_internal_disk = 1

		personal
			name = "Personal Computer"
			icon_state = "old"
			base_icon_state = "old"
			setup_frame_type = /obj/computer3frame/desktop
			setup_starting_peripheral1 = /obj/item/peripheral/network/powernet_card/terminal
			setup_starting_peripheral2 = /obj/item/peripheral/sound_card
			setup_starting_program = /datum/computer/file/terminal_program/email

			personel_alt
				icon_state = "old_alt"
				base_icon_state = "old_alt"


		med_data
			name = "Medical computer"
			icon_state = "datamed"
			base_icon_state = "datamed"
			setup_starting_peripheral1 = /obj/item/peripheral/network/powernet_card
			setup_starting_peripheral2 = /obj/item/peripheral/printer
			setup_starting_program = /datum/computer/file/terminal_program/medical_records



			console_upper
				icon = 'icons/obj/computerpanel.dmi'
				icon_state = "medicalcomputer1"
				base_icon_state = "azungarcomputer_upper"
				setup_frame_type = /obj/computer3frame/azungarcomputer_upper

			console_lower
				icon = 'icons/obj/computerpanel.dmi'
				icon_state = "medicalcomputer2"
				base_icon_state = "azungarcomputer_lower"
				setup_frame_type = /obj/computer3frame/azungarcomputer_lower

		secure_data
			name = "Security computer"
			icon_state = "datasec"
			base_icon_state = "datasec"
			setup_starting_peripheral1 = /obj/item/peripheral/network/powernet_card
			setup_starting_peripheral2 = /obj/item/peripheral/network/radio/locked/pda/transmit_only
			setup_starting_program = /datum/computer/file/terminal_program/secure_records

			console_upper
				icon = 'icons/obj/computerpanel.dmi'
				icon_state = "securitycomputer1"
				base_icon_state = "securitycomputer1"
			console_lower
				icon = 'icons/obj/computerpanel.dmi'
				icon_state = "securitycomputer2"
				base_icon_state = "securitycomputer2"

		bank_data
			name = "Bank computer"
			icon_state = "databank"
			base_icon_state = "databank"
			setup_starting_peripheral1 = /obj/item/peripheral/network/powernet_card
			setup_starting_peripheral2 = /obj/item/peripheral/printer
			setup_starting_program = list(/datum/computer/file/terminal_program/bank_records, /datum/computer/file/terminal_program/secure_records)

			console_upper
				icon = 'icons/obj/computerpanel.dmi'
				icon_state = "bank1"
				base_icon_state = "bank1"
			console_lower
				icon = 'icons/obj/computerpanel.dmi'
				icon_state = "bank2"
				base_icon_state = "bank2"

		communications
			name = "Communications Console"
			icon_state = "comm"
			setup_starting_program = list(/datum/computer/file/terminal_program/communications, /datum/computer/file/terminal_program/job_controls)
			setup_starting_peripheral1 = /obj/item/peripheral/network/powernet_card
			setup_starting_peripheral2 = /obj/item/peripheral/network/radio/locked/status
			setup_drive_size = 80

			console_upper
				icon = 'icons/obj/computerpanel.dmi'
				icon_state = "communications1"
				base_icon_state = "communications1"
			console_lower
				icon = 'icons/obj/computerpanel.dmi'
				icon_state = "communications2"
				base_icon_state = "communications2"

		disease_research
			name = "Disease Database"
			icon_state = "resdis"
			setup_starting_program = /datum/computer/file/terminal_program/disease_research
			setup_drive_size = 48

		artifact_research
			name = "Artifact Database"
			icon_state = "resart"
			setup_starting_program = /datum/computer/file/terminal_program/artifact_research
			setup_drive_size = 48

		hangar_control
			name = "Hangar Control"
			icon_state = "comm"
			//setup_starting_program = /datum/computer/file/terminal_program/hangar_control
			setup_drive_size = 48
		hangar_research
			name = "Hangar Research"
			icon_state = "resrob"
			//setup_starting_program = /datum/computer/file/terminal_program/hangar_research
			setup_drive_size = 48
		robotics_research
			name = "Robotics Database"
			icon_state = "resrob"
			setup_starting_program = /datum/computer/file/terminal_program/robotics_research
			setup_drive_size = 48
/*
		dna_scan
			name = "DNA Modifier Access Console"
			icon_state = "scanner"
			setup_starting_peripheral1 = /obj/item/peripheral/dnascanner_control
*/

		engine
			name = "Engine Control Console"
			icon_state = "engine"
			base_icon_state = "engine"

			setup_starting_program = /datum/computer/file/terminal_program/engine_control
			setup_starting_peripheral1 = /obj/item/peripheral/network/powernet_card
			setup_starting_peripheral2 = /obj/item/peripheral/network/radio/locked/pda/transmit_only
			setup_drive_size = 48

			console_upper
				icon = 'icons/obj/computerpanel.dmi'
				icon_state = "engine1"
				base_icon_state = "engine1"
			console_lower
				icon = 'icons/obj/computerpanel.dmi'
				icon_state = "engine2"
				base_icon_state = "engine2"
			manta_computer
				icon = 'icons/obj/large/32x96.dmi'
				icon_state = "nuclearcomputer"
				anchored = ANCHORED_ALWAYS
				density = 1
				bound_height = 96
				bound_width = 32

		radio
			name = "wireless computer"
			setup_starting_peripheral1 = /obj/item/peripheral/network/radio

		basic_test
			name = "personal computer"
			//setup_starting_program = /datum/computer/file/terminal_program/basic
			setup_starting_peripheral1 = /obj/item/peripheral/network/powernet_card
			setup_starting_peripheral2 = /obj/item/peripheral/drive/cart_reader

		supply
			name = "Supply Ordering Computer"
			setup_idscan_path = /obj/item/peripheral/card_scanner/register

	terminal //Terminal computer, stripped down with less cards.
		name = "Terminal"
		icon_state = "dterm"
		base_icon_state = "dterm"
		setup_drive_size = 24
		setup_frame_type = /obj/computer3frame/terminal
		setup_starting_os = /datum/computer/file/terminal_program/os/terminal_os

		console_upper
			icon = 'icons/obj/computerpanel.dmi'
			icon_state = "dwaine1"
			base_icon_state = "dwaine1"
		console_lower
			icon = 'icons/obj/computerpanel.dmi'
			icon_state = "dwaine2"
			base_icon_state = "dwaine2"

		network
			name = "Network Terminal"
			//Terminal frames can only hold two cards please don't add more here
			setup_starting_peripheral1 = /obj/item/peripheral/network/powernet_card/terminal

			console_upper
				icon = 'icons/obj/computerpanel.dmi'
				icon_state = "dwaine1"
				base_icon_state = "dwaine1"
			console_lower
				icon = 'icons/obj/computerpanel.dmi'
				icon_state = "dwaine2"
				base_icon_state = "dwaine2"

		zeta
			name = "DWAINE Terminal"
			setup_idscan_path = /obj/item/peripheral/card_scanner
			setup_starting_peripheral1 = /obj/item/peripheral/network/powernet_card/terminal

			console_upper
				icon = 'icons/obj/computerpanel.dmi'
				icon_state = "dwaine1"
				base_icon_state = "dwaine1"
			console_lower
				icon = 'icons/obj/computerpanel.dmi'
				icon_state = "dwaine2"
				base_icon_state = "dwaine2"


	luggable //A portable(!!) computer 3. Cards cannot be exchanged.
		name = "portable computer"
		desc = "A much smaller computer workstation, designed to be hoisted around by 80s business executives."
		density = 0
		icon_state = "bcase"
		base_icon_state = "bcase"

		setup_drive_type = /obj/item/disk/data/fixed_disk/computer3
		setup_starting_os = /datum/computer/file/terminal_program/os/main_os
		setup_idscan_path = /obj/item/peripheral/card_scanner
		setup_has_internal_disk = 1
		setup_starting_peripheral1 = /obj/item/peripheral/network/omni
		setup_starting_peripheral2 = /obj/item/peripheral/cell_monitor
		setup_drive_size = 32

		var/obj/item/cell/cell //We have limited power! Immersion!!
		var/setup_charge_maximum = 15000
		var/obj/item/luggable_computer/personal/case //The object that holds us when we're all closed up.
		var/deployed = 1

		Exited(Obj, newloc)
			. = ..()
			if(Obj == src.cell)
				src.cell = null

		personal
			name = "Personal Laptop"
			desc = "This fine piece of hardware sports an incredible 2 kilobytes of RAM, all for a price slightly higher than the whole economy of greece."
			icon_state = "oldlap"
			base_icon_state = "oldlap"
			setup_starting_peripheral1 = /obj/item/peripheral/network/omni
			setup_starting_peripheral2 = /obj/item/peripheral/sound_card


/obj/machinery/computer3/New()
	..()

	light = new/datum/light/point
	light.set_brightness(0.4)
	light.attach(src)

	src.base_icon_state = src.icon_state
	src.tgui_input_history = list()
	src.tgui_input_index = list()
	src.tgui_last_accessed = list()

	if(glow_in_dark_screen)
		src.screen_image = image('icons/obj/computer_screens.dmi', src.icon_state, -1)
		screen_image.plane = PLANE_LIGHTING
		screen_image.blend_mode = BLEND_ADD
		screen_image.layer = LIGHTING_LAYER_BASE
		screen_image.color = list(0.33,0.33,0.33, 0.33,0.33,0.33, 0.33,0.33,0.33)
		src.AddOverlays(screen_image, "screen_image")

	SPAWN(0.4 SECONDS)
		if(!length(src.peripherals)) // make sure this is the first time we're initializing this computer
			if(ispath(src.setup_starting_peripheral1))
				new src.setup_starting_peripheral1(src) //Peripherals add themselves automatically if spawned inside a computer3

			if(ispath(src.setup_starting_peripheral2))
				new src.setup_starting_peripheral2(src)


			if(src.setup_idscan_path)
				new src.setup_idscan_path(src)

			if(!hd && (setup_drive_size > 0))
				if(src.setup_drive_type)
					src.hd = new src.setup_drive_type
					src.hd.set_loc(src)
				else
					src.hd = new /obj/item/disk/data/fixed_disk(src)
				src.hd.file_amount = src.setup_drive_size

			for (var/program_path in (list() + src.setup_starting_program)) //neat hack to make it work with lists or a single path
				if(ispath(program_path))
					var/datum/computer/file/terminal_program/starting = new program_path

					src.hd.file_amount = max(src.hd.file_amount, starting.size)

					starting.transfer_holder(src.hd)

			if(ispath(src.setup_starting_os) && src.hd)
				var/datum/computer/file/terminal_program/os/os = new src.setup_starting_os
				if((src.hd.root.size + os.size) >= src.hd.file_amount)
					src.hd.file_amount += os.size

				os.setup_string = src.setup_os_string
				src.host_program = os
				src.host_program.master = src
				src.processing_programs += src.host_program
				if(!src.active_program)
					src.active_program = os

				src.hd.root.add_file(os)

		src.post_system()

		if (prob(60))
			switch(rand(1,2))
				if(1)
					setup_font_color = "#E79C01"
				if(2)
					setup_font_color = "#A5A5FF"
					setup_bg_color = "#4242E7"

	return
/obj/machinery/computer3/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Terminal")
		ui.open()

/obj/machinery/computer3/ui_static_data(mob/user)
	. = list(
		"ckey" = user.ckey,
	)
	if(src.setup_has_internal_disk) // the magic internal floppy drive is in here
		. += list("peripherals" = list(list(
		"icon" = "save",
		"card" = "internal",
		"color" = src.diskette,
		"contents" = src.diskette,
		"label" = "Disk",
		)))
	for (var/i in 1 to length(src.peripherals)) // originally i had all this stuff in static data, but the buttons didnt update.
		var/obj/item/peripheral/periph = src.peripherals[i]
		if(periph.setup_has_badge)
			var/list/pdata = periph.return_badge() // reduces copy pasting
			pdata["index"] = i
			if(pdata)
				var/bcolor = pdata["contents"]
				pdata += list("color" = bcolor, "card" = periph.type)
				.["peripherals"] += list(pdata)

/obj/machinery/computer3/ui_data(mob/user)
	src.tgui_last_accessed[user.ckey] ||= ""
	. = list(
		"displayHTML" = src.temp, // display data
		"TermActive" = src.active_program, // is the terminal running or restarting
		"fdisk" = src.diskette, // for showing if the internal diskette slot is filled
		"windowName" = src.name,
		"user" = user,
		"fontColor" = src.setup_font_color, // display monochrome values
		"bgColor" = src.setup_bg_color,
		"inputValue" = src.tgui_last_accessed[user.ckey],
	)

/// Get the history entry at a certain index. Returns null if the index is out of bounds or the ckey is null. Will return an empty string for length+1
/obj/machinery/computer3/proc/get_history(ckey, index)
	if (isnull(ckey))
		return
	// Allow length+1 to simulate hitting the 'end' of the history and ending up on an empty line
	if (index == length(src.tgui_input_history[ckey]) + 1)
		return ""
	// Ensure index with key exists
	src.tgui_input_history[ckey] ||= list()
	// Ensure we can return a value
	if (index < 1 || length(src.tgui_input_history[ckey]) < index)
		return
	return src.tgui_input_history[ckey][index]

/obj/machinery/computer3/proc/add_history(ckey, new_history)
	// Ensure index with key exists
	src.tgui_input_history[ckey] ||= list()
	src.tgui_input_history[ckey].Add(new_history)
	// Ensure not over limit after adding new entry
	if (length(src.tgui_input_history) > MAX_INPUT_HISTORY_LENGTH)
		src.tgui_input_history[ckey].Remove(src.tgui_input_history[ckey][1])
	// After typing something else in the console, history is always most recent entry
	src.tgui_input_index[ckey] = length(src.tgui_input_history[ckey])

/// Traverse the current history by some amount. Returns true if different history was accessed, false otherwise (usually if new index OOB)
/obj/machinery/computer3/proc/traverse_history(ckey, amount)
	// Most recent entry in history if first time accessing
	src.tgui_input_index[ckey] ||= length(src.tgui_input_history[ckey])
	// Ensure previous history exists
	var/result = src.get_history(ckey, src.tgui_input_index[ckey] + amount)
	if (isnull(result))
		return FALSE
	src.tgui_input_index[ckey] = src.tgui_input_index[ckey] + amount
	src.tgui_last_accessed[ckey] = result
	return TRUE

/obj/machinery/computer3/ui_act(action, params)
	. = ..()
	if (.) return

	switch(action)
		if("restart")
			src.restart()
			src.updateUsrDialog()
		if("history")
			if (params["direction"] == "prev")
				return src.traverse_history(params["ckey"], -1)
			if (params["direction"] == "next")
				return src.traverse_history(params["ckey"],  1)
		if("text")
			if(src.active_program && params["value"]) // haha it fucking works WOOOOOO
				if(params["value"] == "term_clear")
					src.temp = "Cleared\n"
					return
				src.active_program.input_text(params["value"])
				src.add_history(params["ckey"], params["value"])
				playsound(src.loc, "keyboard", 50, 1, -15)
				src.updateUsrDialog()
		if("buttonPressed")
			var/obj/item/I = usr.equipped() // how the old code did it
			if(params["card"] == "internal") // the hacky magic floppy disk reader
				if(src.diskette)
					//Ai/cyborgs cannot press a physical button from a room away.
					if((issilicon(usr) || isAI(usr)) && BOUNDS_DIST(src, usr) > 0)
						boutput(usr, SPAN_ALERT("You cannot press the ejection button."))
						return
					for(var/datum/computer/file/terminal_program/P in src.processing_programs)
						P.disk_ejected(src.diskette)
					usr.put_in_hand_or_eject(src.diskette)
					src.diskette= null
				else if(istype(I,/obj/item/disk/data/floppy))
					usr.drop_item()
					I.loc = src
					src.diskette = I
				update_static_data(usr)
			else
				//What type of drive are we?
				if (findtext(params["card"], "/obj/item/peripheral/card_scanner"))
					//A card drive!
					var/obj/item/peripheral/card_scanner/dv = src.peripherals[params["index"]]
					if(dv.authid)
						usr.put_in_hand_or_eject(dv.authid)
						dv.authid = null
					else if(istype(I, /obj/item/card/id))
						usr.drop_item()
						I.loc = src
						dv.authid = I
					update_static_data(usr)

				else if (findtext(params["card"], "/obj/item/peripheral/drive"))
					//A disk drive!
					var/obj/item/peripheral/drive/dv = src.peripherals[params["index"]]
					if(dv.disk)
						usr.put_in_hand_or_eject(dv.disk)
						dv.disk = null
					else if(istype(I, dv.setup_disk_type))
						usr.drop_item()
						I.loc = src
						dv.disk = I
					update_static_data(usr)
				else if (findtext(params["card"], "/obj/item/peripheral/cheget_key"))
					var/obj/item/peripheral/cheget_key/cheget_key = src.peripherals[params["index"]]
					if (cheget_key.inserted_key)
						usr.put_in_hand_or_eject(cheget_key.inserted_key)
						cheget_key.inserted_key = null
						boutput(usr, SPAN_NOTICE("You turn the key and pull it out of the lock. The green light turns off."))
						playsound(src.loc, 'sound/impact_sounds/Generic_Click_1.ogg', 30, 1)
						SPAWN(1 SECOND)
							if(!cheget_key.inserted_key)
								src.visible_message(SPAN_ALERT("[src] emits a dour boop and a small red light flickers on."))
								playsound(src.loc, 'sound/machines/cheget_sadbloop.ogg', 30, 1)
								var/datum/signal/deauthSignal = get_free_signal()
								deauthSignal.data = list("authcode"="\ref[src]")
								cheget_key.send_command("key_deauth", deauthSignal)

					else if(istype(I, /obj/item/device/key/cheget))
						usr.drop_item()
						I.loc = src
						cheget_key.inserted_key = I
						boutput(usr, SPAN_NOTICE("You insert the key and turn it."))
						playsound(src.loc, 'sound/impact_sounds/Generic_Click_1.ogg', 30, 1)
						SPAWN(1 SECOND)
							if(cheget_key.inserted_key)
								src.visible_message(SPAN_ALERT("[src] emits a satisfied boop and a little green light comes on."))
								playsound(src.loc, 'sound/machines/cheget_goodbloop.ogg', 30, 1)
								var/datum/signal/authSignal = get_free_signal()
								authSignal.data = list("authcode"="\ref[I]")
								cheget_key.send_command("key_auth", authSignal)
					else if(istype(I, /obj/item/device/key))
						boutput(usr, SPAN_ALERT("It doesn't fit.  Must be the wrong key."))
						src.visible_message(SPAN_ALERT("[src] emits a grumpy boop."))
						playsound(src.loc, 'sound/machines/cheget_grumpbloop.ogg', 30, 1)
					update_static_data(usr)
	. = TRUE

/obj/machinery/computer3/updateUsrDialog()
	..()
	if (src.temp_add)
		src.temp += src.temp_add
		src.temp_add = null

/obj/machinery/computer3/process()
	if(status & BROKEN)
		return
	..()
	if(status & NOPOWER)
		return

	for(var/datum/computer/file/terminal_program/P in src.processing_programs)
		P.process()

	return

/obj/machinery/computer3/power_change()
	if(status & BROKEN)
		icon_state = src.base_icon_state
		src.icon_state += "b"
		light.disable()
		if(glow_in_dark_screen)
			src.ClearSpecificOverlays("screen_image")

	else if(powered())
		icon_state = src.base_icon_state
		status &= ~NOPOWER
		light.enable()
		if(glow_in_dark_screen)
			src.AddOverlays(screen_image, "screen_image")
	else
		SPAWN(rand(0, 15))
			icon_state = src.base_icon_state
			src.icon_state += "0"
			status |= NOPOWER
			light.disable()
			if(glow_in_dark_screen)
				src.ClearSpecificOverlays("screen_image")

/obj/machinery/computer3/attackby(obj/item/W, mob/user)
	if (istype(W, /obj/item/disk/data/floppy)) //INSERT SOME DISKETTES
		if ((!src.diskette) && src.setup_has_internal_disk)
			user.drop_item()
			W.set_loc(src)
			src.diskette = W
			boutput(user, "You insert [W].")
			update_static_data(usr)
			return
		else if(src.diskette)
			boutput(user, SPAN_ALERT("There's already a disk inside!"))
		else if(!src.setup_has_internal_disk)
			boutput(user, SPAN_ALERT("There's no visible peripheral device to insert the disk into!"))

	else if (isscrewingtool(W))
		playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
		SETUP_GENERIC_ACTIONBAR(user, src, 2 SECONDS, /obj/machinery/computer3/proc/unscrew_monitor,\
		list(W, user), W.icon, W.icon_state, null, null)

	else if(istype(W, /obj/item/card/id))
		var/obj/item/peripheral/card_scanner/dv = get_card_scanner()
		if (!dv)
			src.Attackhand(user)
			return

		if (dv.authid)
			boutput(user, SPAN_ALERT("There is already a card inserted!"))
		else
			usr.drop_item()
			W.loc = src
			dv.authid = W
			update_static_data(usr)
		return

	else
		src.Attackhand(user)
	return

/obj/machinery/computer3/proc/get_card_scanner()
	. = locate(/obj/item/peripheral/card_scanner) in src.peripherals
	if (!.)
		. = locate(/obj/item/peripheral/card_scanner/editor) in src.peripherals
	if (!.)
		. = locate(/obj/item/peripheral/card_scanner/register) in src.peripherals
	if (!.)
		. = locate(/obj/item/peripheral/card_scanner/clownifier) in src.peripherals

/obj/machinery/computer3/proc/unscrew_monitor(obj/item/W as obj, mob/user as mob)
	if(!ispath(setup_frame_type, /obj/computer3frame))
		src.setup_frame_type = /obj/computer3frame
	var/obj/computer3frame/A = new setup_frame_type( src.loc )
	A.computer_type = src.type
	if(src.material) A.setMaterial(src.material)
	A.created_icon_state = src.base_icon_state
	A.set_dir(src.dir)
	if (src.status & BROKEN)
		user?.show_text("The broken glass falls out.", "blue")
		var/obj/item/raw_material/shard/glass/G = new /obj/item/raw_material/shard/glass
		G.set_loc( src.loc )
		A.state = 3
		A.icon_state = "3"
	else
		user?.show_text("You disconnect the monitor.", "blue")
		A.state = 4
		A.icon_state = "4"

	for (var/obj/item/peripheral/C in src.peripherals)
		C.set_loc(A)
		A.peripherals.Add(C)
		C.uninstalled()

	if(src.diskette)
		src.diskette.set_loc(src.loc)
		src.diskette = null

	if(src.hd)
		src.hd.set_loc(A)
		A.hd = src.hd
		src.hd = null

	A.mainboard = new /obj/item/motherboard(A)
	A.mainboard.created_name = src.name
	A.mainboard.integrated_floppy = src.setup_has_internal_disk


	A.anchored = ANCHORED
	//dispose()
	src.dispose()

/obj/machinery/computer3/meteorhit(var/obj/O as obj)
	if(status & BROKEN)
		//dispose()
		src.dispose()
	set_broken()
	var/datum/effects/system/harmless_smoke_spread/smoke = new /datum/effects/system/harmless_smoke_spread()
	smoke.set_up(5, 0, src)
	smoke.start()
	return

/obj/machinery/computer3/ex_act(severity)
	switch(severity)
		if(1)
			//dispose()
			src.dispose()
			return
		if(2)
			if (prob(50))
				set_broken()
		if(3)
			if (prob(25))
				set_broken()

/obj/machinery/computer3/emp_act()
	..()
	if(prob(20))
		src.set_broken()
	return

/obj/machinery/computer3/blob_act(var/power)
	if (prob(power * 2.5))
		set_broken()
		src.set_density(0)

/obj/machinery/computer3/bullet_act(obj/projectile/P)
	. = ..()
	switch (P.proj_data.damage_type)
		if (D_KINETIC, D_PIERCING, D_SLASHING)
			if (prob(P.power))
				if (status & BROKEN)
					playsound(src, "sound/impact_sounds/Glass_Shatter_[rand(1,3)].ogg", 50, TRUE)
					src.unscrew_monitor()
				else
					src.set_broken()

/obj/machinery/computer3/overload_act()
	return !src.set_broken()

/obj/machinery/computer3/disposing()
	if (hd)
		if (hd.loc == src)
			hd.dispose()
		hd = null

	if (diskette)
		if (diskette.loc == src)
			diskette.dispose()
		diskette = null

	if (peripherals)
		for (var/obj/P in peripherals)
			if (P.loc == src)
				P.dispose()

		peripherals.len = 0
		peripherals = null

	if (processing_programs)
		src.processing_programs.len = 0
		src.processing_programs = null

	tgui_input_history = null

	active_program = null
	host_program = null

	..()

/obj/machinery/computer3/proc

	run_program(datum/computer/file/terminal_program/program)
		if((!program) || (!program.holder))
			return 0

		if(!(program.holder in src))
	//		boutput(world, "Not in src")
			program = new program.type
			program.transfer_holder(src.hd)

		if(program.master != src)
			program.master = src

		if(!src.host_program && istype(program, /datum/computer/file/terminal_program/os))
			src.host_program = program

		if(!(program in src.processing_programs))
			src.processing_programs += program

		src.active_program = program
		src.active_program.initialize()
		return 1

	//Stop processing the current active program and make the host active again
	unload_program(datum/computer/file/terminal_program/program)
		if(!program)
			return 0

		if(program == src.host_program)
			return 0

		src.processing_programs -= program
		if(src.active_program == program)
			src.active_program = src.host_program

		return 1

	delete_file(datum/computer/file/theFile)
		//boutput(world, "Deleting [file]...")
		if((!theFile) || (!theFile.holder) || (theFile.holder.read_only))
			//boutput(world, "Cannot delete :(")
			return 0

		//Don't delete the running program you jerk
		if(src.active_program == theFile || src.host_program == theFile)
			src.active_program = null

		//boutput(world, "Now calling del on [file]...")
		//qdel(file)
		theFile.dispose()
		return 1

	send_command(command, datum/signal/signal, target_ref)
		//for(var/obj/item/peripheral/P in src.peripherals)
		//	P.receive_command(src, command, signal)

		. = 1
		var/obj/item/peripheral/P = locate(target_ref) in src.peripherals
		if(istype(P))
			. = P.receive_command(src, command, signal)

		if(signal)
			qdel(signal)
		return

	receive_command(obj/source, command, datum/signal/signal)
		if(source in src.contents)

			for(var/datum/computer/file/terminal_program/P in src.processing_programs)
				P.receive_command(src, command, signal)

			qdel(signal)
		return

	restart()
		if(src.restarting)
			return
		src.restarting = 1
		src.active_program = null
		src.host_program?.restart()
		src.host_program = null
		src.processing_programs = new
		src.temp = ""
		src.temp_add = "Restarting system...<br>"
		src.tgui_input_history = list()
		src.tgui_input_index = list()
		src.updateUsrDialog()
		playsound(src.loc, 'sound/machines/keypress.ogg', 50, 1, -15)
		SPAWN(2 SECONDS)
			src.restarting = 0
			src.post_system()

		return

	post_system()
		src.temp_add += "Initializing system...<br>"

		if(!src.hd)
			src.temp_add += "<font color=red>1701 - NO FIXED DISK</font><br>"

		if(src.host_program) //Let the starting programs set up vars or whatever
			src.host_program.initialize()

			if(src.active_program && src.active_program != src.host_program) //Don't init one twice!
				src.active_program.initialize()

		else
			if(src.diskette && src.diskette.root)
				var/datum/computer/file/terminal_program/os/newos = locate(/datum/computer/file/terminal_program/os) in src.diskette.root.contents

				if(newos && istype(newos))
					src.temp_add += "Booting from diskette...<br>"
					src.run_program(newos)
				else
					src.temp_add += "<font color=red>Non-system disk or disk error.</font><br>"

			if(!src.host_program && src.hd && src.hd.root)
				var/datum/computer/file/terminal_program/os/newos = locate(/datum/computer/file/terminal_program/os) in src.hd.root.contents

				if(newos && istype(newos))
					src.temp_add += "Booting from fixed disk...<br>"
					src.run_program(newos)
				else
					src.temp_add += "<font color=red>Unable to boot from fixed disk.</font><br>"

			if(!src.host_program)
				var/success = 0
				for(var/obj/item/disk/data/D in src)
					if(D == src.hd || D == src.diskette)
						continue

					var/datum/computer/file/terminal_program/os/newos = locate() in D.root.contents

					if(istype(newos))
						src.temp_add += "Booting from peripheral disk...<br>"
						success = 1
						src.run_program(newos)
						break

				if(!success)
					src.temp_add += "<font color=red>ERR - BOOT FAILURE</font><br>"

		src.updateUsrDialog()
		return

/obj/machinery/computer3/clone()
	var/obj/machinery/computer3/cloneComp = ..()
	if (!cloneComp)
		return

	if (src.hd)
		cloneComp.hd = src.hd.clone()

	if (src.diskette)
		cloneComp.diskette = src.diskette.clone()

	cloneComp.setup_starting_peripheral1 = src.setup_starting_peripheral1
	cloneComp.setup_starting_peripheral2 = src.setup_starting_peripheral2

	cloneComp.setup_starting_os = null
	cloneComp.setup_idscan_path = src.setup_idscan_path
	cloneComp.setup_has_internal_disk = src.setup_has_internal_disk

	cloneComp.setup_font_color = src.setup_font_color
	cloneComp.setup_bg_color = src.setup_bg_color

	return cloneComp


//Special overrides and what-not for luggables.
/obj/item/luggable_computer
	name = "briefcase"
	icon = 'icons/obj/computer.dmi'
	icon_state = "briefcase"
	inhand_image_icon = 'icons/mob/inhand/hand_general.dmi'
	item_state = "briefcase"
	desc = "A common item to find in an office.  Is that an antenna?"
	flags = TABLEPASS| CONDUCT | NOSPLASH
	force = 8
	throw_speed = 1
	throw_range = 4
	w_class = W_CLASS_BULKY
	var/obj/machinery/computer3/luggable/luggable = null
	var/luggable_type = /obj/machinery/computer3/luggable

	New()
		..()
		SPAWN(1 SECOND)
			if(!luggable)
				src.luggable = new luggable_type (src)
				src.luggable.case = src
				src.luggable.deployed = 0
		BLOCK_SETUP(BLOCK_LARGE)
		return

	attack_self(mob/user as mob)
		return deploy(user)

	disposing()
		if (luggable && luggable.loc == src)
			luggable.dispose()
			luggable = null

		..()

	verb/unfold()
		set src in view(1)

		if (usr.stat)
			return

		src.deploy(usr)
		return

	proc/deploy(mob/user as mob)
		var/turf/T = get_turf(src)
		if(!T || !luggable)
			boutput(user, SPAN_ALERT("You can't seem to get the latch open!"))
			return

		if (src.loc == user)
			user.drop_item()
			user.u_equip(src)
		src.luggable.set_loc(T)
		src.luggable.case = src
		src.luggable.deployed = 1
		src.set_loc(src.luggable)
		for (var/obj/item/peripheral/P in src.luggable)
			P.installed(src.luggable)

		user.visible_message("<b>[user]</b> deploys [src.luggable]!","You deploy [src.luggable]!")

/obj/machinery/computer3/luggable
	New()
		..()
		src.cell = new /obj/item/cell(src)
		src.cell.maxcharge = setup_charge_maximum
		src.cell.charge = src.cell.maxcharge
		return

	disposing()
		if (src.cell)
			src.cell.dispose()
			src.cell = null

		if (case && case.loc == src)
			case.dispose()
			case = null

		..()

	verb/fold_up()
		set src in view(1)

		if(usr.stat)
			return

		src.visible_message(SPAN_ALERT("[usr] folds [src] back up!"))
		src.undeploy()
		return

	proc/undeploy()
		if(!src.case)
			src.case = new /obj/item/luggable_computer(src)
			src.case.luggable = src

		for (var/obj/item/peripheral/peripheral in peripherals)
			peripheral.uninstalled()

		src.case.set_loc(get_turf(src))
		src.set_loc(src.case)
		src.deployed = 0
		return

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/disk/data/floppy)) //INSERT SOME DISKETTES
			if ((!src.diskette) && src.setup_has_internal_disk)
				user.drop_item()
				W.set_loc(src)
				src.diskette = W
				boutput(user, "You insert [W].")
				update_static_data(usr)
			else if(src.diskette)
				boutput(user, SPAN_ALERT("There's already a disk inside!"))
			else if(!src.setup_has_internal_disk)
				boutput(user, SPAN_ALERT("There's no visible peripheral device to insert the disk into!"))

		else if (ispryingtool(W))
			if(!src.cell)
				boutput(user, SPAN_ALERT("There is no energy cell inserted!"))
				return

			playsound(src.loc, 'sound/items/Crowbar.ogg', 50, 1)
			src.cell.set_loc(get_turf(src))
			src.cell = null
			user.visible_message(SPAN_ALERT("[user] removes the power cell from [src]!."),SPAN_ALERT("You remove the power cell from [src]!"))
			src.power_change()
			update_static_data(usr)
			return

		else if (istype(W, /obj/item/cell))
			if(src.cell)
				boutput(user, SPAN_ALERT("There is already an energy cell inserted!"))

			else
				user.drop_item()
				W.set_loc(src)
				src.cell = W
				boutput(user, "You insert [W].")
				src.power_change()
				update_static_data(usr)
			return

		else if(istype(W, /obj/item/card/id))
			var/obj/item/peripheral/card_scanner/dv = get_card_scanner()
			if (!dv)
				src.Attackhand(user)
				return

			if (dv.authid)
				boutput(user, SPAN_ALERT("There is already a card inserted!"))
			else
				usr.drop_item()
				W.loc = src
				dv.authid = W
				update_static_data(usr)
			return
		else
			src.Attackhand(user)
		return

	powered()
		if(!src.cell || src.cell.charge <= 0)
			return 0

		return 1

	use_power(var/amount, var/chan=EQUIP)
		if(!src.cell || !src.deployed)
			return

		cell.use(amount / 100)

		src.power_change()
		return



//A personal version!

/obj/item/luggable_computer/personal
	name = "Personal Laptop"
	desc = "This fine piece of hardware sports an incredible 2 kilobytes of RAM, all for a price slightly higher than the whole economy of greece."
	icon_state = "oldlapshut"
	luggable_type = /obj/machinery/computer3/luggable/personal
	w_class = W_CLASS_NORMAL


/obj/machinery/computer3/luggable/personal

	undeploy()
		if(!src.case)
			src.case = new /obj/item/luggable_computer/personal(src)
			src.case.luggable = src

		for (var/obj/item/peripheral/peripheral in peripherals)
			peripheral.uninstalled()

		src.case.set_loc(get_turf(src))
		src.set_loc(src.case)
		src.deployed = 0
		return

#undef MAX_INPUT_HISTORY_LENGTH
