TYPEINFO(/obj/machinery/codereader)
	mats = list("metal" = 15, "conductive" = 10)

/obj/machinery/codereader
	name = "codereader"
	desc = "A large device for reading security codes from floppy disks."
	icon = 'icons/obj/machines/codereader.dmi'
	icon_state = "codereader"
	anchored = ANCHORED
	deconstruct_flags = DECON_SCREWDRIVER | DECON_CROWBAR | DECON_WIRECUTTERS | DECON_MULTITOOL
	var/obj/item/disk/data/floppy/inserted_disk

/obj/machinery/codereader/was_deconstructed_to_frame(mob/user)
	. = ..()
	src.eject_disk()

/obj/machinery/codereader/update_icon(...)
	if (!src.inserted_disk)
		src.ClearSpecificOverlays("inserted_disk")
	else
		var/image/overlay = image(src.icon, "disk_overlay")
		overlay.color = src.inserted_disk.disk_color
		src.UpdateOverlays(overlay, "inserted_disk")

/obj/machinery/codereader/attackby(obj/item/I, mob/user)
	if (istype(I, /obj/item/disk/data/floppy))
		src.insert_disk(I, user)
		return
	. = ..()

/obj/machinery/codereader/attack_hand(mob/user)
	if (src.inserted_disk)
		src.eject_disk(user)
		return
	. = ..()

/obj/machinery/codereader/proc/insert_disk(obj/item/disk/data/floppy/disk, mob/user)
	if(!istype(disk)) return
	if(src.inserted_disk)
		boutput(user, SPAN_NOTICE("[src] already has a disk in it!"))
		return
	logTheThing(LOG_STATION, user, "inserts [disk.type] to a codereader at [log_loc(src)]")
	user?.drop_item(disk)
	disk.set_loc(src)
	src.inserted_disk = disk
	src.process_disk(user)
	playsound(src, 'sound/items/floppy_disk.ogg', 30, TRUE)
	src.UpdateIcon()

/obj/machinery/codereader/proc/eject_disk(mob/user)
	if(!src.inserted_disk) return
	src.inserted_disk.set_loc(get_turf(src))
	user?.put_in_hand_or_drop(src.inserted_disk)
	src.inserted_disk = null
	playsound(src, 'sound/items/floppy_disk.ogg', 30, TRUE)
	src.UpdateIcon()

#define IS_REAL_READABLE_NETPASS(x) (x in list(netpass_heads, netpass_security, netpass_medical, netpass_login))
/obj/machinery/codereader/proc/process_disk(mob/user)
	if(!src.inserted_disk || !istype(src.inserted_disk))
		return FALSE
	var/found_codes = list()
	for(var/datum/computer/file/record/record in src.inserted_disk.root.contents)
		for(var/field in record.fields)
			if(!IS_REAL_READABLE_NETPASS(record.fields[field]))
				continue
			found_codes += list("[field]" = record.fields[field])
	if(length(found_codes))
		src.print_codes(found_codes)
		return TRUE
	return FALSE
#undef IS_REAL_READABLE_NETPASS

/obj/machinery/codereader/proc/print_codes(var/list/codes)
	if(!codes) return FALSE
	var/printtext = ""
	for(var/code in codes)
		printtext += "[code]: [codes[code]]<br>"
	src.UpdateOverlays(image(src.icon, "printing_overlay"), "printing_overlay")
	playsound(src, 'sound/machines/printer_thermal.ogg', 50, TRUE)
	SPAWN(3 SECONDS)
		src.UpdateOverlays(null, "printing_overlay")
		var/obj/item/paper/printed_paper = new /obj/item/paper/thermal(src.loc)
		printed_paper.name = "Authorisation Passes"
		printed_paper.desc = "Network authorisation passes confirmed by a codereader."
		printed_paper.info = printtext
		//offset so it looks like it came out the printer tray
		printed_paper.pixel_x = src.pixel_x + 2
		printed_paper.pixel_y = src.pixel_y + 9
	return TRUE

/obj/machinery/codereader/syndicate
	name = "syndicate codereader"
	desc = "A large device for stealing NanoTrasen security codes from floppy disks."
	icon_state = "codereader_syndicate"
	is_syndicate = TRUE
	var/id = "listening_post_inner"
	var/static/authdisk_uploaded_by = null

	get_help_message(dist, mob/user)
		if (!src.authdisk_uploaded_by)
			. = "You can insert the <b>Authentication Disk</b> to open the listening post barracks."

/obj/machinery/codereader/syndicate/process_disk(mob/user)
	if(istype(src.inserted_disk, /obj/item/disk/data/floppy/read_only/authentication) && !src.authdisk_uploaded_by)
		src.authdisk_uploaded_by = (user?.real_name || "Unknown")
		var/list/antag_roles = list()
		var/list/bought_items = list()
		for (var/datum/antagonist/antag_role in user.mind.antagonists)
			antag_roles += antag_role.display_name
			if (istype(antag_role, /datum/antagonist/traitor))
				var/datum/antagonist/traitor/traitor = antag_role
				for (var/datum/syndicate_buylist/bought in traitor.purchased_items)
					bought_items += bought.name
			if (istype(antag_role, /datum/antagonist/spy_thief))
				var/datum/antagonist/spy_thief/spief = antag_role
				for (var/datum/syndicate_buylist/redeemed in spief.redeemed_items)
					bought_items += redeemed.name
		logTheThing(LOG_STATION, user, "unlocks the listening post barracks by inserting an auth disk into [src]")
		// ircbot.export_async("admin_debug", list("msg"="<@844525423412379668>: [user] ([user.ckey]), job: [user.job], antag role: [english_list(antag_roles)], bought items: [english_list(bought_items)] unlocked the listening post barracks with [src.inserted_disk] at [ticker.round_elapsed_ticks/(1 MINUTE)] minutes shift time"))
		SPAWN(3 SECONDS)
			for (var/obj/machinery/door/airlock/airlock in by_type[/obj/machinery/door])
				if (airlock.id == src.id)
					airlock.bolt_open()
	return ..()
