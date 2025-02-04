//The advanced pea-green monochrome lcd of tomorrow.

/obj/item/device/pda2
	name = "PDA"
	desc = "A portable microcomputer by Thinktronic Systems, LTD. It has a slot for an ID card, and a hole to put a pen into."
	icon = 'icons/obj/items/pda.dmi'
	icon_state = "pda"
	item_state = "pda"
	w_class = W_CLASS_SMALL
	rand_pos = 0
	c_flags = ONBELT
	wear_layer = MOB_BELT_LAYER
	force = 3
	var/obj/item/card/id/ID_card = null // slap an ID card into that thang
	var/datum/db_record/accessed_record = null // the bank account on the id card
	var/obj/item/pen = null // slap a pen into that thang
	var/registered = null // so we don't need to replace all the dang checks for ID cards
	var/assignment = null
	var/access = list()
	var/image/ID_image = null
	var/owner = null
	var/ownerAssignment = null
	var/obj/item/disk/data/cartridge/cartridge = null //current cartridge
	var/ejectable_cartridge = 1
	var/datum/computer/file/pda_program/active_program = null
	var/datum/computer/file/pda_program/os/main_os/host_program = null
	var/datum/computer/file/pda_program/scan/scan_program = null
	var/datum/computer/file/pda_program/fileshare/fileshare_program = null
	var/obj/item/disk/data/fixed_disk/hd = null
	var/closed = 1 //Can we insert a module now?
	var/obj/item/uplink/integrated/pda/uplink = null
	var/obj/item/device/pda_module/module = null
	var/frequency = FREQ_PDA
	var/beacon_freq = FREQ_NAVBEACON //Beacon frequency for locating beacons (I love beacons)
	var/net_id = null //Hello dude intercepting our radio transmissions, here is a number that is not just \ref
	var/scannable = TRUE // Whether this PDA is picked up when scanning for PDAs on the messenger

	var/tmp/list/pdasay_autocomplete = list()

	var/tmp/list/image/overlay_images = null
	var/tmp/current_overlay = "idle"

	var/bg_color = "#6F7961"
	var/link_color = "#000000"
	var/linkbg_color = "#565D4B"
	///is the background colour of this PDA locked due to annoying propreitary software
	var/locked_bg_color = FALSE
	var/graphic_mode = 0

	var/screen_x = 0
	var/screen_y = 0

	var/setup_default_pen = /obj/item/pen //PDAs can contain writing implements by default
	var/setup_default_cartridge = null //Cartridge contains job-specific programs
	var/setup_drive_size = 32 //PDAs don't have much work room at all, really.
	// 2020 zamu update: 24 -> 32
	var/setup_system_os_path = /datum/computer/file/pda_program/os/main_os //Needs an operating system to...operate!!
	var/setup_scanner_on = 1 //Do we search the cart for a scanprog to start loaded?
	var/setup_default_module = /obj/item/device/pda_module/flashlight //Module to have installed on spawn.
	var/mailgroups = list(MGO_STAFF,MGD_PARTY) //What default mail groups the PDA is part of.
	var/default_muted_mailgroups = list() //What mail groups should the PDA ignore by default
	var/reserved_mailgroups = list( // Job-specific mailgroups that cannot be joined or left
		// Departments
		MGD_COMMAND, MGD_SECURITY, MGD_MEDBAY, MGD_MEDRESEACH, MGD_SCIENCE, MGD_CARGO, MGD_STATIONREPAIR, MGD_BOTANY, MGD_MINING, MGD_KITCHEN, MGD_SPIRITUALAFFAIRS,
		// Other
		MGO_STAFF, MGO_AI, MGO_SILICON, MGO_JANITOR, MGO_ENGINEER,
		// Alerts
		MGA_MAIL, MGA_RADIO, MGA_CHECKPOINT, MGA_ARREST, MGA_DEATH, MGA_MEDCRIT, MGA_CLONER, MGA_ENGINE, MGA_RKIT, MGA_SALES, MGA_SHIPPING, MGA_CARGOREQUEST, MGA_CRISIS, MGA_TRACKING, MGA_SYNDICATE
	)
	var/alertgroups = list(MGA_MAIL, MGA_RADIO) // What mail groups that we're not a member of should we be able to mute?
	var/bombproof = 0 // can't be destroyed with detomatix
	var/exploding = 0
	/// Syndie sound programs can blow out the speakers and render it forever *silent*
	var/speaker_busted = 0

	/// The PDA's currently loaded ringtone set
	var/datum/ringtone/r_tone = /datum/ringtone
	/// A temporary ringtone set for preview purposed
	var/datum/ringtone/r_tone_temp
	/// A list of ringtones tied to an alert -- Overrides whatever settings set for their mailgroup. Typically remains static in length
	var/list/alert_ringtones = list(MGA_MAIL = null,\
																	MGA_CHECKPOINT = null,\
																	MGA_ARREST = null,\
																	MGA_DEATH = null,\
																	MGA_MEDCRIT = null,\
																	MGA_CLONER = null,\
																	MGA_ENGINE = null,\
																	MGA_RKIT = null,\
																	MGA_SALES = null,\
																	MGA_SHIPPING = null,\
																	MGA_CARGOREQUEST = null,\
																	MGA_CRISIS = null,\
																	MGA_RADIO = null)

	/// mailgroup-specific ringtones, added on the fly!
	var/list/mailgroup_ringtones = list()
	var/window_title = "Personal Data Assistant"

	registered_owner()
		.= registered


/*
 *	Types of pda, for the different jobs and stuff
 */
