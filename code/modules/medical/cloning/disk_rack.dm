#define LIGHT_KEY "angry_light_[i]"

ADMIN_INTERACT_PROCS(/obj/machinery/disk_rack, proc/add_disk_of_type, proc/delete_disk_in_slot)
TYPEINFO(/obj/machinery/disk_rack)
	mats = list("metal" = 30, "conductive" = 10)

/obj/machinery/disk_rack
	name = "disk rack"
	desc = "A big clunky rack for storing floppy disks in."
	icon = 'icons/obj/disk_rack.dmi'
	icon_state = "disk_rack"
	layer = STORAGE_LAYER
	density = TRUE
	anchored = ANCHORED
	deconstruct_flags = DECON_SCREWDRIVER | DECON_CROWBAR | DECON_WIRECUTTERS | DECON_MULTITOOL
	requires_power = FALSE //we handle our own power stuff
	var/list/obj/item/disk/data/disks[DISK::RACK::MAX_DISKS]
	var/list/active_lights[DISK::RACK::MAX_DISKS]
	var/accepted_disk_type = /obj/item/disk/data/floppy
	var/disk_overlay_state = "disk_overlay"

/obj/machinery/disk_rack/New()
	. = ..()
	src.AddComponent(/datum/component/side_by_side, /obj/machinery/disk_rack, 8, 0)

/obj/machinery/disk_rack/was_deconstructed_to_frame(mob/user)
	. = ..()
	for (var/i in 1 to DISK::RACK::MAX_DISKS)
		if (disks[i])
			src.remove_disk(i)

/obj/machinery/disk_rack/update_icon(...)
	for (var/i in 1 to DISK::RACK::MAX_DISKS)
		var/obj/item/disk/data/disk = src.disks[i]
		if (!disk)
			src.ClearSpecificOverlays("disks_[i]")
			continue
		var/image/overlay = image(src.icon, disk_overlay_state)
		overlay.color = disk.disk_color
		overlay.pixel_y = (i-1) * 2
		src.UpdateOverlays(overlay, "disks_[i]")

/obj/machinery/disk_rack/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "DiskRack", src.name)
		ui.open()

/obj/machinery/disk_rack/ui_data(mob/user)
	var/list/disk_data[DISK::RACK::MAX_DISKS]
	for (var/i in 1 to DISK::RACK::MAX_DISKS)
		disk_data[i] = list()
		disk_data[i]["litColor"] = "#f00"
		disk_data[i]["unlitColor"] = "#940"
		#ifdef XMAS
		if (i % 2)
			disk_data[i]["litColor"] = "#0f0"
			disk_data[i]["unlitColor"] = "#490"
		#endif
		var/obj/item/disk/data/disk = src.disks[i]
		if (disk)
			disk_data[i]["disk"] = list()
			disk_data[i]["disk"] = list("name" = disk.disk_name(), "color" = disk.disk_color)
			disk_data[i]["disk"] += src.special_disk_data(disk, i)
	return list("disk_slots" = disk_data)

/obj/machinery/disk_rack/proc/special_disk_data(obj/item/disk/data/floppy/disk, index)
	return list()

/obj/machinery/disk_rack/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if (.)
		return .
	if (action == "diskAction")
		var/index = text2num_safe(params["dmIndex"])
		if (index < 1 || index > DISK::RACK::MAX_DISKS) //nu
			return FALSE
		if (BOUNDS_DIST(ui.user, src) || isintangible(ui.user))
			return FALSE
		if (src.disks[index])
			src.remove_disk(index, ui.user)
			return TRUE
		var/disk = ui.user.equipped()
		if (!istype(disk, accepted_disk_type))
			return FALSE
		src.insert_disk(index, disk, ui.user)
		return TRUE

/obj/machinery/disk_rack/proc/remove_disk(index, mob/user)
	var/obj/item/disk/data/disk = src.disks[index]
	disk.set_loc(get_turf(src))
	user?.put_in_hand_or_drop(disk)
	src.disks[index] = null
	playsound(src, 'sound/items/floppy_disk.ogg', 30, TRUE)
	src.update_lights()
	src.UpdateIcon()

/obj/machinery/disk_rack/proc/insert_disk(index, obj/item/disk/data/disk, mob/user)
	if (!istype(disk, src.accepted_disk_type))
		if (user)
			boutput(user, SPAN_ALERT("This disk rack cannot accept a disk of this size!"))
		return FALSE
	src.disks[index] = disk
	user?.drop_item(disk)
	disk.set_loc(src)
	playsound(src, 'sound/items/floppy_disk.ogg', 30, TRUE)
	src.update_lights()
	src.UpdateIcon()
	return TRUE

/obj/machinery/disk_rack/attackby(obj/item/disk/data/disk, mob/user)
	if (istype(disk, src.accepted_disk_type))
		for (var/i in 1 to DISK::RACK::MAX_DISKS)
			if (src.disks[i])
				continue
			src.insert_disk(i, disk, user)
			tgui_process.update_uis(src)
			return
	. = ..()

/obj/machinery/disk_rack/process(mult)
	. = ..()
	src.update_lights()

/obj/machinery/disk_rack/power_change()
	..()
	if (status & NOPOWER)
		for (var/i in 1 to DISK::RACK::MAX_DISKS)
			src.ClearSpecificOverlays(LIGHT_KEY)

