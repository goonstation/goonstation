//The advanced pea-green monochrome lcd of tomorrow.

/obj/item/device/pda2
	name = "PDA"
	desc = "A portable microcomputer by Thinktronic Systems, LTD. Functionality determined by an EEPROM cartridge."
	icon = 'icons/obj/items/pda.dmi'
	icon_state = "pda"
	item_state = "pda"
	w_class = 2.0
	rand_pos = 0
	flags = FPRINT | TABLEPASS | ONBELT
	module_research = list("science" = 1, "miniaturization" = 5, "devices" = 5, "efficiency" = 3)
	module_research_type = /obj/item/device/pda2
	var/obj/item/card/id/ID_card = null // slap an ID card into that thang
	var/registered = null // so we don't need to replace all the dang checks for ID cards
	var/assignment = null
	var/access = list()
	var/image/ID_image = null

	var/owner = null
	var/ownerAssignment = null
	var/obj/item/disk/data/cartridge/cartridge = null //current cartridge
	var/ejectable_cartridge = 1
	var/datum/computer/file/pda_program/active_program = null
	var/datum/computer/file/pda_program/os/host_program = null
	var/datum/computer/file/pda_program/scan/scan_program = null
	var/obj/item/disk/data/fixed_disk/hd = null
	var/closed = 1 //Can we insert a module now?
	var/obj/item/uplink/integrated/pda/uplink = null
	var/obj/item/device/pda_module/module = null
	var/frequency = 1149
	var/bot_freq = 1447 //Bot control frequency
	var/beacon_freq = 1445 //Beacon frequency for locating beacons (I love beacons)
	var/datum/radio_frequency/radio_connection
	var/net_id = null //Hello dude intercepting our radio transmissions, here is a number that is not just \ref

	var/tmp/list/pdasay_autocomplete = list()

	var/bg_color = "6F7961"
	var/link_color = "000000"
	var/linkbg_color = "565D4B"
	var/graphic_mode = 0

	var/setup_default_cartridge = null //Cartridge contains job-specific programs
	var/setup_drive_size = 32 //PDAs don't have much work room at all, really.
	// 2020 zamu update: 24 -> 32
	var/setup_system_os_path = /datum/computer/file/pda_program/os/main_os //Needs an operating system to...operate!!
	var/setup_scanner_on = 1 //Do we search the cart for a scanprog to start loaded?
	var/setup_default_module = /obj/item/device/pda_module/flashlight //Module to have installed on spawn.
	var/mailgroups = list("staff",MGD_PARTY) //What default mail groups the PDA is part of.
	var/muted_mailgroups = list() //What mail groups should the PDA ignore?
	var/reserved_mailgroups = list(MGD_COMMAND,MGD_SECURITY,MGD_SCIENCE,"ai","sillicon",MGD_MEDRESEACH,MGD_MEDBAY ,MGD_CARGO,"janitor",MGD_SPIRITUALAFFAIRS,"engineer","mining",MGD_KITCHEN,"mechanic",MGD_BOTANY,MGD_STATIONREPAIR) //Job-specific mailgroups that cannot be joined or left
	var/bombproof = 0 // can't be destroyed with detomatix
	var/exploding = 0

	registered_owner()
		.= registered


/*
 *	Types of pda, for the different jobs and stuff
 */