/obj/item/device/pda2
	captain
		icon_state = "pda-c"
		setup_default_pen = /obj/item/pen/fancy
		setup_default_cartridge = /obj/item/disk/data/cartridge/captain
		setup_drive_size = 32
		mailgroups = list(MGD_COMMAND,MGD_PARTY)

	heads
		icon_state = "pda-h"
		setup_default_pen = /obj/item/pen/fancy
		setup_default_cartridge = /obj/item/disk/data/cartridge/head
		setup_drive_size = 32
		mailgroups = list(MGD_COMMAND,MGD_PARTY)

	hop
		icon_state = "pda-hop"
		setup_default_pen = /obj/item/pen/fancy
		setup_default_cartridge = /obj/item/disk/data/cartridge/hop
		setup_drive_size = 32
		mailgroups = list(MGD_COMMAND,MGD_PARTY)

	hos
		icon_state = "pda-hos"
		setup_default_pen = /obj/item/pen/fancy
		setup_default_cartridge = /obj/item/disk/data/cartridge/hos
		setup_default_module = /obj/item/device/pda_module/alert
		setup_drive_size = 32
		mailgroups = list(MGD_SECURITY,MGD_COMMAND,MGD_PARTY)
		alertgroups = list(MGA_MAIL, MGA_RADIO, MGA_CHECKPOINT, MGA_ARREST, MGA_DEATH, MGA_CRISIS, MGA_TRACKING)

	ntso
		icon_state = "pda-nt"
		setup_default_pen = /obj/item/pen/fancy
		setup_default_cartridge = /obj/item/disk/data/cartridge/hos //hos cart gives access to manifest compared to regular sec cart, useful for NTSO
		setup_default_module = /obj/item/device/pda_module/alert
		setup_drive_size = 32
		mailgroups = list(MGD_SECURITY,MGD_COMMAND,MGD_PARTY)
		alertgroups = list(MGA_MAIL, MGA_RADIO, MGA_CHECKPOINT, MGA_ARREST, MGA_DEATH, MGA_CRISIS, MGA_TRACKING)


	ntofficial
		icon_state = "pda-nt"
		setup_default_pen = /obj/item/pen/fancy
		setup_default_cartridge = /obj/item/disk/data/cartridge/head
		setup_drive_size = 32
		mailgroups = list(MGD_COMMAND,MGD_PARTY)

	nt_medical
		icon_state = "pda-nt"
		setup_default_pen = /obj/item/pen/fancy
		setup_default_cartridge = /obj/item/disk/data/cartridge/medical_director
		setup_drive_size = 32
		mailgroups = list(MGD_MEDBAY,MGD_COMMAND,MGD_PARTY)
		alertgroups = list(MGA_MAIL, MGA_RADIO, MGA_DEATH, MGA_MEDCRIT, MGA_CLONER, MGA_CRISIS)

	nt_engineer
		icon_state = "pda-nt"
		setup_default_cartridge = /obj/item/disk/data/cartridge/chiefengineer
		setup_default_module = /obj/item/device/pda_module/tray
		mailgroups = list(MGO_ENGINEER,MGD_STATIONREPAIR,MGD_CARGO,MGD_COMMAND,MGD_PARTY)
		alertgroups = list(MGA_MAIL, MGA_RADIO, MGA_ENGINE, MGA_CRISIS, MGA_RKIT)


	ai
		icon_state = "pda-h"
		setup_default_pen = null // ai don't need no pens
		setup_default_cartridge = /obj/item/disk/data/cartridge/ai
		ejectable_cartridge = 0
		setup_drive_size = 1024
		bombproof = 1
		mailgroups = list( // keep in sync with the list of reserved mail groups
			// Departments
			MGD_COMMAND, MGD_SECURITY, MGD_MEDBAY, MGD_MEDRESEACH, MGD_SCIENCE, MGD_CARGO, MGD_MINING, MGD_STATIONREPAIR, MGD_BOTANY, MGD_KITCHEN, MGD_SPIRITUALAFFAIRS,
			// Other
			MGO_STAFF, MGO_AI, MGO_SILICON, MGO_JANITOR, MGO_ENGINEER,
			// start in party line by default
			MGD_PARTY,
		)
		default_muted_mailgroups = list(MGA_MAIL, MGA_SALES, MGA_SHIPPING, MGA_CARGOREQUEST, MGA_RKIT)
		alertgroups = list(MGA_MAIL, MGA_RADIO, MGA_CHECKPOINT, MGA_ARREST, MGA_DEATH, MGA_MEDCRIT, MGA_CLONER, MGA_ENGINE, MGA_RKIT, MGA_SALES, MGA_SHIPPING, MGA_CARGOREQUEST, MGA_CRISIS) // keep in sync with the list of mail alert groups

	cyborg
		icon_state = "pda-h"
		setup_default_pen = null // you don't even have hands
		setup_default_cartridge = /obj/item/disk/data/cartridge/cyborg
		ejectable_cartridge = 0
		setup_drive_size = 1024
		bombproof = 1
		mailgroups = list(MGO_SILICON,MGD_PARTY)
		alertgroups = list(MGA_MAIL, MGA_RADIO, MGA_DEATH)
		default_muted_mailgroups = list(MGA_RKIT)

	research_director
		icon_state = "pda-rd"
		setup_default_pen = /obj/item/pen/fancy
		setup_default_cartridge = /obj/item/disk/data/cartridge/research_director
		setup_drive_size = 32
		mailgroups = list(MGD_SCIENCE,MGD_COMMAND,MGD_PARTY)

	medical_director
		icon_state = "pda-md"
		setup_default_pen = /obj/item/pen/fancy
		setup_default_cartridge = /obj/item/disk/data/cartridge/medical_director
		setup_drive_size = 32
		mailgroups = list(MGD_MEDRESEACH,MGD_MEDBAY,MGD_COMMAND,MGD_PARTY)
		alertgroups = list(MGA_MAIL, MGA_RADIO, MGA_DEATH, MGA_MEDCRIT, MGA_CLONER, MGA_CRISIS)

	medical
		name = "Medical PDA"
		icon_state = "pda-m"
		setup_default_cartridge = /obj/item/disk/data/cartridge/medical
		mailgroups = list(MGD_MEDBAY ,MGD_PARTY)
		alertgroups = list(MGA_MAIL, MGA_RADIO, MGA_DEATH, MGA_MEDCRIT, MGA_CLONER, MGA_CRISIS)

		robotics
			name = "Robotics PDA"
			mailgroups = list(MGD_MEDRESEACH,MGD_PARTY, MGO_SILICON)
			alertgroups = list(MGA_MAIL, MGA_RADIO, MGA_DEATH, MGA_MEDCRIT, MGA_CLONER, MGA_CRISIS, MGA_SALES)
			default_muted_mailgroups = list(MGA_SALES)

	genetics
		name = "Genetics PDA"
		icon_state = "pda-gen"
		setup_default_cartridge = /obj/item/disk/data/cartridge/genetics
		mailgroups = list(MGD_MEDBAY,MGD_MEDRESEACH,MGD_PARTY)
		alertgroups = list(MGA_MAIL, MGA_RADIO, MGA_SALES)

	security
		name = "Security PDA"
		icon_state = "pda-s"
		setup_default_cartridge = /obj/item/disk/data/cartridge/security
		setup_default_module = /obj/item/device/pda_module/alert
		mailgroups = list(MGD_SECURITY,MGD_PARTY)
		alertgroups = list(MGA_MAIL, MGA_RADIO, MGA_CHECKPOINT, MGA_ARREST, MGA_DEATH, MGA_CRISIS, MGA_TRACKING)

	forensic
		name = "Forensic PDA"
		icon_state = "pda-s"
		setup_default_pen = /obj/item/clothing/mask/cigarette
		setup_default_cartridge = /obj/item/disk/data/cartridge/forensic
		mailgroups = list(MGD_SECURITY,MGD_PARTY)
		alertgroups = list(MGA_MAIL, MGA_RADIO, MGA_CHECKPOINT, MGA_ARREST, MGA_DEATH, MGA_CRISIS, MGA_TRACKING)

	toxins
		icon_state = "pda-tox"
		setup_default_cartridge = /obj/item/disk/data/cartridge/toxins
		mailgroups = list(MGD_SCIENCE,MGD_PARTY)

	quartermaster
		name = "Quartermaster PDA"
		icon_state = "pda-q"
		setup_default_cartridge = /obj/item/disk/data/cartridge/quartermaster
		mailgroups = list(MGD_CARGO,MGD_PARTY)
		alertgroups = list(MGA_MAIL, MGA_RADIO, MGA_SALES, MGA_SHIPPING, MGA_CARGOREQUEST)

	clown
		icon_state = "pda-clown"
		desc = "A portable microcomputer by Thinktronic Systems, LTD. The surface is coated with polytetrafluoroethylene and banana drippings."
		setup_default_pen = /obj/item/pen/crayon/random
		setup_default_cartridge = /obj/item/disk/data/cartridge/clown
		event_handler_flags = USE_FLUID_ENTER

		proc/on_mob_throw_end(mob/M)
			UnregisterSignal(M, COMSIG_MOVABLE_THROW_END)
			LAZYLISTREMOVE(M.attached_objs, src)
			src.glide_size = initial(src.glide_size)

		Crossed(atom/movable/AM)
			..()
			if (istype(src.loc, /turf/space))
				return
			if (iscarbon(AM))
				var/mob/M = AM
				LAZYLISTADDUNIQUE(M.attached_objs, src)
				src.glide_size = M.glide_size
				RegisterSignal(M, COMSIG_MOVABLE_THROW_END, PROC_REF(on_mob_throw_end))
				if (M.slip(walking_matters = 1, ignore_actual_delay = 1, throw_type = THROW_PEEL_SLIP, params = list("slip_obj" = src)))
					boutput(M, SPAN_NOTICE("You slipped on the PDA!"))
					if (M.bioHolder.HasEffect("clumsy"))
						M.changeStatus("knockdown", 5 SECONDS)
						JOB_XP(M, "Clown", 1)
				else
					src.on_mob_throw_end(M)

	janitor
		icon_state = "pda-j"
		setup_default_cartridge = /obj/item/disk/data/cartridge/janitor
		mailgroups = list(MGO_JANITOR,MGD_STATIONREPAIR,MGD_PARTY)

	chaplain
		icon_state = "pda-holy"
		mailgroups = list(MGD_SPIRITUALAFFAIRS,MGD_PARTY)
		alertgroups = list(MGA_MAIL, MGA_RADIO, MGA_DEATH, MGA_MEDCRIT)

	atmos
		name = "Atmos PDA"
		icon_state = "pda-a"
		setup_default_cartridge = /obj/item/disk/data/cartridge/atmos

	engine
		name = "Engineer PDA"
		icon_state = "pda-e"
		setup_default_cartridge = /obj/item/disk/data/cartridge/engineer
		setup_default_module = /obj/item/device/pda_module/tray //mechanics used to have these
		mailgroups = list(MGO_ENGINEER,MGD_STATIONREPAIR,MGD_PARTY)
		alertgroups = list(MGA_MAIL, MGA_RADIO, MGA_ENGINE, MGA_RKIT, MGA_CRISIS)

	technical_assistant
		name = "Technical Assistant PDA"
		icon_state = "pda-e" //tech ass is too broad to have a set cartridge but should get alerts
		mailgroups = list(MGD_STATIONREPAIR,MGD_PARTY)
		setup_default_module = /obj/item/device/pda_module/tray
		alertgroups = list(MGA_MAIL,MGA_RADIO)

	mining
		name = "Mining PDA"
		icon_state = "pda-q"
		setup_default_cartridge = /obj/item/disk/data/cartridge/miner
		mailgroups = list(MGD_MINING,MGD_PARTY)
		alertgroups = list(MGA_MAIL, MGA_RADIO, MGA_SALES)

	chiefengineer
		icon_state = "pda-ce"
		setup_default_cartridge = /obj/item/disk/data/cartridge/chiefengineer
		setup_default_module = /obj/item/device/pda_module/tray
		mailgroups = list(MGO_ENGINEER,MGD_MINING,MGD_STATIONREPAIR,MGD_CARGO,MGD_COMMAND,MGD_PARTY)
		alertgroups = list(MGA_MAIL, MGA_RADIO, MGA_ENGINE, MGA_CRISIS, MGA_SALES, MGA_CARGOREQUEST, MGA_SHIPPING, MGA_RKIT)

	chef
		mailgroups = list(MGD_KITCHEN,MGD_PARTY)

	bartender
		setup_default_cartridge = /obj/item/disk/data/cartridge/bartender
		mailgroups = list(MGD_KITCHEN,MGD_PARTY)

	botanist
		icon_state = "pda-hydro"
		setup_default_cartridge = /obj/item/disk/data/cartridge/botanist
		mailgroups = list(MGD_BOTANY,MGD_PARTY)

	syndicate
		icon_state = "pda-syn"
		name = "Military PDA"
		desc = "A cheap knockoff looking portable microcomputer claiming to be made by ElecTek LTD. It has a slot for an ID card, and a hole to put a pen into."
		setup_system_os_path = /datum/computer/file/pda_program/os/main_os/knockoff
		mailgroups = list(MGA_SYNDICATE)
		locked_bg_color = TRUE
		bg_color = "#A33131"
		r_tone = /datum/ringtone/basic/ring10
		screen_x = 2
		window_title = "Personnel Data Actuator"

		nuclear
			owner = "John Doe"
			setup_system_os_path = /datum/computer/file/pda_program/os/main_os/knockoff/mess_off
			setup_default_cartridge = /obj/item/disk/data/cartridge/nuclear

			New()
				START_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)
				..()

			disposing()
				STOP_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)
				..()

		New()
			..()
			var/datum/computer/file/text/pda2manual/old_manual = locate() in src.hd.root.contents
			src.hd.root.remove_file(old_manual)
			var/datum/computer/file/pda_program/emergency_alert/crisis = locate() in src.hd.root.contents
			src.hd.root.remove_file(crisis)
			src.hd.root.add_file(new /datum/computer/file/text/pda2manual/knockoff)


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
	START_TRACKING
	// This should probably be okay before the spawn, this way the HUD ability actually immediately shows up
	if(src.setup_default_module)
		src.module = new src.setup_default_module(src)
	var/mob/M = src.loc
	if(ispath(src.r_tone))
		src.r_tone = new r_tone(src)

	if(istype(M) && M.client && !src.locked_bg_color)
		src.bg_color = M.client.preferences.PDAcolor

	var/list/color_vals = hex_to_rgb_list(src.bg_color)
	src.linkbg_color = rgb(color_vals[1] * 0.8, color_vals[2] * 0.8, color_vals[3] * 0.8)
	src.update_colors(src.bg_color, src.linkbg_color)

	src.hd = new /obj/item/disk/data/fixed_disk(src)
	src.hd.file_amount = src.setup_drive_size
	src.hd.name = "Minidrive"
	src.hd.title = "Minidrive"

	if(src.setup_system_os_path)
		src.set_host_program(new src.setup_system_os_path)
		src.set_active_program(src.host_program)

		src.hd.file_amount = max(src.hd.file_amount, src.host_program.size)

		src.host_program.transfer_holder(src.hd)

		src.hd.root.add_file(new /datum/computer/file/text/pda2manual)
		src.hd.root.add_file(new /datum/computer/file/pda_program/robustris)
		src.hd.root.add_file(new /datum/computer/file/pda_program/emergency_alert)
		src.hd.root.add_file(new /datum/computer/file/pda_program/gps)
		src.hd.root.add_file(new /datum/computer/file/pda_program/cargo_request(src))
		if(length(src.default_muted_mailgroups))
			src.host_program.muted_mailgroups = src.default_muted_mailgroups
		if(ismob(src.loc))
			var/mob/mob = src.loc
			get_all_character_setup_ringtones()

			if(mob.client && (mob.client.preferences.pda_ringtone_index in selectable_ringtones) && mob.client?.preferences.pda_ringtone_index != "Two-Beep")
				src.set_ringtone(selectable_ringtones[mob.client.preferences.pda_ringtone_index], FALSE, FALSE, "main", null, FALSE)
				var/rtone_program = src.ringtone2program(src.r_tone)
				if(rtone_program)
					src.hd.root.add_file(new rtone_program)

	src.net_id = format_net_id("\ref[src]")

	if (src.setup_default_pen)
		src.pen = new src.setup_default_pen(src)
		if(istype(src.pen, /obj/item/clothing/mask/cigarette))
			src.UpdateOverlays(image(src.icon, "cig"), "pen")
		else if(istype(src.pen, /obj/item/pen/crayon))
			var/image/pen_overlay = image(src.icon, "crayon")
			pen_overlay.color = pen.color
			src.UpdateOverlays(pen_overlay, "pen")
		else if(istype(src.pen, /obj/item/pen/pencil))
			src.UpdateOverlays(image(src.icon, "pencil"), "pen")
		else
			src.UpdateOverlays(image(src.icon, "pen"), "pen")

	if (src.setup_default_cartridge)
		src.cartridge = new src.setup_default_cartridge(src)

	if (src.setup_scanner_on && src.cartridge)
		var/datum/computer/file/pda_program/scan/scan = locate() in src.cartridge.root.contents
		if (istype(scan))
			src.set_scan_program(scan)

