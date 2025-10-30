#define MAX_DISKS 8
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
	var/list/obj/item/disk/data/floppy/disks[MAX_DISKS]
	var/list/active_lights[MAX_DISKS]

/obj/machinery/disk_rack/New()
	. = ..()
	src.AddComponent(/datum/component/side_by_side, /obj/machinery/disk_rack, 8, 0)

/obj/machinery/disk_rack/was_deconstructed_to_frame(mob/user)
	. = ..()
	for (var/i in 1 to MAX_DISKS)
		if (disks[i])
			src.remove_disk(i)

/obj/machinery/disk_rack/update_icon(...)
	for (var/i in 1 to MAX_DISKS)
		var/obj/item/disk/data/floppy/disk = src.disks[i]
		if (!disk)
			src.ClearSpecificOverlays("disks_[i]")
			continue
		var/image/overlay = image(src.icon, "disk_overlay")
		overlay.color = disk.disk_color
		overlay.pixel_y = (i-1) * 2
		src.UpdateOverlays(overlay, "disks_[i]")

/obj/machinery/disk_rack/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "DiskRack", src.name)
		ui.open()

/obj/machinery/disk_rack/ui_data(mob/user)
	var/list/disk_data[MAX_DISKS]
	for (var/i in 1 to MAX_DISKS)
		var/obj/item/disk/data/floppy/disk = src.disks[i]
		if (disk)
			disk_data[i] = list("name" = disk.disk_name(), "color" = disk.disk_color)
			disk_data[i] += src.special_disk_data(disk, i)
	return list("disks" = disk_data)

/obj/machinery/disk_rack/proc/special_disk_data(obj/item/disk/data/floppy/disk, index)
	return list()

/obj/machinery/disk_rack/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if (.)
		return .
	if (action == "diskAction")
		var/index = text2num_safe(params["dmIndex"])
		if (index < 1 || index > MAX_DISKS) //nu
			return FALSE
		if (BOUNDS_DIST(ui.user, src) || isintangible(ui.user))
			return FALSE
		if (src.disks[index])
			src.remove_disk(index, ui.user)
			return TRUE
		var/obj/item/disk/data/floppy/disk = ui.user.equipped()
		if (!istype(disk))
			return FALSE
		src.insert_disk(index, disk, ui.user)
		return TRUE

/obj/machinery/disk_rack/proc/remove_disk(index, mob/user)
	var/obj/item/disk/data/floppy/disk = src.disks[index]
	disk.set_loc(get_turf(src))
	user?.put_in_hand_or_drop(disk)
	src.disks[index] = null
	playsound(src, 'sound/items/floppy_disk.ogg', 30, TRUE)
	src.UpdateIcon()

/obj/machinery/disk_rack/proc/insert_disk(index, obj/item/disk/data/floppy/disk, mob/user)
	src.disks[index] = disk
	user?.drop_item(disk)
	disk.set_loc(src)
	playsound(src, 'sound/items/floppy_disk.ogg', 30, TRUE)
	src.UpdateIcon()

/obj/machinery/disk_rack/attackby(obj/item/disk/data/floppy/disk, mob/user)
	if (istype(disk))
		for (var/i in 1 to MAX_DISKS)
			if (src.disks[i])
				continue
			src.insert_disk(i, disk, user)
			tgui_process.update_uis(src)
			return
	. = ..()

/obj/machinery/disk_rack/clone
	name = "clone rack"
	desc = "A big clunky rack for storing cloning records in."
	icon_state = "clone_rack_med"
	var/emagged = FALSE
	var/net_id
	var/list/last_heartbeats[MAX_DISKS]
	/// If we were a concerned mother, how long would our daughter have to have NOT TEXTED for us to assume they are dead?
	var/patience = 10 SECONDS

/obj/machinery/disk_rack/clone/New()
	. = ..()
	if (!src.net_id)
		src.net_id = generate_net_id(src)
	MAKE_DEFAULT_RADIO_PACKET_COMPONENT(src.net_id, null, FREQ_CLONER_IMPLANT)

/obj/machinery/disk_rack/clone/receive_signal(datum/signal/signal, receive_method, receive_param, connection_id)
	if(signal.data["sender"] && signal.data["command"] == "heartbeat")
		var/uid = signal.data["bio_id"]
		for (var/i in 1 to MAX_DISKS)
			var/obj/item/disk/data/floppy/disk = src.disks[i]
			if (!disk)
				continue
			var/datum/computer/file/clone/clone_record = locate() in disk.root.contents
			if (!clone_record)
				continue
			var/datum/bioHolder/stored_bioholder = clone_record["holder"]
			if (stored_bioholder.Uid == uid)
				src.last_heartbeats[i] = TIME

/obj/machinery/disk_rack/clone/insert_disk(index, obj/item/disk/data/floppy/disk, mob/user)
	..()
	src.last_heartbeats[index] = TIME //give us a grace period for the first heartbeat to turn up

/obj/machinery/disk_rack/clone/proc/cloneable_disk(index)
	var/obj/item/disk/data/floppy/disk = src.disks[index]
	if (!(locate(/datum/computer/file/clone) in disk.root.contents)) //no record = no clone
		return FALSE
	return TIME - src.last_heartbeats[index] > src.patience

/obj/machinery/disk_rack/clone/special_disk_data(obj/item/disk/data/floppy/disk, index)
	if (status & NOPOWER)
		return list("light" = FALSE)
	return list("light" = src.active_lights[index])

/obj/machinery/disk_rack/clone/ui_data(mob/user)
	return ..() + list("has_lights" = TRUE)

/obj/machinery/disk_rack/clone/process(mult)
	src.update_lights()

/obj/machinery/disk_rack/clone/remove_disk(index, mob/user)
	. = ..()
	src.update_lights()

#define LIGHT_KEY "angry_light_[i]"

/obj/machinery/disk_rack/clone/power_change()
	..()
	if (status & NOPOWER)
		for (var/i in 1 to MAX_DISKS)
			src.ClearSpecificOverlays(LIGHT_KEY)

/obj/machinery/disk_rack/clone/proc/update_lights()
	if (status & NOPOWER)
		return
	for (var/i in 1 to MAX_DISKS)
		var/obj/item/disk/data/floppy/disk = src.disks[i]
		if (!disk || !(src.cloneable_disk(i) || src.emagged && prob(20)))
			src.active_lights[i] = FALSE
			src.ClearSpecificOverlays(LIGHT_KEY)
			continue
		src.active_lights[i] = TRUE
		if (src.GetOverlayImage(LIGHT_KEY))
			continue
		var/image/overlay = image(src.icon, "angry_light")
		overlay.plane = PLANE_SELFILLUM
		overlay.pixel_y = (i-1) * 2
		src.UpdateOverlays(overlay, LIGHT_KEY)
#undef LIGHT_KEY

/obj/machinery/disk_rack/clone/emag_act(mob/user, obj/item/card/emag/E)
	if (src.emagged)
		return FALSE
	boutput(user, SPAN_ALERT("You short out [src]'s ImplantSense™ control module!"))
	src.emagged = TRUE
	src.processing_tier = PROCESSING_32TH
	return TRUE


/obj/machinery/disk_rack/office
	New()
		. = ..()
		var/i = 1
		for (var/type in childrentypesof(/obj/item/disk/data/floppy/office))
			src.insert_disk(i++, new type)

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