/obj/item/device/pda2
	captain
		icon_state = "pda-c"
		setup_default_cartridge = /obj/item/disk/data/cartridge/captain
		setup_drive_size = 32
		mailgroups = list(MGD_COMMAND,MGD_PARTY)

	heads
		icon_state = "pda-h"
		setup_default_cartridge = /obj/item/disk/data/cartridge/head
		setup_drive_size = 32
		mailgroups = list(MGD_COMMAND,MGD_PARTY)

	hos
		icon_state = "pda-hos"
		setup_default_cartridge = /obj/item/disk/data/cartridge/hos
		setup_drive_size = 32
		mailgroups = list(MGD_SECURITY,MGD_COMMAND,MGD_PARTY)

	ai
		icon_state = "pda-h"
		setup_default_cartridge = /obj/item/disk/data/cartridge/ai
		ejectable_cartridge = 0
		setup_drive_size = 1024
		bombproof = 1
		mailgroups = list("ai") //"special" mailgroup, just recieves everything

	cyborg
		icon_state = "pda-h"
		setup_default_cartridge = /obj/item/disk/data/cartridge/cyborg
		ejectable_cartridge = 0
		setup_drive_size = 1024
		bombproof = 1
		mailgroups = list("silicon",MGD_PARTY)

	research_director
		icon_state = "pda-rd"
		setup_default_cartridge = /obj/item/disk/data/cartridge/research_director
		setup_drive_size = 32
		mailgroups = list(MGD_SCIENCE,MGD_COMMAND,MGD_PARTY)

	medical_director
		icon_state = "pda-md"
		setup_default_cartridge = /obj/item/disk/data/cartridge/medical_director
		setup_drive_size = 32
		mailgroups = list(MGD_MEDRESEACH,MGD_MEDBAY ,MGD_COMMAND,MGD_PARTY)

	medical
		icon_state = "pda-m"
		setup_default_cartridge = /obj/item/disk/data/cartridge/medical
		mailgroups = list(MGD_MEDBAY ,MGD_PARTY)

		robotics
			mailgroups = list(MGD_MEDRESEACH,MGD_PARTY)

	genetics
		icon_state = "pda-gen"
		setup_default_cartridge = /obj/item/disk/data/cartridge/genetics
		mailgroups = list(MGD_MEDRESEACH,MGD_PARTY)

	security
		icon_state = "pda-s"
		setup_default_cartridge = /obj/item/disk/data/cartridge/security
		mailgroups = list(MGD_SECURITY,MGD_PARTY)

	forensic
		icon_state = "pda-s"
		setup_default_cartridge = /obj/item/disk/data/cartridge/forensic
		mailgroups = list(MGD_SECURITY,MGD_PARTY)

	toxins
		icon_state = "pda-tox"
		setup_default_cartridge = /obj/item/disk/data/cartridge/toxins
		mailgroups = list(MGD_SCIENCE,MGD_PARTY)

	quartermaster
		icon_state = "pda-q"
		setup_default_cartridge = /obj/item/disk/data/cartridge/quartermaster
		mailgroups = list(MGD_CARGO,MGD_PARTY)

	clown
		icon_state = "pda-clown"
		desc = "A portable microcomputer by Thinktronic Systems, LTD. The surface is coated with polytetrafluoroethylene and banana drippings."
		setup_default_cartridge = /obj/item/disk/data/cartridge/clown
		event_handler_flags = USE_HASENTERED | USE_FLUID_ENTER

		HasEntered(AM as mob|obj) //Clown PDA is slippery.
			if (istype(src.loc, /turf/space))
				return
			if (iscarbon(AM))
				var/mob/M = AM
				if (M.slip(ignore_actual_delay = 1))
					boutput(M, "<span class='notice'>You slipped on the PDA!</span>")
					if (M.bioHolder.HasEffect("clumsy"))
						M.changeStatus("weakened", 5 SECONDS)
						JOB_XP(M, "Clown", 1)

	janitor
		icon_state = "pda-j"
		setup_default_cartridge = /obj/item/disk/data/cartridge/janitor
		mailgroups = list("janitor",MGD_STATIONREPAIR,MGD_PARTY)

	chaplain
		icon_state = "pda-holy"
		mailgroups = list(MGD_SPIRITUALAFFAIRS,MGD_PARTY)

	atmos
		icon_state = "pda-a"
		setup_default_cartridge = /obj/item/disk/data/cartridge/atmos

	engine
		icon_state = "pda-e"
		setup_default_cartridge = /obj/item/disk/data/cartridge/engineer
		mailgroups = list("engineer",MGD_STATIONREPAIR,MGD_PARTY)

	mining
		icon_state = "pda-e"
		mailgroups = list("mining",MGD_PARTY)

	chef
		mailgroups = list(MGD_KITCHEN,MGD_PARTY)

	barman
		mailgroups = list(MGD_KITCHEN,MGD_PARTY)

	mechanic
		icon_state = "pda-a"
		setup_default_module = /obj/item/device/pda_module/tray
		setup_default_cartridge = /obj/item/disk/data/cartridge/mechanic
		mailgroups = list("mechanic",MGD_STATIONREPAIR,MGD_PARTY)

	botanist
		icon_state = "pda-hydro"
		setup_default_cartridge = /obj/item/disk/data/cartridge/botanist
		mailgroups = list(MGD_BOTANY,MGD_PARTY)

	syndicate
		icon_state = "pda-syn"
		name = "Military PDA"
		owner = "John Doe"
		setup_default_cartridge = /obj/item/disk/data/cartridge/nuclear
		setup_system_os_path = /datum/computer/file/pda_program/os/main_os/mess_off