/obj/item/device/pda2/disposing()
	STOP_TRACKING
	if (src.cartridge)
		src.cartridge.dispose()
		src.cartridge = null

	src.set_active_program(null)
	src.set_host_program(null)
	src.set_scan_program(null)
	qdel(src.r_tone)
	qdel(src.r_tone_temp)
	src.r_tone = null
	src.r_tone_temp = null
	for(var/R in src.mailgroup_ringtones)
		if(src.mailgroup_ringtones[R])
			qdel(src.mailgroup_ringtones[R])
			src.mailgroup_ringtones[R] = null

	for(var/T in src.alert_ringtones)
		if(src.alert_ringtones[T])
			qdel(src.alert_ringtones[T])
			src.alert_ringtones[T] = null

	if (src.pen)
		qdel(src.pen)
		src.pen = null

	if (src.hd)
		src.hd.dispose()
		src.hd = null

	if (src.uplink)
		src.uplink.dispose()
		src.uplink = null

	if (src.module)
		src.module.remove_abilities_from_host()
		src.module.dispose()
		src.module = null

	var/mob/living/ourHolder = src.loc
	if (istype(ourHolder))
		ourHolder.u_equip(src)


	..()

/obj/item/device/pda2/attack_self(mob/user as mob)
	if(!user.client)
		return
	if(!user.literate)
		boutput(user, SPAN_ALERT("You don't know how to read, the screen is meaningless to you."))
		return

	src.add_dialog(user)

	var/wincheck = winexists(user, "pda2_\ref[src]")
	//boutput(world, wincheck)
	if(wincheck != "MAIN")
		winclone(user, "pda2", "pda2_\ref[src]")
	winset(user, "pda2_\ref[src]", "title=\"[src.window_title]\"")
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

		var/dat = {"<!doctype html>
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
	<style type='text/css'>
		hr {
			color:#000;
			background-color:#000;
			height:2px;
			border-width:0;
		}
		h1,h2,h3,h4,h5,h6 { margin: 0.5em 0; padding: 0; }
		ul, ol { margin: 0.5em; }
		body {
			background-color: [src.bg_color];
			color: [src.link_color];
			font-family: Tahoma, sans-serif;
			font-size: [(user?.client?.preferences && user?.client?.preferences.font_size) ? "[user?.client?.preferences.font_size]%" : "10pt"];
;
		}
		a {
			background-color: [src.linkbg_color];
			color: [src.link_color];
			text-decoration: none;
			padding: 0.0em 0.2em;
		}
		a:hover   { background-color: [src.link_color];   color: [src.bg_color]; }

	</style>
	<script>
		function updateScroll() {window.name = document.documentElement.scrollTop || document.body.scrollTop;}
		window.addEventListener("beforeunload", updateScroll);
		window.addEventListener("scroll", updateScroll);
		window.addEventListener("load", function() {document.documentElement.scrollTop = document.body.scrollTop = window.name;});
	</script>
</head>
<body>"}

		// you can just use the windows close button for this...
		// dat += "<a href='byond://?src=\ref[src];close=1'>Close</a>"

		if (!src.owner)
			if (src.cartridge && src.ejectable_cartridge)
				dat += "<a href='byond://?src=\ref[src];eject_cart=1'>Eject [stripTextMacros(src.cartridge.name)]</a><br>"
			if (src.ID_card)
				dat += "<a href='byond://?src=\ref[src];eject_id_card=1'>Eject [src.ID_card]</a><br>"
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
						dat += "<a href='byond://?src=\ref[src];eject_cart=1'>Eject [stripTextMacros(src.cartridge.name)]</a><br>"
					if (src.ID_card)
						dat += "<a href='byond://?src=\ref[src];eject_id_card=1'>Eject [src.ID_card]</a><br>"
					dat += "<center><font color=red>Fatal Error 0x17<br>"
					dat += "No System Software Loaded</font></center>"

		user.Browse(dat, "window=pda2_\ref[src].texto")


	winshow(user,"pda2_\ref[src]",1)

	onclose(user,"pda2_\ref[src]")
	return

/obj/item/device/pda2/Topic(href, href_list)
	..()
	if (usr.contents.Find(src) || usr.contents.Find(src.master) || ((istype(src.loc, /turf) || isAI(usr)) && ( BOUNDS_DIST(src, usr) == 0 || isAI(usr) )))
		if(!can_act(usr))
			return

		src.add_fingerprint(usr)
		src.add_dialog(usr)

		if (href_list["eject_cart"])
			src.eject_cartridge(usr ? usr : null)

		else if (href_list["eject_id_card"])
			src.eject_id_card(usr ? usr : null)

		else if (href_list["eject_cash"])
			src.eject_cash(usr ? usr : null)

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

/obj/item/device/pda2/attackby(obj/item/C, mob/user)
	if (istype(C, /obj/item/disk/data/cartridge))
		user.drop_item()
		C.set_loc(src)
		if (isnull(src.cartridge))
			boutput(user, SPAN_NOTICE("You insert [C] into [src]."))
		else
			boutput(user, SPAN_NOTICE("You remove the old cartridge and insert [C] into [src]."))
			user.put_in_hand_or_eject(src.cartridge)
		src.cartridge = C
		src.updateSelfDialog()

	else if (istype(C, /obj/item/device/pda_module))
		if(src.closed)
			boutput(user, SPAN_ALERT("The casing is closed!"))
			return

		if(src.module)
			boutput(user, SPAN_ALERT("There is already a module installed!"))
			return

		user.drop_item()
		C.set_loc(src)
		src.module = C
		C:install(src)
		src.updateSelfDialog()
		return

	else if (isscrewingtool(C))
		playsound(user.loc, 'sound/items/Screwdriver.ogg', 50, 1)
		src.closed = !src.closed
		boutput(user, "You [src.closed ? "secure" : "unscrew"] the cover.")

	else if (ispryingtool(C))
		if(!module)
			return

		if(src.closed)
			boutput(user, SPAN_ALERT("The casing is closed!"))
			return

		src.module.set_loc(get_turf(src))
		src.module.uninstall()
		src.module = null
		boutput(user, "You pry the module out.")
		src.updateSelfDialog()

	else if (istype(C, /obj/item/card/id))
		var/obj/item/card/id/ID = C
		if (!ID.registered)
			boutput(user, SPAN_ALERT("This ID isn't registered to anyone!"))
			return
		if (!src.owner)
			src.owner = ID.registered
			src.ownerAssignment = ID.assignment
			src.name = "PDA-[src.owner]"
			boutput(user, SPAN_NOTICE("Card scanned."))
			src.updateSelfDialog()
		else
			if (src.ID_card)
				if (IS_WORN_BY_SOMEONE_OTHER_THAN(src, user))
					boutput(user, SPAN_ALERT("There's already an ID card in [src]."))
					return
				boutput(user, SPAN_NOTICE("You swap [ID] and [src.ID_card]."))
				src.eject_id_card(user)
				src.insert_id_card(ID, user)
				return
			else if (!src.ID_card)
				src.insert_id_card(ID, user)
				boutput(user, SPAN_NOTICE("You insert [ID] into [src]."))

	else if (istype(C, /obj/item/uplink_telecrystal))
		if (src.uplink && src.uplink.active)
			var/crystal_amount = C.amount
			src.uplink.uses = src.uplink.uses + crystal_amount
			boutput(user, "You insert [crystal_amount] [syndicate_currency] into the [src].")
			qdel(C)

	else if (istype(C, /obj/item/explosive_uplink_telecrystal))
		if (src.uplink && src.uplink.active)
			boutput(user, SPAN_ALERT("The [C] explodes!"))
			var/turf/T = get_turf(C.loc)
			if(T)
				T.hotspot_expose(700,125)
				explosion(C, T, -1, -1, 2, 3) //about equal to a PDA bomb
			C.set_loc(user.loc)
			qdel(C)

	else if (istype(C, /obj/item/pen) || istype(C, /obj/item/clothing/mask/cigarette) || istype(C, /obj/item/device/light/flashlight/penlight))
		if (!src.pen)
			src.insert_pen(C, user)
		else
			boutput(user, SPAN_ALERT("There is already something in [src]'s pen slot!"))

	else if (istype(C, /obj/item/currency/spacecash))
		src.insert_cash(C, user)

/obj/item/device/pda2/examine()
	. = ..()
	. += "The back cover is [src.closed ? "closed" : "open"]."
	if (src.ID_card)
		. += "[ID_card] has been inserted into it."
	if (src.pen)
		. += "[pen] is sticking out of the pen slot."

/obj/item/device/pda2/attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
	if(src.scan_program)
		return
	else
		..()

/obj/item/device/pda2/afterattack(atom/A as mob|obj|turf|area, mob/user as mob)
	var/scan_dat = null
	if (src.scan_program && istype(src.scan_program))
		scan_dat = src.scan_program.scan_atom(A)
	else
		scan_dat = scan_atmospheric(A, visible = 1) // Replaced with global proc (Convair880).

	if(scan_dat)
		A.visible_message(SPAN_ALERT("[user] has scanned [A]!"))
		user.show_message(scan_dat, 1)

	return

/obj/item/device/pda2/MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
	if (istype(uplink,/obj/item/uplink/integrated/pda/spy))
		var/obj/item/uplink/integrated/pda/spy/U = uplink
		var/datum/bounty_claim/claim = U.bounty_is_claimable(O, user)
		if (claim)
			actions.start(new/datum/action/bar/private/spy_steal(claim.delivery, U), user)
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

/obj/item/device/pda2/mouse_drop(atom/over_object, src_location, over_location)
	..()
	if (over_object == usr && src.loc == usr && isliving(usr) && !usr.stat)
		src.AttackSelf(usr)

/obj/item/device/pda2/verb/pdasay(var/target in pdasay_autocomplete, var/message as text)
	set name = "PDAsay"
	set desc = "Send a PDA message to somebody (You may need to scan for other PDAs first)."
	set category = "Local"
	set src in usr

	if (!target || !message)
		return

	if (!can_act(usr))
		return

	if (istype(src.host_program))
		src.host_program.pda_message(pdasay_autocomplete[target], target, message)


/obj/item/device/pda2/verb/eject()
	set name = "Eject PDA ID"
	set desc = "Eject the currently loaded ID card from this PDA."
	set category = "Local"
	set src in usr

	if (is_incapacitated(usr))
		return

	eject_id_card(usr)
	src.updateSelfDialog()

/obj/item/device/pda2/verb/ejectPen()
	set name = "Eject Pen"
	set desc = "Eject the currently loaded writing utensil from this PDA."
	set category = "Local"
	set src in usr

	if (is_incapacitated(usr))
		return

	eject_pen(usr)
	src.updateSelfDialog()

/obj/item/device/pda2

	proc/update_colors(bg, linkbg)
		src.bg_color = bg
		src.linkbg_color = linkbg
		var/color_list = hex_to_rgb_list(src.linkbg_color)
		if(max(color_list[1], color_list[2], color_list[3]) <= 50)
			src.link_color = "#dddddd"
		else
			src.link_color = initial(src.link_color)

		if (!overlay_images)
			src.overlay_images = list()
			overlay_images["idle"] = image('icons/obj/items/pda.dmi', "screen-idle", pixel_x = src.screen_x, pixel_y = src.screen_y)
			overlay_images["alert"] = image('icons/obj/items/pda.dmi', "screen-message", pixel_x = src.screen_x, pixel_y = src.screen_y)

		for (var/k in src.overlay_images)
			src.overlay_images[k].color = bg

		src.update_overlay()

	proc/set_active_program(datum/computer/file/pda_program/program)
		src.active_program?.on_deactivated(src)
		src.active_program = program
		src.active_program?.on_activated(src)

	proc/set_host_program(datum/computer/file/pda_program/program)
		src.host_program?.on_unset_host(src)
		src.host_program = program
		src.host_program?.on_set_host(src)

	proc/set_scan_program(datum/computer/file/pda_program/program)
		src.scan_program?.on_unset_scan(src)
		src.scan_program = program
		src.scan_program?.on_set_scan(src)

	proc/is_user_in_interact_range(var/mob/user)
		return in_interact_range(src, user) || loc == user || isAI(user)

	proc/post_signal(datum/signal/signal,var/newfreq)
		if(!signal)
			return
		var/freq = newfreq
		if(!freq)
			freq = src.frequency

		signal.source = src
		signal.data["sender"] = src.net_id

		SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, signal, null, freq)

	proc/eject_cartridge(var/mob/user as mob)
		if (src.cartridge && src.ejectable_cartridge)
			var/turf/T = get_turf(src)

			if(src.active_program && (src.active_program.holder == src.cartridge))
				src.set_active_program(null)

			if(src.host_program && (src.host_program.holder == src.cartridge))
				src.set_host_program(null)

			if(src.scan_program && (src.scan_program.holder == src.cartridge))
				src.set_scan_program(null)

			src.cartridge.set_loc(T)
			if (istype(user))
				user.put_in_hand_or_eject(src.cartridge) // try to eject it into the users hand, if we can
			src.cartridge = null

		return

	proc/eject_cash(var/mob/user as mob)
		if (src.loc == user && src.ID_card && src.accessed_record)
			var/amount = tgui_input_number(usr, "How much would you like to withdraw?", "Withdrawal", 0, src.accessed_record["current_money"], 0)
			if (src.loc != user || !src.ID_card || !src.accessed_record)
				// no withdrawing after you're gone
				return
			if (amount < 1)
				boutput(usr, SPAN_ALERT("Invalid amount!"))
				return
			if(amount > src.accessed_record["current_money"])
				boutput(usr, SPAN_ALERT("Insufficient funds in account."))
			else
				src.accessed_record["current_money"] -= amount
				var/obj/item/currency/spacecash/S = new /obj/item/currency/spacecash
				S.setup(src.loc, amount)
				usr.put_in_hand_or_drop(S)
				boutput(user, SPAN_NOTICE("Withdrawal successful. Your account now has [src.accessed_record["current_money"]] credits."))
				playsound(src.loc, 'sound/machines/printer_cargo.ogg', 50, 1)
		return

	proc/insert_cash(var/obj/item/currency/spacecash/cash as obj, var/mob/user as mob)
		if (src.ID_card && src.accessed_record)
			src.accessed_record["current_money"] += cash.amount
			boutput(user, SPAN_NOTICE("You insert [cash] into \the [src]. Your account now has [src.accessed_record["current_money"]] credits."))
			cash.amount = 0
			qdel(cash)
			playsound(src.loc, 'sound/machines/paper_shredder.ogg', 50, 1)
			src.updateSelfDialog()
		else
			if (src.ID_card && !src.accessed_record)
				boutput(user, SPAN_ALERT("\The [src] refuses your [cash]. The inserted ID card doesn't have a bank account associated with it."))
			else if (!src.ID_card)
				boutput(user, SPAN_ALERT("\The [src] refuses your [cash]. There is no ID card inserted."))
		return

	proc/eject_id_card(var/mob/user as mob)
		if (src.ID_card)
			src.registered = null
			src.assignment = null
			src.access = null
			src.accessed_record = null
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
		src.accessed_record = data_core.bank.find_record("name", ID.registered)
		if (!src.ID_image)
			src.ID_image = image(src.icon, "blank")
		src.ID_image = src.ID_card.icon_state
		src.underlays += src.ID_image
		src.updateSelfDialog()
		user.UpdateName()

	proc/eject_pen(var/mob/user as mob)
		if (src.pen)
			if (istype(user))
				user.put_in_hand_or_drop(src.pen)
			else
				var/turf/T = get_turf(src)
				src.pen.set_loc(T)
			src.pen = null
			src.UpdateOverlays(null, "pen")
			return

	proc/insert_pen(obj/item/insertedPen, mob/user)
		if (!istype(insertedPen))
			return
		if (user)
			user.u_equip(insertedPen)
			insertedPen.set_loc(src)
			src.pen = insertedPen
			if(istype(insertedPen, /obj/item/clothing/mask/cigarette))
				src.UpdateOverlays(image(src.icon, "cig"), "pen")
			else if(istype(insertedPen, /obj/item/pen/crayon))
				var/image/pen_overlay = image(src.icon, "crayon")
				pen_overlay.color = insertedPen.color
				src.UpdateOverlays(pen_overlay, "pen")
			else if(istype(insertedPen, /obj/item/pen/pencil))
				src.UpdateOverlays(image(src.icon, "pencil"), "pen")
			else
				src.UpdateOverlays(image(src.icon, "pen"), "pen")
			var/original_icon_state = src.icon_state
			animate(src, time=0, icon_state="")
			animate(time=2, icon_state=original_icon_state)
			animate(time=2, transform=matrix(null, 0, -1, MATRIX_TRANSLATE))
			animate(time=3, transform=null)
			boutput(user, SPAN_NOTICE("You insert [insertedPen] into [src]."))

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

	proc/update_overlay(mode = null)
		if (mode)
			src.current_overlay = mode
		src.UpdateOverlays(src.overlay_images[src.current_overlay], "screen_overlay")

	/// Takes a ringtone datum and outputs the program that supposedly holds it
	proc/ringtone2program(var/ringtone)
		if(istype(ringtone, /datum/ringtone))
			var/datum/ringtone/RTone = ringtone
			ringtone = RTone.name
		switch(ringtone)
			if("Two-Beep")
				return /datum/computer/file/pda_program/ringtone
			if("WOLF PACK", "dog pack")
				return /datum/computer/file/pda_program/ringtone/dogs
			if("Norman Number's Counting Safari")
				return /datum/computer/file/pda_program/ringtone/numbers
			if("Nooty's Tooter", "Buzzo's Bleater", "Hobo's Harp")
				return /datum/computer/file/pda_program/ringtone/clown
			if("Retrospection", "Introspection", "Perspection", "Inspection", "Spectrum", "Spectral", "Refraction", "Reboundance", "Reflection", "Relaxation", "Stance")
				return /datum/computer/file/pda_program/ringtone/basic
			if("Spacechimes", "Shy Spacechimes", "Perky Spacechimes", "Sedate Spacechimes", "Focused Spacechimes")
				return /datum/computer/file/pda_program/ringtone/chimes
			if("BEEP 2: The Fourth", "Moonlit Peahen", "Plinkoe's Journey", "ringtone.dm,58: Cannot read null.name", "Fweeuweeu")
				return /datum/computer/file/pda_program/ringtone/beepy
			if("KABLAMMO - Realistic Explosion FX", "Modern Commando - Realistic Gunfire FX", "Plinkoe's Journey", "ringtone.dm,58: Cannot read null.name", "Fweeuweeu")
				return /datum/computer/file/pda_program/ringtone/syndie
			else
				return /datum/computer/file/pda_program/ringtone

	proc/set_ringtone(var/datum/ringtone/RT, var/temp = 0, var/overrideAlert = 0, var/groupType, var/groupName, var/announceIt = 1)
		if(!istype(RT)) // Invalid ringtone? use the default
			qdel(src.r_tone)
			qdel(src.r_tone_temp)
			src.r_tone = new/datum/ringtone(src)
			src.r_tone_temp = new/datum/ringtone(src)
			if (ismob(src.loc))
				var/mob/B = src.loc
				B.show_message(SPAN_ALERT("FATAL RINGTONE ERROR! Please call 1-800-IM-CODER."), 1)
				B.show_message(SPAN_ALERT("Restoring backup ringtone..."), 1)
			return
		else
			if(temp)
				qdel(src.r_tone_temp)
				src.r_tone_temp = RT
				src.r_tone_temp.holder = src
				if(overrideAlert)
					src.r_tone_temp.overrideAlert = overrideAlert
			else
				switch(groupType)
					if("main")
						qdel(src.r_tone)
						src.r_tone = RT
						src.r_tone.holder = src
						if(overrideAlert)
							src.r_tone.overrideAlert = overrideAlert
					if("alert")
						if(groupName in src.alert_ringtones)
							qdel(src.alert_ringtones[groupName])
							src.alert_ringtones[groupName] = RT
							var/datum/ringtone/RTone = src.alert_ringtones[groupName]
							RTone.holder = src
							if(overrideAlert)
								RTone.overrideAlert = overrideAlert
					if("mailgroup")
						if(groupName in src.mailgroup_ringtones)
							qdel(src.mailgroup_ringtones[groupName])
							src.mailgroup_ringtones -= groupName
						src.mailgroup_ringtones[groupName] = RT
						var/datum/ringtone/RTone = src.mailgroup_ringtones[groupName]
						RTone.holder = src
						if(overrideAlert)
							RTone.overrideAlert = overrideAlert
				if (announceIt && ismob(src.loc))
					var/mob/M = src.loc
					M.show_message("[bicon(src)] [RT?.succText]")

	proc/bust_speaker()
		src.visible_message(SPAN_ALERT("[src]'s tiny speaker explodes!"))
		playsound(src, 'sound/impact_sounds/Machinery_Break_1.ogg', 20, TRUE)
		elecflash(src, radius=1, power=1, exclude_center = 0)
		src.speaker_busted = 1

	proc/route_ringtone(var/list/groupID, var/recent)
		if(!islist(groupID))
			groupID = list(groupID)
		for(var/alert in groupID) // Alerts get priority
			if(alert in src.alert_ringtones)
				if(istype(src.alert_ringtones[alert], /datum/ringtone))
					var/datum/ringtone/rtone = src.alert_ringtones[alert]
					. = rtone.PlayRingtone(recent)
					break
		if(!.)
			for(var/group in groupID)
				if(group in src.mailgroup_ringtones)
					if(istype(src.mailgroup_ringtones[group], /datum/ringtone))
						var/datum/ringtone/rtone = src.mailgroup_ringtones[group]
						. = rtone.PlayRingtone(recent)
						break
		if(!.)
			return src.r_tone?.PlayRingtone(recent)

	proc/display_alert(var/alert_message, var/previewRing, var/list/groupID, var/recent) //Add alert overlay and beep
		if (alert_message && !src.speaker_busted)
			if(previewRing && istype(src.r_tone_temp))
				. = src.r_tone_temp?.PlayRingtone()
			else
				. = src.route_ringtone(groupID, recent)
			if(. && (src.r_tone?.overrideAlert || src.r_tone_temp?.overrideAlert))
				alert_message = .

			src.audible_message("[bicon(src)] *[alert_message]*")

			//this one prob sloewr
			//for (var/mob/O in hearers(3, src.loc))

		update_overlay("alert")
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
			src.set_host_program(program)

		if(istype(program, /datum/computer/file/pda_program/scan))
			if(program == src.scan_program)
				src.set_scan_program(null)
			else
				src.set_scan_program(program)
			return 1

		src.set_active_program(program)
		program.init()

		if(program.setup_use_process) processing_items |= src

		return 1

	proc/unload_active_program()
		if(src.active_program == src.host_program)
			return 1

		if(src.active_program.setup_use_process && !src.host_program.setup_use_process)
			processing_items.Remove(src)

		if(src.host_program && src.host_program.holder && (src.host_program.holder in src.contents))
			src.run_program(src.host_program)
		else
			src.set_active_program(null)

		src.updateSelfDialog()
		return 1

	proc/delete_file(datum/computer/file/theFile)
		//boutput(world, "Deleting [file]...")
		if((!theFile) || (!theFile.holder) || (theFile.holder.read_only))
			//boutput(world, "Cannot delete :(")
			return 0

		//Don't delete the running program you jerk
		if(src.active_program == theFile || src.host_program == theFile)
			src.set_active_program(null)

		//boutput(world, "Now calling del on [file]...")
		//qdel(file)
		theFile.dispose()
		return 1

	proc/explode()
		if (src.bombproof)
			if (ismob(src.loc))
				boutput(src.loc, SPAN_ALERT("<b>ALERT:</b> An attempt to run malicious explosive code on your PDA has been blocked."))
			return

		if(src in bible_contents)
			for_by_tcl(B, /obj/item/bible)
				var/turf/T = get_turf(B.loc)
				if(T)
					T.hotspot_expose(700,125)
					explosion(src, T, -1, -1, 2, 3)
			qdel(src)
			return

		var/turf/T = get_turf(src.loc)

		if (ismob(src.loc))
			var/mob/M = src.loc
			M.show_message(SPAN_ALERT("Your [src] explodes!"), 1)

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
		ai.eyecam.playsound_local_not_inworld('sound/machines/twobeep.ogg', 35)
		ai.eyecam.show_message(message)
	if (ismob(ai.deployed_shell))
		var/mob/M = ai.deployed_shell
		M.show_message(message)