/obj/machinery/disk_rack/proc/update_lights()
	if (status & NOPOWER)
		return

	for (var/i in 1 to DISK::RACK::MAX_DISKS)
		if (!src.disk_should_blink(i))
			src.ClearSpecificOverlays(LIGHT_KEY)
			src.active_lights[i] = FALSE
			continue

		src.active_lights[i] = TRUE
		if (src.GetOverlayImage(LIGHT_KEY))
			continue
		var/image/overlay = image(src.icon, "angry_light")
		overlay.color = "#f00"
		#ifdef XMAS
		if (i % 2)
			overlay.color = "#0f0"
		#endif
		overlay.plane = PLANE_SELFILLUM
		overlay.pixel_y = (i-1) * 2
		src.UpdateOverlays(overlay, LIGHT_KEY)

/obj/machinery/disk_rack/proc/disk_should_blink(index)
	return FALSE

/obj/machinery/disk_rack/proc/add_disk_of_type()
	set name = "Add Disk"
	var/chosen = tgui_input_list(usr, "Select disk type to add", "Disk To Add", concrete_typesof(src.accepted_disk_type))
	if (chosen)
		var/obj/item/disk/data/new_disk = new chosen(src)
		for (var/i in 1 to DISK::RACK::MAX_DISKS)
			if (src.disks[i])
				continue
			src.insert_disk(i, new_disk, null)
			tgui_process.update_uis(src)
			return

/obj/machinery/disk_rack/proc/delete_disk_in_slot()
	set name = "Delete Disk"
	var/list/choices = list()
	for (var/i in 1 to DISK::RACK::MAX_DISKS)
		if (src.disks[i])
			var/obj/item/disk/data/disk_choice = src.disks[i]
			choices.Add(disk_choice.name)
	if (length(choices) == 0)
		boutput(usr, "Hey! No disks in this rack! What are you gonna delete?")
		return
	var/chosen = tgui_input_list(usr, "Select disk to DELETE", "Disk to DELETE", choices)
	if (!chosen)
		return

	for (var/i in 1 to DISK::RACK::MAX_DISKS)
		if (src.disks[i])
			var/obj/item/disk/data/disk_check = src.disks[i]
			if (disk_check.name == chosen)
				src.remove_disk(i)
				qdel(disk_check)
				break

/obj/machinery/disk_rack/clone
	name = "clone rack"
	desc = "A big clunky rack for storing cloning records in."
	icon_state = "clone_rack_med"
	var/emagged = FALSE
	var/net_id
	var/list/received_deaths[DISK::RACK::MAX_DISKS]

/obj/machinery/disk_rack/clone/New()
	. = ..()
	if (!src.net_id)
		src.net_id = generate_net_id(src)
	MAKE_DEFAULT_RADIO_PACKET_COMPONENT(src.net_id, null, FREQ_CLONER_IMPLANT)

/obj/machinery/disk_rack/clone/receive_signal(datum/signal/signal, receive_method, receive_param, connection_id)
	if(signal.data["sender"] && signal.data["command"] == "clone_record_death")
		var/uid = signal.data["bio_id"]
		for (var/i in 1 to DISK::RACK::MAX_DISKS)
			var/obj/item/disk/data/floppy/disk = src.disks[i]
			if (!disk)
				continue
			var/datum/computer/file/clone/clone_record = locate() in disk.root.contents
			if (!clone_record)
				continue
			var/datum/bioHolder/stored_bioholder = clone_record["holder"]
			if (stored_bioholder.Uid == uid)
				src.received_deaths[i] = TRUE

/obj/machinery/disk_rack/clone/insert_disk(index, obj/item/disk/data/floppy/disk, mob/user)
	..()
	src.received_deaths[index] = FALSE

/obj/machinery/disk_rack/clone/proc/cloneable_disk(index)
	var/obj/item/disk/data/floppy/disk = src.disks[index]
	if (!(locate(/datum/computer/file/clone) in disk.root.contents)) //no record = no clone
		return FALSE
	return src.received_deaths[index]

/obj/machinery/disk_rack/clone/special_disk_data(obj/item/disk/data/floppy/disk, index)
	if (status & NOPOWER)
		return list("light" = FALSE)
	return list("light" = src.active_lights[index])

/obj/machinery/disk_rack/clone/ui_data(mob/user)
	return ..() + list("has_lights" = TRUE)

/obj/machinery/disk_rack/clone/emag_act(mob/user, obj/item/card/emag/E)
	if (src.emagged)
		return FALSE
	boutput(user, SPAN_ALERT("You short out [src]'s ImplantSense™ control module!"))
	src.emagged = TRUE
	src.processing_tier = PROCESSING_32TH
	return TRUE

/obj/machinery/disk_rack/clone/disk_should_blink(index)
	if (!index || index < 1 || index > DISK::RACK::MAX_DISKS || !src.disks[index])
		return FALSE
	if (src.cloneable_disk(index) || src.emagged && prob(20))
		return TRUE

/obj/machinery/disk_rack/office
	New()
		. = ..()
		var/i = 1
		for (var/type in childrentypesof(/obj/item/disk/data/floppy/office))
			src.insert_disk(i++, new type)

/obj/machinery/disk_rack/wide_disk
	icon_state = "disk_rack_wide"
	accepted_disk_type = /obj/item/disk/data/wide_floppy
	disk_overlay_state = "disk_overlay_wide"

/obj/spawner/clone_rack
	icon = 'icons/obj/disk_rack.dmi'
	icon_state = "spawner"

	New()
		. = ..()
		var/obj/machinery/disk_rack/clone/rack = new(get_turf(src))
		rack.pixel_x = 8
		rack = new(get_turf(src))
		rack.pixel_x = -8
		qdel(src)

#undef LIGHT_KEY