/obj/item/device/pda2/pickup(mob/user)
	..()
	if (src.module)
		src.module.relay_pickup(user)

/obj/item/device/pda2/dropped(mob/user)
	..()
	if (src.module)
		src.module.relay_drop(user)

/obj/item/device/pda2/New()
	..()
	// This should probably be okay before the spawn, this way the HUD ability actually immediately shows up
	if(src.setup_default_module)
		src.module = new src.setup_default_module(src)
	SPAWN_DBG(0.5 SECONDS)
		src.hd = new /obj/item/disk/data/fixed_disk(src)
		src.hd.file_amount = src.setup_drive_size
		src.hd.name = "Minidrive"
		src.hd.title = "Minidrive"

		if(src.setup_system_os_path)
			src.host_program = new src.setup_system_os_path
			src.active_program = src.host_program

			src.hd.file_amount = max(src.hd.file_amount, src.host_program.size)

			src.host_program.transfer_holder(src.hd)

			src.hd.root.add_file(new /datum/computer/file/text/pda2manual)
			src.hd.root.add_file(new /datum/computer/file/pda_program/robustris)
			src.hd.root.add_file(new /datum/computer/file/pda_program/emergency_alert)
			src.hd.root.add_file(new /datum/computer/file/pda_program/cargo_request(src))

		src.net_id = format_net_id("\ref[src]")

		if(radio_controller)
			radio_controller.add_object(src, "[frequency]")

		if (src.setup_default_cartridge)
			src.cartridge = new src.setup_default_cartridge(src)

		if (src.setup_scanner_on && src.cartridge)
			var/datum/computer/file/pda_program/scan/scan = locate() in src.cartridge.root.contents
			if (scan && istype(scan))
				src.scan_program = scan

/obj/item/device/pda2/disposing()
	if (src.cartridge)
		for (var/datum/computer/file/pda_program/P in src.cartridge.root.contents)
			if (P.name == "Packet Sniffer")
				radio_controller.remove_object(src, "[P:scan_freq]")
				continue
			if (P.name == "Ping Tool")
				radio_controller.remove_object(src, "[P:send_freq]")
		src.cartridge.dispose()
		src.cartridge = null

	src.active_program = null
	src.host_program = null
	src.scan_program = null

	if (src.hd)
		for (var/datum/computer/file/pda_program/P in src.hd.root.contents)
			if (P.name == "Packet Sniffer")
				radio_controller.remove_object(src, "[P:scan_freq]")
				continue
			if (P.name == "Ping Tool")
				radio_controller.remove_object(src, "[P:send_freq]")
		src.hd.dispose()
		src.hd = null

	if (src.uplink)
		src.uplink.dispose()
		src.uplink = null

	if (src.module)
		src.module.remove_abilities_from_host()
		src.module.dispose()
		src.module = null

	radio_controller.remove_object(src, "[frequency]")

	if (radio_connection)
		radio_connection.devices -= src
		radio_connection = null

	var/mob/living/ourHolder = src.loc
	if (istype(ourHolder))
		ourHolder.u_equip(src)


	..()