/obj/item/device/pda2/ai/is_user_in_interact_range(var/mob/user)
	if (issilicon(user))
		var/mob/living/silicon/S = user
		if (S.mainframe && S.mainframe == loc)
			return 1
	if (isAIeye(user))
		var/mob/living/intangible/aieye/E = user
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
<li>Modules: Light up your life with a flashlight, or see right through the floor with a T-ray Scanner! The choice is yours!</li>
</ul></i>
<b>To send a file with the messenger:</b><br>
Enter the file browser and copy the file you want to send.  Now enter the messenger and select *send file*.<br>
<br>
ThinkOS 7 supports a wide variety of software solutions, ranging from robot interface systems to forensic and medical scanners.<br>
<font size=1>This technology produced by Thinktronic Systems, LTD for the NanoTrasen Corporation</font>
"}

/datum/computer/file/text/pda2manual/knockoff
	name = "User Guide!"

	data = {"
ElecTek 5 Personnel Data Actuator Manual<br>
Operating System: ThoughtOS 1.2<hr>
ThoughtOS 1.2 appears with several useful application!<br>
<i><ul>
<li>Notemaker: Load, edit, and save text files just like this one!</li>
<li>Messenger: Send messages between all enabled PDAs.  Can also send the current file in the clipboard.</li>
<li>File Browser: Manage and execute programs in the internal drive or loaded cartridge.</li>
<li>Atmos Scanner: Using patented AirScan technology.</li>
<li>Modules: Light up your life with a flashlight, or see right through the floor with a T-ray Scanner! The choice is yours!</li>
</ul></i>
<b>To send a file with the messenger:</b><br>
Enter the file browser and copy the file you want to send.  Now enter the messenger and select *send file*.<br>
<br>
<font size=1>This technology produced by ElecTek LTD, part of the BonkTek Consortium!</font>
"}