/obj/item/device/pda2/attack_self(mob/user as mob)
	if(!user.literate)
		boutput(user, "<span class='alert'>You don't know how to read, the screen is meaningless to you.</span>")
		return

	src.add_dialog(user)

	var/wincheck = winexists(user, "pda2_\ref[src]")
	//boutput(world, wincheck)
	if(wincheck != "MAIN")
		winclone(user, "pda2", "pda2_\ref[src]")

	var/display_mode = src.graphic_mode
	if(!src.host_program || !owner)
		display_mode = 0

	if (display_mode)
		winset(user, "pda2_\ref[src].texto","is-visible=false")
		winset(user, "pda2_\ref[src].grido","is-visible=true")

		if(src.active_program)
			src.active_program.build_grid(user, "pda2_\ref[src].grido")
		else
			if(src.host_program)
				src.run_program(src.host_program)
				src.active_program.build_grid(user, "pda2_\ref[src].grido")


	else
		winset(user, "pda2_\ref[src].texto","is-visible=true")
		winset(user, "pda2_\ref[src].grido","is-visible=false")

		var/dat = {"<html><head>
		<style type="text/css">
		hr
		{
			color:#000;
			background-color:#000;
			height:2px;
			border-width:0;
		}
		body
		{
			background-color:#[src.bg_color]
		}

		a:link {background-color:#[src.linkbg_color];color:#[src.link_color];text-decoration:none}
		a:visited {background-color:#[src.linkbg_color];color:#[src.bg_color]}
		a:active {background-color:#[src.linkbg_color];color:#[src.bg_color]}
		a:hover {background-color:#[src.link_color];color:#[src.bg_color]}

		</style>
		</head>
		<body vlink='#[src.link_color]' alink='#[src.link_color]'>"}

		dat += "<a href='byond://?src=\ref[src];close=1'>Close</a>"

		if (!src.owner)
			if (src.cartridge && src.ejectable_cartridge)
				dat += " | <a href='byond://?src=\ref[src];eject_cart=1'>Eject [src.cartridge]</a>"
			if (src.ID_card)
				dat += " | <a href='byond://?src=\ref[src];eject_id_card=1'>Eject [src.ID_card]</a>"
			dat += "<br>Warning: No owner information entered.  Please swipe card.<br><br>"
			dat += "<a href='byond://?src=\ref[src];refresh=1'>Retry</a>"
		else
			if (src.active_program)
				dat += src.active_program.return_text()
			else
				if (src.host_program)
					src.run_program(src.host_program)
					dat += src.active_program.return_text()
				else
					if (src.cartridge && src.ejectable_cartridge)
						dat += " | <a href='byond://?src=\ref[src];eject_cart=1'>Eject [src.cartridge]</a><br>"
					if (src.ID_card)
						dat += " | <a href='byond://?src=\ref[src];eject_id_card=1'>Eject [src.ID_card]</a>"
					dat += "<center><font color=red>Fatal Error 0x17<br>"
					dat += "No System Software Loaded</font></center>"

		user << output(dat, "pda2_\ref[src].texto")


	winshow(user,"pda2_\ref[src]",1)

	onclose(user,"pda2_\ref[src]")
	return

/obj/item/device/pda2/Topic(href, href_list)
	..()
	if (usr.contents.Find(src) || usr.contents.Find(src.master) || ((istype(src.loc, /turf) || isAI(usr)) && ( get_dist(src, usr) <= 1 || isAI(usr) )))
		if (usr.stat || usr.restrained())
			return

		src.add_fingerprint(usr)
		src.add_dialog(usr)

		if (href_list["return_to_host"])
			if (src.host_program)
				src.active_program = src.host_program
				src.host_program = null

		else if (href_list["eject_cart"])
			src.eject_cartridge(usr ? usr : null)

		else if (href_list["eject_id_card"])
			src.eject_id_card(usr ? usr : null)

		else if (href_list["refresh"])
			var/obj/item/uplink/integrated/pda/uplink = src.uplink
			if(istype(uplink))
				uplink.refresh()
			src.updateSelfDialog()

		else if (href_list["close"])
			usr.Browse(null, "window=pda2_\ref[src]")
			src.remove_dialog(usr)

		src.updateSelfDialog()
		return

/obj/item/device/pda2/attackby(obj/item/C as obj, mob/user as mob)
	if (istype(uplink,/obj/item/uplink/integrated/pda/spy))
		var/obj/item/uplink/integrated/pda/spy/U = uplink
		if (U.try_deliver(C, user))
			return

	if (istype(C, /obj/item/disk/data/cartridge))
		user.drop_item()
		C.set_loc(src)
		if (isnull(src.cartridge))
			boutput(user, "<span class='notice'>You insert [C] into [src].</span>")
		else
			boutput(user, "<span class='notice'>You remove the old cartridge and insert [C] into [src].</span>")
			user.put_in_hand_or_eject(src.cartridge)
		src.cartridge = C
		src.updateSelfDialog()

	else if (istype(C, /obj/item/device/pda_module))
		if(src.closed)
			boutput(user, "<span class='alert'>The casing is closed!</span>")
			return

		if(src.module)
			boutput(user, "<span class='alert'>There is already a module installed!</span>")
			return

		user.drop_item()
		C.set_loc(src)
		src.module = C
		C:install(src)
		src.updateSelfDialog()
		return

	else if (isscrewingtool(C))
		playsound(user.loc, "sound/items/Screwdriver.ogg", 50, 1)
		src.closed = !src.closed
		boutput(user, "You [src.closed ? "secure" : "unscrew"] the cover.")

	else if (ispryingtool(C))
		if(!module)
			return

		if(src.closed)
			boutput(user, "<span class='alert'>The casing is closed!</span>")
			return

		src.module.set_loc(get_turf(src))
		src.module.uninstall()
		src.module = null
		boutput(user, "You pry the module out.")
		src.updateSelfDialog()

	else if (istype(C, /obj/item/card/id))
		var/obj/item/card/id/ID = C
		if (!ID.registered)
			boutput(user, "<span class='alert'>This ID isn't registered to anyone!</span>")
			return
		if (!src.owner)
			src.owner = ID.registered
			src.ownerAssignment = ID.assignment
			src.name = "PDA-[src.owner]"
			boutput(user, "<span class='notice'>Card scanned.</span>")
			src.updateSelfDialog()
		else
			if (src.ID_card)
				boutput(user, "<span class='notice'>You swap [ID] and [src.ID_card].</span>")
				src.eject_id_card(user)
				src.insert_id_card(ID, user)
				return
			else if (!src.ID_card)
				src.insert_id_card(ID, user)
				boutput(user, "<span class='notice'>You insert [ID] into [src].</span>")

/obj/item/device/pda2/examine()
	. = ..()
	. += "The back cover is [src.closed ? "closed" : "open"]."
	if (src.ID_card)
		. += "[ID_card] has been inserted into it."

/obj/item/device/pda2/receive_signal(datum/signal/signal, rx_method, rx_freq)
	if(!signal || signal.encryption || !src.owner) return

	if(src.host_program)
		src.host_program.network_hook(signal, rx_method, rx_freq)

	if(src.active_program && (src.active_program != src.host_program))
		src.active_program.network_hook(signal, rx_method, rx_freq)


	if(signal.data["address_1"] && signal.data["address_1"] != src.net_id)

		// special programs can receive all signals
		if((signal.data["address_1"] == "ping") && signal.data["sender"])
			var/datum/signal/pingreply = new
			pingreply.source = src
			pingreply.data["device"] = "NET_PDA_51XX"
			pingreply.data["netid"] = src.net_id
			pingreply.data["address_1"] = signal.data["sender"]
			pingreply.data["command"] = "ping_reply"
			pingreply.data["data"] = src.owner
			SPAWN_DBG(0.5 SECONDS)
				src.post_signal(pingreply)

			return

		else if(!src.mailgroups || !(signal.data["group"] in src.mailgroups))
			if (!("ai" in src.mailgroups) || !signal.data["group"])
				return

	if(src.host_program)
		src.host_program.receive_signal(signal, rx_method, rx_freq)

	if(src.active_program && (src.active_program != src.host_program))
		src.active_program.receive_signal(signal, rx_method, rx_freq)

	return

/obj/item/device/pda2/attack(mob/M as mob, mob/user as mob)
	if(src.scan_program)
		return
	else
		..()

/obj/item/device/pda2/afterattack(atom/A as mob|obj|turf|area, mob/user as mob)
	if (istype(uplink,/obj/item/uplink/integrated/pda/spy))
		var/obj/item/uplink/integrated/pda/spy/U = uplink
		var/atom/b_item = U.bounty_is_claimable(A)
		if (b_item)
			actions.start(new/datum/action/bar/private/spy_steal(b_item,U), user)
			return

	var/scan_dat = null
	if (src.scan_program && istype(src.scan_program))
		scan_dat = src.scan_program.scan_atom(A)
	else
		scan_dat = scan_atmospheric(A, visible = 1) // Replaced with global proc (Convair880).

	if(scan_dat)
		A.visible_message("<span class='alert'>[user] has scanned [A]!</span>")
		user.show_message(scan_dat, 1)

	return

/obj/item/device/pda2/MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
	if (istype(uplink,/obj/item/uplink/integrated/pda/spy))
		var/obj/item/uplink/integrated/pda/spy/U = uplink
		var/atom/b_item = U.bounty_is_claimable(O)
		if (b_item)
			actions.start(new/datum/action/bar/private/spy_steal(b_item,U), user)
			return
	..()

/obj/item/device/pda2/process()
	if(src.active_program)
		src.active_program.process()

	else
		if(src.host_program && src.host_program.holder && (src.host_program.holder in src.master.contents))
			src.run_program(src.host_program)
		else
			processing_items.Remove(src)

	return

/obj/item/device/pda2/MouseDrop(atom/over_object, src_location, over_location)
	..()
	if (over_object == usr && src.loc == usr && isliving(usr) && !usr.stat)
		src.attack_self(usr)

/obj/item/device/pda2/verb/pdasay(var/target in pdasay_autocomplete, var/message as text)
	set name = "PDAsay"
	set desc = "Send a PDA message to somebody (You may need to scan for other PDAs first)."
	set category = "Local"
	set src in usr

	if (!target || !message)
		return

	if (usr.getStatusDuration("paralysis") || usr.getStatusDuration("stunned") || usr.getStatusDuration("weakened") || usr.stat)
		return

	if (istype(src.host_program))
		src.host_program.pda_message(pdasay_autocomplete[target], target, message)


/obj/item/device/pda2/verb/eject()
	set name = "Eject ID"
	set desc = "Eject the currently loaded ID card from this PDA."
	set category = "Local"
	set src in usr

	if (usr.getStatusDuration("paralysis") || usr.getStatusDuration("stunned") || usr.getStatusDuration("weakened") || usr.stat)
		return

	eject_id_card(usr)
	src.updateSelfDialog()

/obj/item/device/pda2
	proc/is_user_in_range(var/mob/user)
		return in_range(src, user) || loc == user || isAI(user)

	proc/post_signal(datum/signal/signal,var/newfreq)
		SPAWN_DBG(0)
			LAGCHECK(LAG_REALTIME)
			if(!signal)
				return
			var/freq = newfreq
			if(!freq)
				freq = src.frequency

			signal.source = src
			signal.data["sender"] = src.net_id

			var/datum/radio_frequency/frequency = radio_controller.return_frequency("[freq]")

			signal.transmission_method = TRANSMISSION_RADIO
			if(frequency)
				return frequency.post_signal(src, signal)
			//else
				//qdel(signal)

	proc/eject_cartridge(var/mob/user as mob)
		if (src.cartridge && src.ejectable_cartridge)
			var/turf/T = get_turf(src)

			if(src.active_program && (src.active_program.holder == src.cartridge))
				src.active_program = null

			if(src.host_program && (src.host_program.holder == src.cartridge))
				src.host_program = null

			if(src.scan_program && (src.scan_program.holder == src.cartridge))
				src.scan_program = null

			src.cartridge.set_loc(T)
			if (istype(user))
				user.put_in_hand_or_eject(src.cartridge) // try to eject it into the users hand, if we can
			src.cartridge = null

		return

	proc/eject_id_card(var/mob/user as mob)
		if (src.ID_card)
			src.registered = null
			src.assignment = null
			src.access = null
			src.underlays -= src.ID_image
			if (istype(user))
				user.put_in_hand_or_drop(src.ID_card)
			else
				var/turf/T = get_turf(src)
				src.ID_card.set_loc(T)
			src.ID_card = null
			return

	proc/insert_id_card(var/obj/item/card/id/ID as obj, var/mob/user as mob)
		if (!istype(ID))
			return
		if (src.ID_card)
			src.eject_id_card(istype(user) ? user : null)
		src.ID_card = ID
		if (user)
			user.u_equip(ID)
		ID.set_loc(src)
		src.registered = ID.registered
		src.assignment = ID.assignment
		src.access = ID.access
		if (!src.ID_image)
			src.ID_image = image(src.icon, "blank")
		src.ID_image = src.ID_card.icon_state
		src.underlays += src.ID_image
		src.updateSelfDialog()
		user.UpdateName()
/*
	//Toggle the built-in flashlight
	toggle_light()
		src.fon = (!src.fon)

		if (ismob(src.loc))
			if (src.fon)
				src.loc.sd_SetLuminosity(src.loc.luminosity + src.f_lum)
			else
				src.loc.sd_SetLuminosity(src.loc.luminosity - src.f_lum)
		else
			src.sd_SetLuminosity(src.fon * src.f_lum)

		src.updateSelfDialog()
*/
	proc/display_alert(var/alert_message) //Add alert overlay and beep
		if (alert_message)
			playsound(get_turf(src), "sound/machines/twobeep.ogg", 35, 1)

			for (var/atom in mobs)
				if (!atom) continue
				var/mob/O = atom
				if (get_dist(get_turf(src),O) <= 3)
					O.show_message(text("[bicon(src)] *[alert_message]*"))

			//this one prob sloewr
			//for (var/mob/O in hearers(3, src.loc))

		src.overlays = null
		src.overlays += image('icons/obj/items/pda.dmi', "pda-r")
		return

	proc/display_message(var/message)
		if (ismob(loc))
			var/mob/M = loc
			M.show_message(message)

	proc/run_program(datum/computer/file/pda_program/program)
		if((!program) || (!program.holder))
			return 0

		if(!(program.holder in src))
	//		boutput(world, "Not in src")
			program = new program.type
			program.transfer_holder(src.hd)

		if(program.master != src)
			program.master = src

		if(!src.host_program && istype(program, /datum/computer/file/pda_program/os))
			src.host_program = program

		if(istype(program, /datum/computer/file/pda_program/scan))
			if(program == src.scan_program)
				src.scan_program = null
			else
				src.scan_program = program
			return 1

		src.active_program = program
		program.init()

		if(program.setup_use_process && !(src in processing_items))
			processing_items.Add(src)

		return 1

	proc/unload_active_program()
		if(src.active_program == src.host_program)
			return 1

		if(src.active_program.setup_use_process && !src.host_program.setup_use_process)
			processing_items.Remove(src)

		if(src.host_program && src.host_program.holder && (src.host_program.holder in src.contents))
			src.run_program(src.host_program)
		else
			src.active_program = null

		src.updateSelfDialog()
		return 1

	proc/delete_file(datum/computer/file/theFile)
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

	proc/explode()
		if (src.bombproof)
			if (ismob(src.loc))
				boutput(src.loc, "<span class='alert'><b>ALERT:</b> An attempt to run malicious explosive code on your PDA has been blocked.</span>")
			return

		if(src in bible_contents)
			for(var/obj/item/storage/bible/B in by_type[/obj/item/storage/bible])
				var/turf/T = get_turf(B.loc)
				if(T)
					T.hotspot_expose(700,125)
					explosion(src, T, -1, -1, 2, 3)
			bible_contents.Remove(src)
			qdel(src)
			return

		var/turf/T = get_turf(src.loc)

		if (ismob(src.loc))
			var/mob/M = src.loc
			M.show_message("<span class='alert'>Your [src] explodes!</span>", 1)

		if(T)
			T.hotspot_expose(700,125)

			explosion(src, T, -1, -1, 2, 3)

		if (src.ID_card) //let's not destroy IDs
			ID_card.set_loc(T)

		//dispose()
		//src.dispose()
		qdel(src)
		return

/obj/item/device/pda2/ai/display_message(var/message)
	. = ..(message)
	// The AI might be deployed to shell, in which case we'll relay the message
	if (!isAI(loc))
		return ..()
	var/mob/living/silicon/ai/ai = loc
	if (ai.deployed_to_eyecam)
		ai.eyecam << sound('sound/machines/twobeep.ogg', volume=35)
		ai.eyecam.show_message(message)
	if (ismob(ai.deployed_shell))
		var/mob/M = ai.deployed_shell
		M.show_message(message)

/obj/item/device/pda2/ai/is_user_in_range(var/mob/user)
	if (issilicon(user))
		var/mob/living/silicon/S = user
		if (S.mainframe && S.mainframe == loc)
			return 1
	if (isAIeye(user))
		var/mob/dead/aieye/E = user
		if (E.mainframe)
			return 1
	return ..(user)

/*
 *	PDA 2 ~help file~
 */

/datum/computer/file/text/pda2manual
	name = "Readme"

	data = {"
Thinktronic 5150 Personal Data Assistant Manual<br>
Operating System: ThinkOS 7<hr>
ThinkOS 7 comes with several useful applications built in, these include:<br>
<i><ul>
<li>Notetaker: Load, edit, and save text files just like this one!</li>
<li>Messenger: Send messages between all enabled PDAs.  Can also send the current file in the clipboard.</li>
<li>File Browser: Manage and execute programs in the internal drive or loaded cartridge.</li>
<li>Atmos Scanner: Using patented AirScan technology.</li>
<li>Modules: Light up your life with a flashlight, or see right through the floor with a T-Scanner! The choice is yours!</li>
</ul></i>
<b>To send a file with the messenger:</b><br>
Enter the file browser and copy the file you want to send.  Now enter the messenger and select *send file*.<br>
<br>
ThinkOS 7 supports a wide variety of software solutions, ranging from robot interface systems to forensic and medical scanners.<br>
<font size=1>This technology produced by Thinktronic Systems, LTD for the NanoTrasen Corporation</font>
"}
